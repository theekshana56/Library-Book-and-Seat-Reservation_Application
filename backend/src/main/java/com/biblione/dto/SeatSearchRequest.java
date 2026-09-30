package com.biblione.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;

@Data
public class SeatSearchRequest {

    @NotNull
    private LocalDate date;

    @NotNull
    private LocalTime startTime;

    @Min(1)
    private int durationMinutes;

    private String zonePreference;
    private Boolean powerRequired;
}