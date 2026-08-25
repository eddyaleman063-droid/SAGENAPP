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

  const WizardConfirmationStep({super.key, required this.stepConfig});

  String _labelForValue(List<WizardOption> options, String value) {
    for (final opt in options) {
      if (opt.value == value) return opt.label;
    }
    return value;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final l = AppLocalizations.of(context)!;
    final allSteps = OnboardingWizardConfig.localizedSteps(l);

    final referral = ref.watch(
      onboardingWizardProvider.select((s) {
        final raw = s.sectionData[1];
        return raw is String ? raw : raw?.toString();
      }),
    );
    final knowledge = ref.watch(
      onboardingWizardProvider.select((s) {
        final raw = s.sectionData[2];
        return raw is String ? raw : raw?.toString();
      }),
    );
    final reasons = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData[3]),
    );
    final reasonsList = reasons is List
        ? reasons.map((e) => e.toString()).toList()
        : <String>[];
    final habits = ref.watch(
      onboardingWizardProvider.select((s) {
        final raw = s.sectionData[4];
        return raw is String ? raw : raw?.toString();
      }),
    );
    final prefer = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData[5]),
    );
    final preferList = prefer is List
        ? prefer.map((e) => e.toString()).toList()
        : <String>[];
    final goal = ref.watch(
      onboardingWizardProvider.select((s) {
        final raw = s.sectionData[6];
        return raw is String ? raw : raw?.toString();
      }),
    );
    final commitments = ref.watch(
      onboardingWizardProvider.select((s) => s.sectionData[7]),
    );
    final commitmentsList = commitments is List
        ? commitments.map((e) => e.toString()).toList()
        : <String>[];
    final config = stepConfig;

    final originLabel = referral != null
        ? _labelForValue(allSteps[1].options, referral)
        : null;
    final knowledgeLabel = knowledge != null
        ? _labelForValue(allSteps[2].options, knowledge)
        : null;
    final reasonsLabels = reasonsList
        .map((v) => _labelForValue(allSteps[3].options, v))
        .toList();
    final habitsLabel = habits != null
        ? _labelForValue(allSteps[4].options, habits)
        : null;
    final preferLabels = preferList
        .map((v) => _labelForValue(allSteps[5].options, v))
        .toList();
    final commitmentLabels = commitmentsList
        .map((v) => _labelForValue(allSteps[7].options, v))
        .toList();

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
            WizardSummaryRow(label: l.summaryOrigin, value: originLabel ?? '—'),
            WizardSummaryRow(
              label: l.summaryKnowledge,
              value: knowledgeLabel ?? '—',
            ),
            if (reasonsLabels.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryMotivations,
                value: reasonsLabels.join(', '),
              ),
            WizardSummaryRow(
              label: l.summaryLearning,
              value: habitsLabel ?? '—',
            ),
            if (preferLabels.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryPreferences,
                value: preferLabels.join(', '),
              ),
            WizardSummaryRow(
              label: l.summaryDailyGoal,
              value: l.minutes(goal ?? '0'),
            ),
            if (commitmentLabels.isNotEmpty)
              WizardSummaryRow(
                label: l.summaryCommitment,
                value: commitmentLabels.join(', '),
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
