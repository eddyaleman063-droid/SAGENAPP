import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/auth/verify_email_screen.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createTestApp() {
    final router = GoRouter(
      initialLocation: '/verify-email',
      routes: [
        GoRoute(
          path: '/verify-email',
          name: 'verify-email',
          builder: (context, state) => const VerifyEmailScreen(),
        ),
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('home'))),
        ),
        GoRoute(
          path: '/welcome',
          name: 'welcome',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('welcome'))),
        ),
        GoRoute(
          path: '/main',
          name: 'main',
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('main'))),
        ),
      ],
    );

    return ProviderScope(
      overrides: [prefsProvider.overrideWithValue(prefs)],
      child: MaterialApp.router(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('VerifyEmailScreen', () {
    testWidgets('renders verification email icon', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.byIcon(Icons.mark_email_unread_rounded), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.text('Verifica tu correo electrónico'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders verification message', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.textContaining('verificación'), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('renders check verification button', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.text('Ya verifiqué'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders resend email button', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.text('Reenviar correo de verificación'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('renders sign out button', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();
      expect(find.text('Cerrar sesión'), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('sign out button shows confirmation dialog', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      await tester.tap(find.text('Cerrar sesión').first);
      await tester.pumpAndSettle();

      expect(
        find.text('¿Estás seguro de que quieres cerrar sesión?'),
        findsOneWidget,
      );
      expect(find.text('Cancelar'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('cancel in dialog dismisses dialog', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pump();

      await tester.tap(find.text('Cerrar sesión').first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      expect(
        find.text('¿Estás seguro de que quieres cerrar sesión?'),
        findsNothing,
      );
      await tester.pumpAndSettle();
    });
  });
}
