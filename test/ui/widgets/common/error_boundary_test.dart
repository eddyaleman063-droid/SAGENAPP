import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/error_boundary.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

class _NoPrecacheService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

Widget _wrap({required Widget child, GoRouter? router}) {
  final overrides = [
    reduceAnimationsProvider.overrideWithValue(true),
    sageEmotionServiceProvider.overrideWithValue(_NoPrecacheService()),
  ];
  if (router != null) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ErrorBoundary(child: child),
    ),
  );
}

Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 1));
}

void _reportError() {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: Exception('boom de prueba'),
      stack: StackTrace.current,
    ),
  );
}

void main() {
  testWidgets('renderiza el child cuando no hay error', (tester) async {
    await tester.pumpWidget(_wrap(child: const Text('contenido ok')));
    await _settle(tester);
    expect(find.text('contenido ok'), findsOneWidget);
    expect(find.byType(SageEmotionWidget), findsNothing);
  });

  testWidgets('un error global muestra el fallback', (tester) async {
    await tester.pumpWidget(_wrap(child: const Text('contenido ok')));
    await _settle(tester);

    _reportError();
    await tester.pump();
    await _settle(tester);
    tester.takeException();

    final l = AppLocalizations.of(tester.element(find.byType(ErrorBoundary)))!;
    expect(find.text(l.errorSomethingWrong), findsWidgets);
    expect(find.text(l.errorUnexpected), findsOneWidget);
    expect(find.byType(SageEmotionWidget), findsOneWidget);
    expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    expect(find.text(l.errorRetry), findsOneWidget);
  });

  testWidgets('retry restaura el contenido y evita repetir el mismo error', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(child: const Text('contenido ok')));
    await _settle(tester);
    _reportError();
    await tester.pump();
    await _settle(tester);
    tester.takeException();
    expect(find.text(errorSomethingWrongText(tester)), findsWidgets);

    await tester.tap(find.text(errorRetryText(tester)));
    await tester.pump();
    await _settle(tester);
    expect(find.text('contenido ok'), findsOneWidget);

    _reportError();
    await tester.pump();
    await _settle(tester);
    tester.takeException();
    expect(find.text('contenido ok'), findsNothing);
  });

  testWidgets('muestra una solapa de error distinta si cambia el mensaje', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(child: const Text('x')));
    await _settle(tester);
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: Exception('uno'),
        stack: StackTrace.current,
      ),
    );
    await tester.pump();
    await _settle(tester);
    tester.takeException();
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: Exception('dos'),
        stack: StackTrace.current,
      ),
    );
    await tester.pump();
    await _settle(tester);
    tester.takeException();
    expect(find.text(errorRetryText(tester)), findsOneWidget);
  });

  testWidgets('boton inicio navega a la raiz con GoRouter', (tester) async {
    final router = GoRouter(
      initialLocation: '/app',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: '/app',
          builder: (_, _) => const ErrorBoundary(child: Text('app content')),
        ),
      ],
    );
    await tester.pumpWidget(
      _wrap(child: const Text('ignored'), router: router),
    );
    await _settle(tester);
    _reportError();
    await tester.pump();
    await _settle(tester);
    tester.takeException();

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pump();
    await _settle(tester);
    expect(find.text('HOME'), findsOneWidget);
    expect(find.text('app content'), findsNothing);
  });

  testWidgets('boton inicio sin router no rompe', (tester) async {
    await tester.pumpWidget(_wrap(child: const Text('contenido ok')));
    await _settle(tester);
    _reportError();
    await tester.pump();
    await _settle(tester);
    tester.takeException();
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pump();
    await _settle(tester);
    expect(find.byType(ErrorBoundary), findsOneWidget);
  });
}

String errorSomethingWrongText(WidgetTester tester) {
  return AppLocalizations.of(
    tester.element(find.byType(ErrorBoundary)),
  )!.errorSomethingWrong;
}

String errorRetryText(WidgetTester tester) {
  return AppLocalizations.of(
    tester.element(find.byType(ErrorBoundary)),
  )!.errorRetry;
}
