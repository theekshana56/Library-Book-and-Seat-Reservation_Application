import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:biblione/admin/controllers/admin_api_client.dart';
import 'package:biblione/admin/screens/admin_proposal_review_screen.dart';
import 'package:biblione/admin/screens/publisher_proposal_form_screen.dart';
import 'package:biblione/api/api_client.dart';
import 'package:biblione/debug_agent_log.dart';
import 'package:biblione/main.dart';
import 'package:biblione/models/book.dart';
import 'package:biblione/user_management/widgets/auth_gate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:biblione/screens/search_catalog_screen.dart';

class FakeApiClient extends ApiClient {
  @override
  Future<List<Book>> searchBooks({
    String query = '',
    String category = '',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return const [];
  }
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });
  testWidgets('search catalog does not update state after disposal', (
    WidgetTester tester,
  ) async {
    final fakeApi = FakeApiClient();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SearchCatalogScreen(apiClient: fakeApi)),
      ),
    );
    await tester.pump();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(tester.takeException(), isNull);
  });

  testWidgets('app builds and exposes the auth gate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BiblioneApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(AuthGate), findsOneWidget);
  });

  testWidgets('vendor submit and reload do not break the pushed admin route', (
    WidgetTester tester,
  ) async {
    Map<String, dynamic>? submittedPayload;
    final client = MockClient((request) async {
      if (request.method == 'POST') {
        submittedPayload = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            ...submittedPayload!,
            'id': 'proposal-test',
            'vendorName': 'Test Vendor',
            'status': 'PENDING_ADMIN_REVIEW',
            'createdAt': '2026-09-29T10:00:00',
          }),
          201,
        );
      }
      if (request.method == 'GET') return http.Response('[]', 200);
      return http.Response('Not found', 404);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PublisherProposalFormScreen(
                      apiClient: AdminApiClient(client: client),
                    ),
                  ),
                ),
                child: const Text('Open vendor form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open vendor form'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(1));
    await tester.enterText(fields.at(1), 'Test title');
    await tester.ensureVisible(fields.at(2));
    await tester.enterText(fields.at(2), 'Test author');
    await tester.ensureVisible(fields.at(4));
    await tester.enterText(fields.at(4), 'Computer Science');
    await tester.ensureVisible(fields.at(6));
    await tester.enterText(fields.at(6), '12.50');
    await tester.ensureVisible(fields.at(7));
    await tester.enterText(fields.at(7), '5');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final submitButton = find.widgetWithText(FilledButton, 'Submit Proposal');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();
    await tester.tap(submitButton);
    for (var frame = 0; frame < 8 && submittedPayload == null; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    for (var frame = 0; frame < 4; frame++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(submittedPayload?['description'], isA<String>());
    expect(find.text('Offer submitted for admin review.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Open vendor form'), findsOneWidget);
    expect(tester.takeException(), isNull);
    client.close();
  });

  testWidgets('vendor ISBN lookup fills book details from Google Books', (
    WidgetTester tester,
  ) async {
    http.Request? lookupRequest;
    final apiClient = MockClient((_) async => http.Response('[]', 200));
    final googleBooksClient = MockClient((request) async {
      lookupRequest = request;
      return http.Response(
        jsonEncode({
          'items': [
            {
              'volumeInfo': {
                'title': 'The Pragmatic Programmer',
                'authors': ['David Thomas'],
                'categories': ['Computers'],
                'description': 'A software development book.',
                'imageLinks': {'thumbnail': 'http://example.com/cover.jpg'},
              },
            },
          ],
        }),
        200,
      );
    });

    await tester.pumpWidget(
      MaterialApp(
        home: PublisherProposalFormScreen(
          apiClient: AdminApiClient(client: apiClient),
          googleBooksClient: googleBooksClient,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final isbnField = find.byType(TextFormField).at(3);
    await tester.ensureVisible(isbnField);
    await tester.enterText(isbnField, '978-0-13-595705-9');
    final lookupButton = find.widgetWithText(
      FilledButton,
      'Auto-Fill from ISBN',
    );
    await tester.ensureVisible(lookupButton);
    await tester.tap(lookupButton);
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextFormField>(find.byType(TextFormField));
    expect(lookupRequest?.url.host, 'www.googleapis.com');
    expect(lookupRequest?.url.path, '/books/v1/volumes');
    expect(lookupRequest?.url.queryParameters['q'], 'isbn:9780135957059');
    expect(fields.elementAt(1).controller?.text, 'The Pragmatic Programmer');
    expect(fields.elementAt(2).controller?.text, 'David Thomas');
    expect(fields.elementAt(4).controller?.text, 'Computers');
    expect(
      fields.elementAt(8).controller?.text,
      'https://example.com/cover.jpg',
    );
    expect(find.text('Book details filled from Google Books.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    apiClient.close();
    googleBooksClient.close();
  });

  testWidgets('vendor ISBN lookup reports Google Books quota errors', (
    WidgetTester tester,
  ) async {
    final apiClient = MockClient((_) async => http.Response('[]', 200));
    final googleBooksClient = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'error': {'code': 429, 'message': 'Quota exceeded'},
        }),
        429,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PublisherProposalFormScreen(
          apiClient: AdminApiClient(client: apiClient),
          googleBooksClient: googleBooksClient,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final isbnField = find.byType(TextFormField).at(3);
    await tester.ensureVisible(isbnField);
    await tester.enterText(isbnField, '9780135957059');
    final lookupButton = find.widgetWithText(
      FilledButton,
      'Auto-Fill from ISBN',
    );
    await tester.ensureVisible(lookupButton);
    await tester.tap(lookupButton);
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Google Books request limit reached. Check the API quota in Google Cloud or try again later.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox());
    apiClient.close();
    googleBooksClient.close();
  });

  testWidgets(
    'approve dialog disposes controllers while the route is still animating',
    (WidgetTester tester) async {
      final exceptions = <Object>[];
      final previousOnError = FlutterError.onError;
      addTearDown(() {
        FlutterError.onError = previousOnError;
      });
      final proposal = {
        'id': 'p1',
        'vendorId': 'v1',
        'vendorName': 'Vendor',
        'bookTitle': 'Runtime Book',
        'author': 'Ada',
        'isbn': '123',
        'category': 'CS',
        'description': 'desc',
        'proposedPrice': 10.0,
        'vendorSupplyQty': 4,
        'adminRequestedLotQty': 0,
        'adminMessage': '',
        'sampleCoverImageUrl': '',
        'status': 'PENDING_ADMIN_REVIEW',
      };
      final client = MockClient((request) async {
        if (request.method == 'GET' && request.url.path.contains('proposals')) {
          return http.Response(jsonEncode([proposal]), 200);
        }
        if (request.method == 'PUT') {
          return http.Response(
            jsonEncode({...proposal, 'status': 'APPROVED'}),
            200,
          );
        }
        return http.Response('[]', 200);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: AdminProposalReviewScreen(
            apiClient: AdminApiClient(client: client),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Runtime Book'), findsOneWidget);

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(find.text('Approve book offer'), findsOneWidget);

      final fields = find.byType(TextField);
      await tester.tap(fields.last);
      await tester.enterText(fields.last, 'ok');
      await tester.pump();

      FlutterError.onError = (details) {
        exceptions.add(details.exception);
        agentDebugLog(
          location: 'widget_test.dart:reviewDialog',
          message: details.exceptionAsString(),
          hypothesisId: 'A',
          runId: 'post-fix',
          data: {
            'stack': details.stack?.toString().split('\n').take(8).join(' | '),
          },
        );
      };

      await tester.tap(find.text('Approve offer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      agentDebugLog(
        location: 'widget_test.dart:reviewDialogSummary',
        message: 'exceptions after approve dialog close',
        hypothesisId: 'A',
        runId: 'post-fix',
        data: {
          'count': exceptions.length,
          'exceptions': exceptions.map((e) => e.toString()).take(5).toList(),
        },
      );

      expect(exceptions, isEmpty);
      client.close();
    },
  );
}
