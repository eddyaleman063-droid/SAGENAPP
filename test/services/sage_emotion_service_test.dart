import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/sage_emotion_service.dart';

void main() {
  final service = SageEmotionService();
  const user = SageUserContext(
    userName: 'Alex',
    userLevel: 4,
    currentStreak: 8,
    lessonsCompleted: 15,
  );

  group('context factories', () {
    test('forHome returns calm with greeting', () {
      final ctx = service.forHome(ctx: user);
      expect(ctx.emotion, SageEmotion.calm);
      expect(ctx.message, startsWith('Alex,'));
    });

    test('forTaskComplete is excited and praises long streaks', () {
      final ctx = service.forTaskComplete(ctx: user);
      expect(ctx.emotion, SageEmotion.excited);
      expect(ctx.message, startsWith('Alex,'));
      expect(ctx.message, contains('8'));
    });

    test('forTaskComplete omits streak praise under threshold', () {
      final ctx = service.forTaskComplete(
        ctx: const SageUserContext(userName: 'Ana', currentStreak: 3),
      );
      expect(ctx.emotion, SageEmotion.excited);
      expect(ctx.message, isNot(contains('streak is amazing')));
    });

    test('forXpGain is happy and hints about level', () {
      final ctx = service.forXpGain(ctx: user);
      expect(ctx.emotion, SageEmotion.happy);
      expect(ctx.message, contains('4'));
    });

    test('forLearningQuestion is thinking', () {
      final ctx = service.forLearningQuestion(ctx: user);
      expect(ctx.emotion, SageEmotion.thinking);
      expect(ctx.message, contains('Alex'));
    });

    test('forOnboarding is curious', () {
      final ctx = service.forOnboarding(ctx: user);
      expect(ctx.emotion, SageEmotion.curious);
    });

    test('forExplanation is serious', () {
      final ctx = service.forExplanation(ctx: user);
      expect(ctx.emotion, SageEmotion.serious);
    });

    test('forLoading and forInitializing map correctly', () {
      expect(service.forLoading().emotion, SageEmotion.thinking);
      expect(service.forInitializing().emotion, SageEmotion.calm);
    });

    test('forHighStreak mentions the streak days', () {
      final ctx = service.forHighStreak(ctx: user);
      expect(ctx.emotion, SageEmotion.excited);
      expect(ctx.message, contains('8 days'));
    });

    test('forStreakAtRisk is worried and urgent for long streaks', () {
      final ctx = service.forStreakAtRisk(ctx: user);
      expect(ctx.emotion, SageEmotion.worried);
      expect(ctx.message, contains('8 days'));
    });

    test('forStreakLost is sad and encourages experienced users', () {
      final ctx = service.forStreakLost(ctx: user);
      expect(ctx.emotion, SageEmotion.sadSoft);
      expect(ctx.message, contains('start again'));
    });

    test('forAchievement, forCelebration and forSuccess', () {
      expect(service.forAchievement(ctx: user).emotion, SageEmotion.excited);
      expect(
        service.forCelebration(ctx: user).emotion,
        SageEmotion.excitedWave,
      );
      expect(service.forSuccess(ctx: user).emotion, SageEmotion.happy);
    });

    test('forError prefers the detail message', () {
      final ctx = service.forError('Algo falló');
      expect(ctx.emotion, SageEmotion.worried);
      expect(ctx.message, 'Algo falló');
    });

    test('forError falls back to localized message when no detail', () {
      final ctx = service.forError(null);
      expect(ctx.message, isNotEmpty);
    });

    test(
      'forCriticalError, forEasterEgg, forEmptyState, forRetry, forReading',
      () {
        expect(service.forCriticalError().emotion, SageEmotion.serious);
        expect(service.forEasterEgg().emotion, SageEmotion.wink);
        expect(service.forEmptyState(ctx: user).message, startsWith('Alex,'));
        expect(service.forRetry().emotion, SageEmotion.curious);
        expect(service.forReading().emotion, SageEmotion.reading);
      },
    );
  });

  group('localized messages', () {
    test('uses provided AppLocalizations for messages', () {
      final l10n = lookupAppLocalizations(const Locale('es'));
      final ctx = service.forHome(ctx: user, l10n: l10n);
      expect(ctx.message, contains('Alex,'));
      expect(ctx.message, isNot(startsWith('Alex, Welcome back')));
    });
  });

  group('emotion helpers', () {
    test('emotionSize returns 100 for reading/thinking', () {
      expect(service.emotionSize(SageEmotion.reading), 100);
      expect(service.emotionSize(SageEmotion.thinking), 100);
    });

    test('emotionSize returns 110 for excited emotions', () {
      expect(service.emotionSize(SageEmotion.excited), 110);
      expect(service.emotionSize(SageEmotion.excitedWave), 110);
      expect(service.emotionSize(SageEmotion.happyWings), 110);
    });

    test('emotionSize defaults to 90', () {
      expect(service.emotionSize(SageEmotion.calm), 90);
      expect(service.emotionSize(SageEmotion.wink), 90);
    });

    test('shouldAnimateEmotionChange returns false for identical emotions', () {
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.happy,
          SageEmotion.happy,
        ),
        isFalse,
      );
    });

    test('animates on crying/furious transitions', () {
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.crying,
          SageEmotion.calm,
        ),
        isTrue,
      );
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.furious,
          SageEmotion.sad,
        ),
        isTrue,
      );
    });

    test('does not animate within neutral or close sets', () {
      expect(
        service.shouldAnimateEmotionChange(SageEmotion.calm, SageEmotion.happy),
        isFalse,
      );
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.excited,
          SageEmotion.laughing,
        ),
        isFalse,
      );
    });

    test('isSignificantMoodShift detects intense emotions', () {
      expect(
        service.isSignificantMoodShift(SageEmotion.calm, SageEmotion.furious),
        isTrue,
      );
      expect(
        service.isSignificantMoodShift(SageEmotion.crying, SageEmotion.calm),
        isTrue,
      );
      expect(
        service.isSignificantMoodShift(SageEmotion.happy, SageEmotion.excited),
        isFalse,
      );
    });

    test('canIdleBreathe allows calm idle emotions', () {
      expect(service.canIdleBreathe(SageEmotion.calm), isTrue);
      expect(service.canIdleBreathe(SageEmotion.whistling), isTrue);
      expect(service.canIdleBreathe(SageEmotion.wink), isFalse);
      expect(service.canIdleBreathe(SageEmotion.excited), isFalse);
    });
  });

  group('asset paths', () {
    test('every emotion maps to a png asset path', () {
      for (final emotion in SageEmotion.values) {
        expect(
          emotion.assetPath,
          startsWith('assets/mascot/emotions/sage_'),
          reason: 'Unexpected path for $emotion',
        );
        expect(emotion.assetPath, endsWith('.png'));
      }
    });

    test('duplicate file names are intentional aliases', () {
      expect(SageEmotion.happy.assetPath, SageEmotion.happyWings.assetPath);
      expect(SageEmotion.excited.assetPath, SageEmotion.excitedWave.assetPath);
    });
  });
}
