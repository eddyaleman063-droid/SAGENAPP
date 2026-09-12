import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/ui/screens/auth/forgot_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthService extends AuthService {
  _FakeAuthService({this.onSend});

  final Future<void> Function(String email)? onSend;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (onSend != null) {
      await onSend!(email);
      return;
    }
    throw StateError('unexpected call');
  }
}

GoRouter _router(_FakeAuthService auth) => GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const Scaffold(body: Text('LOGIN')),
    ),
    GoRoute(path: '/forgot', builder: (_, _) => const ForgotPasswordScreen()),
  ],
);

Widget _wrap(GoRouter router, _FakeAuthService auth, SharedPreferences prefs) {
  return ProviderScope(
    overrides: [
      authServiceProvider.overrideWithValue(auth),
      prefsProvider.overrideWithValue(prefs),
    ],
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<SharedPreferences> _newPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

Future<void> _open(
  WidgetTester tester,
  GoRouter router,
  _FakeAuthService auth,
) async {
  await tester.pumpWidget(_wrap(router, auth, await _newPrefs()));
  await tester.pump(const Duration(milliseconds: 500));
  router.push('/forgot');
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

AppLocalizations _l(WidgetTester tester) {
  return AppLocalizations.of(
    tester.element(find.byType(ForgotPasswordScreen)),
  )!;
}

void main() {
  testWidgets('renderiza titulo, descripcion y boton de enviar', (
    tester,
  ) async {
    await _open(tester, _router(_FakeAuthService()), _FakeAuthService());
    final l = _l(tester);
    expect(find.text(l.authForgotPasswordTitle), findsNWidgets(2));
    expect(find.text(l.authForgotPasswordDesc), findsOneWidget);
    expect(find.text(l.authSendLink), findsOneWidget);
    expect(find.text(l.authEmailLabel), findsOneWidget);
  });

  testWidgets('email vacio muestra advertencia', (tester) async {
    await _open(tester, _router(_FakeAuthService()), _FakeAuthService());
    final l = _l(tester);
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l.authEnterEmailError), findsOneWidget);
  });

  testWidgets('email invalido muestra advertencia', (tester) async {
    await _open(tester, _router(_FakeAuthService()), _FakeAuthService());
    final l = _l(tester);
    await tester.enterText(find.byType(TextField), 'no-es-un-email');
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l.authEmailInvalid), findsOneWidget);
  });

  testWidgets('email valido envia el reset y muestra estado enviado', (
    tester,
  ) async {
    String? sentTo;
    final auth = _FakeAuthService(onSend: (email) async => sentTo = email);
    await _open(tester, _router(auth), auth);
    final l = _l(tester);
    await tester.enterText(find.byType(TextField), 'user@example.com');
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(sentTo, 'user@example.com');
    expect(find.text(l.authRecoveryEmailSentTitle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
  });

  testWidgets('enviar por teclado (done) funciona', (tester) async {
    String? sentTo;
    final auth = _FakeAuthService(onSend: (email) async => sentTo = email);
    await _open(tester, _router(auth), auth);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(sentTo, 'a@b.com');
  });

  testWidgets('AuthException muestra error localizado', (tester) async {
    final auth = _FakeAuthService(
      onSend: (_) async => throw const AuthException('network_error'),
    );
    await _open(tester, _router(auth), auth);
    final l = _l(tester);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l.authNetworkError), findsOneWidget);
  });

  testWidgets('error generico muestra notificacion de error', (tester) async {
    final auth = _FakeAuthService(onSend: (_) async => throw Exception('boom'));
    await _open(tester, _router(auth), auth);
    final l = _l(tester);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text(l.authSendEmailError), findsOneWidget);
  });

  testWidgets('boton atras regresa al login', (tester) async {
    final auth = _FakeAuthService();
    await _open(tester, _router(auth), auth);
    final l = _l(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip(l.backButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LOGIN'), findsOneWidget);
  });

  testWidgets('boton volver en estado enviado regresa', (tester) async {
    final auth = _FakeAuthService(onSend: (_) async {});
    await _open(tester, _router(auth), auth);
    final l = _l(tester);
    await tester.enterText(find.byType(TextField), 'a@b.com');
    await tester.tap(find.text(l.authSendLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l.authBack));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
