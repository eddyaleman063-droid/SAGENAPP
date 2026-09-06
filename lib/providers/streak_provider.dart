import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../utils/map_utils.dart';
import '../services/emotion_event_bus.dart';

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

  void _syncStreakToFirestore({
    bool freezeUsed = false,
    int? oldStreak,
    int? milestone,
    bool persistDailyBonus = false,
    bool checkIn = true,
    String? itemUsed,
    int? fallbackStreak,
  }) {
    try {
      // Sync streak to server via Cloud Function (not just local cache).
      // Fire-and-forget with bounded retry + backoff so a transient network
      // failure does not silently diverge the server streak (NUEVO-09).
      Future<void>.delayed(Duration.zero, () async {
        for (int attempt = 0; attempt < 3; attempt++) {
          try {
            final result = await ref
                .read(economicFunctionsServiceProvider)
                .incrementStreak(
                  freezeUsed: freezeUsed,
                  checkIn: checkIn,
                  itemUsed: itemUsed,
                );
            if (result != null) {
              _reconcileServerStreak(result);
              // NUEVO-fix (H1): only a real check-in may grant deferred
              // gems / roll the streak chest. A read-only sync (checkIn:false,
              // e.g. reload/login) reconciles ledgers but must never credit.
              if (!checkIn) return;
              final serverStreak = (result['currentStreak'] as num?)?.toInt();
              final itemConsumed =
                  itemUsed != null && result['itemConsumed'] == true;
              // Las gemas de milestone/bono diario dependen de la racha del
              // servidor: se persisten SOLO tras confirmar el incremento para
              // que earnGems lea la racha nueva y acredite el valor correcto
              // (si se enviaran antes, leerían la racha vieja y quedarían
              // gemas fantasma locales sin acreditación real).
              if (serverStreak != null && serverStreak > (oldStreak ?? 0)) {
                final gemNotifier = ref.read(gemProvider.notifier);
                gemNotifier
                    .persistDeferredStreakEarn(
                      'streak_milestone',
                      dayStreak: serverStreak,
                      milestone: milestone,
                    )
                    .catchError((Object e) {
                      AppLogger().warning(
                        'StreakNotifier: deferred milestone gem persist failed: $e',
                      );
                    });
                if (persistDailyBonus) {
                  gemNotifier
                      .persistDeferredStreakEarn(
                        'daily_bonus',
                        dayStreak: serverStreak,
                      )
                      .catchError((Object e) {
                        AppLogger().warning(
                          'StreakNotifier: deferred daily bonus persist failed: $e',
                        );
                      });
                }
                if (oldStreak != null) {
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
              // NUEVO-fix (H5): el servidor consumió el ítem declarado (lo
              // validó y lo decrementó en el inventario). El cliente refleja
              // el consumo local para mantener el inventario sincronizado y
              // persiste el bono diario del día protegido usando la racha ya
              // confirmada (única persistencia en este camino:
              // persistDailyBonus es false aquí).
              if (itemConsumed && serverStreak != null && serverStreak > 0) {
                final itemNotifier = ref.read(itemProvider.notifier);
                if (itemUsed == 'titaniumShield') {
                  itemNotifier.useTitaniumShield();
                } else if (itemUsed == 'phoenixFeather') {
                  itemNotifier.usePhoenixFeather();
                }
                final gemNotifier = ref.read(gemProvider.notifier);
                gemNotifier.awardDailyBonus(serverStreak);
                gemNotifier
                    .persistDeferredStreakEarn(
                      'daily_bonus',
                      dayStreak: serverStreak,
                    )
                    .catchError((Object e) {
                      AppLogger().warning(
                        'StreakNotifier: item-protected daily bonus persist failed: $e',
                      );
                    });
              }
            }
            return;
          } catch (e) {
            if (attempt == 2) {
              AppLogger().warning(
                'StreakNotifier: server streak sync failed after retries: $e',
              );
              // NUEVO-fix (H5): si el sync del día protegido falla del todo
              // (offline), se conserva la protección optimista local para que
              // el ítem mantenga su efecto hasta el próximo reconcile con el
              // servidor (que lo corregirá si difiere).
              if (itemUsed != null && fallbackStreak != null) {
                final current = state.status;
                if (current.currentStreak < fallbackStreak) {
                  final fb = StreakStatus(
                    currentStreak: fallbackStreak,
                    longestStreak: current.longestStreak > fallbackStreak
                        ? current.longestStreak
                        : fallbackStreak,
                    lastActivityDate: current.lastActivityDate,
                    streakFreezes: current.streakFreezes,
                    isAtRisk: current.isAtRisk,
                    message: current.message,
                    tier: current.tier,
                  );
                  state = state.copyWith(status: fb);
                  _service.saveStreak(
                    currentStreak: fb.currentStreak,
                    longestStreak: fb.longestStreak,
                    lastActivityDate: fb.lastActivityDate,
                    streakFreezes: fb.streakFreezes,
                  );
                  _saveExtras(ref.read(storageServiceProvider));
                }
              }
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
      final oldStreak = current.currentStreak;
      final serverDiverged =
          serverStreak != current.currentStreak ||
          serverLongest != current.longestStreak;
      final serverBroke =
          result['streakBroken'] == true || result['freezeDenied'] == true;
      // NUEVO-fix: read-back de escudos reales del servidor. El cliente refleja
      // su contador local (streak_freezes) con los shields que el servidor
      // realmente posee (streak_shields + shop_streak_shields), vía
      // shieldsRemaining. Corrige la divergencia de "ledgers" (escudos
      // fantasma locales, o escudos del servidor nunca reflejados en el
      // cliente).
      final serverShields = (result['shieldsRemaining'] as num?)?.toInt();
      final shieldsChanged =
          serverShields != null && serverShields != current.streakFreezes;

      if (!serverDiverged && !serverBroke && !shieldsChanged) return;

      // Si el servidor rompió explícitamente la racha o denegó un freez (0
      // escudos) es la fuente de verdad más baja y se hace caso. En cambio, si
      // solo hubo divergencia (p. ej. syncs previos fallaron y el servidor
      // quedó por detrás), se conserva el MÁXIMO: los días ya ganados en local
      // por check-ins válidos no deben regresarse por un intento de sync
      // fallido. (NUEVO-fix: evitaba perder rachas legítimas ante divergencias
      // temporales.)
      final int newCurrentStreak;
      final int newLongestStreak;
      if (serverBroke) {
        newCurrentStreak = serverStreak;
        newLongestStreak = serverLongest ?? current.longestStreak;
      } else {
        newCurrentStreak = serverStreak > current.currentStreak
            ? serverStreak
            : current.currentStreak;
        newLongestStreak =
            (serverLongest ?? current.longestStreak) > current.longestStreak
            ? (serverLongest ?? current.longestStreak)
            : current.longestStreak;
      }

      // NUEVO-fix: los escudos locales se reconcilian con los realmente
      // poseídos en el servidor (shieldsRemaining). Si el servidor aún no
      // envía el campo (versión vieja) y denegó un freez, se repone 1 escudo
      // al cliente para no perderlo sin efecto protector (compatibilidad con
      // contratos previos).
      final freezeDenied = result['freezeDenied'] == true;
      final int newFreezes = serverShields != null
          ? serverShields.clamp(0, 1000)
          : freezeDenied
          ? current.streakFreezes + 1
          : current.streakFreezes;

      final newStatus = StreakStatus(
        currentStreak: newCurrentStreak,
        longestStreak: newLongestStreak,
        lastActivityDate: current.lastActivityDate,
        streakFreezes: newFreezes,
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
      // Una reconciliación al alza desde el servidor puede cruzar umbrales de
      // logros (p.ej. 25 -> 30): se evalúan aquí igual que en checkIn para no
      // perder la celebración de hitos como streak30/shieldCrystal.
      _checkAchievements(oldStreak, newStatus);
    } catch (e) {
      AppLogger().warning('StreakNotifier._reconcileServerStreak failed: $e');
    }
  }

  void _checkAchievements(int oldStreak, StreakStatus newStatus) {
    final a = ref.read(analyticsServiceProvider);
    final profile = ref.read(achievementProvider.notifier);
    if (newStatus.currentStreak >= 1 && oldStreak == 0) {
      a.unlockAchievement(Achievement.shieldBasic);
    }
    if (newStatus.currentStreak >= 3 && oldStreak < 3) {
      a.unlockAchievement(Achievement.streak3);
      profile.unlockAchievement('streak_3');
    }
    if (newStatus.currentStreak >= 7 && oldStreak < 7) {
      a.unlockAchievement(Achievement.shieldGlow);
      a.unlockAchievement(Achievement.streak7);
      a.unlockAchievement(Achievement.perfectWeek);
      profile.unlockAchievement('streak_7');
    }
    if (newStatus.currentStreak >= 30 && oldStreak < 30) {
      a.unlockAchievement(Achievement.shieldCrystal);
      a.unlockAchievement(Achievement.cyberGuardian);
      a.unlockAchievement(Achievement.streak30);
      profile.unlockAchievement('streak_30');
    }
    if (newStatus.currentStreak >= 100 && oldStreak < 100) {
      a.unlockAchievement(Achievement.shieldLegendary);
    }
    if (newStatus.currentStreak >= 14 && oldStreak < 14) {
      a.unlockAchievement(Achievement.streak14);
    }
    if (newStatus.currentStreak >= 100 && oldStreak < 100) {
      a.unlockAchievement(Achievement.streak100);
    }
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

      // Pre-compute diff to determine if protection items are needed.
      // NUEVO-fix (H5): el cliente solo DECLARA la intención (itemUsed); la
      // protección la DECIDE el servidor (valida el inventario y consume el
      // ítem en la misma transacción). Solo se declara cuando no hay freezes
      // locales: los escudos reales protegen primero y un ítem nunca se gasta
      // por un día que ya estaba cubierto.
      bool needsProtection = false;
      String? itemUsed;
      if (oldStreak > 0 && lastDate != null) {
        final diff = _utcDayDiff(lastDate, DateTime.now());
        if (diff >= 2) {
          needsProtection = true;
          if (streakFreezes <= 0) {
            if (items.hasTitaniumShield()) {
              itemUsed = 'titaniumShield';
            } else if (items.hasPhoenixFeather()) {
              itemUsed = 'phoenixFeather';
            }
          }
        }
      }

      final newStatus = _service.checkIn();

      // NUEVO-fix (H5): día perdido protegido por un ítem premium. Se aplica
      // una protección OPTIMISTA (que el próximo reconcile corrige si el
      // servidor la niega) y el sync declara itemUsed para que el servidor
      // decida. Se elimina el consumo/inyección local: eran descartados por el
      // servidor y gastaban el ítem sin efecto.
      if (needsProtection && itemUsed != null) {
        final now = DateTime.now();
        final StreakStatus protectedStatus;
        if (itemUsed == 'titaniumShield') {
          protectedStatus = StreakStatus(
            currentStreak: oldStreak + 1,
            longestStreak: (newStatus.longestStreak > oldStreak + 1
                ? newStatus.longestStreak
                : oldStreak + 1),
            lastActivityDate: now,
            streakFreezes: newStatus.streakFreezes,
            isAtRisk: false,
            message: '',
            tier: newStatus.tier,
          );
        } else {
          protectedStatus = StreakStatus(
            currentStreak: oldStreak,
            longestStreak: newStatus.longestStreak,
            lastActivityDate: now,
            streakFreezes: newStatus.streakFreezes,
            isAtRisk: false,
            message: '',
            tier: newStatus.tier,
          );
        }
        state = state.copyWith(status: protectedStatus);
        _service.saveStreak(
          currentStreak: protectedStatus.currentStreak,
          longestStreak: protectedStatus.longestStreak,
          lastActivityDate: now,
          streakFreezes: protectedStatus.streakFreezes,
        );
        _saveExtras(ref.read(storageServiceProvider));
        _checkAchievements(oldStreak, protectedStatus);
        _syncStreakToFirestore(
          freezeUsed: newStatus.freezeConsumed,
          oldStreak: oldStreak,
          itemUsed: itemUsed,
          persistDailyBonus: false,
          fallbackStreak: protectedStatus.currentStreak,
        );
        _scheduleStreakReminder();
        return;
      }

      // Streak was genuinely lost (no phoenix revival) — react accordingly.
      if (oldStreak > 0 && newStatus.currentStreak < oldStreak) {
        ref.read(emotionEventBusProvider).fire(EmotionEventType.streakLost);
      }

      // Solo el primer check-in del día debe inflar las estadísticas.
      final now = DateTime.now();
      final isFirstCheckInToday =
          lastDate == null || _utcDayDiff(lastDate, now) != 0;

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
        ref
            .read(emotionEventBusProvider)
            .fire(EmotionEventType.streakMilestone);
      }

      // El bono diario se concede solo el primer check-in del día local.
      // awardDailyBonus guarda internamente con clave UTC (alineada con el
      // servidor) pero éste manda el día local de la racha; evaluarlo aquí
      // evita duplicar el bono si un segundo check-in cae en otra fecha UTC.
      if (isFirstCheckInToday) {
        ref.read(gemProvider.notifier).awardDailyBonus(newStatus.currentStreak);
      }
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
        milestone: milestone,
        persistDailyBonus: isFirstCheckInToday,
      );
      _scheduleStreakReminder();
    } catch (e, stack) {
      AppLogger().error('streak checkIn failed', e, stack);
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
    // NUEVO-fix (H1): reload/login only reconciles local ledgers with the
    // server (read-only sync). Opening the app never advances the streak,
    // burns a shield or breaks it — only an explicit checkIn() may mutate.
    _syncStreakToFirestore(checkIn: false);
  }
}

/// Diferencia en días calendario UTC entre [from] y [to], alineada con el
/// servidor (economic.incrementStreak parte por día UTC). Evita que las
/// comparaciones "mismo día" usen la medianoche local, que difiere del
/// servidor durante varias horas al día.
int _utcDayDiff(DateTime from, DateTime to) {
  final a = from.toUtc();
  final b = to.toUtc();
  final dayA = DateTime.utc(a.year, a.month, a.day);
  final dayB = DateTime.utc(b.year, b.month, b.day);
  return dayB.difference(dayA).inDays;
}
