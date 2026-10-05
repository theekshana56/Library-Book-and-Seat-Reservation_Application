package com.biblione.user.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record VendorRegistrationRequest(
        @NotBlank(message = "Contact name is required")
        String fullName,

        @NotBlank(message = "Company name is required")
        String companyName,

        @NotBlank(message = "Email is required")
        @Email(message = "Invalid email format")
        String email,

        @NotBlank(message = "Password is required")
        @Size(min = 6, message = "Password must be at least 6 characters")
        String password,

        @NotBlank(message = "Confirm password is required")
        String confirmPassword
) {}
