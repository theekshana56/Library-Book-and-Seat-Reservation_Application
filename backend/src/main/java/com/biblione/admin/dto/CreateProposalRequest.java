package com.biblione.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;

public record CreateProposalRequest(
        @NotBlank String vendorId,
        @NotBlank String bookTitle,
        @NotBlank String author,
        String isbn,
        @NotBlank String category,
        String description,
        @Positive double proposedPrice,
        @Positive int vendorSupplyQty,
        String sampleCoverImageUrl) {
}
