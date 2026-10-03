import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_api_client.dart';

class NotificationController extends ChangeNotifier {
  final NotificationApiClient _apiClient = NotificationApiClient();
  
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await _apiClient.fetchNotifications();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(String title, String message) async {
    try {
      final newNotification = await _apiClient.createReminder(title, message);
      _notifications.insert(0, newNotification);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> editReminder(String id, String title, String message) async {
    try {
      final updated = await _apiClient.updateReminder(id, title, message);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      // Optimistic update
      _notifications[index].isRead = true;
      notifyListeners();
      try {
        await _apiClient.markAsRead(id);
      } catch (e) {
        // Revert on failure
        _notifications[index].isRead = false;
        notifyListeners();
      }
    }
  }

  Future<void> deleteNotification(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final backup = _notifications[index];
      _notifications.removeAt(index);
      notifyListeners();
      try {
        await _apiClient.deleteNotification(id);
      } catch (e) {
        _notifications.insert(index, backup);
        notifyListeners();
        rethrow;
      }
    }
  }
}
