import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReferralSourceScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const ReferralSourceScreen({
    super.key,
    this.onContinue,
    this.onBack,
  });

  @override
  State<ReferralSourceScreen> createState() => _ReferralSourceScreenState();
}

class _ReferralSourceScreenState extends State<ReferralSourceScreen> {
  int? _selectedIndex;
  bool _isPressed = false;

  static const _progressValue = 0.50;

  List<String> _sourceLabels(AppLocalizations l) => [
    l.referralSource1,
    l.referralSource2,
    l.referralSource3,
    l.referralSource4,
    l.referralSource5,
    l.referralSource6,
    l.referralSource7,
  ];

  void _onTapUp() {
    setState(() => _isPressed = false);
    if (_selectedIndex == null) return;
    HapticFeedback.lightImpact();
    ExperienceService.instance.mediumHaptic();
    widget.onContinue?.call();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: dark ? PremiumColors.deepBackground : PremiumColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Block 1: Header (fixed) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs, vertical: AppSpacing.sm),
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

            // ── Block 2: Mascot (fixed) ──
            RepaintBoundary(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
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
                                color: dark
                                    ? Colors.white.withValues(alpha: 0.10)
                                    : context.borderSubtle,
                              ),
                            ),
                            child: Text(
                              l.onbReferralQuestion,
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

            const SizedBox(height: AppSpacing.xxl),

            // ── Block 3: Scrollable options (expanded) ──
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                itemCount: _sourceLabels(l).length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedIndex == index;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: _sourceLabels(l)[index],
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selectedIndex = index);
                      },
                      child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 64,
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
                              : (dark
                                   ? Colors.white.withValues(alpha: 0.10)
                                   : context.borderSubtle),
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _brandLogo(index),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                              _sourceLabels(l)[index],
                              style: AppTextStyle.body.copyWith(
                                color: context.textPrimary,
                                fontWeight: FontWeight.w500,
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

            // ── Block 4: Bottom button (fixed) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
              child: Semantics(
                button: true,
                label: l.continueText,
                child: GestureDetector(
                  onTapDown: _selectedIndex != null
                      ? (_) => setState(() => _isPressed = true)
                      : null,
                  onTapUp: _selectedIndex != null ? (_) => _onTapUp() : null,
                  onTapCancel: _selectedIndex != null
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
                      color: _selectedIndex != null
                          ? PremiumColors.primaryAccent
                          : context.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: _isPressed || _selectedIndex == null
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
                          color: _selectedIndex != null
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

// ── Brand logo helpers ──────────────────────────────────────

Widget _brandLogo(int index) {
  switch (index) {
    case 0:
      return _squared(PremiumColors.youtubeRed, Icons.play_arrow, Colors.white);
    case 1:
      return _squared(PremiumColors.tiktokBlack, Icons.music_note,
          PremiumColors.tiktokCyan);
    case 2:
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            colors: [PremiumColors.instagramPurple, PremiumColors.instagramRed, PremiumColors.instagramOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
      );
    case 3:
      return const ImageIcon(
        AssetImage('assets/ui/google_logo.png'),
        size: 24,
      );
    case 4:
      return _squared(PremiumColors.spotifyGreen, Icons.play_circle, Colors.white);
    case 5:
      return _squared(null, Icons.favorite, PremiumColors.pinkHeart);
    case 6:
      return _squared(null, Icons.more_horiz, PremiumColors.typeSystem);
    default:
      return const SizedBox(width: 32, height: 32);
  }
}

Widget _squared(Color? bg, IconData icon, Color iconColor) {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    ),
    child: Icon(icon, color: iconColor, size: 20),
  );
}
