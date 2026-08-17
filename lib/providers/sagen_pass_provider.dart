import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sagen_pass.dart';
import '../repositories/sagen_pass_repository.dart';
import '../services/app_logger.dart';
import 'service_providers.dart';

final sagenPassProvider = NotifierProvider<SagenPassNotifier, SagenPass>(
  SagenPassNotifier.new,
);

class SagenPassNotifier extends Notifier<SagenPass> {
  late final SagenPassRepository _repo;

  @override
  SagenPass build() {
    _repo = ref.watch(sagenPassRepositoryProvider);
    final local = _load();
    _checkSeasonReset(local);
    _reconcileWithServer();
    return local;
  }

  void _checkSeasonReset(SagenPass pass) {
    final now = DateTime.now();
    final seasonEnd = pass.seasonStart.add(
      Duration(days: pass.seasonDurationDays),
    );
    if (now.isAfter(seasonEnd)) {
      // Season expired - reset to level 1 with fresh state
      state = SagenPass(
        currentLevel: 1,
        currentSP: 0,
        claimedLevels: [],
        seasonStart: now,
        seasonDurationDays: pass.seasonDurationDays,
      );
      _save();
    }
  }

  SagenPass _load() {
    return SagenPass(
      currentLevel: _repo.currentLevel,
      currentSP: _repo.currentSP,
      claimedLevels: _repo.claimedLevels,
      seasonStart: _repo.seasonStart,
      premium: _repo.premium,
    );
  }

  /// Reconcile local state with server-side authoritative season data.
  Future<void> _reconcileWithServer() async {
    try {
      final serverData = await ref
          .read(gamificationCloudServiceProvider)
          .getSagenPassSeason();
      if (serverData == null) return;

      final serverSeasonStart = serverData['seasonStart'];
      final serverLevel = serverData['level'] as int? ?? state.currentLevel;
      final serverSP = serverData['sp'] as int? ?? state.currentSP;
      final serverClaimed = serverData['claimed'];
      final serverPremium = serverData['premium'] as bool? ?? state.premium;

      List<int> claimed;
      if (serverClaimed is List) {
        claimed = serverClaimed.whereType<int>().toList();
      } else {
        claimed = state.claimedLevels;
      }

      // Reconcile seasonStart from server (authoritative)
      DateTime? seasonStart;
      if (serverSeasonStart != null) {
        if (serverSeasonStart is String) {
          seasonStart = DateTime.tryParse(serverSeasonStart);
        }
      }

      // Apply server values (server is source of truth)
      state = state.copyWith(
        currentLevel: serverLevel,
        currentSP: serverSP,
        claimedLevels: claimed,
        seasonStart: seasonStart,
        premium: serverPremium,
      );
      _save();
    } catch (e) {
      AppLogger().warning(
        'SagenPass: server reconciliation failed, using local: $e',
      );
    }
  }

  void _save() {
    _repo.save(
      state.currentLevel,
      state.currentSP,
      state.claimedLevels,
      state.seasonStart,
      state.premium,
    );
  }

  /// Claims a level reward via server-side Cloud Function.
  /// Server response is validated to prevent crashes from malformed data.
  Future<PassLevel?> claimLevel(int level) async {
    if (state.isLevelClaimed(level)) return null;
    if (level > state.currentLevel) return null;

    final result = await ref
        .read(gamificationCloudServiceProvider)
        .claimPassReward(level);
    if (result == null) return null;

    // Validate claimedLevels from server response
    final rawClaimed = result['claimedLevels'];
    List<int> claimed;
    if (rawClaimed is List) {
      claimed = rawClaimed.whereType<int>().toList();
    } else {
      // Fallback: add the level locally
      claimed = [...state.claimedLevels, level];
    }

    // Reconcile seasonStart from server if returned
    DateTime? seasonStart;
    final rawSeasonStart = result['seasonStart'];
    if (rawSeasonStart is String) {
      seasonStart = DateTime.tryParse(rawSeasonStart);
    }

    state = state.copyWith(
      claimedLevels: claimed,
      seasonStart: seasonStart ?? state.seasonStart,
    );
    _save();
    return getLevel(level);
  }

  PassLevel? getLevel(int level) {
    try {
      return SagenPass.allLevels.firstWhere((l) => l.level == level);
    } catch (e) {
      AppLogger().warning('SagenPass: getLevel failed for level $level: $e');
      return null;
    }
  }
}
