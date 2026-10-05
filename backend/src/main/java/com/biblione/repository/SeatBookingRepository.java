package com.biblione.repository;

import com.biblione.model.SeatBooking;
import com.biblione.model.SeatBookingStatus;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.time.LocalDate;
import java.util.List;

public interface SeatBookingRepository
        extends MongoRepository<SeatBooking, String> {

    List<SeatBooking> findByUserIdOrderByCreatedAtDesc(
            String userId
    );

    List<SeatBooking> findBySeatCodeIgnoreCaseAndBookingDateAndStatusIn(
            String seatCode,
            LocalDate bookingDate,
            List<SeatBookingStatus> statuses
    );

    long countBySeatCodeIgnoreCaseAndStatusIn(String seatCode, List<SeatBookingStatus> statuses);
    boolean existsBySeatCodeIgnoreCase(String seatCode);
}