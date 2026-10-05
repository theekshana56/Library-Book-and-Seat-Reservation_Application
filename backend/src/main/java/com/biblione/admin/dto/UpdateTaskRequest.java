package com.biblione.admin.dto;

import jakarta.validation.constraints.NotBlank;

public record UpdateTaskRequest(
        @NotBlank String assignedStaffId,
        @NotBlank String taskDescription,
        String targetShelfCode) {}
