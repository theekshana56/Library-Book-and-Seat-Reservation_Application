package com.biblione.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateReservationRequest {

    @NotBlank
    private String pickupDesk;

    @NotBlank
    private String pickupDeskDetail;
}
