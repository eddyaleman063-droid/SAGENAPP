import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/screens/splash_screen.dart';

class _WelcomeStub extends StatelessWidget {
  const _WelcomeStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('WELCOME_STUB')));
  }
}

Widget _wrap({bool autoNavigate = true}) {
  final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(
        name: 'welcome',
        path: '/welcome',
        builder: (_, _) => const _WelcomeStub(),
      ),
    ],
  );
  return MaterialApp.router(
    routerConfig: router,
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  testWidgets('fase 1 muestra titulo sobre fondo splash sin spinner', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap());
    expect(find.text('SAGEN'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('fase 2 muestra spinner de carga', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('autoNavigate false no navega al terminar animacion', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(autoNavigate: false));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('WELCOME_STUB'), findsNothing);
    expect(find.text('SAGEN'), findsOneWidget);
  });

  testWidgets('autoNavigate true navega a welcome', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('WELCOME_STUB'), findsOneWidget);
  });

  testWidgets('tap navega inmediatamente', (tester) async {
    await tester.pumpWidget(_wrap());
    await tester.tap(find.text('SAGEN'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('WELCOME_STUB'), findsOneWidget);
  });
}
