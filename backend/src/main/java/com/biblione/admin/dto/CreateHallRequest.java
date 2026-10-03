package com.biblione.admin.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record CreateHallRequest(
        @NotBlank String hallCode,
        @NotBlank String name,
        @NotBlank String building,
        @Min(1) int floorCount,
        String description) {
}
