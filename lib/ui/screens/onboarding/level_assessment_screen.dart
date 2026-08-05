import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LevelAssessmentScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const LevelAssessmentScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<LevelAssessmentScreen> createState() =>
      _LevelAssessmentScreenState();
}

class _LevelAssessmentScreenState
    extends ConsumerState<LevelAssessmentScreen> {
  int? _selectedLevelIndex;
  bool _isPressed = false;

  static const _progressValue = 0.65;

  List<String> _levelLabels(AppLocalizations l) => [
    l.levelAssessment0,
    l.levelAssessment1,
    l.levelAssessment2,
    l.levelAssessment3,
    l.levelAssessment4,
  ];

  void _onTapUp() {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    if (_selectedLevelIndex != null) {
      ref.read(assessmentLevelProvider.notifier).state = _selectedLevelIndex;
      ExperienceService.instance.lightHaptic();
      widget.onContinue?.call();
    }
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.sm),
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
                        'assets/mascot/emotions/sage_thinking.png',
                        width: 80,
                        height: 80,
                        cacheWidth: 160,
                        cacheHeight: 160,
                        errorBuilder: (_, _, _) => const Icon(Icons.pets, size: 48),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: dark ? PremiumColors.onboardingBubbleDark : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                              border: Border.all(
                                color: context.borderSubtle,
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.onbLevelQuestion,
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
                                      color: context.borderSubtle,
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

            const SizedBox(height: AppSpacing.xxl),

            // ── Scrollable options ──
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                itemCount: _levelLabels(AppLocalizations.of(context)!).length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedLevelIndex == index;
                  return Semantics(
                    key: ValueKey('level_$index'),
                    button: true,
                    selected: isSelected,
                    label: _levelLabels(AppLocalizations.of(context)!)[index],
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedLevelIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 68,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? PremiumColors.primaryAccent.withValues(alpha: 0.08)
                              : context.subtle,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(
                            color: isSelected
                                ? PremiumColors.primaryAccent
                                : context.borderSubtle,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            _SignalBars(litCount: index + 1),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                _levelLabels(AppLocalizations.of(context)!)[index],
                                style: AppTextStyle.bodyMd.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w500,
                                  height: 1.3,
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

            // ── Bottom button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.continueText,
                child: GestureDetector(
                  onTapDown: _selectedLevelIndex != null
                      ? (_) => setState(() => _isPressed = true)
                      : null,
                  onTapUp: _selectedLevelIndex != null
                      ? (_) => _onTapUp()
                      : null,
                  onTapCancel: _selectedLevelIndex != null
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
                    color: _selectedLevelIndex != null
                        ? PremiumColors.primaryAccent
                        : context.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    boxShadow: _isPressed || _selectedLevelIndex == null
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
                        color: _selectedLevelIndex != null
                            ? context.textPrimary
                            : context.textDisabled,
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

// ── Signal bar indicator ──────────────────────────────────

class _SignalBars extends StatelessWidget {
  final int litCount;

  const _SignalBars({required this.litCount});

  static const List<double> _barHeights = [6.0, 10.0, 14.0, 18.0, 22.0];
  static const double _barWidth = 3.5;
  static const double _barSpacing = 2.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _barWidth * 5 + _barSpacing * 4,
      height: 22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (int i) {
          final bool lit = i < litCount;
          return Container(
            width: _barWidth,
            height: _barHeights[i],
            margin: EdgeInsets.only(right: i < 4 ? _barSpacing : 0),
            decoration: BoxDecoration(
              color: lit
                  ? PremiumColors.primaryAccent
                  : context.textDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
