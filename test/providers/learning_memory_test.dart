import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/models/quick_challenge.dart';

void main() {
  late SharedPreferences prefs;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });
  group('LearningMemoryNotifier', () {
    test('starts with empty weak topics', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      expect(notifier.weakTopics, isEmpty);
      expect(notifier.completedChallenges, isEmpty);
    });
    test('records lesson pass', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordLessonResult(passed: true, topic: 'phishing');
      expect(notifier.totalLessonsPassed, 1);
      expect(notifier.totalLessonsFailed, 0);
    });
    test('records lesson fail', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordLessonResult(passed: false, topic: 'passwords');
      expect(notifier.totalLessonsPassed, 0);
      expect(notifier.totalLessonsFailed, 1);
    });
    test('identifies weak topics after repeated failures', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      for (var i = 0; i < 3; i++) {
        notifier.recordLessonResult(passed: false, topic: 'phishing');
      }
      expect(notifier.weakTopics.length, 1);
      expect(notifier.weakTopics.first.isWeak, isTrue);
      expect(notifier.weakTopics.first.failRate, 1.0);
    });
    test('does not flag topics with few attempts as weak', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordLessonResult(passed: false, topic: 'phishing');
      expect(notifier.weakTopics.length, 1);
      expect(notifier.weakTopics.first.isWeak, isFalse);
    });
    test('recommends challenge types for weak phishing topic', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      for (var i = 0; i < 3; i++) {
        notifier.recordLessonResult(passed: false, topic: 'phishing');
      }
      final types = notifier.recommendedChallengeTypes;
      expect(types, contains(QuickChallengeType.detectPhishing));
    });
    test('recommends challenge types for weak passwords topic', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      for (var i = 0; i < 3; i++) {
        notifier.recordLessonResult(passed: false, topic: 'passwords');
      }
      final types = notifier.recommendedChallengeTypes;
      expect(types, contains(QuickChallengeType.safePassword));
    });
    test('records challenge attempt', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordChallengeAttempt(
        challengeId: 'qc1',
        passed: true,
        type: QuickChallengeType.detectPhishing,
      );
      expect(notifier.completedChallenges, contains('qc1'));
    });
    test('tracks sessions this week', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordLessonResult(passed: true, topic: 'general');
      expect(notifier.sessionsThisWeek, greaterThan(0));
    });
    test('calculates overall pass rate', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      notifier.recordLessonResult(passed: true, topic: 'a');
      notifier.recordLessonResult(passed: false, topic: 'b');
      expect(notifier.overallPassRate, 0.5);
    });
  });
}
