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
@Document(collection = "loans")
public class Loan {

    @Id
    private String id;

    @Indexed
    private String userId;
    private String bookId;
    private String title;
    private String author;
    private String coverImageUrl;
    private Instant borrowedAt;
    private Instant dueDate;
    private int renewCount;
    private int loanLimit;
    private String status;
}
