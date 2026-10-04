package com.biblione.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SeatMapSeatResponse {

    private String id;
    private String seatCode;
    private String hallCode;
    private String floor;
    private String zone;
    private boolean hasPowerOutlet;
    private int acousticsDb;
    private List<String> features;
    private boolean available;
}