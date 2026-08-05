import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN E2E — App Launch', () {
    testWidgets('app launches without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify the app is running and shows something
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('app shows splash or onboarding', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // After splash, app should show either onboarding or login
      final hasOnboarding = find.textContaining('SAGEN').evaluate().isNotEmpty;
      final hasLogin = find.textContaining('Login').evaluate().isNotEmpty;
      final hasWelcome = find.textContaining('Welcome').evaluate().isNotEmpty;

      // At least one of these should be present
      expect(hasOnboarding || hasLogin || hasWelcome, true);
    });
  });
}
