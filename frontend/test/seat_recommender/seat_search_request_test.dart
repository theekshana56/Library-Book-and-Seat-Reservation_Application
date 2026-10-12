import 'package:biblione/seat_recommender/models/seat_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeatSearchRequest.toJson', () {
    test('serializes all fields with a zero-padded date', () {
      final request = SeatSearchRequest(
        date: DateTime(2026, 10, 12),
        startTime: '09:05:00',
        durationMinutes: 90,
        zonePreference: 'Quiet Zone',
        powerRequired: true,
      );

      expect(request.toJson(), {
        'date': '2026-10-12',
        'startTime': '09:05:00',
        'durationMinutes': 90,
        'zonePreference': 'Quiet Zone',
        'powerRequired': true,
      });
    });

    test('preserves a null power preference', () {
      final request = SeatSearchRequest(
        date: DateTime(2026, 1, 2),
        startTime: '08:00:00',
        durationMinutes: 60,
        zonePreference: 'General Zone',
        powerRequired: null,
      );

      expect(request.toJson()['powerRequired'], isNull);
    });
  });
}
