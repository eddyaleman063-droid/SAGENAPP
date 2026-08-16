import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../ui/widgets/common/benefit_row.dart';
import '../../../services/sage_emotion_service.dart';
import 'package:sagen/l10n/app_localizations.dart';

class ProfileHookScreen extends StatelessWidget {
  final VoidCallback onCreateProfile;
  final VoidCallback onSkipToHome;

  const ProfileHookScreen({
    super.key,
    required this.onCreateProfile,
    required this.onSkipToHome,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const SizedBox(
                width: 110,
                height: 110,
                child: ExcludeSemantics(
                  child: SageEmotionWidget(
                    emotion: SageEmotion.happy,
                    size: 110,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l.regProfileAlmostReady,
                style: AppTextStyle.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.regProfileDesc,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textTertiary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  color: context.surfaceTinted,
                  border: Border.all(color: context.subtleBorder),
                ),
                child: Column(
                  children: [
                    BenefitRow(
                      icon: Icons.cloud_done_rounded,
                      text: l.regCloudSave,
                      iconColor: PremiumColors.primary,
                      textColor: context.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BenefitRow(
                      icon: Icons.local_fire_department_rounded,
                      text: l.regStreakSync,
                      iconColor: PremiumColors.primary,
                      textColor: context.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BenefitRow(
                      icon: Icons.auto_awesome_rounded,
                      text: l.regRewards,
                      iconColor: PremiumColors.primary,
                      textColor: context.textPrimary,
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(
                  button: true,
                  label: l.regCreateProfile,
                  child: ElevatedButton(
                    onPressed: onCreateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      l.regCreateProfile,
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: l.regLater,
                child: TextButton(
                  onPressed: onSkipToHome,
                  child: Text(
                    l.regLater,
                    style: AppTextStyle.subtitle.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn().slideY(begin: 0.1),
        ),
      ),
    );
  }
}
