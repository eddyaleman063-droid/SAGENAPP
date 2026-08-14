import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/special_item.dart';
import '../services/storage_service.dart';
import 'learning_provider.dart';
import 'prefs_provider.dart';
import 'service_providers.dart';

enum ShopCategory { consumables, cosmetics, themes }

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String iconAsset;
  final bool isOwned;
  final int supporterLevelRequired;
  final int gemCost;
  final ShopCategory category;
  final SpecialItemType? specialItemType;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    this.iconAsset = 'shield',
    this.isOwned = false,
    this.supporterLevelRequired = 1,
    this.gemCost = 0,
    this.category = ShopCategory.consumables,
    this.specialItemType,
  });

  ShopItem copyWith({bool? isOwned}) => ShopItem(
    id: id,
    name: name,
    description: description,
    iconAsset: iconAsset,
    isOwned: isOwned ?? this.isOwned,
    supporterLevelRequired: supporterLevelRequired,
    gemCost: gemCost,
    category: category,
    specialItemType: specialItemType,
  );
}

class ShopState {
  final List<ShopItem> items;
  final bool xpBoostActive;

  const ShopState({this.items = const [], this.xpBoostActive = false});

  ShopState copyWith({List<ShopItem>? items, bool? xpBoostActive}) => ShopState(
    items: items ?? this.items,
    xpBoostActive: xpBoostActive ?? this.xpBoostActive,
  );
}

class ShopNotifier extends Notifier<ShopState> {
  late StorageService _storage;

  static const _keyXpBoost = 'shop_xp_boost';
  static const _keyOwnedItems = 'shop_owned_items';

  @override
  ShopState build() {
    final prefs = ref.read(prefsProvider);
    _storage = StorageService(prefs);
    return _load();
  }

  /// Complete catalog: consumables + cosmetics + themes — all purchasable with gems.
  static const _defaultItems = [
    // ── Consumables ──
    ShopItem(
      id: 'focus_elixir',
      name: 'Focus Elixir',
      description: '2x EXP for 15 minutes',
      iconAsset: 'auto_awesome',
      gemCost: 30,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.focusElixir,
    ),
    ShopItem(
      id: 'xp_boost',
      name: 'XP Boost',
      description: '2x XP on your next lesson',
      iconAsset: 'bolt',
      gemCost: 40,
      category: ShopCategory.consumables,
    ),
    ShopItem(
      id: 'luck_boost',
      name: 'Luck Boost',
      description: '+15% chest rarity for 30 min',
      iconAsset: 'casino',
      gemCost: 40,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.luckBoost,
    ),
    ShopItem(
      id: 'sage_monocle',
      name: "Sage's Monocle",
      description: 'Eliminates 2 wrong answers',
      iconAsset: 'visibility',
      gemCost: 50,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.sageMonocle,
    ),
    ShopItem(
      id: 'time_warp',
      name: 'Time Warp',
      description: 'Skip cooldown on next review',
      iconAsset: 'schedule',
      gemCost: 60,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.timeWarp,
    ),
    ShopItem(
      id: 'titanium_shield',
      name: 'Titanium Shield',
      description: 'Protects your streak if you miss 1 day',
      iconAsset: 'shield',
      gemCost: 80,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.titaniumShield,
    ),
    ShopItem(
      id: 'phoenix_feather',
      name: 'Phoenix Feather',
      description: 'Revives your streak if lost',
      iconAsset: 'local_fire_department',
      gemCost: 100,
      category: ShopCategory.consumables,
      specialItemType: SpecialItemType.phoenixFeather,
    ),
    // ── Cosmetics: Avatar Frames ──
    ShopItem(
      id: 'avatar_frame_neon',
      name: 'Neon Frame',
      description: 'Animated frame with neon glow',
      iconAsset: 'filter_frames',
      gemCost: 120,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.avatarFrameNeon,
    ),
    ShopItem(
      id: 'avatar_frame_galaxy',
      name: 'Galaxy Frame',
      description: 'Galactic starframe',
      iconAsset: 'filter_frames',
      gemCost: 180,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.avatarFrameGalaxy,
    ),
    ShopItem(
      id: 'avatar_frame_dragon',
      name: 'Dragon Frame',
      description: 'Animated dragon fire frame',
      iconAsset: 'filter_frames',
      gemCost: 200,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.avatarFrameDragon,
    ),
    ShopItem(
      id: 'avatar_frame_crystal',
      name: 'Crystal Frame',
      description: 'Crystalline ice frame',
      iconAsset: 'filter_frames',
      gemCost: 250,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.avatarFrameCrystal,
    ),
    ShopItem(
      id: 'avatar_frame_skull',
      name: 'Skull Frame',
      description: 'Legendary skull flame frame',
      iconAsset: 'filter_frames',
      gemCost: 350,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.avatarFrameSkull,
    ),
    // ── Cosmetics: Titles ──
    ShopItem(
      id: 'title_storm_breaker',
      name: 'Title: Storm Breaker',
      description: 'Rare title for your profile',
      iconAsset: 'title',
      gemCost: 120,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.titleStormBreaker,
    ),
    ShopItem(
      id: 'title_cyber_sage',
      name: 'Title: Cyber Sage',
      description: 'Exclusive title for your profile',
      iconAsset: 'title',
      gemCost: 150,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.titleCyberSage,
    ),
    ShopItem(
      id: 'title_shadow_hacker',
      name: 'Title: Shadow Hacker',
      description: 'Epic title for your profile',
      iconAsset: 'title',
      gemCost: 200,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.titleShadowHacker,
    ),
    ShopItem(
      id: 'title_night_guardian',
      name: 'Title: Night Guardian',
      description: 'Exclusive title for your profile',
      iconAsset: 'title',
      gemCost: 220,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.titleNightGuardian,
    ),
    ShopItem(
      id: 'title_digital_phoenix',
      name: 'Title: Digital Phoenix',
      description: 'Legendary title for your profile',
      iconAsset: 'title',
      gemCost: 300,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.titleDigitalPhoenix,
    ),
    // ── Cosmetics: Profile Effects ──
    ShopItem(
      id: 'effect_digital_rain',
      name: 'Effect: Digital Rain',
      description: 'Animated Matrix rain effect',
      iconAsset: 'auto_awesome',
      gemCost: 250,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.effectDigitalRain,
    ),
    ShopItem(
      id: 'effect_fire_trail',
      name: 'Effect: Fire Trail',
      description: 'Animated fire trail effect',
      iconAsset: 'local_fire_department',
      gemCost: 350,
      category: ShopCategory.cosmetics,
      specialItemType: SpecialItemType.effectFireTrail,
    ),
    // ── Themes ──
    ShopItem(
      id: 'theme_blue',
      name: 'Deep Blue Theme',
      description: 'Premium blue appearance',
      iconAsset: 'palette',
      gemCost: 150,
      category: ShopCategory.themes,
    ),
    ShopItem(
      id: 'theme_purple',
      name: 'Purple Theme',
      description: 'Premium purple appearance',
      iconAsset: 'palette',
      gemCost: 150,
      category: ShopCategory.themes,
    ),
    ShopItem(
      id: 'theme_dark_fire',
      name: 'Dark Fire Theme',
      description: 'Dark fire effects theme',
      iconAsset: 'palette',
      gemCost: 250,
      category: ShopCategory.themes,
      specialItemType: SpecialItemType.themeDarkFire,
    ),
    ShopItem(
      id: 'theme_cyber_neon',
      name: 'Cyber Neon Theme',
      description: 'Futuristic neon theme',
      iconAsset: 'palette',
      gemCost: 350,
      category: ShopCategory.themes,
      specialItemType: SpecialItemType.themeCyberNeon,
    ),
  ];

  /// Maps a shop item id to its special-item type, mirroring the default
  /// catalog. Used when the Remote Config catalog omits specialItemType so
  /// consumable purchases still credit the inventory (NUEVO-08 / store).
  static ShopCategory _categoryFromString(String? raw) {
    switch (raw) {
      case 'cosmetics':
        return ShopCategory.cosmetics;
      case 'themes':
        return ShopCategory.themes;
      default:
        return ShopCategory.consumables;
    }
  }

  static SpecialItemType? _specialTypeForId(String id) {
    for (final item in _defaultItems) {
      if (item.id == id) return item.specialItemType;
    }
    return null;
  }

  static SpecialItemType? _specialTypeFromValue(Object? raw) {
    if (raw is String && raw.isNotEmpty) {
      for (final v in SpecialItemType.values) {
        if (v.name == raw) return v;
      }
    }
    return null;
  }

  ShopState _load() {
    final xpBoostActive = _storage.getBool(_keyXpBoost);
    final ownedIds = _storage.getStringList(_keyOwnedItems);
    final ownedSet = ownedIds.toSet();

    final catalog = ref.read(remoteConfigServiceProvider).shopCatalog;
    final items = catalog.isNotEmpty
        ? catalog
              .map(
                (e) {
                  final id = e['id'] as String? ?? '';
                  return ShopItem(
                    id: id,
                    name: e['name'] as String? ?? '',
                    description: e['description'] as String? ?? '',
                    iconAsset: e['iconAsset'] as String? ?? 'shield',
                    isOwned: ownedSet.contains(id),
                    supporterLevelRequired:
                        (e['supporterLevelRequired'] as num?)?.toInt() ?? 1,
                    gemCost: (e['gemCost'] as num?)?.toInt() ?? 100,
                    category: _categoryFromString(e['category'] as String?),
                    specialItemType: _specialTypeFromValue(e['specialItemType']) ??
                        _specialTypeForId(id),
                  );
                },
              )
              .where((i) => i.id.isNotEmpty)
              .toList()
        : _defaultItems
              .map((i) => i.copyWith(isOwned: ownedSet.contains(i.id)))
              .toList();

    return ShopState(xpBoostActive: xpBoostActive, items: items);
  }

  bool canUnlock(ShopItem item) {
    final learning = ref.read(learningProvider.notifier);
    final supporterLevel = _calculateSupporterLevel(
      learning.state.totalDonated,
    );
    return supporterLevel >= item.supporterLevelRequired;
  }

  int _calculateSupporterLevel(double totalDonated) {
    if (totalDonated >= 50) return 3;
    if (totalDonated >= 20) return 2;
    if (totalDonated > 0) return 1;
    return 0;
  }

  void unlockItem(String id) {
    final newItems = [
      for (final i in state.items)
        if (i.id == id) i.copyWith(isOwned: true) else i,
    ];
    state = state.copyWith(items: newItems);
    _save();
  }

  void relockItem(String id) {
    final newItems = [
      for (final i in state.items)
        if (i.id == id) i.copyWith(isOwned: false) else i,
    ];
    state = state.copyWith(items: newItems);
    _save();
  }

  void activateXpBoost() {
    _storage.setBool(_keyXpBoost, true);
    state = state.copyWith(xpBoostActive: true);
  }

  void deactivateXpBoost() {
    _storage.setBool(_keyXpBoost, false);
    state = state.copyWith(xpBoostActive: false);
  }

  void _save() {
    final ownedIds = state.items
        .where((i) => i.isOwned)
        .map((i) => i.id)
        .toList();
    _storage.setStringList(_keyOwnedItems, ownedIds);
  }
}
