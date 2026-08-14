import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'app_logger.dart';

/// Reads feature flags and config values from Firebase Remote Config.
class RemoteConfigService {
  static final RemoteConfigService instance = RemoteConfigService._();
  RemoteConfigService._() : _logger = AppLogger();
  final AppLogger _logger;

  FirebaseRemoteConfig? _rc;
  bool _initialized = false;

  static const _keyChestDropRates = 'chest_drop_rates';
  static const _keyPityThreshold = 'chest_pity_threshold';
  static const _keyMaxGemCap = 'economy_max_gem_cap';
  static const _keyShopCatalog = 'shop_catalog';
  static const _keyMissionLegendaryRate = 'mission_legendary_rate';
  static const _keyMissionGoldRate = 'mission_gold_rate';
  static const _keyMissionSilverRate = 'mission_silver_rate';
  static const _keyEvolutionBronzeToSilver = 'chest_evolution_bronze_silver';
  static const _keyEvolutionSilverToGold = 'chest_evolution_silver_gold';
  static const _keyEvolutionGoldToLegendary = 'chest_evolution_gold_legendary';
  static const _keyStreakMaxFreezes = 'streak_max_freezes';
  static const _keyDailyGemCapLesson = 'daily_gem_cap_lesson';
  static const _keyDailyGemCapChest = 'daily_gem_cap_chest';
  static const _keyDailyGemCapAchievement = 'daily_gem_cap_achievement';
  static const _keyDailyGemCapMission = 'daily_gem_cap_mission';
  static const _keyDailyGemCapStreak = 'daily_gem_cap_streak';
  static const _keyDailyGemCapChallenge = 'daily_gem_cap_challenge';
  static const _keyDailyGemCapGacha = 'daily_gem_cap_gacha';

  // Feature Flags
  static const _ffNewUI = 'ff_new_ui';
  static const _ffChatV2 = 'ff_chat_v2';
  static const _ffMiniGames = 'ff_mini_games';
  static const _ffStoreRedesign = 'ff_store_redesign';
  static const _ffStreakFreeze = 'ff_streak_freeze';
  static const _ffLeaderboard = 'ff_leaderboard';
  static const _ffDarkMode = 'ff_dark_mode';
  static const _ffVoiceInput = 'ff_voice_input';

  // A/B Test Keys
  static const _abOnboardingFlow = 'ab_onboarding_flow';
  static const _abLessonLayout = 'ab_lesson_layout';
  static const _abChestAnimation = 'ab_chest_animation';
  static const _abPaywallPosition = 'ab_paywall_position';

  Future<void> init() async {
    if (_initialized) return;
    try {
      _rc = FirebaseRemoteConfig.instance;
      final rc = _rc;
      if (rc == null) return;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );
      await rc.setDefaults({
        _keyChestDropRates: jsonEncode(_defaultDropRates()),
        _keyPityThreshold: 20,
        _keyMaxGemCap: 50000,
        _keyShopCatalog: '[]',
        _keyMissionLegendaryRate: 0.01,
        _keyMissionGoldRate: 0.06,
        _keyMissionSilverRate: 0.20,
        _keyEvolutionBronzeToSilver: 0.45,
        _keyEvolutionSilverToGold: 0.20,
        _keyEvolutionGoldToLegendary: 0.03,
        _keyStreakMaxFreezes: 7,
        _keyDailyGemCapLesson: 50,
        _keyDailyGemCapChest: 200,
        _keyDailyGemCapAchievement: 200,
        _keyDailyGemCapMission: 50,
        _keyDailyGemCapStreak: 200,
        _keyDailyGemCapChallenge: 30,
        _keyDailyGemCapGacha: 200,
        // Feature Flags defaults
        _ffNewUI: false,
        _ffChatV2: false,
        _ffMiniGames: true,
        _ffStoreRedesign: false,
        _ffStreakFreeze: false,
        _ffLeaderboard: true,
        _ffDarkMode: true,
        _ffVoiceInput: false,
        // A/B Test defaults
        _abOnboardingFlow: 'standard',
        _abLessonLayout: 'card',
        _abChestAnimation: 'classic',
        _abPaywallPosition: 'bottom',
      });
      await rc.fetchAndActivate().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          _logger.warning(
            'RemoteConfigService.init: fetchAndActivate timed out, using defaults',
          );
          return false;
        },
      );
      _initialized = true;
    } catch (e) {
      _logger.error('RemoteConfigService.init', e);
    }
  }

  // ── Feature Flags ──────────────────────────────────────
  bool get isNewUIEnabled => _rc?.getBool(_ffNewUI) ?? false;
  bool get isChatV2Enabled => _rc?.getBool(_ffChatV2) ?? false;
  bool get isMiniGamesEnabled => _rc?.getBool(_ffMiniGames) ?? true;
  bool get isStoreRedesignEnabled => _rc?.getBool(_ffStoreRedesign) ?? false;
  bool get isStreakFreezeEnabled => _rc?.getBool(_ffStreakFreeze) ?? false;
  bool get isLeaderboardEnabled => _rc?.getBool(_ffLeaderboard) ?? true;
  bool get isDarkModeEnabled => _rc?.getBool(_ffDarkMode) ?? true;
  bool get isVoiceInputEnabled => _rc?.getBool(_ffVoiceInput) ?? false;

  bool isFeatureEnabled(String key, {bool defaultValue = false}) {
    return _rc?.getBool(key) ?? defaultValue;
  }

  // ── A/B Testing ────────────────────────────────────────
  String get onboardingFlowVariant =>
      _rc?.getString(_abOnboardingFlow) ?? 'standard';
  String get lessonLayoutVariant => _rc?.getString(_abLessonLayout) ?? 'card';
  String get chestAnimationVariant =>
      _rc?.getString(_abChestAnimation) ?? 'classic';
  String get paywallPositionVariant =>
      _rc?.getString(_abPaywallPosition) ?? 'bottom';

  String getExperimentVariant(String key, {String defaultValue = 'control'}) {
    return _rc?.getString(key) ?? defaultValue;
  }

  Map<String, String> get allExperiments => {
    'onboarding_flow': onboardingFlowVariant,
    'lesson_layout': lessonLayoutVariant,
    'chest_animation': chestAnimationVariant,
    'paywall_position': paywallPositionVariant,
  };

  Map<String, bool> get allFeatureFlags => {
    'new_ui': isNewUIEnabled,
    'chat_v2': isChatV2Enabled,
    'mini_games': isMiniGamesEnabled,
    'store_redesign': isStoreRedesignEnabled,
    'streak_freeze': isStreakFreezeEnabled,
    'leaderboard': isLeaderboardEnabled,
    'dark_mode': isDarkModeEnabled,
    'voice_input': isVoiceInputEnabled,
  };

  Map<String, dynamic>? _cachedDropRates;
  DateTime? _lastDropRatesFetch;
  List<Map<String, dynamic>>? _cachedShopCatalog;
  DateTime? _lastShopCatalogFetch;

  Map<String, dynamic> get chestDropRates {
    final now = DateTime.now();
    if (_cachedDropRates != null &&
        _lastDropRatesFetch != null &&
        now.difference(_lastDropRatesFetch!) < const Duration(minutes: 30)) {
      return _cachedDropRates!;
    }
    if (_rc == null) return _defaultDropRates();
    try {
      final rc = _rc!;
      _cachedDropRates =
          jsonDecode(rc.getString(_keyChestDropRates)) as Map<String, dynamic>;
      _lastDropRatesFetch = now;
      return _cachedDropRates!;
    } catch (e) {
      AppLogger().error(
        'RemoteConfig: chestDropRates parse failed, using defaults',
        e,
      );
      return _defaultDropRates();
    }
  }

  int get pityThreshold => _rc?.getInt(_keyPityThreshold) ?? 20;

  double get missionLegendaryRate =>
      (_rc?.getDouble(_keyMissionLegendaryRate) ?? 0.01).clamp(0, 1);
  double get missionGoldRate =>
      (_rc?.getDouble(_keyMissionGoldRate) ?? 0.06).clamp(0, 1);
  double get missionSilverRate {
    final raw = (_rc?.getDouble(_keyMissionSilverRate) ?? 0.20);
    final clamped = raw.clamp(0.0, 1.0);
    final sum = missionLegendaryRate + missionGoldRate + clamped;
    if (sum > 1.0) {
      final remaining = 1.0 - missionLegendaryRate - missionGoldRate;
      return remaining.clamp(0.0, 1.0);
    }
    return clamped;
  }

  double get evolutionBronzeToSilver =>
      (_rc?.getDouble(_keyEvolutionBronzeToSilver) ?? 0.45).clamp(0.0, 1.0);
  double get evolutionSilverToGold =>
      (_rc?.getDouble(_keyEvolutionSilverToGold) ?? 0.20).clamp(0.0, 1.0);
  double get evolutionGoldToLegendary =>
      (_rc?.getDouble(_keyEvolutionGoldToLegendary) ?? 0.03).clamp(0.0, 1.0);

  int get streakMaxFreezes => _rc?.getInt(_keyStreakMaxFreezes) ?? 7;

  /// BUG-073: Shop catalog from RemoteConfig (empty list = use hardcoded defaults)
  List<Map<String, dynamic>> get shopCatalog {
    final now = DateTime.now();
    if (_cachedShopCatalog != null &&
        _lastShopCatalogFetch != null &&
        now.difference(_lastShopCatalogFetch!) < const Duration(minutes: 30)) {
      return _cachedShopCatalog!;
    }
    if (_rc == null) return const [];
    try {
      final rc = _rc!;
      final raw = rc.getString(_keyShopCatalog);
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _cachedShopCatalog = decoded.cast<Map<String, dynamic>>();
        _lastShopCatalogFetch = now;
        return _cachedShopCatalog!;
      }
      _cachedShopCatalog = const [];
      _lastShopCatalogFetch = now;
      return const [];
    } catch (_) {
      _logger.warning('RemoteConfig: shopCatalog parse failed, using defaults');
      _cachedShopCatalog = const [];
      _lastShopCatalogFetch = now;
      return const [];
    }
  }

  List<Map<String, dynamic>> getDropRatesForChest(String chestType) {
    final rates = chestDropRates[chestType];
    if (rates is List) {
      final list = rates.cast<Map<String, dynamic>>();
      final totalWeight = list.fold<int>(
        0,
        (sum, r) => sum + (r['weight'] as int? ?? 0),
      );
      if (totalWeight <= 0) {
        // All weights are zero — use default rates to avoid division by zero
        final defaults = _defaultDropRates();
        final fallback = defaults[chestType];
        if (fallback is List) return fallback.cast<Map<String, dynamic>>();
        return const [];
      }
      if (totalWeight == 100) return list;
      final factor = 100 / totalWeight;
      return list
          .map(
            (r) => {
              ...r,
              'weight': ((r['weight'] as int? ?? 0) * factor).round(),
            },
          )
          .toList();
    }
    final defaults = _defaultDropRates();
    final fallback = defaults[chestType];
    if (fallback is List) return fallback.cast<Map<String, dynamic>>();
    return const [];
  }

  Map<String, dynamic> _defaultDropRates() => {
    'bronze': [
      {'category': 'gems', 'weight': 80},
      {'category': 'xp', 'weight': 19},
      {'category': 'cosmetic', 'weight': 1},
    ],
    'silver': [
      {'category': 'gems', 'weight': 55},
      {'category': 'booster', 'weight': 25},
      {'category': 'shield', 'weight': 10},
      {'category': 'cosmetic', 'weight': 10},
    ],
    'gold': [
      {'category': 'gems', 'weight': 35},
      {'category': 'booster', 'weight': 35},
      {'category': 'shield', 'weight': 20},
      {'category': 'title', 'weight': 10},
    ],
    'legendary': [
      {'category': 'title', 'weight': 30},
      {'category': 'gems', 'weight': 25},
      {'category': 'booster', 'weight': 20},
      {'category': 'shield', 'weight': 15},
      {'category': 'cosmetic', 'weight': 10},
    ],
  };
}
