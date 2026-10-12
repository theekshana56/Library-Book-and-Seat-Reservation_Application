import 'package:biblione/notifications/models/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNotification', () {
    test('round trips JSON and preserves ISO timestamp', () {
      final notification = AppNotification.fromJson({
        'id': 'notification-1',
        'title': 'Book ready',
        'message': 'Pick up your book.',
        'type': 'SYSTEM',
        'createdAt': '2026-10-12T08:00:00Z',
        'isRead': true,
      });

      expect(notification.toJson(), {
        'id': 'notification-1',
        'title': 'Book ready',
        'message': 'Pick up your book.',
        'type': 'SYSTEM',
        'createdAt': '2026-10-12T08:00:00.000Z',
        'isRead': true,
      });
    });

    test('accepts the legacy read field and supports copyWith', () {
      final notification = AppNotification.fromJson({
        'id': 'notification-1',
        'title': 'Book ready',
        'message': 'Pick up your book.',
        'type': 'SYSTEM',
        'createdAt': '2026-10-12T08:00:00Z',
        'read': true,
      });

      final copy = notification.copyWith(title: 'Updated', isRead: false);

      expect(notification.title, 'Book ready');
      expect(notification.isRead, isTrue);
      expect(copy.title, 'Updated');
      expect(copy.isRead, isFalse);
      expect(copy.id, notification.id);
    });
  });
}
