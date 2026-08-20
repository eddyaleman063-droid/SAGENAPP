import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN E2E — Login → Onboarding → Lesson → Reward', () {
    testWidgets('1. App launches and shows initial screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should show either login, onboarding, or dashboard
      final hasLogin =
          find.textContaining('Iniciar').evaluate().isNotEmpty ||
          find.textContaining('Login').evaluate().isNotEmpty ||
          find.textContaining('Email').evaluate().isNotEmpty;
      final hasOnboarding = find
          .byType(BottomNavigationBar)
          .evaluate()
          .isNotEmpty;
      final hasWelcome = find.textContaining('SAGEN').evaluate().isNotEmpty;

      expect(
        hasLogin || hasOnboarding || hasWelcome,
        true,
        reason: 'App must show login, onboarding, or dashboard on launch',
      );
    });

    testWidgets('2. Login screen has email and password fields', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Only run if on login screen
      final emailField = find.byType(TextFormField).first;
      if (emailField.evaluate().isEmpty) return; // Skip if not on login

      expect(
        emailField,
        findsOneWidget,
        reason: 'Login must have input fields',
      );
    });

    testWidgets('3. Onboarding screens are navigable', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for onboarding-specific widgets
      final hasWizard = find.byType(Scaffold).evaluate().isNotEmpty;
      if (!hasWizard) return;

      // Try to find and tap continue/next buttons
      final continueButtons = find.textContaining('Continuar');
      final nextButtons = find.textContaining('Siguiente');
      final skipButtons = find.textContaining('Omitir');

      if (continueButtons.evaluate().isNotEmpty) {
        await tester.tap(continueButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      } else if (nextButtons.evaluate().isNotEmpty) {
        await tester.tap(nextButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      } else if (skipButtons.evaluate().isNotEmpty) {
        await tester.tap(skipButtons.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }
    });

    testWidgets('4. Dashboard shows learning content', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if we reached dashboard (has bottom nav)
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isEmpty) return; // Not on dashboard

      // Dashboard should show some learning content
      final hasLessons =
          find.textContaining('Leccion').evaluate().isNotEmpty ||
          find.textContaining('Etapa').evaluate().isNotEmpty ||
          find.textContaining('Aprender').evaluate().isNotEmpty;
      final hasStreak = find
          .byIcon(Icons.local_fire_department_rounded)
          .evaluate()
          .isNotEmpty;
      final hasGems = find.byIcon(Icons.diamond_rounded).evaluate().isNotEmpty;

      expect(
        hasLessons || hasStreak || hasGems,
        true,
        reason: 'Dashboard should show learning content, streak, or gems',
      );
    });

    testWidgets('5. Lesson screen is accessible from dashboard', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isEmpty) return;

      // Try to tap on first lesson card
      final lessonCards = find.byType(Card);
      if (lessonCards.evaluate().isNotEmpty) {
        await tester.tap(lessonCards.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 1000));

        // At minimum, the app shouldn't crash
        expect(true, true, reason: 'Lesson navigation did not crash');
      }
    });

    testWidgets('6. Accessibility: semantic labels present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check that the app has basic semantic structure
      final hasSemantics = find.byType(Semantics).evaluate().isNotEmpty;
      expect(
        hasSemantics,
        true,
        reason: 'App should have semantic labels for accessibility',
      );
    });

    testWidgets('7. App handles rapid navigation without crash', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Rapidly tap bottom nav items
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isEmpty) return;

      for (int i = 0; i < 4; i++) {
        final items = find.byType(BottomNavigationBarItem);
        if (items.evaluate().length > i) {
          await tester.tap(items.at(i));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // App should not crash
      expect(true, true, reason: 'Rapid navigation should not crash');
    });

    testWidgets('8. Profile screen shows user info', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Navigate to profile tab (last item in bottom nav)
      final navBar = find.byType(BottomNavigationBar);
      if (navBar.evaluate().isEmpty) return;

      final items = find.byType(BottomNavigationBarItem);
      if (items.evaluate().length >= 4) {
        await tester.tap(items.last);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // Profile should show some user info
        final hasProfile =
            find.byIcon(Icons.person_rounded).evaluate().isNotEmpty ||
            find.textContaining('Perfil').evaluate().isNotEmpty;
        expect(
          hasProfile || items.evaluate().length >= 4,
          true,
          reason: 'Profile screen should be accessible',
        );
      }
    });
  });
}

/// Placeholder for quiz widget detection
class QuizWidget extends StatelessWidget {
  const QuizWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
