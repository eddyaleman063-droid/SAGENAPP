import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../models/learning/quiz_score.dart';
import '../../widgets/animations/particle_burst.dart';
import '../../widgets/common/confetti_widget.dart';

enum _FeedbackState { accuracy, speed, standard }

class SessionSummaryScreen extends StatefulWidget {
  final QuizScoreCalculator score;
  final double timeThresholdSeconds;

  const SessionSummaryScreen({
    super.key,
    required this.score,
    this.timeThresholdSeconds = 30,
  });

  @override
  State<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends State<SessionSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late _FeedbackState _state;
  String _dynamicText = '';
  late String _sageAsset;
  final _random = Random();

  List<String> _accuracyTexts(AppLocalizations l) => [
    l.sessionSummaryAccuracy1,
    l.sessionSummaryAccuracy2,
    l.sessionSummaryAccuracy3,
    l.sessionSummaryAccuracy4,
    l.sessionSummaryAccuracy5,
    l.sessionSummaryAccuracy6,
    l.sessionSummaryAccuracy7,
  ];

  List<String> _speedTexts(AppLocalizations l) => [
    l.sessionSummarySpeed1,
    l.sessionSummarySpeed2,
    l.sessionSummarySpeed3,
    l.sessionSummarySpeed4,
    l.sessionSummarySpeed5,
    l.sessionSummarySpeed6,
    l.sessionSummarySpeed7,
  ];

  List<String> _standardTexts(AppLocalizations l) => [
    l.sessionSummaryStandard1,
    l.sessionSummaryStandard2,
    l.sessionSummaryStandard3,
    l.sessionSummaryStandard4,
    l.sessionSummaryStandard5,
    l.sessionSummaryStandard6,
    l.sessionSummaryStandard7,
  ];

  static const _accuracyAssets = [
    'assets/mascot/emotions/sage_excited_wave.png',
    'assets/mascot/emotions/sage_happy_wings.png',
    'assets/mascot/emotions/sage_laughing.png',
  ];

  static const _speedAssets = [
    'assets/mascot/emotions/sage_curious.png',
    'assets/mascot/emotions/sage_shocked.png',
    'assets/mascot/emotions/sage_surprised_wings.png',
  ];

  static const _standardAssets = [
    'assets/mascot/emotions/sage_calm.png',
    'assets/mascot/emotions/sage_neutral.png',
    'assets/mascot/emotions/sage_whistling.png',
  ];

  _FeedbackState _determineState(double accuracy, double avgTime) {
    if (accuracy >= 90) return _FeedbackState.accuracy;
    if (avgTime < widget.timeThresholdSeconds && accuracy > 70) {
      return _FeedbackState.speed;
    }
    return _FeedbackState.standard;
  }

  String _pickRandom(List<String> list) => list[_random.nextInt(list.length)];

  int get _totalXp => widget.score.xp;

  @override
  void initState() {
    super.initState();
    final accuracy = widget.score.accuracyPercent;
    final avgTime = widget.score.avgTimePerQuestion;
    _state = _determineState(accuracy, avgTime);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l = AppLocalizations.of(context)!;
      setState(() {
        _dynamicText = switch (_state) {
          _FeedbackState.accuracy => _pickRandom(_accuracyTexts(l)),
          _FeedbackState.speed => _pickRandom(_speedTexts(l)),
          _FeedbackState.standard => _pickRandom(_standardTexts(l)),
        };
      });
    });
    _sageAsset = switch (_state) {
      _FeedbackState.accuracy => _pickRandom(_accuracyAssets),
      _FeedbackState.speed => _pickRandom(_speedAssets),
      _FeedbackState.standard => _pickRandom(_standardAssets),
    };
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _glowCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ExperienceService.instance.mediumHaptic();
      Future.delayed(const Duration(milliseconds: 200), () {
        ExperienceService.instance.mediumHaptic();
      });
      Future.delayed(const Duration(milliseconds: 400), () {
        ExperienceService.instance.mediumHaptic();
      });
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Color get _primaryColor => switch (_state) {
    _FeedbackState.accuracy => PremiumColors.streakOrange,
    _FeedbackState.speed => PremiumColors.splashBlue,
    _FeedbackState.standard => PremiumColors.primaryAccent,
  };

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final isPerfect = widget.score.accuracyPercent >= 90;
    final isGood = widget.score.accuracyPercent >= 70;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go('/home');
      },
      child: Scaffold(
      backgroundColor: dark ? PremiumColors.darkBg : PremiumColors.lightBg,
      body: Stack(
        children: [
          if (isPerfect)
            const Positioned.fill(
              child: ConfettiWidget(type: ConfettiType.level, particleCount: 80),
            )
          else if (isGood)
            const Positioned.fill(
              child: ConfettiWidget(type: ConfettiType.streak, particleCount: 40),
            ),
          SafeArea(
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.2,
                      colors: [
                        _primaryColor.withValues(alpha: 0.06 + _glowCtrl.value * 0.04),
                        dark ? PremiumColors.darkBg : PremiumColors.lightBg,
                        dark ? PremiumColors.darkBg : PremiumColors.lightBg,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      _buildMascot(),
                      const SizedBox(height: AppSpacing.lg),
                      _buildDynamicText(),
                      const SizedBox(height: AppSpacing.xxl),
                      _StatsGrid(
                        totalXp: _totalXp,
                        accuracyPercent: widget.score.accuracyPercent,
                        timeSeconds: widget.score.timeSpentSeconds,
                        primaryColor: _primaryColor,
                      ),
                      const Spacer(flex: 3),
                      _buildButton(),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ).animate().fadeIn(),
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildMascot() {
    final isPerfect = widget.score.accuracyPercent >= 90;
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isPerfect)
          Positioned(
            child: ParticleBurst(
              color: _primaryColor,
              count: 16,
              radius: 80,
              duration: const Duration(milliseconds: 800),
            ),
          ),
        ExcludeSemantics(child: Image.asset(
          _sageAsset,
          height: 120,
          cacheWidth: 240,
          cacheHeight: 240,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(height: 120, width: 120),
        )),
      ],
    );
  }

  Widget _buildDynamicText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Text(
        _dynamicText,
        textAlign: TextAlign.center,
        style: AppTextStyle.headlineLarge.copyWith(
          fontWeight: FontWeight.bold,
          color: _primaryColor,
          height: 1.3,
          shadows: [
            Shadow(
              color: _primaryColor.withValues(alpha: 0.25),
              blurRadius: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton() {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: l10n.sessionSummaryReceiveRewardLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              ExperienceService.instance.mediumHaptic();
              context.goNamed('habit-transition');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.sessionSummaryReceiveReward,
                  style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.arrow_forward_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int totalXp;
  final double accuracyPercent;
  final int timeSeconds;
  final Color primaryColor;

  const _StatsGrid({
    required this.totalXp,
    required this.accuracyPercent,
    required this.timeSeconds,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final valColor = context.textPrimary;
    final minutes = (timeSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (timeSeconds % 60).toString().padLeft(2, '0');
    final timeFormatted = '$minutes:$secs';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        children: [
          Expanded(child: Semantics(
            label: AppLocalizations.of(context)!.xpGainedLabel(totalXp),
            container: true,
            child: _StatBlock(
              icon: Icons.bolt_rounded,
              label: AppLocalizations.of(context)!.sessionSummaryExp,
              color: PremiumColors.streakOrange,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: totalXp.toDouble()),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) => Text(
                  '+${val.toInt()}',
                  style: AppTextStyle.titleLg.copyWith(fontWeight: FontWeight.bold, color: valColor),
                ),
              ),
            ),
          )),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Semantics(
            label: AppLocalizations.of(context)!.accuracyPercentLabel(accuracyPercent.toStringAsFixed(0)),
            container: true,
            child: _StatBlock(
              icon: Icons.gps_fixed_rounded,
              label: AppLocalizations.of(context)!.sessionSummaryAccuracy,
              color: PremiumColors.success,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: accuracyPercent),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) => Text(
                  '${val.toStringAsFixed(0)}%',
                  style: AppTextStyle.titleLg.copyWith(fontWeight: FontWeight.bold, color: valColor),
                ),
              ),
            ),
          )),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Semantics(
            label: AppLocalizations.of(context)!.timeLabel(timeFormatted),
            container: true,
            child: _StatBlock(
              icon: Icons.timer_outlined,
              label: AppLocalizations.of(context)!.sessionSummaryTime,
              color: PremiumColors.splashBlue,
              child: Text(
                timeFormatted,
                style: AppTextStyle.title.copyWith(fontWeight: FontWeight.bold, color: valColor),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget child;

  const _StatBlock({
    required this.icon,
    required this.label,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: context.surfaceCard,
        border: Border.all(color: context.subtleBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: ExcludeSemantics(child: Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyle.micro.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
