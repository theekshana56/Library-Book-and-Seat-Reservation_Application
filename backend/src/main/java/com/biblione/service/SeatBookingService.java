package com.biblione.service;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.dto.SeatMapSeatResponse;
import com.biblione.exception.ApiException;
import com.biblione.model.Seat;
import com.biblione.model.SeatBooking;
import com.biblione.model.SeatBookingStatus;
import com.biblione.repository.SeatBookingRepository;
import com.biblione.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SeatBookingService {

    private final SeatBookingRepository seatBookingRepository;
    private final SeatRepository seatRepository;

    public List<SeatMapSeatResponse> getSeatMap(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {
        validateTimeRange(startTime, endTime);

        return seatRepository.findAll()
                .stream()
                .sorted(
                        Comparator.comparing(
                                Seat::getSeatCode
                        )
                )
                .map(
                        seat -> SeatMapSeatResponse.builder()

                                .id(
                                        seat.getId()
                                )

                                .seatCode(
                                        seat.getSeatCode()
                                )

                                .hallCode(
                                        seat.getHallCode()
                                )

                                .floor(
                                        seat.getFloor()
                                )

                                .zone(
                                        seat.getZone()
                                )

                                .hasPowerOutlet(
                                        seat.isHasPowerOutlet()
                                )

                                .acousticsDb(
                                        seat.getAcousticsDb()
                                )

                                .features(
                                        seat.getFeatures() == null
                                                ? List.of()
                                                : seat.getFeatures()
                                )

                                .available(
                                        isSeatAvailableInternal(
                                                seat.getSeatCode(),
                                                date,
                                                startTime,
                                                endTime
                                        )
                                )

                                .build()
                )
                .toList();
    }

    public SeatBooking createBooking(
            CreateSeatBookingRequest request
    ) {

        validateTimeRange(
                request.getStartTime(),
                request.getEndTime()
        );

        Seat seat = seatRepository
                .findBySeatCodeIgnoreCase(
                        request.getSeatCode()
                )
                .orElseThrow(
                        () -> new ApiException(
                                HttpStatus.NOT_FOUND,
                                "Seat not found: "
                                        + request.getSeatCode()
                        )
                );

        boolean available =
                isSeatAvailableInternal(
                        seat.getSeatCode(),
                        request.getBookingDate(),
                        request.getStartTime(),
                        request.getEndTime()
                );

        if (!available) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Seat is already reserved for the selected time"
            );
        }

        SeatBooking booking =
                SeatBooking.builder()

                        .userId(
                                request.getUserId()
                        )

                        .seatCode(
                                seat.getSeatCode()
                        )

                        .bookingDate(
                                request.getBookingDate()
                        )

                        .startTime(
                                request.getStartTime()
                        )

                        .endTime(
                                request.getEndTime()
                        )

                        .status(
                                SeatBookingStatus.RESERVED
                        )

                        .createdAt(
                                LocalDateTime.now()
                        )

                        .build();

        return seatBookingRepository.save(
                booking
        );
    }

    public SeatBooking getBooking(
            String id
    ) {

        return seatBookingRepository
                .findById(id)
                .orElseThrow(
                        () -> new ApiException(
                                HttpStatus.NOT_FOUND,
                                "Seat booking not found"
                        )
                );
    }

    public List<SeatBooking> getUserBookings(
            String userId
    ) {

        return seatBookingRepository
                .findByUserIdOrderByCreatedAtDesc(
                        userId
                );
    }

    public SeatBooking checkIn(
            String id,
            String scannedSeatCode
    ) {

        SeatBooking booking =
                getBooking(id);

        if (
                booking.getStatus()
                        != SeatBookingStatus.RESERVED
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Only reserved bookings can be checked in"
            );
        }

        if (
                !booking.getSeatCode()
                        .equalsIgnoreCase(
                                scannedSeatCode
                        )
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "QR code does not match the reserved seat"
            );
        }

        booking.setStatus(
                SeatBookingStatus.CHECKED_IN
        );

        booking.setCheckInTime(
                LocalDateTime.now()
        );

        return seatBookingRepository.save(
                booking
        );
    }

    public SeatBooking cancelBooking(
            String id
    ) {

        SeatBooking booking =
                getBooking(id);

        if (
                booking.getStatus()
                        == SeatBookingStatus.CHECKED_IN
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "A checked-in booking cannot be cancelled"
            );
        }

        if (
                booking.getStatus()
                        == SeatBookingStatus.CANCELLED
        ) {

            return booking;
        }

        booking.setStatus(
                SeatBookingStatus.CANCELLED
        );

        return seatBookingRepository.save(
                booking
        );
    }

    public void deleteBooking(
            String id
    ) {

        if (
                !seatBookingRepository
                        .existsById(id)
        ) {

            throw new ApiException(
                    HttpStatus.NOT_FOUND,
                    "Seat booking not found"
            );
        }

        seatBookingRepository.deleteById(
                id
        );
    }

    public boolean isSeatAvailable(
            String seatCode,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        validateTimeRange(
                startTime,
                endTime
        );

        Seat seat =
                seatRepository
                        .findBySeatCodeIgnoreCase(
                                seatCode
                        )
                        .orElseThrow(
                                () -> new ApiException(
                                        HttpStatus.NOT_FOUND,
                                        "Seat not found: "
                                                + seatCode
                                )
                        );

        return isSeatAvailableInternal(
                seat.getSeatCode(),
                date,
                startTime,
                endTime
        );
    }

    private boolean isSeatAvailableInternal(
            String seatCode,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        List<SeatBookingStatus>
                activeStatuses =
                List.of(
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

        return bookings
                .stream()
                .noneMatch(
                        existing ->
                                timesOverlap(
                                        startTime,
                                        endTime,
                                        existing.getStartTime(),
                                        existing.getEndTime()
                                )
                );
    }

    private void validateTimeRange(
            LocalTime startTime,
            LocalTime endTime
    ) {

        if (
                startTime == null
                        || endTime == null
                        || !endTime.isAfter(
                                startTime
                        )
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "End time must be after start time"
            );
        }
    }

    private boolean timesOverlap(
            LocalTime start1,
            LocalTime end1,
            LocalTime start2,
            LocalTime end2
    ) {

        return start1.isBefore(
                end2
        )
                &&
                start2.isBefore(
                        end1
                );
    }
}