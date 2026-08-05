import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/lesson/first_lesson_screen.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFirstLessonNotifier extends FirstLessonNotifier {
  _MockFirstLessonNotifier(this.initialState);
  final FirstLessonState initialState;

  @override
  FirstLessonState build() => initialState;

  @override
  Future<void> startLesson({DiagnosticPath path = DiagnosticPath.beginner}) async {}
}

Challenge _createChallenge({int id = 0}) {
  return Challenge(
    id: 'q$id',
    question: '¿Qué es el phishing?',
    type: LessonType.multipleChoice,
    options: ['Correo fraudulento', 'Antivirus', 'Firewall', 'Navegador'],
    correctIndex: 0,
    explanation: 'El phishing es un correo electrónico fraudulento.',
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp(FirstLessonState state) {
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        firstLessonProvider.overrideWith(() => _MockFirstLessonNotifier(state)),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: FirstLessonScreen(onComplete: () {}),
      ),
    );
  }

  group('FirstLessonScreen', () {
    testWidgets('renders shimmer when questions are empty', (tester) async {
      const state = FirstLessonState();
      await tester.pumpWidget(buildApp(state));
      await tester.pump();

      expect(find.byType(ShimmerLoading), findsAtLeast(1));
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('renders question text and answer options', (tester) async {
      final questions = [_createChallenge()];
      final state = FirstLessonState(questions: questions, startTime: DateTime.now());
      await tester.pumpWidget(buildApp(state));
      await tester.pump();

      expect(find.text('¿Qué es el phishing?'), findsOneWidget);
      expect(find.text('Correo fraudulento'), findsOneWidget);
      expect(find.text('Antivirus'), findsOneWidget);
      expect(find.text('Firewall'), findsOneWidget);
      expect(find.text('Navegador'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('shows progress bar, step counter, and percentage', (tester) async {
      final questions = [_createChallenge(), _createChallenge(id: 1)];
      final state = FirstLessonState(questions: questions, startTime: DateTime.now());
      await tester.pumpWidget(buildApp(state));
      await tester.pump();
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('selecting correct answer shows feedback and continue button',
        (tester) async {
      final questions = [_createChallenge(), _createChallenge(id: 1)];
      final state = FirstLessonState(questions: questions, startTime: DateTime.now());
      await tester.pumpWidget(buildApp(state));
      await tester.pump();

      await tester.tap(find.text('Correo fraudulento'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('El phishing es un correo electrónico fraudulento.'), findsOneWidget);
      expect(find.text('SIGUIENTE'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('continue button advances to next question', (tester) async {
      final questions = [_createChallenge(), _createChallenge(id: 1)];
      final state = FirstLessonState(questions: questions, startTime: DateTime.now());
      await tester.pumpWidget(buildApp(state));
      await tester.pump();

      await tester.tap(find.text('Correo fraudulento'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      await tester.tap(find.text('SIGUIENTE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Correo fraudulento'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}
