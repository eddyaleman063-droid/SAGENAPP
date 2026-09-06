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
    test('reserved topics count totals but do not become weak topics', () {
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(() => container.dispose());
      final notifier = container.read(learningMemoryProvider.notifier);

      for (var i = 0; i < 3; i++) {
        notifier.recordLessonResult(passed: false, topic: 'review');
      }
      expect(notifier.totalLessonsFailed, 3);
      expect(notifier.weakTopics, isEmpty);

      notifier.recordLessonResult(passed: true, topic: 'lesson');
      expect(notifier.totalLessonsPassed, 1);
      expect(notifier.weakTopics, isEmpty);
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
    test('calendar week: same ISO week is the same calendar week', () {
      // Semana ISO del lunes 2026-01-05 al domingo 2026-01-11.
      expect(
        LearningMemoryNotifier.isSameCalendarWeek(
          DateTime(2026, 1, 5), // lunes
          DateTime(2026, 1, 11), // domingo
        ),
        isTrue,
      );
    });
    test('calendar week: crossing a week boundary resets (not sliding 7d)', () {
      // Sábado 2026-01-03 (semana ISO 2025-W53) vs lunes 2026-01-05
      // (semana ISO 2026-W01): semanas distintas pese a distar <7 días.
      expect(
        LearningMemoryNotifier.isSameCalendarWeek(
          DateTime(2026, 1, 3),
          DateTime(2026, 1, 5),
        ),
        isFalse,
      );
    });
    test('calendar week: far apart dates are different weeks', () {
      expect(
        LearningMemoryNotifier.isSameCalendarWeek(
          DateTime(2026, 1, 1),
          DateTime(2026, 1, 22),
        ),
        isFalse,
      );
    });
  });
}
