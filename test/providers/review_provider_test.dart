import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ReviewState', () {
    test('initial state has correct defaults', () {
      const state = ReviewState();
      expect(state.questionFailures, isEmpty);
      expect(state.questionTopics, isEmpty);
      expect(state.topicScores, isEmpty);
      expect(state.totalReviews, 0);
    });

    test('copyWith updates only specified fields', () {
      const state = ReviewState();
      final updated = state.copyWith(totalReviews: 3);
      expect(updated.totalReviews, 3);
      expect(updated.questionFailures, isEmpty);
    });
  });

  group('ReviewNotifier', () {
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
      final state = container.read(reviewProvider);
      expect(state.totalReviews, 0);
      expect(state.questionFailures, isEmpty);
    });

    test('initial getters return empty state', () {
      final notifier = container.read(reviewProvider.notifier);
      expect(notifier.hasWeakTopics, false);
      expect(notifier.hasReviewableQuestions, false);
      expect(notifier.weakTopics, isEmpty);
      expect(notifier.failedQuestionIds, isEmpty);
      expect(notifier.totalReviews, 0);
    });

    test('recordMistake adds question failure and topic score', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.failureCountFor('q1'), 1);
      expect(notifier.scoreFor('phishing'), 1);
      expect(notifier.getTopicForQuestion('q1'), 'phishing');
    });

    test('recordMistake increments multiple failures for same question', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.failureCountFor('q1'), 2);
      expect(notifier.scoreFor('phishing'), 2);
    });

    test('recordMistake caps topic score at max', () {
      final notifier = container.read(reviewProvider.notifier);
      for (int i = 0; i < 15; i++) {
        notifier.recordMistake('q$i', 'passwords');
      }
      expect(notifier.scoreFor('passwords'), 10);
    });

    test('hasReviewableQuestions returns true after mistakes', () {
      final notifier = container.read(reviewProvider.notifier);
      expect(notifier.hasReviewableQuestions, false);
      notifier.recordMistake('q1', 'phishing');
      expect(notifier.hasReviewableQuestions, true);
    });

    test('recordCorrect decrements failure count', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.failureCountFor('q1'), 1);
    });

    test('recordCorrect removes question when count reaches 0', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.failureCountFor('q1'), 0);
      expect(notifier.hasReviewableQuestions, false);
    });

    test('recordCorrect decrements topic score', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordMistake('q2', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.scoreFor('phishing'), 1);
    });

    test('recordCorrect removes topic when score reaches 0', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.recordMistake('q1', 'phishing');
      notifier.recordCorrect('q1');
      expect(notifier.scoreFor('phishing'), 0);
    });

    test('markReviewCompleted increments total reviews', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.markReviewCompleted();
      expect(notifier.totalReviews, 1);
    });

    test('markReviewCompleted increments cumulative', () {
      final notifier = container.read(reviewProvider.notifier);
      notifier.markReviewCompleted();
      notifier.markReviewCompleted();
      notifier.markReviewCompleted();
      expect(notifier.totalReviews, 3);
    });

    test('weakTopics identifies topics above threshold', () {
      final notifier = container.read(reviewProvider.notifier);
      for (int i = 0; i < 5; i++) {
        notifier.recordMistake('q$i', 'phishing');
      }
      expect(notifier.hasWeakTopics, true);
      expect(notifier.weakTopics, contains('phishing'));
    });

    test('reload preserves persisted state', () async {
      SharedPreferences.setMockInitialValues({
        'review_q_fails': '{"q1":2,"q2":1}',
        'review_q_topics': '{"q1":"phishing","q2":"passwords"}',
        'review_t_scores': '{"phishing":2,"passwords":1}',
        'review_total': 5,
      });
      final prefs = await SharedPreferences.getInstance();
      final newContainer = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      final notifier = newContainer.read(reviewProvider.notifier);
      expect(notifier.failureCountFor('q1'), 2);
      expect(notifier.failureCountFor('q2'), 1);
      expect(notifier.scoreFor('phishing'), 2);
      expect(notifier.scoreFor('passwords'), 1);
      expect(notifier.totalReviews, 5);
      newContainer.dispose();
    });
  });
}
