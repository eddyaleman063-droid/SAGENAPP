import 'dart:math';
import '../core/interfaces/i_streak_service.dart';
import '../repositories/streak_repository.dart';
import 'app_logger.dart';

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
    final now = DateTime.now().toUtc();
    final midnight = DateTime.utc(now.year, now.month, now.day + 1);
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
  final AppLogger _logger = AppLogger();

  StreakService(this._repo);

  // -- Día del streak alineado con el servidor (UTC) --------------------------
  // El servidor (economic.incrementStreak) parte la "racha diaria" por el día
  // UTC (`YYYY-MM-DD` del timestamp). El cliente debe usar el mismo límite:
  // si usara la medianoche local, un check-in de noche (p.ej. 20:00 en UTC-6,
  // que ya es la madrugada UTC del día siguiente) contaría como día nuevo en
  // el servidor pero "mismo día" en local, desplazando la racha de forma
  // permanente. Todo el historial se almacena como medianoche UTC.

  /// Día calendario UTC al que pertenece el instante [t].
  static DateTime _dayOf(DateTime t) {
    final u = t.toUtc();
    return DateTime.utc(u.year, u.month, u.day);
  }

  /// Día calendario UTC de hoy.
  static DateTime _todayUtc() => _dayOf(DateTime.now());

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
    // Normalize to UTC midnight for consistent date comparisons (the server
    // splits streak days by UTC calendar date).
    final normalized = lastDate != null ? _dayOf(lastDate) : null;
    _repo.saveAll(
      currentStreak: current,
      longestStreak: longest,
      lastActivityDate: normalized?.toIso8601String() ?? '',
      streakFreezes: freezes,
    );
  }

  StreakStatus _evaluate(
    int current,
    int longest,
    DateTime? lastDate,
    int freezes, {
    bool freezeConsumed = false,
  }) {
    final today = _todayUtc();

    final atRisk =
        current > 0 &&
        lastDate != null &&
        today.difference(_dayOf(lastDate)).inDays >= 1;

    final message = _buildMessage(current, atRisk);
    final tier = _tierFor(current);

    return StreakStatus(
      currentStreak: current,
      longestStreak: max(current, longest),
      lastActivityDate: lastDate,
      streakFreezes: freezes,
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
      final today = _todayUtc();

      int newCurrent;
      int newFreezes = freezes;
      bool freezeConsumed = false;

      if (lastDate != null) {
        final last = _dayOf(lastDate);
        if (today == last) {
          return _evaluate(current, longest, lastDate, freezes);
        }
        final diff = today.difference(last).inDays;
        if (diff == 1) {
          newCurrent = (current + 1).clamp(0, 10000);
        } else if (diff >= 2 && freezes > 0) {
          // NUEVO-fix (H3): mirror del contrato server-side. El servidor
          // (economic.incrementStreak) mantiene viva la racha para CUALQUIER
          // gap >= 2 días consumiendo UN escudo si el usuario posee uno; solo
          // rompe si no hay escudos. Antes el cliente rompía localmente a partir
          // de diff >= 3 (sin quemar nada), lo que causaba un flash de "racha
          // perdida" y luego el reconcile revivía la racha con el escudo ya
          // quemado en servidor. Con esto local == servidor (quemando también
          // offline), sin sorpresas ni doble contabilidad.
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

      // Nota: ya no se concede aquí un escudo "gratis" local cada 7 días. Ese
      // contador local (streak_freezes) vivía solo en el cliente y el servidor
      // (fuente de verdad de escudos) nunca lo honraba: al faltar un día el
      // freeze se denegaba y la racha se rompía pese a "poseer" el escudo. Los
      // escudos ahora los acredita el servidor (claimFreeStreakShield, shop,
      // cofre) y el cliente los refleja vía shieldsRemaining durante el sync.

      final newLongest = max(newCurrent, longest);
      _save(newCurrent, newLongest, now, newFreezes);

      return _evaluate(
        newCurrent,
        newLongest,
        now,
        newFreezes,
        freezeConsumed: freezeConsumed,
      );
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
    return status.timeUntilMidnight.inHours <= 4 &&
        status.timeUntilMidnight.inHours > 0;
  }
}
