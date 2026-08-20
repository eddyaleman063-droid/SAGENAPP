import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/ui/widgets/learning/quiz_session.dart';
import 'package:sagen/ui/widgets/rive_flame_widget.dart';
import '../common/confetti_widget.dart';
import '../common/localization_helper.dart';

class QuizSummaryScreen extends StatefulWidget {
  final QuizResult result;
  final VoidCallback onContinue;
  final VoidCallback? onRetry;

  const QuizSummaryScreen({
    super.key,
    required this.result,
    required this.onContinue,
    this.onRetry,
  });

  @override
  State<QuizSummaryScreen> createState() => _QuizSummaryScreenState();
}

class _QuizSummaryScreenState extends State<QuizSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  bool _tapped = false;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceCtrl.forward();
    ExperienceService.instance.heavyHaptic();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    final dark = context.isDark;
    final scorePercent = (widget.result.score * 100).round();
    final minutes = widget.result.timeTaken.inMinutes;
    final seconds = widget.result.timeTaken.inSeconds % 60;
    final r = widget.result;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: RiveFlameWidget(phase: null),
            ),
          ),
          if (r.perfect)
            const Positioned.fill(
              child: ConfettiWidget(
                type: ConfettiType.level,
                particleCount: 80,
              ),
            )
          else if (r.score >= 0.7)
            const Positioned.fill(
              child: ConfettiWidget(
                type: ConfettiType.streak,
                particleCount: 40,
              ),
            ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _entranceCtrl,
                      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: r.perfect
                            ? const LinearGradient(
                                colors: [
                                  PremiumColors.achievementStart,
                                  PremiumColors.achievementEnd,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : r.score >= 0.7
                            ? const LinearGradient(
                                colors: [
                                  PremiumColors.primary,
                                  PremiumColors.primaryLight,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : LinearGradient(
                                colors: [
                                  context.borderSubtle,
                                  context.borderSubtle.withValues(alpha: 0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (r.perfect
                                        ? PremiumColors.achievementEnd
                                        : PremiumColors.primary)
                                    .withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$scorePercent%',
                          style: AppTextStyle.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entranceCtrl,
                      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                    ),
                    child: Text(
                      r.perfect
                          ? l.summaryPerfect
                          : r.score >= 0.7
                          ? l.summaryGoodWork
                          : l.summaryKeepPracticing,
                      style: AppTextStyle.headline.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entranceCtrl,
                      curve: const Interval(0.3, 0.7, curve: Curves.easeOut),
                    ),
                    child: Text(
                      l.correctAnswers(r.correctAnswers, r.totalQuestions),
                      style: AppTextStyle.bodyMd.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  if (minutes > 0 || seconds > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${minutes}m ${seconds}s',
                        style: AppTextStyle.caption.copyWith(
                          color: context.textTertiary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _entranceCtrl,
                            curve: const Interval(
                              0.3,
                              0.8,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceCtrl,
                        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
                      ),
                      child: _RewardRow(
                        iconWidget: const ExcludeSemantics(
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: PremiumColors.achievementEnd,
                          ),
                        ),
                        label: l.summaryXpEarned,
                        value: '${r.xpEarned}',
                        color: PremiumColors.achievementEnd,
                        dark: dark,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: _entranceCtrl,
                            curve: const Interval(
                              0.45,
                              0.95,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                        ),
                    child: FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceCtrl,
                        curve: const Interval(
                          0.45,
                          0.95,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: _RewardRow(
                        iconWidget: const ExcludeSemantics(
                          child: Icon(
                            Icons.emoji_events_rounded,
                            size: 18,
                            color: PremiumColors.achievementEnd,
                          ),
                        ),
                        label: l.profileStreak,
                        value: l.summaryStreakDays(r.perfect ? 2 : 1),
                        color: PremiumColors.achievementEnd,
                        dark: dark,
                      ),
                    ),
                  ),
                  if (r.gemsEarned > 0) ...[
                    const SizedBox(height: AppSpacing.md),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _entranceCtrl,
                              curve: const Interval(
                                0.5,
                                1.0,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: _entranceCtrl,
                          curve: const Interval(
                            0.5,
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: _RewardRow(
                          iconWidget: const ExcludeSemantics(
                            child: Icon(
                              Icons.diamond_rounded,
                              size: 18,
                              color: PremiumColors.accentCyan,
                            ),
                          ),
                          label: l.gems,
                          value: '+${r.gemsEarned}',
                          color: PremiumColors.accentCyan,
                          dark: dark,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.huge),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _entranceCtrl,
                      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Semantics(
                        button: true,
                        label: AppLocalizations.of(context)?.continueText ?? '',
                        child: ElevatedButton.icon(
                          onPressed: _tapped
                              ? null
                              : () {
                                  setState(() => _tapped = true);
                                  ExperienceService.instance.lightHaptic();
                                  widget.onContinue();
                                },
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                          label: Text(
                            l.continueText,
                            style: AppTextStyle.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PremiumColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            elevation: 4,
                            shadowColor: PremiumColors.primary.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.onRetry != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _entranceCtrl,
                        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ExperienceService.instance.lightHaptic();
                            widget.onRetry?.call();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(
                            l.sessionRetry,
                            style: AppTextStyle.bodyMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: PremiumColors.primary,
                            side: BorderSide(
                              color: PremiumColors.primary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final Widget iconWidget;
  final String label;
  final String value;
  final Color color;
  final bool dark;

  const _RewardRow({
    required this.iconWidget,
    required this.label,
    required this.value,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: iconWidget,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyle.bodyMd.copyWith(color: context.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyle.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
