package com.biblione.notification.controller;

import com.biblione.auth.security.AuthContext;
import com.biblione.auth.security.AuthenticatedUser;
import com.biblione.notification.model.CreateNotificationRequest;
import com.biblione.notification.model.Notification;
import com.biblione.notification.service.NotificationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/notifications")
@RequiredArgsConstructor
public class NotificationController {

    private final NotificationService notificationService;

    @GetMapping
    public List<Notification> getNotifications() {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        return notificationService.getUserNotifications(user.id(), user.universityId());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Notification createReminder(@Valid @RequestBody CreateNotificationRequest request) {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        return notificationService.createCustomReminder(user.id(), request);
    }

    @PutMapping("/{id}")
    public Notification updateReminder(@PathVariable String id, @Valid @RequestBody CreateNotificationRequest request) {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        return notificationService.updateReminder(user.id(), user.universityId(), id, request);
    }

    @PutMapping("/{id}/read")
    public Notification markAsRead(@PathVariable String id) {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        return notificationService.markAsRead(user.id(), user.universityId(), id);
    }

    @DeleteMapping("/{id}")
    public Map<String, String> deleteNotification(@PathVariable String id) {
        AuthenticatedUser user = AuthContext.getCurrentUser();
        notificationService.deleteNotification(user.id(), user.universityId(), id);
        return Map.of("message", "Notification deleted successfully");
    }
}
