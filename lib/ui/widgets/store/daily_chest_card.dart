import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/chest_widget.dart';
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
      final xp = await ref
          .read(gamificationProvider.notifier)
          .claimDailyChest();
      if (!mounted) return;
      if (xp > 0) {
        exp.successHaptic();
        SagenNotification.show(
          context,
          message: AppLocalizations.of(context)!.storeDailyChestReward(xp),
          type: NotificationType.success,
        );
      } else if (xp < 0) {
        // NUEVO-fix (chest desync): -1 = el servidor informó que el cofre ya
        // se reclamó hoy (reconciliación). El estado local ya se ocultó; NO
        // mostrar el toast genérico de fallo (confundía al usuario en cada
        // bucle de "reclamado que reaparece").
        exp.lightHaptic();
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
    final dark = context.isDark;

    return _PulsingGlowWrapper(
      child: Semantics(
        button: true,
        label: l.storeDailyChestTitle,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            gradient: LinearGradient(
              colors: [
                PremiumColors.chestBronzeBody.withValues(
                  alpha: dark ? 0.20 : 0.14,
                ),
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
                child: ChestWidget(
                  type: ChestType.bronze,
                  size: 56,
                  animate: false,
                  open: false,
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
      ),
    );
  }
}

class _PulsingGlowWrapper extends StatelessWidget {
  final Widget child;
  const _PulsingGlowWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final reduce = ExperienceService.instance.reduceAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeInOut,
      builder: (_, value, _) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.chestGoldBody.withValues(
                alpha: reduce ? 0.5 : 0.3 + 0.4 * value,
              ),
              blurRadius: reduce ? 18.0 : 14.0 + 8.0 * value,
              spreadRadius: reduce ? 1.0 : 0.5 + 1.0 * value,
            ),
          ],
        ),
        child: child,
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
      label: label,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled
            ? () {
                ExperienceService.instance.lightHaptic();
                onTap!();
              }
            : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: enabled
                ? const LinearGradient(
                    colors: [
                      PremiumColors.chestBronzeBody,
                      PremiumColors.chestGoldBody,
                    ],
                  )
                : null,
            color: enabled ? null : context.surfaceTinted,
          ),
          child: loading
              ? const ExcludeSemantics(
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
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
