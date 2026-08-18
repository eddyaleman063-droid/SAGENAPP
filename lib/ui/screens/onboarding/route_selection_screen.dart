import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RouteSelectionScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const RouteSelectionScreen({super.key, this.onContinue, this.onBack});

  @override
  State<RouteSelectionScreen> createState() => _RouteSelectionScreenState();
}

class _RouteSelectionScreenState extends State<RouteSelectionScreen> {
  int? _selectedRouteIndex;
  bool _isPressed = false;

  static const _progressValue = 0.35;

  List<(String, String)> _routes(AppLocalizations l) => [
    ('🛡️', l.routeSelection1),
    ('💻', l.routeSelection2),
    ('⚙️', l.routeSelection3),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Scaffold(
      backgroundColor: dark
          ? PremiumColors.deepBackground
          : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header: back arrow + progress bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xxs,
                vertical: AppSpacing.sm,
              ),
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

            const SizedBox(height: AppSpacing.lg),

            // ── Horizontal mascot block ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mascot on the left
                  ExcludeSemantics(
                    child: Image.asset(
                      'assets/mascot/emotions/sage_thinking.png',
                      width: 80,
                      height: 80,
                      cacheWidth: 160,
                      cacheHeight: 160,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.pets, size: 48),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Speech bubble with left-pointing arrow
                  Expanded(
                    child: RepaintBoundary(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
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
                              AppLocalizations.of(context)!.onbRouteQuestion,
                              style: AppTextStyle.body.copyWith(
                                color: context.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                          // Left-pointing arrow
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ── Section subtitle ──
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xxl,
                  bottom: AppSpacing.md,
                ),
                child: Text(
                  AppLocalizations.of(context)!.onbRouteAvailable,
                  style: AppTextStyle.subtitle.copyWith(
                    color: context.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // ── Route options ──
            Expanded(
              child: RepaintBoundary(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  itemCount: _routes(AppLocalizations.of(context)!).length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final isSelected = _selectedRouteIndex == index;
                    final (emoji, title) = _routes(
                      AppLocalizations.of(context)!,
                    )[index];
                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label: title,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedRouteIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 60,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? PremiumColors.primaryAccent.withValues(
                                    alpha: 0.08,
                                  )
                                : context.subtle,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            border: Border.all(
                              color: isSelected
                                  ? PremiumColors.primaryAccent
                                  : (dark
                                        ? Colors.white.withValues(alpha: 0.10)
                                        : context.borderSubtle),
                              width: isSelected ? 2.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(emoji, style: AppTextStyle.headline),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Text(
                                  title,
                                  style: AppTextStyle.body.copyWith(
                                    color: context.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: PremiumColors.primaryAccent,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── Conditional bottom button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.continueText,
                child: GestureDetector(
                  onTapDown: _selectedRouteIndex != null
                      ? (_) => setState(() => _isPressed = true)
                      : null,
                  onTapUp: _selectedRouteIndex != null
                      ? (_) {
                          setState(() => _isPressed = false);
                          HapticFeedback.lightImpact();
                          ExperienceService.instance.lightHaptic();
                          widget.onContinue?.call();
                        }
                      : null,
                  onTapCancel: _selectedRouteIndex != null
                      ? () => setState(() => _isPressed = false)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    transform: _isPressed
                        ? Matrix4.translationValues(0, 4, 0)
                        : Matrix4.identity(),
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _selectedRouteIndex != null
                          ? PremiumColors.primaryAccent
                          : context.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: _isPressed || _selectedRouteIndex == null
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
                          color: _selectedRouteIndex != null
                              ? context.textPrimary
                              : context.subtle,
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
