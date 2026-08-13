import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chest_type.dart';
import '../models/daily_mission.dart';
import '../services/chest_event_bus.dart';
import '../services/storage_service.dart';
import '../services/app_logger.dart';
import 'providers.dart';

class MissionState {
  final List<DailyMission> missions;
  final DateTime lastReset;
  final int totalMissionsCompleted;

  MissionState({
    this.missions = const [],
    DateTime? lastReset,
    this.totalMissionsCompleted = 0,
  }) : lastReset = lastReset ?? DateTime(0);

  MissionState copyWith({
    List<DailyMission>? missions,
    DateTime? lastReset,
    int? totalMissionsCompleted,
  }) {
    return MissionState(
      missions: missions ?? this.missions,
      lastReset: lastReset ?? this.lastReset,
      totalMissionsCompleted:
          totalMissionsCompleted ?? this.totalMissionsCompleted,
    );
  }
}

class MissionNotifier extends Notifier<MissionState> {
  late final StorageService _storage;
  bool _disposed = false;

  List<DailyMission> get missions => List.unmodifiable(state.missions);
  int get totalMissionsCompleted => state.totalMissionsCompleted;
  int get completedToday => state.missions.where((m) => m.completed).length;

  static const _keyMissions = 'daily_missions_v2';
  static const _keyReset = 'daily_missions_reset';
  static const _keyTotal = 'daily_missions_total';

  @override
  MissionState build() {
    ref.onDispose(() => _disposed = true);
    _storage = StorageService(ref.read(prefsProvider));
    _load();
    _checkReset();
    return state;
  }

  void _load() {
    final raw = _storage.getString(_keyMissions);
    List<DailyMission> missions = [];
    if (raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          missions = decoded
              .map((e) => DailyMission.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        AppLogger().warning('Failed to parse missions JSON: $e');
      }
    }
    final resetStr = _storage.getString(_keyReset);
    DateTime lastReset = DateTime.now();
    if (resetStr.isNotEmpty) {
      lastReset = DateTime.tryParse(resetStr) ?? DateTime.now();
    }
    final total = _storage.getInt(_keyTotal);

    state = MissionState(
      missions: missions,
      lastReset: lastReset,
      totalMissionsCompleted: total,
    );
    if (missions.isEmpty) {
      _generateMissions();
    }
  }

  void _save() {
    _storage.setString(
      _keyMissions,
      jsonEncode(state.missions.map((m) => m.toJson()).toList()),
    );
    _storage.setString(_keyReset, state.lastReset.toIso8601String());
    _storage.setInt(_keyTotal, state.totalMissionsCompleted);
  }

  void _checkReset() {
    final now = DateTime.now();
    final reset = DateTime(
      state.lastReset.year,
      state.lastReset.month,
      state.lastReset.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    if (today.isAfter(reset)) {
      _generateMissions();
      state = state.copyWith(lastReset: now);
      _save();
    }
  }

  void _generateMissions() {
    final daySeed = DateTime.now().difference(DateTime(2024, 1, 1)).inDays;
    final uid = ref.read(authServiceProvider).currentUser?.uid ?? 'anonymous';
    final userSeed = uid.hashCode;
    final combinedSeed = daySeed ^ userSeed;
    final allMissions = [
      DailyMission(
        id: 'm1',
        title: 'Perfect Lesson',
        description: 'Complete a lesson without mistakes.',
        type: MissionType.perfectLesson,
        target: 1,
        xpReward: 40,
        difficulty: MissionDifficulty.hard,
        rarity: MissionRarity.rare,
        xpBonus: 10,
        category: MissionCategory.learning,
      ),
      DailyMission(
        id: 'm2',
        title: 'Active Learner',
        description: 'Complete 1 security lesson.',
        type: MissionType.completeLesson,
        target: 1,
        xpReward: 30,
        difficulty: MissionDifficulty.easy,
        rarity: MissionRarity.common,
        category: MissionCategory.learning,
      ),
      DailyMission(
        id: 'm3',
        title: 'Digital Detective',
        description: 'Analyze a suspicious link.',
        type: MissionType.analyzeLink,
        target: 1,
        xpReward: 25,
        difficulty: MissionDifficulty.easy,
        rarity: MissionRarity.common,
        category: MissionCategory.protection,
      ),
      DailyMission(
        id: 'm4',
        title: 'Chat with Sage',
        description: 'Talk to Sage about digital security.',
        type: MissionType.talkToSage,
        target: 1,
        xpReward: 20,
        difficulty: MissionDifficulty.easy,
        rarity: MissionRarity.common,
        category: MissionCategory.awareness,
      ),
      DailyMission(
        id: 'm5',
        title: 'Active Streak',
        description: 'Maintain your learning streak today.',
        type: MissionType.maintainStreak,
        target: 1,
        xpReward: 35,
        difficulty: MissionDifficulty.medium,
        rarity: MissionRarity.rare,
        xpBonus: 5,
        streakBonus: 1,
        category: MissionCategory.consistency,
      ),
      DailyMission(
        id: 'm6',
        title: 'Express Challenge',
        description: 'Complete a quick 30-second challenge.',
        type: MissionType.quickChallenge,
        target: 1,
        xpReward: 20,
        difficulty: MissionDifficulty.easy,
        rarity: MissionRarity.common,
        category: MissionCategory.learning,
      ),
      DailyMission(
        id: 'm7',
        title: 'Phishing Hunter',
        description: 'Correctly detect a phishing attempt.',
        type: MissionType.detectPhishing,
        target: 1,
        xpReward: 45,
        difficulty: MissionDifficulty.hard,
        rarity: MissionRarity.epic,
        xpBonus: 15,
        category: MissionCategory.privacy,
      ),
      DailyMission(
        id: 'm8',
        title: '3 Queries',
        description: 'Talk to Sage 3 times about different topics.',
        type: MissionType.talkToSage,
        target: 3,
        xpReward: 50,
        difficulty: MissionDifficulty.medium,
        rarity: MissionRarity.rare,
        xpBonus: 10,
        category: MissionCategory.awareness,
      ),
      DailyMission(
        id: 'm9',
        title: 'Constant Protector',
        description: 'Complete 3 lessons today.',
        type: MissionType.completeLesson,
        target: 3,
        xpReward: 60,
        difficulty: MissionDifficulty.hard,
        rarity: MissionRarity.epic,
        xpBonus: 20,
        streakBonus: 2,
        category: MissionCategory.consistency,
      ),
    ];

    final startIdx = combinedSeed % allMissions.length;
    state = state.copyWith(
      missions: [
        allMissions[startIdx % allMissions.length],
        allMissions[(startIdx + 3) % allMissions.length],
        allMissions[(startIdx + 6) % allMissions.length],
      ],
    );
  }

  void advanceMission(MissionType type, {int amount = 1}) {
    final missions = state.missions;
    final idx = missions.indexWhere((m) => m.type == type && !m.completed);
    if (idx == -1) return;

    final mission = missions[idx];
    final newProgress = mission.progress + amount;
    final newCompleted = newProgress >= mission.target;

    final newMissions = List<DailyMission>.from(missions);
    newMissions[idx] = mission.copyWith(
      progress: newProgress,
      completed: newCompleted,
    );

    state = state.copyWith(
      missions: newMissions,
      totalMissionsCompleted:
          state.totalMissionsCompleted + (newCompleted ? 1 : 0),
    );
    _save();

    if (newCompleted) {
      _rewardMission(mission).catchError((e) {
        AppLogger().warning('Mission reward failed: $e');
      });
    }
  }

  Future<void> _rewardMission(DailyMission mission) async {
    if (_disposed) return;
    final roll = math.Random().nextDouble();

    ChestType? chestType;

    if (roll < 0.02) {
      chestType = ChestType.legendary;
    } else if (roll < 0.08) {
      chestType = ChestType.gold;
    } else if (roll < 0.25) {
      chestType = ChestType.silver;
    } else if (roll < 0.70) {
      chestType = ChestType.bronze;
    }

    if (chestType != null) {
      final reward = await ref.read(chestRewardRollerProvider).roll(chestType);
      await ref
          .read(learningProvider.notifier)
          .addXp(reward.xp, reason: 'mission_reward');
      ref.read(gemProvider.notifier).awardMissionGems();
      ref
          .read(chestEventBusProvider)
          .fire(
            ChestRewardData(
              type: chestType,
              xp: reward.xp,
              streakShields: reward.streakShields,
              xpBoost: reward.xpBoost,
              specialItems: reward.specialItems,
              cosmeticUnlocks: reward.cosmeticUnlocks,
              source: 'mission',
            ),
          );
    }
  }

  void reload() {
    _load();
    _checkReset();
  }
}
