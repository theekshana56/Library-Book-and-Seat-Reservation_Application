import 'package:biblione/seat_recommender/models/seat_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeatMatch.fromJson', () {
    test('parses a complete seat payload', () {
      final seat = SeatMatch.fromJson({
        'id': 'seat-1',
        'seatCode': 'A12',
        'floor': 'Level 2',
        'zone': 'Quiet Zone',
        'hasPowerOutlet': true,
        'acousticsDb': 24.8,
        'features': ['Power outlet'],
        'matchScore': 96.7,
      });

      expect(seat.id, 'seat-1');
      expect(seat.seatCode, 'A12');
      expect(seat.floor, 'Level 2');
      expect(seat.zone, 'Quiet Zone');
      expect(seat.hasPowerOutlet, isTrue);
      expect(seat.acousticsDb, 24);
      expect(seat.features, ['Power outlet']);
      expect(seat.matchScore, 96);
    });

    test('uses safe defaults for null values', () {
      final seat = SeatMatch.fromJson({
        'id': null,
        'seatCode': null,
        'floor': null,
        'zone': null,
        'hasPowerOutlet': null,
        'acousticsDb': null,
        'features': null,
        'matchScore': null,
      });

      expect(seat.id, isEmpty);
      expect(seat.seatCode, 'Unknown');
      expect(seat.floor, 'Library floor');
      expect(seat.zone, 'General Zone');
      expect(seat.hasPowerOutlet, isFalse);
      expect(seat.acousticsDb, 0);
      expect(seat.features, isEmpty);
      expect(seat.matchScore, 0);
    });
  });
}
