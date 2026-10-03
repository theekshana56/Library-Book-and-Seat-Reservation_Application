import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/models.dart';
import '../user_management/services/auth_storage.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static const demoUserId = 'IT23773158';

  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE', defaultValue: '');
    if (env.isNotEmpty) return env;
    if (kIsWeb) return 'http://localhost:8080';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080';
      default:
        return 'http://localhost:8080';
    }
  }

  Future<List<Book>> searchBooks({
    String query = '',
    String category = '',
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/books').replace(
      queryParameters: {
        if (query.isNotEmpty) 'query': query,
        if (category.isNotEmpty && category != 'All Topics')
          'category': category,
      },
    );
    final res = await http.get(uri);
    _ensureOk(res);
    final list = jsonDecode(res.body) as List;
    return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Book> getBook(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/v1/books/$id'));
    _ensureOk(res);
    return Book.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Reservation> reserveBook(String bookId) async {
    String currentUserId = demoUserId;
    try {
      final user = await AuthStorage().getUser();
      if (user != null && user.universityId != null && user.universityId!.isNotEmpty) {
        currentUserId = user.universityId!;
      }
    } catch (_) {}

    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/reservations'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': currentUserId,
        'bookId': bookId,
        'borrowerLabel': 'RW - 20248839',
        'studentCardId': '2024-9182',
        'department': 'CS Dept',
      }),
    );
    _ensureOk(res);
    return Reservation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<int> joinWaitlist(String bookId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/waitlist'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': demoUserId, 'bookId': bookId}),
    );
    _ensureOk(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return body['queuePosition'] as int;
  }

  Future<void> cancelReservation(String id) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/reservations/$id/cancel'),
    );
    _ensureOk(res);
  }

  Future<UserBookings> getBookings([String? userId]) async {
    final targetId = userId ?? demoUserId;
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/users/$targetId/bookings'),
    );
    _ensureOk(res);
    return UserBookings.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<Loan> renewLoan(String id) async {
    final res = await http.post(Uri.parse('$baseUrl/api/v1/loans/$id/renew'));
    _ensureOk(res);
    return Loan.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  void _ensureOk(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    try {
      final body = jsonDecode(res.body);
      throw ApiException(
        body['message']?.toString() ?? 'Request failed (${res.statusCode})',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Unable to reach Biblione API at $baseUrl');
    }
  }
}
