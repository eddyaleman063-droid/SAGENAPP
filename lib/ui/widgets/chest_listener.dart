import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/analytics_service.dart';
import 'package:sagen/services/app_logger.dart';
import 'package:sagen/services/emotion_event_bus.dart';

import '../../services/chest_event_bus.dart';
import 'chest_reward_dialog.dart';

class ChestListener extends ConsumerStatefulWidget {
  final Widget child;
  const ChestListener({super.key, required this.child});

  @override
  ConsumerState<ChestListener> createState() => _ChestListenerState();
}

class _ChestListenerState extends ConsumerState<ChestListener> {
  bool _dialogOpen = false;
  final _pendingRewards = <ChestRewardData>[];
  late final _bus = ref.read(chestEventBusProvider);
  StreamSubscription<ChestRewardData>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _bus.events.listen(_onChestEvent);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onChestEvent(ChestRewardData data) {
    if (!mounted) return;

    if (_dialogOpen) {
      _pendingRewards.add(data);
      return;
    }

    _processEvent(data);
  }

  void _processEvent(ChestRewardData data) {
    _dialogOpen = true;
    try {
      ref.read(experienceServiceProvider).chestOpenHaptic();
    } catch (e, st) {
      AppLogger().error('ChestListener: haptic failed', e, st);
    }

    // NUEVO-fix (ronda 9, P7): el whenComplete podía ejecutarse tras el
    // dispose del widget (navegación/sign-out con el diálogo abierto) y
    // _deliverRewards leía ref/estado ya liberado (StateError en un callback
    // sin manejar). El guard mounted corta la entrega y libera la cola.
    ChestRewardDialog.show(context, data).whenComplete(() {
      if (!mounted) {
        _dialogOpen = false;
        _pendingRewards.clear();
        return;
      }
      _deliverRewards(data);
      _bus.consume();
      _dialogOpen = false;

      if (_pendingRewards.isNotEmpty) {
        final next = _pendingRewards.removeAt(0);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _processEvent(next);
        });
      }
    });
  }

  void _deliverRewards(ChestRewardData data) {
    try {
      ref.read(inventoryProvider.notifier).recordChestOpened(data);
      ref
          .read(analyticsServiceProvider)
          .track(
            AnalyticEvent.chestOpened,
            properties: {
              'type': data.type.name,
              'source': data.source,
              'xp': data.xp,
              'specialItems': data.specialItems.length,
              'cosmetics': data.cosmeticUnlocks.length,
            },
          );

      if (data.streakShields != null && data.streakShields! > 0) {
        final streakNotifier = ref.read(streakProvider.notifier);
        final currentFreezes = streakNotifier.streakFreezes;
        final maxFreezes = ref
            .read(remoteConfigServiceProvider)
            .streakMaxFreezes;
        final shields = data.streakShields ?? 0;
        final newFreezes = (currentFreezes + shields).clamp(0, maxFreezes);
        streakNotifier.setFreezes(newFreezes);
      }

      if (data.xpBoost) {
        ref.read(shopProvider.notifier).activateXpBoost();
      }

      if (data.gems > 0) {
        ref.read(gemProvider.notifier).addGems(data.gems, reason: 'chest');
      }

      if (data.specialItems.isNotEmpty || data.cosmeticUnlocks.isNotEmpty) {
        final itemNotifier = ref.read(itemProvider.notifier);
        for (final itemType in data.specialItems) {
          itemNotifier.addItem(itemType);
        }
        for (final cosmeticType in data.cosmeticUnlocks) {
          itemNotifier.addItem(cosmeticType);
        }
        ref
            .read(emotionEventBusProvider)
            .fire(EmotionEventType.achievementUnlocked);
      }

      if (data.streakShields != null && data.streakShields! > 0) {
        ref
            .read(emotionEventBusProvider)
            .fire(EmotionEventType.streakMilestone);
      }
    } catch (e, st) {
      AppLogger().error('ChestListener: reward delivery failed', e, st);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
