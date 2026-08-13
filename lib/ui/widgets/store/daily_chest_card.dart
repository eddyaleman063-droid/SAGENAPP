import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';

/// Daily chest claim card shown on the Store screen.
/// The reward is server-authoritative: XP is credited by the
/// `claimDailyChest` callable and applied locally without a second
/// server call. Offline/errors keep the chest unclaimed for retry.
class DailyChestCard extends ConsumerStatefulWidget {
  const DailyChestCard({super.key});

  @override
  ConsumerState<DailyChestCard> createState() => _DailyChestCardState();
}

class _DailyChestCardState extends ConsumerState<DailyChestCard> {
  bool _claiming = false;

  Future<void> _claim() async {
    if (_claiming) return;
    final exp = ref.read(experienceServiceProvider);
    setState(() => _claiming = true);
    try {
      final xp = await ref.read(gamificationProvider.notifier).claimDailyChest();
      if (!mounted) return;
      if (xp > 0) {
        exp.successHaptic();
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)!.storeDailyChestReward(xp),
          type: NotificationType.success,
        );
      } else {
        exp.errorHaptic();
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)!.storePurchaseFailed,
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _claiming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final hasUnclaimed = ref.watch(
      gamificationProvider.select((g) => g.hasUnclaimedChest),
    );
    if (!hasUnclaimed) return const SizedBox.shrink();
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      button: true,
      label: l.storeDailyChestTitle,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          gradient: LinearGradient(
            colors: [
              PremiumColors.chestBronzeBody.withValues(alpha: dark ? 0.20 : 0.14),
              context.surfaceCard,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.card(),
          border: Border.all(
            color: PremiumColors.chestBronzeAccent.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 40,
                color: PremiumColors.chestBronzeBody,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.storeDailyChestTitle,
                    style: AppTextStyle.titleSmall.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l.storeDailyChestSubtitle,
                    style: AppTextStyle.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _ClaimButton(
              label: l.storeDailyChestClaim,
              loading: _claiming,
              onTap: _claiming ? null : _claim,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  const _ClaimButton({
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                onTap!();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: enabled
                ? const LinearGradient(
                    colors: [PremiumColors.chestBronzeBody, PremiumColors.chestGoldBody],
                  )
                : null,
            color: enabled ? null : context.surfaceTinted,
          ),
          child: loading
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  label,
                  style: AppTextStyle.subtitle.copyWith(
                    fontWeight: FontWeight.w700,
                    color: enabled ? Colors.white : context.textTertiary,
                  ),
                ),
        ),
      ),
    );
  }
}
