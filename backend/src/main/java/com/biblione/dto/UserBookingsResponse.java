package com.biblione.dto;

import com.biblione.model.Loan;
import com.biblione.model.Reservation;
import com.biblione.model.SeatHold;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserBookingsResponse {

    private String userId;
    private int activeCount;
    private int historyCount;
    private int loanLimit;
    private List<Reservation> reservations;
    private List<SeatHold> seatHolds;
    private List<Loan> loans;
}
