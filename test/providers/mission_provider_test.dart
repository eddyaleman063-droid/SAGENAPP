import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/models/daily_mission.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/auth_service.dart';
import 'package:sagen/services/cloud_sync_service.dart';

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
      currentLevel: newLevel > state.currentLevel ? newLevel : state.currentLevel,
    );
  }
}

void main() {
  group('MissionProvider', () {
    late ProviderContainer container;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          cloudSyncServiceProvider.overrideWith((ref) => MockCloudSyncService()),
          authServiceProvider.overrideWith((ref) => MockAuthService()),
          learningProvider.overrideWith(() => TestLearningNotifier()),
        ],
      );
    });
    tearDown(() {
      container.dispose();
    });
    test('generates daily missions', () {
      final state = container.read(missionProvider);
      expect(state.missions.length, 3);
      expect(state.missions.where((m) => m.completed).length, 0);
      expect(state.totalMissionsCompleted, 0);
    });
    test('all missions have valid fields', () {
      final state = container.read(missionProvider);
      for (final m in state.missions) {
        expect(m.id, isNotEmpty);
        expect(m.title, isNotEmpty);
        expect(m.description, isNotEmpty);
        expect(m.target, greaterThan(0));
        expect(m.xpReward, greaterThan(0));
      }
    });
    test('advanceMission increments progress', () async {
      final notifier = container.read(missionProvider.notifier);
      final state = container.read(missionProvider);
      final mission = state.missions.first;
      notifier.advanceMission(mission.type, amount: 1);
      final updated = container.read(missionProvider);
      final updatedMission = updated.missions.firstWhere((m) => m.id == mission.id);
      expect(updatedMission.progress, greaterThan(0));
      await Future.delayed(const Duration(milliseconds: 100));
    });
    test('advanceMission completes mission when target reached', () async {
      final notifier = container.read(missionProvider.notifier);
      final state = container.read(missionProvider);
      final mission = state.missions.first;
      notifier.advanceMission(mission.type, amount: mission.target);
      final updated = container.read(missionProvider);
      final updatedMission = updated.missions.firstWhere((m) => m.id == mission.id);
      expect(updatedMission.completed, true);
      await Future.delayed(const Duration(milliseconds: 100));
    });
    test('DailyMission serialization roundtrip preserves all fields', () {
      final original = DailyMission(
        id: 'test1',
        title: 'Título test',
        description: 'Descripción test',
        type: MissionType.analyzeLink,
        xpReward: 50,
        target: 3,
        difficulty: MissionDifficulty.hard,
        rarity: MissionRarity.epic,
        xpBonus: 10,
        streakBonus: 2,
        category: MissionCategory.protection,
        progress: 1,
        completed: false,
      );
      final json = original.toJson();
      final restored = DailyMission.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.type, original.type);
      expect(restored.xpReward, original.xpReward);
      expect(restored.target, original.target);
      expect(restored.difficulty, original.difficulty);
      expect(restored.rarity, original.rarity);
      expect(restored.xpBonus, original.xpBonus);
      expect(restored.streakBonus, original.streakBonus);
      expect(restored.category, original.category);
      expect(restored.progress, original.progress);
      expect(restored.completed, original.completed);
    });
    test('DailyMission progressFraction calculation', () {
      final mission = DailyMission(
        id: 'test',
        title: '',
        description: '',
        type: MissionType.completeLesson,
        target: 4,
        progress: 2,
      );
      expect(mission.progressFraction, 0.5);
    });
    test('DailyMission progressFraction clamps at 1.0', () {
      final mission = DailyMission(
        id: 'test',
        title: '',
        description: '',
        type: MissionType.completeLesson,
        target: 4,
        progress: 10,
      );
      expect(mission.progressFraction, 1.0);
    });
    test('DailyMission progressFraction returns 0 for target 0', () {
      final mission = DailyMission(
        id: 'test',
        title: '',
        description: '',
        type: MissionType.completeLesson,
        target: 0,
      );
      expect(mission.progressFraction, 0.0);
    });
  });
}
