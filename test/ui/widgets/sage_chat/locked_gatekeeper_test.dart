import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/sage_chat/locked_gatekeeper.dart';

void main() {
  Widget buildApp({
    int completed = 3,
    int required = 10,
    double progress = 0.3,
  }) {
    return ProviderScope(
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LockedGatekeeper(
            lessonsCompleted: completed,
            lessonsRequired: required,
            progress: progress,
            dark: false,
          ),
        ),
      ),
    );
  }

  testWidgets('shows locked title and progress counters', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Tutor IA Bloqueado'), findsOneWidget);
    expect(find.text('3 / 10 lecciones'), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('shows sample chat preview with placeholder messages', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pump(const Duration(milliseconds: 100));
    final l = AppLocalizations.of(
      tester.element(find.byType(LockedGatekeeper)),
    )!;
    expect(find.text(l.tutorSampleTitle), findsOneWidget);
    expect(find.text(l.tutorSampleQuestion1), findsOneWidget);
    expect(find.text(l.tutorSampleAnswer1), findsOneWidget);
    expect(find.text(l.tutorSampleQuestion2), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('shows motivational message (need <= 3)', (tester) async {
    await tester.pumpWidget(
      buildApp(completed: 8, required: 10, progress: 0.8),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final l = AppLocalizations.of(
      tester.element(find.byType(LockedGatekeeper)),
    )!;
    expect(find.text(l.tutorMotivationAlmost(2)), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('shows general motivational message (need > 5)', (tester) async {
    await tester.pumpWidget(
      buildApp(completed: 1, required: 10, progress: 0.1),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final l = AppLocalizations.of(
      tester.element(find.byType(LockedGatekeeper)),
    )!;
    expect(find.text(l.tutorMotivationGeneral), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
  });
}
