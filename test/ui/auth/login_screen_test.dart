import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/ui/screens/auth/login_screen.dart';

late SharedPreferences prefs;

Widget _buildApp({
  bool isOnboarding = false,
  VoidCallback? onSwitchToRegister,
}) {
  return ProviderScope(
    overrides: [prefsProvider.overrideWithValue(prefs)],
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: LoginScreen(
        isOnboarding: isOnboarding,
        onSwitchToRegister: onSwitchToRegister,
      ),
    ),
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('renders login title', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Ingresa tus datos'), findsOneWidget);
  });

  testWidgets('renders email and password fields', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('login button is disabled when fields are empty', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'INGRESAR'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('shows close button', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('shows forgot password button', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('RESTABLECER CONTRASEÑA'), findsOneWidget);
  });

  testWidgets('shows create account link when onSwitchToRegister provided', (
    tester,
  ) async {
    var called = false;
    await tester.pumpWidget(_buildApp(onSwitchToRegister: () => called = true));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(called, isFalse);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('Crear cuenta'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('enables login button when valid email and password entered', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(
      find.byType(TextFormField).first,
      'test@example.com',
    );
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.pump(const Duration(milliseconds: 300));
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'INGRESAR'),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('password visibility toggle works', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(Icons.visibility), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });
}
