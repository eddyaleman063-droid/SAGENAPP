import '../models/chest_type.dart';
import '../providers/learning_provider.dart';
import 'chest_event_bus.dart';
import 'chest_reward_roller.dart';
import 'app_logger.dart';

/// Manages streak-based chest drops and scheduling.
class StreakChestService {
  final ChestRewardRoller _roller;
  final ChestEventBus _eventBus;

  StreakChestService({ChestRewardRoller? roller, ChestEventBus? eventBus})
    : _roller = roller ?? ChestRewardRoller.instance,
      _eventBus = eventBus ?? ChestEventBus.instance;

  bool _checking = false;
  final _logger = AppLogger();

  Future<void> checkAndReward({
    required int oldStreak,
    required int newStreak,
    required LearningNotifier learning,
  }) async {
    if (_checking) return;
    _checking = true;
    try {
      if (newStreak <= oldStreak) return;
      if (newStreak != 7 &&
          newStreak != 14 &&
          newStreak != 30 &&
          newStreak != 100) {
        return;
      }

      final t = newStreak == 7
          ? ChestType.silver
          : newStreak == 14
          ? ChestType.gold
          : newStreak == 30
          ? ChestType.gold
          : ChestType.legendary;

      final reward = await _roller.roll(
        t,
        contextId: 'streak_$newStreak',
        source: 'streak',
      );

      // rollChestDrop ya acredita el XP y las gemas del cofre en el servidor;
      // solo se reflejan en el estado local para no duplicar la recompensa.
      learning.applyServerChestReward(reward.xp, reward.gems);

      _eventBus.fire(
        ChestRewardData(
          type: reward.chestType ?? t,
          xp: reward.xp,
          gems: reward.gems,
          streakShields: reward.streakShields,
          xpBoost: reward.xpBoost,
          specialItems: reward.specialItems,
          cosmeticUnlocks: reward.cosmeticUnlocks,
          source: 'streak',
        ),
      );
    } catch (e, stack) {
      _logger.error('StreakChestService: failed to check/reward', e, stack);
    } finally {
      _checking = false;
    }
  }
}
