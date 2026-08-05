/// All special items, cosmetics, and effects available in chests.
enum SpecialItemType {
  // ── Consumable Items (usable) ──
  focusElixir,      // x2 EXP for 15 min
  phoenixFeather,   // Revive streak if lost <24h ago
  sageMonocle,      // Remove 2 wrong answers in a challenge
  titaniumShield,   // Auto-protect streak on miss
  luckBoost,        // +15% chest rarity boost for 30 min
  timeWarp,         // Skip cooldown on next lesson review

  // ── Permanent Cosmetics: Avatar Frames ──
  avatarFrameNeon,      // Neon glow frame
  avatarFrameDragon,    // Dragon fire frame
  avatarFrameCrystal,   // Ice crystal frame
  avatarFrameSkull,     // Skull flame frame (legendary)
  avatarFrameGalaxy,    // Galaxy star frame (epic)

  // ── Permanent Cosmetics: Titles ──
  titleCyberSage,       // "Cyber Sage" title
  titleNightGuardian,   // "Night Guardian" title
  titleDigitalPhoenix,  // "Digital Phoenix" title
  titleShadowHacker,    // "Shadow Hacker" title (epic)
  titleStormBreaker,    // "Storm Breaker" title (rare)

  // ── Permanent Cosmetics: Themes ──
  themeDarkFire,        // Dark fire theme
  themeCyberNeon,       // Cyber neon theme

  // ── Permanent Cosmetics: Profile Effects ──
  effectDigitalRain,    // Digital rain matrix effect
  effectFireTrail,      // Fire trail effect
}

extension SpecialItemTypeProperties on SpecialItemType {
  String get displayName {
    switch (this) {
      case SpecialItemType.focusElixir: return 'Focusing Elixir';
      case SpecialItemType.phoenixFeather: return 'Phoenix Feather';
      case SpecialItemType.sageMonocle: return 'Sage Monocle';
      case SpecialItemType.titaniumShield: return 'Titanium Shield';
      case SpecialItemType.luckBoost: return 'Luck Boost';
      case SpecialItemType.timeWarp: return 'Time Warp';
      case SpecialItemType.avatarFrameNeon: return 'Neon Frame';
      case SpecialItemType.avatarFrameDragon: return 'Dragon Frame';
      case SpecialItemType.avatarFrameCrystal: return 'Crystal Frame';
      case SpecialItemType.avatarFrameSkull: return 'Skull Flame Frame';
      case SpecialItemType.avatarFrameGalaxy: return 'Galaxy Frame';
      case SpecialItemType.titleCyberSage: return 'Cyber Sage Title';
      case SpecialItemType.titleNightGuardian: return 'Night Guardian Title';
      case SpecialItemType.titleDigitalPhoenix: return 'Digital Phoenix Title';
      case SpecialItemType.titleShadowHacker: return 'Shadow Hacker Title';
      case SpecialItemType.titleStormBreaker: return 'Storm Breaker Title';
      case SpecialItemType.themeDarkFire: return 'Dark Fire Theme';
      case SpecialItemType.themeCyberNeon: return 'Cyber Neon Theme';
      case SpecialItemType.effectDigitalRain: return 'Digital Rain Effect';
      case SpecialItemType.effectFireTrail: return 'Fire Trail Effect';
    }
  }

  String get description {
    switch (this) {
      case SpecialItemType.focusElixir: return 'Multiplies EXP x2 for 15 min';
      case SpecialItemType.phoenixFeather: return 'Revives streak if lost less than 24h ago';
      case SpecialItemType.sageMonocle: return 'Removes 2 wrong answers in a challenge';
      case SpecialItemType.titaniumShield: return 'Auto-protects streak if you miss a day';
      case SpecialItemType.luckBoost: return '+15% chest rarity boost for 30 min';
      case SpecialItemType.timeWarp: return 'Skip cooldown on next lesson review';
      case SpecialItemType.avatarFrameNeon: return 'Animated neon glow frame for your avatar';
      case SpecialItemType.avatarFrameDragon: return 'Dragon fire frame for your avatar';
      case SpecialItemType.avatarFrameCrystal: return 'Ice crystal frame for your avatar';
      case SpecialItemType.avatarFrameSkull: return 'Legendary skull flame frame';
      case SpecialItemType.avatarFrameGalaxy: return 'Epic galaxy star frame';
      case SpecialItemType.titleCyberSage: return 'Exclusive "Cyber Sage" display title';
      case SpecialItemType.titleNightGuardian: return 'Exclusive "Night Guardian" display title';
      case SpecialItemType.titleDigitalPhoenix: return 'Exclusive "Digital Phoenix" display title';
      case SpecialItemType.titleShadowHacker: return 'Epic "Shadow Hacker" display title';
      case SpecialItemType.titleStormBreaker: return 'Rare "Storm Breaker" display title';
      case SpecialItemType.themeDarkFire: return 'Dark fire color theme for the app';
      case SpecialItemType.themeCyberNeon: return 'Cyber neon color theme for the app';
      case SpecialItemType.effectDigitalRain: return 'Animated digital rain profile effect';
      case SpecialItemType.effectFireTrail: return 'Animated fire trail profile effect';
    }
  }

  /// Maximum quantity a player can hold for each item type.
  int get maxLimit {
    switch (this) {
      case SpecialItemType.focusElixir: return 5;
      case SpecialItemType.phoenixFeather: return 3;
      case SpecialItemType.sageMonocle: return 4;
      case SpecialItemType.titaniumShield: return 3;
      case SpecialItemType.luckBoost: return 4;
      case SpecialItemType.timeWarp: return 3;
      case SpecialItemType.avatarFrameNeon: return 1;
      case SpecialItemType.avatarFrameDragon: return 1;
      case SpecialItemType.avatarFrameCrystal: return 1;
      case SpecialItemType.avatarFrameSkull: return 1;
      case SpecialItemType.avatarFrameGalaxy: return 1;
      case SpecialItemType.titleCyberSage: return 1;
      case SpecialItemType.titleNightGuardian: return 1;
      case SpecialItemType.titleDigitalPhoenix: return 1;
      case SpecialItemType.titleShadowHacker: return 1;
      case SpecialItemType.titleStormBreaker: return 1;
      case SpecialItemType.themeDarkFire: return 1;
      case SpecialItemType.themeCyberNeon: return 1;
      case SpecialItemType.effectDigitalRain: return 1;
      case SpecialItemType.effectFireTrail: return 1;
    }
  }

  /// Rarity tier for drop weighting: 0=common, 1=uncommon, 2=rare, 3=epic, 4=legendary
  int get rarityTier {
    switch (this) {
      case SpecialItemType.focusElixir: return 1;
      case SpecialItemType.luckBoost: return 1;
      case SpecialItemType.sageMonocle: return 2;
      case SpecialItemType.timeWarp: return 2;
      case SpecialItemType.phoenixFeather: return 3;
      case SpecialItemType.titaniumShield: return 3;
      case SpecialItemType.avatarFrameNeon: return 2;
      case SpecialItemType.avatarFrameDragon: return 3;
      case SpecialItemType.avatarFrameCrystal: return 3;
      case SpecialItemType.avatarFrameSkull: return 4;
      case SpecialItemType.avatarFrameGalaxy: return 3;
      case SpecialItemType.titleCyberSage: return 2;
      case SpecialItemType.titleNightGuardian: return 3;
      case SpecialItemType.titleDigitalPhoenix: return 4;
      case SpecialItemType.titleShadowHacker: return 3;
      case SpecialItemType.titleStormBreaker: return 2;
      case SpecialItemType.themeDarkFire: return 3;
      case SpecialItemType.themeCyberNeon: return 4;
      case SpecialItemType.effectDigitalRain: return 3;
      case SpecialItemType.effectFireTrail: return 4;
    }
  }

  bool get isCosmetic => !isConsumable;

  bool get isConsumable => [
    SpecialItemType.focusElixir,
    SpecialItemType.phoenixFeather,
    SpecialItemType.sageMonocle,
    SpecialItemType.titaniumShield,
    SpecialItemType.luckBoost,
    SpecialItemType.timeWarp,
  ].contains(this);
}

/// Runtime representation of a special item with quantity.
class SpecialItem {
  final SpecialItemType type;
  final int quantity;
  final DateTime? activeUntil;

  const SpecialItem({
    required this.type,
    this.quantity = 0,
    this.activeUntil,
  });

  bool get isActive => activeUntil != null && DateTime.now().isBefore(activeUntil!);
  bool get hasQuantity => quantity > 0;

  SpecialItem copyWith({int? quantity, DateTime? activeUntil, bool clearActive = false}) {
    return SpecialItem(
      type: type,
      quantity: quantity ?? this.quantity,
      activeUntil: clearActive ? null : (activeUntil ?? this.activeUntil),
    );
  }
}
