import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:biblione/api/api_client.dart';
import 'package:biblione/models/models.dart';
import 'package:biblione/screens/home_screen.dart';
import 'package:biblione/user_management/models/user_profile.dart';

class _HomeApi extends ApiClient {
  int calls = 0;
  final requestedUserIds = <String?>[];
  bool failFirstRequest = false;

  @override
  Future<UserBookings> getBookings([String? userId]) async {
    calls++;
    requestedUserIds.add(userId);
    if (failFirstRequest && calls == 1) {
      throw ApiException('API unavailable');
    }
    return const UserBookings(
      userId: 'IT23773158',
      activeCount: 0,
      historyCount: 0,
      loanLimit: 5,
      reservations: [],
      seatHolds: [],
      loans: [],
    );
  }
}

void main() {
  testWidgets('home loads live booking data and opens quick actions', (
    tester,
  ) async {
    final api = _HomeApi();
    var openedSeats = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            apiClient: api,
            userProfile: const UserProfile(
              id: 'user-1',
              universityId: 'IT23773158',
              fullName: 'Ravindu Weerasinghe',
              email: 'ravindu@example.edu',
              role: 'STUDENT',
            ),
            onFindSeat: () => openedSeats = true,
            onExploreBooks: () {},
            onViewBookings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.calls, 1);
    expect(api.requestedUserIds, ['IT23773158']);
    expect(find.text('IT23773158'), findsOneWidget);
    expect(find.textContaining('Ravindu 👋'), findsOneWidget);
    expect(find.text('YOUR LIBRARY SNAPSHOT'), findsOneWidget);
    await tester.tap(find.text('Find a desk'));
    expect(openedSeats, isTrue);

    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.text('Your next great study session starts here.'),
    );
    expect(
      find.text('Your next great study session starts here.'),
      findsOneWidget,
    );
  });

  testWidgets('home displays backend errors and can retry', (tester) async {
    final api = _HomeApi()..failFirstRequest = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            apiClient: api,
            userProfile: const UserProfile(
              id: 'user-1',
              universityId: 'IT23773158',
              fullName: 'Ravindu Weerasinghe',
              email: 'ravindu@example.edu',
              role: 'STUDENT',
            ),
            onFindSeat: () {},
            onExploreBooks: () {},
            onViewBookings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('We couldn’t load your library activity.'),
      findsOneWidget,
    );
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(api.calls, 2);
    expect(find.text('YOUR LIBRARY SNAPSHOT'), findsOneWidget);
  });

  testWidgets('home does not fall back to seeded demo member data', (
    tester,
  ) async {
    final api = _HomeApi();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeScreen(
            apiClient: api,
            onFindSeat: () {},
            onExploreBooks: () {},
            onViewBookings: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.calls, 0);
    expect(find.text('there 👋'), findsNothing);
    expect(
      find.text('Sign in to view your library activity.'),
      findsOneWidget,
    );
  });
}
