import 'package:biblione/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Biblione application starts successfully', (tester) async {
    await tester.pumpWidget(
      const BiblioneApp(
        home: Scaffold(
          body: Text('Biblione system test'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Biblione system test'), findsOneWidget);
  });
}
