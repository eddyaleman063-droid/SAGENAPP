import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FirstLessonState', () {
    test('initial state has correct defaults', () {
      const state = FirstLessonState();
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
      expect(state.correctCount, 0);
      expect(state.wrongCount, 0);
      expect(state.showFeedback, false);
    });

    test('totalQuestions returns length', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q1',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
          Challenge(
            id: '2',
            question: 'Q2',
            type: LessonType.trueFalse,
            options: ['T', 'F'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
      );
      expect(state.totalQuestions, 2);
    });

    test('isComplete is true when past last question', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
        currentIndex: 1,
      );
      expect(state.isComplete, true);
    });

    test('isPerfect when all correct', () {
      const state = FirstLessonState(
        questions: [
          Challenge(
            id: '1',
            question: 'Q1',
            type: LessonType.multipleChoice,
            options: ['A', 'B'],
            correctIndex: 0,
            explanation: 'E',
          ),
          Challenge(
            id: '2',
            question: 'Q2',
            type: LessonType.trueFalse,
            options: ['T', 'F'],
            correctIndex: 0,
            explanation: 'E',
          ),
        ],
        correctCount: 2,
      );
      expect(state.isPerfect, true);
    });
  });

  group('FirstLessonNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(firstLessonProvider);
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
    });

    test('reset clears state', () {
      final notifier = container.read(firstLessonProvider.notifier);
      notifier.startLesson();
      notifier.reset();
      final state = container.read(firstLessonProvider);
      expect(state.questions, isEmpty);
      expect(state.currentIndex, 0);
    });

    test('submitAnswer is no-op when no current challenge', () {
      final notifier = container.read(firstLessonProvider.notifier);
      notifier.submitAnswer(0);
      expect(container.read(firstLessonProvider).showFeedback, false);
    });

    test('nextQuestion moves to next index', () {
      final notifier = container.read(firstLessonProvider.notifier);
      notifier.startLesson();
      final firstIndex = container.read(firstLessonProvider).currentIndex;
      notifier.submitAnswer(0);
      notifier.nextQuestion();
      expect(container.read(firstLessonProvider).currentIndex, firstIndex + 1);
    });
  });
}
