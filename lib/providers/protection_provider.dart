import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/map_utils.dart';
import '../services/storage_service.dart';
import '../models/protection_level.dart';
import 'prefs_provider.dart';

class ProtectionState {
  final int score;
  final int totalQueries;
  final int totalAnalyses;
  final int totalMissionsCompleted;
  final int totalCheckIns;
  final List<String> learnedTopics;
  final Map<String, int> habits;
  final String lastInsight;

  const ProtectionState({
    this.score = 0,
    this.totalQueries = 0,
    this.totalAnalyses = 0,
    this.totalMissionsCompleted = 0,
    this.totalCheckIns = 0,
    this.learnedTopics = const [],
    this.habits = const {},
    this.lastInsight = '',
  });

  ProtectionState copyWith({
    int? score,
    int? totalQueries,
    int? totalAnalyses,
    int? totalMissionsCompleted,
    int? totalCheckIns,
    List<String>? learnedTopics,
    Map<String, int>? habits,
    String? lastInsight,
  }) {
    return ProtectionState(
      score: score ?? this.score,
      totalQueries: totalQueries ?? this.totalQueries,
      totalAnalyses: totalAnalyses ?? this.totalAnalyses,
      totalMissionsCompleted:
          totalMissionsCompleted ?? this.totalMissionsCompleted,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      learnedTopics: learnedTopics ?? this.learnedTopics,
      habits: habits ?? this.habits,
      lastInsight: lastInsight ?? this.lastInsight,
    );
  }
}

class ProtectionNotifier extends Notifier<ProtectionState> {
  late final StorageService _storage;

  int get score => state.score;
  int get level => protectionLevelForScore(state.score);
  String get levelName => protectionNameForLevel(level);
  double get progress => protectionProgress(state.score, level);
  int get totalQueries => state.totalQueries;
  int get totalAnalyses => state.totalAnalyses;
  int get totalMissionsCompleted => state.totalMissionsCompleted;
  int get totalCheckIns => state.totalCheckIns;
  List<String> get learnedTopics => List.unmodifiable(state.learnedTopics);
  Map<String, int> get habits => Map.unmodifiable(state.habits);
  String get lastInsight => state.lastInsight;

  static const _keyScore = 'protection_score';
  static const _keyQueries = 'protection_queries';
  static const _keyAnalyses = 'protection_analyses';
  static const _keyMissions = 'protection_missions';
  static const _keyCheckIns = 'protection_checkins';
  static const _keyTopics = 'protection_topics';
  static const _keyHabits = 'protection_habits';

  @override
  ProtectionState build() {
    _storage = StorageService(ref.read(prefsProvider));
    _load();
    return state;
  }

  void _load() {
    final score = _storage.getInt(_keyScore);
    final totalQueries = _storage.getInt(_keyQueries);
    final totalAnalyses = _storage.getInt(_keyAnalyses);
    final totalMissionsCompleted = _storage.getInt(_keyMissions);
    final totalCheckIns = _storage.getInt(_keyCheckIns);
    List<String> learnedTopics = [];
    final topics = _storage.getString(_keyTopics);
    if (topics.isNotEmpty) {
      learnedTopics = topics.split(',').where((s) => s.isNotEmpty).toList();
    }
    Map<String, int> habits = {};
    final habitsStr = _storage.getString(_keyHabits);
    if (habitsStr.isNotEmpty) {
      habits = parseStringMap(habitsStr);
    }

    state = ProtectionState(
      score: score,
      totalQueries: totalQueries,
      totalAnalyses: totalAnalyses,
      totalMissionsCompleted: totalMissionsCompleted,
      totalCheckIns: totalCheckIns,
      learnedTopics: learnedTopics,
      habits: habits,
    );
  }

  void registerCheckIn() {
    int newScore = state.score;
    final oldLevel = protectionLevelForScore(newScore);
    newScore += 10;
    if (newScore < 0) newScore = 0;
    final newLevel = protectionLevelForScore(newScore);
    final newHabits = Map<String, int>.from(state.habits);
    newHabits['checkins'] = (newHabits['checkins'] ?? 0) + 1;
    state = state.copyWith(
      totalCheckIns: state.totalCheckIns + 1,
      score: newScore,
      habits: newHabits,
      lastInsight: newLevel > oldLevel
          ? 'Reached level $newLevel — ${protectionNameForLevel(newLevel)}'
          : state.lastInsight,
    );
    _save();
  }

  void registerQuery(String? topic) {
    int newScore = state.score;
    final newHabits = Map<String, int>.from(state.habits);
    newHabits['queries'] = (newHabits['queries'] ?? 0) + 1;
    List<String> newTopics = List<String>.from(state.learnedTopics);
    String lastInsight = state.lastInsight;

    final oldLevel1 = protectionLevelForScore(newScore);
    newScore += 5;
    if (newScore < 0) newScore = 0;
    final newLevel1 = protectionLevelForScore(newScore);
    if (newLevel1 > oldLevel1) {
      lastInsight =
          'Reached level $newLevel1 — ${protectionNameForLevel(newLevel1)}';
    }

    if (topic != null && topic.isNotEmpty && !newTopics.contains(topic)) {
      newTopics.add(topic);
      final oldLevel2 = protectionLevelForScore(newScore);
      newScore += 15;
      if (newScore < 0) newScore = 0;
      final newLevel2 = protectionLevelForScore(newScore);
      if (newLevel2 > oldLevel2) {
        lastInsight =
            'Reached level $newLevel2 — ${protectionNameForLevel(newLevel2)}';
      }
    }

    state = state.copyWith(
      totalQueries: state.totalQueries + 1,
      score: newScore,
      learnedTopics: newTopics,
      habits: newHabits,
      lastInsight: lastInsight,
    );
    _save();
  }

  void registerAnalysis() {
    int newScore = state.score;
    final oldLevel = protectionLevelForScore(newScore);
    newScore += 8;
    if (newScore < 0) newScore = 0;
    final newLevel = protectionLevelForScore(newScore);
    final newHabits = Map<String, int>.from(state.habits);
    newHabits['analyses'] = (newHabits['analyses'] ?? 0) + 1;
    state = state.copyWith(
      totalAnalyses: state.totalAnalyses + 1,
      score: newScore,
      habits: newHabits,
      lastInsight: newLevel > oldLevel
          ? 'Reached level $newLevel — ${protectionNameForLevel(newLevel)}'
          : state.lastInsight,
    );
    _save();
  }

  void registerMissionCompleted() {
    int newScore = state.score;
    final oldLevel = protectionLevelForScore(newScore);
    newScore += 30;
    if (newScore < 0) newScore = 0;
    final newLevel = protectionLevelForScore(newScore);
    final newHabits = Map<String, int>.from(state.habits);
    newHabits['missions'] = (newHabits['missions'] ?? 0) + 1;
    state = state.copyWith(
      totalMissionsCompleted: state.totalMissionsCompleted + 1,
      score: newScore,
      habits: newHabits,
      lastInsight: newLevel > oldLevel
          ? 'Reached level $newLevel — ${protectionNameForLevel(newLevel)}'
          : state.lastInsight,
    );
    _save();
  }

  String generateInsight() {
    final s = state;
    final insights = <String>[];
    if (s.totalQueries > 20) {
      insights.add(
        'You have ${s.totalQueries} queries. Your learning is consistent.',
      );
    }
    if (s.totalAnalyses > 10) {
      insights.add(
        'You analyzed ${s.totalAnalyses} links. Your detection skills are growing.',
      );
    }
    if (s.totalMissionsCompleted > 5) {
      insights.add(
        'Completed ${s.totalMissionsCompleted} missions. Keep it up!',
      );
    }
    final lvl = protectionLevelForScore(s.score);
    if (lvl >= 10) {
      insights.add(
        'Level $lvl — ${protectionNameForLevel(lvl)}. Your consistency pays off.',
      );
    }
    if (s.totalCheckIns > 30) {
      insights.add(
        'Over ${s.totalCheckIns} active days. Consistency is your best ally.',
      );
    }
    if (insights.isEmpty) {
      insights.addAll([
        'Every day you use SAGEN, your protection grows.',
        'Keep learning. Digital security is built day by day.',
        'Your protection level will increase with every action.',
      ]);
    }
    final insight =
        insights[DateTime.now().millisecondsSinceEpoch % insights.length];
    state = state.copyWith(lastInsight: insight);
    _save();
    return insight;
  }

  void reload() {
    _load();
  }

  void _save() {
    final s = state;
    _storage.setInt(_keyScore, s.score);
    _storage.setInt(_keyQueries, s.totalQueries);
    _storage.setInt(_keyAnalyses, s.totalAnalyses);
    _storage.setInt(_keyMissions, s.totalMissionsCompleted);
    _storage.setInt(_keyCheckIns, s.totalCheckIns);
    _storage.setString(_keyTopics, s.learnedTopics.join(','));
    _storage.setString(_keyHabits, encodeStringMap(s.habits));
  }
}
