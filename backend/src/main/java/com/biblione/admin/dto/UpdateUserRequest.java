package com.biblione.admin.dto;

import com.biblione.admin.model.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record UpdateUserRequest(
        @NotBlank String fullName,
        @NotBlank @Email String email,
        @NotNull UserRole role,
        String department,
        String userCategory,
        String vendorCompanyName,
        @NotNull Boolean active) {}
