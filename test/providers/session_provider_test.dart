import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';

class MockSessionNotifier extends SessionNotifier {
  List<Challenge> _fakeChallenges(int count) {
    return List.generate(
      count,
      (i) => Challenge(
        id: 'q_$i',
        question: 'Question $i?',
        type: LessonType.multipleChoice,
        options: ['A', 'B', 'C', 'D'],
        correctIndex: 0,
        explanation: 'Because $i',
      ),
    );
  }

  @override
  Future<void> startSession(
    String stageId,
    String lessonId, {
    int count = 5,
    bool resume = false,
  }) async {
    final challenges = _fakeChallenges(count);
    state = state.copyWith(
      challenges: () => challenges,
      totalQuestions: challenges.length,
      currentIndex: 0,
      lives: 3,
      correctCount: 0,
      wrongCount: 0,
      feedbackSelected: -1,
      feedbackCorrect: false,
      phase: SessionPhase.playing,
      currentChallenge: () => challenges.isNotEmpty ? challenges[0] : null,
    );
  }
}

Future<ProviderContainer> createContainer() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      sessionProvider.overrideWith(() => MockSessionNotifier()),
      prefsProvider.overrideWithValue(prefs),
    ],
  );
}

void main() {
  group('SessionNotifier', () {
    test('initial state is intro with 3 lives and no challenge', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      expect(notifier.state.phase, SessionPhase.intro);
      expect(notifier.currentChallenge, isNull);
      expect(notifier.lives, 3);
      expect(notifier.correctCount, 0);
      expect(notifier.wrongCount, 0);
    });

    test('startSession initializes playing state with challenges', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      expect(notifier.state.phase, SessionPhase.playing);
      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.challenges.length, 5);
      expect(notifier.lives, 3);
      expect(notifier.totalQuestions, 5);
      expect(notifier.currentIndex, 0);
    });

    test('submitAnswer handles correct and incorrect feedback', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      final correctIdx = notifier.currentChallenge!.correctIndex;
      notifier.submitAnswer(correctIdx);
      expect(notifier.state.phase, SessionPhase.feedback);
      expect(notifier.feedbackCorrect, true);
      expect(notifier.correctCount, 1);
      expect(notifier.lives, 3);

      notifier.nextQuestion();
      final wrongIdx =
          (notifier.currentChallenge!.correctIndex + 1) %
          notifier.currentChallenge!.options.length;
      notifier.submitAnswer(wrongIdx);
      expect(notifier.state.phase, SessionPhase.feedback);
      expect(notifier.feedbackCorrect, false);
      expect(notifier.wrongCount, 1);
      expect(notifier.lives, 2);
    });

    test('nextQuestion ignores double-tap in same frame', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      final correctIdx = notifier.currentChallenge!.correctIndex;
      notifier.submitAnswer(correctIdx);
      expect(notifier.state.phase, SessionPhase.feedback);
      expect(notifier.currentIndex, 0);

      // Doble toque: dos llamadas seguidas a nextQuestion en el mismo frame.
      // La primera avanza a playing (índice 1); la segunda debe ser no-op.
      notifier.nextQuestion();
      notifier.nextQuestion();

      expect(notifier.state.phase, SessionPhase.playing);
      expect(notifier.currentIndex, 1);
      expect(notifier.currentChallenge!.id, 'q_1');
    });

    test('gameOver when lives reach 0', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      for (int i = 0; i < 3; i++) {
        final wrongIdx =
            (notifier.currentChallenge!.correctIndex + 1) %
            notifier.currentChallenge!.options.length;
        notifier.submitAnswer(wrongIdx);
        if (i < 2) notifier.nextQuestion();
      }

      expect(notifier.lives, 0);
      notifier.onFeedbackDismissed();
      expect(notifier.state.phase, SessionPhase.gameOver);
    });

    test('completed state when all questions answered', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 3);

      for (int i = 0; i < 3; i++) {
        notifier.submitAnswer(notifier.currentChallenge!.correctIndex);
        notifier.nextQuestion();
      }

      expect(notifier.state.phase, SessionPhase.completed);
      expect(notifier.correctCount, 3);
      expect(notifier.wrongCount, 0);
    });

    test('retry after game over resets lives and counters', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      // Fallar 3 veces seguidas: se agota la vida -> game over.
      for (int i = 0; i < 3; i++) {
        final wrongIdx =
            (notifier.currentChallenge!.correctIndex + 1) %
            notifier.currentChallenge!.options.length;
        notifier.submitAnswer(wrongIdx);
        if (i < 2) notifier.nextQuestion();
      }
      notifier.onFeedbackDismissed();
      expect(notifier.state.phase, SessionPhase.gameOver);
      expect(notifier.lives, 0);

      notifier.retry();

      expect(notifier.state.phase, SessionPhase.playing);
      expect(notifier.lives, 3);
      expect(notifier.correctCount, 0);
      expect(notifier.wrongCount, 0);
      expect(notifier.currentIndex, 0);
      expect(notifier.currentChallenge, isNotNull);
    });
  });

  group('SessionNotifier review feedback', () {
    test('correct answer does not schedule a never-failed question', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      notifier.submitAnswer(0, topicForReview: 'Phishing');

      final review = container.read(reviewProvider);
      expect(review.interval['q_0'], isNull);
      expect(review.repetition['q_0'], isNull);
      expect(review.nextReviewDate, isEmpty);
    });

    test('correct answer after a mistake schedules the review', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      final wrongIdx =
          (notifier.currentChallenge!.correctIndex + 1) %
          notifier.currentChallenge!.options.length;
      notifier.submitAnswer(wrongIdx, topicForReview: 'Phishing');

      final reviewNotif = container.read(reviewProvider.notifier);
      expect(reviewNotif.failureCountFor('q_0'), 1);

      // Fallada y luego acertada: entra al planificador SM-2 (intervalo 1).
      reviewNotif.recordCorrect('q_0');

      final review = container.read(reviewProvider);
      expect(review.interval['q_0'], 1);
      expect(review.repetition['q_0'], 1);
    });

    test('wrong answer feeds recordMistake with the given topic', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      final wrongIdx =
          (notifier.currentChallenge!.correctIndex + 1) %
          notifier.currentChallenge!.options.length;
      notifier.submitAnswer(wrongIdx, topicForReview: 'Phishing');

      final reviewNotif = container.read(reviewProvider.notifier);
      expect(reviewNotif.failureCountFor('q_0'), 1);
      expect(reviewNotif.getTopicForQuestion('q_0'), 'Phishing');
      final review = container.read(reviewProvider);
      expect(review.interval['q_0'], 1);
      expect(review.repetition['q_0'], 0);
    });

    test('wrong answer without topic falls back to "lesson"', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      final wrongIdx =
          (notifier.currentChallenge!.correctIndex + 1) %
          notifier.currentChallenge!.options.length;
      notifier.submitAnswer(wrongIdx);

      final reviewNotif = container.read(reviewProvider.notifier);
      expect(reviewNotif.getTopicForQuestion('q_0'), 'lesson');
    });

    test('correct answer clears an existing failure for the same id', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      container.read(reviewProvider.notifier).recordMistake('q_0', 'Phishing');
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('stage_1', 'non_existent', count: 5);

      notifier.submitAnswer(0, topicForReview: 'Phishing');

      final review = container.read(reviewProvider);
      expect(review.questionFailures['q_0'], isNull);
    });
  });

  group('SessionNotifier resume persistence', () {
    test('hasResumableProgress is false when nothing is saved', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);
      final can = await notifier.hasResumableProgress(
        'ac_st1',
        'ac_s1_ses1_l1',
      );
      expect(can, false);
    });

    test(
      'hasResumableProgress is true for a valid recent saved lesson',
      () async {
        SharedPreferences.setMockInitialValues({
          'lesson_progress_ac_st1/ac_s1_ses1_l1': <String>[
            'ac_st1',
            '3',
            '2',
            'q0,q1,q2,q3,q4',
            DateTime.now().toIso8601String(),
            'q2',
          ],
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(prefs)],
        );
        addTearDown(() => container.dispose());

        final notifier = container.read(sessionProvider.notifier);
        final can = await notifier.hasResumableProgress(
          'ac_st1',
          'ac_s1_ses1_l1',
        );
        expect(can, true);
      },
    );

    test(
      'hasResumableProgress is false when the saved lesson is too old',
      () async {
        SharedPreferences.setMockInitialValues({
          'lesson_progress_ac_st1/ac_s1_ses1_l1': <String>[
            'ac_st1',
            '3',
            '2',
            'q0,q1,q2,q3,q4',
            DateTime.now()
                .subtract(const Duration(minutes: 45))
                .toIso8601String(),
            'q2',
          ],
        });
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(prefs)],
        );
        addTearDown(() => container.dispose());

        final notifier = container.read(sessionProvider.notifier);
        final can = await notifier.hasResumableProgress(
          'ac_st1',
          'ac_s1_ses1_l1',
        );
        expect(can, false);
      },
    );

    test('discardResume removes the saved progress key', () async {
      SharedPreferences.setMockInitialValues({
        'lesson_progress_ac_st1/ac_s1_ses1_l1': <String>[
          'ac_st1',
          '3',
          '2',
          'q0,q1,q2,q3,q4',
          DateTime.now().toIso8601String(),
          'q2',
        ],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());

      final notifier = container.read(sessionProvider.notifier);
      await notifier.discardResume('ac_st1', 'ac_s1_ses1_l1');
      final can = await notifier.hasResumableProgress(
        'ac_st1',
        'ac_s1_ses1_l1',
      );
      expect(can, false);
    });

    test('clearAllProgress removes every saved lesson key', () async {
      SharedPreferences.setMockInitialValues({
        'lesson_progress_ac_st1/ac_s1_ses1_l1': <String>[
          'ac_st1',
          '3',
          '2',
          'q0,q1,q2,q3,q4',
          DateTime.now().toIso8601String(),
          'q2',
        ],
        'lesson_progress_ac_st2/ac_s2_ses1_l1': <String>[
          'ac_st2',
          '1',
          '1',
          'a0,a1,a2,a3,a4',
          DateTime.now().toIso8601String(),
          'a1',
        ],
      });
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());

      final notifier = container.read(sessionProvider.notifier);
      await notifier.clearAllProgress();

      final leftover = prefs.getKeys().where(
        (k) => k.startsWith('lesson_progress_'),
      );
      expect(leftover, isEmpty);
      expect(notifier.state.phase, SessionPhase.intro);
    });
  });
}
