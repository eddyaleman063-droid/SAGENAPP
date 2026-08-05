import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/mascot_reaction_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/emotion_event_bus.dart';
import '../../../services/sage_emotion_service.dart';
import 'sage_emotion_widget.dart';

class ReactiveSageWidget extends ConsumerStatefulWidget {
  final SageEmotion baseEmotion;
  final double size;
  final String? semanticLabel;
  final bool animated;

  const ReactiveSageWidget({
    super.key,
    required this.baseEmotion,
    this.size = 90,
    this.semanticLabel,
    this.animated = true,
  });

  @override
  ConsumerState<ReactiveSageWidget> createState() => _ReactiveSageWidgetState();
}

class _ReactiveSageWidgetState extends ConsumerState<ReactiveSageWidget> {
  StreamSubscription<EmotionEventType>? _eventSub;
  final _eventToEmotion = <EmotionEventType, SageEmotion>{
    EmotionEventType.streakLost: SageEmotion.sadSoft,
    EmotionEventType.achievementUnlocked: SageEmotion.excited,
    EmotionEventType.lessonCompleted: SageEmotion.happy,
    EmotionEventType.perfectLesson: SageEmotion.celebrating,
    EmotionEventType.streakMilestone: SageEmotion.proud,
    EmotionEventType.levelledUp: SageEmotion.excitedWave,
    EmotionEventType.chatSent: SageEmotion.reading,
    EmotionEventType.chatReceived: SageEmotion.happy,
    EmotionEventType.chatError: SageEmotion.worried,
  };

  @override
  void initState() {
    super.initState();
    _eventSub = ref.read(emotionEventBusProvider).events.listen((event) {
      final emotion = _eventToEmotion[event];
      if (emotion != null && mounted) {
        ref.read(mascotReactionProvider.notifier).triggerReaction(emotion);
      }
    });
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reaction = ref.watch(mascotReactionProvider);
    final effectiveEmotion = reaction.overrideEmotion ?? widget.baseEmotion;

    return SageEmotionWidget(
      emotion: effectiveEmotion,
      size: widget.size,
      semanticLabel: widget.semanticLabel,
      animated: widget.animated,
    );
  }
}
