package com.biblione.repository;

import com.biblione.model.SeatHold;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface SeatHoldRepository extends MongoRepository<SeatHold, String> {

    List<SeatHold> findByUserIdAndStatus(
            String userId,
            String status
    );

    List<SeatHold> findByUserIdAndStatusIn(
            String userId,
            List<String> statuses
    );

    List<SeatHold> findByStatusIn(
            List<String> statuses
    );

    List<SeatHold> findBySeatCodeIgnoreCaseAndStatusIn(
            String seatCode,
            List<String> statuses
    );

    boolean existsBySeatCodeIgnoreCase(
            String seatCode
    );
}