package com.biblione.service;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.dto.UpdateReservationRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.WaitlistEntry;
import com.biblione.notification.service.NotificationService;
import com.biblione.repository.BookRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.repository.WaitlistRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BookReservationServiceTest {

    @Mock
    private BookRepository bookRepository;
    @Mock
    private ReservationRepository reservationRepository;
    @Mock
    private LoanRepository loanRepository;
    @Mock
    private SeatHoldRepository seatHoldRepository;
    @Mock
    private WaitlistRepository waitlistRepository;
    @Mock
    private NotificationService notificationService;

    private BookReservationService service;

    @BeforeEach
    void setUp() {
        service = new BookReservationService(
            bookRepository,
            reservationRepository,
            loanRepository,
            seatHoldRepository,
            waitlistRepository,
            notificationService
        );
    }

    @Test
    void reserveBookDecrementsStockAndCreatesHold() {
        Book book = Book.builder()
                .id("book-ddia")
                .title("Designing Data-Intensive Applications")
                .author("Martin Kleppmann")
                .availableCopies(3)
                .totalCopies(3)
                .shelfCode("CS-204")
                .expressHoldHours(24)
                .pickupDesk("Central Circulation Desk")
                .build();
        when(bookRepository.findById("book-ddia")).thenReturn(Optional.of(book));
        when(reservationRepository.existsByUserIdAndBookIdAndStatusIn(any(), any(), any())).thenReturn(false);
        when(bookRepository.save(any(Book.class))).thenAnswer(inv -> inv.getArgument(0));
        when(reservationRepository.save(any(Reservation.class))).thenAnswer(inv -> inv.getArgument(0));

        CreateReservationRequest request = new CreateReservationRequest();
        request.setUserId("IT23773158");
        request.setBookId("book-ddia");

        Reservation reservation = service.reserveBook(request);

        assertThat(book.getAvailableCopies()).isEqualTo(2);
        assertThat(reservation.getHoldIdCode()).startsWith("BBL-").endsWith("-DDIA");
        assertThat(reservation.getStatus()).isEqualTo("READY_FOR_PICKUP");
        assertThat(reservation.getExpiresAt()).isAfter(Instant.now().plus(23, ChronoUnit.HOURS));
    }

    @Test
    void reserveBookRejectedWhenNoCopies() {
        Book book = Book.builder().id("book-x").title("X").availableCopies(0).totalCopies(1).build();
        when(bookRepository.findById("book-x")).thenReturn(Optional.of(book));

        CreateReservationRequest request = new CreateReservationRequest();
        request.setUserId("u1");
        request.setBookId("book-x");

        assertThatThrownBy(() -> service.reserveBook(request)).isInstanceOf(ApiException.class);
        verify(reservationRepository, never()).save(any());
    }

    @Test
    void unshelvedCopiesAreUnavailableAndCanJoinWaitlist() {
        Book book = Book.builder().id("book-pending").title("Pending Book")
            .availableCopies(2).totalCopies(2).waitlistCount(2)
            .inventoryStatus("PENDING_SHELVING").build();
        when(bookRepository.findById("book-pending")).thenReturn(Optional.of(book));

        CreateReservationRequest request = new CreateReservationRequest();
        request.setUserId("u1");
        request.setBookId("book-pending");

        assertThat(book.isAvailable()).isFalse();
        assertThatThrownBy(() -> service.reserveBook(request)).isInstanceOf(ApiException.class);
        when(waitlistRepository.existsByUserIdAndBookIdAndStatus("u1", "book-pending", "WAITING"))
                .thenReturn(false);
        when(waitlistRepository.countByBookIdAndStatus("book-pending", "WAITING")).thenReturn(1L);
        when(waitlistRepository.save(any(WaitlistEntry.class))).thenAnswer(inv -> inv.getArgument(0));
        when(bookRepository.save(any(Book.class))).thenAnswer(inv -> inv.getArgument(0));

        WaitlistEntry entry = service.joinWaitlist(request);

        assertThat(entry.getQueuePosition()).isEqualTo(3);
        assertThat(book.getWaitlistCount()).isEqualTo(3);
        verify(reservationRepository, never()).save(any());
    }

    @Test
    void searchBooksIncludesTitlesAwaitingShelvingAndHidesArchivedTitles() {
        Book ready = Book.builder().id("book-ready").title("Ready Book").inventoryStatus("AVAILABLE").build();
        Book pending = Book.builder().id("book-pending").title("Pending Book").inventoryStatus("PENDING_SHELVING").build();
        Book archived = Book.builder().id("book-archived").title("Archived Book")
                .inventoryStatus("AVAILABLE").active(false).build();
        when(bookRepository.findAll()).thenReturn(java.util.List.of(ready, pending, archived));

        var results = service.searchBooks("", "");

        assertThat(results).containsExactly(ready, pending);
    }

    @Test
    void searchBooksMatchesPrefixesInsteadOfLettersInsideWords() {
        Book exactTitle = Book.builder().id("book-exact-title").title("A").build();
        Book exactAuthor = Book.builder().id("book-exact-author").title("Unknown Exact Author").author("A").build();
        Book titlePrefix = Book.builder().id("book-alpha").title("A Brief History").build();
        Book authorPrefix = Book.builder().id("book-author").title("Unknown Title").author("Ada Lovelace").build();
        Book categoryPrefix = Book.builder().id("book-category").title("Unknown Category Match").category("Astronomy").build();
        Book containsOnly = Book.builder().id("book-art").title("The Art of Search").build();
        when(bookRepository.findAll()).thenReturn(
            java.util.List.of(authorPrefix, categoryPrefix, titlePrefix, exactAuthor, containsOnly, exactTitle));

        var results = service.searchBooks("a", "");

        assertThat(results).containsExactly(exactTitle, exactAuthor, titlePrefix, authorPrefix, categoryPrefix);
    }

    @Test
    void cancelReservationRestoresStock() {
        Reservation reservation = Reservation.builder()
                .id("res-1")
                .bookId("book-ddia")
                .status("READY_FOR_PICKUP")
                .createdAt(Instant.now())
                .expiresAt(Instant.now().plus(24, ChronoUnit.HOURS))
                .build();
        Book book = Book.builder().id("book-ddia").availableCopies(1).totalCopies(3).build();
        when(reservationRepository.findById("res-1")).thenReturn(Optional.of(reservation));
        when(reservationRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(bookRepository.findById("book-ddia")).thenReturn(Optional.of(book));
        when(bookRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        service.cancelReservation("res-1");

        assertThat(reservation.getStatus()).isEqualTo("CANCELLED");
        assertThat(book.getAvailableCopies()).isEqualTo(2);
    }

    @Test
    void updateReservationChangesBookAndTransfersStockWithinManagementWindow() {
        Reservation reservation = Reservation.builder()
                .id("res-1")
                .userId("user-1")
                .bookId("old-book")
                .status("READY_FOR_PICKUP")
                .createdAt(Instant.now())
                .expiresAt(Instant.now().plus(24, ChronoUnit.HOURS))
                .build();
        Book oldBook = Book.builder()
                .id("old-book")
                .availableCopies(1)
                .totalCopies(3)
                .build();
        Book replacement = Book.builder()
                .id("new-book")
                .title("New Book")
                .author("New Author")
                .availableCopies(2)
                .totalCopies(3)
                .shelfCode("CS-210")
                .pickupDesk("North Desk")
                .pickupDeskDetail("Level 2, North Entrance")
                .build();
        UpdateReservationRequest request = new UpdateReservationRequest();
        request.setBookId("new-book");
        when(reservationRepository.findById("res-1")).thenReturn(Optional.of(reservation));
        when(reservationRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));
        when(reservationRepository.existsByUserIdAndBookIdAndStatusIn(
                "user-1", "new-book", BookReservationService.ACTIVE_RESERVATION_STATUSES))
                .thenReturn(false);
        when(bookRepository.findById("new-book")).thenReturn(Optional.of(replacement));
        when(bookRepository.findById("old-book")).thenReturn(Optional.of(oldBook));
        when(bookRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        Reservation updated = service.updateReservation("res-1", request);

        assertThat(updated.getBookId()).isEqualTo("new-book");
        assertThat(updated.getTitle()).isEqualTo("New Book");
        assertThat(updated.getPickupDesk()).isEqualTo("North Desk");
        assertThat(replacement.getAvailableCopies()).isEqualTo(1);
        assertThat(oldBook.getAvailableCopies()).isEqualTo(2);
    }

    @Test
    void updateReservationIsRejectedAfterManagementWindow() {
        Reservation reservation = Reservation.builder()
                .id("res-1")
                .userId("user-1")
                .bookId("old-book")
                .status("READY_FOR_PICKUP")
                .createdAt(Instant.now().minus(25, ChronoUnit.HOURS))
                .expiresAt(Instant.now().plus(1, ChronoUnit.HOURS))
                .build();
        UpdateReservationRequest request = new UpdateReservationRequest();
        request.setBookId("new-book");
        when(reservationRepository.findById("res-1")).thenReturn(Optional.of(reservation));

        assertThatThrownBy(() -> service.updateReservation("res-1", request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("within 24 hours");

        verify(reservationRepository, never()).save(any());
    }

    @Test
    void cancelReservationIsRejectedAfterManagementWindow() {
        Reservation reservation = Reservation.builder()
                .id("res-1")
                .bookId("book-ddia")
                .status("READY_FOR_PICKUP")
                .createdAt(Instant.now().minus(25, ChronoUnit.HOURS))
                .expiresAt(Instant.now().plus(1, ChronoUnit.HOURS))
                .build();
        when(reservationRepository.findById("res-1")).thenReturn(Optional.of(reservation));

        assertThatThrownBy(() -> service.cancelReservation("res-1"))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("within 24 hours");

        verify(reservationRepository, never()).save(any());
        verify(bookRepository, never()).findById("book-ddia");
    }

    @Test
    void renewLoanExtendsDueDate() {
        Instant due = Instant.parse("2026-10-18T00:00:00Z");
        Loan loan = Loan.builder().id("loan-1").status("ACTIVE").dueDate(due).renewCount(0).build();
        when(loanRepository.findById("loan-1")).thenReturn(Optional.of(loan));
        when(loanRepository.save(any())).thenAnswer(inv -> inv.getArgument(0));

        Loan renewed = service.renewLoan("loan-1");

        ArgumentCaptor<Loan> captor = ArgumentCaptor.forClass(Loan.class);
        verify(loanRepository).save(captor.capture());
        assertThat(renewed.getDueDate()).isEqualTo(due.plus(14, ChronoUnit.DAYS));
        assertThat(captor.getValue().getRenewCount()).isEqualTo(1);
    }

    @Test
    void acronymFromTitleUsesInitials() {
        assertThat(BookReservationService.acronymFromTitle("Designing Data-Intensive Applications"))
                .isEqualTo("DDIA");
    }
}
