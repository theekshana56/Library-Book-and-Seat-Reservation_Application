package com.biblione.service;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.dto.UserBookingsResponse;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.SeatHold;
import com.biblione.repository.BookRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.SeatHoldRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BookReservationService {

    static final List<String> ACTIVE_RESERVATION_STATUSES = List.of("READY_FOR_PICKUP", "CONFIRMED");
    static final int DEFAULT_LOAN_LIMIT = 5;

    private static final SecureRandom RANDOM = new SecureRandom();

    private final BookRepository bookRepository;
    private final ReservationRepository reservationRepository;
    private final LoanRepository loanRepository;
    private final SeatHoldRepository seatHoldRepository;

    public List<Book> searchBooks(String query, String category) {
        String q = query == null ? "" : query.trim().toLowerCase(Locale.ROOT);
        String cat = category == null || "All Topics".equalsIgnoreCase(category.trim()) ? "" : category.trim();
        return bookRepository.findAll().stream()
            .filter(book -> !"PENDING_SHELVING".equals(book.getInventoryStatus()))
                .filter(book -> cat.isEmpty() || book.getCategory() != null
                        && book.getCategory().equalsIgnoreCase(cat))
                .filter(book -> q.isEmpty() || matchesQuery(book, q))
                .toList();
    }

    private static boolean matchesQuery(Book book, String q) {
        return contains(book.getTitle(), q)
                || contains(book.getAuthor(), q)
                || contains(book.getCategory(), q)
                || contains(book.getPublisher(), q)
                || contains(book.getCallNumber(), q);
    }

    private static boolean contains(String value, String q) {
        return value != null && value.toLowerCase(Locale.ROOT).contains(q);
    }

    public Book getBook(String id) {
        return bookRepository.findById(id)
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
                .build();

        return reservationRepository.save(reservation);
    }

    public Reservation cancelReservation(String reservationId) {
        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Reservation not found"));

        if ("CANCELLED".equals(reservation.getStatus()) || "EXPIRED".equals(reservation.getStatus())) {
            throw new ApiException(HttpStatus.CONFLICT, "Reservation is no longer active.");
        }

        reservation.setStatus("CANCELLED");
        reservationRepository.save(reservation);

        bookRepository.findById(reservation.getBookId()).ifPresent(book -> {
            book.setAvailableCopies(Math.min(book.getTotalCopies(), book.getAvailableCopies() + 1));
            bookRepository.save(book);
        });

        return reservation;
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
