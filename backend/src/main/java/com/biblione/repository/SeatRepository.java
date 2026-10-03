package com.biblione.repository;

import com.biblione.model.Seat;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface SeatRepository extends MongoRepository<Seat, String> {

	Optional<Seat> findBySeatCodeIgnoreCase(String seatCode);
}
