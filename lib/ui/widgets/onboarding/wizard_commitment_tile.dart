import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/providers.dart';
import '../../../services/experience_service.dart';

class WizardCommitmentTile extends ConsumerWidget {
  final WizardOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const WizardCommitmentTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final cardBg = cs.onSurface.withValues(alpha: 0.04);
    final cardBorder = cs.onSurface.withValues(alpha: 0.08);
    final accentColor = option.color ?? PremiumColors.splashBlue;

    return Semantics(
      button: true,
      selected: isSelected,
      label: option.label,
      child: GestureDetector(
        onTap: () {
          ExperienceService.instance.lightHaptic();
          onTap();
        },
        child: AnimatedContainer(
        duration: ref.read(experienceServiceProvider).fast,
        curve: AppEasing.entrance,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [accentColor.withValues(alpha: 0.15), accentColor.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : cardBg,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? accentColor.withValues(alpha: 0.5) : cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                        color: isSelected ? accentColor.withValues(alpha: 0.2) : context.shimmerBase,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: ExcludeSemantics(
                child: Icon(option.icon, size: 26, color: accentColor),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold,
                      color: isSelected ? textPrimary : textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.diamond_rounded,
                          size: 14,
                          color: PremiumColors.splashBlue.withValues(alpha: isSelected ? 1.0 : 0.6),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        option.subtitle ?? '',
                        style: AppTextStyle.caption.copyWith(color: PremiumColors.splashBlue.withValues(alpha: isSelected ? 0.9 : 0.6),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : cs.onSurface.withValues(alpha: 0.2),
                  width: 2,
                ),
                color: isSelected ? accentColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
