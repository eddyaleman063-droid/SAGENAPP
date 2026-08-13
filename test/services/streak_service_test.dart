import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/repositories/streak_repository.dart';
import 'package:sagen/services/streak_service.dart';

class MockStreakRepository extends Mock implements StreakRepository {}

void main() {
  group('StreakService', () {
    late MockStreakRepository repo;
    late StreakService service;

    setUp(() {
      repo = MockStreakRepository();
      service = StreakService(repo);

      when(() => repo.currentStreak).thenReturn(0);
      when(() => repo.longestStreak).thenReturn(0);
      when(() => repo.streakFreezes).thenReturn(0);
      when(() => repo.lastActivityDate).thenReturn('');
    });

    group('load', () {
      test('returns zero streak when no stored data', () {
        final status = service.load();

        expect(status.currentStreak, 0);
        expect(status.longestStreak, 0);
        expect(status.lastActivityDate, isNull);
        expect(status.streakFreezes, 0);
        expect(status.isAtRisk, false);
        expect(status.hasStreak, false);
        expect(status.isStreakFrozen, false);
        expect(status.tier, 'inactive');
      });

      test('loads saved streak values', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(() => repo.currentStreak).thenReturn(5);
        when(() => repo.longestStreak).thenReturn(10);
        when(() => repo.streakFreezes).thenReturn(2);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(yesterday.toIso8601String());

        final status = service.load();

        expect(status.currentStreak, 5);
        expect(status.longestStreak, 10);
        expect(status.streakFreezes, 2);
        expect(status.lastActivityDate, isNotNull);
        expect(status.tier, 'basic');
      });

      test('resets streak after 2+ days without freezes', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        when(() => repo.currentStreak).thenReturn(5);
        when(() => repo.longestStreak).thenReturn(10);
        when(() => repo.streakFreezes).thenReturn(0);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(threeDaysAgo.toIso8601String());

        final status = service.load();

        expect(status.currentStreak, 0);
        expect(status.longestStreak, 10);
        expect(status.hasStreak, false);
      });

      test('uses freeze for 2-day gap via checkIn', () {
        final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
        when(() => repo.currentStreak).thenReturn(5);
        when(() => repo.longestStreak).thenReturn(10);
        when(() => repo.streakFreezes).thenReturn(1);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(twoDaysAgo.toIso8601String());

        final status = service.checkIn();

        expect(status.currentStreak, 6);
        expect(status.streakFreezes, 0);
      });
    });

    group('checkIn', () {
      test('starts streak at 1 on first check-in', () {
        when(() => repo.currentStreak).thenReturn(0);
        when(() => repo.longestStreak).thenReturn(0);
        when(() => repo.streakFreezes).thenReturn(0);
        when(() => repo.lastActivityDate).thenReturn('');

        final status = service.checkIn();

        expect(status.currentStreak, 1);
        expect(status.longestStreak, 1);
        expect(status.hasStreak, true);
        expect(status.lastActivityDate, isNotNull);
      });

      test('increments streak for consecutive day check-in', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(() => repo.currentStreak).thenReturn(3);
        when(() => repo.longestStreak).thenReturn(5);
        when(() => repo.streakFreezes).thenReturn(0);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(yesterday.toIso8601String());

        final status = service.checkIn();

        expect(status.currentStreak, 4);
        expect(status.longestStreak, 5);
      });

      test('returns same streak for same-day check-in', () {
        final today = DateTime.now();
        when(() => repo.currentStreak).thenReturn(3);
        when(() => repo.longestStreak).thenReturn(5);
        when(() => repo.streakFreezes).thenReturn(0);
        when(() => repo.lastActivityDate).thenReturn(today.toIso8601String());

        final status = service.checkIn();

        expect(status.currentStreak, 3);
      });

      test('resets streak after gap without freezes', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        when(() => repo.currentStreak).thenReturn(5);
        when(() => repo.longestStreak).thenReturn(10);
        when(() => repo.streakFreezes).thenReturn(0);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(threeDaysAgo.toIso8601String());

        final status = service.checkIn();

        expect(status.currentStreak, 1);
        expect(status.longestStreak, 10);
      });

      test('limits freezes to 7', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(() => repo.currentStreak).thenReturn(5);
        when(() => repo.longestStreak).thenReturn(10);
        when(() => repo.streakFreezes).thenReturn(7);
        when(
          () => repo.lastActivityDate,
        ).thenReturn(yesterday.toIso8601String());

        service.checkIn();

        verify(
          () => repo.saveAll(
            currentStreak: 6,
            longestStreak: 10,
            lastActivityDate: any(named: 'lastActivityDate'),
            streakFreezes: 7,
          ),
        ).called(1);
      });
    });

    group('tier', () {
      test('returns inactive for streak 0', () {
        when(() => repo.currentStreak).thenReturn(0);
        final status = service.load();
        expect(status.tier, 'inactive');
      });

      test('returns basic for streak 1-6', () {
        when(() => repo.currentStreak).thenReturn(3);
        final status = service.load();
        expect(status.tier, 'basic');
      });

      test('returns glow for streak 7-13', () {
        when(() => repo.currentStreak).thenReturn(7);
        final status = service.load();
        expect(status.tier, 'glow');
      });

      test('returns particles for streak 14-29', () {
        when(() => repo.currentStreak).thenReturn(14);
        final status = service.load();
        expect(status.tier, 'particles');
      });

      test('returns crystal for streak 30-99', () {
        when(() => repo.currentStreak).thenReturn(30);
        final status = service.load();
        expect(status.tier, 'crystal');
      });

      test('returns legendary for streak 100+', () {
        when(() => repo.currentStreak).thenReturn(100);
        final status = service.load();
        expect(status.tier, 'legendary');
      });
    });

    group('shouldSendReminder', () {
      StreakStatus makeStatus({int streak = 5, bool atRisk = true}) {
        return StreakStatus(
          currentStreak: streak,
          longestStreak: streak,
          lastActivityDate: DateTime.now().subtract(const Duration(days: 1)),
          streakFreezes: 0,
          isAtRisk: atRisk,
          message: '',
          tier: 'basic',
        );
      }

      test('returns false when no streak', () {
        final status = makeStatus(streak: 0, atRisk: false);
        expect(service.shouldSendReminder(status), false);
      });

      test('returns false when not at risk', () {
        final status = makeStatus(atRisk: false);
        expect(service.shouldSendReminder(status), false);
      });

      test('returns true within 4 hours of midnight', () {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day + 1);
        final hoursUntilMidnight = midnight.difference(now).inHours;
        final expected = hoursUntilMidnight <= 4 && hoursUntilMidnight > 0;

        final status = makeStatus(streak: 5, atRisk: true);
        expect(service.shouldSendReminder(status), expected);
      });
    });

    group('StreakStatus', () {
      test('timeUntilMidnight is positive', () {
        const status = StreakStatus(
          currentStreak: 1,
          longestStreak: 1,
          streakFreezes: 0,
          isAtRisk: false,
          message: '',
          tier: 'basic',
        );
        expect(status.timeUntilMidnight.inSeconds, greaterThan(0));
      });
    });

    group('mocktail verification', () {
      test('checkIn calls repo getters and saveAll', () {
        when(() => repo.currentStreak).thenReturn(0);
        when(() => repo.longestStreak).thenReturn(0);
        when(() => repo.streakFreezes).thenReturn(0);
        when(() => repo.lastActivityDate).thenReturn('');

        service.checkIn();

        verify(() => repo.currentStreak).called(1);
        verify(() => repo.longestStreak).called(1);
        verify(() => repo.streakFreezes).called(1);
        verify(() => repo.lastActivityDate).called(1);
        verify(
          () => repo.saveAll(
            currentStreak: any(named: 'currentStreak'),
            longestStreak: any(named: 'longestStreak'),
            lastActivityDate: any(named: 'lastActivityDate'),
            streakFreezes: any(named: 'streakFreezes'),
          ),
        ).called(1);
      });

      test('load calls repo getters without saving', () {
        when(() => repo.currentStreak).thenReturn(0);
        when(() => repo.longestStreak).thenReturn(0);
        when(() => repo.streakFreezes).thenReturn(0);
        when(() => repo.lastActivityDate).thenReturn('');

        service.load();

        verify(() => repo.currentStreak).called(1);
        verify(() => repo.longestStreak).called(1);
        verify(() => repo.streakFreezes).called(1);
        verify(() => repo.lastActivityDate).called(1);
        verifyNever(
          () => repo.saveAll(
            currentStreak: any(named: 'currentStreak'),
            longestStreak: any(named: 'longestStreak'),
            lastActivityDate: any(named: 'lastActivityDate'),
            streakFreezes: any(named: 'streakFreezes'),
          ),
        );
      });
    });
  });
}
