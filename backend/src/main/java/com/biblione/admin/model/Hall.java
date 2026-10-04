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
@Document(collection = "halls")
public class Hall {

    @Id
    private String id;

    @NotBlank
    @Indexed(unique = true)
    private String hallCode;

    @NotBlank
    private String name;

    @NotBlank
    private String building;

    @Min(1)
    private int floorCount;

    private String description;
}
