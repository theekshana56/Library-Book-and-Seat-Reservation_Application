package com.biblione.repository;

import com.biblione.model.WaitlistEntry;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface WaitlistRepository extends MongoRepository<WaitlistEntry, String> {

    boolean existsByUserIdAndBookIdAndStatus(String userId, String bookId, String status);

    long countByBookIdAndStatus(String bookId, String status);

    List<WaitlistEntry> findByBookIdAndStatusOrderByQueuePositionAsc(String bookId, String status);
}
