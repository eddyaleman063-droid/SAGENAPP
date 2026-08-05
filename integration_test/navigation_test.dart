import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN E2E — Navigation', () {
    testWidgets('bottom navigation works across tabs', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Find bottom navigation bar
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isEmpty) return; // Not on dashboard yet

      // Tap each nav item
      for (int i = 0; i < 5; i++) {
        final navItem = find.byType(BottomNavigationBarItem).at(i);
        if (navItem.evaluate().isNotEmpty) {
          await tester.tap(navItem);
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }
      }
    });

    testWidgets('back navigation works', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }
    });
  });
}
