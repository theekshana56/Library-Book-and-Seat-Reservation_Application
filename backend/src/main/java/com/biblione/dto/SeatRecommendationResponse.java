package com.biblione.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class SeatRecommendationResponse {

    private List<SeatMatch> exactMatches;
    private List<SeatMatch> closestMatches;
}
