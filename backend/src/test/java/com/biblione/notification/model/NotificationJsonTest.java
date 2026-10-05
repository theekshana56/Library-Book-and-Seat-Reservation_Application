package com.biblione.notification.model;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class NotificationJsonTest {

    private final ObjectMapper objectMapper = new ObjectMapper().findAndRegisterModules();

    @Test
    void serializesReadStateUsingFrontendFieldName() throws Exception {
        Notification notification = Notification.builder()
                .id("notification-1")
                .userId("user-1")
                .title("Book ready")
                .message("Pick up your book.")
                .type("SYSTEM")
                .isRead(true)
                .build();

        JsonNode json = objectMapper.readTree(objectMapper.writeValueAsString(notification));

        assertTrue(json.has("isRead"));
        assertTrue(json.get("isRead").asBoolean());
        assertFalse(json.has("read"));
    }
}
