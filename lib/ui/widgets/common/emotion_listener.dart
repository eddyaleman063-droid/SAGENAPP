import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/mascot_reaction_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/emotion_event_bus.dart';
import 'package:sagen/services/sage_emotion_service.dart';

class EmotionListener extends ConsumerStatefulWidget {
  final Widget child;
  const EmotionListener({super.key, required this.child});

  @override
  ConsumerState<EmotionListener> createState() => _EmotionListenerState();
}

class _EmotionListenerState extends ConsumerState<EmotionListener> {
  StreamSubscription<EmotionEventType>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.read(emotionEventBusProvider).events.listen(_onEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onEvent(EmotionEventType event) {
    if (!mounted) return;
    final notifier = ref.read(mascotReactionProvider.notifier);
    final emotion = _mapEvent(event);
    if (emotion != null) {
      notifier.triggerReaction(emotion, duration: _durationFor(event));
    }
  }

  SageEmotion? _mapEvent(EmotionEventType event) {
    switch (event) {
      case EmotionEventType.chatSent:
        return SageEmotion.thinking;
      case EmotionEventType.chatReceived:
        return SageEmotion.excited;
      case EmotionEventType.chatError:
        return SageEmotion.worried;
      case EmotionEventType.lessonCompleted:
        return SageEmotion.proud;
      case EmotionEventType.perfectLesson:
        return SageEmotion.celebrating;
      case EmotionEventType.streakMilestone:
        return SageEmotion.excitedWave;
      case EmotionEventType.streakLost:
        return SageEmotion.sad;
      case EmotionEventType.achievementUnlocked:
        return SageEmotion.excited;
      case EmotionEventType.levelledUp:
        return SageEmotion.excitedWave;
    }
  }

  Duration _durationFor(EmotionEventType event) {
    switch (event) {
      case EmotionEventType.chatSent:
        return const Duration(seconds: 3);
      case EmotionEventType.chatReceived:
        return const Duration(seconds: 4);
      case EmotionEventType.chatError:
        return const Duration(seconds: 3);
      case EmotionEventType.lessonCompleted:
        return const Duration(seconds: 5);
      case EmotionEventType.perfectLesson:
        return const Duration(seconds: 6);
      case EmotionEventType.streakMilestone:
        return const Duration(seconds: 5);
      case EmotionEventType.streakLost:
        return const Duration(seconds: 4);
      case EmotionEventType.achievementUnlocked:
        return const Duration(seconds: 5);
      case EmotionEventType.levelledUp:
        return const Duration(seconds: 5);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
