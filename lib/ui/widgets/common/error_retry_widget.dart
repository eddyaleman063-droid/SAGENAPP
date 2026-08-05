import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';

class ErrorRetryWidget extends StatelessWidget {
  final String? message;
  final String? details;
  final VoidCallback? onRetry;

  const ErrorRetryWidget({
    super.key,
    this.message,
    this.details,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              label: l.errorGeneric,
              child: const SageEmotionWidget(emotion: SageEmotion.worried),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message ?? l.errorSomethingWrong,
              style: AppTextStyle.titleSmall.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                details!,
                style: AppTextStyle.subtitle.copyWith(
                  color: context.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onRetry?.call();
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l.tryAgain),
                style: OutlinedButton.styleFrom(
                  foregroundColor: PremiumColors.splashBlue,
                  side: BorderSide(color: PremiumColors.splashBlue.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
