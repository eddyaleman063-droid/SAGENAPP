import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chest_type.dart';
import '../models/chest_reward.dart';
import 'chest_drop_service.dart';
import 'app_logger.dart';

/// Rolls chest rewards via the server-side Cloud Function.
///
/// ## XP Ranges by Chest Type
///   - bronze:   15–25 XP
///   - silver:   25–35 XP
///   - gold:     35–50 XP
///   - legendary: 50–75 XP
///
/// ## Special Drops (server-authoritative, NUEVO-08)
///   - streakShields: 1 when category = shield (server)
///   - xpBoost: true when category = booster (server)
///   - specialItems / cosmeticUnlocks: rolled and persisted SERVER-SIDE.
///     The client never rolls them locally (a modified client could
///     otherwise fabricate infinite consumables).
class ChestRewardRoller {
  ChestRewardRoller._({ChestDropService? dropService})
    : _dropService = dropService ?? ChestDropService.instance;

  @visibleForTesting
  ChestRewardRoller({ChestDropService? dropService})
    : _dropService = dropService ?? ChestDropService.instance;
  static final ChestRewardRoller instance = ChestRewardRoller._();

  final ChestDropService _dropService;
  Completer<void>? _rollMutex;

  static int _fallbackXp(ChestType type) => 0;

  Future<ChestReward> roll(
    ChestType type, {
    bool luckBoostActive = false,
    String? contextId,
    String source = 'lesson',
  }) async {
    while (_rollMutex != null) {
      await _rollMutex?.future;
    }
    _rollMutex = Completer<void>();
    try {
      ChestReward serverReward;
      try {
        serverReward = await _dropService.roll(
          type,
          contextId: contextId,
          source: source,
          luckBoostActive: luckBoostActive,
        );
      } catch (e) {
        AppLogger().warning(
          'ChestRewardRoller: server roll failed, using minimal reward: $e',
        );
        serverReward = ChestReward(xp: _fallbackXp(type));
      }

      return ChestReward(
        xp: serverReward.xp,
        gems: serverReward.gems,
        streakShields: serverReward.streakShields,
        xpBoost: serverReward.xpBoost,
        chestType: serverReward.chestType,
        specialItems: serverReward.specialItems,
        cosmeticUnlocks: serverReward.cosmeticUnlocks,
      );
    } finally {
      final mutex = _rollMutex;
      _rollMutex = null;
      mutex?.complete();
    }
  }
}
