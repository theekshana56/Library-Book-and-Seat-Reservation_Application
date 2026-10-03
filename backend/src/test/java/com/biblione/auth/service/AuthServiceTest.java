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
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private AdminUserRepository userRepository;

    @Mock
    private AuthSessionRepository sessionRepository;

    @Mock
    private TokenService tokenService;

    @Mock
    private PasswordEncoder passwordEncoder;

    @InjectMocks
    private AuthService authService;

    @Test
    void register_success() {
        RegisterRequest request = new RegisterRequest(
                "Jane Doe",
                "IT20240001",
                "jane@biblione.edu",
                "secret123",
                "secret123"
        );

        when(userRepository.existsByEmailIgnoreCase("jane@biblione.edu")).thenReturn(false);
        when(userRepository.existsByUniversityIdIgnoreCase("IT20240001")).thenReturn(false);
        when(passwordEncoder.encode("secret123")).thenReturn("hashed-secret");
        when(userRepository.save(any(AdminUser.class))).thenAnswer(invocation -> {
            AdminUser u = invocation.getArgument(0);
            u.setId("user-1");
            return u;
        });

        UserResponse response = authService.register(request);

        assertThat(response.id()).isEqualTo("user-1");
        assertThat(response.fullName()).isEqualTo("Jane Doe");
        assertThat(response.universityId()).isEqualTo("IT20240001");
        assertThat(response.email()).isEqualTo("jane@biblione.edu");
        assertThat(response.role()).isEqualTo(UserRole.STUDENT);
        assertThat(response.active()).isTrue();
    }

    @Test
    void register_failsWhenPasswordsDoNotMatch() {
        RegisterRequest request = new RegisterRequest(
                "Jane Doe",
                "IT20240001",
                "jane@biblione.edu",
                "secret123",
                "different123"
        );

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Password and confirmation do not match");
    }

    @Test
    void register_failsOnDuplicateEmail() {
        RegisterRequest request = new RegisterRequest(
                "Jane Doe",
                "IT20240001",
                "jane@biblione.edu",
                "secret123",
                "secret123"
        );

        when(userRepository.existsByEmailIgnoreCase("jane@biblione.edu")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("email already exists");
    }

    @Test
    void register_failsOnDuplicateUniversityId() {
        RegisterRequest request = new RegisterRequest(
                "Jane Doe",
                "IT20240001",
                "jane@biblione.edu",
                "secret123",
                "secret123"
        );

        when(userRepository.existsByEmailIgnoreCase("jane@biblione.edu")).thenReturn(false);
        when(userRepository.existsByUniversityIdIgnoreCase("IT20240001")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("University ID already exists");
    }

    @Test
    void login_successWithEmail() {
        LoginRequest request = new LoginRequest("jane@biblione.edu", null, null, "secret123");

        AdminUser user = AdminUser.builder()
                .id("user-1")
                .fullName("Jane Doe")
                .universityId("IT20240001")
                .email("jane@biblione.edu")
                .password("hashed-secret")
                .role(UserRole.STUDENT)
                .active(true)
                .build();

        when(userRepository.findByEmailIgnoreCase("jane@biblione.edu")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("secret123", "hashed-secret")).thenReturn(true);
        when(tokenService.generateToken()).thenReturn("raw-token-123");
        when(tokenService.hashToken("raw-token-123")).thenReturn("hash-123");

        AuthResponse response = authService.login(request);

        assertThat(response.token()).isEqualTo("raw-token-123");
        assertThat(response.tokenType()).isEqualTo("Bearer");
        assertThat(response.user().email()).isEqualTo("jane@biblione.edu");
        verify(sessionRepository).save(any(AuthSession.class));
    }

    @Test
    void login_successWithUniversityId() {
        LoginRequest request = new LoginRequest("IT20240001", null, null, "secret123");

        AdminUser user = AdminUser.builder()
                .id("user-1")
                .fullName("Jane Doe")
                .universityId("IT20240001")
                .email("jane@biblione.edu")
                .password("hashed-secret")
                .role(UserRole.STUDENT)
                .active(true)
                .build();

        when(userRepository.findByEmailIgnoreCase("it20240001")).thenReturn(Optional.empty());
        when(userRepository.findByUniversityIdIgnoreCase("IT20240001")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("secret123", "hashed-secret")).thenReturn(true);
        when(tokenService.generateToken()).thenReturn("raw-token-123");
        when(tokenService.hashToken("raw-token-123")).thenReturn("hash-123");

        AuthResponse response = authService.login(request);

        assertThat(response.token()).isEqualTo("raw-token-123");
        assertThat(response.user().universityId()).isEqualTo("IT20240001");
    }

    @Test
    void login_failsOnInvalidPassword() {
        LoginRequest request = new LoginRequest("jane@biblione.edu", null, null, "wrongpass");

        AdminUser user = AdminUser.builder()
                .id("user-1")
                .email("jane@biblione.edu")
                .password("hashed-secret")
                .active(true)
                .build();

        when(userRepository.findByEmailIgnoreCase("jane@biblione.edu")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("wrongpass", "hashed-secret")).thenReturn(false);

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("Invalid email/University ID or password");
    }

    @Test
    void login_failsWhenUserInactive() {
        LoginRequest request = new LoginRequest("jane@biblione.edu", null, null, "secret123");

        AdminUser user = AdminUser.builder()
                .id("user-1")
                .email("jane@biblione.edu")
                .password("hashed-secret")
                .active(false)
                .build();

        when(userRepository.findByEmailIgnoreCase("jane@biblione.edu")).thenReturn(Optional.of(user));
        when(passwordEncoder.matches("secret123", "hashed-secret")).thenReturn(true);

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(ApiException.class)
                .hasMessageContaining("inactive");
    }

    @Test
    void logout_revokesSession() {
        AuthenticatedUser currentUser = new AuthenticatedUser(
                "user-1", "IT20240001", "Jane Doe", "jane@biblione.edu",
                UserRole.STUDENT, "CS", "UNDERGRADUATE", true, "hash-123"
        );

        AuthSession session = AuthSession.builder()
                .id("sess-1")
                .tokenHash("hash-123")
                .userId("user-1")
                .revoked(false)
                .build();

        when(sessionRepository.findByTokenHashAndRevokedFalse("hash-123")).thenReturn(Optional.of(session));

        authService.logout(currentUser);

        assertThat(session.isRevoked()).isTrue();
        verify(sessionRepository).save(session);
    }
}
