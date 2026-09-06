import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/ui/widgets/chest_widget.dart';
import 'package:sagen/ui/widgets/chest_painter.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );
  }

  Finder chestPaint() {
    return find.byWidgetPredicate(
      (w) => w is CustomPaint && w.painter is ChestPainter,
    );
  }

  testWidgets('renders a closed chest with treasure semantics', (tester) async {
    await tester.pumpWidget(
      buildApp(const ChestWidget(type: ChestType.bronze)),
    );
    await tester.pump();
    expect(find.byType(ChestWidget), findsOneWidget);
    expect(chestPaint(), findsOneWidget);
    expect(find.bySemanticsLabel('Tesoro bronze'), findsOneWidget);
  });

  testWidgets('opens when animate=false and open=true without waiting', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        const ChestWidget(type: ChestType.gold, open: true, animate: false),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(ChestWidget), findsOneWidget);
  });

  testWidgets('fires onOpenComplete after the open animation completes', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      buildApp(
        ChestWidget(
          type: ChestType.legendary,
          open: true,
          onOpenComplete: () => completed = true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(completed, isFalse);
    await tester.pump(const Duration(milliseconds: 600));
    expect(completed, isTrue);
  });

  testWidgets('respects reduced animations via animate=false open flag', (
    tester,
  ) async {
    var completed = false;
    await tester.pumpWidget(
      buildApp(
        ChestWidget(
          type: ChestType.silver,
          open: true,
          animate: false,
          onOpenComplete: () => completed = true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(completed, isFalse);
  });
}
