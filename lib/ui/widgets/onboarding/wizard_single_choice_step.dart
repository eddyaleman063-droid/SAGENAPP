import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';

import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'wizard_option_tile.dart';

class WizardSingleChoiceStep extends ConsumerWidget {
  final int stepIndex;
  final WizardStepConfig stepConfig;

  const WizardSingleChoiceStep({
    super.key,
    required this.stepIndex,
    required this.stepConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = stepConfig;
    final selected = ref.watch(
      onboardingWizardProvider.select(
        (s) => s.sectionData[stepIndex] as String?,
      ),
    );
    final textPrimary = context.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),
          Text(
            config.question,
            style: AppTextStyle.title.copyWith(
              fontWeight: FontWeight.bold,
              color: textPrimary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < config.options.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    WizardSingleChoiceTile(
                      option: config.options[i],
                      isSelected: selected == config.options[i].value,
                      onTap: () {
                        ref
                            .read(onboardingWizardProvider.notifier)
                            .setSectionData(stepIndex, config.options[i].value);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
