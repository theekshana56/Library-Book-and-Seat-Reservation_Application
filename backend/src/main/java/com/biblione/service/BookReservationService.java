package com.biblione.service;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.dto.UpdateReservationRequest;
import com.biblione.dto.UserBookingsResponse;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.SeatHold;
import com.biblione.model.WaitlistEntry;
import com.biblione.repository.BookRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.repository.WaitlistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.Duration;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookReservationService {

    static final List<String> ACTIVE_RESERVATION_STATUSES = List.of("READY_FOR_PICKUP", "CONFIRMED");
    static final int DEFAULT_LOAN_LIMIT = 5;
    private static final Duration RESERVATION_MANAGEMENT_WINDOW = Duration.ofHours(24);

    private static final SecureRandom RANDOM = new SecureRandom();

    private final BookRepository bookRepository;
    private final ReservationRepository reservationRepository;
    private final LoanRepository loanRepository;
    private final SeatHoldRepository seatHoldRepository;
    private final WaitlistRepository waitlistRepository;
    private final com.biblione.notification.service.NotificationService notificationService;

    public List<Book> searchBooks(String query, String category) {
        String q = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        String cat = category == null || "All Topics".equalsIgnoreCase(category.trim()) ? "" : category.trim();
        var results = bookRepository.findAll().stream()
                .filter(book -> !Boolean.FALSE.equals(book.getActive()))
                .filter(book -> cat.isEmpty() || book.getCategory() != null
                        && book.getCategory().equalsIgnoreCase(cat))
                .filter(book -> q.isEmpty() || matchesQuery(book, q))
            .toList();
        if (q.isEmpty()) {
            return results;
        }
        return results.stream()
            .sorted(java.util.Comparator.comparingInt(book -> matchRank(book, q)))
            .toList();
    }

    private static boolean matchesQuery(Book book, String q) {
        return startsWith(book.getTitle(), q)
                || startsWith(book.getAuthor(), q)
                || startsWith(book.getCategory(), q)
                || startsWith(book.getPublisher(), q)
                || startsWith(book.getCallNumber(), q);
    }

    private static boolean startsWith(String value, String q) {
        return value != null && value.toLowerCase(Locale.ROOT).startsWith(q);
    }

    private static int matchRank(Book book, String q) {
        if (equalsQuery(book.getTitle(), q)) return 0;
        if (equalsQuery(book.getAuthor(), q)) return 1;
        if (startsWith(book.getTitle(), q)) return 2;
        if (startsWith(book.getAuthor(), q)) return 3;
        if (equalsQuery(book.getCategory(), q)) return 4;
        if (startsWith(book.getCategory(), q)) return 5;
        if (equalsQuery(book.getPublisher(), q)) return 6;
        if (startsWith(book.getPublisher(), q)) return 7;
        if (equalsQuery(book.getCallNumber(), q)) return 8;
        return 9;
    }

    private static boolean equalsQuery(String value, String q) {
        return value != null && value.trim().equalsIgnoreCase(q);
    }

    public Book getBook(String id) {
        return bookRepository.findById(id)
                .filter(book -> !Boolean.FALSE.equals(book.getActive()))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Book not found"));
    }

    public Reservation reserveBook(String userId, String bookId) {
        CreateReservationRequest request = new CreateReservationRequest();
        request.setUserId(userId);
        request.setBookId(bookId);
        return reserveBook(request);
    }

    public Reservation reserveBook(CreateReservationRequest request) {
        String userId = request.getUserId();
        Book book = getBook(request.getBookId());

        if (!book.isAvailable()) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "All copies are currently in circulation. Join the waitlist instead.");
        }

        if (reservationRepository.existsByUserIdAndBookIdAndStatusIn(
                userId, book.getId(), ACTIVE_RESERVATION_STATUSES)) {
            throw new ApiException(HttpStatus.CONFLICT, "You already have an active hold on this title.");
        }

        book.setAvailableCopies(book.getAvailableCopies() - 1);
        bookRepository.save(book);

        Instant now = Instant.now();
        int holdHours = book.getExpressHoldHours() != null ? book.getExpressHoldHours() : 24;
        int loanPeriodDays = request.getLoanPeriodDays() == null
                ? 14
                : request.getLoanPeriodDays();

        Reservation reservation = Reservation.builder()
                .holdIdCode(generateHoldId(book))
                .userId(userId)
                .borrowerLabel(blankTo(request.getBorrowerLabel(), "RW - 20248839"))
                .studentCardId(blankTo(request.getStudentCardId(), "2024-9182"))
                .department(blankTo(request.getDepartment(), "CS Dept"))
                .bookId(book.getId())
                .title(book.getTitle())
                .author(book.getAuthor())
                .coverImageUrl(book.getCoverImageUrl())
                .shelfCode(book.getShelfCode())
                .shelfDetail(book.getShelfDetail())
                .format(book.getFormat() == null ? "Print Copy" : book.getFormat())
                .priorityHold(true)
                .pickupDesk(blankTo(book.getPickupDesk(), "Central Circulation Desk"))
                .pickupDeskDetail(blankTo(book.getPickupDeskDetail(), "Level 1 • East Atrium Entrance"))
                .status("READY_FOR_PICKUP")
                .createdAt(now)
                .expiresAt(now.plus(holdHours, ChronoUnit.HOURS))
                .loanPeriodDays(loanPeriodDays)
                .build();

        reservation = reservationRepository.save(reservation);

        loanRepository.save(Loan.builder()
                .userId(userId)
                .bookId(book.getId())
                .title(book.getTitle())
                .author(book.getAuthor())
                .coverImageUrl(book.getCoverImageUrl())
                .borrowedAt(now)
                .dueDate(now.plus(loanPeriodDays, ChronoUnit.DAYS))
                .renewCount(0)
                .loanLimit(DEFAULT_LOAN_LIMIT)
                .status("ACTIVE")
                .build());
        
        try {
            notificationService.createSystemNotification(userId, "Book Ready for Pickup", 
                "The book '" + book.getTitle() + "' is now available at the " + reservation.getPickupDesk() + ".");
        } catch (Exception e) {
            // Ignore if notification service is not available
        }
        
        return reservation;
    }

    public WaitlistEntry joinWaitlist(CreateReservationRequest request) {
        Book book = getBook(request.getBookId());
        if (book.isAvailable()) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "This book is available to reserve instead of joining the waitlist.");
        }
        if (waitlistRepository.existsByUserIdAndBookIdAndStatus(
                request.getUserId(), book.getId(), "WAITING")) {
            throw new ApiException(HttpStatus.CONFLICT, "You are already on the waitlist for this book.");
        }

        int queuePosition = Math.max(book.getWaitlistCount(),
            (int) waitlistRepository.countByBookIdAndStatus(book.getId(), "WAITING")) + 1;
        WaitlistEntry entry = waitlistRepository.save(WaitlistEntry.builder()
                .userId(request.getUserId())
                .bookId(book.getId())
                .title(book.getTitle())
                .status("WAITING")
                .queuePosition(queuePosition)
                .createdAt(Instant.now())
                .build());
        book.setWaitlistCount(queuePosition);
        bookRepository.save(book);
        return entry;
    }

    public Reservation cancelReservation(String reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Reservation not found"));

        if ("CANCELLED".equals(reservation.getStatus()) || "EXPIRED".equals(reservation.getStatus())) {
            throw new ApiException(HttpStatus.CONFLICT, "Reservation is no longer active.");
        }
        requireManageableReservation(reservation);

        reservation.setStatus("CANCELLED");
        reservationRepository.save(reservation);

        bookRepository.findById(reservation.getBookId()).ifPresent(book -> {
            book.setAvailableCopies(Math.min(book.getTotalCopies(), book.getAvailableCopies() + 1));
            bookRepository.save(book);
        });

        return reservation;
    }

    public Reservation updateReservation(String reservationId, UpdateReservationRequest request) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Reservation not found"));

        requireManageableReservation(reservation);
        if (reservation.getBookId().equals(request.getBookId())) {
            return reservation;
        }

        Book replacement = getBook(request.getBookId());
        if (!replacement.isAvailable()) {
            throw new ApiException(HttpStatus.CONFLICT, "The selected book is not available.");
        }
        if (reservationRepository.existsByUserIdAndBookIdAndStatusIn(
                reservation.getUserId(), replacement.getId(), ACTIVE_RESERVATION_STATUSES)) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "You already have an active hold on the selected book.");
        }

        Book currentBook = bookRepository.findById(reservation.getBookId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Current reserved book not found"));

        replacement.setAvailableCopies(replacement.getAvailableCopies() - 1);
        bookRepository.save(replacement);

        reservation.setBookId(replacement.getId());
        reservation.setTitle(replacement.getTitle());
        reservation.setAuthor(replacement.getAuthor());
        reservation.setCoverImageUrl(replacement.getCoverImageUrl());
        reservation.setShelfCode(replacement.getShelfCode());
        reservation.setShelfDetail(replacement.getShelfDetail());
        reservation.setFormat(replacement.getFormat() == null ? "Print Copy" : replacement.getFormat());
        reservation.setPickupDesk(blankTo(replacement.getPickupDesk(), "Central Circulation Desk"));
        reservation.setPickupDeskDetail(blankTo(
                replacement.getPickupDeskDetail(), "Level 1 • East Atrium Entrance"));
        reservation.setHoldIdCode(generateHoldId(replacement));
        Reservation updated = reservationRepository.save(reservation);

        currentBook.setAvailableCopies(Math.min(
                currentBook.getTotalCopies(), currentBook.getAvailableCopies() + 1));
        bookRepository.save(currentBook);
        return updated;
    }

    private void requireManageableReservation(Reservation reservation) {
        if (!ACTIVE_RESERVATION_STATUSES.contains(reservation.getStatus())) {
            throw new ApiException(HttpStatus.CONFLICT, "Reservation is no longer active.");
        }

        Instant createdAt = reservation.getCreatedAt();
        if (createdAt == null) {
            throw new ApiException(HttpStatus.CONFLICT, "Reservation has no valid management window.");
        }

        Instant deadline = createdAt.plus(RESERVATION_MANAGEMENT_WINDOW);
        if (reservation.getExpiresAt() != null && reservation.getExpiresAt().isBefore(deadline)) {
            deadline = reservation.getExpiresAt();
        }
        if (!Instant.now().isBefore(deadline)) {
            throw new ApiException(HttpStatus.CONFLICT,
                    "Book holds can only be changed or cancelled within 24 hours of being placed.");
        }
    }

    public Loan renewLoan(String loanId) {
        Loan loan = loanRepository.findById(loanId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Loan not found"));

        if (!"ACTIVE".equals(loan.getStatus())) {
            throw new ApiException(HttpStatus.CONFLICT, "Only active loans can be renewed.");
        }

        loan.setDueDate(loan.getDueDate().plus(14, ChronoUnit.DAYS));
        loan.setRenewCount(loan.getRenewCount() + 1);
        return loanRepository.save(loan);
    }

    public UserBookingsResponse getUserBookings(String userId) {
        List<Reservation> reservations = reservationRepository
                .findByUserIdAndStatusIn(userId, ACTIVE_RESERVATION_STATUSES);
        List<SeatHold> seats = seatHoldRepository.findByUserIdAndStatus(userId, "CONFIRMED");
        List<Loan> loans = loanRepository.findByUserIdAndStatus(userId, "ACTIVE");

        int active = reservations.size() + seats.size();
        return UserBookingsResponse.builder()
                .userId(userId)
                .activeCount(active)
                .historyCount(4)
                .loanLimit(DEFAULT_LOAN_LIMIT)
                .reservations(reservations)
                .seatHolds(seats)
                .loans(loans)
                .build();
    }

    String generateHoldId(Book book) {
        String acronym = acronymFromTitle(book.getTitle());
        int serial = 1000 + RANDOM.nextInt(9000);
        return "BBL-" + serial + "-" + acronym;
    }

    static String acronymFromTitle(String title) {
        if (title == null || title.isBlank()) {
            return "BOOK";
        }
        String letters = java.util.Arrays.stream(title.split("[^A-Za-z0-9]+"))
                .filter(part -> !part.isBlank())
                .map(part -> part.substring(0, 1).toUpperCase(Locale.ROOT))
                .collect(Collectors.joining());
        if (letters.length() > 4) {
            return letters.substring(0, 4);
        }
        return letters.isEmpty() ? "BOOK" : letters;
    }

    private static String blankTo(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
