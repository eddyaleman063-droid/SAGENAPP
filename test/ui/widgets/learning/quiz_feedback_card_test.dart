import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/learning/quiz_feedback_card.dart';

Widget _wrap({required bool correct, required String explanation}) {
  return MaterialApp(
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: QuizFeedbackCard(correct: correct, explanation: explanation),
    ),
  );
}

void main() {
  testWidgets('shows success message when correct', (tester) async {
    await tester.pumpWidget(_wrap(correct: true, explanation: 'Bien hecho'));
    expect(find.text('¡Correcto!'), findsOneWidget);
    expect(find.text('Bien hecho'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
  });

  testWidgets('shows error message when incorrect', (tester) async {
    await tester.pumpWidget(_wrap(correct: false, explanation: 'Revisa esto'));
    expect(find.text('Incorrecto'), findsOneWidget);
    expect(find.text('Revisa esto'), findsOneWidget);
    expect(find.byIcon(Icons.info_rounded), findsOneWidget);
  });
}
