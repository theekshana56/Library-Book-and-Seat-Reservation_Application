package com.biblione.service;

import com.biblione.dto.CreateSeatBookingRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Seat;
import com.biblione.model.SeatBooking;
import com.biblione.repository.SeatBookingRepository;
import com.biblione.repository.SeatRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.springframework.data.mongodb.core.FindAndModifyOptions;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SeatBookingServiceTest {

    @Mock
    private SeatBookingRepository seatBookingRepository;
    @Mock
    private SeatRepository seatRepository;
    @Mock
    private MongoTemplate mongoTemplate;

    private SeatBookingService service;

    @BeforeEach
    void setUp() {
        service = new SeatBookingService(
                seatBookingRepository,
                seatRepository,
                mongoTemplate
        );
    }

    @Test
    void conflictingLockRejectsBookingBeforeCheckingAvailability() {
        Seat seat = Seat.builder()
                .id("seat-1")
                .seatCode("A1")
                .build();
        when(seatRepository.findBySeatCodeIgnoreCase("A1"))
                .thenReturn(Optional.of(seat));
        when(mongoTemplate.findAndModify(
                any(Query.class),
                any(Update.class),
                any(FindAndModifyOptions.class),
                eq(Seat.class)
        )).thenReturn(null);

        assertThatThrownBy(() -> service.createBooking(request()))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("currently being booked");

        verify(seatBookingRepository, never())
                .findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
                        any(),
                        any(),
                        any()
                );
    }

    @Test
    void successfulBookingReleasesItsLock() {
        Seat seat = Seat.builder()
                .id("seat-1")
                .seatCode("A1")
                .build();
        when(seatRepository.findBySeatCodeIgnoreCase("A1"))
                .thenReturn(Optional.of(seat));
        when(mongoTemplate.findAndModify(
                any(Query.class),
                any(Update.class),
                any(FindAndModifyOptions.class),
                eq(Seat.class)
        )).thenReturn(seat);
        when(seatBookingRepository
                .findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
                        eq("A1"),
                        eq(LocalDate.of(2026, 10, 5)),
                        any()
                ))
                .thenReturn(List.of());
        when(seatBookingRepository.save(any(SeatBooking.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        SeatBooking booking = service.createBooking(request());

        assertThat(booking.getSeatCode()).isEqualTo("A1");
        assertThat(booking.getStatus().name()).isEqualTo("RESERVED");
        verify(mongoTemplate).updateFirst(
                any(Query.class),
                any(Update.class),
                eq(Seat.class)
        );
    }

    private CreateSeatBookingRequest request() {
        CreateSeatBookingRequest request = new CreateSeatBookingRequest();
        request.setUserId("user-1");
        request.setSeatCode("A1");
        request.setBookingDate(LocalDate.of(2026, 10, 5));
        request.setStartTime(LocalTime.of(10, 0));
        request.setEndTime(LocalTime.of(11, 0));
        return request;
    }
}
