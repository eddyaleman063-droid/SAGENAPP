import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';
import 'package:sagen/ui/widgets/store/buy_button.dart';

class StreakFireCard extends ConsumerWidget {
  final StreakState streak;
  const StreakFireCard({
    super.key,
    required this.streak,
  });

  Color _fireColor(BuildContext context) {
    final curStreak = streak.currentStreak;
    final isFrozen = streak.isStreakFrozen;
    if (isFrozen) return PremiumColors.premiumIce;
    if (curStreak > 0) return PremiumColors.streakOrange;
    return context.textDisabled;
  }

  String _fireStatusText(AppLocalizations l) {
    final curStreak = streak.currentStreak;
    final isFrozen = streak.isStreakFrozen;
    if (isFrozen) return l.streakFrozen;
    if (curStreak > 0) return l.streakDaysCount(curStreak);
    return l.streakNoActiveStreak;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final curStreak = streak.currentStreak;
    final isFrozen = streak.isStreakFrozen;
    final showOnboarding = curStreak == 0 && !isFrozen;

    return Semantics(
      label: AppLocalizations.of(context)?.streakFireCardLabel ?? AppLocalizations.of(context)!.streakFireCardA11y,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          colors: [
            _fireColor(context).withValues(alpha: 0.1),
            context.surfaceCard.withValues(
              alpha: 0.5,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card(),
        border: Border.all(color: _fireColor(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: _fireColor(context).withValues(alpha: 0.15),
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.local_fire_department_rounded,
                    color: _fireColor(context),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.streakFreeze,
                      style: AppTextStyle.body.copyWith(fontWeight: FontWeight.w600,
                        color: context.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      l.streakFreezeDescription,
                      style: AppTextStyle.caption.copyWith(color: context.textTertiary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.local_fire_department_rounded,
                            size: 12,
                            color: _fireColor(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _fireStatusText(l),
                      style: AppTextStyle.label.copyWith(fontWeight: FontWeight.w600,
                            color: _fireColor(context)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BuyButton(
                cost: 0,
                canBuy: !isFrozen,
                onBuy: () => _buyFreeze(context, ref),
              ),
            ],
          ),
          if (showOnboarding) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: PremiumColors.streakOrange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: PremiumColors.streakOrange.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.streakShieldOnboarding,
                      style: AppTextStyle.label.copyWith(color: context.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isFrozen) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: PremiumColors.premiumIce.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.ac_unit_rounded,
                      size: 14,
                      color: PremiumColors.premiumIce,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l.streakShieldActive,
                      style: AppTextStyle.label.copyWith(color: PremiumColors.premiumIce,
                        fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
    );
  }

  Future<void> _buyFreeze(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context)!;
    final exp = ref.read(experienceServiceProvider);
    if (streak.isStreakFrozen) {
      exp.errorHaptic();
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.storeShieldLimitReached,
          type: NotificationType.error,
        );
      }
      return;
    }
    final maxFreezes = ref.read(remoteConfigServiceProvider).streakMaxFreezes;
    final currentFreezes = ref.read(streakProvider).status.streakFreezes;
    if (currentFreezes >= maxFreezes) {
      exp.errorHaptic();
      if (context.mounted) {
        SagenNotification.show(
          context,
          message: l.storeShieldLimitReached,
          type: NotificationType.error,
        );
      }
      return;
    }
    ref.read(streakProvider.notifier).setFreezes(currentFreezes + 1);
    exp.successHaptic();
    if (context.mounted) {
      SagenNotification.show(
        context,
        message: l.storePurchaseSuccess,
        type: NotificationType.success,
      );
    }
  }
}
