import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/services/streak_visibility_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/ui/widgets/rive_flame_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyStreakScreen extends ConsumerStatefulWidget {
  const DailyStreakScreen({super.key});

  @override
  ConsumerState<DailyStreakScreen> createState() => _DailyStreakScreenState();
}

class _DailyStreakScreenState extends ConsumerState<DailyStreakScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl;
  late final Animation<double> _fireFade;
  late final Animation<double> _fireScale;
  late final AnimationController _resetCtrl;

  String? _message;

  int _todayIndex = 0;
  final List<bool> _weekDays = List.filled(7, false);
  bool _isWeeklyReset = false;
  int _streakDays = 0;
  bool _streakFrozen = false;
  bool _showDefrosting = false;
  bool _circleFilled = false;
  bool _navigating = false;

  List<String> _dayLabels(AppLocalizations l) => [
    l.dayAbbrMon,
    l.dayAbbrTue,
    l.dayAbbrWed,
    l.dayAbbrThu,
    l.dayAbbrFri,
    l.dayAbbrSat,
    l.dayAbbrSun,
  ];

  List<String> _streakMessages(AppLocalizations l) => [
    l.streakMsg1,
    l.streakMsg2,
    l.streakMsg3,
    l.streakMsg4,
    l.streakMsg5,
  ];

  @override
  void initState() {
    super.initState();
    _todayIndex = (DateTime.now().weekday - 1) % 7;
    _weekDays[_todayIndex] = true;
    _isWeeklyReset = _todayIndex == 6;

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fireFade = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );
    _fireScale = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _resetCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchStreakData();
      _entryCtrl.forward();
      Future.delayed(const Duration(milliseconds: 900), () {
        if (!mounted) return;
        setState(() => _circleFilled = true);
        ExperienceService.instance.mediumHaptic();
        if (_isWeeklyReset) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _resetCtrl.forward();
          });
        }
      });
      _checkMilestone();
    });
  }

  void _checkMilestone() {
    final streak = ref.read(streakProvider);
    if (streak.justHitMilestone) {
      final milestone = streak.lastMilestone;
      ref.read(streakProvider.notifier).clearMilestone();
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        _showMilestoneCelebration(milestone!);
      });
    }
  }

  void _showMilestoneCelebration(int milestone) {
    ExperienceService.instance.mediumHaptic();
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        backgroundColor: dark ? PremiumColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SageEmotionWidget(
                emotion: SageEmotion.celebrating,
                size: 80,
                animated: true,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l.challenge_streak_milestone_title,
                style: AppTextStyle.titleLg.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PremiumColors.streakOrange,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.challenge_streak_milestone_desc(milestone),
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: l.closeButton,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.streakOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(l.closeButton),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchStreakData() {
    final streak = ref.read(streakProvider);
    _streakDays = streak.currentStreak;
    _streakFrozen = streak.isStreakFrozen;
    final storage = ref.read(storageServiceProvider);
    if (storage.getBool('streak_just_defrosted')) {
      _showDefrosting = true;
      storage.setBool('streak_just_defrosted', false);
    }
    final heatmap = streak.heatmapData;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: _todayIndex));
    for (int i = 0; i < 7; i++) {
      if (i == _todayIndex) continue;
      final date = startOfWeek.add(Duration(days: i));
      final key = date.toIso8601String().substring(0, 10);
      _weekDays[i] = heatmap.containsKey(key) && heatmap[key]! > 0;
    }
    if (mounted) {
      setState(() {}); // rebuild with updated _streakDays, _weekDays, etc.
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _resetCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_navigating) return;
    _navigating = true;
    ExperienceService.instance.lightHaptic();
    final prefs = ref.read(prefsProvider);
    StreakVisibilityService(prefs).markShown();
    if (!mounted) return;
    context.goNamed('main');
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    final bg = dark ? PremiumColors.darkBg : PremiumColors.lightBg;
    final bubbleColor = dark ? PremiumColors.darkSurface : Colors.white;
    final textColor = dark ? PremiumColors.textLight : PremiumColors.textDark;
    const accent = PremiumColors.streakOrange;

    _message ??= _streakMessages(l)[Random().nextInt(5)];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: AppLocalizations.of(context)!.backButton,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded),
                          onPressed: () {
                            ExperienceService.instance.lightHaptic();
                            context.pop();
                          },
                          tooltip: AppLocalizations.of(context)!.backButton,
                        ),
                      ),
                    ),
                    SizedBox(height: h * 0.05),
                    SizedBox(
                      height: h * 0.20,
                      child: _buildSpeechBubble(bubbleColor, textColor),
                    ),
                    SizedBox(
                      height: h * 0.38,
                      child: _buildHeroSection(
                        accent,
                        AppLocalizations.of(context)!,
                      ),
                    ),
                    SizedBox(
                      height: h * 0.18,
                      child: _buildWeekTimeline(accent, dark, l),
                    ),
                    SizedBox(
                      height: h * 0.08,
                      child: _buildMonthlyHeatmap(accent, dark),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildButton(AppLocalizations.of(context)!),
                    SizedBox(height: h * 0.04),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(Color bgColor, Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 28,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Text(
                _message ?? '',
                textAlign: TextAlign.center,
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: textColor,
                ),
              ),
            ),
            Positioned(
              bottom: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Transform.rotate(
                  angle: pi / 4,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: bgColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(height: 7, color: bgColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(Color accent, AppLocalizations l) {
    return FadeTransition(
      opacity: _fireFade,
      child: ScaleTransition(
        scale: _fireScale,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: RiveFlameWidget(
                  phase: _showDefrosting
                      ? FlamePhase.defrosting
                      : _streakFrozen
                      ? FlamePhase.frozen
                      : null,
                ),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: SageEmotionWidget(
                  emotion: SageEmotion.excitedWave,
                  size: 130,
                  animated: true,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    label: l.currentStreakDays(_streakDays),
                    container: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: _streakDays.toDouble()),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOutCubic,
                          builder: (context, val, _) => Text(
                            '${val.toInt()}',
                            textAlign: TextAlign.center,
                            style: AppTextStyle.heroLarge.copyWith(
                              fontWeight: FontWeight.w900,
                              color: accent,
                              height: 1,
                              letterSpacing: -1,
                              shadows: [
                                Shadow(
                                  color: accent.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.streakDayLabel,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.subtitle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: accent.withValues(alpha: 0.8),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekTimeline(Color accent, bool dark, AppLocalizations l) {
    final grayColor = dark
        ? PremiumColors.streakInactiveDark
        : PremiumColors.streakInactiveLight;
    final grayText = context.textTertiary;

    return AnimatedBuilder(
      animation: Listenable.merge([_resetCtrl]),
      builder: (context, _) {
        final rp = _resetCtrl.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isToday = i == _todayIndex;
            final isPast = _weekDays[i];

            Color circleColor = grayColor;
            double scale = 1.0;
            bool showCheck = false;

            if (_isWeeklyReset && rp > 0 && rp < 1.0) {
              _weeklyResetState(
                i,
                rp,
                accent,
                grayColor,
                isPast,
                outColor: (c) => circleColor = c,
                outScale: (s) => scale = s,
                outCheck: (c) => showCheck = c,
              );
            } else {
              final filled = isToday ? _circleFilled : isPast;
              circleColor = filled ? accent : grayColor;
              scale = isToday && _circleFilled ? 1.0 : (isToday ? 0.5 : 1.0);
              showCheck = filled;
            }

            final dayLabel = _dayLabels(l)[i];
            final dayStatus = (isToday && _circleFilled) || isPast
                ? l.streakStatusCompleted
                : isToday
                ? l.streakStatusToday
                : l.streakStatusPending;
            return Semantics(
              label: '$dayLabel: $dayStatus',
              container: true,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Text(
                      dayLabel,
                      style: AppTextStyle.label.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _circleFilled && i == _todayIndex
                            ? accent
                            : grayText,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Transform.scale(
                    scale: scale,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                      child: showCheck
                          ? const Icon(
                              Icons.check_rounded,
                              size: 18,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }

  void _weeklyResetState(
    int index,
    double rp,
    Color accent,
    Color gray,
    bool defaultPast, {
    required void Function(Color) outColor,
    required void Function(double) outScale,
    required void Function(bool) outCheck,
  }) {
    const waveEnd = 0.7;
    const fillStart = 0.7;

    if (rp < waveEnd) {
      final waveCenter = (index / 6.0) * waveEnd;
      final dist = (rp - waveCenter).abs();
      const pulseWidth = 0.14;
      if (dist < pulseWidth) {
        final pulse = 1.0 - dist / pulseWidth;
        outScale(1.0 + 0.25 * sin(pulse * pi));
        outColor(Color.lerp(accent, Colors.white, pulse) ?? accent);
        outCheck(true);
      } else {
        final shouldBeFilled = defaultPast || (rp > waveCenter);
        outColor(shouldBeFilled ? accent : gray);
        outScale(1.0);
        outCheck(shouldBeFilled);
      }
    } else {
      final fillProgress = (rp - fillStart) / (1.0 - fillStart);
      final threshold = index / 6.0;
      if (threshold <= fillProgress) {
        outColor(gray);
        outScale(1.0);
        outCheck(false);
      } else {
        outColor(accent);
        outScale(1.0);
        outCheck(true);
      }
    }
  }

  Widget _buildMonthlyHeatmap(Color accent, bool dark) {
    final heatmap = ref.watch(streakProvider.select((s) => s.heatmapData));
    final now = DateTime.now();
    final grayColor = dark
        ? PremiumColors.streakInactiveDark
        : PremiumColors.streakInactiveLight;

    return Semantics(
      label: AppLocalizations.of(context)!.activityMap30Days,
      container: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(30, (i) {
          final date = now.subtract(Duration(days: 29 - i));
          final key = date.toIso8601String().substring(0, 10);
          final hasActivity = heatmap.containsKey(key) && heatmap[key]! > 0;
          final isToday = i == 29;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasActivity
                  ? accent.withValues(alpha: isToday ? 1.0 : 0.6)
                  : grayColor,
              border: isToday ? Border.all(color: accent, width: 1.5) : null,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildButton(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Semantics(
        button: true,
        label: l.onboardingCommitButton,
        child: ElevatedButton(
          onPressed: _handleContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: PremiumColors.streakOrange,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department_rounded, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l.onboardingCommitButton,
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
