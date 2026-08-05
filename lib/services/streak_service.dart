import 'dart:math';
import '../core/interfaces/i_streak_service.dart';
import '../repositories/streak_repository.dart';
import 'app_logger.dart';
import 'remote_config_service.dart';

/// Current streak state including freeze status and motivational message.
class StreakStatus {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActivityDate;
  final int streakFreezes;
  final bool isAtRisk;
  final bool freezeConsumed;
  final String message;
  final String tier;

  const StreakStatus({
    required this.currentStreak,
    required this.longestStreak,
    this.lastActivityDate,
    required this.streakFreezes,
    required this.isAtRisk,
    this.freezeConsumed = false,
    required this.message,
    required this.tier,
  });

  bool get hasStreak => currentStreak > 0;
  bool get isStreakFrozen => streakFreezes > 0 && isAtRisk && currentStreak > 0;

  Duration get timeUntilMidnight {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }
}

/// Tracks and manages daily learning streaks.
///
/// Handles streak increments, freeze consumption, milestone rewards,
/// and streak-at-risk notifications. Delegates persistence to
/// [StreakRepository] and reads thresholds from [RemoteConfigService].
class StreakService implements IStreakService {
  final StreakRepository _repo;
  final RemoteConfigService _remoteConfig;
  final AppLogger _logger = AppLogger();

  StreakService(this._repo, {RemoteConfigService? remoteConfig})
      : _remoteConfig = remoteConfig ?? RemoteConfigService.instance;

  @override
  StreakStatus load() {
    try {
      final current = _repo.currentStreak.clamp(0, 10000);
      final longest = _repo.longestStreak.clamp(0, 10000);
      final freezes = _repo.streakFreezes.clamp(0, 1000);

      final lastStr = _repo.lastActivityDate;
      final lastDate = lastStr.isNotEmpty ? DateTime.tryParse(lastStr) : null;

      return _evaluate(current, longest, lastDate, freezes);
    } catch (e) {
      _logger.error('StreakService: load failed: $e');
      return _evaluate(0, 0, null, 0);
    }
  }

  void saveFreezes(int count) {
    _repo.saveStreakFreezes(count.clamp(0, 1000));
  }

  void saveStreak({
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActivityDate,
    int? streakFreezes,
  }) {
    _repo.saveCurrentStreak(currentStreak);
    _repo.saveLongestStreak(longestStreak);
    if (lastActivityDate != null) {
      _repo.saveLastActivityDate(lastActivityDate.toIso8601String());
    }
    if (streakFreezes != null) {
      _repo.saveStreakFreezes(streakFreezes);
    }
  }

  void _save(int current, int longest, DateTime? lastDate, int freezes) {
    // Normalize to midnight for consistent date comparisons
    final normalized = lastDate != null ? DateTime(lastDate.year, lastDate.month, lastDate.day) : null;
    _repo.saveAll(
      currentStreak: current,
      longestStreak: longest,
      lastActivityDate: normalized?.toIso8601String() ?? '',
      streakFreezes: freezes,
    );
  }

  StreakStatus _evaluate(int current, int longest, DateTime? lastDate, int freezes, {bool freezeConsumed = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int updatedCurrent = current;
    int updatedFreezes = freezes;
    DateTime? updatedLast = lastDate;

    if (lastDate != null) {
      final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
      final diff = today.difference(last).inDays;

      if (diff >= 2) {
        updatedCurrent = 0;
        updatedLast = null;
      }
    }

    final atRisk = updatedCurrent > 0 && updatedLast != null &&
        today.difference(DateTime(updatedLast.year, updatedLast.month, updatedLast.day)).inDays >= 1;

    final message = _buildMessage(updatedCurrent, atRisk);
    final tier = _tierFor(updatedCurrent);

    final newLongest = max(updatedCurrent, longest);
    if (updatedCurrent != current || newLongest != longest || updatedLast != lastDate || updatedFreezes != freezes) {
      _save(updatedCurrent, newLongest, updatedLast, updatedFreezes);
    }

    return StreakStatus(
      currentStreak: updatedCurrent,
      longestStreak: max(updatedCurrent, longest),
      lastActivityDate: updatedLast,
      streakFreezes: updatedFreezes,
      isAtRisk: atRisk,
      freezeConsumed: freezeConsumed,
      message: message,
      tier: tier,
    );
  }

  @override
  StreakStatus checkIn() {
    try {
      final current = _repo.currentStreak.clamp(0, 10000);
      final longest = _repo.longestStreak.clamp(0, 10000);
      final freezes = _repo.streakFreezes.clamp(0, 1000);
      final lastStr = _repo.lastActivityDate;
      final lastDate = lastStr.isNotEmpty ? DateTime.tryParse(lastStr) : null;

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      int newCurrent;
      int newFreezes = freezes;
      bool freezeConsumed = false;

      if (lastDate != null) {
        final last = DateTime(lastDate.year, lastDate.month, lastDate.day);
        if (today == last) {
          return _evaluate(current, longest, lastDate, freezes);
        }
        final diff = today.difference(last).inDays;
        if (diff == 1) {
          newCurrent = (current + 1).clamp(0, 10000);
        } else if (diff == 2 && freezes > 0) {
          newCurrent = (current + 1).clamp(0, 10000);
          newFreezes = freezes - 1;
          freezeConsumed = true;
        } else {
          newCurrent = 1;
          newFreezes = freezes;
        }
      } else {
        newCurrent = 1;
      }

      if (newCurrent > 0 && newCurrent % 7 == 0 && newFreezes < _remoteConfig.streakMaxFreezes) {
        newFreezes = newFreezes + 1;
      }

      final newLongest = max(newCurrent, longest);
      _save(newCurrent, newLongest, now, newFreezes);

      return _evaluate(newCurrent, newLongest, now, newFreezes, freezeConsumed: freezeConsumed);
    } catch (e) {
      _logger.error('StreakService: checkIn failed: $e');
      return _evaluate(0, 0, null, 0);
    }
  }

  String _buildMessage(int streak, bool atRisk) {
    if (atRisk) return 'Your streak is at risk!';
    if (streak >= 100) return '100 days. Legend.';
    if (streak >= 50) return '50 days of constant protection.';
    if (streak >= 30) return 'One month. You are a Digital Guardian.';
    if (streak >= 14) return 'Two weeks. Your shield shines.';
    if (streak >= 7) return 'One week! Keep going.';
    if (streak >= 3) return '3 days. Good start.';
    if (streak > 0) return 'Keep protecting yourself!';
    return 'Complete activities to start your streak.';
  }

  String _tierFor(int streak) {
    if (streak >= 100) return 'legendary';
    if (streak >= 30) return 'crystal';
    if (streak >= 14) return 'particles';
    if (streak >= 7) return 'glow';
    if (streak >= 1) return 'basic';
    return 'inactive';
  }

  @override
  bool shouldSendReminder(StreakStatus status) {
    if (!status.hasStreak) return false;
    if (!status.isAtRisk) return false;
    return status.timeUntilMidnight.inHours <= 4 && status.timeUntilMidnight.inHours > 0;
  }
}
