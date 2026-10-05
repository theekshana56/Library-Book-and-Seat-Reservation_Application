import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api/api_client.dart';
import '../../user_management/services/auth_storage.dart';
import '../models/notification_model.dart';

class NotificationApiClient {
  NotificationApiClient({this._token});

  final String? _token;
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = _token ?? await _authStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<AppNotification>> fetchNotifications() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiClient.baseUrl}/api/v1/notifications'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => AppNotification.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load notifications: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<AppNotification> createReminder(String title, String message) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/v1/notifications'),
      headers: headers,
      body: jsonEncode({'title': title, 'message': message}),
    );
    if (response.statusCode == 201) {
      return AppNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to create reminder: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<AppNotification> updateReminder(
    String id,
    String title,
    String message,
  ) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/api/v1/notifications/$id'),
      headers: headers,
      body: jsonEncode({'title': title, 'message': message}),
    );
    if (response.statusCode == 200) {
      return AppNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to update reminder: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<AppNotification> markAsRead(String id) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('${ApiClient.baseUrl}/api/v1/notifications/$id/read'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return AppNotification.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to mark as read: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiClient.baseUrl}/api/v1/notifications/$id'),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete notification: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
