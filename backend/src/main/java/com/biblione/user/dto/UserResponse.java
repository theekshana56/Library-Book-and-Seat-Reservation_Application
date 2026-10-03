package com.biblione.user.dto;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;
import com.biblione.auth.security.AuthenticatedUser;

public record UserResponse(
        String id,
        String universityId,
        String fullName,
        String email,
        UserRole role,
        String department,
        String userCategory,
        boolean active
) {
    public static UserResponse from(AdminUser user) {
        return new UserResponse(
                user.getId(),
                user.getUniversityId(),
                user.getFullName(),
                user.getEmail(),
                user.getRole(),
                user.getDepartment(),
                user.getUserCategory(),
                user.isActive()
        );
    }

    public static UserResponse from(AuthenticatedUser user) {
        return new UserResponse(
                user.id(),
                user.universityId(),
                user.fullName(),
                user.email(),
                user.role(),
                user.department(),
                user.userCategory(),
                user.active()
        );
    }
}
