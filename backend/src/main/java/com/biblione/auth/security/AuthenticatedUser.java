package com.biblione.auth.security;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;

public record AuthenticatedUser(
        String id,
        String universityId,
        String fullName,
        String email,
        UserRole role,
        String department,
        String userCategory,
        boolean active,
        String tokenHash
) {
    public static AuthenticatedUser from(AdminUser user, String tokenHash) {
        return new AuthenticatedUser(
                user.getId(),
                user.getUniversityId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole(),
                user.getDepartment(),
                user.getUserCategory(),
                user.isActive(),
                tokenHash
        );
    }
}
