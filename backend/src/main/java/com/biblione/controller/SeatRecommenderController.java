package com.biblione.controller;

import com.biblione.dto.SeatRecommendationResponse;
import com.biblione.dto.SeatSearchRequest;
import com.biblione.service.SeatRecommenderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/seats")
@RequiredArgsConstructor
public class SeatRecommenderController {

    private final SeatRecommenderService seatRecommenderService;

    @PostMapping("/recommend")
    public SeatRecommendationResponse recommend(@Valid @RequestBody SeatSearchRequest request) {
        return seatRecommenderService.recommend(request);
    }
}
