import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/gamification_repository.dart';
import '../services/app_logger.dart';
import 'gem_provider.dart';
import 'learning_provider.dart';
import 'service_providers.dart';

class GamificationState {
  final bool hasUnclaimedChest;
  final int secondsUntilMidnight;
  final int dailyMissionsCompleted;

  const GamificationState({
    this.hasUnclaimedChest = false,
    this.secondsUntilMidnight = 0,
    this.dailyMissionsCompleted = 0,
  });

  GamificationState copyWith({
    bool? hasUnclaimedChest,
    int? secondsUntilMidnight,
    int? dailyMissionsCompleted,
  }) {
    return GamificationState(
      hasUnclaimedChest: hasUnclaimedChest ?? this.hasUnclaimedChest,
      secondsUntilMidnight: secondsUntilMidnight ?? this.secondsUntilMidnight,
      dailyMissionsCompleted:
          dailyMissionsCompleted ?? this.dailyMissionsCompleted,
    );
  }
}

class GamificationNotifier extends Notifier<GamificationState> {
  late final GamificationRepository _repo;
  Set<String> _countedMissions = {};
  Timer? _midnightTimer;
  bool _disposed = false;
  bool _chestReconciled = false;
  String _lastMidnightDay = '';

  static String _utcDayKey(DateTime t) {
    final u = t.toUtc();
    return '${u.year}-${u.month.toString().padLeft(2, '0')}-${u.day.toString().padLeft(2, '0')}';
  }

  @override
  GamificationState build() {
    _repo = ref.read(gamificationRepositoryProvider);
    _countedMissions = _repo.getCountedMissions();
    _repo.checkMidnightReset();
    _lastMidnightDay = _utcDayKey(DateTime.now());
    _startMidnightTimer();
    // NUEVO-fix (chest desync): el servidor es la fuente de verdad. Se
    // reconcilia el ledger local una vez por sesión (fire-and-forget; si hay
    // error/offline se conserva el valor local y el puente pasivo del
    // CloudSyncService a través del mapping seguirá corrigiendo en arranques).
    _reconcileDailyChestOnce();
    ref.onDispose(() {
      _disposed = true;
      _midnightTimer?.cancel();
    });
    return GamificationState(
      hasUnclaimedChest: _repo.canClaimDailyChest,
      secondsUntilMidnight: _repo.secondsUntilMidnight,
    );
  }

  void _reconcileDailyChestOnce() {
    if (_chestReconciled) return;
    _chestReconciled = true;
    _syncDailyChestToServer();
  }

  /// Pide al servidor el estado autoritativo del cofre y lo aplica al ledger
  /// local. Cierra el bucle "reclamado que reaparece" y el caso de recompensa
  /// oculta por prefs stale (reclamado en otro dispositivo/sesión).
  Future<void> _syncDailyChestToServer() async {
    try {
      final result = await ref
          .read(gamificationCloudServiceProvider)
          .getDailyChestStatusResult();
      if (_disposed || result.isError) return;
      final data = result.value ?? const <String, dynamic>{};
      final available = data['available'] == true;
      final lastClaimed = data['lastClaimedDate'];
      if (available) {
        // El server dice que HOY aún no se reclamó: asegura que el flag local
        // no bloquee la recompensa (fija el caso "oculto por prefs stale").
        _repo.setUnclaimedChest(true);
      } else if (lastClaimed is String && lastClaimed.isNotEmpty) {
        // El server dice reclamado: persiste la fecha autoritativa y limpia el
        // flag para que el cofre NO reaparezca en el próximo arranque.
        _repo.setLastClaimDate(lastClaimed);
        _repo.setUnclaimedChest(false);
      }
      if (state.hasUnclaimedChest != available) {
        state = state.copyWith(hasUnclaimedChest: available);
      }
    } catch (e) {
      // Offline o error transitorio: no romper el arranque; se conserva el
      // valor local y el puente del CloudSyncService corrige en el próximo
      // snapshot.
      AppLogger().warning('Daily chest status reconcile failed: $e');
    }
  }

  void _startMidnightTimer() {
    _midnightTimer?.cancel();
    // Check every 5 minutes instead of 30 seconds to reduce CPU usage
    _midnightTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final now = DateTime.now();
      final newSeconds = _repo.secondsUntilMidnight;
      if (newSeconds != state.secondsUntilMidnight) {
        state = state.copyWith(secondsUntilMidnight: newSeconds);
      }
      // NUEVO-fix (H2): el reset de medianoche se dispara por CRUCE DE DÍA UTC,
      // no por `secondsUntilMidnight <= 0` (que nunca ocurre: la getter siempre
      // devuelve los segundos RESTANTES hasta la próxima medianoche). Sin esto,
      // si la app cruzaba la medianoche UTC abierta, misiones/cofre quedaban
      // stale hasta el próximo arranque.
      final todayKey = _utcDayKey(now);
      if (todayKey != _lastMidnightDay) {
        _lastMidnightDay = todayKey;
        _repo.checkMidnightReset();
        _countedMissions.clear();
        _repo.saveCountedMissions(_countedMissions);
        state = state.copyWith(hasUnclaimedChest: _repo.canClaimDailyChest);
        // El servidor es la fuente de verdad del cofre: al cruzar medianoche se
        // re-sincroniza para que el flag local no bloquee la recompensa diaria.
        _syncDailyChestToServer();
      }
    });
  }

  Future<int> claimDailyChest() async {
    if (_disposed || !state.hasUnclaimedChest) return 0;
    try {
      final result = await ref
          .read(gamificationCloudServiceProvider)
          .claimDailyChestResult();
      if (result.isError) {
        // Offline or server error: keep the chest unclaimed so the user can retry.
        return 0;
      }
      final data = result.value ?? const <String, dynamic>{};
      if (data['alreadyClaimed'] == true) {
        // NUEVO-fix (chest desync): antes solo se limpiaba el flag local sin
        // persistir la fecha, así el cofre reaparecía en el siguiente arranque
        // (nunca terminaba el bucle). Ahora se persiste la fecha autoritativa
        // del servidor en el ledger local. -1 = "ya reclamado" (sin toast de
        // error; el cofre simplemente desaparece).
        final serverDate = data['lastClaimedDate'];
        if (serverDate is String && serverDate.isNotEmpty) {
          _repo.setLastClaimDate(serverDate);
        }
        _repo.setUnclaimedChest(false);
        state = state.copyWith(hasUnclaimedChest: false);
        return -1;
      }
      final xp = data['xp'] is int ? (data['xp'] as int) : 0;
      if (xp > 0) {
        // Server already credited XP in the claim transaction; apply locally only.
        ref.read(learningProvider.notifier).applyServerXp(xp);
      }
      // F3: the server credits gems in the same claim transaction but the
      // response gems were previously ignored, leaving the local balance stale
      // (missing ~5 gems) until the next server sync. Mirror them locally.
      final gemsData = data['gems'];
      if (gemsData is Map<String, dynamic>) {
        final gemsAdded = (gemsData['added'] as num?)?.toInt() ?? 0;
        if (gemsAdded > 0) {
          ref
              .read(gemProvider.notifier)
              .addGems(gemsAdded, reason: 'daily_chest');
        }
      }
      try {
        _repo.claimDailyChest();
      } catch (e) {
        AppLogger().warning('Daily chest local claim record failed: $e');
      }
      state = state.copyWith(hasUnclaimedChest: false);
      return xp;
    } catch (e) {
      AppLogger().warning('Daily chest claim failed: $e');
      return 0;
    }
  }

  void incrementMission(String missionId, {int amount = 1}) {
    if (missionId.isEmpty) return;
    final key = '$missionId:$amount';
    if (_countedMissions.contains(key)) return;
    _countedMissions.add(key);
    _repo.saveCountedMissions(_countedMissions);
    _repo.incrementMission(missionId, amount: amount);
    state = state.copyWith(
      dailyMissionsCompleted: state.dailyMissionsCompleted + amount,
    );
  }
}

final gamificationProvider =
    NotifierProvider<GamificationNotifier, GamificationState>(
      GamificationNotifier.new,
    );
