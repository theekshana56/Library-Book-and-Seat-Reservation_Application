package com.biblione.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "reservations")
public class Reservation {

    @Id
    private String id;

    @Indexed(unique = true)
    private String holdIdCode;

    @Indexed
    private String userId;
    private String borrowerLabel;
    private String studentCardId;
    private String department;

    private String bookId;
    private String title;
    private String author;
    private String coverImageUrl;
    private String shelfCode;
    private String shelfDetail;
    private String format;
    private boolean priorityHold;

    private String pickupDesk;
    private String pickupDeskDetail;

    private String status;
    private Instant createdAt;
    private Instant expiresAt;
}
