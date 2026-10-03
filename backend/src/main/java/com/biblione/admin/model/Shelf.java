package com.biblione.admin.model;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "shelves")
public class Shelf {

    @Id
    private String id;

    @NotBlank
    @Indexed(unique = true)
    private String shelfCode;
    @NotBlank
    private String level;
    @NotBlank
    private String zone;
    @Min(1)
    private int maxCapacity;
    @Min(0)
    private int currentBookCount;
}
