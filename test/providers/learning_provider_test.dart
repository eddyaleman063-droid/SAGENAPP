import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCloudSyncService extends Mock implements CloudSyncService {}

class MockAuthService extends Mock implements AuthService {}

class TestLearningNotifier extends LearningNotifier {
  @override
  LearningState build() {
    return const LearningState(isLoading: false);
  }

  @override
  Future<void> addXp(
    int amount, {
    String? reason,
    String? lessonId,
    String? achievementId,
  }) async {
    final newXp = state.xp + amount;
    final newTotalXp = state.totalXpEarned + amount;
    final newLevel = (newTotalXp / 100).floor() + 1;
    state = state.copyWith(
      xp: newLevel > state.currentLevel ? 0 : newXp,
      totalXpEarned: newTotalXp,
      currentLevel: newLevel > state.currentLevel
          ? newLevel
          : state.currentLevel,
    );
  }
}

void main() {
  group('LearningNotifier - XP', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cloudSyncServiceProvider.overrideWith(
            (ref) => MockCloudSyncService(),
          ),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          learningProvider.overrideWith(() => TestLearningNotifier()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('initial xp is 0', () {
      final notifier = container.read(learningProvider.notifier);
      expect(notifier.state.xp, 0);
    });

    test('addXp increases balance and totalXpEarned', () async {
      final notifier = container.read(learningProvider.notifier);
      await notifier.addXp(10);
      expect(notifier.state.xp, 10);
      expect(notifier.state.totalXpEarned, 10);
    });

    test('addXp accumulates correctly across multiple calls', () async {
      final notifier = container.read(learningProvider.notifier);
      await notifier.addXp(5);
      await notifier.addXp(15);
      await notifier.addXp(3);
      expect(notifier.state.xp, 23);
      expect(notifier.state.totalXpEarned, 23);
    });

    test('addXp with 0 is a no-op', () async {
      final notifier = container.read(learningProvider.notifier);
      await notifier.addXp(0);
      expect(notifier.state.xp, 0);
      expect(notifier.state.totalXpEarned, 0);
    });

    test('reconcile applies server-authoritative capped XP', () {
      final notifier = container.read(learningProvider.notifier);
      // Estado local optimista que quedó inflado por el cap diario del server:
      // se acreditaron 15 localmente pero el servidor solo concedió 5.
      notifier.reconcileForTest({
        'type': 'completeLesson',
        'totalXp': 105,
        'level': 2,
        'lessonsCompleted': 7,
        'lessonId': 'ac_s1_ses1_l1',
      });
      expect(notifier.state.totalXpEarned, 105);
      expect(notifier.state.currentLevel, 2);
      expect(notifier.state.xp, 5);
      expect(notifier.state.lessonsCompleted, 7);
    });
  });

  group('ShopNotifier - XP boost (NUEVO-boost)', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cloudSyncServiceProvider.overrideWith(
            (ref) => MockCloudSyncService(),
          ),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          learningProvider.overrideWith(() => TestLearningNotifier()),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('honors an armed boost with 2x XP in xpForLessonId', () {
      final notifier = container.read(learningProvider.notifier);
      final shop = container.read(shopProvider.notifier);
      expect(notifier.xpForLessonId('ac_s1_ses1_l1'), 15);
      shop.activateXpBoost();
      expect(container.read(shopProvider).xpBoostActive, isTrue);
      expect(notifier.xpForLessonId('ac_s1_ses1_l1'), 30);
      expect(notifier.xpForLessonId('ac_s1_ses1_l6'), 40);
    });

    test('syncXpBoostFromServer re-arms when the server still has boosts', () {
      final shop = container.read(shopProvider.notifier);
      shop.syncXpBoostFromServer(2);
      expect(container.read(shopProvider).xpBoostActive, isTrue);
      shop.syncXpBoostFromServer(1);
      expect(container.read(shopProvider).xpBoostActive, isTrue);
    });

    test('syncXpBoostFromServer disarms when the server counter hits 0', () {
      final shop = container.read(shopProvider.notifier);
      shop.activateXpBoost();
      shop.syncXpBoostFromServer(0);
      expect(container.read(shopProvider).xpBoostActive, isFalse);
    });
  });
}
