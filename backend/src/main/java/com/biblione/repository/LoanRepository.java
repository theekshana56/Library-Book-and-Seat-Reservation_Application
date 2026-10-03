package com.biblione.repository;

import com.biblione.model.Loan;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;

public interface LoanRepository extends MongoRepository<Loan, String> {

    List<Loan> findByUserIdAndStatus(String userId, String status);

    long countByUserIdAndStatus(String userId, String status);
}
