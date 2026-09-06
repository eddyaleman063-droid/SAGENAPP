import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/core/result.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/gamification_cloud_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

class _FakeGamificationCloudService extends Mock
    implements GamificationCloudService {}

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
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          learningProvider.overrideWith(() => mockLearning),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(gamificationProvider);
      expect(state.dailyMissionsCompleted, 0);
    });

    test(
      'claimDailyChest keeps chest unclaimed when cloud claim fails',
      () async {
        final notifier = container.read(gamificationProvider.notifier);
        final xp = await notifier.claimDailyChest();
        expect(xp, 0);
        expect(container.read(gamificationProvider).hasUnclaimedChest, true);
      },
    );

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

  group('GamificationNotifier chest reconcile (server-authoritative)', () {
    late MockLearningNotifier mockLearning;

    setUp(() async {
      mockLearning = MockLearningNotifier();
    });

    test('hides a claimed chest and persists the server date', () async {
      final prefs = await SharedPreferences.getInstance();
      final fake = _FakeGamificationCloudService();
      when(() => fake.getDailyChestStatusResult()).thenAnswer(
        (_) async => AppResult.ok(<String, dynamic>{
          'lastClaimedDate': '2026-09-04',
          'available': false,
        }),
      );
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          learningProvider.overrideWith(() => mockLearning),
          gamificationCloudServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(gamificationProvider).hasUnclaimedChest, isTrue);

      await pumpEventQueue();
      final after = container.read(gamificationProvider);
      expect(after.hasUnclaimedChest, isFalse);
      expect(prefs.getString('gamification_last_claim_date'), '2026-09-04');
      expect(prefs.getBool('gamification_unclaimed_chest'), isFalse);
    });

    test('keeps the chest available when the server says available', () async {
      final prefs = await SharedPreferences.getInstance();
      final fake = _FakeGamificationCloudService();
      when(() => fake.getDailyChestStatusResult()).thenAnswer(
        (_) async => AppResult.ok(<String, dynamic>{
          'lastClaimedDate': '',
          'available': true,
        }),
      );
      final container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          learningProvider.overrideWith(() => mockLearning),
          gamificationCloudServiceProvider.overrideWithValue(fake),
        ],
      );
      addTearDown(container.dispose);

      container.read(gamificationProvider);
      await pumpEventQueue();
      expect(container.read(gamificationProvider).hasUnclaimedChest, isTrue);
      expect(prefs.getBool('gamification_unclaimed_chest'), isTrue);
    });
  });
}
