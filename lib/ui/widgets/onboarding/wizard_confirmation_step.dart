import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';

import 'package:sagen/core/theme/app_colors.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';
import 'wizard_summary_row.dart' show WizardSummaryRow;

class WizardConfirmationStep extends ConsumerWidget {
  final WizardStepConfig stepConfig;
  final String Function(int, OnboardingWizardState, AppLocalizations)?
  sageMessageForStep;

  const WizardConfirmationStep({
    super.key,
    required this.stepConfig,
    this.sageMessageForStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final l = AppLocalizations.of(context)!;

    final sectionData = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData),
    );
    final referral = sectionData[1] as String? ?? '—';
    final knowledge = sectionData[2] as String? ?? '—';
    final reasons = (sectionData[3] as List<String>?) ?? [];
    final habits = sectionData[4] as String? ?? '—';
    final prefer = (sectionData[5] as List<String>?) ?? [];
    final goal = sectionData[6] as String? ?? '—';
    final commitments = (sectionData[7] as List<String>?) ?? [];
    final config = stepConfig;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Text(
              config.question,
              style: AppTextStyle.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            WizardSummaryRow(label: l.summaryOrigin, value: referral),
            WizardSummaryRow(label: l.summaryKnowledge, value: knowledge),
            if (reasons.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryMotivations,
                value: reasons.join(', '),
              ),
            WizardSummaryRow(label: l.summaryLearning, value: habits),
            if (prefer.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryPreferences,
                value: prefer.join(', '),
              ),
            WizardSummaryRow(label: l.summaryDailyGoal, value: l.minutes(goal)),
            if (commitments.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryCommitment,
                value: l.commitDays(commitments.length),
              ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: PremiumColors.splashBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: PremiumColors.splashBlue.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  const ExcludeSemantics(
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: PremiumColors.splashBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      l.summaryReady,
                      style: AppTextStyle.subtitle.copyWith(
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
