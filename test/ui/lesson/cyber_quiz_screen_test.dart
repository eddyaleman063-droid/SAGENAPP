import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/ui/screens/lesson/cyber_quiz_screen.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

List<Challenge> _questions() => [
  const Challenge(
    id: 'q1',
    question: 'Which option is correct?',
    type: LessonType.multipleChoice,
    options: ['A', 'B', 'C'],
    correctIndex: 1,
    explanation: 'B is correct',
  ),
];

void main() {
  testWidgets('announces a live-region verdict when the answer is correct', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(CyberQuizScreen(questions: _questions())),
    );

    await tester.tap(find.text('B'));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    final l = AppLocalizations.of(tester.element(find.byType(CyberQuizScreen)))!;
    expect(find.bySemanticsLabel(l.quizVerdictCorrect), findsOneWidget);
    semantics.dispose();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('announces a live-region verdict when the answer is incorrect', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(CyberQuizScreen(questions: _questions())),
    );

    await tester.tap(find.text('A'));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pump();

    final l = AppLocalizations.of(tester.element(find.byType(CyberQuizScreen)))!;
    expect(find.bySemanticsLabel(l.quizVerdictIncorrect), findsOneWidget);
    semantics.dispose();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('does not expose a verdict label before checking', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      _wrap(CyberQuizScreen(questions: _questions())),
    );

    final l = AppLocalizations.of(tester.element(find.byType(CyberQuizScreen)))!;
    expect(find.bySemanticsLabel(l.quizVerdictCorrect), findsNothing);
    expect(find.bySemanticsLabel(l.quizVerdictIncorrect), findsNothing);
    semantics.dispose();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox());
  });
}
