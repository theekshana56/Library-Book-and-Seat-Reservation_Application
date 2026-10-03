package com.biblione.auth.service;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.auth.model.AuthSession;
import com.biblione.auth.repository.AuthSessionRepository;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.exception.ApiException;
import com.biblione.user.dto.AuthResponse;
import com.biblione.user.dto.LoginRequest;
import com.biblione.user.dto.RegisterRequest;
import com.biblione.user.dto.UserResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Locale;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class AuthService {

    private static final int SESSION_EXPIRATION_DAYS = 7;

    private final AdminUserRepository userRepository;
    private final AuthSessionRepository sessionRepository;
    private final TokenService tokenService;
    private final PasswordEncoder passwordEncoder;

    public UserResponse register(RegisterRequest request) {
        if (!request.password().equals(request.confirmPassword())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Password and confirmation do not match.");
        }

        String email = request.email().trim().toLowerCase(Locale.ROOT);
        if (userRepository.existsByEmailIgnoreCase(email)) {
            throw new ApiException(HttpStatus.CONFLICT, "An account with this email already exists.");
        }

        String universityId = request.universityId().trim();
        if (userRepository.existsByUniversityIdIgnoreCase(universityId)) {
            throw new ApiException(HttpStatus.CONFLICT, "An account with this University ID already exists.");
        }

        AdminUser newUser = AdminUser.builder()
                .fullName(request.fullName().trim())
                .universityId(universityId)
                .email(email)
                .password(passwordEncoder.encode(request.password()))
                .role(UserRole.STUDENT)
                .active(true)
                .userCategory("STUDENT")
                .department(null)
                .build();

        AdminUser savedUser = userRepository.save(newUser);
        log.info("Registered new student: id={}, universityId={}, email={}", savedUser.getId(), savedUser.getUniversityId(), savedUser.getEmail());
        return UserResponse.from(savedUser);
    }

    public AuthResponse login(LoginRequest request) {
        String identifier = request.resolveIdentifier();
        if (identifier.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Email or University ID is required.");
        }

        Optional<AdminUser> userOpt = userRepository.findByEmailIgnoreCase(identifier.toLowerCase(Locale.ROOT));
        if (userOpt.isEmpty()) {
            userOpt = userRepository.findByUniversityIdIgnoreCase(identifier);
        }

        // Generic error message to prevent account enumeration
        if (userOpt.isEmpty() || !passwordEncoder.matches(request.password(), userOpt.get().getPassword())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid email/University ID or password.");
        }

        AdminUser user = userOpt.get();
        if (!user.isActive()) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Your account is inactive. Please contact the library administrator.");
        }

        String rawToken = tokenService.generateToken();
        String tokenHash = tokenService.hashToken(rawToken);
        Instant now = Instant.now();
        Instant expiresAt = now.plus(SESSION_EXPIRATION_DAYS, ChronoUnit.DAYS);

        AuthSession session = AuthSession.builder()
                .tokenHash(tokenHash)
                .userId(user.getId())
                .createdAt(now)
                .expiresAt(expiresAt)
                .revoked(false)
                .build();

        sessionRepository.save(session);
        log.info("User logged in successfully: userId={}, email={}", user.getId(), user.getEmail());

        return new AuthResponse(rawToken, "Bearer", expiresAt, UserResponse.from(user));
    }

    public void logout(AuthenticatedUser currentUser) {
        if (currentUser == null || currentUser.tokenHash() == null) {
            return;
        }

        sessionRepository.findByTokenHashAndRevokedFalse(currentUser.tokenHash())
                .ifPresent(session -> {
                    session.setRevoked(true);
                    sessionRepository.save(session);
                    log.info("Revoked session for user: userId={}", currentUser.id());
                });
    }

    public void revokeAllSessionsForUser(String userId) {
        var sessions = sessionRepository.findByUserIdAndRevokedFalse(userId);
        for (var session : sessions) {
            session.setRevoked(true);
        }
        if (!sessions.isEmpty()) {
            sessionRepository.saveAll(sessions);
            log.info("Revoked {} active sessions for user {}", sessions.size(), userId);
        }
    }
}
