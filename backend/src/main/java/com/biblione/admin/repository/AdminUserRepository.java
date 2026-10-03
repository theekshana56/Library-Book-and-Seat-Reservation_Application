package com.biblione.admin.repository;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;
import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface AdminUserRepository extends MongoRepository<AdminUser, String> {
    Optional<AdminUser> findByEmailIgnoreCase(String email);
    boolean existsByEmailIgnoreCase(String email);
    Optional<AdminUser> findByUniversityIdIgnoreCase(String universityId);
    boolean existsByUniversityIdIgnoreCase(String universityId);
    List<AdminUser> findByRole(UserRole role);
    List<AdminUser> findByRoleAndActive(UserRole role, boolean active);
}