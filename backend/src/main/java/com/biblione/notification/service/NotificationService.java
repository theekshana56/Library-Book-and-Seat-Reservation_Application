package com.biblione.notification.service;

import com.biblione.exception.ApiException;
import com.biblione.notification.model.CreateNotificationRequest;
import com.biblione.notification.model.Notification;
import com.biblione.notification.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;

    public List<Notification> getUserNotifications(String userId, String universityId) {
        java.util.List<String> ids = new java.util.ArrayList<>();
        if (userId != null && !userId.isBlank()) ids.add(userId);
        if (universityId != null && !universityId.isBlank() && !ids.contains(universityId)) ids.add(universityId);
        return notificationRepository.findByUserIdInOrderByCreatedAtDesc(ids);
    }

    public List<Notification> getUserNotifications(String userId) {
        return getUserNotifications(userId, null);
    }

    public Notification createCustomReminder(String userId, CreateNotificationRequest request) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(request.title())
                .message(request.message())
                .type("REMINDER")
                .isRead(false)
                .build();
        return notificationRepository.save(notification);
    }

    public void createSystemNotification(String userId, String title, String message) {
        Notification notification = Notification.builder()
                .userId(userId)
                .title(title)
                .message(message)
                .type("SYSTEM")
                .isRead(false)
                .build();
        notificationRepository.save(notification);
    }

    public Notification updateReminder(String userId, String universityId, String id, CreateNotificationRequest request) {
        Notification notification = getNotificationIfOwned(userId, universityId, id);
        if (!"REMINDER".equals(notification.getType())) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Only custom reminders can be edited.");
        }
        notification.setTitle(request.title());
        notification.setMessage(request.message());
        return notificationRepository.save(notification);
    }

    public Notification markAsRead(String userId, String universityId, String id) {
        Notification notification = getNotificationIfOwned(userId, universityId, id);
        notification.setRead(true);
        return notificationRepository.save(notification);
    }

    public void deleteNotification(String userId, String universityId, String id) {
        Notification notification = getNotificationIfOwned(userId, universityId, id);
        notificationRepository.delete(notification);
    }

    private Notification getNotificationIfOwned(String userId, String universityId, String id) {
        Notification notification = notificationRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Notification not found."));
        boolean match = (userId != null && userId.equals(notification.getUserId())) ||
                        (universityId != null && universityId.equalsIgnoreCase(notification.getUserId()));
        if (!match) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Access denied.");
        }
        return notification;
    }
}
