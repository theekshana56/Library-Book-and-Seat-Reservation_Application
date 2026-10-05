package com.biblione.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import java.time.Instant;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "seats")
public class Seat {

    @Id
    private String id;

    @NotBlank
    @Indexed(unique = true)
    private String seatCode;

    @NotBlank
    private String hallCode;

    @NotBlank
    private String floor;

    @NotBlank
    private String zone;
    private boolean hasPowerOutlet;

    @Min(0)
    private int acousticsDb;
    private List<String> features;
    @JsonIgnore
    private String bookingLockToken;
    @JsonIgnore
    private Instant bookingLockExpiresAt;
    private Boolean active;
}
