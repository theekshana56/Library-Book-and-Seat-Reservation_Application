package com.biblione.service;

import com.biblione.dto.SeatMatch;
import com.biblione.dto.SeatRecommendationResponse;
import com.biblione.dto.SeatSearchRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Seat;
import com.biblione.model.SeatHold;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.repository.SeatRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.http.HttpStatus;

import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;
import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class SeatRecommenderService {

    private static final List<String> ACTIVE_HOLD_STATUSES = List.of("CONFIRMED", "CHECKED_IN");
    private static final int CLOSEST_MATCH_LIMIT = 5;

    private final SeatRepository seatRepository;
    private final SeatHoldRepository seatHoldRepository;

    public SeatRecommendationResponse recommend(SeatSearchRequest request) {
                validateStartTime(request);
        Set<String> heldSeatCodes = seatHoldRepository.findByStatusIn(ACTIVE_HOLD_STATUSES).stream()
                .filter(hold -> overlapsRequest(hold, request))
                .map(SeatHold::getSeatCode)
                .filter(code -> code != null && !code.isBlank())
                .map(code -> code.toUpperCase(Locale.ROOT))
                .collect(Collectors.toSet());

        List<ScoredSeat> available = seatRepository.findAll().stream()
                .filter(seat -> seat.getSeatCode() != null && !seat.getSeatCode().isBlank())
                .filter(seat -> !heldSeatCodes.contains(seat.getSeatCode().toUpperCase(Locale.ROOT)))
                .map(seat -> new ScoredSeat(seat, score(seat, request), isExactMatch(seat, request)))
                .sorted(Comparator.comparingInt(ScoredSeat::score).reversed()
                        .thenComparing(scored -> scored.seat().getSeatCode()))
                .toList();

        List<SeatMatch> exactMatches = available.stream()
                .filter(ScoredSeat::exact)
                .map(scored -> SeatMatch.from(scored.seat(), scored.score()))
                .toList();
        List<SeatMatch> closestMatches = available.stream()
                .filter(scored -> !scored.exact())
                .limit(CLOSEST_MATCH_LIMIT)
                .map(scored -> SeatMatch.from(scored.seat(), scored.score()))
                .toList();

        return SeatRecommendationResponse.builder()
                .exactMatches(exactMatches)
                .closestMatches(closestMatches)
                .build();
    }

        private void validateStartTime(SeatSearchRequest request) {
                if (request.getDate().isAfter(java.time.LocalDate.now().plusDays(14))) {
                        throw new ApiException(HttpStatus.BAD_REQUEST,
                                        "Seat searches are limited to the next 14 days.");
                }
                LocalDateTime requestedStart = request.getDate().atTime(request.getStartTime());
                if (requestedStart.isBefore(LocalDateTime.now().plusHours(2))) {
                        throw new ApiException(HttpStatus.BAD_REQUEST,
                                        "Seat searches must start at least 2 hours from now.");
                }
        }

    private boolean isExactMatch(Seat seat, SeatSearchRequest request) {
        boolean zoneMatches = isAny(request.getZonePreference())
                || containsIgnoreCase(seat.getZone(), request.getZonePreference());
        boolean powerMatches = request.getPowerRequired() == null
                || request.getPowerRequired() == seat.isHasPowerOutlet();
        return zoneMatches && powerMatches;
    }

    private int score(Seat seat, SeatSearchRequest request) {
        int score = 0;
        if (isAny(request.getZonePreference()) || containsIgnoreCase(seat.getZone(), request.getZonePreference())) {
            score += 45;
        }
        if (request.getPowerRequired() == null || request.getPowerRequired() == seat.isHasPowerOutlet()) {
            score += 45;
        }
        score += Math.max(0, Math.min(10, (40 - seat.getAcousticsDb()) / 2));
        return score;
    }

    private boolean containsIgnoreCase(String value, String expected) {
        return value != null && expected != null
                && value.toLowerCase(Locale.ROOT).contains(expected.toLowerCase(Locale.ROOT));
    }

    private boolean isAny(String value) {
        return value == null || value.isBlank() || "any".equalsIgnoreCase(value);
    }

        private boolean overlapsRequest(SeatHold hold, SeatSearchRequest request) {
                if (hold.getDate() == null || hold.getStartTime() == null
                                || hold.getDurationMinutes() == null || hold.getDurationMinutes() < 1) {
                        return true;
                }
                LocalDateTime holdStart = hold.getDate().atTime(hold.getStartTime());
                LocalDateTime holdEnd = holdStart.plusMinutes(hold.getDurationMinutes());
                LocalDateTime requestStart = request.getDate().atTime(request.getStartTime());
                LocalDateTime requestEnd = requestStart.plusMinutes(request.getDurationMinutes());
                return holdStart.isBefore(requestEnd) && holdEnd.isAfter(requestStart);
        }

    private record ScoredSeat(Seat seat, int score, boolean exact) {
    }
}
