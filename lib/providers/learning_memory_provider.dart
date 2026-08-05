import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/app_logger.dart';
import '../services/storage_service.dart';
import '../models/quick_challenge.dart';
import 'prefs_provider.dart';

class WeakTopic {
  final String id;
  final String label;
  final int failCount;
  final int totalAttempts;

  WeakTopic({required this.id, required this.label, this.failCount = 0, this.totalAttempts = 0});

  double get failRate => totalAttempts > 0 ? failCount / totalAttempts : 0;
  bool get isWeak => totalAttempts >= 2 && failRate > 0.5;

  Map<String, dynamic> toJson() => {
    'id': id, 'label': label, 'failCount': failCount, 'totalAttempts': totalAttempts,
  };

  factory WeakTopic.fromJson(Map<String, dynamic> json) => WeakTopic(
    id: json['id'] as String,
    label: json['label'] as String,
    failCount: json['failCount'] as int? ?? 0,
    totalAttempts: json['totalAttempts'] as int? ?? 0,
  );
}

class LearningMemoryState {
  final List<WeakTopic> weakTopics;
  final List<String> completedChallenges;
  final int totalLessonsFailed;
  final int totalLessonsPassed;
  final DateTime? lastSessionDate;
  final int sessionsThisWeek;

  const LearningMemoryState({
    this.weakTopics = const [],
    this.completedChallenges = const [],
    this.totalLessonsFailed = 0,
    this.totalLessonsPassed = 0,
    this.lastSessionDate,
    this.sessionsThisWeek = 0,
  });

  LearningMemoryState copyWith({
    List<WeakTopic> Function()? weakTopics,
    List<String> Function()? completedChallenges,
    int? totalLessonsFailed,
    int? totalLessonsPassed,
    DateTime? Function()? lastSessionDate,
    int? sessionsThisWeek,
  }) {
    return LearningMemoryState(
      weakTopics: weakTopics != null ? weakTopics() : this.weakTopics,
      completedChallenges: completedChallenges != null ? completedChallenges() : this.completedChallenges,
      totalLessonsFailed: totalLessonsFailed ?? this.totalLessonsFailed,
      totalLessonsPassed: totalLessonsPassed ?? this.totalLessonsPassed,
      lastSessionDate: lastSessionDate != null ? lastSessionDate() : this.lastSessionDate,
      sessionsThisWeek: sessionsThisWeek ?? this.sessionsThisWeek,
    );
  }

  double get overallPassRate => (totalLessonsPassed + totalLessonsFailed) > 0
      ? totalLessonsPassed / (totalLessonsPassed + totalLessonsFailed)
      : 0;

  List<QuickChallengeType> get recommendedChallengeTypes {
    final weak = weakTopics.where((t) => t.isWeak).toList();
    if (weak.isEmpty) return [];
    final types = <QuickChallengeType>[];
    for (final t in weak) {
      switch (t.id) {
        case 'phishing': types.add(QuickChallengeType.detectPhishing);
        case 'passwords': types.add(QuickChallengeType.safePassword);
        case 'risks': types.add(QuickChallengeType.detectRisk);
        case 'scenarios': types.add(QuickChallengeType.whatWouldYouDo);
      }
    }
    return types;
  }

  List<String> get suggestedTipTopics {
    return weakTopics.where((t) => t.isWeak).map((t) => t.label).toList();
  }
}

class LearningMemoryNotifier extends Notifier<LearningMemoryState> {
  late final StorageService _storage;
  bool _saveInProgress = false;
  bool _savePending = false;

  static const _keyWeakTopics = 'learning_memory_weak_topics';
  static const _keyCompletedChallenges = 'learning_memory_completed_challenges';
  static const _keyFailed = 'learning_memory_failed';
  static const _keyPassed = 'learning_memory_passed';
  static const _keyLastSession = 'learning_memory_last_session';
  static const _keySessionsWeek = 'learning_memory_sessions_week';

  @override
  LearningMemoryState build() {
    final prefs = ref.read(prefsProvider);
    _storage = StorageService(prefs);
    _load();
    return state;
  }

  List<WeakTopic> get weakTopics => List.unmodifiable(state.weakTopics);
  List<String> get completedChallenges => List.unmodifiable(state.completedChallenges);
  int get totalLessonsFailed => state.totalLessonsFailed;
  int get totalLessonsPassed => state.totalLessonsPassed;
  DateTime? get lastSessionDate => state.lastSessionDate;
  int get sessionsThisWeek => state.sessionsThisWeek;
  double get overallPassRate => state.overallPassRate;
  List<QuickChallengeType> get recommendedChallengeTypes => state.recommendedChallengeTypes;
  List<String> get suggestedTipTopics => state.suggestedTipTopics;

  void _load() {
    final raw = _storage.getString(_keyWeakTopics);
    List<WeakTopic> weakTopics = [];
    if (raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        weakTopics = list.map((e) => WeakTopic.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        AppLogger().warning('LearningMemory: failed to decode weak topics: $e');
      }
    }

    List<String> completedChallenges = [];
    final completed = _storage.getString(_keyCompletedChallenges);
    if (completed.isNotEmpty) {
      try {
        completedChallenges = (jsonDecode(completed) as List).cast<String>();
      } catch (e) {
        AppLogger().warning('LearningMemory: failed to decode completed challenges: $e');
      }
    }

    final totalLessonsFailed = _storage.getInt(_keyFailed);
    final totalLessonsPassed = _storage.getInt(_keyPassed);

    DateTime? lastSessionDate;
    final last = _storage.getString(_keyLastSession);
    if (last.isNotEmpty) lastSessionDate = DateTime.tryParse(last);

    final sessionsThisWeek = _storage.getInt(_keySessionsWeek);

    state = LearningMemoryState(
      weakTopics: weakTopics,
      completedChallenges: completedChallenges,
      totalLessonsFailed: totalLessonsFailed,
      totalLessonsPassed: totalLessonsPassed,
      lastSessionDate: lastSessionDate,
      sessionsThisWeek: sessionsThisWeek,
    );
  }

  Future<void> _save() async {
    if (_saveInProgress) {
      _savePending = true;
      return;
    }
    _saveInProgress = true;
    try {
      await _storage.setString(_keyWeakTopics, jsonEncode(state.weakTopics.map((t) => t.toJson()).toList()));
      await _storage.setString(_keyCompletedChallenges, jsonEncode(state.completedChallenges));
      await _storage.setInt(_keyFailed, state.totalLessonsFailed);
      await _storage.setInt(_keyPassed, state.totalLessonsPassed);
      await _storage.setInt(_keySessionsWeek, state.sessionsThisWeek);
      if (state.lastSessionDate case final last?) {
        await _storage.setString(_keyLastSession, last.toIso8601String());
      }
    } finally {
      _saveInProgress = false;
      if (_savePending) {
        _savePending = false;
        await _save();
      }
    }
  }

  void recordLessonResult({required bool passed, required String topic}) {
    final weakTopics = List<WeakTopic>.from(state.weakTopics);
    int totalLessonsFailed = state.totalLessonsFailed;
    int totalLessonsPassed = state.totalLessonsPassed;

    if (passed) {
      totalLessonsPassed++;
    } else {
      totalLessonsFailed++;
    }

    final existing = weakTopics.where((t) => t.id == topic).toList();
    if (existing.isNotEmpty) {
      final idx = weakTopics.indexOf(existing.first);
      weakTopics[idx] = WeakTopic(
        id: existing.first.id,
        label: existing.first.label,
        totalAttempts: existing.first.totalAttempts + 1,
        failCount: passed ? existing.first.failCount : existing.first.failCount + 1,
      );
    } else {
      weakTopics.add(WeakTopic(id: topic, label: topic, totalAttempts: 1, failCount: passed ? 0 : 1));
    }

    state = state.copyWith(
      weakTopics: () => weakTopics,
      totalLessonsFailed: totalLessonsFailed,
      totalLessonsPassed: totalLessonsPassed,
    );

    _updateSession();
    _save();
  }

  void recordChallengeAttempt({required String challengeId, required bool passed, required QuickChallengeType type}) {
    const maxCompletedChallenges = 500;
    final topic = _topicForType(type);
    final completedChallenges = List<String>.from(state.completedChallenges);
    if (!completedChallenges.contains(challengeId)) {
      completedChallenges.add(challengeId);
      if (completedChallenges.length > maxCompletedChallenges) {
        completedChallenges.removeRange(0, completedChallenges.length - maxCompletedChallenges);
      }
    }

    final weakTopics = List<WeakTopic>.from(state.weakTopics);
    final existing = weakTopics.where((t) => t.id == topic).toList();
    if (existing.isNotEmpty) {
      final idx = weakTopics.indexOf(existing.first);
      weakTopics[idx] = WeakTopic(
        id: existing.first.id,
        label: existing.first.label,
        totalAttempts: existing.first.totalAttempts + 1,
        failCount: passed ? existing.first.failCount : existing.first.failCount + 1,
      );
    } else {
      weakTopics.add(WeakTopic(id: topic, label: topic, totalAttempts: 1, failCount: passed ? 0 : 1));
    }

    state = state.copyWith(
      completedChallenges: () => completedChallenges,
      weakTopics: () => weakTopics,
    );

    _updateSession();
    _save();
  }

  void _updateSession() {
    final now = DateTime.now();
    final lastDate = state.lastSessionDate;
    int sessionsThisWeek = state.sessionsThisWeek;
    DateTime? lastSessionDate = state.lastSessionDate;

    if (lastDate == null || !_isSameDay(lastDate, now)) {
      if (lastDate != null && now.difference(lastDate).inDays <= 7) {
        sessionsThisWeek++;
      } else {
        sessionsThisWeek = 1;
      }
      lastSessionDate = now;
    }

    state = state.copyWith(
      sessionsThisWeek: sessionsThisWeek,
      lastSessionDate: () => lastSessionDate,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _topicForType(QuickChallengeType type) {
    switch (type) {
      case QuickChallengeType.detectPhishing: return 'phishing';
      case QuickChallengeType.safePassword: return 'passwords';
      case QuickChallengeType.detectRisk: return 'risks';
      case QuickChallengeType.whatWouldYouDo: return 'scenarios';
      case QuickChallengeType.trueFalse: return 'general';
    }
  }
}
