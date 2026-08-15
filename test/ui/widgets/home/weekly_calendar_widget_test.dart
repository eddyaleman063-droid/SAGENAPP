import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/weekly_calendar_widget.dart';

import '../../../helpers/test_helpers.dart';

void main() {
  Widget wrap(Map<String, bool> weekDays) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: WeeklyCalendarWidget(
          currentStreak: 2,
          streakGoal: 7,
          weekDays: weekDays,
          isDark: false,
        ),
      ),
    );
  }

  testWidgetsAnimated('labels completed days as completed for screen readers', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final completedKey =
        '${startOfWeek.year.toString().padLeft(4, '0')}-${startOfWeek.month.toString().padLeft(2, '0')}-${startOfWeek.day.toString().padLeft(2, '0')}';

    await tester.pumpWidget(wrap({completedKey: true}));
    await tester.pump(const Duration(milliseconds: 300));

    final l = AppLocalizations.of(
      tester.element(find.byType(WeeklyCalendarWidget)),
    )!;
    expect(
      find.bySemanticsLabel(l.weekDayCompleted(l.dayShortMon)),
      findsOneWidget,
    );
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
  });
}
