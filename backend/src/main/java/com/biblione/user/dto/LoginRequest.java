package com.biblione.user.dto;

import jakarta.validation.constraints.NotBlank;

public record LoginRequest(
        String identifier,
        String email,
        String universityId,
        @NotBlank(message = "Password is required")
        String password
) {
    public String resolveIdentifier() {
        if (identifier != null && !identifier.isBlank()) {
            return identifier.trim();
        }
        if (email != null && !email.isBlank()) {
            return email.trim();
        }
        if (universityId != null && !universityId.isBlank()) {
            return universityId.trim();
        }
        return "";
    }
}
