package com.biblione.admin.dto;

import com.biblione.admin.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

public record CreateUserRequest(
        @NotBlank String fullName,
        @NotBlank @Email String email,
        @NotBlank @Size(min = 10, max = 128) String password,
        @NotNull UserRole role,
        String department,
        String userCategory,
        Boolean active) {
}
