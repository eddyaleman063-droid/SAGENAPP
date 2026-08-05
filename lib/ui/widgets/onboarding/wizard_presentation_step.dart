import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';

class WizardPresentationStep extends StatelessWidget {
  const WizardPresentationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final textPrimary = context.textPrimary;
    final textSecondary = context.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            l.regWelcomeSagen,
            style: AppTextStyle.displayMedium.copyWith(fontWeight: FontWeight.w900,
              color: textPrimary,
              letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              l.onboardingDesc,
              textAlign: TextAlign.center,
              style: AppTextStyle.titleSmall.copyWith(color: textSecondary,
                height: 1.5),
            ),
          ),
          const Spacer(flex: 2),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
