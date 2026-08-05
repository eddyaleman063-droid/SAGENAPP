import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN E2E — Localization', () {
    testWidgets('app renders in system locale', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should render without locale-related errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('no untranslated strings visible', (tester) async {
      SharedPreferences.setMockInitialValues({});
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check for common untranslated patterns
      final allText = find.byType(Text);
      for (final textWidget in allText.evaluate()) {
        final text = textWidget.widget as Text;
        if (text.data != null) {
          // Should not contain raw key patterns like 'someKey'
          expect(
            text.data!.contains(RegExp(r'^[a-z]+$')),
            false,
            reason: 'Untranslated string found: ${text.data}',
          );
        }
      }
    });
  });
}
