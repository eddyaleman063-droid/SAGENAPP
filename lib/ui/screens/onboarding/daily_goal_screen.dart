import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';

class DailyGoalConfig {
  final String label;
  final int minutes;
  final int questionsPerSession;

  const DailyGoalConfig({
    required this.label,
    required this.minutes,
    required this.questionsPerSession,
  });
}

List<DailyGoalConfig> dailyGoalOptions(AppLocalizations l) => [
  DailyGoalConfig(
    label: l.dailyGoalRelaxed,
    minutes: 3,
    questionsPerSession: 5,
  ),
  DailyGoalConfig(
    label: l.dailyGoalNormal,
    minutes: 10,
    questionsPerSession: 12,
  ),
  DailyGoalConfig(
    label: l.dailyGoalSerious,
    minutes: 15,
    questionsPerSession: 18,
  ),
  DailyGoalConfig(
    label: l.dailyGoalIntense,
    minutes: 30,
    questionsPerSession: 35,
  ),
];

class DailyGoalScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const DailyGoalScreen({super.key, this.onContinue, this.onBack});

  @override
  ConsumerState<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends ConsumerState<DailyGoalScreen> {
  int? _selectedIndex;
  bool _isPressed = false;
  List<DailyGoalConfig> _goals = [];

  static const double _progressValue = 0.90;

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    ExperienceService.instance.mediumHaptic();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    if (_selectedIndex != null) {
      final goal = _goals[_selectedIndex!];
      ref.read(dashboardProvider.notifier).setDailyGoalMinutes(goal.minutes);
      widget.onContinue?.call();
    }
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  bool get _canContinue => _selectedIndex != null;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    _goals = dailyGoalOptions(l);
    return Scaffold(
      backgroundColor: dark
          ? PremiumColors.deepBackground
          : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
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
                      onPressed: widget.onBack ?? () => context.pop(),
                      tooltip: l.backButton,
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Image.asset(
                        'assets/mascot/emotions/sage_curious.png',
                        width: 80,
                        height: 80,
                        cacheWidth: 160,
                        cacheHeight: 160,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.pets, size: 48),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
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
                              l.dailyGoalQuestion,
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
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Goal options ──
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedIndex == index;
                  return Semantics(
                    key: ValueKey('goal_$index'),
                    button: true,
                    selected: isSelected,
                    label: '${l.minutesPerDay(goal.minutes)} - ${goal.label}',
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.minutesPerDay(goal.minutes),
                              style: AppTextStyle.titleSmall.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              goal.label,
                              style: AppTextStyle.body.copyWith(
                                color: isSelected
                                    ? PremiumColors.primaryAccent
                                    : context.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
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
                AppSpacing.xxl,
                0,
                AppSpacing.xxl,
                AppSpacing.xxl,
              ),
              child: Semantics(
                button: true,
                label: AppLocalizations.of(context)!.onboardingCommitButton,
                child: GestureDetector(
                  onTapDown: _canContinue ? _onTapDown : null,
                  onTapUp: _canContinue ? _onTapUp : null,
                  onTapCancel: _canContinue ? _onTapCancel : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 80),
                    transform: _isPressed
                        ? Matrix4.translationValues(0, 4, 0)
                        : Matrix4.identity(),
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _canContinue
                          ? PremiumColors.primaryAccent
                          : context.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: _isPressed || !_canContinue
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
                        AppLocalizations.of(context)!.onboardingCommitButton,
                        style: AppTextStyle.titleSmall.copyWith(
                          color: _canContinue
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
