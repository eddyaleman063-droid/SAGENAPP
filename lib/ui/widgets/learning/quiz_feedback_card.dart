import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';
import '../common/localization_helper.dart';

class QuizFeedbackCard extends StatelessWidget {
  final bool correct;
  final String explanation;

  const QuizFeedbackCard({
    super.key,
    required this.correct,
    required this.explanation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.xxs),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: correct
            ? PremiumColors.success.withValues(alpha: 0.06)
            : PremiumColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: correct
              ? PremiumColors.success.withValues(alpha: 0.2)
              : PremiumColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: correct
                  ? PremiumColors.success.withValues(alpha: 0.1)
                  : PremiumColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
            ),
            child: ExcludeSemantics(
              child: Icon(
                correct ? Icons.check_rounded : Icons.info_rounded,
                size: 16,
                color: correct ? PremiumColors.success : PremiumColors.error,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  correct ? l10n(context).sessionCorrect : l10n(context).sessionIncorrect,
                  style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.bold,
                    color: correct ? PremiumColors.success : PremiumColors.error),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  explanation,
                  style: AppTextStyle.caption.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54),
                    height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
