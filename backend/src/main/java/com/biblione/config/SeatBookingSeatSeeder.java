package com.biblione.config;

import com.biblione.model.Seat;
import com.biblione.repository.SeatRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class SeatBookingSeatSeeder implements CommandLineRunner {

    private final SeatRepository seatRepository;

    public SeatBookingSeatSeeder(SeatRepository seatRepository) {
        this.seatRepository = seatRepository;
    }

    @Override
    public void run(String... args) {

        for (int i = 1; i <= 12; i++) {

            String seatCode = String.format("A%02d", i);

            if (seatRepository.findBySeatCodeIgnoreCase(seatCode).isEmpty()) {

                Seat seat = Seat.builder()
                        .seatCode(seatCode)
                        .hallCode("QUIET-ZONE")
                        .floor("Level 2")
                        .zone("Quiet Zone")
                        .hasPowerOutlet(true)
                        .acousticsDb(35)
                        .features(List.of(
                                "Power Outlet",
                                "Window View"
                        ))
                        .build();

                seatRepository.save(seat);

                System.out.println("Seeded seat: " + seatCode);
            }
        }
    }
}