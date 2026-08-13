import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_reward.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/providers/learning_provider.dart';
import 'package:sagen/services/chest_event_bus.dart';
import 'package:sagen/services/chest_reward_roller.dart';
import 'package:sagen/services/streak_chest_service.dart';

class _FakeLearning extends LearningNotifier {
  int xp = 0;
  String? lastReason;

  @override
  Future<void> addXp(int amount, {String? reason, String? lessonId}) async {
    xp += amount;
    lastReason = reason;
  }
}

class _FakeRoller extends ChestRewardRoller {
  _FakeRoller(this._result, {this.gate});

  final ChestReward _result;
  final Completer<void>? gate;

  @override
  Future<ChestReward> roll(
    ChestType type, {
    bool luckBoostActive = false,
  }) async {
    if (gate != null) await gate!.future;
    return _result;
  }
}

class _ThrowingRoller extends ChestRewardRoller {
  @override
  Future<ChestReward> roll(
    ChestType type, {
    bool luckBoostActive = false,
  }) async {
    throw Exception('boom');
  }
}

void main() {
  final events = <ChestRewardData>[];
  late StreamSubscription<ChestRewardData> sub;
  late _FakeLearning learning;

  setUp(() {
    events.clear();
    ChestEventBus.instance.reset();
    sub = ChestEventBus.instance.events.listen(events.add);
    learning = _FakeLearning();
  });

  tearDown(() async {
    await sub.cancel();
    ChestEventBus.instance.reset();
  });

  ChestRewardData? singleEvent() => events.isEmpty ? null : events.first;

  Future<void> flush() => pumpEventQueue();

  test('does not reward when new streak is lower than old', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 25)),
    );
    await service.checkAndReward(
      oldStreak: 7,
      newStreak: 3,
      learning: learning,
    );
    expect(learning.xp, 0);
    expect(events, isEmpty);
  });

  test('does not reward on non-milestone streaks', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 25)),
    );
    await service.checkAndReward(
      oldStreak: 3,
      newStreak: 8,
      learning: learning,
    );
    expect(learning.xp, 0);
    expect(events, isEmpty);
  });

  test('rewards silver chest at streak 7', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 30, streakShields: 1)),
    );
    await service.checkAndReward(
      oldStreak: 6,
      newStreak: 7,
      learning: learning,
    );
    await flush();
    expect(learning.xp, 30);
    expect(learning.lastReason, 'streak_chest');
    expect(singleEvent()?.type, ChestType.silver);
    expect(singleEvent()?.xp, 30);
    expect(singleEvent()?.streakShields, 1);
    expect(singleEvent()?.source, 'streak');
  });

  test('rewards gold chest at streak 14', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 40)),
    );
    await service.checkAndReward(
      oldStreak: 13,
      newStreak: 14,
      learning: learning,
    );
    await flush();
    expect(singleEvent()?.type, ChestType.gold);
  });

  test('rewards gold chest at streak 30', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 45)),
    );
    await service.checkAndReward(
      oldStreak: 29,
      newStreak: 30,
      learning: learning,
    );
    await flush();
    expect(singleEvent()?.type, ChestType.gold);
  });

  test('rewards legendary chest at streak 100', () async {
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 60)),
    );
    await service.checkAndReward(
      oldStreak: 99,
      newStreak: 100,
      learning: learning,
    );
    await flush();
    expect(singleEvent()?.type, ChestType.legendary);
  });

  test('propagates special drops in the event', () async {
    final service = StreakChestService(
      roller: _FakeRoller(
        const ChestReward(
          xp: 35,
          xpBoost: true,
          specialItems: [SpecialItemType.phoenixFeather],
          cosmeticUnlocks: [SpecialItemType.focusElixir],
        ),
      ),
    );
    await service.checkAndReward(
      oldStreak: 13,
      newStreak: 14,
      learning: learning,
    );
    await flush();
    final event = singleEvent();
    expect(event?.xpBoost, isTrue);
    expect(event?.specialItems, const [SpecialItemType.phoenixFeather]);
    expect(event?.cosmeticUnlocks, const [SpecialItemType.focusElixir]);
  });

  test('does not crash when roller throws', () async {
    final service = StreakChestService(roller: _ThrowingRoller());
    await service.checkAndReward(
      oldStreak: 6,
      newStreak: 7,
      learning: learning,
    );
    expect(learning.xp, 0);
    expect(events, isEmpty);
  });

  test('ignores concurrent calls while a check is in progress', () async {
    final gate = Completer<void>();
    final service = StreakChestService(
      roller: _FakeRoller(const ChestReward(xp: 30), gate: gate),
    );
    final first = service.checkAndReward(
      oldStreak: 6,
      newStreak: 7,
      learning: learning,
    );
    await service.checkAndReward(
      oldStreak: 6,
      newStreak: 7,
      learning: learning,
    );
    gate.complete();
    await first;
    expect(learning.xp, 30);
  });
}
