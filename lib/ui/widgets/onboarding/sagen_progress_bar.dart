import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class SagenProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onExit;

  const SagenProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onExit,
  });

  double get _progress => totalSteps <= 0 ? 0.0 : currentStep / totalSteps;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final trackColor = context.subtle;
    final fillColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          if (onExit != null)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: onExit,
                tooltip: l.exitText,
              ),
            ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _progress),
                duration: AppMotion.medium,
                curve: AppEasing.entrance,
                builder: (context, value, _) {
                  return Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: fillColor,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
