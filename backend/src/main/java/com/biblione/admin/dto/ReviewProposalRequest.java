package com.biblione.admin.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record ReviewProposalRequest(
        @NotNull Boolean approved,
        @Positive Integer requestedLotQty,
        String message) {
}
