import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Provider declarations ──────────────────────────────────────────
import 'auth_provider.dart';
import 'dashboard_provider.dart';
import 'energy_provider.dart';
import 'inventory_provider.dart';
import 'language_provider.dart';
import 'learning_memory_provider.dart';
import 'mission_provider.dart';
import 'protection_provider.dart';
import 'review_provider.dart';
import 'sage_ai_provider.dart';
import 'session_provider.dart';
import 'shop_provider.dart';
import 'streak_provider.dart';
import 'theme_provider.dart';
import 'achievement_provider.dart';
import 'item_provider.dart';
import 'gem_provider.dart';

// ── Re-exports ─────────────────────────────────────────────────────
// Each provider file is exported once, from its canonical location.
export 'achievement_provider.dart';
export 'auth_provider.dart';
export 'dashboard_provider.dart';
export 'energy_provider.dart';
export 'first_lesson_provider.dart';
export 'gamification_provider.dart';
export 'hardware_tier_provider.dart';
export 'inventory_provider.dart';
export 'language_provider.dart';
export 'leaderboard_provider.dart';
export 'learning_memory_provider.dart';
export 'learning_provider.dart';
export 'mission_provider.dart';
export 'onboarding_wizard_provider.dart';
export 'prefs_provider.dart';
export 'protection_provider.dart';
export 'registration_funnel_provider.dart';
export 'review_provider.dart';
export 'sage_ai_provider.dart';
export 'service_providers.dart';
export 'session_provider.dart';
export 'shop_provider.dart';
export 'streak_provider.dart';
export 'theme_provider.dart';
export 'item_provider.dart';
export 'gem_provider.dart';

// ── Notifier providers ─────────────────────────────────────────────

final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(ThemeNotifier.new);

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

final streakProvider = NotifierProvider<StreakNotifier, StreakState>(StreakNotifier.new);

final protectionProvider = NotifierProvider<ProtectionNotifier, ProtectionState>(ProtectionNotifier.new);

final achievementProvider = NotifierProvider<AchievementNotifier, AchievementState>(AchievementNotifier.new);

final inventoryProvider = NotifierProvider<InventoryNotifier, InventoryState>(InventoryNotifier.new);

final reviewProvider = NotifierProvider<ReviewNotifier, ReviewState>(ReviewNotifier.new);

final languageProvider = NotifierProvider<LanguageNotifier, LanguageState>(LanguageNotifier.new);

final learningMemoryProvider = NotifierProvider<LearningMemoryNotifier, LearningMemoryState>(LearningMemoryNotifier.new);

final missionProvider = NotifierProvider<MissionNotifier, MissionState>(MissionNotifier.new);

final shopProvider = NotifierProvider<ShopNotifier, ShopState>(ShopNotifier.new);

final energyProvider = NotifierProvider<EnergyNotifier, EnergyState>(EnergyNotifier.new);

final sageAiProvider = NotifierProvider.autoDispose<SageAiNotifier, SageAiChatState>(SageAiNotifier.new);

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(DashboardNotifier.new);

final sessionProvider = NotifierProvider.autoDispose<SessionNotifier, SessionState>(SessionNotifier.new);

final itemProvider = NotifierProvider<ItemNotifier, ItemState>(ItemNotifier.new);

final gemProvider = NotifierProvider<GemNotifier, GemState>(GemNotifier.new);

final assessmentLevelProvider = StateProvider.autoDispose<int?>((ref) => null);
