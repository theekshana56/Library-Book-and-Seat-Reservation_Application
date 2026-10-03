package com.biblione.admin.repository;

import com.biblione.admin.model.Hall;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface HallRepository extends MongoRepository<Hall, String> {

    Optional<Hall> findByHallCodeIgnoreCase(String hallCode);
}
