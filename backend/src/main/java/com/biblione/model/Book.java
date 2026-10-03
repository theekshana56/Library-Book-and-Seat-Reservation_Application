package com.biblione.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "books")
public class Book {

    @Id
    private String id;

    @Indexed
    private String title;
    private String author;
    private String publisher;
    private String edition;
    private int year;
    private String category;
    private String callNumber;
    private String format;
    private String shelfCode;
    private String shelfDetail;
    private String wayfinding;
    private String pickupDesk;
    private String pickupDeskDetail;
    private int loanPeriodDays;
    private int totalCopies;
    private int availableCopies;
    private int waitlistCount;
    private Instant nextReturnDate;
    private String currentBorrower;
    private String coverImageUrl;
    private String description;
    private String catalogNotice;
    private Integer expressHoldHours;
    private String isbn;
    private String inventoryStatus;
    private String proposalId;

    @Version
    private Long version;

    public boolean isAvailable() {
        return availableCopies > 0
                && (inventoryStatus == null || !"PENDING_SHELVING".equals(inventoryStatus))
                && shelfCode != null && !shelfCode.isBlank();
    }
}
