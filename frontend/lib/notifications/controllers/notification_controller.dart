import 'package:flutter/material.dart';

import '../models/notification_model.dart';
import '../services/notification_api_client.dart';

class NotificationController extends ChangeNotifier {
  NotificationController({NotificationApiClient? apiClient})
    : _apiClient = apiClient ?? NotificationApiClient();

  final NotificationApiClient _apiClient;
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  bool _disposed = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _notifyListeners() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> loadNotifications() async {
    if (_isLoading || _disposed) return;
    _isLoading = true;
    _error = null;
    _notifyListeners();
    try {
      _notifications = await _apiClient.fetchNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  Future<void> addReminder(String title, String message) async {
    _error = null;
    try {
      final newNotification = await _apiClient.createReminder(title, message);
      _notifications.insert(0, newNotification);
      _notifyListeners();
    } catch (e) {
      _error = e.toString();
      _notifyListeners();
      rethrow;
    }
  }

  Future<void> editReminder(String id, String title, String message) async {
    _error = null;
    try {
      final updated = await _apiClient.updateReminder(id, title, message);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updated;
        _notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final original = _notifications[index];
      _error = null;
      _notifications[index] = original.copyWith(isRead: true);
      _notifyListeners();
      try {
        await _apiClient.markAsRead(id);
      } catch (e) {
        _error = e.toString();
        final currentIndex = _notifications.indexWhere((n) => n.id == id);
        if (currentIndex != -1) {
          _notifications[currentIndex] = original;
        }
        _notifyListeners();
        rethrow;
      }
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = _notifications
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList();
    for (final id in unreadIds) {
      await markAsRead(id);
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final backup = _notifications[index];
      _error = null;
      _notifications.removeAt(index);
      _notifyListeners();
      try {
        await _apiClient.deleteNotification(id);
      } catch (e) {
        _error = e.toString();
        _notifications.insert(
          index.clamp(0, _notifications.length).toInt(),
          backup,
        );
        _notifyListeners();
        rethrow;
      }
    }
  }
}
