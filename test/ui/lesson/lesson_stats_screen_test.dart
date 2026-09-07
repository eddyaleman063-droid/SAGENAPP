import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/screens/lesson/lesson_stats_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockFirstLessonNotifier extends FirstLessonNotifier {
  _MockFirstLessonNotifier(this.initialState);

  final FirstLessonState initialState;

  @override
  FirstLessonState build() => initialState;

  @override
  Future<void> startLesson({
    DiagnosticPath path = DiagnosticPath.beginner,
  }) async {}
}

class _MockLearningNotifier extends LearningNotifier {
  _MockLearningNotifier();

  int? lastXpAmount;
  String? lastXpReason;

  @override
  LearningState build() => const LearningState();

  @override
  Future<void> addXp(
    int amount, {
    String? reason,
    String? lessonId,
    String? achievementId,
  }) async {
    lastXpAmount = amount;
    lastXpReason = reason;
  }
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

FirstLessonState _completedPerfectState({int count = 30}) {
  return FirstLessonState(
    questions: List.generate(count, (i) => _createChallenge(id: i)),
    currentIndex: count,
    correctCount: count,
    wrongCount: 0,
    startTime: DateTime.now(),
    showFeedback: false,
  );
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget buildApp(
    FirstLessonState state, {
    required _MockLearningNotifier learning,
    required VoidCallback onRecibirXp,
  }) {
    return ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        firstLessonProvider.overrideWith(() => _MockFirstLessonNotifier(state)),
        learningProvider.overrideWith(() => learning),
      ],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: LessonStatsScreen(onRecibirXp: onRecibirXp),
      ),
    );
  }

  group('LessonStatsScreen', () {
    testWidgets(
      'shows the real +15 reward, not the fictitious QuizScoreCalculator total',
      (tester) async {
        final learning = _MockLearningNotifier();
        // 30/30 perfect would have yielded 30*15+30 = 480 under the old
        // formula; the server only credits a flat +15 (lesson_reward).
        await tester.pumpWidget(
          buildApp(
            _completedPerfectState(),
            learning: learning,
            onRecibirXp: () {},
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('+15'), findsOneWidget);
        expect(find.text('+480'), findsNothing);
        expect(find.text('100%'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets(
      'rounds accuracy percentages (62.5% -> 63%) instead of truncating',
      (tester) async {
        final learning = _MockLearningNotifier();
        final state = FirstLessonState(
          questions: List.generate(8, (i) => _createChallenge(id: i)),
          currentIndex: 8,
          correctCount: 5,
          wrongCount: 3,
          startTime: DateTime.now(),
          showFeedback: false,
        );
        await tester.pumpWidget(
          buildApp(state, learning: learning, onRecibirXp: () {}),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('63%'), findsOneWidget);
        expect(find.text('62%'), findsNothing);
        await tester.pump(const Duration(seconds: 5));
      },
    );

    testWidgets(
      "tapping 'Recibir XP' awards exactly +15 (reason 'lesson_reward') "
      'and then advances',
      (tester) async {
        final learning = _MockLearningNotifier();
        var advanced = false;
        await tester.pumpWidget(
          buildApp(
            _completedPerfectState(),
            learning: learning,
            onRecibirXp: () => advanced = true,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        final l = AppLocalizations.of(
          tester.element(find.byType(LessonStatsScreen)),
        )!;
        await tester.tap(find.text(l.statsReceiveXp));
        await tester.pump();

        expect(learning.lastXpAmount, LessonStatsScreen.onboardingXpReward);
        expect(learning.lastXpReason, 'lesson_reward');
        expect(advanced, isTrue);
        await tester.pump(const Duration(seconds: 5));
      },
    );
  });
}
