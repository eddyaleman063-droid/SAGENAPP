import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/sage_chat/empty_chat.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

void main() {
  Widget buildApp() {
    return const ProviderScope(
      child: MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: EmptyChat()),
      ),
    );
  }

  testWidgets('renders empty chat title', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(Text), findsWidgets);
  });

  testWidgets('renders emotion widget', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 6));
    expect(find.byType(SageEmotionWidget), findsOneWidget);
  });

  testWidgets('renders subtitle text', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(seconds: 6));
    final texts = find
        .byType(Text)
        .evaluate()
        .map((e) => (e.widget as Text).data ?? '')
        .toList();
    expect(texts.length, greaterThanOrEqualTo(1));
  });
}
