import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/exit_confirmation_wrapper.dart';

GoRouter _router() => GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const Scaffold(body: Text('HOME')),
    ),
    GoRoute(
      path: '/inner',
      builder: (_, _) => const ExitConfirmationWrapper(
        child: Scaffold(body: Text('dentro del juego')),
      ),
    ),
  ],
);

Widget _wrap(GoRouter router) {
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _openInner(WidgetTester tester, GoRouter router) async {
  await tester.pumpWidget(_wrap(router));
  await _settle(tester);
  router.push('/inner');
  await tester.pump();
  await _settle(tester);
}

void _triggerBack(WidgetTester tester) {
  final ctx = tester.element(find.byType(ExitConfirmationWrapper));
  Navigator.of(ctx).maybePop();
}

void main() {
  testWidgets('renderiza el child sin dialog', (tester) async {
    await _openInner(tester, _router());
    expect(find.text('dentro del juego'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('volver abre el dialog de confirmacion', (tester) async {
    await _openInner(tester, _router());
    _triggerBack(tester);
    await tester.pump();
    await _settle(tester);

    final l = AppLocalizations.of(
      tester.element(find.byType(ExitConfirmationWrapper)),
    )!;
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l.miniGameExitTitle), findsOneWidget);
    expect(find.text(l.miniGameExitContent), findsOneWidget);
  });

  testWidgets('cancelar cierra el dialog y NO sale del juego', (tester) async {
    await _openInner(tester, _router());
    _triggerBack(tester);
    await tester.pump();
    await _settle(tester);

    final l = AppLocalizations.of(
      tester.element(find.byType(ExitConfirmationWrapper)),
    )!;
    await tester.tap(find.text(l.cancel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('dentro del juego'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('salir cierra el dialog y navega hacia atras', (tester) async {
    await _openInner(tester, _router());
    _triggerBack(tester);
    await tester.pump();
    await _settle(tester);

    final l = AppLocalizations.of(
      tester.element(find.byType(ExitConfirmationWrapper)),
    )!;
    await tester.tap(find.text(l.exitText));
    await tester.pump();
    await _settle(tester);

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('dentro del juego'), findsNothing);
  });

  testWidgets('segundo back tras cancelar vuelve a pedir confirmacion', (
    tester,
  ) async {
    await _openInner(tester, _router());
    _triggerBack(tester);
    await tester.pump();
    await _settle(tester);
    final l = AppLocalizations.of(
      tester.element(find.byType(ExitConfirmationWrapper)),
    )!;
    await tester.tap(find.text(l.cancel));
    await tester.pump();
    await _settle(tester);

    _triggerBack(tester);
    await tester.pump();
    await _settle(tester);
    expect(find.byType(AlertDialog), findsOneWidget);
  });
}
