import 'dart:async';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/gem_repository.dart';
import '../services/app_logger.dart';
import '../utils/map_utils.dart';
import 'providers.dart';

/// Result of a server-authoritative shop purchase.
enum ShopPurchaseResult { success, owned, failure }

class GemState {
  final int balance;
  final int totalEarned;
  final int totalSpent;

  const GemState({this.balance = 0, this.totalEarned = 0, this.totalSpent = 0});

  GemState copyWith({int? balance, int? totalEarned, int? totalSpent}) {
    return GemState(
      balance: balance ?? this.balance,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
    );
  }
}

class GemNotifier extends Notifier<GemState> {
  late final GemRepository _repo;

  /// Broadcast stream that emits gem amounts when earned.
  /// Listeners (e.g. root widget) can show reward animations.
  final _rewardController = StreamController<int>.broadcast();
  Stream<int> get onGemsEarned => _rewardController.stream;

  /// Broadcast stream that emits gem milestone thresholds when reached.
  final _milestoneController = StreamController<int>.broadcast();
  Stream<int> get onGemMilestone => _milestoneController.stream;

  /// Milestones: when totalEarned crosses these thresholds, celebrate.
  static const gemMilestones = [100, 500, 1000, 5000, 10000];

  @override
  GemState build() {
    _repo = ref.read(gemRepositoryProvider);
    return _load();
  }

  GemState _load() {
    return GemState(
      balance: _repo.balance,
      totalEarned: _repo.totalEarned,
      totalSpent: _repo.totalSpent,
    );
  }

  void addGems(int amount, {String? reason}) {
    if (amount <= 0) return;
    final prevEarned = _repo.totalEarned;
    _repo.addGems(amount);
    _repo.save();
    state = _load();
    _rewardController.add(amount);
    _checkMilestones(prevEarned, state.totalEarned);
  }

  void _checkMilestones(int prevEarned, int newEarned) {
    for (final m in gemMilestones) {
      if (prevEarned < m && newEarned >= m) {
        _milestoneController.add(m);
      }
    }
  }

  bool spendGems(int amount, {String? reason}) {
    final success = _repo.spendGems(amount);
    if (success) {
      _repo.save();
      state = _load();
    }
    return success;
  }

  /// Server-authoritative shop purchase. The Cloud Function decides the cost
  /// from its own catalog (client amounts are ignored) and deducts atomically.
  /// Returns the outcome: success, already-owned (one-time item) or failure.
  /// Reconciles the local cached balance with the server balance.
  Future<ShopPurchaseResult> spendShopGems(String itemId) async {
    try {
      // Unique idempotency key per purchase attempt (NUEVO-01): a constant
      // key like 'shop_$itemId' would make every later purchase a free
      // "duplicate". A fresh key makes each consumable re-purchase a real
      // charge while keeping the transaction_logs retry-safe.
      final key =
          'shop_${itemId}_${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
      final result = await FirebaseFunctions.instance
          .httpsCallable('spendGems')
          .call({'itemId': itemId, 'idempotencyKey': key})
          .timeout(const Duration(seconds: 10));
      final data = result.data as Map<String, dynamic>;
      final serverBalance = (data['balance'] as num?)?.toInt();
      if (serverBalance != null) syncBalance(serverBalance);
      if (data['owned'] == true) return ShopPurchaseResult.owned;
      return (data['success'] == true || data['duplicate'] == true)
          ? ShopPurchaseResult.success
          : ShopPurchaseResult.failure;
    } catch (e) {
      AppLogger().error('GemProvider.spendShopGems failed', e);
      return ShopPurchaseResult.failure;
    }
  }

  /// Reconciles the cached balance with the authoritative server balance.
  void syncBalance(int serverBalance) {
    if (serverBalance < 0) return;
    _repo.setBalance(serverBalance);
    _repo.save();
    state = _load();
  }

  /// Fetches the authoritative gem balance from the server (getGemsBalance)
  /// and reconciles the local cache. The local ledger is optimistic-only;
  /// the server is the single source of truth (NUEVO-03).
  /// Also retries any pending offline gem earn persistence before syncing.
  Future<void> syncBalanceFromServer() async {
    await _retryPendingEarns();
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('getGemsBalance')
          .call()
          .timeout(const Duration(seconds: 10));
      final data = result.data as Map<String, dynamic>;
      final serverBalance = (data['balance'] as num?)?.toInt();
      if (serverBalance != null) syncBalance(serverBalance);
    } catch (e) {
      AppLogger().warning(
        'GemNotifier: failed to sync balance from server: $e',
      );
    }
  }

  static const _keyPendingEarns = 'gems_pending_earn_queue';
  static const _maxPendingEarns = 50;

  /// Persists a local-only gem award to the authoritative server ledger via
  /// earnGems, then reconciles the cache with the server's balance. The local
  /// credit stays optimistic; the server decides the real amount (caps apply).
  /// On failure, queues the earn for later retry so gems are never lost.
  Future<void> _persistEarnToServer(
    String reason,
    Map<String, dynamic> meta,
  ) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('earnGems')
          .call({'reason': reason, 'meta': meta})
          .timeout(const Duration(seconds: 10));
      final data = result.data as Map<String, dynamic>;
      final serverBalance = (data['balance'] as num?)?.toInt();
      if (serverBalance != null) syncBalance(serverBalance);
    } catch (e) {
      // Offline or server error: queue for retry so gems are never lost.
      _enqueuePendingEarn(reason, meta);
      AppLogger().warning('GemNotifier: earnGems($reason) queued for retry');
    }
  }

  void _enqueuePendingEarn(String reason, Map<String, dynamic> meta) {
    try {
      final prefs = ref.read(prefsProvider);
      final raw = prefs.getStringList(_keyPendingEarns) ?? [];
      if (raw.length >= _maxPendingEarns) {
        raw.removeRange(0, raw.length - _maxPendingEarns + 1);
      }
      raw.add(
        '$reason|${DateTime.now().toIso8601String()}|${_encodeMeta(meta)}',
      );
      prefs.setStringList(_keyPendingEarns, raw);
    } catch (e) {
      AppLogger().warning('GemNotifier: failed to enqueue pending earn: $e');
    }
  }

  Future<void> _retryPendingEarns() async {
    try {
      final prefs = ref.read(prefsProvider);
      final raw = prefs.getStringList(_keyPendingEarns);
      if (raw == null || raw.isEmpty) return;
      final remaining = <String>[];
      for (final entry in raw) {
        final parts = entry.split('|');
        if (parts.length < 3) continue;
        final reason = parts[0];
        final meta = _decodeMeta(parts[2]);
        try {
          await FirebaseFunctions.instance
              .httpsCallable('earnGems')
              .call({'reason': reason, 'meta': meta})
              .timeout(const Duration(seconds: 10));
        } catch (e) {
          remaining.add(entry);
        }
      }
      prefs.setStringList(_keyPendingEarns, remaining);
    } catch (e) {
      AppLogger().warning('GemNotifier: retry pending earns failed: $e');
    }
  }

  static String _encodeMeta(Map<String, dynamic> meta) {
    return meta.entries.map((e) => '${e.key}=${e.value}').join(',');
  }

  static Map<String, dynamic> _decodeMeta(String encoded) {
    if (encoded.isEmpty) return const {};
    return Map.fromEntries(
      encoded.split(',').where((e) => e.contains('=')).map((e) {
        final parts = e.split('=');
        return MapEntry(parts[0], parts.sublist(1).join('='));
      }),
    );
  }

  /// Award gems from a lesson based on correct answers.
  /// Base: 5 gems per correct answer. The perfect bonus is a FLAT +20
  /// (awardPerfectLessonBonus), matching the server formula — the base is not
  /// doubled (NUEVO-03).
  void awardLessonGems(int correctAnswers, bool isPerfect) {
    final base = correctAnswers * 5;
    if (base > 0) addGems(base, reason: 'lesson');
  }

  /// Award gems from daily login bonus.
  /// Escalates with streak: day 1-2=5, day 3-6=8, day 7-13=12, day 14-29=18, day 30+=30
  void awardDailyBonus(int dayStreak) {
    final prefs = ref.read(prefsProvider);
    final today = utcDayKey();
    const lastKey = 'last_daily_bonus_day';
    if (prefs.getString(lastKey) == today) return;
    prefs.setString(lastKey, today);
    const thresholds = {30: 30, 14: 18, 7: 12, 3: 8};
    final gems =
        thresholds.entries
            .where((e) => dayStreak >= e.key)
            .map((e) => e.value)
            .firstOrNull ??
        5;
    addGems(gems, reason: 'daily_bonus');
    _persistEarnToServer('daily_bonus', {'dayStreak': dayStreak});
  }

  /// Award gems from achievement unlock.
  /// Scales with achievement XP: xpReward / 4, clamped 2-30.
  /// Uses floor() to match the server-authoritative formula (gems.js):
  /// floor(xp / 4) — a modified client cannot get more gems than the server
  /// will credit on reconciliation.
  void awardAchievementGems(int xpReward) {
    final gems = (xpReward / 4).floor().clamp(2, 30);
    addGems(gems, reason: 'achievement');
    _persistEarnToServer('achievement', {'xp': xpReward});
  }

  /// Award gems for completing a perfect lesson (all correct).
  /// Bonus 20 gems on top of normal lesson gems.
  void awardPerfectLessonBonus() {
    addGems(20, reason: 'perfect_lesson');
  }

  /// Award gems for first lesson of the day.
  /// 10 bonus gems once per day.
  void awardFirstLessonOfDay() {
    final prefs = ref.read(prefsProvider);
    final today = utcDayKey();
    const lastKey = 'last_first_lesson_day';
    if (prefs.getString(lastKey) == today) return;
    prefs.setString(lastKey, today);
    addGems(10, reason: 'first_lesson_of_day');
    _persistEarnToServer('first_lesson_of_day', const {});
  }

  /// Whether the first-lesson-of-day bonus can still be awarded today.
  bool get canAwardFirstLessonOfDay {
    final prefs = ref.read(prefsProvider);
    final today = utcDayKey();
    return prefs.getString('last_first_lesson_day') != today;
  }

  /// Award gems for reaching a streak milestone.
  /// Scales: 7d=15, 14d=30, 30d=60, 60d=100, 100d=150, 180d=250, 365d=500
  void awardStreakMilestone(int streakDays) {
    const thresholds = {
      365: 500,
      180: 250,
      100: 150,
      60: 100,
      30: 60,
      14: 30,
      7: 15,
    };
    final gems = thresholds.entries
        .where((e) => streakDays >= e.key)
        .map((e) => e.value)
        .firstOrNull;
    if (gems == null) return;
    addGems(gems, reason: 'streak_milestone');
    _persistEarnToServer('streak_milestone', {'streakDays': streakDays});
  }

  /// Award gems for completing a daily mission.
  /// Fixed 12 gems per mission.
  void awardMissionGems() {
    addGems(12, reason: 'mission');
    _persistEarnToServer('mission', const {});
  }
}
