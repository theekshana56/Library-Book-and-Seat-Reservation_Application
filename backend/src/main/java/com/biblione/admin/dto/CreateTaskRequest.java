package com.biblione.admin.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record CreateTaskRequest(
        @NotBlank String assignedStaffId,
        String bookId,
        String bookTitle,
        @NotBlank String taskDescription,
        String targetShelfCode,
        @Min(1) Integer quantity) {
}
