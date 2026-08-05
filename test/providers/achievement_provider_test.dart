import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/mock_learning_provider.dart';

void main() {
  group('AchievementState', () {
    test('initial state has default values', () {
      const state = AchievementState();
      expect(state.isInitialized, false);
      expect(state.achievements, isEmpty);
      expect(state.unlockedCount, 0);
      expect(state.totalCount, 0);
      expect(state.progress, 0.0);
    });

    test('copyWith updates specified fields', () {
      const state = AchievementState();
      final updated = state.copyWith(
        isInitialized: true,
        unlockedCount: 1,
        totalCount: 12,
        progress: 1 / 12,
      );
      expect(updated.isInitialized, true);
      expect(updated.unlockedCount, 1);
      expect(updated.totalCount, 12);
      expect(updated.progress, closeTo(0.08333, 0.001));
    });
  });

  group('AchievementNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [
        prefsProvider.overrideWithValue(prefs),
        learningProvider.overrideWith(() => MockLearningNotifier()),
      ]);
    });

    tearDown(() => container.dispose());

    test('initial state has defaults before init', () {
      final state = container.read(achievementProvider);
      expect(state.isInitialized, false);
      expect(state.totalCount, 0);
    });

    test('unlockAchievement works even without async init completing', () async {
      final notifier = container.read(achievementProvider.notifier);
      final result = notifier.unlockAchievement('first_lesson');
      expect(result, isTrue);
    });

    test('totalCount is populated from templates', () async {
      var state = container.read(achievementProvider);
      expect(state.totalCount, 0);
      await Future(() {});
      state = container.read(achievementProvider);
      expect(state.totalCount, greaterThan(0));
      expect(state.unlockedCount, 0);
    });

    test('unlockAchievement updates state', () async {
      final notifier = container.read(achievementProvider.notifier);
      final result = notifier.unlockAchievement('first_lesson');
      expect(result, isTrue);
      final state = container.read(achievementProvider);
      expect(state.unlockedCount, 1);
      expect(state.achievements.any((a) => a.id == 'first_lesson' && a.unlocked), isTrue);
    });

    test('unlockAchievement returns false for unknown id', () async {
      final notifier = container.read(achievementProvider.notifier);
      final result = notifier.unlockAchievement('nonexistent');
      expect(result, isFalse);
    });

    test('unlockAchievement returns false for already unlocked', () async {
      final notifier = container.read(achievementProvider.notifier);
      notifier.unlockAchievement('first_lesson');
      final result = notifier.unlockAchievement('first_lesson');
      expect(result, isFalse);
    });

    test('progress reflects unlocked count', () async {
      final notifier = container.read(achievementProvider.notifier);
      notifier.unlockAchievement('first_lesson');
      notifier.unlockAchievement('five_lessons');
      notifier.unlockAchievement('ten_lessons');
      final state = container.read(achievementProvider);
      expect(state.unlockedCount, 3);
      expect(state.progress, greaterThan(0));
    });
  });
}
