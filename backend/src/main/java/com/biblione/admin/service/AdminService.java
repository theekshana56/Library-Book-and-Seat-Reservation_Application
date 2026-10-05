package com.biblione.admin.service;

import com.biblione.admin.dto.AdminStatsResponse;
import com.biblione.admin.dto.CreateHallRequest;
import com.biblione.admin.dto.CreateBookRequest;
import com.biblione.admin.dto.CreateSeatRequest;
import com.biblione.admin.dto.CreateTaskRequest;
import com.biblione.admin.dto.CreateUserRequest;
import com.biblione.admin.dto.UpdateTaskRequest;
import com.biblione.admin.dto.UpdateTaskStatusRequest;
import com.biblione.admin.dto.UpdateUserRequest;
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
import com.biblione.admin.dto.UpdateUserStatusRequest;
import com.biblione.exception.ApiException;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.model.Book;
import com.biblione.model.Seat;
import com.biblione.repository.BookRepository;
import com.biblione.repository.SeatRepository;
import com.biblione.repository.SeatBookingRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.WaitlistRepository;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.model.SeatBookingStatus;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminUserRepository userRepository;
    private final PublisherProposalRepository proposalRepository;
    private final StaffTaskRepository taskRepository;
    private final ShelfRepository shelfRepository;
    private final BookRepository bookRepository;
    private final SeatRepository seatRepository;
    private final HallRepository hallRepository;
    private final SeatBookingRepository seatBookingRepository;
    private final ReservationRepository reservationRepository;
    private final LoanRepository loanRepository;
    private final WaitlistRepository waitlistRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminUser createUser(CreateUserRequest request) {
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "An account with this email already exists.");
        }
        return userRepository.save(AdminUser.builder()
                .fullName(request.fullName().trim())
                .email(email)
                .password(passwordEncoder.encode(request.password()))
                .role(request.role())
                .department(request.department())
                .userCategory(request.userCategory())
                .vendorCompanyName(request.role() == UserRole.VENDOR
                        ? blankToNull(request.vendorCompanyName()) == null
                                ? blankToNull(request.department())
                                : blankToNull(request.vendorCompanyName())
                        : null)
                .active(request.active() == null || request.active())
                .build());
    }

    public List<AdminUser> getUsers(UserRole role, Boolean active) {
        if (role != null && active != null) {
            return userRepository.findByRoleAndActive(role, active);
        }
        if (role != null) {
            return userRepository.findByRole(role);
        }
        return userRepository.findAll().stream()
                .filter(user -> active == null || user.isActive() == active)
                .toList();
    }

    public AdminUser updateUserStatus(String id, UpdateUserStatusRequest request) {
        AdminUser user = userRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found."));
        user.setActive(request.active());
        return userRepository.save(user);
    }

    public AdminUser getUser(String id) {
        return userRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User not found."));
    }

    public AdminUser updateUser(String id, UpdateUserRequest request) {
        AdminUser user = getUser(id);
        String email = request.email().trim().toLowerCase(Locale.ROOT);
        userRepository.findByEmailIgnoreCase(email)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new ApiException(HttpStatus.CONFLICT, "An account with this email already exists.");
                });
        user.setFullName(request.fullName().trim());
        user.setEmail(email);
        user.setRole(request.role());
        user.setDepartment(blankToNull(request.department()));
        user.setUserCategory(blankToNull(request.userCategory()));
        user.setVendorCompanyName(request.role() == UserRole.VENDOR
                ? blankToNull(request.vendorCompanyName()) : null);
        user.setActive(request.active());
        return userRepository.save(user);
    }

    public AdminStatsResponse getStats() {
        long capacity = shelfRepository.findAll().stream()
                .filter(shelf -> !Boolean.FALSE.equals(shelf.getActive()))
                .mapToLong(Shelf::getMaxCapacity).sum();
        long activeUsers = userRepository.findAll().stream().filter(AdminUser::isActive).count();
        return new AdminStatsResponse(
                userRepository.count(),
                taskRepository.countByStatusNotIn(List.of(TaskStatus.COMPLETED, TaskStatus.CANCELLED)),
                proposalRepository.countByStatus(com.biblione.admin.model.ProposalStatus.PENDING_ADMIN_REVIEW),
                capacity,
                activeUsers);
    }

    public List<Book> getPendingShelvingBooks() {
        return bookRepository.findByInventoryStatus("PENDING_SHELVING").stream()
                .filter(book -> !Boolean.FALSE.equals(book.getActive()))
                .toList();
    }

    public StaffTask updateTask(String id, UpdateTaskRequest request) {
        StaffTask task = taskRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Staff task not found."));
        if (task.getStatus() == TaskStatus.COMPLETED || task.getStatus() == TaskStatus.CANCELLED) {
            throw new ApiException(HttpStatus.CONFLICT, "Completed or cancelled tasks cannot be edited.");
        }
        AdminUser staff = userRepository.findById(request.assignedStaffId())
                .filter(user -> user.isActive() && user.getRole() == UserRole.LIBRARY_STAFF)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                        "The selected account is not active library staff."));
        String shelfCode = blankToNull(request.targetShelfCode());
        if (shelfCode != null && shelfRepository.findByShelfCodeIgnoreCase(shelfCode)
                .filter(shelf -> !Boolean.FALSE.equals(shelf.getActive())).isEmpty()) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Active target shelf not found.");
        }
        task.setAssignedStaffId(staff.getId());
        task.setAssignedStaffName(staff.getFullName());
        task.setTaskDescription(request.taskDescription().trim());
        task.setTargetShelfCode(shelfCode);
        return taskRepository.save(task);
    }

    public StaffTask cancelTask(String id) {
        StaffTask task = taskRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Staff task not found."));
        if (task.getStatus() == TaskStatus.COMPLETED || task.getStatus() == TaskStatus.CANCELLED) {
            throw new ApiException(HttpStatus.CONFLICT, "Completed or cancelled tasks cannot be cancelled.");
        }
        task.setStatus(TaskStatus.CANCELLED);
        return taskRepository.save(task);
    }

    public StaffTask createTask(CreateTaskRequest request) {
        AdminUser staff = userRepository.findById(request.assignedStaffId())
                .filter(user -> user.isActive() && user.getRole() == UserRole.LIBRARY_STAFF)
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST,
                        "The selected account is not active library staff."));

        Book book = null;
        if (request.bookId() != null && !request.bookId().isBlank()) {
            book = bookRepository.findById(request.bookId())
                    .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
            if (Boolean.FALSE.equals(book.getActive())) {
                throw new ApiException(HttpStatus.CONFLICT, "Archived books cannot be assigned to staff.");
            }
        }
        int quantity = request.quantity() == null ? (book == null ? 1 : book.getTotalCopies()) : request.quantity();
        if (book != null) {
            if (!"PENDING_SHELVING".equals(book.getInventoryStatus())) {
                throw new ApiException(HttpStatus.CONFLICT, "Only books awaiting shelving can be assigned as inventory tasks.");
            }
            int remaining = book.getTotalCopies() - book.getAvailableCopies();
            if (quantity != remaining) {
                throw new ApiException(HttpStatus.BAD_REQUEST, "A shelving task must cover all remaining copies in the approved lot.");
            }
            if (taskRepository.existsByBookIdAndStatusNotIn(
                    book.getId(), List.of(TaskStatus.COMPLETED, TaskStatus.CANCELLED))) {
                throw new ApiException(HttpStatus.CONFLICT, "This book already has an open shelving task.");
            }
        }

        String targetShelfCode = blankToNull(request.targetShelfCode());
        if (targetShelfCode != null && shelfRepository.findByShelfCodeIgnoreCase(targetShelfCode)
                .filter(shelf -> !Boolean.FALSE.equals(shelf.getActive())).isEmpty()) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Active target shelf not found.");
        }

        return taskRepository.save(StaffTask.builder()
                .assignedStaffId(staff.getId())
                .assignedStaffName(staff.getFullName())
                .bookId(book == null ? null : book.getId())
                .bookTitle(book == null ? request.bookTitle() : book.getTitle())
                .taskDescription(request.taskDescription().trim())
                .targetShelfCode(targetShelfCode)
                .quantity(quantity)
                .status(TaskStatus.PENDING)
                .createdAt(Instant.now())
                .build());
    }

    public List<StaffTask> getStaffTasks(String staffId, AuthenticatedUser currentUser) {
        if (currentUser.role() == UserRole.LIBRARY_STAFF && !staffId.equals(currentUser.id())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "You can only view your own assigned tasks.");
        }
        return taskRepository.findByAssignedStaffIdOrderByCreatedAtDesc(staffId);
    }

    public StaffTask updateTaskStatus(
            String id,
            UpdateTaskStatusRequest request,
            AuthenticatedUser currentUser) {
        StaffTask task = taskRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Staff task not found."));
        if (currentUser.role() == UserRole.LIBRARY_STAFF && !task.getAssignedStaffId().equals(currentUser.id())) {
            throw new ApiException(HttpStatus.FORBIDDEN, "You can only update your own assigned tasks.");
        }
        if (request.status() == TaskStatus.PENDING) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Task status can only move to IN_PROGRESS or COMPLETED.");
        }
        if (currentUser.role() != UserRole.ADMIN && request.status() == TaskStatus.CANCELLED) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Only administrators can cancel assigned tasks.");
        }
        if (task.getStatus() == TaskStatus.COMPLETED || task.getStatus() == TaskStatus.CANCELLED) {
            throw new ApiException(HttpStatus.CONFLICT, "Completed or cancelled tasks cannot be changed.");
        }
        if (request.targetShelfCode() != null && !request.targetShelfCode().isBlank()) {
            task.setTargetShelfCode(request.targetShelfCode().trim());
        }
        if (request.status() == TaskStatus.COMPLETED) {
            completeInventoryTask(task, request.targetShelfCode());
        }
        task.setStatus(request.status());
        return taskRepository.save(task);
    }

    private void completeInventoryTask(StaffTask task, String suppliedShelfCode) {
        if (task.getBookId() == null) {
            return;
        }
        String shelfCode = blankToNull(suppliedShelfCode);
        if (shelfCode == null) shelfCode = task.getTargetShelfCode();
        if (shelfCode == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "A shelf code is required to complete a shelving task.");
        }
        Shelf shelf = shelfRepository.findByShelfCodeIgnoreCase(shelfCode)
                .filter(item -> !Boolean.FALSE.equals(item.getActive()))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Shelf not found."));
        Book book = bookRepository.findById(task.getBookId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
        int quantity = task.getQuantity() > 0 ? task.getQuantity() : book.getTotalCopies();
        if (shelf.getCurrentBookCount() + quantity > shelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.CONFLICT, "The selected shelf does not have enough capacity.");
        }
        int available = Math.min(book.getTotalCopies(), book.getAvailableCopies() + quantity);
        book.setAvailableCopies(available);
        book.setShelfCode(shelf.getShelfCode());
        book.setShelfDetail(shelf.getLevel() + ", " + shelf.getZone());
        book.setWayfinding(shelf.getLevel() + " • " + shelf.getZone());
        book.setInventoryStatus("AVAILABLE");
        bookRepository.save(book);
        shelf.setCurrentBookCount(shelf.getCurrentBookCount() + quantity);
        shelfRepository.save(shelf);
        task.setTargetShelfCode(shelf.getShelfCode());
    }

    public Shelf createShelf(Shelf shelf) {
        shelf.setShelfCode(shelf.getShelfCode().trim().toUpperCase(Locale.ROOT));
        if (shelfRepository.findByShelfCodeIgnoreCase(shelf.getShelfCode()).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "A shelf with this code already exists.");
        }
        if (shelf.getCurrentBookCount() > shelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Current book count cannot exceed shelf capacity.");
        }
        if (shelf.getCurrentBookCount() < 0) shelf.setCurrentBookCount(0);
        shelf.setActive(true);
        return shelfRepository.save(shelf);
    }

    public List<Shelf> getShelves() {
        return shelfRepository.findAll();
    }

    public List<Shelf> getActiveShelves() {
        return shelfRepository.findAll().stream()
                .filter(shelf -> !Boolean.FALSE.equals(shelf.getActive()))
                .toList();
    }

    public Hall createHall(CreateHallRequest request) {
        String hallCode = request.hallCode().trim().toUpperCase(Locale.ROOT);
        if (hallRepository.findByHallCodeIgnoreCase(hallCode).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "A hall with this code already exists.");
        }
        return hallRepository.save(Hall.builder()
                .hallCode(hallCode)
                .name(request.name().trim())
                .building(request.building().trim())
                .floorCount(request.floorCount())
                .description(blankToNull(request.description()))
                .active(true)
                .build());
    }

    public List<Hall> getHalls() {
        return hallRepository.findAll();
    }

    public Hall updateHall(String id, CreateHallRequest request) {
        Hall hall = hallRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Hall not found."));
        String code = request.hallCode().trim().toUpperCase(Locale.ROOT);
        hallRepository.findByHallCodeIgnoreCase(code)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new ApiException(HttpStatus.CONFLICT, "A hall with this code already exists.");
                });
        String previousCode = hall.getHallCode();
        hall.setHallCode(code);
        hall.setName(request.name().trim());
        hall.setBuilding(request.building().trim());
        hall.setFloorCount(request.floorCount());
        hall.setDescription(blankToNull(request.description()));
        if (!previousCode.equalsIgnoreCase(code)) {
            for (Seat seat : seatRepository.findAll().stream()
                    .filter(item -> item.getHallCode().equalsIgnoreCase(previousCode)).toList()) {
                seat.setHallCode(code);
                seatRepository.save(seat);
            }
        }
        return hallRepository.save(hall);
    }

    public Hall archiveHall(String id) {
        Hall hall = hallRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Hall not found."));
        boolean hasActiveSeats = seatRepository.findAll().stream()
                .anyMatch(seat -> seat.getHallCode().equalsIgnoreCase(hall.getHallCode())
                        && !Boolean.FALSE.equals(seat.getActive()));
        if (hasActiveSeats) {
            throw new ApiException(HttpStatus.CONFLICT, "Archive or move the hall's seats before archiving this hall.");
        }
        hall.setActive(false);
        return hallRepository.save(hall);
    }

    public Seat createSeat(CreateSeatRequest request) {
        String seatCode = request.seatCode().trim().toUpperCase(Locale.ROOT);
        String hallCode = request.hallCode().trim().toUpperCase(Locale.ROOT);
        if (seatRepository.findBySeatCodeIgnoreCase(seatCode).isPresent()) {
            throw new ApiException(HttpStatus.CONFLICT, "A seat with this code already exists.");
        }
        if (hallRepository.findByHallCodeIgnoreCase(hallCode)
                .filter(hall -> !Boolean.FALSE.equals(hall.getActive())).isEmpty()) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Active hall not found.");
        }
        List<String> features = request.features() == null ? List.of() : request.features().stream()
                .filter(Objects::nonNull)
                .map(String::trim)
                .filter(feature -> !feature.isEmpty())
                .distinct()
                .toList();
        return seatRepository.save(Seat.builder()
                .seatCode(seatCode)
                .hallCode(hallCode)
                .floor(request.floor().trim())
                .zone(request.zone().trim())
                .hasPowerOutlet(request.hasPowerOutlet())
                .acousticsDb(request.acousticsDb())
                .features(features)
                .active(true)
                .build());
    }

    public List<Seat> getSeats() {
        return seatRepository.findAll();
    }

    public Seat updateSeat(String id, CreateSeatRequest request) {
        Seat seat = seatRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Seat not found."));
        String code = request.seatCode().trim().toUpperCase(Locale.ROOT);
        if (!seat.getSeatCode().equalsIgnoreCase(code)
                && (seatBookingRepository.existsBySeatCodeIgnoreCase(seat.getSeatCode())
                || seatHoldRepository.existsBySeatCodeIgnoreCase(seat.getSeatCode()))) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Seat code cannot change after bookings have referenced it.");
        }
        seatRepository.findBySeatCodeIgnoreCase(code)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new ApiException(HttpStatus.CONFLICT, "A seat with this code already exists.");
                });
        String hallCode = request.hallCode().trim().toUpperCase(Locale.ROOT);
        hallRepository.findByHallCodeIgnoreCase(hallCode)
                .filter(hall -> !Boolean.FALSE.equals(hall.getActive()))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Active hall not found."));
        seat.setSeatCode(code);
        seat.setHallCode(hallCode);
        seat.setFloor(request.floor().trim());
        seat.setZone(request.zone().trim());
        seat.setHasPowerOutlet(request.hasPowerOutlet());
        seat.setAcousticsDb(request.acousticsDb());
        seat.setFeatures(request.features() == null ? List.of() : request.features().stream()
                .filter(Objects::nonNull).map(String::trim).filter(value -> !value.isEmpty()).distinct().toList());
        return seatRepository.save(seat);
    }

    public Seat archiveSeat(String id) {
        Seat seat = seatRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Seat not found."));
        long bookings = seatBookingRepository.countBySeatCodeIgnoreCaseAndStatusIn(
                seat.getSeatCode(), List.of(SeatBookingStatus.RESERVED, SeatBookingStatus.CHECKED_IN));
        boolean hasActiveHolds = seatHoldRepository.findByStatusIn(List.of("CONFIRMED", "CHECKED_IN"))
                .stream().anyMatch(hold -> hold.getSeatCode() != null
                        && hold.getSeatCode().equalsIgnoreCase(seat.getSeatCode()));
        if (bookings > 0 || hasActiveHolds) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Cancel active bookings and holds before archiving this seat.");
        }
        seat.setActive(false);
        return seatRepository.save(seat);
    }

    public Shelf archiveShelf(String id) {
        Shelf shelf = shelfRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Shelf not found."));
        boolean hasBooks = bookRepository.findByShelfCode(shelf.getShelfCode()).stream()
                .anyMatch(book -> !Boolean.FALSE.equals(book.getActive()));
        boolean hasOpenTasks = taskRepository.findByTargetShelfCode(shelf.getShelfCode()).stream()
                .anyMatch(task -> task.getStatus() != TaskStatus.COMPLETED
                        && task.getStatus() != TaskStatus.CANCELLED);
        if (hasBooks || hasOpenTasks) {
            throw new ApiException(HttpStatus.CONFLICT, "Move books and open tasks before archiving this shelf.");
        }
        shelf.setActive(false);
        return shelfRepository.save(shelf);
    }

    public List<Book> getBooks() {
        return bookRepository.findAll();
    }

    public Book getBook(String id) {
        return bookRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
    }

    public Book createBook(CreateBookRequest request) {
        int year = request.year();
        if (year < 0) throw new ApiException(HttpStatus.BAD_REQUEST, "Publication year cannot be negative.");
        String shelfCode = blankToNull(request.shelfCode());
        Shelf shelf = shelfCode == null ? null : shelfRepository.findByShelfCodeIgnoreCase(shelfCode)
                .filter(item -> !Boolean.FALSE.equals(item.getActive()))
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Select an active shelf."));
        if (shelf != null && shelf.getCurrentBookCount() + request.totalCopies() > shelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.CONFLICT, "The selected shelf does not have enough capacity.");
        }
        Book book = Book.builder()
                .title(request.title().trim())
                .author(request.author().trim())
                .publisher(blankToNull(request.publisher()))
                .edition(blankToNull(request.edition()))
                .year(year)
                .category(request.category().trim())
                .callNumber(blankToNull(request.callNumber()))
                .format(blankToNull(request.format()))
                .shelfCode(shelfCode)
                .shelfDetail(shelf == null ? null : shelf.getLevel() + ", " + shelf.getZone())
                .wayfinding(shelf == null ? null : shelf.getLevel() + " • " + shelf.getZone())
                .loanPeriodDays(request.loanPeriodDays())
                .totalCopies(request.totalCopies())
                .availableCopies(shelf == null ? 0 : request.totalCopies())
                .waitlistCount(0)
                .coverImageUrl(blankToNull(request.coverImageUrl()))
                .description(blankToNull(request.description()))
                .isbn(blankToNull(request.isbn()))
                .inventoryStatus(shelf == null ? "PENDING_SHELVING" : "AVAILABLE")
                .active(true)
                .build();
        Book saved = bookRepository.save(book);
        if (shelf != null) {
            shelf.setCurrentBookCount(shelf.getCurrentBookCount() + request.totalCopies());
            shelfRepository.save(shelf);
        }
        return saved;
    }

    public Book updateBook(String id, CreateBookRequest request) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
        if (request.year() < 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Publication year cannot be negative.");
        }
        int borrowed = book.getTotalCopies() - book.getAvailableCopies();
        if (request.totalCopies() < borrowed) {
            throw new ApiException(HttpStatus.CONFLICT, "Total copies cannot be lower than copies currently on loan.");
        }
        String shelfCode = blankToNull(request.shelfCode());
        Shelf oldShelf = blankToNull(book.getShelfCode()) == null ? null
                : shelfRepository.findByShelfCodeIgnoreCase(book.getShelfCode()).orElse(null);
        Shelf newShelf = shelfCode == null ? null : shelfRepository.findByShelfCodeIgnoreCase(shelfCode)
                .filter(item -> !Boolean.FALSE.equals(item.getActive()))
                .orElseThrow(() -> new ApiException(HttpStatus.BAD_REQUEST, "Select an active shelf."));
        int newShelfCopies = newShelf == null ? 0 : newShelf.getCurrentBookCount()
                - (oldShelf != null && oldShelf.getId().equals(newShelf.getId()) ? book.getTotalCopies() : 0)
                + request.totalCopies();
        if (newShelf != null && newShelfCopies > newShelf.getMaxCapacity()) {
            throw new ApiException(HttpStatus.CONFLICT, "The selected shelf does not have enough capacity.");
        }
        if (oldShelf != null && (newShelf == null || !oldShelf.getId().equals(newShelf.getId()))) {
            oldShelf.setCurrentBookCount(Math.max(0, oldShelf.getCurrentBookCount() - book.getTotalCopies()));
            shelfRepository.save(oldShelf);
        }
        if (newShelf != null) {
            newShelf.setCurrentBookCount(newShelfCopies);
            shelfRepository.save(newShelf);
        }
        book.setTitle(request.title().trim());
        book.setAuthor(request.author().trim());
        book.setPublisher(blankToNull(request.publisher()));
        book.setEdition(blankToNull(request.edition()));
        book.setYear(request.year());
        book.setCategory(request.category().trim());
        book.setCallNumber(blankToNull(request.callNumber()));
        book.setFormat(blankToNull(request.format()));
        book.setShelfCode(shelfCode);
        book.setLoanPeriodDays(request.loanPeriodDays());
        book.setTotalCopies(request.totalCopies());
        book.setAvailableCopies(Math.max(0, request.totalCopies() - borrowed));
        book.setCoverImageUrl(blankToNull(request.coverImageUrl()));
        book.setDescription(blankToNull(request.description()));
        book.setIsbn(blankToNull(request.isbn()));
        if (shelfCode == null) {
            book.setInventoryStatus("PENDING_SHELVING");
            book.setShelfDetail(null);
            book.setWayfinding(null);
        } else {
            book.setShelfDetail(newShelf.getLevel() + ", " + newShelf.getZone());
            book.setWayfinding(newShelf.getLevel() + " • " + newShelf.getZone());
            book.setInventoryStatus("AVAILABLE");
        }
        return bookRepository.save(book);
    }

    public Book archiveBook(String id) {
        Book book = bookRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found."));
        long activeReservations = reservationRepository.countByBookIdAndStatusIn(
                id, List.of("READY_FOR_PICKUP", "CONFIRMED"));
        long activeLoans = loanRepository.countByBookIdAndStatus(id, "ACTIVE");
        long waitingUsers = waitlistRepository.countByBookIdAndStatus(id, "WAITING");
        boolean hasOpenShelvingTask = taskRepository.existsByBookIdAndStatusNotIn(
                id, List.of(TaskStatus.COMPLETED, TaskStatus.CANCELLED));
        if (activeReservations > 0 || activeLoans > 0 || waitingUsers > 0 || hasOpenShelvingTask) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Resolve active reservations, loans, waitlists, and shelving tasks before archiving this title.");
        }
        Shelf shelf = blankToNull(book.getShelfCode()) == null ? null
                : shelfRepository.findByShelfCodeIgnoreCase(book.getShelfCode()).orElse(null);
        if (shelf != null) {
            shelf.setCurrentBookCount(Math.max(0, shelf.getCurrentBookCount() - book.getTotalCopies()));
            shelfRepository.save(shelf);
        }
        book.setActive(false);
        return bookRepository.save(book);
    }

    public Shelf updateShelf(String id, Shelf update) {
        Shelf shelf = shelfRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Shelf not found."));
        String code = update.getShelfCode().trim().toUpperCase(Locale.ROOT);
        shelfRepository.findByShelfCodeIgnoreCase(code)
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> { throw new ApiException(HttpStatus.CONFLICT, "A shelf with this code already exists."); });
        if (update.getMaxCapacity() < shelf.getCurrentBookCount()) {
            throw new ApiException(HttpStatus.CONFLICT, "Capacity cannot be lower than the current book count.");
        }
        String previousCode = shelf.getShelfCode();
        if (!previousCode.equalsIgnoreCase(code)) {
            for (Book book : bookRepository.findByShelfCode(previousCode)) {
                book.setShelfCode(code);
                book.setShelfDetail(update.getLevel() + ", " + update.getZone());
                book.setWayfinding(update.getLevel() + " • " + update.getZone());
                bookRepository.save(book);
            }
            for (StaffTask task : taskRepository.findByTargetShelfCode(previousCode)) {
                task.setTargetShelfCode(code);
                taskRepository.save(task);
            }
        }
        shelf.setShelfCode(code);
        shelf.setLevel(update.getLevel());
        shelf.setZone(update.getZone());
        shelf.setMaxCapacity(update.getMaxCapacity());
        return shelfRepository.save(shelf);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
