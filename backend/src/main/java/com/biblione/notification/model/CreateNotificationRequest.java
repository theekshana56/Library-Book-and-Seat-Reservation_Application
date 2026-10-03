package com.biblione.notification.model;

import jakarta.validation.constraints.NotBlank;

public record CreateNotificationRequest(
        @NotBlank(message = "Title is required") String title,
        @NotBlank(message = "Message is required") String message
) {}
