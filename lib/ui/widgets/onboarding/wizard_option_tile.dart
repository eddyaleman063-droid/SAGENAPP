import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/providers.dart';
import '../../../services/experience_service.dart';

class WizardSingleChoiceTile extends ConsumerWidget {
  final WizardOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const WizardSingleChoiceTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _WizardOptionTileBase(
      option: option,
      isSelected: isSelected,
      onTap: onTap,
      showCheckbox: false,
    );
  }
}

class WizardMultiChoiceTile extends ConsumerWidget {
  final WizardOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const WizardMultiChoiceTile({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _WizardOptionTileBase(
      option: option,
      isSelected: isSelected,
      onTap: onTap,
      showCheckbox: true,
    );
  }
}

class _WizardOptionTileBase extends ConsumerWidget {
  final WizardOption option;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckbox;

  const _WizardOptionTileBase({
    required this.option,
    required this.isSelected,
    required this.onTap,
    required this.showCheckbox,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final cardBg = cs.onSurface.withValues(alpha: 0.04);
    final cardSelectedBg = PremiumColors.splashBlue.withValues(alpha: 0.12);
    final cardBorder = cs.onSurface.withValues(alpha: 0.08);
    final cardSelectedBorder = PremiumColors.splashBlue.withValues(alpha: 0.5);
    final iconColor = context.textTertiary;
    const iconSelectedColor = PremiumColors.splashBlue;

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
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected ? cardSelectedBg : cardBg,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected ? cardSelectedBorder : cardBorder,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  option.icon,
                  size: 22,
                  color: isSelected ? iconSelectedColor : iconColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  option.label,
                  style: AppTextStyle.bodyMd.copyWith(
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected ? textPrimary : textSecondary,
                  ),
                ),
              ),
              if (showCheckbox)
                Icon(
                  isSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 22,
                  color: isSelected ? iconSelectedColor : iconColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
