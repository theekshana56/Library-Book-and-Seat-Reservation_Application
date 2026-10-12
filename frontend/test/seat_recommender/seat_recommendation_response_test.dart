import 'package:biblione/seat_recommender/models/seat_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SeatRecommendationResponse.fromJson', () {
    test('parses exact and closest match lists', () {
      final response = SeatRecommendationResponse.fromJson({
        'exactMatches': [
          {
            'id': 'seat-1',
            'seatCode': 'A12',
            'floor': 'Level 2',
            'zone': 'Quiet Zone',
            'hasPowerOutlet': true,
            'acousticsDb': 24,
            'features': ['Power outlet'],
            'matchScore': 96,
          },
        ],
        'closestMatches': [
          {
            'id': 'seat-2',
            'seatCode': 'B04',
            'floor': 'Level 1',
            'zone': 'General Zone',
            'hasPowerOutlet': false,
            'acousticsDb': 35,
            'features': [],
            'matchScore': 82,
          },
        ],
      });

      expect(response.exactMatches.single.seatCode, 'A12');
      expect(response.closestMatches.single.seatCode, 'B04');
    });

    test('uses empty lists when match lists are absent', () {
      final response = SeatRecommendationResponse.fromJson({});

      expect(response.exactMatches, isEmpty);
      expect(response.closestMatches, isEmpty);
    });
  });
}
