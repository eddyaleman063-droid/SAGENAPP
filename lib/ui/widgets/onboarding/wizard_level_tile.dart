import 'package:flutter/material.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/experience_service.dart';

class WizardLevelTile extends StatelessWidget {
  final WizardOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const WizardLevelTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final cardBg = cs.onSurface.withValues(alpha: 0.04);
    final cardBorder = cs.onSurface.withValues(alpha: 0.08);
    final iconColor = context.textTertiary;

    final levelVal = int.tryParse(option.value) ?? 0;
    final fill = levelVal / 5.0;
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
          duration: const Duration(milliseconds: 200),
          curve: AppEasing.entrance,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.1) : cardBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.4)
                  : cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      option.icon,
                      size: 22,
                      color: isSelected ? accentColor : iconColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? textPrimary : textSecondary,
                          ),
                        ),
                        if (option.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            option.subtitle!,
                            style: AppTextStyle.caption.copyWith(
                              color: isSelected
                                  ? textSecondary.withValues(alpha: 0.7)
                                  : textSecondary.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 22,
                    color: isSelected ? accentColor : iconColor,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ExcludeSemantics(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: isSelected ? fill : 0.0,
                    backgroundColor: context.shimmerBase,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                    minHeight: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
