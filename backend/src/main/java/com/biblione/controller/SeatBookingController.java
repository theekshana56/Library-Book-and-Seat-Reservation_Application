package com.biblione.controller;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.model.SeatBooking;
import com.biblione.service.SeatBookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/seat-bookings")
@RequiredArgsConstructor
public class SeatBookingController {

    private final SeatBookingService seatBookingService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public SeatBooking createBooking(
            @Valid @RequestBody CreateSeatBookingRequest request
    ) {
        return seatBookingService.createBooking(request);
    }

    @GetMapping("/{id}")
    public SeatBooking getBooking(
            @PathVariable String id
    ) {
        return seatBookingService.getBooking(id);
    }

    @GetMapping("/user/{userId}")
    public List<SeatBooking> getUserBookings(
            @PathVariable String userId
    ) {
        return seatBookingService.getUserBookings(userId);
    }

    @PostMapping("/{id}/check-in")
    public SeatBooking checkIn(
            @PathVariable String id,
            @RequestBody Map<String, String> body
    ) {
        String seatCode = body.get("seatCode");

        if (seatCode == null || seatCode.isBlank()) {
            throw new IllegalArgumentException(
                    "seatCode is required"
            );
        }

        return seatBookingService.checkIn(
                id,
                seatCode
        );
    }

    @PostMapping("/{id}/cancel")
    public SeatBooking cancelBooking(
            @PathVariable String id
    ) {
        return seatBookingService.cancelBooking(id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteBooking(
            @PathVariable String id
    ) {
        seatBookingService.deleteBooking(id);
    }

    @GetMapping("/availability/{seatCode}")
    public Map<String, Boolean> checkAvailability(
            @PathVariable String seatCode,
            @RequestParam LocalDate date,
            @RequestParam LocalTime startTime,
            @RequestParam LocalTime endTime
    ) {
        boolean available =
                seatBookingService.isSeatAvailable(
                        seatCode,
                        date,
                        startTime,
                        endTime
                );

        return Map.of(
                "available",
                available
        );
    }
}