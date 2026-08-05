import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sagen/l10n/app_localizations.dart';

enum SageEmotion {
  calm,
  happy,
  curious,
  thinking,
  reading,
  serious,
  neutral,
  excited,
  confused,
  worried,
  sadSoft,
  sad,
  crying,
  depressed,
  angry,
  furious,
  shocked,
  sleepy,
  whistling,
  pointLeft,
  pointRight,
  wink,
  shy,
  laughing,
  singing,
  scared,
  embarrassed,
  annoyed,
  unmotivated,
  distressed,
  aggressive,
  lol,
  happyWings,
  excitedWave,
  surprisedWings,
  celebrating,
  proud,
  panic,
}

extension SageEmotionX on SageEmotion {
  String get assetPath => 'assets/mascot/emotions/$_fileName.png';

  String get _fileName {
    switch (this) {
      case SageEmotion.calm: return 'sage_calm';
      case SageEmotion.happy: return 'sage_happy_wings';
      case SageEmotion.curious: return 'sage_curious';
      case SageEmotion.thinking: return 'sage_thinking';
      case SageEmotion.reading: return 'sage_reading';
      case SageEmotion.serious: return 'sage_serious';
      case SageEmotion.neutral: return 'sage_neutral';
      case SageEmotion.excited: return 'sage_excited_wave';
      case SageEmotion.confused: return 'sage_confused';
      case SageEmotion.worried: return 'sage_worried';
      case SageEmotion.sadSoft: return 'sage_sad_soft';
      case SageEmotion.sad: return 'sage_sad';
      case SageEmotion.crying: return 'sage_crying';
      case SageEmotion.depressed: return 'sage_depressed';
      case SageEmotion.angry: return 'sage_angry';
      case SageEmotion.furious: return 'sage_furious_1';
      case SageEmotion.shocked: return 'sage_shocked';
      case SageEmotion.sleepy: return 'sage_sleeping';
      case SageEmotion.whistling: return 'sage_whistling';
      case SageEmotion.pointLeft: return 'sage_point_left';
      case SageEmotion.pointRight: return 'sage_point_right';
      case SageEmotion.wink: return 'sage_wink';
      case SageEmotion.shy: return 'sage_shy';
      case SageEmotion.laughing: return 'sage_laughing';
      case SageEmotion.singing: return 'sage_singing';
      case SageEmotion.scared: return 'sage_scared';
      case SageEmotion.embarrassed: return 'sage_embarrassed';
      case SageEmotion.annoyed: return 'sage_annoyed';
      case SageEmotion.unmotivated: return 'sage_unmotivated';
      case SageEmotion.distressed: return 'sage_distressed';
      case SageEmotion.aggressive: return 'sage_aggressive';
      case SageEmotion.lol: return 'sage_lol';
      case SageEmotion.happyWings: return 'sage_happy_wings';
      case SageEmotion.excitedWave: return 'sage_excited_wave';
      case SageEmotion.surprisedWings: return 'sage_surprised_wings';
      case SageEmotion.celebrating: return 'sage_celebrating';
      case SageEmotion.proud: return 'sage_proud';
      case SageEmotion.panic: return 'sage_panic';
    }
  }
}

/// Contextual data for Sage emotion calculation.
class SageContext {
  final SageEmotion emotion;
  final String? message;

  const SageContext({required this.emotion, this.message});
}

/// User-specific context for Sage emotion computation.
class SageUserContext {
  final String userName;
  final int userLevel;
  final int currentStreak;
  final int lessonsCompleted;

  const SageUserContext({
    this.userName = '',
    this.userLevel = 1,
    this.currentStreak = 0,
    this.lessonsCompleted = 0,
  });
}

/// Determines mascot emotion based on user context.
class SageEmotionService {
  SageEmotionService();

  final Set<SageEmotion> _precached = {};
  bool _initialized = false;

  static const _coreEmotions = {
    SageEmotion.calm,
    SageEmotion.happy,
    SageEmotion.excited,
    SageEmotion.thinking,
    SageEmotion.serious,
    SageEmotion.worried,
    SageEmotion.excitedWave,
    SageEmotion.happyWings,
  };

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await precacheCore();
  }

  Future<void> precacheCore() async {
    await Future.wait(_coreEmotions.map(_precache));
  }

  Future<void> ensurePrecached(SageEmotion emotion) async {
    if (_precached.contains(emotion)) return;
    await _precache(emotion);
  }

  Future<void> _precache(SageEmotion emotion) async {
    if (_precached.contains(emotion)) return;
    final provider = AssetImage(emotion.assetPath);
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    final listener = ImageStreamListener(
      (image, sync) {
        image.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) completer.complete();
      },
    );
    stream.addListener(listener);
    bool removed = false;
    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (!removed) {
            stream.removeListener(listener);
            removed = true;
          }
        },
      );
    } finally {
      if (!removed) {
        stream.removeListener(listener);
      }
    }
    _precached.add(emotion);
  }

  String _greeting(SageUserContext? ctx) {
    if (ctx == null || ctx.userName.isEmpty) return '';
    return '${ctx.userName}, ';
  }

  SageContext forHome({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.calm, message: l10n?.sageWelcomeBack(name) ?? '$name Welcome back!');
  }

  SageContext forTaskComplete({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    final extra = ctx != null && ctx.currentStreak > 5
        ? (l10n?.sageStreakAmazing(ctx.currentStreak) ?? ' Your ${ctx.currentStreak}-day streak is amazing!')
        : '';
    return SageContext(emotion: SageEmotion.excited, message: l10n?.sageGreatJob(extra, name) ?? '$name Great job!$extra');
  }

  SageContext forXpGain({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    final levelHint = ctx != null && ctx.userLevel > 1
        ? (l10n?.sageLevelHint(ctx.userLevel) ?? ' Level ${ctx.userLevel} is near.')
        : '';
    return SageContext(emotion: SageEmotion.happy, message: l10n?.sageAdvancing(levelHint, name) ?? '${name}Keep progressing.$levelHint');
  }

  SageContext forLearningQuestion({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.thinking, message: l10n?.sageWhatDoYouThink(name) ?? '$name What do you think is correct?');
  }

  SageContext forOnboarding({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.curious, message: l10n?.sageTellMeMore(name) ?? '${name}Tell me more about yourself');
  }

  SageContext forExplanation({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.serious, message: l10n?.sageImportant ?? 'This is very important');
  }

  SageContext forLoading({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.thinking, message: l10n?.sageLoading ?? 'Give me a second...');
  }

  SageContext forInitializing({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.calm, message: l10n?.sagePreparing ?? 'Preparing everything for you');
  }

  SageContext forHighStreak({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    final days = ctx != null && ctx.currentStreak > 0
        ? (l10n?.sageHighStreakDays(ctx.currentStreak) ?? ' ${ctx.currentStreak} days in a row.')
        : '';
    return SageContext(emotion: SageEmotion.excited, message: l10n?.sageImpressiveStreak(days, name) ?? '$name Impressive streak!$days');
  }

  SageContext forStreakAtRisk({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    final urgency = ctx != null && ctx.currentStreak >= 7
        ? (l10n?.sageStreakAtRisk(ctx.currentStreak) ?? " Don't lose ${ctx.currentStreak} days of effort!")
        : '';
    return SageContext(emotion: SageEmotion.worried, message: l10n?.sageStreakAtRiskMessage(name, urgency) ?? "$name Don't lose your streak!$urgency");
  }

  SageContext forStreakLost({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    final encouragement = ctx != null && ctx.lessonsCompleted > 10
        ? (l10n?.sageStreakLost ?? " You have the knowledge to start again.")
        : '';
    return SageContext(emotion: SageEmotion.sadSoft, message: l10n?.sageStreakLostMessage(encouragement, name) ?? '$name The streak has been lost.$encouragement');
  }

  SageContext forAchievement({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.excited, message: l10n?.sageAchievementUnlocked(name) ?? '$name Achievement unlocked!');
  }

  SageContext forCelebration({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.excitedWave, message: l10n?.sageCongratulations(name) ?? '$name Congratulations!');
  }

  SageContext forError(String? detail, {SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(
      emotion: SageEmotion.worried,
      message: detail ?? l10n?.sageSomethingWrong ?? 'Something went wrong',
    );
  }

  SageContext forCriticalError({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.serious, message: l10n?.sageCriticalError ?? 'Critical error');
  }

  SageContext forEasterEgg({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.wink, message: l10n?.sageEasterEgg ?? 'Did you see that?');
  }

  SageContext forEmptyState({SageUserContext? ctx, AppLocalizations? l10n}) {
    final name = _greeting(ctx);
    return SageContext(emotion: SageEmotion.calm, message: l10n?.sageEmptyState(name) ?? '$name Nothing here yet');
  }

  SageContext forRetry({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.curious, message: l10n?.sageTryAgain ?? 'Shall we try again?');
  }

  SageContext forSuccess({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.happy, message: l10n?.sagePerfect ?? 'Perfect!');
  }

  SageContext forReading({SageUserContext? ctx, AppLocalizations? l10n}) {
    return SageContext(emotion: SageEmotion.reading, message: l10n?.sageReadCarefully ?? 'Read carefully');
  }

  double emotionSize(SageEmotion emotion) {
    if (emotion == SageEmotion.reading || emotion == SageEmotion.thinking) return 100;
    if (emotion == SageEmotion.excited || emotion == SageEmotion.excitedWave || emotion == SageEmotion.happyWings) return 110;
    return 90;
  }

  bool shouldAnimateEmotionChange(SageEmotion old, SageEmotion next) {
    if (old == next) return false;
    if (old == SageEmotion.crying || next == SageEmotion.crying) return true;
    if (old == SageEmotion.furious || next == SageEmotion.furious) return true;
    final neutralSet = {SageEmotion.calm, SageEmotion.neutral, SageEmotion.happy};
    if (neutralSet.contains(old) && neutralSet.contains(next)) return false;
    final closeSet = {
      SageEmotion.happy, SageEmotion.happyWings, SageEmotion.excited, SageEmotion.excitedWave,
      SageEmotion.laughing, SageEmotion.lol,
    };
    if (closeSet.contains(old) && closeSet.contains(next)) return false;
    final negativeSet = {
      SageEmotion.worried, SageEmotion.sadSoft, SageEmotion.crying,
      SageEmotion.depressed, SageEmotion.angry, SageEmotion.annoyed,
    };
    if (negativeSet.contains(old) && negativeSet.contains(next)) return false;
    return true;
  }

  bool isSignificantMoodShift(SageEmotion old, SageEmotion next) {
    final intense = {
      SageEmotion.furious, SageEmotion.aggressive, SageEmotion.crying,
      SageEmotion.depressed, SageEmotion.shocked,
      SageEmotion.angry, SageEmotion.scared, SageEmotion.distressed,
    };
    return intense.contains(old) || intense.contains(next);
  }

  bool canIdleBreathe(SageEmotion emotion) {
    switch (emotion) {
      case SageEmotion.calm:
      case SageEmotion.neutral:
      case SageEmotion.thinking:
      case SageEmotion.reading:
      case SageEmotion.curious:
      case SageEmotion.serious:
      case SageEmotion.sleepy:
      case SageEmotion.whistling:
        return true;
      default:
        return false;
    }
  }
}
