import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/ui/widgets/common/sagen_touch_response.dart';

class SagenOptionCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const SagenOptionCard({
    super.key,
    required this.leading,
    required this.title,
    this.subtitle,
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
        label: subtitle != null ? '$title $subtitle' : title,
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
                  ExcludeSemantics(
                    child: SizedBox(width: 24, height: 24, child: leading),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: titleColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                          ),
                        ],
                      ],
                    ),
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
