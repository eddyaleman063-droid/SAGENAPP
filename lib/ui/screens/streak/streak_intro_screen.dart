import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../services/sage_emotion_service.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StreakIntroScreen extends StatelessWidget {
  final VoidCallback onContinue;

  const StreakIntroScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: dark ? PremiumColors.deepBackground : PremiumColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const SizedBox(
                width: 120,
                height: 120,
                child: SageEmotionWidget(
                  emotion: SageEmotion.excitedWave,
                  size: 120,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  color: PremiumColors.streakOrange.withValues(alpha: 0.1),
                  border: Border.all(color: PremiumColors.streakOrange.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, size: 18, color: PremiumColors.streakOrange),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.streakBadge,
                      style: AppTextStyle.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.streakOrange,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l.streakKeepAlive,
                style: AppTextStyle.headline.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.streakKeepAliveDesc,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  color: context.surfaceTinted,
                  border: Border.all(
                    color: context.subtleBorder,
                  ),
                ),
                child: Column(
                  children: [
                    _BenefitRow(icon: Icons.shield_rounded, text: l.streakStrongerShield),
                    const SizedBox(height: AppSpacing.md),
                    _BenefitRow(icon: Icons.auto_awesome_rounded, text: l.streakRewards),
                    const SizedBox(height: AppSpacing.md),
                    _BenefitRow(icon: Icons.emoji_events_rounded, text: l.streakAchievements),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: Semantics(
                  button: true,
                  label: l.streakGotIt,
                  child: ElevatedButton(
                    onPressed: onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.streakOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      elevation: 4,
                    ),
                    child: Text(l.streakGotIt, style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ).animate().fadeIn().slideY(begin: 0.05),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: PremiumColors.streakOrange),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.subtitle.copyWith(
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
