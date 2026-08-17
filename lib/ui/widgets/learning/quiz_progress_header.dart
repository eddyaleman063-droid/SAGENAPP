import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/services/experience_service.dart';
import '../common/localization_helper.dart';

class QuizProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final double progress;
  final String title;

  const QuizProgressHeader({
    super.key,
    required this.current,
    required this.total,
    required this.progress,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        boxShadow: AppShadows.card(),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Semantics(
                label: '${l10n(context).exitText} quiz',
                button: true,
                child: GestureDetector(
                  onTap: () {
                    ExperienceService.instance.lightHaptic();
                    context.pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$current / $total',
                style: AppTextStyle.subtitle.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.54),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Semantics(
              label: l10n(context).quizProgress((progress * 100).round()),
              value: '${(progress * 100).round()}',
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PremiumColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
