package com.biblione.service;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.dto.SeatMapSeatResponse;
import com.biblione.exception.ApiException;
import com.biblione.model.Seat;
import com.biblione.model.SeatBooking;
import com.biblione.model.SeatBookingStatus;
import com.biblione.model.SeatHold;
import com.biblione.repository.SeatBookingRepository;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class SeatBookingService {

    private static final Duration BOOKING_LOCK_LEASE =
            Duration.ofMinutes(5);

    private static final List<SeatBookingStatus>
            ACTIVE_BOOKING_STATUSES =
            List.of(
                    SeatBookingStatus.RESERVED,
                    SeatBookingStatus.CHECKED_IN
            );

    private static final List<String>
            ACTIVE_HOLD_STATUSES =
            List.of(
                    "CONFIRMED",
                    "CHECKED_IN"
            );

    private final SeatBookingRepository
            seatBookingRepository;

    private final SeatRepository
            seatRepository;

    private final SeatHoldRepository
            seatHoldRepository;

    private final MongoTemplate
            mongoTemplate;

    public List<SeatMapSeatResponse> getSeatMap(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        validateBookingWindow(
                date,
                startTime,
                endTime
        );

        return seatRepository
                .findAll()
                .stream()

                .filter(
                        seat ->
                                !Boolean.FALSE.equals(
                                        seat.getActive()
                                )
                )

                .sorted(
                        Comparator.comparing(
                                Seat::getSeatCode
                        )
                )

                .map(
                        seat ->
                                SeatMapSeatResponse
                                        .builder()

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

        validateBookingWindow(
                request.getBookingDate(),
                request.getStartTime(),
                request.getEndTime()
        );

        Seat seat =
                seatRepository
                        .findBySeatCodeIgnoreCase(
                                request.getSeatCode()
                        )

                        .filter(
                                candidate ->
                                        !Boolean.FALSE.equals(
                                                candidate.getActive()
                                        )
                        )

                        .orElseThrow(
                                () ->
                                        new ApiException(
                                                HttpStatus.NOT_FOUND,
                                                "Seat not found: "
                                                        + request.getSeatCode()
                                        )
                        );

        String lockToken =
                acquireBookingLock(
                        seat.getId()
                );

        try {

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
                                    request
                                            .getUserId()
                                            .trim()
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

            SeatBooking saved =
                    seatBookingRepository.save(
                            booking
                    );

            /*
             * Important integration:
             *
             * The rest of the project already uses SeatHold for
             * recommender availability and My Bookings.
             *
             * We create a mirror SeatHold with the SAME ID as
             * the SeatBooking.
             */
            try {

                SeatHold mirrorHold =
                        buildMirrorHold(
                                saved,
                                seat
                        );

                seatHoldRepository.save(
                        mirrorHold
                );

            } catch (RuntimeException error) {

                if (saved.getId() != null) {

                    seatBookingRepository
                            .deleteById(
                                    saved.getId()
                            );
                }

                throw new ApiException(
                        HttpStatus.INTERNAL_SERVER_ERROR,
                        "Unable to complete the seat booking. Please try again."
                );
            }

            return saved;

        } finally {

            releaseBookingLock(
                    seat.getId(),
                    lockToken
            );
        }
    }

    public SeatBooking getBooking(
            String id
    ) {

        return seatBookingRepository
                .findById(id)

                .orElseThrow(
                        () ->
                                new ApiException(
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
                !booking
                        .getSeatCode()
                        .equalsIgnoreCase(
                                scannedSeatCode
                        )
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "QR code does not match the reserved seat"
            );
        }

        validateCheckInWindow(
                booking
        );

        booking.setStatus(
                SeatBookingStatus.CHECKED_IN
        );

        booking.setCheckInTime(
                LocalDateTime.now()
        );

        SeatBooking saved =
                seatBookingRepository.save(
                        booking
                );

        syncMirrorHoldStatus(
                saved.getId(),
                "CHECKED_IN"
        );

        return saved;
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

        LocalDateTime bookingStart =
                LocalDateTime.of(
                        booking.getBookingDate(),
                        booking.getStartTime()
                );

        if (
                !LocalDateTime
                        .now()
                        .plusHours(1)
                        .isBefore(
                                bookingStart
                        )
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Seat bookings can only be cancelled at least one hour before the start time"
            );
        }

        booking.setStatus(
                SeatBookingStatus.CANCELLED
        );

        SeatBooking saved =
                seatBookingRepository.save(
                        booking
                );

        syncMirrorHoldStatus(
                saved.getId(),
                "CANCELLED"
        );

        return saved;
    }

    public void deleteBooking(
            String id
    ) {

        SeatBooking booking =
                getBooking(id);

        /*
         * Do not allow active bookings to be deleted directly.
         * First cancel the booking.
         */
        if (
                booking.getStatus()
                        != SeatBookingStatus.CANCELLED
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Only cancelled seat bookings can be removed"
            );
        }

        seatBookingRepository
                .deleteById(id);

        seatHoldRepository
                .deleteById(id);
    }

    public boolean isSeatAvailable(
            String seatCode,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        validateBookingWindow(
                date,
                startTime,
                endTime
        );

        Seat seat =
                seatRepository
                        .findBySeatCodeIgnoreCase(
                                seatCode
                        )

                        .filter(
                                candidate ->
                                        !Boolean.FALSE.equals(
                                                candidate.getActive()
                                        )
                        )

                        .orElseThrow(
                                () ->
                                        new ApiException(
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

        /*
         * Check bookings made through Aloka's
         * Seat Booking flow.
         */
        List<SeatBooking> bookings =
                seatBookingRepository
                        .findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
                                seatCode,
                                date,
                                ACTIVE_BOOKING_STATUSES
                        );

        boolean bookingConflict =
                bookings
                        .stream()

                        .anyMatch(
                                existing ->
                                        timesOverlap(
                                                startTime,
                                                endTime,
                                                existing.getStartTime(),
                                                existing.getEndTime()
                                        )
                        );

        if (bookingConflict) {
            return false;
        }

        /*
         * Also check the existing project's SeatHold system.
         * This prevents the two member features from
         * double-booking the same seat.
         */
        List<SeatHold> holds =
                seatHoldRepository
                        .findBySeatCodeIgnoreCaseAndStatusIn(
                                seatCode,
                                ACTIVE_HOLD_STATUSES
                        );

        return holds
                .stream()

                .noneMatch(
                        hold ->
                                holdOverlaps(
                                        hold,
                                        date,
                                        startTime,
                                        endTime
                                )
                );
    }

    private SeatHold buildMirrorHold(
            SeatBooking booking,
            Seat seat
    ) {

        int durationMinutes =
                (int)
                        Duration
                                .between(
                                        booking.getStartTime(),
                                        booking.getEndTime()
                                )
                                .toMinutes();

        LocalDateTime bookingStart =
                LocalDateTime.of(
                        booking.getBookingDate(),
                        booking.getStartTime()
                );

        List<String> amenities =
                new ArrayList<>();

        if (seat.isHasPowerOutlet()) {

            amenities.add(
                    "power"
            );
        }

        if (
                seat.getZone() != null
                        &&
                        seat
                                .getZone()
                                .toLowerCase()
                                .contains("quiet")
        ) {

            amenities.add(
                    "quiet"
            );
        }

        if (
                seat.getFeatures() != null
                        &&
                        seat
                                .getFeatures()
                                .stream()
                                .anyMatch(
                                        feature ->
                                                feature != null
                                                        &&
                                                        feature
                                                                .toLowerCase()
                                                                .contains("wifi")
                                )
        ) {

            amenities.add(
                    "wifi"
            );
        }

        List<String> locationParts =
                new ArrayList<>();

        if (
                seat.getFloor() != null
                        &&
                        !seat
                                .getFloor()
                                .isBlank()
        ) {

            locationParts.add(
                    seat.getFloor()
            );
        }

        if (
                seat.getZone() != null
                        &&
                        !seat
                                .getZone()
                                .isBlank()
        ) {

            locationParts.add(
                    seat.getZone()
            );
        }

        String location =
                String.join(
                        " · ",
                        locationParts
                );

        return SeatHold
                .builder()

                /*
                 * Same ID is intentional.
                 * It lets My Bookings open the corresponding
                 * SeatBooking directly.
                 */
                .id(
                        booking.getId()
                )

                .userId(
                        booking.getUserId()
                )

                .seatCode(
                        booking.getSeatCode()
                )

                .seatName(
                        "Seat - "
                                + booking.getSeatCode()
                )

                .zone(
                        location
                )

                .slotLabel(
                        booking.getBookingDate()
                                + ", "
                                + booking.getStartTime()
                                + " - "
                                + booking.getEndTime()
                )

                .date(
                        booking.getBookingDate()
                )

                .startTime(
                        booking.getStartTime()
                )

                .durationMinutes(
                        durationMinutes
                )

                /*
                 * High-fidelity flow mentions a
                 * 15-minute check-in policy.
                 */
                .checkInBy(
                        bookingStart
                                .plusMinutes(15)
                                .atZone(
                                        ZoneId.systemDefault()
                                )
                                .toInstant()
                )

                .amenities(
                        amenities
                )

                .status(
                        "CONFIRMED"
                )

                .build();
    }

    private void syncMirrorHoldStatus(
            String bookingId,
            String status
    ) {

        if (bookingId == null) {
            return;
        }

        seatHoldRepository
                .findById(
                        bookingId
                )

                .ifPresent(
                        hold -> {

                            hold.setStatus(
                                    status
                            );

                            seatHoldRepository
                                    .save(
                                            hold
                                    );
                        }
                );
    }

    private boolean holdOverlaps(
            SeatHold hold,
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        /*
         * Some old seed SeatHold records do not have
         * date/start/duration.
         *
         * Only keep them blocking while their
         * check-in deadline is still active.
         */
        if (
                hold.getDate() == null
                        ||
                        hold.getStartTime() == null
                        ||
                        hold.getDurationMinutes() == null
                        ||
                        hold.getDurationMinutes() < 1
        ) {

            return hold.getCheckInBy() != null
                    &&
                    hold
                            .getCheckInBy()
                            .isAfter(
                                    Instant.now()
                            );
        }

        if (
                !hold
                        .getDate()
                        .equals(
                                date
                        )
        ) {

            return false;
        }

        LocalTime holdEnd =
                hold
                        .getStartTime()
                        .plusMinutes(
                                hold.getDurationMinutes()
                        );

        return timesOverlap(
                startTime,
                endTime,
                hold.getStartTime(),
                holdEnd
        );
    }

    private String acquireBookingLock(
            String seatId
    ) {

        Instant now =
                Instant.now();

        String lockToken =
                UUID
                        .randomUUID()
                        .toString();

        Criteria availableLock =
                new Criteria()
                        .orOperator(

                                Criteria
                                        .where(
                                                "bookingLockExpiresAt"
                                        )
                                        .is(null),

                                Criteria
                                        .where(
                                                "bookingLockExpiresAt"
                                        )
                                        .lt(now)
                        );

        Query query =
                Query.query(

                        new Criteria()
                                .andOperator(

                                        Criteria
                                                .where("id")
                                                .is(seatId),

                                        availableLock
                                )
                );

        Update update =
                new Update()

                        .set(
                                "bookingLockToken",
                                lockToken
                        )

                        .set(
                                "bookingLockExpiresAt",
                                now.plus(
                                        BOOKING_LOCK_LEASE
                                )
                        );

        Seat lockedSeat =
                mongoTemplate
                        .findAndModify(

                                query,
                                update,

                                FindAndModifyOptions
                                        .options()
                                        .returnNew(true),

                                Seat.class
                        );

        if (lockedSeat == null) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Seat is currently being booked. Please retry"
            );
        }

        return lockToken;
    }

    private void releaseBookingLock(
            String seatId,
            String lockToken
    ) {

        Query query =
                Query.query(

                        Criteria
                                .where("id")
                                .is(seatId)

                                .and(
                                        "bookingLockToken"
                                )
                                .is(
                                        lockToken
                                )
                );

        Update update =
                new Update()

                        .unset(
                                "bookingLockToken"
                        )

                        .unset(
                                "bookingLockExpiresAt"
                        );

        mongoTemplate
                .updateFirst(
                        query,
                        update,
                        Seat.class
                );
    }

    private void validateBookingWindow(
            LocalDate date,
            LocalTime startTime,
            LocalTime endTime
    ) {

        validateTimeRange(
                startTime,
                endTime
        );

        if (date == null) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "Booking date is required"
            );
        }

        LocalDateTime now =
                LocalDateTime.now();

        LocalDateTime start =
                LocalDateTime.of(
                        date,
                        startTime
                );

        LocalDateTime end =
                LocalDateTime.of(
                        date,
                        endTime
                );

        if (
                !end.isAfter(
                        now
                )
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "Seat booking time must be in the future"
            );
        }

        /*
         * Allows a user to start/check-in to a booking
         * within the 15 minute check-in window,
         * but prevents old bookings.
         */
        if (
                start.isBefore(
                        now.minusMinutes(15)
                )
        ) {

            throw new ApiException(
                    HttpStatus.BAD_REQUEST,
                    "Seat booking cannot start more than 15 minutes in the past"
            );
        }
    }

    private void validateCheckInWindow(
            SeatBooking booking
    ) {

        LocalDateTime now =
                LocalDateTime.now();

        LocalDateTime start =
                LocalDateTime.of(
                        booking.getBookingDate(),
                        booking.getStartTime()
                );

        LocalDateTime end =
                LocalDateTime.of(
                        booking.getBookingDate(),
                        booking.getEndTime()
                );

        if (
                now.isBefore(
                        start.minusMinutes(15)
                )
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "Check-in opens 15 minutes before the booking start time"
            );
        }

        if (
                now.isAfter(
                        end
                )
        ) {

            throw new ApiException(
                    HttpStatus.CONFLICT,
                    "This booking has already ended"
            );
        }
    }

    private void validateTimeRange(
            LocalTime startTime,
            LocalTime endTime
    ) {

        if (
                startTime == null
                        ||
                        endTime == null
                        ||
                        !endTime.isAfter(
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