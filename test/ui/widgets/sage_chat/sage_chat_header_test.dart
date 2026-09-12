import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/sage_chat/header.dart';

class _NoPrecacheService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

Widget _wrap({
  required bool isBusy,
  required bool hasMessages,
  VoidCallback? onClear,
}) {
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (_, _) => Scaffold(
          body: SageChatHeader(
            isBusy: isBusy,
            hasMessages: hasMessages,
            onClear: onClear,
          ),
        ),
      ),
    ],
  );
  return ProviderScope(
    overrides: [
      reduceAnimationsProvider.overrideWithValue(true),
      sageEmotionServiceProvider.overrideWithValue(_NoPrecacheService()),
    ],
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

void main() {
  testWidgets('renderiza titulo y subtitulo del tutor', (tester) async {
    await tester.pumpWidget(_wrap(isBusy: false, hasMessages: false));
    await _settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(SageChatHeader)))!;
    expect(find.text(l.chatSageTutorLabel), findsOneWidget);
    expect(find.text(l.chatGuideSubtitle), findsOneWidget);
  });

  testWidgets('mascota piensa cuando esta ocupada', (tester) async {
    await tester.pumpWidget(_wrap(isBusy: true, hasMessages: true));
    await _settle(tester);
    final w = tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget));
    expect(w.emotion, SageEmotion.thinking);
  });

  testWidgets('mascota calmada cuando esta libre', (tester) async {
    await tester.pumpWidget(_wrap(isBusy: false, hasMessages: false));
    await _settle(tester);
    final w = tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget));
    expect(w.emotion, SageEmotion.calm);
  });

  testWidgets('sin mensajes el boton de borrar no abre dialog', (tester) async {
    await tester.pumpWidget(_wrap(isBusy: false, hasMessages: false));
    await _settle(tester);
    await tester.tap(
      find.byIcon(Icons.delete_outline_rounded),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('abre dialog y confirmar borra e invoca onClear', (tester) async {
    var cleared = false;
    await tester.pumpWidget(
      _wrap(isBusy: false, hasMessages: true, onClear: () => cleared = true),
    );
    await _settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(SageChatHeader)))!;
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(l.chatClearTitle), findsOneWidget);

    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.text(l.chatClearAction),
    );
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);
    expect(cleared, isTrue);
  });

  testWidgets('cancelar cierra el dialog sin borrar', (tester) async {
    var cleared = false;
    await tester.pumpWidget(
      _wrap(isBusy: false, hasMessages: true, onClear: () => cleared = true),
    );
    await _settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(SageChatHeader)))!;
    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    await tester.tap(find.text(l.chatCancel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(AlertDialog), findsNothing);
    expect(cleared, isFalse);
  });
}
