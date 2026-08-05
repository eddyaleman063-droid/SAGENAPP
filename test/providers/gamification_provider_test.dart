import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

void main() {
  group('GamificationState', () {
    test('initial state has correct defaults', () {
      const state = GamificationState();
      expect(state.hasUnclaimedChest, false);
      expect(state.secondsUntilMidnight, 0);
      expect(state.dailyMissionsCompleted, 0);
    });

    test('copyWith updates only specified fields', () {
      const state = GamificationState();
      final updated = state.copyWith(hasUnclaimedChest: true);
      expect(updated.hasUnclaimedChest, true);
      expect(updated.dailyMissionsCompleted, 0);
    });
  });

  group('GamificationNotifier', () {
    late ProviderContainer container;
    late MockLearningNotifier mockLearning;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      mockLearning = MockLearningNotifier();
      container = ProviderContainer(overrides: [
        prefsProvider.overrideWithValue(prefs),
        learningProvider.overrideWith(() => mockLearning),
      ]);
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(gamificationProvider);
      expect(state.dailyMissionsCompleted, 0);
    });

    test('claimDailyChest returns xp and updates state', () async {
      final notifier = container.read(gamificationProvider.notifier);
      final xp = await notifier.claimDailyChest();
      expect(xp, greaterThanOrEqualTo(0));
      if (xp > 0) {
        final state = container.read(gamificationProvider);
        expect(state.hasUnclaimedChest, false);
      }
    });

    test('incrementMission increments mission completed count', () {
      final notifier = container.read(gamificationProvider.notifier);
      notifier.incrementMission('mission_1');
      expect(container.read(gamificationProvider).dailyMissionsCompleted, 1);
    });

    test('incrementMission stacks multiple calls', () {
      final notifier = container.read(gamificationProvider.notifier);
      notifier.incrementMission('mission_1');
      notifier.incrementMission('mission_2');
      expect(container.read(gamificationProvider).dailyMissionsCompleted, 2);
    });
  });
}
