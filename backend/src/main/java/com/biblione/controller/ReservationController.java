package com.biblione.controller;

import com.biblione.dto.CreateReservationRequest;
import com.biblione.dto.UpdateReservationRequest;
import com.biblione.dto.UserBookingsResponse;
import com.biblione.model.Book;
import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.SeatBooking;
import com.biblione.model.SeatBookingStatus;
import com.biblione.model.SeatHold;
import com.biblione.model.WaitlistEntry;
import com.biblione.service.BookReservationService;
import com.biblione.service.SeatBookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
@RequiredArgsConstructor
public class ReservationController {

    private final BookReservationService bookReservationService;
    private final SeatBookingService seatBookingService;

    @GetMapping("/books")
    public List<Book> searchBooks(
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false, defaultValue = "") String category
    ) {
        return bookReservationService.searchBooks(query, category);
    }

    @GetMapping("/books/{id}")
    public Book getBook(@PathVariable String id) {
        return bookReservationService.getBook(id);
    }

    @PostMapping("/reservations")
    @ResponseStatus(HttpStatus.CREATED)
    public Reservation createReservation(
            @Valid @RequestBody CreateReservationRequest request
    ) {
        return bookReservationService.reserveBook(request);
    }

    @PostMapping("/waitlist")
    @ResponseStatus(HttpStatus.CREATED)
    public WaitlistEntry joinWaitlist(
            @Valid @RequestBody CreateReservationRequest request
    ) {
        return bookReservationService.joinWaitlist(request);
    }

    @PostMapping("/reservations/{id}/cancel")
    public Reservation cancelReservation(
            @PathVariable String id
    ) {
        return bookReservationService.cancelReservation(id);
    }

    @PutMapping("/reservations/{id}")
    public Reservation updateReservation(
            @PathVariable String id,
            @Valid @RequestBody UpdateReservationRequest request
    ) {
        return bookReservationService.updateReservation(id, request);
    }

    @DeleteMapping("/reservations/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteReservation(
            @PathVariable String id
    ) {
        bookReservationService.cancelReservation(id);
    }

    @GetMapping("/users/{userId}/bookings")
public UserBookingsResponse getBookings(
        @PathVariable String userId
) {
    return bookReservationService.getUserBookings(userId);
}

    @PostMapping("/loans/{id}/renew")
    public Loan renewLoan(
            @PathVariable String id
    ) {
        return bookReservationService.renewLoan(id);
    }

    private SeatHold convertSeatBookingToHold(
            SeatBooking booking
    ) {

        long durationMinutes =
                Duration.between(
                        booking.getStartTime(),
                        booking.getEndTime()
                ).toMinutes();

        LocalDateTime bookingStart =
                LocalDateTime.of(
                        booking.getBookingDate(),
                        booking.getStartTime()
                );

        return SeatHold.builder()
                .id(booking.getId())
                .userId(booking.getUserId())
                .seatCode(booking.getSeatCode())
                .seatName(
                        "Seat - " + booking.getSeatCode()
                )
                .zone("Study Seat")
                .slotLabel(
                        booking.getBookingDate()
                                + ", "
                                + booking.getStartTime()
                                + " - "
                                + booking.getEndTime()
                )
                .date(booking.getBookingDate())
                .startTime(booking.getStartTime())
                .durationMinutes(
                        (int) durationMinutes
                )
                .amenities(List.of())
                .checkInBy(
                        bookingStart
                                .plusMinutes(15)
                                .atZone(
                                        ZoneId.systemDefault()
                                )
                                .toInstant()
                )
                .status(
                        booking.getStatus()
                                == SeatBookingStatus.CHECKED_IN
                                ? "CHECKED_IN"
                                : "CONFIRMED"
                )
                .build();
    }
}