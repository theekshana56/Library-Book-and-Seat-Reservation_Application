package com.biblione.dto;

import com.biblione.model.Seat;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SeatMatch {

    private String id;
    private String seatCode;
    private String floor;
    private String zone;
    private boolean hasPowerOutlet;
    private int acousticsDb;
    private List<String> features;
    private int matchScore;

    public static SeatMatch from(Seat seat, int matchScore) {
        return SeatMatch.builder()
                .id(seat.getId())
                .seatCode(seat.getSeatCode())
                .floor(seat.getFloor())
                .zone(seat.getZone())
                .hasPowerOutlet(seat.isHasPowerOutlet())
                .acousticsDb(seat.getAcousticsDb())
                .features(seat.getFeatures())
                .matchScore(matchScore)
                .build();
    }
}
