import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN E2E — Accessibility', () {
    testWidgets('all buttons have semantic labels', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find all buttons
      final buttons = find.byType(ElevatedButton);
      final filledButtons = find.byType(FilledButton);
      final textButtons = find.byType(TextButton);
      final iconButtons = find.byType(IconButton);

      // All buttons should be wrapped in Semantics
      for (final finder in [buttons, filledButtons, textButtons, iconButtons]) {
        for (final button in finder.evaluate()) {
          final hasSemantics = find
              .ancestor(
                of: find.byWidget(button.widget),
                matching: find.byType(Semantics),
              )
              .evaluate()
              .isNotEmpty;
          // Button should have Semantics ancestor
          expect(
            hasSemantics,
            true,
            reason: 'Button missing Semantics wrapper',
          );
        }
      }
    });

    testWidgets('no overflow errors on small screens', (tester) async {
      tester.view.physicalSize = const Size(320, 568); // iPhone SE
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should not have any overflow errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow errors on large screens', (tester) async {
      tester.view.physicalSize = const Size(1024, 1366); // iPad
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(tester.takeException(), isNull);
    });
  });
}
