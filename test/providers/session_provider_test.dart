import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/local_question_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  group('SessionState metrics', () {
    test('progress and segment metrics on a playing session', () {
      const state = SessionState(
        challenges: [],
        currentIndex: 2,
        totalQuestions: 5,
        phase: SessionPhase.playing,
      );
      expect(state.progress, 2 / 5);
      expect(state.segmentCount, 5);
      expect(state.completedSegments, 2);
      expect(state.accuracy, 0);
      expect(state.isPerfect, false);
      expect(state.earnedXp, 0);
    });

    test('completedSegments counts feedback question as answered', () {
      const state = SessionState(
        currentIndex: 2,
        totalQuestions: 5,
        phase: SessionPhase.feedback,
      );
      expect(state.completedSegments, 3);
      expect(state.progress, 3 / 5);
    });

    test('completedSegments clamps and handles empty sessions', () {
      const empty = SessionState();
      expect(empty.completedSegments, 0);
      expect(empty.progress, 0);
      const finished = SessionState(
        currentIndex: 5,
        totalQuestions: 5,
        phase: SessionPhase.completed,
      );
      expect(finished.completedSegments, 5);
    });

    test('accuracy reflects correct over answered', () {
      const state = SessionState(correctCount: 3, wrongCount: 1);
      expect(state.accuracy, 3 / 4);
    });

    test('isPerfect requires all correct and no wrong', () {
      const perfect = SessionState(
        correctCount: 3,
        wrongCount: 0,
        totalQuestions: 3,
      );
      expect(perfect.isPerfect, true);
      const imperfect = SessionState(
        correctCount: 3,
        wrongCount: 1,
        totalQuestions: 4,
      );
      expect(imperfect.isPerfect, false);
    });

    test('earnedXp scales and applies the perfect bonus', () {
      const perfect = SessionState(
        correctCount: 3,
        wrongCount: 0,
        totalQuestions: 3,
      );
      expect(perfect.earnedXp, 3 * 15 + 30);
      const imperfect = SessionState(
        correctCount: 2,
        wrongCount: 1,
        totalQuestions: 3,
      );
      expect(imperfect.earnedXp, 2 * 15);
    });

    test('copyWith updates fields and clears via closures', () {
      const base = SessionState();
      final updated = base.copyWith(
        currentChallenge: () => null,
        challenges: () => const [],
        currentIndex: 1,
        lives: 5,
        correctCount: 2,
        wrongCount: 1,
        totalQuestions: 3,
        feedbackSelected: 0,
        feedbackCorrect: true,
        phase: SessionPhase.feedback,
      );
      expect(updated.phase, SessionPhase.feedback);
      expect(updated.currentIndex, 1);
      expect(updated.lives, 5);
      expect(updated.feedbackSelected, 0);
      expect(updated.feedbackCorrect, true);
      final untouched = base.copyWith();
      expect(untouched.phase, SessionPhase.intro);
      expect(untouched.lives, 3);
    });
  });

  group('SessionNotifier state getters', () {
    test('getters mirror SessionState during an active session', () async {
      final container = await createContainer();
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      expect(notifier.progress, 0);
      expect(notifier.segmentCount, 0);
      expect(notifier.completedSegments, 0);
      expect(notifier.accuracy, 0);
      expect(notifier.isPerfect, false);
      expect(notifier.earnedXp, 0);

      await notifier.startSession('stage_1', 'non_existent', count: 3);
      expect(notifier.segmentCount, 3);
      expect(notifier.totalQuestions, 3);
      expect(notifier.completedSegments, 0);

      for (int i = 0; i < 3; i++) {
        notifier.submitAnswer(notifier.currentChallenge!.correctIndex);
        notifier.nextQuestion();
      }

      expect(notifier.state.phase, SessionPhase.completed);
      expect(notifier.completedSegments, 3);
      expect(notifier.progress, 1);
      expect(notifier.accuracy, 1);
      expect(notifier.isPerfect, true);
      expect(notifier.earnedXp, 3 * 15 + 30);
    });
  });

  group('SessionNotifier real startSession against the seeded DB', () {
    late Directory tempDir;

    setUp(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      tempDir = Directory.systemTemp.createTempSync('sagen_session_test');
      LocalQuestionDB.overrideDatabasesPath = tempDir.path;
    });

    tearDown(() async {
      await LocalQuestionDB.instance.close();
      LocalQuestionDB.overrideDatabasesPath = null;
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {}
    });

    List<String> progressPayload({
      required String stageId,
      required List<String> ids,
      int answered = 3,
      int correct = 2,
      DateTime? savedAt,
      String? firstUnansweredId,
    }) {
      return [
        stageId,
        answered.toString(),
        correct.toString(),
        ids.join(','),
        (savedAt ?? DateTime.now()).toIso8601String(),
        firstUnansweredId ?? '',
      ];
    }

    test('startSession fills 15 real seeded challenges', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', count: 15);

      expect(notifier.state.phase, SessionPhase.playing);
      expect(notifier.totalQuestions, 15);
      expect(notifier.challenges.length, 15);
      expect(notifier.currentChallenge, isNotNull);
      expect(notifier.lives, 3);
    });

    test('startSession handles an unknown lesson gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('unknown_stage', 'unknown_lesson', count: 15);

      expect(notifier.state.phase, SessionPhase.playing);
      expect(notifier.totalQuestions, 0);
      expect(notifier.challenges, isEmpty);
      expect(notifier.currentChallenge, isNull);
    });

    test('startSession resume restores cursor and real counters', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', count: 15);
      final ids = notifier.challenges.map((c) => c.id).toList();
      final firstUnansweredId = ids[2];

      await prefs.setStringList(
        'lesson_progress_ac_st1/ac_s1_ses1_l1',
        progressPayload(
          stageId: 'ac_st1',
          ids: ids,
          answered: 3,
          correct: 2,
          firstUnansweredId: firstUnansweredId,
        ),
      );

      await notifier.startSession(
        'ac_st1',
        'ac_s1_ses1_l1',
        count: 15,
        resume: true,
      );

      expect(notifier.state.phase, SessionPhase.playing);
      final newIds = notifier.challenges.map((c) => c.id).toList();
      expect(notifier.currentIndex, newIds.indexOf(firstUnansweredId));
      expect(notifier.currentChallenge!.id, firstUnansweredId);
      expect(notifier.correctCount, 2);
      expect(notifier.wrongCount, 1);
      expect(notifier.lives, 3);
    });

    test(
      'startSession resume clears stale progress and starts fresh',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(prefs)],
        );
        addTearDown(() => container.dispose());
        final notifier = container.read(sessionProvider.notifier);

        await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', count: 15);
        final ids = notifier.challenges.map((c) => c.id).toList();

        await prefs.setStringList(
          'lesson_progress_ac_st1/ac_s1_ses1_l1',
          progressPayload(
            stageId: 'ac_st1',
            ids: ids,
            savedAt: DateTime.now().subtract(const Duration(minutes: 45)),
            firstUnansweredId: ids[2],
          ),
        );

        await notifier.startSession(
          'ac_st1',
          'ac_s1_ses1_l1',
          count: 15,
          resume: true,
        );

        expect(notifier.currentIndex, 0);
        expect(notifier.correctCount, 0);
        expect(notifier.wrongCount, 0);
        expect(
          prefs.getStringList('lesson_progress_ac_st1/ac_s1_ses1_l1'),
          isNull,
        );
      },
    );

    test('startSession resume clears invalid progress payloads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', count: 15);
      final ids = notifier.challenges.map((c) => c.id).toList();

      // 1) IDs mismatch (subset) -> cleared and starts fresh.
      await prefs.setStringList(
        'lesson_progress_ac_st1/ac_s1_ses1_l1',
        progressPayload(
          stageId: 'ac_st1',
          ids: ids.sublist(0, 3),
          firstUnansweredId: ids[1],
        ),
      );
      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', resume: true);
      expect(notifier.currentIndex, 0);
      expect(
        prefs.getStringList('lesson_progress_ac_st1/ac_s1_ses1_l1'),
        isNull,
      );

      // 2) Empty first-unanswered id -> cleared and starts fresh.
      await prefs.setStringList(
        'lesson_progress_ac_st1/ac_s1_ses1_l1',
        progressPayload(stageId: 'ac_st1', ids: ids),
      );
      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', resume: true);
      expect(notifier.currentIndex, 0);
      expect(
        prefs.getStringList('lesson_progress_ac_st1/ac_s1_ses1_l1'),
        isNull,
      );

      // 3) Unknown first-unanswered id -> cleared and starts fresh.
      await prefs.setStringList(
        'lesson_progress_ac_st1/ac_s1_ses1_l1',
        progressPayload(
          stageId: 'ac_st1',
          ids: ids,
          firstUnansweredId: 'ac_s1_ses1_l1_q999',
        ),
      );
      await notifier.startSession('ac_st1', 'ac_s1_ses1_l1', resume: true);
      expect(notifier.currentIndex, 0);
      expect(
        prefs.getStringList('lesson_progress_ac_st1/ac_s1_ses1_l1'),
        isNull,
      );
    });
  });
}
