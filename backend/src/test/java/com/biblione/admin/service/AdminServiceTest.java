package com.biblione.admin.service;

import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.dto.CreateTaskRequest;
import com.biblione.admin.dto.CreateHallRequest;
import com.biblione.admin.dto.CreateSeatRequest;
import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.Hall;
import com.biblione.admin.model.Shelf;
import com.biblione.admin.model.StaffTask;
import com.biblione.admin.model.TaskStatus;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.admin.repository.HallRepository;
import com.biblione.admin.repository.PublisherProposalRepository;
import com.biblione.admin.repository.ShelfRepository;
import com.biblione.admin.repository.StaffTaskRepository;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.repository.BookRepository;
import com.biblione.repository.SeatRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AdminServiceTest {

    @Mock
    private AdminUserRepository userRepository;
    @Mock
    private PublisherProposalRepository proposalRepository;
    @Mock
    private StaffTaskRepository taskRepository;
    @Mock
    private ShelfRepository shelfRepository;
    @Mock
    private BookRepository bookRepository;
        @Mock
        private SeatRepository seatRepository;
        @Mock
        private HallRepository hallRepository;
    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AdminService service;

    @Test
    void completingShelvingTaskPublishesBookAndUpdatesShelfCount() {
        StaffTask task = StaffTask.builder()
                .id("task-1")
                .bookId("book-1")
                .quantity(3)
                .targetShelfCode("CS-204")
                .status(TaskStatus.IN_PROGRESS)
                .build();
        Book book = Book.builder().id("book-1").totalCopies(3).availableCopies(0).build();
        Shelf shelf = Shelf.builder().shelfCode("CS-204").level("Level 2").zone("East Wing")
                .maxCapacity(50).currentBookCount(4).build();
        when(taskRepository.findById("task-1")).thenReturn(Optional.of(task));
        when(bookRepository.findById("book-1")).thenReturn(Optional.of(book));
        when(shelfRepository.findByShelfCodeIgnoreCase("CS-204")).thenReturn(Optional.of(shelf));
        when(bookRepository.save(any(Book.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(shelfRepository.save(any(Shelf.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(taskRepository.save(any(StaffTask.class))).thenAnswer(invocation -> invocation.getArgument(0));

        StaffTask completed = service.updateTaskStatus("task-1", new UpdateTaskStatusRequest(TaskStatus.COMPLETED, null));

        assertThat(completed.getStatus()).isEqualTo(TaskStatus.COMPLETED);
        assertThat(book.getAvailableCopies()).isEqualTo(3);
        assertThat(book.getInventoryStatus()).isEqualTo("AVAILABLE");
        assertThat(book.getShelfCode()).isEqualTo("CS-204");
        assertThat(shelf.getCurrentBookCount()).isEqualTo(7);
        verify(taskRepository).save(task);
    }

    @Test
    void shelvingTaskCannotOverfillShelf() {
        StaffTask task = StaffTask.builder().id("task-1").bookId("book-1").quantity(3)
                .targetShelfCode("CS-204").status(TaskStatus.IN_PROGRESS).build();
        Book book = Book.builder().id("book-1").totalCopies(3).availableCopies(0).build();
        Shelf shelf = Shelf.builder().shelfCode("CS-204").maxCapacity(5).currentBookCount(4).build();
        when(taskRepository.findById("task-1")).thenReturn(Optional.of(task));
        when(shelfRepository.findByShelfCodeIgnoreCase("CS-204")).thenReturn(Optional.of(shelf));
        when(bookRepository.findById("book-1")).thenReturn(Optional.of(book));

        assertThatThrownBy(() -> service.updateTaskStatus("task-1", new UpdateTaskStatusRequest(TaskStatus.COMPLETED, null)))
                .isInstanceOf(ApiException.class);
        assertThat(book.getAvailableCopies()).isZero();
    }

    @Test
    void shelvingAssignmentMustCoverTheWholeApprovedLot() {
        AdminUser staff = AdminUser.builder().id("staff-1").fullName("Library Staff")
                .role(UserRole.LIBRARY_STAFF).active(true).build();
        Book book = Book.builder().id("book-1").title("Spring Boot Essentials")
                .totalCopies(15).availableCopies(0).inventoryStatus("PENDING_SHELVING").build();
        when(userRepository.findById("staff-1")).thenReturn(Optional.of(staff));
        when(bookRepository.findById("book-1")).thenReturn(Optional.of(book));

        assertThatThrownBy(() -> service.createTask(new CreateTaskRequest(
                "staff-1", "book-1", book.getTitle(), "Shelve books", "CS-301", 10)))
                .isInstanceOf(ApiException.class);
        verify(taskRepository, never()).save(any(StaffTask.class));
    }

    @Test
    void shelfCodeEditUpdatesBooksAndOpenTaskTargets() {
        Shelf existing = Shelf.builder().id("shelf-1").shelfCode("CS-204").level("Level 2")
                .zone("East Wing").maxCapacity(50).currentBookCount(3).build();
        Shelf update = Shelf.builder().shelfCode("CS-205").level("Level 2").zone("North Wing")
                .maxCapacity(60).build();
        Book book = Book.builder().id("book-1").shelfCode("CS-204").build();
        StaffTask task = StaffTask.builder().id("task-1").targetShelfCode("CS-204").build();
        when(shelfRepository.findById("shelf-1")).thenReturn(Optional.of(existing));
        when(shelfRepository.findByShelfCodeIgnoreCase("CS-205")).thenReturn(Optional.empty());
        when(bookRepository.findByShelfCode("CS-204")).thenReturn(java.util.List.of(book));
        when(taskRepository.findByTargetShelfCode("CS-204")).thenReturn(java.util.List.of(task));
        when(bookRepository.save(any(Book.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(taskRepository.save(any(StaffTask.class))).thenAnswer(invocation -> invocation.getArgument(0));
        when(shelfRepository.save(any(Shelf.class))).thenAnswer(invocation -> invocation.getArgument(0));

        Shelf saved = service.updateShelf("shelf-1", update);

        assertThat(saved.getCurrentBookCount()).isEqualTo(3);
        assertThat(book.getShelfCode()).isEqualTo("CS-205");
        assertThat(book.getWayfinding()).isEqualTo("Level 2 • North Wing");
        assertThat(task.getTargetShelfCode()).isEqualTo("CS-205");
    }

        @Test
        void createHallNormalizesCodeAndRejectsDuplicate() {
                when(hallRepository.findByHallCodeIgnoreCase("NORTH")).thenReturn(Optional.empty());
                when(hallRepository.save(any(Hall.class))).thenAnswer(invocation -> invocation.getArgument(0));

                Hall hall = service.createHall(new CreateHallRequest(" north ", "North Library", "Main Campus", 3, "Quiet study"));

                assertThat(hall.getHallCode()).isEqualTo("NORTH");
                assertThat(hall.getFloorCount()).isEqualTo(3);
                when(hallRepository.findByHallCodeIgnoreCase("NORTH")).thenReturn(Optional.of(hall));
                assertThatThrownBy(() -> service.createHall(new CreateHallRequest("NORTH", "Other", "Main Campus", 1, null)))
                                .isInstanceOf(ApiException.class);
        }

        @Test
        void createSeatRequiresHallAndStoresRecommenderFeatures() {
                Hall hall = Hall.builder().hallCode("NORTH").name("North Library").build();
                when(seatRepository.findBySeatCodeIgnoreCase("A04")).thenReturn(Optional.empty());
                when(hallRepository.findByHallCodeIgnoreCase("NORTH")).thenReturn(Optional.of(hall));
                when(seatRepository.save(any())).thenAnswer(invocation -> invocation.getArgument(0));

                var seat = service.createSeat(new CreateSeatRequest(
                                "a04", "north", "Level 2", "Quiet Zone", true, 24, java.util.List.of(" power ", "window", "")));

                assertThat(seat.getSeatCode()).isEqualTo("A04");
                assertThat(seat.getHallCode()).isEqualTo("NORTH");
                assertThat(seat.getFeatures()).containsExactly("power", "window");
                when(hallRepository.findByHallCodeIgnoreCase("MISSING")).thenReturn(Optional.empty());
                assertThatThrownBy(() -> service.createSeat(new CreateSeatRequest(
                                "A05", "MISSING", "Level 2", "Quiet Zone", false, 30, java.util.List.of())))
                                .isInstanceOf(ApiException.class);
        }
}
