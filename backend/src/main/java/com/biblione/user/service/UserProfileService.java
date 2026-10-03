package com.biblione.user.service;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.auth.service.AuthService;
import com.biblione.exception.ApiException;
import com.biblione.user.dto.ChangePasswordRequest;
import com.biblione.user.dto.UpdateProfileRequest;
import com.biblione.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Locale;

@Slf4j
@Service
@RequiredArgsConstructor
public class UserProfileService {

    private final AdminUserRepository userRepository;
    private final AuthService authService;
    private final PasswordEncoder passwordEncoder;

    public UserResponse getCurrentProfile(AuthenticatedUser currentUser) {
        AdminUser user = loadUser(currentUser.id());
        return UserResponse.from(user);
    }

    public UserResponse updateProfile(AuthenticatedUser currentUser, UpdateProfileRequest request) {
        AdminUser user = loadUser(currentUser.id());

        String newEmail = request.email().trim().toLowerCase(Locale.ROOT);
        if (!user.getEmail().equalsIgnoreCase(newEmail)) {
            userRepository.findByEmailIgnoreCase(newEmail).ifPresent(existing -> {
                if (!existing.getId().equals(user.getId())) {
                    throw new ApiException(HttpStatus.CONFLICT, "An account with this email already exists.");
                }
            });
            user.setEmail(newEmail);
        }

        user.setFullName(request.fullName().trim());
        if (request.department() != null) {
            user.setDepartment(request.department().trim());
        }

        AdminUser updated = userRepository.save(user);
        log.info("Profile updated for user: id={}, email={}", updated.getId(), updated.getEmail());
        return UserResponse.from(updated);
    }

    public void changePassword(AuthenticatedUser currentUser, ChangePasswordRequest request) {
        if (!request.newPassword().equals(request.confirmNewPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "New password and confirmation do not match.");
        }

        AdminUser user = loadUser(currentUser.id());

        if (!passwordEncoder.matches(request.currentPassword(), user.getPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Current password is incorrect.");
        }

        user.setPassword(passwordEncoder.encode(request.newPassword()));
        userRepository.save(user);

        // Invalidate all existing sessions so user must log in again
        authService.revokeAllSessionsForUser(user.getId());
        log.info("Password changed and sessions revoked for user: id={}", user.getId());
    }

    private AdminUser loadUser(String userId) {
        return userRepository.findById(userId)
                .filter(AdminUser::isActive)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "User account not found or inactive."));
    }
}
