import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/models.dart';
import '../user_management/services/auth_storage.dart';
import '../models/seat_booking.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  static const demoUserId = 'IT23773158';
  static const seatBookingDemoUserId = 'IT23763630';

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

  Future<String?> getBookSummary(Book book) async {
    final existingSummary = book.description?.trim();
    if (existingSummary != null && existingSummary.isNotEmpty) {
      return existingSummary;
    }

    String? workKey;
    final isbn = book.isbn?.trim();
    if (isbn != null && isbn.isNotEmpty) {
      final editionResponse = await http
          .get(Uri.https('openlibrary.org', '/isbn/$isbn.json'))
          .timeout(const Duration(seconds: 10));
      if (editionResponse.statusCode == 200) {
        final edition = _decodeOpenLibraryResponse(editionResponse);
        final works = edition['works'];
        if (works is List && works.isNotEmpty && works.first is Map) {
          workKey = (works.first as Map)['key']?.toString();
        }
      } else if (editionResponse.statusCode != 404) {
        throw ApiException(
          'Book summary lookup failed (${editionResponse.statusCode}).',
        );
      }
    }

    if (workKey == null || !workKey.startsWith('/works/')) {
      final searchResponse = await http
          .get(
            Uri.https('openlibrary.org', '/search.json', {
              'title': book.title,
              'author': book.author,
              'fields': 'key',
              'limit': '5',
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (searchResponse.statusCode != 200) {
        throw ApiException(
          'Book summary lookup failed (${searchResponse.statusCode}).',
        );
      }
      final search = _decodeOpenLibraryResponse(searchResponse);
      final documents = search['docs'];
      if (documents is List) {
        for (final document in documents) {
          if (document is Map && document['key'] is String) {
            final key = document['key'] as String;
            if (key.startsWith('/works/')) {
              workKey = key;
              break;
            }
          }
        }
      }
    }

    if (workKey == null) return null;

    final workResponse = await http
        .get(Uri.https('openlibrary.org', '$workKey.json'))
        .timeout(const Duration(seconds: 10));
    if (workResponse.statusCode != 200) {
      throw ApiException(
        'Book summary lookup failed (${workResponse.statusCode}).',
      );
    }
    final work = _decodeOpenLibraryResponse(workResponse);
    final description = work['description'];
    final summary = description is Map
        ? description['value']?.toString().trim()
        : description?.toString().trim();
    if (summary != null && summary.isNotEmpty) return summary;

    final firstSentence = work['first_sentence'];
    final sentence = firstSentence is Map
        ? firstSentence['value']?.toString().trim()
        : firstSentence?.toString().trim();
    return sentence == null || sentence.isEmpty ? null : sentence;
  }

  Map<String, dynamic> _decodeOpenLibraryResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (body is! Map<String, dynamic>) {
      throw ApiException('Book summary lookup returned an invalid response.');
    }
    return body;
  }

  Future<Reservation> reserveBook(String bookId) async {
    String currentUserId = demoUserId;
    try {
      final user = await AuthStorage().getUser();
      if (user != null) {
        final universityId = user.universityId?.trim();
        if (universityId != null && universityId.isNotEmpty) {
          currentUserId = universityId;
        } else if (user.id.trim().isNotEmpty) {
          currentUserId = user.id.trim();
        }
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

  Future<Reservation> updateReservation(
    String id, {
    required String bookId,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/api/v1/reservations/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'bookId': bookId}),
    );
    _ensureOk(res);
    return Reservation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteReservation(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/v1/reservations/$id'),
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

  Future<SeatBooking> createSeatBooking({
    required String seatCode,
    required String bookingDate,
    required String startTime,
    required String endTime,
    String userId = seatBookingDemoUserId,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/seat-bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'seatCode': seatCode,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
      }),
    );

    _ensureOk(res);

    return SeatBooking.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<SeatBooking> getSeatBooking(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/api/v1/seat-bookings/$id'));

    _ensureOk(res);

    return SeatBooking.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<SeatBooking>> getUserSeatBookings({
    String userId = seatBookingDemoUserId,
  }) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/v1/seat-bookings/user/$userId'),
    );

    _ensureOk(res);

    final list = jsonDecode(res.body) as List;

    return list
        .map((item) => SeatBooking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SeatBooking> checkInSeatBooking({
    required String bookingId,
    required String seatCode,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/seat-bookings/$bookingId/check-in'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'seatCode': seatCode}),
    );

    _ensureOk(res);

    return SeatBooking.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<SeatBooking> cancelSeatBooking(String bookingId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/v1/seat-bookings/$bookingId/cancel'),
    );

    _ensureOk(res);

    return SeatBooking.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> deleteSeatBooking(String bookingId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/v1/seat-bookings/$bookingId'),
    );

    _ensureOk(res);
  }

  Future<bool> checkSeatAvailability({
    required String seatCode,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final uri =
        Uri.parse('$baseUrl/api/v1/seat-bookings/availability/$seatCode')
            .replace(
              queryParameters: {
                'date': date,
                'startTime': startTime,
                'endTime': endTime,
              },
            );

    final res = await http.get(uri);

    _ensureOk(res);

    final body = jsonDecode(res.body) as Map<String, dynamic>;

    return body['available'] == true;
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
