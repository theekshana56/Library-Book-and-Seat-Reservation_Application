package com.biblione.auth.repository;

import com.biblione.auth.model.AuthSession;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface AuthSessionRepository extends MongoRepository<AuthSession, String> {
    Optional<AuthSession> findByTokenHashAndRevokedFalse(String tokenHash);
    List<AuthSession> findByUserIdAndRevokedFalse(String userId);
    void deleteByUserId(String userId);
}
