import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PostOnboardingWelcomeScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const PostOnboardingWelcomeScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  State<PostOnboardingWelcomeScreen> createState() =>
      _PostOnboardingWelcomeScreenState();
}

class _PostOnboardingWelcomeScreenState
    extends State<PostOnboardingWelcomeScreen> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? PremiumColors.deepBackground : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Header: back arrow only ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: AppLocalizations.of(context)!.backButton,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: context.textSecondary,
                      ),
                      onPressed: () {
                        ExperienceService.instance.lightHaptic();
                        (widget.onBack ?? () => context.pop())();
                      },
                      tooltip: AppLocalizations.of(context)!.backButton,
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
                      margin:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        color: dark ? PremiumColors.onboardingBubbleDark : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : context.borderSubtle,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.onbWelcomeMsg,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.body.copyWith(
                          color: context.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),

                    // Triangle arrow (rotated diamond)
                    const SizedBox(height: 8),
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                        color: dark ? PremiumColors.onboardingBubbleDark : Colors.white,
                        border: Border.all(
                          color: dark
                              ? Colors.white.withValues(alpha: 0.10)
                              : context.borderSubtle,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Mascot
                    ExcludeSemantics(
                      child: Image.asset(
                        'assets/mascot/emotions/sage_excited_wave.png',
                        width: 180,
                        height: 180,
                        cacheWidth: 360,
                        cacheHeight: 360,
                        errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom 3D button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.continueText,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _isPressed = true),
                  onTapUp: (_) {
                    setState(() => _isPressed = false);
                    HapticFeedback.lightImpact();
                    widget.onContinue?.call();
                  },
                  onTapCancel: () => setState(() => _isPressed = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    transform: _isPressed
                        ? Matrix4.translationValues(0, 4, 0)
                        : Matrix4.identity(),
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: PremiumColors.primaryAccent,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: _isPressed
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
                        AppLocalizations.of(context)!.continueText,
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
          ],
        ).animate().fadeIn().slideY(begin: 0.05),
      ),
    );
  }
}
