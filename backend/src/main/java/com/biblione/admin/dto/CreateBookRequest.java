package com.biblione.admin.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record CreateBookRequest(
        @NotBlank String title,
        @NotBlank String author,
        String publisher,
        String edition,
        @Min(0) int year,
        @NotBlank String category,
        String callNumber,
        String format,
        String shelfCode,
        @Min(1) int loanPeriodDays,
        @Min(1) int totalCopies,
        String coverImageUrl,
        String description,
        String isbn) {}
