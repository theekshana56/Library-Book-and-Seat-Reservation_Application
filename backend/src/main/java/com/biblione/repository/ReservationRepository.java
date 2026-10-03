package com.biblione.repository;

import com.biblione.model.Reservation;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface ReservationRepository extends MongoRepository<Reservation, String> {

    List<Reservation> findByUserIdAndStatusIn(String userId, List<String> statuses);

    boolean existsByUserIdAndBookIdAndStatusIn(String userId, String bookId, List<String> statuses);
}
