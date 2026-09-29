package com.biblione.repository;

import com.biblione.model.SeatHold;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface SeatHoldRepository extends MongoRepository<SeatHold, String> {

    List<SeatHold> findByUserIdAndStatus(String userId, String status);
}
