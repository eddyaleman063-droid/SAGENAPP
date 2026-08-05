import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/gamification_repository.dart';
import 'learning_provider.dart';
import 'service_providers.dart';

class GamificationState {
  final bool hasUnclaimedChest;
  final int secondsUntilMidnight;
  final int dailyMissionsCompleted;

  const GamificationState({
    this.hasUnclaimedChest = false,
    this.secondsUntilMidnight = 0,
    this.dailyMissionsCompleted = 0,
  });

  GamificationState copyWith({
    bool? hasUnclaimedChest,
    int? secondsUntilMidnight,
    int? dailyMissionsCompleted,
  }) {
    return GamificationState(
      hasUnclaimedChest: hasUnclaimedChest ?? this.hasUnclaimedChest,
      secondsUntilMidnight: secondsUntilMidnight ?? this.secondsUntilMidnight,
      dailyMissionsCompleted: dailyMissionsCompleted ?? this.dailyMissionsCompleted,
    );
  }
}

class GamificationNotifier extends Notifier<GamificationState> {
  late final GamificationRepository _repo;
  Set<String> _countedMissions = {};
  Timer? _midnightTimer;
  bool _disposed = false;

  @override
  GamificationState build() {
    _repo = ref.read(gamificationRepositoryProvider);
    _countedMissions = _repo.getCountedMissions();
    _repo.checkMidnightReset();
    _startMidnightTimer();
    ref.onDispose(() {
      _disposed = true;
      _midnightTimer?.cancel();
    });
    return GamificationState(
      hasUnclaimedChest: _repo.canClaimDailyChest,
      secondsUntilMidnight: _repo.secondsUntilMidnight,
    );
  }

  void _startMidnightTimer() {
    _midnightTimer?.cancel();
    // Check every 5 minutes instead of 30 seconds to reduce CPU usage
    _midnightTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final newSeconds = _repo.secondsUntilMidnight;
      if (newSeconds != state.secondsUntilMidnight) {
        state = state.copyWith(secondsUntilMidnight: newSeconds);
      }
      if (newSeconds <= 0) {
        _repo.checkMidnightReset();
        _countedMissions.clear();
        _repo.saveCountedMissions(_countedMissions);
        state = state.copyWith(
          hasUnclaimedChest: _repo.canClaimDailyChest,
        );
      }
    });
  }

  Future<int> claimDailyChest() async {
    if (_disposed || !state.hasUnclaimedChest) return 0;
    try {
      if (_disposed) return 0;
      await ref.read(learningProvider.notifier).addXp(10, reason: 'daily_chest');
    } catch (e) {
      return 0;
    }
    _repo.claimDailyChest();
    state = state.copyWith(
      hasUnclaimedChest: false,
    );
    return 10;
  }

  void incrementMission(String missionId, {int amount = 1}) {
    if (missionId.isEmpty) return;
    final key = '$missionId:$amount';
    if (_countedMissions.contains(key)) return;
    _countedMissions.add(key);
    _repo.saveCountedMissions(_countedMissions);
    _repo.incrementMission(missionId, amount: amount);
    state = state.copyWith(
      dailyMissionsCompleted: state.dailyMissionsCompleted + amount,
    );
  }
}

final gamificationProvider = NotifierProvider<GamificationNotifier, GamificationState>(GamificationNotifier.new);
