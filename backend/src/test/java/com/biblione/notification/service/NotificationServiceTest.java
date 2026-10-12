package com.biblione.notification.service;

import com.biblione.exception.ApiException;
import com.biblione.notification.model.CreateNotificationRequest;
import com.biblione.notification.model.Notification;
import com.biblione.notification.repository.NotificationRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NotificationServiceTest {

    @Mock
    private NotificationRepository notificationRepository;

    @InjectMocks
    private NotificationService service;

    @Test
    void createsCustomReminderWithUnreadReminderType() {
        when(notificationRepository.save(any(Notification.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Notification result = service.createCustomReminder(
                "user-1",
                new CreateNotificationRequest("Reminder", "Return book"));

        assertThat(result.getUserId()).isEqualTo("user-1");
        assertThat(result.getType()).isEqualTo("REMINDER");
        assertThat(result.isRead()).isFalse();
        assertThat(result.getTitle()).isEqualTo("Reminder");
    }

    @Test
    void updatesOwnedReminderAndMarksItRead() {
        Notification notification = Notification.builder()
                .id("notification-1")
                .userId("IT20240001")
                .type("REMINDER")
                .title("Old")
                .message("Old message")
                .isRead(false)
                .build();
        when(notificationRepository.findById("notification-1")).thenReturn(Optional.of(notification));
        when(notificationRepository.save(any(Notification.class)))
                .thenAnswer(invocation -> invocation.getArgument(0));

        Notification updated = service.updateReminder(
                "user-1",
                "IT20240001V",
                "notification-1",
                new CreateNotificationRequest("New", "New message"));
        Notification read = service.markAsRead("user-1", "IT20240001V", "notification-1");

        assertThat(updated.getTitle()).isEqualTo("New");
        assertThat(updated.getMessage()).isEqualTo("New message");
        assertThat(read.isRead()).isTrue();
    }

    @Test
    void rejectsMissingOrUnownedNotifications() {
        when(notificationRepository.findById("missing")).thenReturn(Optional.empty());
        when(notificationRepository.findById("other")).thenReturn(Optional.of(
                Notification.builder().id("other").userId("different-user").build()));

        assertThatThrownBy(() -> service.markAsRead("user-1", null, "missing"))
                .isInstanceOf(ApiException.class)
                .hasMessage("Notification not found.");
        assertThatThrownBy(() -> service.deleteNotification("user-1", null, "other"))
                .isInstanceOf(ApiException.class)
                .hasMessage("Access denied.");
    }

    @Test
    void fetchesNotificationsForUserAndUniversityAliases() {
        when(notificationRepository.findByUserIdInOrderByCreatedAtDesc(any()))
                .thenReturn(List.of());

        service.getUserNotifications("user-1", "IT20240001V");

        verify(notificationRepository).findByUserIdInOrderByCreatedAtDesc(any());
    }
}
