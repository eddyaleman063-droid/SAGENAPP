import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/streak_provider.dart';
import 'package:sagen/services/streak_service.dart';

StreakState _state(int streak) => StreakState(
      status: StreakStatus(
        currentStreak: streak,
        longestStreak: streak,
        lastActivityDate: DateTime.now(),
        streakFreezes: 0,
        isAtRisk: false,
        message: '',
        tier: 'bronze',
      ),
      totalCheckIns: streak,
      perfectWeeks: 0,
      missionCompleted: false,
      weeklyStats: {},
      heatmapData: {},
      monthlyData: {},
      streakHistory: [],
      emotionalMessages: const [],
    );

void main() {
  group('streakMultiplier', () {
    test('returns 1.0 for streak < 10', () {
      expect(_state(5).streakMultiplier, 1.0);
    });

    test('returns 1.0 for streak 0', () {
      expect(_state(0).streakMultiplier, 1.0);
    });

    test('returns 1.1 for streak 10', () {
      expect(_state(10).streakMultiplier, 1.1);
    });

    test('returns 1.2 for streak 20', () {
      expect(_state(20).streakMultiplier, 1.2);
    });

    test('returns 2.0 max for streak 100+', () {
      expect(_state(100).streakMultiplier, 2.0);
    });

    test('returns 1.3 for streak 30', () {
      expect(_state(30).streakMultiplier, 1.3);
    });
  });

  group('streakMultiplier with VIP-like scenarios', () {
    test('streakMultiplier is base when no VIP concept in StreakState', () {
      final s = _state(10);
      expect(s.streakMultiplier, 1.1);
    });
  });

  group('StreakState.copyWith', () {
    test('preserves all fields when none changed', () {
      final s = _state(10);
      final copy = s.copyWith();
      expect(copy.currentStreak, 10);
      expect(copy.totalCheckIns, 10);
    });

    test('updates specific fields', () {
      final s = _state(10);
      final copy = s.copyWith(totalCheckIns: 20);
      expect(copy.totalCheckIns, 20);
      expect(copy.currentStreak, 10);
    });
  });

  group('StreakState getters', () {
    test('currentStreak delegates to status', () {
      expect(_state(7).currentStreak, 7);
    });

    test('isStreakFrozen returns false when no freezes', () {
      expect(_state(5).isStreakFrozen, isFalse);
    });
  });
}
