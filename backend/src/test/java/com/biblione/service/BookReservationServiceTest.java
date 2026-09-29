package com.biblione.service;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.repository.BookRepository;
import com.biblione.repository.LoanRepository;
import com.biblione.repository.ReservationRepository;
import com.biblione.repository.SeatHoldRepository;
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

    private BookReservationService service;

    @BeforeEach
    void setUp() {
        service = new BookReservationService(
                bookRepository, reservationRepository, loanRepository, seatHoldRepository);
    }

    @Test
    void reserveBookDecrementsStockAndCreatesHold() {
        Book book = Book.builder()
                .id("book-ddia")
                .title("Designing Data-Intensive Applications")
                .author("Martin Kleppmann")
                .availableCopies(3)
                .totalCopies(3)
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
    void searchBooksHidesAcceptedTitlesUntilShelvingIsComplete() {
        Book ready = Book.builder().id("book-ready").title("Ready Book").inventoryStatus("AVAILABLE").build();
        Book pending = Book.builder().id("book-pending").title("Pending Book").inventoryStatus("PENDING_SHELVING").build();
        when(bookRepository.findAll()).thenReturn(java.util.List.of(ready, pending));

        var results = service.searchBooks("", "");

        assertThat(results).containsExactly(ready);
    }

    @Test
    void cancelReservationRestoresStock() {
        Reservation reservation = Reservation.builder()
                .id("res-1")
                .bookId("book-ddia")
                .status("READY_FOR_PICKUP")
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
