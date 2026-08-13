import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/learning/quiz_option_button.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('es'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders the option text with letter prefix', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const QuizOptionButton(
          index: 0,
          text: 'Madrid',
          selected: false,
          correct: false,
          revealed: false,
        ),
      ),
    );
    expect(find.text('Madrid'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('shows check mark when revealed and correct', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const QuizOptionButton(
          index: 1,
          text: 'París',
          selected: true,
          correct: true,
          revealed: true,
        ),
      ),
    );
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('shows cross when revealed, selected and wrong', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const QuizOptionButton(
          index: 2,
          text: 'Londres',
          selected: true,
          correct: false,
          revealed: true,
        ),
      ),
    );
    expect(find.text('✗'), findsOneWidget);
  });

  testWidgets('shows dash when disabled', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const QuizOptionButton(
          index: 3,
          text: 'Roma',
          selected: false,
          correct: false,
          revealed: false,
          disabled: true,
        ),
      ),
    );
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('fires onTap and ignores taps when revealed', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        QuizOptionButton(
          index: 0,
          text: 'Madrid',
          selected: false,
          correct: false,
          revealed: false,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Madrid'));
    await tester.pump();
    expect(taps, 1);

    await tester.pumpWidget(
      _wrap(
        QuizOptionButton(
          index: 0,
          text: 'Madrid',
          selected: false,
          correct: true,
          revealed: true,
          onTap: () => taps++,
        ),
      ),
    );
    await tester.tap(find.text('Madrid'), warnIfMissed: false);
    await tester.pump();
    expect(taps, 1);
  });
}
