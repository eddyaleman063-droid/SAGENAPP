import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';

import 'package:sagen/core/theme/app_colors.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/theme_constants.dart';

class WizardGoalStep extends ConsumerWidget {
  final int stepIndex;
  final WizardStepConfig stepConfig;

  const WizardGoalStep({
    super.key,
    required this.stepIndex,
    required this.stepConfig,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textPrimary = context.textPrimary;
    final textSecondary = cs.onSurface.withValues(alpha: 0.7);
    final cardBg = cs.onSurface.withValues(alpha: 0.04);
    final cardBorder = cs.onSurface.withValues(alpha: 0.08);
    final subTitleColor = cs.onSurface.withValues(alpha: 0.4);
    final exp = ref.read(experienceServiceProvider);

    final config = stepConfig;
    final selected = ref.watch(
      onboardingWizardProvider.select(
        (s) => s.sectionData[stepIndex] as String?,
      ),
    );

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
          ...config.options.map((opt) {
            final isSel = selected == opt.value;
            final accentColor = opt.color ?? PremiumColors.splashBlue;

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Semantics(
                button: true,
                selected: isSel,
                label: opt.label,
                child: GestureDetector(
                  onTap: () {
                    exp.lightHaptic();
                    ref
                        .read(onboardingWizardProvider.notifier)
                        .setSectionData(stepIndex, opt.value);
                  },
                  child: AnimatedContainer(
                    duration: exp.fast,
                    curve: AppEasing.entrance,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: isSel
                          ? LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.15),
                                accentColor.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSel ? null : cardBg,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: isSel
                            ? accentColor.withValues(alpha: 0.5)
                            : cardBorder,
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isSel
                                ? accentColor.withValues(alpha: 0.2)
                                : context.shimmerBase,
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: ExcludeSemantics(
                            child: Icon(opt.icon, size: 26, color: accentColor),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt.label,
                                style: AppTextStyle.title.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? textPrimary : textSecondary,
                                ),
                              ),
                              if (opt.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  opt.subtitle!,
                                  style: AppTextStyle.subtitle.copyWith(
                                    color: isSel
                                        ? textSecondary.withValues(alpha: 0.7)
                                        : subTitleColor,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSel
                                  ? accentColor
                                  : cs.onSurface.withValues(alpha: 0.2),
                              width: 2,
                            ),
                            color: isSel ? accentColor : Colors.transparent,
                          ),
                          child: isSel
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
