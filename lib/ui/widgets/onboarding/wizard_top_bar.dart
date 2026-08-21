import 'package:flutter/material.dart';
import '../../../config/onboarding_wizard_config.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/l10n/app_localizations.dart';

class WizardTopBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onBack;

  const WizardTopBar({
    super.key,
    required this.currentIndex,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = (currentIndex + 1) / OnboardingWizardConfig.totalSteps;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.backButton,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 22),
              color: cs.onSurface.withValues(alpha: 0.7),
              onPressed: () {
                ExperienceService.instance.lightHaptic();
                onBack();
              },
              padding: const EdgeInsets.all(18),
              tooltip: AppLocalizations.of(context)!.backButton,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              label: AppLocalizations.of(
                context,
              )!.wizardStepLabel(currentIndex + 1),
              value: '${(progress * 100).round()}%',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: cs.onSurface.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PremiumColors.splashBlue.withValues(alpha: 0.8),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
