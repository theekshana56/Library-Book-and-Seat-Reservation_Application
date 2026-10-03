package com.biblione.admin.dto;

import com.biblione.admin.model.TaskStatus;
import jakarta.validation.constraints.NotNull;

public record UpdateTaskStatusRequest(
        @NotNull TaskStatus status,
        String targetShelfCode) {
}
