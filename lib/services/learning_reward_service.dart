import '../models/chest_reward.dart';
import '../models/chest_type.dart';
import 'chest_event_bus.dart';
import 'chest_reward_roller.dart';
import 'audio_service.dart';
import 'emotion_event_bus.dart';

/// Calculates XP and gem rewards for lesson completion.
class LearningRewardService {
  final ChestRewardRoller _roller;
  final ChestEventBus _eventBus;
  final AudioService _audio;
  final EmotionEventBus _emotionBus;

  LearningRewardService({
    ChestRewardRoller? roller,
    ChestEventBus? eventBus,
    AudioService? audio,
    EmotionEventBus? emotionBus,
  })  : _roller = roller ?? ChestRewardRoller.instance,
        _eventBus = eventBus ?? ChestEventBus.instance,
        _audio = audio ?? AudioService.instance,
        _emotionBus = emotionBus ?? EmotionEventBus.instance;

  static final LearningRewardService instance = LearningRewardService();

  /// Determina el tipo de cofre segun el total de lecciones completadas.
  static ChestType chestTypeFor(int lessonsCompleted) {
    if (lessonsCompleted % 15 == 0) return ChestType.legendary;
    if (lessonsCompleted % 5 == 0) return ChestType.gold;
    if (lessonsCompleted % 3 == 0) return ChestType.silver;
    return ChestType.bronze;
  }

  /// Determina el tipo de cofre y retorna [ChestRewardData] listo para
  /// ser disparado por el [ChestEventBus].
  Future<ChestRewardData?> rollChest({
    required int lessonsCompleted,
    required double totalDonated,
    required int xp,
    bool luckBoostActive = false,
  }) async {
    if (!ChestSystem.shouldUnlockChest(lessonsCompleted)) return null;

    final type = chestTypeFor(lessonsCompleted);
    final reward = await _roller.roll(type, luckBoostActive: luckBoostActive);

    return ChestRewardData(
      type: type,
      xp: reward.xp,
      streakShields: reward.streakShields,
      xpBoost: reward.xpBoost,
      specialItems: reward.specialItems,
      cosmeticUnlocks: reward.cosmeticUnlocks,
      source: 'lesson',
    );
  }

  /// Dispara los eventos visuales/sonoros post-recompensa.
  void emitRewardEffects(ChestRewardData data) {
    _eventBus.fire(data);
    _audio.playChestOpen();
    _emotionBus.fire(EmotionEventType.lessonCompleted);
  }
}
