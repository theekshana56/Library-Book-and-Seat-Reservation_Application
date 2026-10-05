import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:biblione/seat_recommender/models/seat_recommendation.dart';
import 'package:biblione/seat_recommender/screens/ranked_results_screen.dart';

void main() {
  testWidgets('recommended seat continues to booking review', (tester) async {
    final request = SeatSearchRequest(
      date: DateTime(2026, 10, 10),
      startTime: '09:00:00',
      durationMinutes: 150,
      zonePreference: 'Quiet Zone',
      powerRequired: null,
    );
    const response = SeatRecommendationResponse(
      exactMatches: [
        SeatMatch(
          id: 'seat-1',
          seatCode: 'A12',
          floor: 'Level 2',
          zone: 'Quiet Zone',
          hasPowerOutlet: true,
          acousticsDb: 24,
          features: ['Power outlet'],
          matchScore: 96,
        ),
      ],
      closestMatches: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: RankedResultsScreen(
          response: response,
          request: request,
          userId: 'IT20260001',
        ),
      ),
    );

    await tester.tap(find.text('View & Book Seat - A12'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to booking'));
    await tester.pumpAndSettle();

    expect(find.text('A12'), findsNWidgets(2));
    expect(find.text('10 October 2026'), findsOneWidget);
    expect(find.textContaining('9:00 AM'), findsOneWidget);
    expect(find.textContaining('11:30 AM'), findsOneWidget);
  });
}
