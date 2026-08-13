import 'dart:math';
import '../models/chest_type.dart';
import '../models/special_item.dart';

/// Client-side special item drop roller for chests.
///
/// ## Probability Distribution (proportional, balanced)
///
/// ### Bronze Chests (common) — NO special items
/// ### Silver Chests (uncommon) — 8% chance of special item
/// ### Gold Chests (rare) — 25% chance of special item
/// ### Legendary Chests (epic) — 60% chance of special item
///
/// Luck Boost active: +15% to drop chance (capped at 95%)
class ChestSpecialDropService {
  static final ChestSpecialDropService instance = ChestSpecialDropService._();
  ChestSpecialDropService._();

  final _rng = Random();

  /// Maximum number of special items per chest
  static const int _maxItemsPerChest = 2;

  DropResult roll(ChestType chestType, {bool luckBoostActive = false}) {
    var dropChance = _dropChanceForChest(chestType);
    if (luckBoostActive) {
      dropChance = (dropChance + 0.15).clamp(0.0, 0.95);
    }
    if (_rng.nextDouble() > dropChance) {
      return const DropResult();
    }

    final items = <SpecialItemType>[];
    final cosmetics = <SpecialItemType>[];

    final itemCount = chestType == ChestType.legendary
        ? (_rng.nextDouble() < 0.4 ? 2 : 1)
        : 1;

    final pool = _poolForChest(chestType);
    final usedTypes = <SpecialItemType>{};

    for (int i = 0; i < itemCount && items.length < _maxItemsPerChest; i++) {
      final item = _weightedPick(pool, usedTypes);
      if (item == null) continue;
      usedTypes.add(item);

      if (item.isCosmetic) {
        cosmetics.add(item);
      } else {
        items.add(item);
      }
    }

    return DropResult(specialItems: items, cosmeticUnlocks: cosmetics);
  }

  double _dropChanceForChest(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return 0.0;
      case ChestType.silver:
        return 0.08;
      case ChestType.gold:
        return 0.25;
      case ChestType.legendary:
        return 0.60;
    }
  }

  List<_WeightedItem> _poolForChest(ChestType type) {
    switch (type) {
      case ChestType.bronze:
        return const [];

      case ChestType.silver:
        return const [
          _WeightedItem(SpecialItemType.focusElixir, 45),
          _WeightedItem(SpecialItemType.luckBoost, 25),
          _WeightedItem(SpecialItemType.sageMonocle, 18),
          _WeightedItem(SpecialItemType.titleStormBreaker, 7),
          _WeightedItem(SpecialItemType.avatarFrameGalaxy, 5),
        ];

      case ChestType.gold:
        return const [
          _WeightedItem(SpecialItemType.focusElixir, 20),
          _WeightedItem(SpecialItemType.luckBoost, 16),
          _WeightedItem(SpecialItemType.sageMonocle, 16),
          _WeightedItem(SpecialItemType.timeWarp, 12),
          _WeightedItem(SpecialItemType.titaniumShield, 8),
          _WeightedItem(SpecialItemType.phoenixFeather, 5),
          _WeightedItem(SpecialItemType.avatarFrameNeon, 4),
          _WeightedItem(SpecialItemType.avatarFrameGalaxy, 4),
          _WeightedItem(SpecialItemType.avatarFrameDragon, 3),
          _WeightedItem(SpecialItemType.titleCyberSage, 3),
          _WeightedItem(SpecialItemType.titleStormBreaker, 3),
          _WeightedItem(SpecialItemType.titleShadowHacker, 2),
          _WeightedItem(SpecialItemType.effectDigitalRain, 2),
          _WeightedItem(SpecialItemType.themeDarkFire, 2),
          _WeightedItem(SpecialItemType.titleNightGuardian, 1),
          _WeightedItem(SpecialItemType.titleDigitalPhoenix, 1),
        ];

      case ChestType.legendary:
        return const [
          _WeightedItem(SpecialItemType.focusElixir, 8),
          _WeightedItem(SpecialItemType.luckBoost, 7),
          _WeightedItem(SpecialItemType.sageMonocle, 8),
          _WeightedItem(SpecialItemType.timeWarp, 7),
          _WeightedItem(SpecialItemType.titaniumShield, 7),
          _WeightedItem(SpecialItemType.phoenixFeather, 6),
          _WeightedItem(SpecialItemType.avatarFrameCrystal, 5),
          _WeightedItem(SpecialItemType.avatarFrameDragon, 4),
          _WeightedItem(SpecialItemType.avatarFrameGalaxy, 4),
          _WeightedItem(SpecialItemType.avatarFrameNeon, 3),
          _WeightedItem(SpecialItemType.avatarFrameSkull, 2),
          _WeightedItem(SpecialItemType.titleNightGuardian, 3),
          _WeightedItem(SpecialItemType.titleShadowHacker, 3),
          _WeightedItem(SpecialItemType.titleCyberSage, 2),
          _WeightedItem(SpecialItemType.titleStormBreaker, 2),
          _WeightedItem(SpecialItemType.titleDigitalPhoenix, 2),
          _WeightedItem(SpecialItemType.effectDigitalRain, 3),
          _WeightedItem(SpecialItemType.effectFireTrail, 2),
          _WeightedItem(SpecialItemType.themeDarkFire, 2),
          _WeightedItem(SpecialItemType.themeCyberNeon, 1),
        ];
    }
  }

  SpecialItemType? _weightedPick(
    List<_WeightedItem> pool,
    Set<SpecialItemType> exclude,
  ) {
    final available = pool.where((w) => !exclude.contains(w.type)).toList();
    if (available.isEmpty) return null;

    final totalWeight = available.fold<int>(0, (sum, w) => sum + w.weight);
    if (totalWeight <= 0) return null;

    var roll = _rng.nextInt(totalWeight);
    for (final item in available) {
      roll -= item.weight;
      if (roll < 0) return item.type;
    }
    return available.last.type;
  }
}

/// Result of a special item drop roll.
class DropResult {
  final List<SpecialItemType> specialItems;
  final List<SpecialItemType> cosmeticUnlocks;

  const DropResult({
    this.specialItems = const [],
    this.cosmeticUnlocks = const [],
  });
}

class _WeightedItem {
  final SpecialItemType type;
  final int weight;

  const _WeightedItem(this.type, this.weight);
}
