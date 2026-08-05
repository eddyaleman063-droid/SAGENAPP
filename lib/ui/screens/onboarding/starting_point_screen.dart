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

class StartingPointScreen extends ConsumerStatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const StartingPointScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  ConsumerState<StartingPointScreen> createState() =>
      _StartingPointScreenState();
}

class _StartingPointScreenState extends ConsumerState<StartingPointScreen> {
  int? _selectedCard;
  bool _isPressed = false;

  static const double _progressValue = 0.98;

  int? get _assessmentLevel => ref.watch(assessmentLevelProvider);

  bool get _badgeOnCard1 => _assessmentLevel != null && _assessmentLevel! <= 1;

  bool get _badgeOnCard2 => _assessmentLevel != null && _assessmentLevel! >= 2;

  void _onTapDown(TapDownDetails _) {
    setState(() => _isPressed = true);
    ExperienceService.instance.mediumHaptic();
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
    HapticFeedback.lightImpact();
    if (_selectedCard != null) {
      ref.read(diagnosticPathProvider.notifier).state =
          _selectedCard == 0 ? DiagnosticPath.beginner : DiagnosticPath.experienced;
    }
    widget.onContinue?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  bool get _canContinue => _selectedCard != null;

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
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl),
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
                              AppLocalizations.of(context)!.onbStartingPerfecto,
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

            // ── Cards ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildCard(
                        index: 0,
                        icon: Icons.menu_book,
                        iconColor: PremiumColors.onboardingAccentOrange,
                        title: AppLocalizations.of(context)!.onbStartingTitle,
                        subtitle: AppLocalizations.of(context)!.onbStartingSubtitle,
                        showBadge: _badgeOnCard1,
                        dark: dark,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: _buildCard(
                        index: 1,
                        icon: Icons.radar,
                        iconColor: PremiumColors.onboardingAccentCyan,
                        title: AppLocalizations.of(context)!.onbStartingExperienced,
                        subtitle: AppLocalizations.of(context)!.onbStartingExperiencedSub,
                        showBadge: _badgeOnCard2,
                        dark: dark,
                      ),
                    ),
                  ],
                ),
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
                          : dark ? PremiumColors.darkCard : context.surfaceCard,
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
                        AppLocalizations.of(context)!.continueText,
                        style: AppTextStyle.titleSmall.copyWith(
                          color: _canContinue
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

  Widget _buildCard({
    required int index,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool showBadge,
    required bool dark,
  }) {
    final l = AppLocalizations.of(context)!;
    final isSelected = _selectedCard == index;
    return Semantics(
      button: true,
      selected: isSelected,
      label: title,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedCard = index);
          ExperienceService.instance.lightHaptic();
        },
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isSelected
              ? PremiumColors.primaryAccent.withValues(alpha: 0.08)
              : context.subtle,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(
            color: isSelected
                ? PremiumColors.primaryAccent
                : context.borderSubtle,
            width: isSelected ? 2.5 : 1,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl, vertical: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Icon(icon, color: iconColor, size: 36),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: AppTextStyle.titleSmall.copyWith(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTextStyle.bodyMd.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (showBadge)
              Positioned(
                top: -10,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: PremiumColors.primaryAccent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    l.recommended,
                      style: AppTextStyle.label.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
