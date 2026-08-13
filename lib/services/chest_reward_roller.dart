import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/chest_type.dart';
import '../models/chest_reward.dart';
import 'chest_drop_service.dart';
import 'chest_special_drop_service.dart';
import 'app_logger.dart';

/// Rolls chest rewards via server-side Cloud Function + client-side special drops.
///
/// ## XP Ranges by Chest Type
///   - bronze:   15–25 XP
///   - silver:   25–35 XP
///   - gold:     35–50 XP
///   - legendary: 50–75 XP
///
/// ## Special Drops (client-side)
///   - streakShields: 1 when category = shield (server)
///   - xpBoost: true when category = booster (server)
///   - specialItems: from ChestSpecialDropService (client-side)
///   - cosmeticUnlocks: from ChestSpecialDropService (client-side)
class ChestRewardRoller {
  ChestRewardRoller._({
    ChestDropService? dropService,
    ChestSpecialDropService? specialDropService,
  }) : _dropService = dropService ?? ChestDropService.instance,
       _specialDropService =
           specialDropService ?? ChestSpecialDropService.instance;

  @visibleForTesting
  ChestRewardRoller({
    ChestDropService? dropService,
    ChestSpecialDropService? specialDropService,
  }) : _dropService = dropService ?? ChestDropService.instance,
       _specialDropService =
           specialDropService ?? ChestSpecialDropService.instance;
  static final ChestRewardRoller instance = ChestRewardRoller._();

  final ChestDropService _dropService;
  final ChestSpecialDropService _specialDropService;
  Completer<void>? _rollMutex;

  static int _fallbackXp(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return 15;
      case ChestType.silver:
        return 25;
      case ChestType.gold:
        return 35;
      case ChestType.legendary:
        return 50;
    }
  }

  Future<ChestReward> roll(
    ChestType type, {
    bool luckBoostActive = false,
  }) async {
    while (_rollMutex != null) {
      await _rollMutex?.future;
    }
    _rollMutex = Completer<void>();
    try {
      ChestReward serverReward;
      try {
        serverReward = await _dropService.roll(type);
      } catch (e) {
        AppLogger().warning(
          'ChestRewardRoller: server roll failed, using minimal reward: $e',
        );
        serverReward = ChestReward(xp: _fallbackXp(type));
      }

      final specialDrop = _specialDropService.roll(
        type,
        luckBoostActive: luckBoostActive,
      );

      return ChestReward(
        xp: serverReward.xp,
        streakShields: serverReward.streakShields,
        xpBoost: serverReward.xpBoost,
        specialItems: specialDrop.specialItems,
        cosmeticUnlocks: specialDrop.cosmeticUnlocks,
      );
    } finally {
      final mutex = _rollMutex;
      _rollMutex = null;
      mutex?.complete();
    }
  }
}
