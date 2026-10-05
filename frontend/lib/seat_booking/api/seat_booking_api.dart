import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart'
    as http;

import '../models/seat_booking_models.dart';
import '../../user_management/services/auth_storage.dart';

class SeatBookingApiException
    implements Exception {

  final String message;

  const SeatBookingApiException(
    this.message,
  );

  @override
  String toString() =>
      message;
}

class SeatBookingApi {
  static String get baseUrl {

    const env =
        String.fromEnvironment(
      'API_BASE',
      defaultValue: '',
    );

    if (env.isNotEmpty) {
      return env;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    switch (
      defaultTargetPlatform
    ) {

      case TargetPlatform.android:

        return 'http://10.0.2.2:8080';

      default:

        return 'http://localhost:8080';
    }
  }

  Future<List<SeatMapSeat>>
  getSeatMap({

    required String date,

    required String startTime,

    required String endTime,

  }) async {

    final uri =
        Uri.parse(
          '$baseUrl/api/v1/seat-bookings/seat-map',
        ).replace(
          queryParameters: {
            'date': date,
            'startTime':
                startTime,
            'endTime':
                endTime,
          },
        );

    final response =
        await http.get(
          uri,
        );

    _ensureOk(
      response,
    );

    final body =
        jsonDecode(
              response.body,
            )
            as List<dynamic>;

    return body
        .map(
          (item) =>
              SeatMapSeat.fromJson(
                item
                    as Map<
                      String,
                      dynamic
                    >,
              ),
        )
        .toList();
  }

  Future<SeatBookingRecord>
  createBooking({

    required String seatCode,

    required String bookingDate,

    required String startTime,

    required String endTime,

    String? userId,

  }) async {
    final requestedUserId = userId?.trim();
    final profile = requestedUserId == null || requestedUserId.isEmpty
        ? await AuthStorage().getUser()
        : null;
    final resolvedUserId =
        requestedUserId?.isNotEmpty == true
            ? requestedUserId
            : profile?.universityId?.trim().isNotEmpty == true
                ? profile!.universityId!.trim()
                : profile?.id.trim();
    if (resolvedUserId == null || resolvedUserId.isEmpty) {
      throw const SeatBookingApiException(
        'Sign in to reserve a study seat.',
      );
    }

    final response =
        await http.post(

      Uri.parse(
        '$baseUrl/api/v1/seat-bookings',
      ),

      headers: const {
        'Content-Type':
            'application/json',
      },

      body: jsonEncode({
        'userId': resolvedUserId,

        'seatCode':
            seatCode,

        'bookingDate':
            bookingDate,

        'startTime':
            startTime,

        'endTime':
            endTime,
      }),
    );

    _ensureOk(
      response,
    );

    return SeatBookingRecord
        .fromJson(
      jsonDecode(
            response.body,
          )
          as Map<
            String,
            dynamic
          >,
    );
  }

  Future<SeatBookingRecord>
  getBooking(
    String bookingId,
  ) async {

    final response =
        await http.get(

      Uri.parse(
        '$baseUrl/api/v1/seat-bookings/$bookingId',
      ),
    );

    _ensureOk(
      response,
    );

    return SeatBookingRecord
        .fromJson(
      jsonDecode(
            response.body,
          )
          as Map<
            String,
            dynamic
          >,
    );
  }

  Future<SeatBookingRecord>
  checkIn({

    required String bookingId,

    required String seatCode,

  }) async {

    final response =
        await http.post(

      Uri.parse(
        '$baseUrl/api/v1/seat-bookings/$bookingId/check-in',
      ),

      headers: const {
        'Content-Type':
            'application/json',
      },

      body: jsonEncode({
        'seatCode':
            seatCode,
      }),
    );

    _ensureOk(
      response,
    );

    return SeatBookingRecord
        .fromJson(
      jsonDecode(
            response.body,
          )
          as Map<
            String,
            dynamic
          >,
    );
  }

  Future<SeatBookingRecord>
  cancelBooking(
    String bookingId,
  ) async {

    final response =
        await http.post(

      Uri.parse(
        '$baseUrl/api/v1/seat-bookings/$bookingId/cancel',
      ),
    );

    _ensureOk(
      response,
    );

    return SeatBookingRecord
        .fromJson(
      jsonDecode(
            response.body,
          )
          as Map<
            String,
            dynamic
          >,
    );
  }

  Future<void>
  deleteBooking(
    String bookingId,
  ) async {

    final response =
        await http.delete(

      Uri.parse(
        '$baseUrl/api/v1/seat-bookings/$bookingId',
      ),
    );

    _ensureOk(
      response,
    );
  }

  void _ensureOk(
    http.Response response,
  ) {

    if (
      response.statusCode >=
              200 &&
          response.statusCode <
              300
    ) {

      return;
    }

    String message =
        'Request failed (${response.statusCode})';

    try {

      final decoded =
          jsonDecode(
            response.body,
          );

      if (
        decoded
            is Map<
              String,
              dynamic
            >
      ) {

        message =
            decoded['message']
                    ?.toString() ??
                message;
      }

    } catch (_) {

      if (
        response.body
            .trim()
            .isNotEmpty
      ) {

        message =
            response.body
                .trim();
      }
    }

    throw SeatBookingApiException(
      message,
    );
  }
}