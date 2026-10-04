package com.biblione.admin.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

import java.util.List;

public record CreateSeatRequest(
        @NotBlank String seatCode,
        @NotBlank String hallCode,
        @NotBlank String floor,
        @NotBlank String zone,
        boolean hasPowerOutlet,
        @Min(0) int acousticsDb,
        List<String> features) {
}
