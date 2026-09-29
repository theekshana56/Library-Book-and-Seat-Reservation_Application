package com.biblione.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "seat_holds")
public class SeatHold {

    @Id
    private String id;

    @Indexed
    private String userId;
    private String seatCode;
    private String seatName;
    private String zone;
    private String slotLabel;
    private List<String> amenities;
    private Instant checkInBy;
    private String status;
}
