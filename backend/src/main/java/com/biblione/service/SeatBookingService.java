package com.biblione.service;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.model.Seat;
import com.biblione.model.SeatBooking;
import com.biblione.model.SeatBookingStatus;
import com.biblione.repository.SeatBookingRepository;
import com.biblione.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SeatBookingService {

    private final SeatBookingRepository seatBookingRepository;
    private final SeatRepository seatRepository;

    public SeatBooking createBooking(
            CreateSeatBookingRequest request
    ) {
        Seat seat = seatRepository
                .findBySeatCodeIgnoreCase(request.getSeatCode())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Seat not found: " + request.getSeatCode()
                        )
                );

        if (!request.getEndTime().isAfter(request.getStartTime())) {
            throw new IllegalArgumentException(
                    "End time must be after start time"
            );
        }

        List<SeatBookingStatus> activeStatuses = List.of(
                SeatBookingStatus.RESERVED,
                SeatBookingStatus.CHECKED_IN
        );

        List<SeatBooking> existingBookings =
                seatBookingRepository
                        .findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
                                seat.getSeatCode(),
                                request.getBookingDate(),
                                activeStatuses
                        );

        boolean conflict = existingBookings.stream()
                .anyMatch(existing ->
                        timesOverlap(
                                request.getStartTime(),
                                request.getEndTime(),
                                existing.getStartTime(),
                                existing.getEndTime()
                        )
                );

        if (conflict) {
            throw new IllegalStateException(
                    "Seat is already reserved for the selected time"
            );
        }

        SeatBooking booking = SeatBooking.builder()
                .userId(request.getUserId())
                .seatCode(seat.getSeatCode())
                .bookingDate(request.getBookingDate())
                .startTime(request.getStartTime())
                .endTime(request.getEndTime())
                .status(SeatBookingStatus.RESERVED)
                .createdAt(LocalDateTime.now())
                .build();

        return seatBookingRepository.save(booking);
    }

    public SeatBooking getBooking(String id) {
        return seatBookingRepository.findById(id)
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Seat booking not found"
                        )
                );
    }

    public List<SeatBooking> getUserBookings(String userId) {
        return seatBookingRepository
                .findByUserIdOrderByCreatedAtDesc(userId);
    }

    public SeatBooking checkIn(
            String id,
            String scannedSeatCode
    ) {
        SeatBooking booking = getBooking(id);

        if (booking.getStatus()
                != SeatBookingStatus.RESERVED) {
            throw new IllegalStateException(
                    "Only reserved bookings can be checked in"
            );
        }

        if (!booking.getSeatCode()
                .equalsIgnoreCase(scannedSeatCode)) {
            throw new IllegalArgumentException(
                    "QR code does not match the reserved seat"
            );
        }

        booking.setStatus(
                SeatBookingStatus.CHECKED_IN
        );

        booking.setCheckInTime(
                LocalDateTime.now()
        );

        return seatBookingRepository.save(booking);
    }

    public SeatBooking cancelBooking(String id) {
        SeatBooking booking = getBooking(id);

        if (booking.getStatus()
                == SeatBookingStatus.CANCELLED) {
            return booking;
        }

        booking.setStatus(
                SeatBookingStatus.CANCELLED
        );

        return seatBookingRepository.save(booking);
    }

    public void deleteBooking(String id) {
        if (!seatBookingRepository.existsById(id)) {
            throw new IllegalArgumentException(
                    "Seat booking not found"
            );
        }

        seatBookingRepository.deleteById(id);
    }

    public boolean isSeatAvailable(
            String seatCode,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {
        List<SeatBookingStatus> activeStatuses = List.of(
                SeatBookingStatus.RESERVED,
                SeatBookingStatus.CHECKED_IN
        );

        List<SeatBooking> bookings =
                seatBookingRepository
                        .findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
                                seatCode,
                                date,
                                activeStatuses
                        );

        return bookings.stream()
                .noneMatch(existing ->
                        timesOverlap(
                                startTime,
                                endTime,
                                existing.getStartTime(),
                                existing.getEndTime()
                        )
                );
    }

    private boolean timesOverlap(
            LocalTime start1,
            LocalTime end1,
            LocalTime start2,
            LocalTime end2
    ) {
        return start1.isBefore(end2)
                && start2.isBefore(end1);
    }
}