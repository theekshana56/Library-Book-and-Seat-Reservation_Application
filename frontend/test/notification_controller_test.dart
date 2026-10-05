import 'package:flutter_test/flutter_test.dart';
import 'package:biblione/notifications/controllers/notification_controller.dart';
import 'package:biblione/notifications/models/notification_model.dart';
import 'package:biblione/notifications/services/notification_api_client.dart';

class _NotificationApi extends NotificationApiClient {
  final notifications = <AppNotification>[
    AppNotification(
      id: 'one',
      title: 'Book ready',
      message: 'Pick up your book.',
      type: 'SYSTEM',
      createdAt: DateTime(2026),
    ),
    AppNotification(
      id: 'two',
      title: 'Study desk',
      message: 'Your seat is reserved.',
      type: 'SYSTEM',
      createdAt: DateTime(2026),
      isRead: true,
    ),
  ];
  final markedRead = <String>[];
  bool failDelete = false;

  @override
  Future<List<AppNotification>> fetchNotifications() async =>
      List.of(notifications);

  @override
  Future<AppNotification> markAsRead(String id) async {
    markedRead.add(id);
    final index = notifications.indexWhere(
      (notification) => notification.id == id,
    );
    final updated = notifications[index].copyWith(isRead: true);
    notifications[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteNotification(String id) async {
    if (failDelete) throw Exception('Delete failed');
    notifications.removeWhere((notification) => notification.id == id);
  }
}

void main() {
  test('notification model accepts backend read boolean serialization', () {
    final notification = AppNotification.fromJson({
      'id': 'one',
      'title': 'Book ready',
      'message': 'Pick up your book.',
      'type': 'SYSTEM',
      'createdAt': '2026-10-05T10:00:00Z',
      'read': true,
    });

    expect(notification.isRead, isTrue);
  });

  test('mark all as read persists each unread notification', () async {
    final api = _NotificationApi();
    final controller = NotificationController(apiClient: api);
    await controller.loadNotifications();

    expect(controller.unreadCount, 1);
    await controller.markAllAsRead();

    expect(api.markedRead, ['one']);
    expect(controller.unreadCount, 0);
    controller.dispose();
  });

  test('badge count follows read state and newly fetched notifications', () async {
    final api = _NotificationApi();
    final controller = NotificationController(apiClient: api);
    await controller.loadNotifications();
    expect(controller.unreadCount, 1);

    await controller.markAsRead('one');
    expect(controller.unreadCount, 0);

    api.notifications.insert(
      0,
      AppNotification(
        id: 'three',
        title: 'Book available',
        message: 'A requested book is ready.',
        type: 'SYSTEM',
        createdAt: DateTime(2026, 10, 5),
      ),
    );
    await controller.loadNotifications();
    expect(controller.unreadCount, 1);

    controller.dispose();
  });

  test('failed deletion restores notification and exposes error', () async {
    final api = _NotificationApi()..failDelete = true;
    final controller = NotificationController(apiClient: api);
    await controller.loadNotifications();

    await expectLater(
      controller.deleteNotification('one'),
      throwsA(isA<Exception>()),
    );

    expect(controller.notifications.map((item) => item.id), ['one', 'two']);
    expect(controller.error, contains('Delete failed'));
    controller.dispose();
  });
}
