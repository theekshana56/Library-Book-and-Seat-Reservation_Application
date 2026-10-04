package com.biblione.auth.security;

import com.biblione.admin.model.AdminUser;
import com.biblione.admin.repository.AdminUserRepository;
import com.biblione.auth.model.AuthSession;
import com.biblione.auth.repository.AuthSessionRepository;
import com.biblione.auth.service.TokenService;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Instant;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Component
@RequiredArgsConstructor
public class BearerTokenAuthenticationFilter extends OncePerRequestFilter {

    public static final String AUTH_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";
    public static final String AUTH_USER_ATTR = "authenticatedUser";

    private final TokenService tokenService;
    private final AuthSessionRepository sessionRepository;
    private final AdminUserRepository userRepository;
    private final ObjectMapper objectMapper;

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            resolveAuthentication(request);

            if (isProtectedPath(request) && AuthContext.getCurrentUser() == null) {
                sendUnauthorizedResponse(response, "Full authentication is required to access this resource.");
                return;
            }

            filterChain.doFilter(request, response);
        } finally {
            AuthContext.clear();
        }
    }

    private void resolveAuthentication(HttpServletRequest request) {
        String authHeader = request.getHeader(AUTH_HEADER);
        if (authHeader == null || !authHeader.regionMatches(true, 0, BEARER_PREFIX, 0, BEARER_PREFIX.length())) {
            return;
        }

        String rawToken = authHeader.substring(BEARER_PREFIX.length()).trim();
        if (rawToken.isEmpty()) {
            return;
        }

        String tokenHash = tokenService.hashToken(rawToken);
        Optional<AuthSession> sessionOpt = sessionRepository.findByTokenHashAndRevokedFalse(tokenHash);
        if (sessionOpt.isEmpty()) {
            return;
        }

        AuthSession session = sessionOpt.get();
        if (session.getExpiresAt() != null && session.getExpiresAt().isBefore(Instant.now())) {
            return;
        }

        Optional<AdminUser> userOpt = userRepository.findById(session.getUserId());
        if (userOpt.isEmpty() || !userOpt.get().isActive()) {
            return;
        }

        AuthenticatedUser authUser = AuthenticatedUser.from(userOpt.get(), tokenHash);
        AuthContext.setCurrentUser(authUser);
        request.setAttribute(AUTH_USER_ATTR, authUser);
    }

    private boolean isProtectedPath(HttpServletRequest request) {
        String path = request.getRequestURI();
        if (path.startsWith("/api/v1/users/me")) {
            return true;
        }
        if (path.startsWith("/api/v1/notifications")) {
            return true;
        }
        if (path.equals("/api/v1/auth/logout")) {
            return true;
        }
        return false;
    }

    private void sendUnauthorizedResponse(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpStatus.UNAUTHORIZED.value());
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        Map<String, Object> errorBody = Map.of(
                "timestamp", Instant.now().toString(),
                "status", HttpStatus.UNAUTHORIZED.value(),
                "error", HttpStatus.UNAUTHORIZED.getReasonPhrase(),
                "message", message
        );
        response.getWriter().write(objectMapper.writeValueAsString(errorBody));
    }
}
