package com.biblione.controller;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.dto.UserBookingsResponse;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.service.BookReservationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ReservationController {

    private final BookReservationService bookReservationService;

    @GetMapping("/books")
    public List<Book> searchBooks(
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false, defaultValue = "") String category) {
        return bookReservationService.searchBooks(query, category);
    }

    @GetMapping("/books/{id}")
    public Book getBook(@PathVariable String id) {
        return bookReservationService.getBook(id);
    }

    @PostMapping("/reservations")
    @ResponseStatus(HttpStatus.CREATED)
    public Reservation createReservation(@Valid @RequestBody CreateReservationRequest request) {
        return bookReservationService.reserveBook(request);
    }

    @PostMapping("/reservations/{id}/cancel")
    public Reservation cancelReservation(@PathVariable String id) {
        return bookReservationService.cancelReservation(id);
    }

    @GetMapping("/users/{userId}/bookings")
    public UserBookingsResponse getBookings(@PathVariable String userId) {
        return bookReservationService.getUserBookings(userId);
    }

    @PostMapping("/loans/{id}/renew")
    public Loan renewLoan(@PathVariable String id) {
        return bookReservationService.renewLoan(id);
    }
}
