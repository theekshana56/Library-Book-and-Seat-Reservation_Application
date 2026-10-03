package com.biblione.auth.controller;

import com.biblione.auth.security.AuthContext;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.auth.service.AuthService;
import com.biblione.user.dto.AuthResponse;
import com.biblione.user.dto.LoginRequest;
import com.biblione.user.dto.RegisterRequest;
import com.biblione.user.dto.UserResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public UserResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/logout")
    public Map<String, String> logout() {
        AuthenticatedUser currentUser = AuthContext.getCurrentUser();
        authService.logout(currentUser);
        return Map.of("message", "Successfully logged out");
    }
}
