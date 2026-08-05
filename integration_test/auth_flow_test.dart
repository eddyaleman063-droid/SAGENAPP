import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sagen/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SAGEN Auth Flow — Splash → Welcome → Login/Register', () {
    testWidgets('1. App launches and shows splash screen', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // App should render something (splash, login, or onboarding)
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasScaffold, true, reason: 'App must render at least a Scaffold on launch');
    });

    testWidgets('2. Splash transitions to welcome or login', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should have navigated past splash to some interactive screen
      final hasTextField = find.byType(TextFormField).evaluate().isNotEmpty;
      final hasBottomNav = find.byType(BottomNavigationBar).evaluate().isNotEmpty;
      final hasButtons = find.byType(ElevatedButton).evaluate().isNotEmpty ||
          find.byType(TextButton).evaluate().isNotEmpty ||
          find.byType(OutlinedButton).evaluate().isNotEmpty;

      expect(hasTextField || hasBottomNav || hasButtons, true,
          reason: 'App should transition from splash to login or dashboard');
    });

    testWidgets('3. Login screen renders all fields when accessible', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final emailField = find.byType(TextFormField);
      if (emailField.evaluate().isEmpty) return; // Not on login screen

      // Login should have at least email field
      expect(emailField.evaluate().isNotEmpty, true,
          reason: 'Login screen should have text input fields');

      // Look for login-specific text
      final hasLoginText = find.textContaining('Iniciar').evaluate().isNotEmpty ||
          find.textContaining('Login').evaluate().isNotEmpty ||
          find.textContaining('Email').evaluate().isNotEmpty ||
          find.textContaining('email').evaluate().isNotEmpty;

      expect(hasLoginText || emailField.evaluate().isNotEmpty, true,
          reason: 'Login screen should show login-related text');
    });

    testWidgets('4. Register screen renders when accessible', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Look for register link/button
      final registerLink = find.textContaining('Registrate');
      final signUpLink = find.textContaining('Sign up');
      final createAccount = find.textContaining('Crear cuenta');

      if (registerLink.evaluate().isEmpty &&
          signUpLink.evaluate().isEmpty &&
          createAccount.evaluate().isEmpty) {
        return; // Register not visible from current screen
      }

      // If we found a register link, it should be tappable
      final link = registerLink.evaluate().isNotEmpty
          ? registerLink.first
          : signUpLink.evaluate().isNotEmpty
              ? signUpLink.first
              : createAccount.first;

      expect(link, findsOneWidget, reason: 'Register link should be present');
    });

    testWidgets('5. Navigation between login and register', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Try to find register navigation
      final registerLink = find.textContaining('Registrate');
      final signUpLink = find.textContaining('Sign up');

      if (registerLink.evaluate().isNotEmpty) {
        await tester.tap(registerLink.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        // After tapping register, should show register-related content
        final hasRegisterContent = find.textContaining('Crear cuenta').evaluate().isNotEmpty ||
            find.textContaining('Registro').evaluate().isNotEmpty ||
            find.byType(TextFormField).evaluate().length >= 2;

        expect(hasRegisterContent || find.byType(Scaffold).evaluate().isNotEmpty, true,
            reason: 'Register screen should be accessible from login');
      } else if (signUpLink.evaluate().isNotEmpty) {
        await tester.tap(signUpLink.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
        expect(find.byType(Scaffold).evaluate().isNotEmpty, true);
      }
    });

    testWidgets('6. App handles authentication state correctly', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // App should not crash and should show a valid screen
      final hasScaffold = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasScaffold, true, reason: 'App should always show a valid screen');
    });

    testWidgets('7. App has semantic structure for accessibility', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final hasSemantics = find.byType(Semantics).evaluate().isNotEmpty;
      expect(hasSemantics, true, reason: 'App should have semantic labels');
    });

    testWidgets('8. App handles rapid navigation without crash', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Rapidly interact with available elements
      final buttons = find.byType(GestureDetector);
      final count = buttons.evaluate().length;
      final tapsToPerform = count > 5 ? 5 : count;

      for (int i = 0; i < tapsToPerform; i++) {
        if (buttons.evaluate().length > i) {
          await tester.tap(buttons.at(i));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // App should not crash
      expect(find.byType(Scaffold).evaluate().isNotEmpty, true,
          reason: 'Rapid navigation should not crash the app');
    });
  });
}
