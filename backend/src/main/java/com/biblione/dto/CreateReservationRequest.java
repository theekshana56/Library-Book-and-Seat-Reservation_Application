package com.biblione.dto;

import jakarta.validation.constraints.NotBlank;
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
}
