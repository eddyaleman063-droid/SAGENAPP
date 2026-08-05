import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/providers.dart';
import '../../../services/app_logger.dart';
import '../../../l10n/app_localizations.dart';
import 'sagen_notification.dart';

/// H-ARC-01 COORDINATION:
/// This widget coordinates in-memory provider reloads when auth state changes.
/// It does NOT perform Firestore writes — it only triggers Riverpod provider
/// reloads (streak, learning, protection, missions). The actual Firestore
/// sync is handled by CloudSyncService (profile fields) and
/// OfflineQueueService → EconomicFunctionsService (economic fields).
class SyncCoordinator extends ConsumerStatefulWidget {
  final Widget child;
  const SyncCoordinator({super.key, required this.child});

  @override
  ConsumerState<SyncCoordinator> createState() => _SyncCoordinatorState();
}

class _SyncCoordinatorState extends ConsumerState<SyncCoordinator> {
  @override
  void initState() {
    super.initState();
    ref.listen(authProvider, (prev, next) {
      if (next.isAuthenticated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          try {
            ref.read(streakProvider.notifier).reload();
          } catch (e) {
            AppLogger().error('SyncCoordinator: streak reload failed', e);
            if (context.mounted) {
              SagenNotification.show(context, message: AppLocalizations.of(context)?.errorGeneric ?? '', type: NotificationType.error);
            }
          }
          try {
            ref.read(learningProvider.notifier).reload();
          } catch (e) {
            AppLogger().error('SyncCoordinator: learning reload failed', e);
            if (context.mounted) {
              SagenNotification.show(context, message: AppLocalizations.of(context)?.errorGeneric ?? '', type: NotificationType.error);
            }
          }
          try {
            ref.read(protectionProvider.notifier).reload();
          } catch (e) {
            AppLogger().error('SyncCoordinator: protection reload failed', e);
            if (context.mounted) {
              SagenNotification.show(context, message: AppLocalizations.of(context)?.errorGeneric ?? '', type: NotificationType.error);
            }
          }
          try {
            ref.read(missionProvider.notifier).reload();
          } catch (e) {
            AppLogger().error('SyncCoordinator: mission reload failed', e);
            if (context.mounted) {
              SagenNotification.show(context, message: AppLocalizations.of(context)?.errorGeneric ?? '', type: NotificationType.error);
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
