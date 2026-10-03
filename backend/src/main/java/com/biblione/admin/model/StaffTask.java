package com.biblione.admin.model;

import jakarta.validation.constraints.NotBlank;
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
@Document(collection = "staff_tasks")
public class StaffTask {

    @Id
    private String id;

    @NotBlank
    @Indexed
    private String assignedStaffId;
    private String assignedStaffName;
    private String bookId;
    private String bookTitle;
    @NotBlank
    private String taskDescription;
    private String targetShelfCode;
    private int quantity;
    private TaskStatus status;
    private Instant createdAt;
}
