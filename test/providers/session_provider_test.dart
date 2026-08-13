import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

void main() {
  group('SessionNotifier', () {
    test('initial state is intro with 3 lives and no challenge', () {
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => MockSessionNotifier())],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(sessionProvider.notifier);

      expect(notifier.state.phase, SessionPhase.intro);
      expect(notifier.currentChallenge, isNull);
      expect(notifier.lives, 3);
      expect(notifier.correctCount, 0);
      expect(notifier.wrongCount, 0);
    });

    test('startSession initializes playing state with challenges', () async {
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => MockSessionNotifier())],
      );
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
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => MockSessionNotifier())],
      );
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

    test('gameOver when lives reach 0', () async {
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => MockSessionNotifier())],
      );
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
      final container = ProviderContainer(
        overrides: [sessionProvider.overrideWith(() => MockSessionNotifier())],
      );
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
  });
}
