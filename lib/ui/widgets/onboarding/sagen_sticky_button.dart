import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/ui/widgets/common/sagen_touch_response.dart';

class SagenStickyButton extends StatelessWidget {
  final String label;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const SagenStickyButton({
    super.key,
    required this.label,
    this.isEnabled = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && onPressed != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Semantics(
          button: true,
          label: label,
          child: SagenTouchResponse(
            onTap: enabled ? onPressed : null,
            enabled: enabled,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppEasing.standard,
              height: 56,
              decoration: BoxDecoration(
                color: enabled
                    ? PremiumColors.buttonGreen
                    : PremiumColors.buttonGrayDark,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: enabled
                    ? const Border(
                        bottom: BorderSide(
                          color: PremiumColors.buttonGreenBorder,
                          width: 4,
                        ),
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: enabled ? Colors.white : PremiumColors.buttonGrayLight,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
