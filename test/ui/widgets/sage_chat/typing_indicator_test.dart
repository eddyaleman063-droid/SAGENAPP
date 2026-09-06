import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/sage_chat/typing_indicator.dart';

void main() {
  Widget buildApp() {
    return const MaterialApp(
      locale: Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TypingIndicator()),
    );
  }

  const label = 'Sage está escribiendo...';

  testWidgets('is hidden during the debounce window', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.bySemanticsLabel(label), findsNothing);
  });

  testWidgets('appears after the debounce window with a live semantics label', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.bySemanticsLabel(label), findsOneWidget);
  });

  testWidgets('continues animating dots without throwing', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.bySemanticsLabel(label), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
