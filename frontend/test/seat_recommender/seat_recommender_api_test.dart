import 'dart:convert';

import 'package:biblione/api/api_client.dart';
import 'package:biblione/seat_recommender/api/seat_recommender_api.dart';
import 'package:biblione/seat_recommender/models/seat_recommendation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final request = SeatSearchRequest(
    date: DateTime(2026, 10, 12),
    startTime: '09:05:00',
    durationMinutes: 90,
    zonePreference: 'Quiet Zone',
    powerRequired: true,
  );

  group('SeatRecommenderApi.recommend', () {
    test('posts the request and parses exact and closest matches', () async {
      final client = MockClient((httpRequest) async {
        expect(httpRequest.method, 'POST');
        expect(httpRequest.url.path, '/api/v1/seats/recommend');
        expect(httpRequest.headers['content-type'], 'application/json');
        expect(jsonDecode(httpRequest.body), request.toJson());

        return http.Response(
          jsonEncode({
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
            'closestMatches': [],
          }),
          200,
        );
      });

      final response = await SeatRecommenderApi(client: client)
          .recommend(request);

      expect(response.exactMatches.single.seatCode, 'A12');
      expect(response.closestMatches, isEmpty);
    });

    test(
      'returns empty match lists for an empty successful response',
      () async {
        final client = MockClient(
          (_) async => http.Response(jsonEncode(<String, dynamic>{}), 200),
        );

        final response = await SeatRecommenderApi(client: client)
            .recommend(request);

        expect(response.exactMatches, isEmpty);
        expect(response.closestMatches, isEmpty);
      },
    );

    test('throws ApiException for an unsuccessful response', () {
      final client = MockClient(
        (_) async => http.Response('server error', 500),
      );

      expect(
        () => SeatRecommenderApi(client: client).recommend(request),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Seat search failed (500).',
          ),
        ),
      );
    });
  });
}
