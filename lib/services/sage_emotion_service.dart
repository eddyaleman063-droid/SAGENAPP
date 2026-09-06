import 'dart:async';
import 'package:flutter/material.dart';

import 'app_logger.dart';
import '../l10n/app_localizations.dart';

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
      case SageEmotion.calm:
        return 'sage_calm';
      case SageEmotion.happy:
        return 'sage_happy_wings';
      case SageEmotion.curious:
        return 'sage_curious';
      case SageEmotion.thinking:
        return 'sage_thinking';
      case SageEmotion.reading:
        return 'sage_reading';
      case SageEmotion.serious:
        return 'sage_serious';
      case SageEmotion.neutral:
        return 'sage_neutral';
      case SageEmotion.excited:
        return 'sage_excited_wave';
      case SageEmotion.confused:
        return 'sage_confused';
      case SageEmotion.worried:
        return 'sage_worried';
      case SageEmotion.sadSoft:
        return 'sage_sad_soft';
      case SageEmotion.sad:
        return 'sage_sad';
      case SageEmotion.crying:
        return 'sage_crying';
      case SageEmotion.depressed:
        return 'sage_depressed';
      case SageEmotion.angry:
        return 'sage_angry';
      case SageEmotion.furious:
        return 'sage_furious_1';
      case SageEmotion.shocked:
        return 'sage_shocked';
      case SageEmotion.sleepy:
        return 'sage_sleeping';
      case SageEmotion.whistling:
        return 'sage_whistling';
      case SageEmotion.pointLeft:
        return 'sage_point_left';
      case SageEmotion.pointRight:
        return 'sage_point_right';
      case SageEmotion.wink:
        return 'sage_wink';
      case SageEmotion.shy:
        return 'sage_shy';
      case SageEmotion.laughing:
        return 'sage_laughing';
      case SageEmotion.singing:
        return 'sage_singing';
      case SageEmotion.scared:
        return 'sage_scared';
      case SageEmotion.embarrassed:
        return 'sage_embarrassed';
      case SageEmotion.annoyed:
        return 'sage_annoyed';
      case SageEmotion.unmotivated:
        return 'sage_unmotivated';
      case SageEmotion.distressed:
        return 'sage_distressed';
      case SageEmotion.aggressive:
        return 'sage_aggressive';
      case SageEmotion.lol:
        return 'sage_lol';
      case SageEmotion.happyWings:
        return 'sage_happy_wings';
      case SageEmotion.excitedWave:
        return 'sage_excited_wave';
      case SageEmotion.surprisedWings:
        return 'sage_surprised_wings';
      case SageEmotion.celebrating:
        return 'sage_celebrating';
      case SageEmotion.proud:
        return 'sage_proud';
      case SageEmotion.panic:
        return 'sage_panic';
    }
  }

  /// Screen-reader label localized with [l]. Callers that always run under a
  /// localized MaterialApp can rely on this; otherwise use [_friendlyName]
  /// style fallbacks when l10n is unavailable.
  String localizedLabel(AppLocalizations l) {
    switch (this) {
      case SageEmotion.calm:
        return l.sageEmotionCalm;
      case SageEmotion.happy:
        return l.sageEmotionHappy;
      case SageEmotion.curious:
        return l.sageEmotionCurious;
      case SageEmotion.thinking:
        return l.sageEmotionThinking;
      case SageEmotion.reading:
        return l.sageEmotionReading;
      case SageEmotion.serious:
        return l.sageEmotionSerious;
      case SageEmotion.neutral:
        return l.sageEmotionNeutral;
      case SageEmotion.excited:
        return l.sageEmotionExcited;
      case SageEmotion.confused:
        return l.sageEmotionConfused;
      case SageEmotion.worried:
        return l.sageEmotionWorried;
      case SageEmotion.sadSoft:
        return l.sageEmotionSadSoft;
      case SageEmotion.sad:
        return l.sageEmotionSad;
      case SageEmotion.crying:
        return l.sageEmotionCrying;
      case SageEmotion.depressed:
        return l.sageEmotionDepressed;
      case SageEmotion.angry:
        return l.sageEmotionAngry;
      case SageEmotion.furious:
        return l.sageEmotionFurious;
      case SageEmotion.shocked:
        return l.sageEmotionShocked;
      case SageEmotion.sleepy:
        return l.sageEmotionSleepy;
      case SageEmotion.whistling:
        return l.sageEmotionWhistling;
      case SageEmotion.pointLeft:
        return l.sageEmotionPointLeft;
      case SageEmotion.pointRight:
        return l.sageEmotionPointRight;
      case SageEmotion.wink:
        return l.sageEmotionWink;
      case SageEmotion.shy:
        return l.sageEmotionShy;
      case SageEmotion.laughing:
        return l.sageEmotionLaughing;
      case SageEmotion.singing:
        return l.sageEmotionSinging;
      case SageEmotion.scared:
        return l.sageEmotionScared;
      case SageEmotion.embarrassed:
        return l.sageEmotionEmbarrassed;
      case SageEmotion.annoyed:
        return l.sageEmotionAnnoyed;
      case SageEmotion.unmotivated:
        return l.sageEmotionUnmotivated;
      case SageEmotion.distressed:
        return l.sageEmotionDistressed;
      case SageEmotion.aggressive:
        return l.sageEmotionAggressive;
      case SageEmotion.lol:
        return l.sageEmotionLol;
      case SageEmotion.happyWings:
        return l.sageEmotionHappyWings;
      case SageEmotion.excitedWave:
        return l.sageEmotionExcitedWave;
      case SageEmotion.surprisedWings:
        return l.sageEmotionSurprisedWings;
      case SageEmotion.celebrating:
        return l.sageEmotionCelebrating;
      case SageEmotion.proud:
        return l.sageEmotionProud;
      case SageEmotion.panic:
        return l.sageEmotionPanic;
    }
  }
}

const int sageEmotionDecodeSize = 360;

class SageEmotionService {
  SageEmotionService();

  final Set<SageEmotion> _precached = {};
  final Map<SageEmotion, Future<void>> _inFlight = {};
  bool _initialized = false;

  // Highest-value emotions shown during cold-start moments: welcome/chat
  // defaults plus the most common event reactions. Aliases (happy/happyWings,
  // excited/excitedWave) share a sprite so only the canonical variant is kept.
  static const _coreEmotions = {
    SageEmotion.calm,
    SageEmotion.happy,
    SageEmotion.excited,
    SageEmotion.thinking,
    SageEmotion.curious,
    SageEmotion.worried,
    SageEmotion.sad,
    SageEmotion.proud,
    SageEmotion.celebrating,
  };

  static const _neutralSet = {
    SageEmotion.calm,
    SageEmotion.neutral,
    SageEmotion.happy,
  };

  static const _closeSet = {
    SageEmotion.happy,
    SageEmotion.happyWings,
    SageEmotion.excited,
    SageEmotion.excitedWave,
    SageEmotion.laughing,
    SageEmotion.lol,
  };

  static const _negativeSet = {
    SageEmotion.sad,
    SageEmotion.sadSoft,
    SageEmotion.worried,
    SageEmotion.crying,
    SageEmotion.depressed,
    SageEmotion.angry,
    SageEmotion.annoyed,
    SageEmotion.scared,
    SageEmotion.distressed,
    SageEmotion.unmotivated,
    SageEmotion.embarrassed,
    SageEmotion.aggressive,
  };

  static const _intenseSet = {
    SageEmotion.furious,
    SageEmotion.aggressive,
    SageEmotion.crying,
    SageEmotion.depressed,
    SageEmotion.shocked,
    SageEmotion.angry,
    SageEmotion.scared,
    SageEmotion.distressed,
  };

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await precacheCore();
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> precacheCore() async {
    await Future.wait(_coreEmotions.map(_precache));
  }

  Future<void> ensurePrecached(SageEmotion emotion) async {
    if (_precached.contains(emotion)) return;
    if (_inFlight.containsKey(emotion)) {
      await _inFlight[emotion];
      return;
    }
    await _precache(emotion);
  }

  Future<void> _precache(SageEmotion emotion) async {
    if (_precached.contains(emotion)) return;
    if (_inFlight.containsKey(emotion)) {
      await _inFlight[emotion];
      return;
    }
    final future = _doPrecache(emotion);
    _inFlight[emotion] = future;
    try {
      await future;
    } finally {
      // NUEVO-fix (ronda 10): remove() devuelve el Future completado que ya se
      // esperó arriba; se descarta explícitamente.
      unawaited(_inFlight.remove(emotion));
    }
  }

  Future<void> _doPrecache(SageEmotion emotion) async {
    if (_precached.contains(emotion)) return;
    final provider = ResizeImage.resizeIfNeeded(
      sageEmotionDecodeSize,
      sageEmotionDecodeSize,
      AssetImage(emotion.assetPath),
    );
    final stream = provider.resolve(ImageConfiguration.empty);
    final completer = Completer<void>();
    bool timedOut = false;
    final listener = ImageStreamListener(
      (image, sync) {
        image.dispose();
        if (!completer.isCompleted) completer.complete();
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(exception, stackTrace);
        }
      },
    );
    stream.addListener(listener);
    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          timedOut = true;
        },
      );
      if (!timedOut) _precached.add(emotion);
    } catch (e) {
      AppLogger().error('Precache failed for $emotion', e);
    } finally {
      stream.removeListener(listener);
    }
  }

  bool shouldAnimateEmotionChange(SageEmotion old, SageEmotion next) {
    if (old == next) return false;
    if (old == SageEmotion.crying || next == SageEmotion.crying) return true;
    if (old == SageEmotion.furious || next == SageEmotion.furious) return true;
    if (_neutralSet.contains(old) && _neutralSet.contains(next)) return false;
    if (_closeSet.contains(old) && _closeSet.contains(next)) return false;
    if (_negativeSet.contains(old) && _negativeSet.contains(next)) return false;
    return true;
  }

  bool isSignificantMoodShift(SageEmotion old, SageEmotion next) {
    return _intenseSet.contains(old) || _intenseSet.contains(next);
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

  // Frustration / struggle cues that should make Sage show empathy rather than
  // defaulting to excitement. Kept intentionally conservative so normal,
  // encouraging study messages are not misread as negative.
  static final RegExp _strugglePattern = RegExp(
    r'\b(no (entiendo|comprendo|puedo|se|funciona|me sale|lo entiendo|se hacerlo)|'
    r'no entiendo|no comprendo|no puedo|no me sale|dif[ií]cil|confundid|perdid|'
    r'frustrad|ay[uú]dame|me cuesta|odio|no me gusta|aburrid|triste|'
    r'horrible|me siento mal)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _curiousPattern = RegExp(
    r'\b(c[aá]lculo|m[aá]s|puedes explicar|expl[ií]came|dime|c[aó]mo|c[uú]al|'
    r'por qu[eé]|curiosidad|quiero saber|aprender|pregunta)',
    caseSensitive: false,
    unicode: true,
  );

  /// Maps the user's inbound message to an empathetic Sage emotion, or null
  /// when it's a normal/positive message (listener keeps its default mapping).
  SageEmotion? resolveUserSentiment(String text) {
    if (text.trim().isEmpty) return null;
    if (_strugglePattern.hasMatch(text)) return SageEmotion.worried;
    if (_curiousPattern.hasMatch(text)) return SageEmotion.curious;
    return null;
  }
}
