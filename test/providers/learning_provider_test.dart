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
  Future<void> addXp(int amount, {String? reason, String? lessonId}) async {
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
  });
}
