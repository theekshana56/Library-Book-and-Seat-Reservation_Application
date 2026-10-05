package com.biblione.auth.security;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.model.UserRole;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.auth.model.AuthSession;
import com.biblione.auth.repository.AuthSessionRepository;
import com.biblione.auth.service.TokenService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Spy;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class BearerTokenAuthenticationFilterTest {

    @Mock
    private TokenService tokenService;

    @Mock
    private AuthSessionRepository sessionRepository;

    @Mock
    private AdminUserRepository userRepository;

    @Spy
    private ObjectMapper objectMapper = new ObjectMapper();

    @InjectMocks
    private BearerTokenAuthenticationFilter filter;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private FilterChain filterChain;

    @AfterEach
    void tearDown() {
        AuthContext.clear();
    }

    @Test
    void doFilter_allowsPublicPathWithoutToken() throws ServletException, IOException {
        when(request.getHeader("Authorization")).thenReturn(null);
        when(request.getRequestURI()).thenReturn("/api/v1/books");

        filter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
    }

    @Test
    void doFilter_blocksProtectedPathWithoutToken() throws ServletException, IOException {
        when(request.getHeader("Authorization")).thenReturn(null);
        when(request.getRequestURI()).thenReturn("/api/v1/users/me");

        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        when(response.getWriter()).thenReturn(pw);

        filter.doFilterInternal(request, response, filterChain);

        verify(response).setStatus(401);
        verify(filterChain, never()).doFilter(any(), any());
    }

    @Test
    void doFilter_authenticatesProtectedPathWithValidToken() throws ServletException, IOException {
        when(request.getHeader("Authorization")).thenReturn("Bearer my-token-123");
        when(request.getRequestURI()).thenReturn("/api/v1/users/me");
        when(tokenService.hashToken("my-token-123")).thenReturn("hash-123");

        AuthSession session = AuthSession.builder()
                .tokenHash("hash-123")
                .userId("u1")
                .expiresAt(Instant.now().plus(1, ChronoUnit.DAYS))
                .revoked(false)
                .build();
        when(sessionRepository.findByTokenHashAndRevokedFalse("hash-123")).thenReturn(Optional.of(session));

        AdminUser user = AdminUser.builder()
                .id("u1")
                .email("u1@biblione.edu")
                .role(UserRole.STUDENT)
                .active(true)
                .build();
        when(userRepository.findById("u1")).thenReturn(Optional.of(user));

        filter.doFilterInternal(request, response, filterChain);

        verify(filterChain).doFilter(request, response);
        verify(request).setAttribute(eq("authenticatedUser"), any(AuthenticatedUser.class));
    }

    @Test
    void doFilter_forbidsStudentFromAdminPath() throws ServletException, IOException {
        when(request.getHeader("Authorization")).thenReturn("Bearer student-token");
        when(request.getRequestURI()).thenReturn("/api/v1/admin/stats");
        when(tokenService.hashToken("student-token")).thenReturn("student-hash");
        when(sessionRepository.findByTokenHashAndRevokedFalse("student-hash"))
                .thenReturn(Optional.of(AuthSession.builder()
                        .tokenHash("student-hash")
                        .userId("student-1")
                        .expiresAt(Instant.now().plus(1, ChronoUnit.DAYS))
                        .revoked(false)
                        .build()));
        when(userRepository.findById("student-1"))
                .thenReturn(Optional.of(AdminUser.builder()
                        .id("student-1")
                        .email("student@example.edu")
                        .role(UserRole.STUDENT)
                        .active(true)
                        .build()));
        when(response.getWriter()).thenReturn(new PrintWriter(new StringWriter()));

        filter.doFilterInternal(request, response, filterChain);

        verify(response).setStatus(403);
        verify(filterChain, never()).doFilter(any(), any());
    }
}
