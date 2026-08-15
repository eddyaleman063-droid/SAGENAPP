import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../utils/map_utils.dart';

import '../services/analytics_service.dart';
import '../services/app_logger.dart';
import '../services/storage_service.dart';
import '../services/streak_service.dart';
import 'providers.dart';

class StreakState {
  final StreakStatus status;
  final int totalCheckIns;
  final int perfectWeeks;
  final bool missionCompleted;
  final Map<String, int> weeklyStats;
  final Map<String, int> heatmapData;
  final Map<String, int> monthlyData;
  final List<String> streakHistory;
  final List<String> emotionalMessages;
  final int? lastMilestone;
  final Map<String, int>? cachedMonthlyStreakStats;

  static const milestoneValues = [7, 14, 30, 60, 100, 180, 365];

  const StreakState({
    required this.status,
    required this.totalCheckIns,
    required this.perfectWeeks,
    required this.missionCompleted,
    required this.weeklyStats,
    required this.heatmapData,
    required this.monthlyData,
    required this.streakHistory,
    required this.emotionalMessages,
    this.lastMilestone,
    this.cachedMonthlyStreakStats,
  });

  bool get justHitMilestone => lastMilestone != null;
  bool get freezeConsumed => status.freezeConsumed;

  StreakState copyWith({
    StreakStatus? status,
    int? totalCheckIns,
    int? perfectWeeks,
    bool? missionCompleted,
    Map<String, int>? weeklyStats,
    Map<String, int>? heatmapData,
    Map<String, int>? monthlyData,
    List<String>? streakHistory,
    List<String>? emotionalMessages,
    int? Function()? lastMilestone,
    Map<String, int>? cachedMonthlyStreakStats,
  }) {
    return StreakState(
      status: status ?? this.status,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      perfectWeeks: perfectWeeks ?? this.perfectWeeks,
      missionCompleted: missionCompleted ?? this.missionCompleted,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      heatmapData: heatmapData ?? this.heatmapData,
      monthlyData: monthlyData ?? this.monthlyData,
      streakHistory: streakHistory ?? this.streakHistory,
      emotionalMessages: emotionalMessages ?? this.emotionalMessages,
      lastMilestone: lastMilestone != null
          ? lastMilestone()
          : this.lastMilestone,
      cachedMonthlyStreakStats:
          cachedMonthlyStreakStats ?? this.cachedMonthlyStreakStats,
    );
  }

  int get currentStreak => status.currentStreak;
  bool get isStreakFrozen => status.isStreakFrozen;

  double get streakMultiplier {
    if (currentStreak < 10) return 1.0;
    final mult = 1.0 + (currentStreak ~/ 10) * 0.1;
    return mult.clamp(1.0, 2.0);
  }
}

class StreakNotifier extends Notifier<StreakState> {
  late StreakService _service;

  static const _missions = [
    'Learn what phishing is',
    'Enable two-factor authentication',
    'Review your passwords',
    'Identify a suspicious link',
    'Learn about secure WiFi networks',
    'Create a strong password',
    'Recognize a fraudulent email',
  ];

  static const _emotionalQuotes = [
    'Your security improves every day.',
    '7 days protecting your digital identity.',
    'Every day counts for your protection.',
    'You are building a secure digital habit.',
    'Your shield grows stronger day by day.',
    'Consistency is your best defense.',
    'Keep going. Today\'s effort protects your tomorrow.',
  ];

  static const _keyTotalCheckIns = 'streak_total_checkins';
  static const _keyPerfectWeeks = 'streak_perfect_weeks';
  static const _keyHistory = 'streak_history';
  static const _keyWeeklyStats = 'streak_weekly_stats';
  static const _keyHeatmap = 'streak_heatmap';
  static const _keyMonthlyData = 'streak_monthly_data';

  @override
  StreakState build() {
    _service = ref.watch(streakServiceProvider);
    final status = _service.load();
    return _loadState(status, ref.watch(storageServiceProvider));
  }

  StreakState _loadState(StreakStatus status, StorageService storage) {
    final totalCheckIns = storage.getInt(_keyTotalCheckIns).clamp(0, 100000);
    final perfectWeeks = storage.getInt(_keyPerfectWeeks).clamp(0, 1000);
    final raw = storage.getString(_keyHistory);
    final streakHistory = raw.isNotEmpty
        ? raw.split(',').where((s) => s.isNotEmpty).toList()
        : <String>[];
    final ws = storage.getString(_keyWeeklyStats);
    final weeklyStats = ws.isNotEmpty ? parseStringMap(ws) : <String, int>{};
    final hm = storage.getString(_keyHeatmap);
    final heatmapData = hm.isNotEmpty ? parseStringMap(hm) : <String, int>{};
    if (heatmapData.length > 365) {
      final keys = heatmapData.keys.toList()..sort();
      final excess = heatmapData.length - 365;
      for (int i = 0; i < excess; i++) {
        heatmapData.remove(keys[i]);
      }
    }
    final md = storage.getString(_keyMonthlyData);
    final monthlyData = md.isNotEmpty ? parseStringMap(md) : <String, int>{};
    final emotionalMessages = _computeEmotionalMessages(status);
    return StreakState(
      status: status,
      totalCheckIns: totalCheckIns,
      perfectWeeks: perfectWeeks,
      missionCompleted: false,
      weeklyStats: weeklyStats,
      heatmapData: heatmapData,
      monthlyData: monthlyData,
      streakHistory: streakHistory,
      emotionalMessages: emotionalMessages,
    );
  }

  List<String> _computeEmotionalMessages(StreakStatus status) {
    final msgs = <String>[];
    if (status.currentStreak >= 100) {
      msgs.add('100 days of constant protection. Legend.');
    } else if (status.currentStreak >= 50) {
      msgs.add('50 days of constant digital protection.');
    } else if (status.currentStreak >= 30) {
      msgs.add(
        'One month of learning. Your dedication makes you a Digital Guardian.',
      );
    } else if (status.currentStreak >= 14) {
      msgs.add('Two weeks of consistency. Your shield shines.');
    } else if (status.currentStreak >= 7) {
      msgs.add('One week protecting your digital identity. Keep it up!');
    } else if (status.currentStreak >= 3) {
      msgs.add('3 days in a row. You are building a solid habit.');
    }
    if (msgs.isEmpty && status.currentStreak > 0) {
      msgs.addAll(_emotionalQuotes.take(2));
    }
    return msgs;
  }

  void _saveExtras(StorageService storage) {
    final s = state;
    storage.setInt(_keyTotalCheckIns, s.totalCheckIns);
    storage.setInt(_keyPerfectWeeks, s.perfectWeeks);
    storage.setString(_keyHistory, s.streakHistory.join(','));
    storage.setString(_keyWeeklyStats, encodeStringMap(s.weeklyStats));
    storage.setString(_keyHeatmap, encodeStringMap(s.heatmapData));
    storage.setString(_keyMonthlyData, encodeStringMap(s.monthlyData));
  }

  void _syncStreakToFirestore({bool freezeUsed = false, int? oldStreak}) {
    try {
      // Sync streak to server via Cloud Function (not just local cache).
      // Fire-and-forget with bounded retry + backoff so a transient network
      // failure does not silently diverge the server streak (NUEVO-09).
      Future<void>.delayed(Duration.zero, () async {
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            final result = await ref
                .read(economicFunctionsServiceProvider)
                .incrementStreak(freezeUsed: freezeUsed);
            // NUEVO-fix: the server streak is authoritative. The streak chest
            // must be rolled only AFTER the server confirms the increment,
            // otherwise rollChestDrop derives a bronze tier from the stale
            // server streak. oldStreak is passed so we only reward when a
            // milestone was actually crossed.
            if (result != null) {
              _reconcileServerStreak(result);
              if (oldStreak != null) {
                final serverStreak = (result['currentStreak'] as num?)?.toInt();
                if (serverStreak != null && serverStreak > oldStreak) {
                  ref
                      .read(streakChestServiceProvider)
                      .checkAndReward(
                        oldStreak: oldStreak,
                        newStreak: serverStreak,
                        learning: ref.read(learningProvider.notifier),
                      )
                      .catchError((e) {
                        AppLogger().error('streak chest reward failed: $e');
                      });
                }
              }
            }
            return;
          } catch (e) {
            if (attempt == 2) {
              AppLogger().warning(
                'StreakNotifier: server streak sync failed after retries: $e',
              );
              return;
            }
            final base = const Duration(seconds: 1) * (attempt + 1);
            await Future.delayed(base);
          }
        }
      });
    } catch (e) {
      AppLogger().warning('StreakNotifier._syncStreakToFirestore failed: $e');
    }
  }

  /// NUEVO-fix: reconcile the local streak with the authoritative server
  /// state returned by `incrementStreak`. When the server denies a freeze,
  /// breaks the streak, or reports a different streak (e.g. another device),
  /// the client no longer keeps a divergent optimistic streak.
  void _reconcileServerStreak(Map<String, dynamic> result) {
    try {
      final serverStreak = (result['currentStreak'] as num?)?.toInt();
      final serverLongest = (result['longestStreak'] as num?)?.toInt();
      if (serverStreak == null) return;

      final current = state.status;
      final serverDiverged =
          serverStreak != current.currentStreak ||
          serverLongest != current.longestStreak;
      final serverBroke =
          result['streakBroken'] == true || result['freezeDenied'] == true;

      if (!serverDiverged && !serverBroke) return;

      final newStatus = StreakStatus(
        currentStreak: serverStreak,
        longestStreak: serverLongest ?? current.longestStreak,
        lastActivityDate: current.lastActivityDate,
        streakFreezes: current.streakFreezes,
        isAtRisk: current.isAtRisk,
        message: current.message,
        tier: current.tier,
      );
      state = state.copyWith(status: newStatus);
      _service.saveStreak(
        currentStreak: newStatus.currentStreak,
        longestStreak: newStatus.longestStreak,
        lastActivityDate: newStatus.lastActivityDate,
        streakFreezes: newStatus.streakFreezes,
      );
      _saveExtras(ref.read(storageServiceProvider));
    } catch (e) {
      AppLogger().warning('StreakNotifier._reconcileServerStreak failed: $e');
    }
  }

  void _checkAchievements(int oldStreak, StreakStatus newStatus) {
    final a = ref.read(analyticsServiceProvider);
    if (newStatus.currentStreak >= 1 && oldStreak == 0) {
      a.unlockAchievement(Achievement.shieldBasic);
    }
    if (newStatus.currentStreak >= 7 && oldStreak < 7) {
      a.unlockAchievement(Achievement.shieldGlow);
    }
    if (newStatus.currentStreak >= 30 && oldStreak < 30) {
      a.unlockAchievement(Achievement.shieldCrystal);
      a.unlockAchievement(Achievement.cyberGuardian);
    }
    if (newStatus.currentStreak >= 100 && oldStreak < 100) {
      a.unlockAchievement(Achievement.shieldLegendary);
    }
    if (newStatus.currentStreak == 7) {
      a.unlockAchievement(Achievement.streak7);
      a.unlockAchievement(Achievement.perfectWeek);
    }
    if (newStatus.currentStreak == 14) {
      a.unlockAchievement(Achievement.streak14);
    }
    if (newStatus.currentStreak == 30) {
      a.unlockAchievement(Achievement.streak30);
    }
    if (newStatus.currentStreak == 100) {
      a.unlockAchievement(Achievement.streak100);
    }
    if (newStatus.currentStreak == 3) a.unlockAchievement(Achievement.streak3);
  }

  int _isoWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays + 1;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }

  // -- Public API: Getters --

  StreakStatus get status => state.status;
  int get currentStreak => state.status.currentStreak;
  int get longestStreak => state.status.longestStreak;
  DateTime? get lastActivityDate => state.status.lastActivityDate;
  int get streakFreezes => state.status.streakFreezes;
  bool get isAtRisk => state.status.isAtRisk;
  String get message => state.status.message;
  String get tier => state.status.tier;
  String get shieldTier => state.status.tier;
  bool get hasStreak => state.status.hasStreak;
  bool get isStreakFrozen => state.status.isStreakFrozen;

  int get totalCheckIns => state.totalCheckIns;
  int get perfectWeeks => state.perfectWeeks;
  bool get missionCompleted => state.missionCompleted;
  Map<String, int> get weeklyStats => Map.unmodifiable(state.weeklyStats);
  Map<String, int> get heatmapData => Map.unmodifiable(state.heatmapData);
  Map<String, int> get monthlyStats => Map.unmodifiable(state.monthlyData);
  List<String> get streakHistory => List.unmodifiable(state.streakHistory);
  List<String> get emotionalMessages =>
      List.unmodifiable(state.emotionalMessages);

  String get currentMission => _missions[DateTime.now().day % _missions.length];

  Map<String, int> get monthlyStreakStats {
    final cached = state.cachedMonthlyStreakStats;
    if (cached != null) return cached;
    final now = DateTime.now();
    final stats = <String, int>{};
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      stats[key] = state.monthlyData[key] ?? 0;
    }
    // Cache the result without side effects — cache is set on next state update
    return stats;
  }

  /// Call after building to cache monthly stats (avoids getter side effect)
  void cacheMonthlyStats() {
    if (state.cachedMonthlyStreakStats != null) return;
    state = state.copyWith(cachedMonthlyStreakStats: monthlyStreakStats);
  }

  String shieldTierName(AppLocalizations l) {
    switch (tier) {
      case 'legendary':
        return l.shieldTierLegendary;
      case 'crystal':
        return l.shieldTierCrystal;
      case 'particles':
        return l.shieldTierParticles;
      case 'glow':
        return l.shieldTierGlow;
      case 'basic':
        return l.shieldTierBasic;
      default:
        return l.shieldTierInactive;
    }
  }

  // -- Public API: Mutations --

  void completeMission() {
    if (state.missionCompleted) return;
    state = state.copyWith(missionCompleted: true);
  }

  static const _keyJustDefrosted = 'streak_just_defrosted';

  void checkIn() {
    try {
      final wasFrozen = state.isStreakFrozen;
      final oldStreak = state.status.currentStreak;
      final lastDate = state.status.lastActivityDate;

      final items = ref.read(itemProvider.notifier);

      // Pre-compute diff to determine if protection items are needed
      bool needsProtection = false;
      bool usePhoenixFeather = false;
      if (oldStreak > 0 && lastDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
        final diff = today.difference(last).inDays;
        if (diff >= 2) {
          needsProtection = true;
          // Phoenix Feather revives streak if no freeze available
          if (!items.hasTitaniumShield() && items.hasPhoenixFeather()) {
            usePhoenixFeather = true;
          }
        }
      }

      // Inject a freeze if Titanium Shield should protect
      if (needsProtection && items.hasTitaniumShield()) {
        items.useTitaniumShield();
        final currentFreezes = streakFreezes;
        final maxFreezes = ref
            .read(remoteConfigServiceProvider)
            .streakMaxFreezes;
        if (currentFreezes < maxFreezes) {
          setFreezes(currentFreezes + 1);
        }
      }

      final newStatus = _service.checkIn();

      // Phoenix Feather: revive streak if it would have been lost
      if (usePhoenixFeather &&
          newStatus.currentStreak < oldStreak &&
          oldStreak > 0) {
        items.usePhoenixFeather();
        final revivedStatus = StreakStatus(
          currentStreak: oldStreak,
          longestStreak: newStatus.longestStreak,
          lastActivityDate: DateTime.now(),
          streakFreezes: newStatus.streakFreezes,
          isAtRisk: false,
          message: 'Your Phoenix Feather revived your streak!',
          tier: newStatus.tier,
        );
        state = state.copyWith(status: revivedStatus);
        // Persist the corrected streak to SharedPreferences
        _service.saveStreak(
          currentStreak: oldStreak,
          longestStreak: revivedStatus.longestStreak,
          lastActivityDate: DateTime.now(),
          streakFreezes: newStatus.streakFreezes,
        );
        _saveExtras(ref.read(storageServiceProvider));
        _syncStreakToFirestore();
        _scheduleStreakReminder();
        return;
      }

      // Solo el primer check-in del día debe inflar las estadísticas.
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isFirstCheckInToday =
          lastDate == null ||
          DateTime(lastDate.year, lastDate.month, lastDate.day) != today;

      final newTotalCheckIns = isFirstCheckInToday
          ? state.totalCheckIns + 1
          : state.totalCheckIns;

      final weekKey = '${now.year}-W${_isoWeekNumber(now)}';
      final newWeeklyStats = Map<String, int>.from(state.weeklyStats);
      if (isFirstCheckInToday) {
        newWeeklyStats[weekKey] = (newWeeklyStats[weekKey] ?? 0) + 1;
      }

      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final newMonthlyData = Map<String, int>.from(state.monthlyData);
      if (isFirstCheckInToday) {
        newMonthlyData[monthKey] = (newMonthlyData[monthKey] ?? 0) + 1;
      }

      final heatmapKey = now.toIso8601String().substring(0, 10);
      final newHeatmap = Map<String, int>.from(state.heatmapData);
      if (isFirstCheckInToday) {
        newHeatmap[heatmapKey] = (newHeatmap[heatmapKey] ?? 0) + 1;
      }
      if (newHeatmap.length > 365) {
        final keys = newHeatmap.keys.toList()..sort();
        final toRemove = newHeatmap.length - 365;
        for (int i = 0; i < toRemove; i++) {
          newHeatmap.remove(keys[i]);
        }
      }

      _checkAchievements(oldStreak, newStatus);
      AnalyticsService.instance.track(
        AnalyticEvent.streakCheckIn,
        properties: {'streak': newStatus.currentStreak.toString()},
      );

      final newEmotions = _computeEmotionalMessages(newStatus);

      final newPerfectWeeks =
          (isFirstCheckInToday &&
              newStatus.currentStreak > 0 &&
              newStatus.currentStreak % 7 == 0)
          ? state.perfectWeeks + 1
          : state.perfectWeeks;

      final int? milestone =
          StreakState.milestoneValues
              .where((m) => oldStreak < m && newStatus.currentStreak >= m)
              .isEmpty
          ? null
          : StreakState.milestoneValues
                .where((m) => oldStreak < m && newStatus.currentStreak >= m)
                .first;

      state = state.copyWith(
        status: newStatus,
        totalCheckIns: newTotalCheckIns,
        perfectWeeks: newPerfectWeeks,
        weeklyStats: newWeeklyStats,
        monthlyData: newMonthlyData,
        heatmapData: newHeatmap,
        emotionalMessages: newEmotions,
        lastMilestone: () => milestone,
        cachedMonthlyStreakStats: null,
      );

      if (milestone != null) {
        ref.read(gemProvider.notifier).awardStreakMilestone(milestone);
      }

      ref.read(gemProvider.notifier).awardDailyBonus(newStatus.currentStreak);

      final storage = ref.read(storageServiceProvider);
      if (wasFrozen && !newStatus.isStreakFrozen) {
        storage.setBool(_keyJustDefrosted, true);
      }
      if (newStatus.freezeConsumed) {
        ref
            .read(notificationServiceProvider)
            .showFreezeConsumedNotification(newStatus.streakFreezes);
      }
      _saveExtras(storage);
      _syncStreakToFirestore(
        freezeUsed: newStatus.freezeConsumed,
        oldStreak: oldStreak,
      );
      _scheduleStreakReminder();
    } catch (e) {
      AppLogger().error('streak checkIn failed: $e');
    }
  }

  void _scheduleStreakReminder() {
    ref
        .read(notificationServiceProvider)
        .scheduleStreakReminder(state.status.currentStreak);
  }

  void clearMilestone() {
    state = state.copyWith(lastMilestone: () => null);
  }

  void setFreezes(int count) {
    final current = state.status;
    final maxFreezes = ref.read(remoteConfigServiceProvider).streakMaxFreezes;
    final clamped = count.clamp(0, maxFreezes);
    final newStatus = StreakStatus(
      currentStreak: current.currentStreak,
      longestStreak: current.longestStreak,
      lastActivityDate: current.lastActivityDate,
      streakFreezes: clamped,
      isAtRisk: current.isAtRisk,
      message: current.message,
      tier: current.tier,
    );
    state = state.copyWith(status: newStatus);
    _service.saveFreezes(clamped);
    _saveExtras(ref.read(storageServiceProvider));
  }

  void reload() {
    final newStatus = _service.load();
    state = state.copyWith(status: newStatus);
    _syncStreakToFirestore();
  }
}
