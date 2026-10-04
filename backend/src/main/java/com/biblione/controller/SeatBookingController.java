package com.biblione.controller;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.dto.SeatMapSeatResponse;
import com.biblione.exception.ApiException;
import com.biblione.model.SeatBooking;
import com.biblione.service.SeatBookingService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
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

    private final SeatBookingService
            seatBookingService;

    @GetMapping("/seat-map")
    public List<SeatMapSeatResponse> getSeatMap(

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.DATE
            )
            LocalDate date,

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.TIME
            )
            LocalTime startTime,

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.TIME
            )
            LocalTime endTime
    ) {

        return seatBookingService
                .getSeatMap(
                        date,
                        startTime,
                        endTime
                );
    }

    @PostMapping
    @ResponseStatus(
            HttpStatus.CREATED
    )
    public SeatBooking createBooking(

            @Valid
            @RequestBody
            CreateSeatBookingRequest request
    ) {

        return seatBookingService
                .createBooking(
                        request
                );
    }

    @GetMapping("/{id}")
    public SeatBooking getBooking(

            @PathVariable
            String id
    ) {

        return seatBookingService
                .getBooking(id);
    }

    @GetMapping("/user/{userId}")
    public List<SeatBooking> getUserBookings(

            @PathVariable
            String userId
    ) {

        return seatBookingService
                .getUserBookings(
                        userId
                );
    }

    @PostMapping("/{id}/check-in")
    public SeatBooking checkIn(

            @PathVariable
            String id,

            @RequestBody
            Map<String, String> body
    ) {

        String seatCode =
                body.get(
                        "seatCode"
                );

        if (
                seatCode == null
                        ||
                        seatCode.isBlank()
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "seatCode is required"
            );
        }

        return seatBookingService
                .checkIn(
                        id,
                        seatCode.trim()
                );
    }

    @PostMapping("/{id}/cancel")
    public SeatBooking cancelBooking(

            @PathVariable
            String id
    ) {

        return seatBookingService
                .cancelBooking(
                        id
                );
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(
            HttpStatus.NO_CONTENT
    )
    public void deleteBooking(

            @PathVariable
            String id
    ) {

        seatBookingService
                .deleteBooking(
                        id
                );
    }

    @GetMapping(
            "/availability/{seatCode}"
    )
    public Map<String, Boolean>
    checkAvailability(

            @PathVariable
            String seatCode,

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.DATE
            )
            LocalDate date,

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.TIME
            )
            LocalTime startTime,

            @RequestParam
            @DateTimeFormat(
                    iso = DateTimeFormat.ISO.TIME
            )
            LocalTime endTime
    ) {

        boolean available =
                seatBookingService
                        .isSeatAvailable(
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