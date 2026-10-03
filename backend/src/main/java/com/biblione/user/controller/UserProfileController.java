package com.biblione.user.controller;

import com.biblione.auth.security.AuthContext;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.user.dto.ChangePasswordRequest;
import com.biblione.user.dto.UpdateProfileRequest;
import com.biblione.user.dto.UserResponse;
import com.biblione.user.service.UserProfileService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/users/me")
@RequiredArgsConstructor
public class UserProfileController {

    private final UserProfileService userProfileService;

    @GetMapping
    public UserResponse getMyProfile() {
        AuthenticatedUser currentUser = AuthContext.getCurrentUser();
        return userProfileService.getCurrentProfile(currentUser);
    }

    @PutMapping
    public UserResponse updateMyProfile(@Valid @RequestBody UpdateProfileRequest request) {
        AuthenticatedUser currentUser = AuthContext.getCurrentUser();
        return userProfileService.updateProfile(currentUser, request);
    }

    @PutMapping("/password")
    public Map<String, String> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        AuthenticatedUser currentUser = AuthContext.getCurrentUser();
        userProfileService.changePassword(currentUser, request);
        return Map.of("message", "Password changed successfully. Please log in with your new password.");
    }
}
