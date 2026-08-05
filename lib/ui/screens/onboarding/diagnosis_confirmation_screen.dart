import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DiagnosisConfirmationScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const DiagnosisConfirmationScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  State<DiagnosisConfirmationScreen> createState() =>
      _DiagnosisConfirmationScreenState();
}

class _DiagnosisConfirmationScreenState
    extends State<DiagnosisConfirmationScreen> {
  bool _isPressed = false;

  static const double _progressValue = 0.80;

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    ExperienceService.instance.mediumHaptic();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    widget.onContinue?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? PremiumColors.deepBackground : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
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
                      onPressed: widget.onBack ?? () => context.pop(),
                      tooltip: AppLocalizations.of(context)!.backButton,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: context.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressValue,
                        child: Container(
                          decoration: BoxDecoration(
                            color: PremiumColors.primaryAccent,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── Mascot row ──
            RepaintBoundary(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Image.asset(
                        'assets/mascot/emotions/sage_happy_wings.png',
                        width: 80,
                        height: 80,
                        cacheWidth: 160,
                        cacheHeight: 160,
                        errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 48),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
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
                              AppLocalizations.of(context)!.onbDiagnosisMsg,
                              style: AppTextStyle.body.copyWith(
                                color: context.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Transform.translate(
                              offset: const Offset(-6, 0),
                              child: Transform.rotate(
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 3),

            // ── Bottom button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.continueText,
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  onTapUp: _onTapUp,
                  onTapCancel: _onTapCancel,
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
