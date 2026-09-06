import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

class PostOnboardingWelcomeScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const PostOnboardingWelcomeScreen({super.key, this.onContinue, this.onBack});

  @override
  State<PostOnboardingWelcomeScreen> createState() =>
      _PostOnboardingWelcomeScreenState();
}

class _PostOnboardingWelcomeScreenState
    extends State<PostOnboardingWelcomeScreen> {
  final ValueNotifier<bool> _isPressed = ValueNotifier(false);

  @override
  void dispose() {
    _isPressed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: dark
          ? PremiumColors.deepBackground
          : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Header: back arrow only ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: l.backButton,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.textSecondary,
                      ),
                      onPressed: () {
                        ExperienceService.instance.lightHaptic();
                        (widget.onBack ?? () => context.pop())();
                      },
                      tooltip: l.backButton,
                    ),
                  ),
                ],
              ),
            ),

            // ── Center block: speech bubble + mascot ──
            Expanded(
              child: RepaintBoundary(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Speech bubble
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xxl,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: dark
                            ? PremiumColors.onboardingBubbleDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : context.borderSubtle,
                        ),
                      ),
                      child: Text(
                        l.onbWelcomeMsg,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.body.copyWith(
                          color: context.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),

                    // Triangle arrow (rotated diamond)
                    const SizedBox(height: AppSpacing.sm),
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: dark
                              ? PremiumColors.onboardingBubbleDark
                              : Colors.white,
                          border: Border.all(
                            color: dark
                                ? Colors.white.withValues(alpha: 0.10)
                                : context.borderSubtle,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Mascot
                    const ExcludeSemantics(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: SageEmotionWidget(
                          emotion: SageEmotion.excitedWave,
                          size: 180,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom 3D button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Semantics(
                button: true,
                label: l.continueText,
                child: GestureDetector(
                  onTapDown: (_) {
                    ExperienceService.instance.mediumHaptic();
                    _isPressed.value = true;
                  },
                  onTapUp: (_) {
                    _isPressed.value = false;
                    widget.onContinue?.call();
                  },
                  onTapCancel: () => _isPressed.value = false,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isPressed,
                    builder: (context, pressed, _) => AnimatedContainer(
                      duration: AppMotion.fast,
                      transform: pressed
                          ? Matrix4.translationValues(0, 4, 0)
                          : Matrix4.identity(),
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: PremiumColors.primaryAccent,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: pressed
                            ? []
                            : [
                                const BoxShadow(
                                  color: PremiumColors.primaryDark,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ],
                      ),
                      child: Center(
                        child: Text(
                          l.continueText,
                          style: AppTextStyle.titleSmall.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate().fadeIn().slideY(begin: 0.05),
      ),
    );
  }
}
