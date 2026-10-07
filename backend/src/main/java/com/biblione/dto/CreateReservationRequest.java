package com.biblione.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import lombok.Data;

@Data
public class CreateReservationRequest {

    @NotBlank
    private String userId;

    @NotBlank
    private String bookId;

    private String borrowerLabel;
    private String studentCardId;
    private String department;

    @Min(3)
    @Max(14)
    private Integer loanPeriodDays = 14;
}
