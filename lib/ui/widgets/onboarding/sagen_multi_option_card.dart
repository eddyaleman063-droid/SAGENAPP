import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/ui/widgets/common/sagen_touch_response.dart';

class SagenMultiOptionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const SagenMultiOptionCard({
    super.key,
    required this.leading,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final borderColor = isSelected ? accentColor : context.subtle;
    final bgColor = isSelected
        ? accentColor.withValues(alpha: 0.10)
        : Colors.transparent;
    final titleColor = isSelected
        ? accentColor
        : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxs,
      ),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: title,
        child: SagenTouchResponse(
          onTap: onTap,
          child: Material(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppEasing.standard,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Row(
                children: [
                  SizedBox(width: 24, height: 24, child: leading),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _CustomCheckbox(
                    isSelected: isSelected,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomCheckbox extends StatelessWidget {
  final bool isSelected;
  final Color accentColor;

  const _CustomCheckbox({required this.isSelected, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      curve: AppEasing.standard,
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? accentColor : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xs),
        border: Border.all(
          color: isSelected ? accentColor : accentColor.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}
