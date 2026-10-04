package com.biblione.admin.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "publisher_proposals")
public class PublisherProposal {

    @Id
    private String id;

    @NotBlank
    @Indexed
    private String vendorId;
    private String vendorName;
    @NotBlank
    private String bookTitle;
    @NotBlank
    private String author;
    private String isbn;
    @NotBlank
    private String category;
    private String description;
    @Positive
    private double proposedPrice;
    @Positive
    private int vendorSupplyQty;
    private int adminRequestedLotQty;
    private String adminMessage;
    private String sampleCoverImageUrl;
    private ProposalStatus status;
    private LocalDateTime createdAt;
}
