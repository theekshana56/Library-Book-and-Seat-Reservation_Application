package com.biblione.service;

import com.biblione.dto.SeatRecommendationResponse;
import com.biblione.dto.SeatSearchRequest;
import com.biblione.exception.ApiException;
import com.biblione.model.Seat;
import com.biblione.model.SeatHold;
import com.biblione.repository.SeatHoldRepository;
import com.biblione.repository.SeatRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class SeatRecommenderServiceTest {

    @Mock
    private SeatRepository seatRepository;
    @Mock
    private SeatHoldRepository seatHoldRepository;
    @InjectMocks
    private SeatRecommenderService service;

    @Test
    void separatesExactFromClosestAndExcludesConfirmedHolds() {
        Seat exact = Seat.builder().seatCode("A01").floor("Level 2").zone("Quiet Zone")
                .hasPowerOutlet(true).acousticsDb(20).features(List.of("Window")).build();
        Seat closest = Seat.builder().seatCode("A02").floor("Level 1").zone("Social Zone")
                .hasPowerOutlet(true).acousticsDb(28).features(List.of()).build();
        Seat held = Seat.builder().seatCode("A03").zone("Quiet Zone").hasPowerOutlet(true).build();
        Seat availableLater = Seat.builder().seatCode("A04").zone("Quiet Zone")
                .hasPowerOutlet(true).acousticsDb(24).features(List.of()).build();
        Seat occupiedDuringSearch = Seat.builder().seatCode("A05").zone("Quiet Zone")
                .hasPowerOutlet(true).acousticsDb(22).features(List.of()).build();
        when(seatRepository.findAll()).thenReturn(List.of(exact, closest, held, availableLater, occupiedDuringSearch));
        when(seatHoldRepository.findByStatusIn(List.of("CONFIRMED", "CHECKED_IN")))
                .thenReturn(List.of(
                        SeatHold.builder().seatCode("a03").status("CONFIRMED").build(),
                        SeatHold.builder().seatCode("A04").status("CONFIRMED")
                                .date(LocalDate.now()).startTime(LocalTime.of(13, 0)).durationMinutes(60).build(),
                        SeatHold.builder().seatCode("A05").status("CONFIRMED")
                                .date(LocalDate.now()).startTime(LocalTime.of(11, 0)).durationMinutes(30).build()));

        SeatSearchRequest request = new SeatSearchRequest();
        request.setDate(LocalDate.now());
        request.setStartTime(LocalTime.of(10, 0));
        request.setDurationMinutes(150);
        request.setZonePreference("Quiet Zone");
        request.setPowerRequired(true);

        SeatRecommendationResponse response = service.recommend(request);

        assertThat(response.getExactMatches()).extracting("seatCode").containsExactly("A01", "A04");
        assertThat(response.getClosestMatches()).extracting("seatCode").containsExactly("A02");
        assertThat(response.getExactMatches().get(0).getMatchScore()).isGreaterThan(90);
    }

        @Test
        void rejectsSeatSearchStartingSoonerThanTwoHoursFromNow() {
                SeatSearchRequest request = new SeatSearchRequest();
                LocalDateTime soon = LocalDateTime.now().plusHours(1);
                request.setDate(soon.toLocalDate());
                request.setStartTime(soon.toLocalTime());
                request.setDurationMinutes(60);

                assertThatThrownBy(() -> service.recommend(request))
                                .isInstanceOf(ApiException.class)
                                .hasMessageContaining("at least 2 hours");
        }

        @Test
        void rejectsSeatSearchBeyondThe14DayWindow() {
                SeatSearchRequest request = new SeatSearchRequest();
                request.setDate(LocalDate.now().plusDays(15));
                request.setStartTime(LocalTime.MIDNIGHT);
                request.setDurationMinutes(60);

                assertThatThrownBy(() -> service.recommend(request))
                                .isInstanceOf(ApiException.class)
                                .hasMessageContaining("next 14 days");
        }
}