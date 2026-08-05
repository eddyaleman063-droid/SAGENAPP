import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/sage_ai_provider.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class LockedGatekeeper extends StatelessWidget {
  final SageAiChatState sage;
  final bool dark;
  const LockedGatekeeper({super.key, required this.sage, required this.dark});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? [PremiumColors.chatLockedDark, PremiumColors.chatLockedDarkSurface]
              : [PremiumColors.chatLockedLight, PremiumColors.chatLockedLightSurface],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumColors.primaryAccent.withValues(alpha: 0.1),
              ),
              child: const ClipOval(
                child: SageEmotionWidget(
                  emotion: SageEmotion.thinking,
                  size: 112,
                  animated: true,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              l.tutorLocked,
              style: AppTextStyle.headlineMedium.copyWith(fontWeight: FontWeight.bold,
                color: context.textPrimary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Text(
                l.tutorLockedDescription,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(color: context.textTertiary),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: sage.progress,
                      backgroundColor: context.subtleBorder,
                      valueColor: const AlwaysStoppedAnimation<Color>(PremiumColors.primaryAccent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l.tutorLessonsProgress(sage.lessonsCompleted, sage.lessonsRequired),
                    style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w600,
                      color: PremiumColors.primaryAccent),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl * 2),
              child: Text(
                _motivationalMessage(l),
                textAlign: TextAlign.center,
                style: AppTextStyle.caption.copyWith(fontStyle: FontStyle.italic,
                  color: context.textTertiary),
              ),
            ),
            const Spacer(flex: 3),
            // Sample chat preview
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: context.isDark ? 0.05 : 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: context.subtleBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.tutorSampleTitle,
                      style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.w600,
                        color: context.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SampleMessage(
                      text: l.tutorSampleQuestion1,
                      isUser: true,
                      dark: dark,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SampleMessage(
                      text: l.tutorSampleAnswer1,
                      isUser: false,
                      dark: dark,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _SampleMessage(
                      text: l.tutorSampleQuestion2,
                      isUser: true,
                      dark: dark,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  String _motivationalMessage(AppLocalizations l) {
    final done = sage.lessonsCompleted;
    final need = sage.lessonsRequired - done;
    if (need <= 0) return '';
    if (need <= 3) return l.tutorMotivationAlmost(need);
    if (need <= 5) return l.tutorMotivationGood(need);
    return l.tutorMotivationGeneral;
  }
}

class _SampleMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool dark;
  const _SampleMessage({required this.text, required this.isUser, required this.dark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isUser
                  ? PremiumColors.primaryAccent.withValues(alpha: 0.8)
                  : context.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              text,
              style: AppTextStyle.subtitle.copyWith(color: isUser ? Colors.white : context.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
