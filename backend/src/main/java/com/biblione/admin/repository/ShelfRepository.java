package com.biblione.admin.repository;

import com.biblione.admin.model.Shelf;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.Optional;

public interface ShelfRepository extends MongoRepository<Shelf, String> {
    Optional<Shelf> findByShelfCodeIgnoreCase(String shelfCode);
}