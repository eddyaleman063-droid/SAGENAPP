import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class MotivationScreen extends StatefulWidget {
  final VoidCallback? onContinue;
  final VoidCallback? onBack;

  const MotivationScreen({super.key, this.onContinue, this.onBack});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final List<bool> _selections = List.generate(7, (_) => false);
  bool _isPressed = false;

  static const double _progressValue = 0.80;

  List<Map<String, dynamic>> _buildOptions(AppLocalizations l) => [
    {"label": l.motivationCareer, "icon": Icons.work},
    {"label": l.motivationStudies, "icon": Icons.school},
    {"label": l.motivationFun, "icon": Icons.celebration},
    {"label": l.motivationMind, "icon": Icons.psychology},
    {"label": l.motivationConnect, "icon": Icons.people},
    {"label": l.motivationTravel, "icon": Icons.flight},
    {"label": l.motivationOther, "icon": Icons.more_horiz},
  ];

  int get _selectedCount => _selections.where((s) => s).length;

  String _dialogText(AppLocalizations l) {
    final count = _selectedCount;
    if (count == 0) {
      return l.motivationDialogNone;
    }
    if (count > 1) {
      return l.motivationDialogMultiple;
    }
    final idx = _selections.indexOf(true);
    switch (idx) {
      case 0:
        return l.onbMotivationCareerMsg;
      case 1:
        return l.onbMotivationStudiesMsg;
      case 2:
        return l.onbMotivationFunMsg;
      case 3:
        return l.onbMotivationMindMsg;
      case 4:
        return l.onbMotivationConnectMsg;
      case 5:
        return l.onbMotivationTravelMsg;
      case 6:
        return l.onbMotivationOtherMsg;
      default:
        return l.onbMotivationTitle;
    }
  }

  String get _mascotAsset {
    final count = _selectedCount;
    if (count == 0) {
      return 'assets/mascot/emotions/sage_curious.png';
    }
    if (count > 1) {
      return 'assets/mascot/emotions/sage_excited_wave.png';
    }
    final idx = _selections.indexOf(true);
    switch (idx) {
      case 0:
        return 'assets/mascot/emotions/sage_thinking.png';
      case 1:
        return 'assets/mascot/emotions/sage_happy_wings.png';
      case 2:
        return 'assets/mascot/emotions/sage_laughing.png';
      case 3:
        return 'assets/mascot/emotions/sage_thinking.png';
      case 4:
        return 'assets/mascot/emotions/sage_happy_wings.png';
      case 5:
        return 'assets/mascot/emotions/sage_wink.png';
      case 6:
        return 'assets/mascot/emotions/sage_curious.png';
      default:
        return 'assets/mascot/emotions/sage_curious.png';
    }
  }

  void _toggle(int index) {
    setState(() {
      if (index == 6) {
        for (int i = 0; i < 6; i++) {
          _selections[i] = false;
        }
        _selections[6] = !_selections[6];
      } else {
        if (_selections[6]) {
          _selections[6] = false;
        }
        _selections[index] = !_selections[index];
      }
    });
  }

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

  bool get _canContinue => _selections.contains(true);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Image.asset(
                        _mascotAsset,
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
                              border: Border.all(color: context.borderSubtle),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              child: Text(
                                _dialogText(AppLocalizations.of(context)!),
                                key: ValueKey(
                                  _dialogText(AppLocalizations.of(context)!),
                                ),
                                style: AppTextStyle.body.copyWith(
                                  color: context.textPrimary,
                                  height: 1.4,
                                ),
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

            const SizedBox(height: AppSpacing.xl),

            // ── Scrollable options ──
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                itemCount: _buildOptions(AppLocalizations.of(context)!).length,
                itemBuilder: (context, index) {
                  final isSelected = _selections[index];
                  final opt = _buildOptions(
                    AppLocalizations.of(context)!,
                  )[index];
                  return Semantics(
                    key: ValueKey('motivation_$index'),
                    button: true,
                    selected: isSelected,
                    label: opt["label"] is String ? opt["label"] as String : '',
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _toggle(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 64,
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
                                : context.borderSubtle,
                            width: isSelected ? 2.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              opt["icon"] is IconData
                                  ? opt["icon"] as IconData
                                  : Icons.star,
                              color: isSelected
                                  ? PremiumColors.primaryAccent
                                  : context.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                opt["label"] is String
                                    ? opt["label"] as String
                                    : '',
                                style: AppTextStyle.body.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? PremiumColors.primaryAccent
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.xs,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? PremiumColors.primaryAccent
                                      : context.textDisabled,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      size: 16,
                                      color: context.textPrimary,
                                    )
                                  : null,
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
}
