import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/streak_repository.dart';
import '../repositories/inventory_repository.dart';
import '../repositories/sagen_pass_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/chest_repository.dart';
import '../repositories/gamification_repository.dart';
import '../repositories/learning_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/gem_repository.dart';
import '../services/analytics_service.dart';
import '../services/app_rating_service.dart';
import '../services/audio_service.dart';
import '../services/auth_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/connectivity_service.dart';
import '../services/economic_functions_service.dart';
import '../services/experience_service.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import '../services/gemini_api_client.dart';
import '../services/icon_manager.dart';
import '../services/sage_emotion_service.dart';
import '../services/screenshot_protection_service.dart';
import '../services/share_service.dart';
import '../services/storage_service.dart';
import '../services/streak_chest_service.dart';
import '../services/streak_service.dart';
import '../services/whats_new_service.dart';
import '../services/app_logger.dart';
import '../services/deep_link_service.dart';
import '../services/notification_service.dart';
import '../services/remote_config_service.dart';
import '../services/gamification_cloud_service.dart';
import '../services/achievement_service.dart';
import '../services/offline_queue_service.dart';
import '../services/device_tier.dart';
import '../services/chest_event_bus.dart';
import '../services/emotion_event_bus.dart';
import '../services/chest_evolution_service.dart';
import '../services/motivational_quotes_service.dart';
import '../services/chest_reward_roller.dart';
import '../services/learning_reward_service.dart';
import 'prefs_provider.dart';

/// Logger — default instance. Override in ProviderScope for production.
final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

/// StorageService se crea a partir de las SharedPreferences inyectadas.
final storageServiceProvider = Provider<StorageService>((ref) {
  final prefs = ref.read(prefsProvider);
  return StorageService(prefs);
});

final streakServiceProvider = Provider<StreakService>((ref) {
  final repo = ref.watch(streakRepositoryProvider);
  return StreakService(repo);
});

/// AuthService — default creates a fresh instance.
/// Override in ProviderScope to share a single instance with manual init.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(logger: ref.read(loggerProvider));
});

/// CloudSyncService — default creates a fresh instance.
/// Override in ProviderScope to share a single instance with manual init.
final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  return CloudSyncService(
    authService: ref.read(authServiceProvider),
    logger: ref.read(loggerProvider),
  );
});

/// FirestoreService — singleton wrapper.
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService.instance;
});

/// EconomicFunctionsService — singleton wrapper.
final economicFunctionsServiceProvider = Provider<EconomicFunctionsService>((ref) {
  return EconomicFunctionsService.instance;
});

// ── Repository providers ──────────────────────────────────────────
final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return StreakRepositoryImpl(prefs);
});

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return InventoryRepositoryImpl(prefs);
});

final sagenPassRepositoryProvider = Provider<SagenPassRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return SagenPassRepositoryImpl(prefs);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return PaymentRepositoryImpl(prefs);
});

final chestRepositoryProvider = Provider<ChestRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return ChestRepositoryImpl(prefs);
});

final gamificationRepositoryProvider = Provider<GamificationRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return GamificationRepositoryImpl(prefs);
});

final learningRepositoryProvider = Provider<LearningRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return LearningRepositoryImpl(prefs);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return ItemRepositoryImpl(prefs);
});

final gemRepositoryProvider = Provider<GemRepository>((ref) {
  final prefs = ref.read(prefsProvider);
  return GemRepositoryImpl(prefs);
});

final geminiApiClientProvider = Provider<GeminiApiClient>((ref) {
  return GeminiApiClient();
});

final aiServiceProvider = Provider<AiService>((ref) {
  final client = ref.watch(geminiApiClientProvider);
  return GeminiAiService(client);
});

final sageEmotionServiceProvider = Provider<SageEmotionService>((ref) {
  return SageEmotionService();
});

final streakChestServiceProvider = Provider<StreakChestService>((ref) {
  return StreakChestService();
});

final appRatingServiceProvider = Provider<AppRatingService>((ref) {
  return AppRatingService();
});

final screenshotProtectionServiceProvider = Provider<ScreenshotProtectionService>((ref) {
  return ScreenshotProtectionService();
});

final whatsNewServiceProvider = Provider<WhatsNewService>((ref) {
  return WhatsNewService(ref.read(prefsProvider));
});

// ── Singleton service providers ─────────────────────────────────────
// These wrap existing singleton instances so they can be overridden in
// tests via ProviderScope.overrideWithValue. New code should prefer
// `ref.read(analyticsServiceProvider)` over `AnalyticsService.instance`.

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService.instance;
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService.instance;
});

final experienceServiceProvider = Provider<ExperienceService>((ref) {
  return ExperienceService.instance;
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});


final shareServiceProvider = Provider<ShareService>((ref) {
  return ShareService.instance;
});

final iconManagerProvider = Provider<IconManager>((ref) {
  return IconManager.instance;
});

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService.instance;
});

final gamificationCloudServiceProvider = Provider<GamificationCloudService>((ref) {
  return GamificationCloudService.instance;
});

final achievementServiceProvider = Provider<AchievementService>((ref) {
  return AchievementService.instance;
});

final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  return OfflineQueueService.instance;
});

final lowEndDeviceDetectorProvider = Provider<LowEndDeviceDetector>((ref) {
  return LowEndDeviceDetector.instance;
});

final chestEventBusProvider = Provider<ChestEventBus>((ref) {
  return ChestEventBus.instance;
});

final emotionEventBusProvider = Provider<EmotionEventBus>((ref) {
  return EmotionEventBus.instance;
});

final chestEvolutionServiceProvider = Provider<ChestEvolutionService>((ref) {
  return ChestEvolutionService.instance;
});

final motivationalQuotesServiceProvider = Provider<MotivationalQuotesService>((ref) {
  return MotivationalQuotesService.instance;
});

final chestRewardRollerProvider = Provider<ChestRewardRoller>((ref) {
  return ChestRewardRoller.instance;
});

final learningRewardServiceProvider = Provider<LearningRewardService>((ref) {
  return LearningRewardService.instance;
});
