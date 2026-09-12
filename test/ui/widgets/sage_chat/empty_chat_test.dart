import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/mascot_reaction_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/sage_chat/empty_chat.dart';

class _NoPrecacheService extends SageEmotionService {
  @override
  Future<void> ensurePrecached(SageEmotion emotion) async {}
}

void main() {
  Widget buildApp({ValueChanged<String>? onSuggestionTap}) {
    return ProviderScope(
      overrides: [
        reduceAnimationsProvider.overrideWithValue(true),
        sageEmotionServiceProvider.overrideWithValue(_NoPrecacheService()),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: EmptyChat(onSuggestionTap: onSuggestionTap)),
      ),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('renders empty chat title', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('renders emotion widget', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);
    expect(find.byType(SageEmotionWidget), findsOneWidget);
  });

  testWidgets('renders subtitle text', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);
    final texts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .toList();
    expect(texts.length, greaterThanOrEqualTo(1));
  });

  testWidgets('no suggestion chips sin callback', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(EmptyChat)))!;
    expect(find.text(l.chatSuggestionHelpLesson), findsNothing);
  });

  testWidgets('muestra chips de sugerencia con callback', (tester) async {
    await tester.pumpWidget(buildApp(onSuggestionTap: (_) {}));
    await settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(EmptyChat)))!;
    expect(find.text(l.chatSuggestionHelpLesson), findsOneWidget);
    expect(find.text(l.chatSuggestionExplainConcept), findsOneWidget);
    expect(find.text(l.chatSuggestionQuizMe), findsOneWidget);
  });

  testWidgets('tap en sugerencia invoca onSuggestionTap', (tester) async {
    String? tapped;
    await tester.pumpWidget(buildApp(onSuggestionTap: (v) => tapped = v));
    await settle(tester);
    final l = AppLocalizations.of(tester.element(find.byType(EmptyChat)))!;
    await tester.tap(find.text(l.chatSuggestionHelpLesson));
    await tester.pump();
    expect(tapped, l.chatSuggestionHelpLesson);
    await settle(tester);
  });

  testWidgets('reaccion del mascot reemplaza la emocion', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);

    final ctx = tester.element(find.byType(EmptyChat));
    final container = ProviderScope.containerOf(ctx);
    container
        .read(mascotReactionProvider.notifier)
        .triggerReaction(SageEmotion.celebrating);
    await tester.pump();
    await settle(tester);

    final w = tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget));
    expect(w.emotion, SageEmotion.celebrating);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('sin reaccion usa curios por defecto', (tester) async {
    await tester.pumpWidget(buildApp());
    await settle(tester);
    final w = tester.widget<SageEmotionWidget>(find.byType(SageEmotionWidget));
    expect(w.emotion, SageEmotion.curious);
  });
}
