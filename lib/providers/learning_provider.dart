import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/learning/stage.dart';
import '../models/learning/lesson.dart';

import '../services/app_logger.dart';
import 'providers.dart';
import '../repositories/learning_repository.dart';
import 'learning_stages.dart';

final learningProvider = NotifierProvider<LearningNotifier, LearningState>(
  LearningNotifier.new,
);

class LearningState {
  final List<Stage> stages;
  final double totalDonated;
  final bool isSupporter;
  final int xp;
  final int currentLevel;
  final int lessonsCompleted;
  final List<String> achievements;
  final int totalXpEarned;
  final int sageTalks;
  final bool isLoading;
  final String? errorMessage;

  const LearningState({
    this.stages = const [],
    this.totalDonated = 0.0,
    this.isSupporter = false,
    this.xp = 0,
    this.currentLevel = 1,
    this.lessonsCompleted = 0,
    this.achievements = const [],
    this.totalXpEarned = 0,
    this.sageTalks = 0,
    this.isLoading = true,
    this.errorMessage,
  });

  LearningState copyWith({
    List<Stage> Function()? stages,
    double? totalDonated,
    bool? isSupporter,
    int? xp,
    int? currentLevel,
    int? lessonsCompleted,
    List<String> Function()? achievements,
    int? totalXpEarned,
    int? sageTalks,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return LearningState(
      stages: stages != null ? stages() : this.stages,
      totalDonated: totalDonated ?? this.totalDonated,
      isSupporter: isSupporter ?? this.isSupporter,
      xp: xp ?? this.xp,
      currentLevel: currentLevel ?? this.currentLevel,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      achievements: achievements != null ? achievements() : this.achievements,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      sageTalks: sageTalks ?? this.sageTalks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  double get overallProgress {
    if (stages.isEmpty) return 0;
    final total = stages.fold<int>(0, (s, stage) => s + stage.lessons.length);
    final done = stages.fold<int>(0, (s, stage) => s + stage.completedCount);
    if (total == 0) return 0;
    return done / total;
  }

  int get nextLevelXp => 100;
  double get levelProgress {
    final inLevelXp = totalXpEarned - (currentLevel - 1) * 100;
    return (inLevelXp / 100).clamp(0.0, 1.0);
  }
}

class LearningNotifier extends Notifier<LearningState> {
  bool _initInProgress = false;
  bool _initQueued = false;
  bool _disposed = false;

  final _levelUpController = StreamController<int>.broadcast();
  Stream<int> get onLevelUp => _levelUpController.stream;

  LearningRepository get _repo => ref.read(learningRepositoryProvider);

  /// XP real que acredita el servidor al completar una lección: recompensa
  /// base por lección (15, 20 si termina en `_l6` — igual que el servidor)
  /// escalada por el multiplicador de racha. El boost de XP NO se aplica
  /// (no tiene efecto server-side, ver NUEVO-10); la reconciliación es
  /// server-authoritative. Fuente única usada tanto para acreditar como
  /// para mostrar en la pantalla de resultados.
  int xpForLesson(Lesson lesson) {
    final streakMult = ref.read(streakProvider).streakMultiplier;
    final baseXp = lesson.id.endsWith('_l6') ? 20 : 15;
    return (baseXp * streakMult).round();
  }

  static List<String> _localizedEmotionalPhrases(AppLocalizations l) => [
    l.emotionPhrase1,
    l.emotionPhrase2,
    l.emotionPhrase3,
    l.emotionPhrase4,
    l.emotionPhrase5,
    l.emotionPhrase6,
    l.emotionPhrase7,
  ];

  String localizedEmotionalPhrase(AppLocalizations l) {
    if (state.lessonsCompleted == 0) return l.emotionPhraseStart;
    final phrases = _localizedEmotionalPhrases(l);
    final idx = (state.lessonsCompleted - 1) % phrases.length;
    return phrases[idx];
  }

  @override
  LearningState build() {
    ref.onDispose(() {
      _disposed = true;
      _levelUpController.close();
      final queue = ref.read(offlineQueueServiceProvider);
      queue.onItemSynced = null;
      queue.onItemDropped = null;
    });

    ref.listen<SharedPreferences>(prefsProvider, (prev, next) {
      if (prev?.getString('preferredLanguage') !=
          next.getString('preferredLanguage')) {
        _init();
      }
    });

    ref.listen(cloudSyncServiceProvider, (prev, next) {
      if (prev != next) _init();
    });

    // Wire up queue reconciliation callbacks and initialize
    final queue = ref.read(offlineQueueServiceProvider);
    queue.onItemSynced = (result) => _reconcileWithServer(result);
    queue.onItemDropped = (item) => _onQueueItemDropped(item);
    queue.init(); // Initialize queue from SQLite

    _init();
    return const LearningState();
  }

  /// Reconcile local state with server response after queue sync.
  /// Server values are the source of truth for economic fields (NUEVO-10):
  /// the server applies the streak multiplier itself, so the local total is
  /// set to the server-reported total/level instead of keeping the inflated
  /// local value forever via max().
  void _reconcileWithServer(Map<String, dynamic> result) {
    if (result['duplicate'] == true) return;
    try {
      final xpData = result['xp'];
      final levelData = result['level'];
      final rawLessons = result['lessonsCompleted'];

      final serverTotalXp = (xpData is Map) ? xpData['totalXp'] as int? : null;
      final serverLevel = (levelData is Map)
          ? levelData['current'] as int?
          : null;
      final serverLessonsCompleted = (rawLessons is int) ? rawLessons : null;
      final serverLessonId = result['lessonId'] as String?;

      // The server gem ledger is authoritative: reconcile the local cache
      // with the balance reported by completeLesson (NUEVO-03).
      final gemsData = result['gems'];
      final serverGemBalance = (gemsData is Map)
          ? (gemsData['balance'] as num?)?.toInt()
          : null;
      if (serverGemBalance != null) {
        ref.read(gemProvider.notifier).syncBalance(serverGemBalance);
      }

      if (serverTotalXp != null || serverLevel != null) {
        final authoritativeTotalXp = serverTotalXp ?? state.totalXpEarned;
        final authoritativeLevel = serverLevel ?? state.currentLevel;
        // Recompute progress-within-level from the authoritative total so
        // the level bar matches the server.
        final progressInLevel =
            authoritativeTotalXp - (authoritativeLevel - 1) * 100;
        state = state.copyWith(
          totalXpEarned: authoritativeTotalXp,
          currentLevel: authoritativeLevel,
          xp: progressInLevel < 0 ? 0 : progressInLevel,
          lessonsCompleted: serverLessonsCompleted ?? state.lessonsCompleted,
        );
        _save();
      }

      // NUEVO-fix: the lesson chest is rolled only AFTER the server confirms
      // the lesson completion, using the server-authoritative lesson counter.
      // Rolling it earlier (from the local, already-incremented counter) made
      // rollChestDrop derive the tier from the stale server counter, turning
      // milestone chests into bronze and locking the wrong idempotency key.
      if (serverLessonsCompleted != null) {
        unawaited(
          _checkLessonChest(
            serverLessonId ?? 'lesson_sync',
            lessonsCompleted: serverLessonsCompleted,
          ),
        );
      }
    } catch (e) {
      AppLogger().warning('_reconcileWithServer failed: $e');
    }
  }

  /// Handle a queue item that was dropped after max retries.
  void _onQueueItemDropped(Map<String, dynamic> item) {
    AppLogger().warning(
      'Queue item dropped after max retries: ${item['lessonId']}',
    );
  }

  Future<void> _init() async {
    if (_initInProgress) {
      _initQueued = true;
      return;
    }
    _initInProgress = true;
    final repo = _repo;
    try {
      await _load();

      final freshStages = await repo.fetchStages();
      if (freshStages.isNotEmpty) {
        _mergeProgress(freshStages, state.stages);
        state = state.copyWith(stages: () => freshStages);
        repo.saveStages(state.stages);
      }

      var currentStages = state.stages;
      if (currentStages.isEmpty) {
        final assetStages = await loadStagesFromAssets();
        if (assetStages.isNotEmpty) {
          currentStages = assetStages;
          currentStages = _unlockFirstStage(currentStages);
          repo.saveStages(currentStages);
          state = state.copyWith(stages: () => currentStages);
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () =>
                'Could not load content. Check your connection and try again.',
          );
          return;
        }
      }

      if (currentStages.isNotEmpty && !currentStages[0].unlocked) {
        currentStages = _unlockFirstStage(currentStages);
        state = state.copyWith(stages: () => currentStages);
      }

      state = state.copyWith(isLoading: false, errorMessage: () => null);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () =>
            'Could not load your progress. Check your connection and try again.',
      );
    } finally {
      _initInProgress = false;
      if (_initQueued) {
        _initQueued = false;
        _init();
      }
    }
  }

  List<Stage> _unlockFirstStage(List<Stage> stages) {
    if (stages.isEmpty) return stages;
    return stages
        .map((s) => s.id == stages[0].id ? s.copyWith(unlocked: true) : s)
        .toList();
  }

  void _mergeProgress(List<Stage> freshStages, List<Stage> cachedStages) {
    for (int i = 0; i < freshStages.length; i++) {
      final fresh = freshStages[i];
      final cached = cachedStages.where((s) => s.id == fresh.id).firstOrNull;
      if (cached == null) continue;
      final updatedLessons = fresh.lessons.map((freshLesson) {
        final cachedLesson = cached.lessons
            .where((l) => l.id == freshLesson.id)
            .firstOrNull;
        if (cachedLesson == null) return freshLesson;
        if (cachedLesson.completed) {
          return freshLesson.copyWith(
            completed: true,
            correctAnswers: cachedLesson.correctAnswers,
            totalQuestions: cachedLesson.totalQuestions,
          );
        }
        // Preserve partial progress even if not yet completed
        if (cachedLesson.correctAnswers > 0 ||
            cachedLesson.totalQuestions > 0) {
          return freshLesson.copyWith(
            correctAnswers: cachedLesson.correctAnswers,
            totalQuestions: cachedLesson.totalQuestions,
          );
        }
        return freshLesson;
      }).toList();
      final updatedSessions = fresh.sessions.map((freshSession) {
        final cachedSession = cached.sessions
            .where((s) => s.id == freshSession.id)
            .firstOrNull;
        if (cachedSession == null) return freshSession;
        final mergedLessons = freshSession.lessons.map((fl) {
          final cl = cachedSession.lessons
              .where((l) => l.id == fl.id)
              .firstOrNull;
          if (cl == null) return fl;
          if (cl.completed) {
            return fl.copyWith(
              completed: true,
              correctAnswers: cl.correctAnswers,
              totalQuestions: cl.totalQuestions,
            );
          }
          if (cl.correctAnswers > 0 || cl.totalQuestions > 0) {
            return fl.copyWith(
              correctAnswers: cl.correctAnswers,
              totalQuestions: cl.totalQuestions,
            );
          }
          return fl;
        }).toList();
        return freshSession.copyWith(lessons: mergedLessons);
      }).toList();
      freshStages[i] = fresh.copyWith(
        unlocked: cached.unlocked,
        lessons: updatedLessons,
        sessions: updatedSessions,
      );
    }
  }

  Future<void> _load() async {
    final repo = _repo;
    await repo.load();
    state = state.copyWith(
      stages: () => List.from(repo.stages),
      xp: repo.xp,
      currentLevel: repo.currentLevel,
      lessonsCompleted: repo.lessonsCompleted,
      achievements: () => List.from(repo.achievements),
      totalXpEarned: repo.totalXpEarned,
      sageTalks: repo.sageTalks,
    );
  }

  void _save() {
    List<Stage>? prevStages;
    int? prevXp;
    int? prevLevel;
    int? prevLessons;
    int? prevTotalXp;
    List<String>? prevAchievements;
    try {
      final repo = _repo;
      final s = state;
      prevStages = List<Stage>.from(repo.stages);
      prevXp = repo.xp;
      prevLevel = repo.currentLevel;
      prevLessons = repo.lessonsCompleted;
      prevTotalXp = repo.totalXpEarned;
      prevAchievements = List<String>.from(repo.achievements);
      repo.saveAll(
        stages: s.stages,
        totalDonated: s.totalDonated,
        xp: s.xp,
        level: s.currentLevel,
        lessonsCompleted: s.lessonsCompleted,
        achievements: s.achievements,
        totalXp: s.totalXpEarned,
        sageTalks: s.sageTalks,
        isSupporter: s.isSupporter,
      );
    } catch (e) {
      AppLogger().warning('LearningNotifier._save failed: $e');
      if (prevXp != null &&
          prevStages != null &&
          prevLevel != null &&
          prevLessons != null &&
          prevAchievements != null &&
          prevTotalXp != null) {
        try {
          final repo = _repo;
          repo.saveAll(
            stages: prevStages,
            totalDonated: repo.totalDonated,
            xp: prevXp,
            level: prevLevel,
            lessonsCompleted: prevLessons,
            achievements: prevAchievements,
            totalXp: prevTotalXp,
            sageTalks: state.sageTalks,
            isSupporter: repo.isSupporter,
          );
        } catch (e) {
          AppLogger().warning('LearningNotifier._save rollback failed: $e');
        }
      }
    }
  }

  Future<void> completeLesson(
    String stageId,
    String lessonId, {
    bool perfectLesson = false,
    int correctAnswers = 0,
    int totalQuestions = 0,
  }) async {
    final stageIndex = state.stages.indexWhere((s) => s.id == stageId);
    if (stageIndex == -1) return;

    final stage = state.stages[stageIndex];
    final lessonIndex = stage.lessons.indexWhere((l) => l.id == lessonId);
    if (lessonIndex == -1) return;

    final lesson = stage.lessons[lessonIndex];
    if (lesson.completed) return;

    final newLesson = lesson.copyWith(
      completed: true,
      correctAnswers: correctAnswers,
      totalQuestions: totalQuestions,
    );

    final newLessons = List.of(stage.lessons);
    newLessons[lessonIndex] = newLesson;

    final newStages = List.of(state.stages);
    newStages[stageIndex] = stage.copyWith(lessons: newLessons);

    final boostActive = ref.read(shopProvider).xpBoostActive;
    final multipliedXp = xpForLesson(lesson);
    if (boostActive) ref.read(shopProvider.notifier).deactivateXpBoost();

    final newLessonsCompleted = state.lessonsCompleted + 1;
    final newXp = state.xp + multipliedXp;
    final newTotalXp = (state.totalXpEarned + multipliedXp).clamp(0, 1000000);

    final newLevel = (newTotalXp / 100).floor() + 1;
    final didLevelUp = newLevel > state.currentLevel;
    final finalCurrentLevel = didLevelUp ? newLevel : state.currentLevel;
    final finalXp = didLevelUp ? newTotalXp - (newLevel - 1) * 100 : newXp;

    state = state.copyWith(
      stages: () => newStages,
      lessonsCompleted: newLessonsCompleted,
      xp: finalXp,
      totalXpEarned: newTotalXp,
      currentLevel: finalCurrentLevel,
    );
    if (didLevelUp && !_disposed) _levelUpController.add(newLevel);

    ref.read(analyticsServiceProvider).trackLessonComplete(lessonId);
    _checkUnlocks();
    _checkAchievements(perfectLesson);

    // Calculate gems for offline queue sync (must match actual gem awards)
    final gemsBase = correctAnswers * 5;
    final gemsPerfectFlat = perfectLesson ? 20 : 0;
    final gemsFirstLesson =
        ref.read(gemProvider.notifier).canAwardFirstLessonOfDay ? 10 : 0;
    final gemsEarned = gemsBase + gemsPerfectFlat + gemsFirstLesson;

    // Award gems for lesson completion
    ref
        .read(gemProvider.notifier)
        .awardLessonGems(correctAnswers, perfectLesson);
    if (perfectLesson) ref.read(gemProvider.notifier).awardPerfectLessonBonus();
    ref.read(gemProvider.notifier).awardFirstLessonOfDay();

    _save();

    // Queue lesson for server-side sync (single entry point).
    ref
        .read(offlineQueueServiceProvider)
        .queueLessonCompletion(
          lessonId: lessonId,
          stageId: stageId,
          gemsEarned: gemsEarned,
          xpEarned: multipliedXp,
          correctAnswers: correctAnswers,
          totalQuestions: totalQuestions,
          completedAt: DateTime.now(),
        );

    // El cofre de lección se rueda tras la confirmación del servidor en
    // _reconcileWithServer (contador server-authoritative). No se rueda aquí.
    _scheduleStreakReminder();
  }

  void _scheduleStreakReminder() {
    if (_disposed) return;
    final streak = ref.read(streakProvider).status.currentStreak;
    ref.read(notificationServiceProvider).scheduleStreakReminder(streak);
  }

  Future<void> _checkLessonChest(
    String lessonId, {
    required int lessonsCompleted,
  }) async {
    final luckActive = ref.read(itemProvider.notifier).isLuckBoostActive();
    final data = await ref
        .read(learningRewardServiceProvider)
        .rollChest(
          lessonsCompleted: lessonsCompleted,
          totalDonated: state.totalDonated,
          xp: state.xp,
          luckBoostActive: luckActive,
          contextId: 'lesson_$lessonId',
        );
    if (data == null) return;

    // El servidor ya acredita el XP del cofre en rollChestDrop de forma
    // atómica; aquí solo se refleja en el estado local (sin re-llamar).
    if (data.xp > 0) applyServerXp(data.xp);

    ref.read(learningRewardServiceProvider).emitRewardEffects(data);
  }

  void _checkAchievements(bool perfectLesson) {
    if (_disposed) return;
    final lc = state.lessonsCompleted;
    final a = ref.read(achievementProvider.notifier);
    if (lc >= 1) {
      a.unlockAchievement('first_lesson');
    }
    if (lc >= 5) {
      a.unlockAchievement('five_lessons');
    }
    if (lc >= 10) {
      a.unlockAchievement('ten_lessons');
    }
    if (lc >= 25) {
      a.unlockAchievement('twenty_five_lessons');
    }
    if (lc >= 50) {
      a.unlockAchievement('fifty_lessons');
    }

    final firstComplete = state.stages.any((s) => s.isComplete);
    if (firstComplete) {
      a.unlockAchievement('stage_complete');
    }

    final allComplete = state.stages.every((s) => s.isComplete);
    if (allComplete) {
      a.unlockAchievement('all_stages');
    }

    if (perfectLesson) {
      a.unlockAchievement('perfect_lesson');
    }
  }

  void _checkUnlocks() {
    var stages = state.stages;
    bool changed = false;
    for (int i = 1; i < stages.length; i++) {
      final prev = stages[i - 1];
      if (prev.isComplete && !stages[i].unlocked) {
        stages[i] = stages[i].copyWith(unlocked: true);
        changed = true;
      }
    }
    if (changed) {
      state = state.copyWith(stages: () => stages);
    }
  }

  bool isStageUnlocked(String stageId) {
    final idx = state.stages.indexWhere((s) => s.id == stageId);
    if (idx <= 0) return true;
    return state.stages[idx].unlocked;
  }

  Future<void> recordDonation({
    required double amount,
    required String method,
  }) async {
    if (amount <= 0) return;
    final previousDonated = state.totalDonated;
    state = state.copyWith(
      totalDonated: state.totalDonated + amount,
      isSupporter: true,
    );

    try {
      await ref
          .read(economicFunctionsServiceProvider)
          .recordDonation(amount: amount, method: method);
      _save();
    } catch (e) {
      state = state.copyWith(
        totalDonated: previousDonated,
        isSupporter: previousDonated > 0,
      );
      AppLogger().warning('recordDonation server call failed, reverted: $e');
    }
  }

  Future<void> addXp(int amount, {String? reason, String? lessonId}) async {
    if (amount <= 0) return;
    final previousXp = state.xp;
    final previousTotalXp = state.totalXpEarned;
    final previousLevel = state.currentLevel;
    final newXp = state.xp + amount;
    final newTotalXp = (state.totalXpEarned + amount).clamp(0, 1000000);
    final newLevel = (newTotalXp / 100).floor() + 1;
    final didLevelUp = newLevel > state.currentLevel;
    state = state.copyWith(
      xp: didLevelUp ? newTotalXp - (newLevel - 1) * 100 : newXp,
      totalXpEarned: newTotalXp,
      currentLevel: didLevelUp ? newLevel : state.currentLevel,
    );
    if (didLevelUp && !_disposed) _levelUpController.add(newLevel);

    try {
      // Server-authoritative: amount is ignored server-side, reward based on reason.
      // Apply the server-reported totals/level so local state matches the
      // server exactly (NUEVO-10).
      final result = await ref
          .read(economicFunctionsServiceProvider)
          .addXp(reason: reason ?? 'lesson_reward', lessonId: lessonId);
      final serverTotalXp = (result?['totalXp'] as num?)?.toInt();
      final serverLevel = (result?['level'] as num?)?.toInt();
      if (result?['duplicate'] != true &&
          serverTotalXp != null &&
          serverLevel != null) {
        final progressInLevel = serverTotalXp - (serverLevel - 1) * 100;
        state = state.copyWith(
          totalXpEarned: serverTotalXp,
          currentLevel: serverLevel,
          xp: progressInLevel < 0 ? 0 : progressInLevel,
        );
      }
      _repo.saveXp(state.xp);
      _repo.saveTotalXp(state.totalXpEarned);
      _repo.saveLevel(state.currentLevel);
    } catch (e) {
      state = state.copyWith(
        xp: previousXp,
        totalXpEarned: previousTotalXp,
        currentLevel: previousLevel,
      );
      AppLogger().warning('addXp server call failed, reverted: $e');
    }
  }

  /// Applies XP already credited server-side (e.g. daily chest).
  /// Updates local state and repo only; does NOT call the server,
  /// preventing double-crediting rewards already granted by a callable.
  void applyServerXp(int amount) {
    if (amount <= 0) return;
    final newTotalXp = (state.totalXpEarned + amount).clamp(0, 1000000);
    final newLevel = (newTotalXp / 100).floor() + 1;
    final didLevelUp = newLevel > state.currentLevel;
    final newXp = didLevelUp
        ? newTotalXp - (newLevel - 1) * 100
        : state.xp + amount;
    state = state.copyWith(
      xp: newXp,
      totalXpEarned: newTotalXp,
      currentLevel: didLevelUp ? newLevel : state.currentLevel,
    );
    if (didLevelUp && !_disposed) _levelUpController.add(newLevel);
    _repo.saveXp(state.xp);
    _repo.saveTotalXp(state.totalXpEarned);
    _repo.saveLevel(state.currentLevel);
  }

  void unlockAchievement(String name) {
    if (state.achievements.contains(name)) return;
    state = state.copyWith(achievements: () => [...state.achievements, name]);
    _save();
  }

  void recordSageTalk() {
    final newCount = state.sageTalks + 1;
    state = state.copyWith(sageTalks: newCount);
    if (newCount >= 10) {
      ref.read(achievementProvider.notifier).unlockAchievement('sage_talk');
    }
    _save();
  }

  Future<void> reload() async {
    try {
      await _load();
      state = state.copyWith(errorMessage: () => null);
    } catch (e) {
      state = state.copyWith(
        errorMessage: () => 'Could not reload your progress. Please try again.',
      );
    }
  }
}
