package com.biblione.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "seat_bookings")
public class SeatBooking {

    @Id
    private String id;

    private String userId;

    private String seatCode;

    private LocalDate bookingDate;

    private LocalTime startTime;

    private LocalTime endTime;

    private SeatBookingStatus status;

    private LocalDateTime createdAt;

    private LocalDateTime checkInTime;
}