import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../services/sage_emotion_service.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/core/theme/app_colors.dart';

class ProfileSuccessScreen extends ConsumerStatefulWidget {
  const ProfileSuccessScreen({super.key});

  @override
  ConsumerState<ProfileSuccessScreen> createState() =>
      _ProfileSuccessScreenState();
}

class _ProfileSuccessScreenState extends ConsumerState<ProfileSuccessScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiCtrl;
  late AnimationController _enterCtrl;

  @override
  void initState() {
    super.initState();
    _confettiCtrl = ConfettiController(duration: const Duration(seconds: 3));
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _enterCtrl.forward();
    _confettiCtrl.play();
    ref.read(authProvider.notifier).markOnboardingCompleted();
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    _enterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.surfaceDeep,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiCtrl,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                PremiumColors.splashBlue,
                PremiumColors.success,
                PremiumColors.achievementEnd,
                PremiumColors.xpColor,
                PremiumColors.danger,
              ],
              numberOfParticles: 40,
              gravity: 0.08,
              emissionFrequency: 0.05,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _enterCtrl,
                      curve: Curves.elasticOut,
                    ),
                    child: const SizedBox(
                      width: 120,
                      height: 120,
                      child: ExcludeSemantics(
                        child: SageEmotionWidget(
                          emotion: SageEmotion.surprisedWings,
                          size: 120,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enterCtrl,
                      curve: Curves.easeIn,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        gradient: const LinearGradient(
                          colors: PremiumColors.gradientAchievement,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l.regProfileCreated,
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enterCtrl,
                      curve: Curves.easeIn,
                    ),
                    child: Text(
                      l.regWelcomeSagen,
                      style: AppTextStyle.headlineLarge.copyWith(
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _enterCtrl,
                      curve: Curves.easeIn,
                    ),
                    child: Text(
                      l.regReadyForLesson,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMd.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ExperienceService.instance.lightHaptic();
                        ref.read(registrationFunnelProvider.notifier).reset();
                        context.goNamed('main');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumColors.primaryAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      child: Text(
                        l.nextText.toUpperCase(),
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn().slideY(begin: 0.05),
    );
  }
}
