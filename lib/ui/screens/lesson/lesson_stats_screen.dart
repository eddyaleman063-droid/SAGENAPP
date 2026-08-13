import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';

class LessonStatsScreen extends ConsumerWidget {
  final VoidCallback onRecibirXp;

  const LessonStatsScreen({super.key, required this.onRecibirXp});

  String _title(double accuracy, AppLocalizations l) {
    if (accuracy >= 1.0) return l.statsNoErrors;
    if (accuracy >= 0.9) return l.statsIncredible;
    if (accuracy >= 0.8) return l.statsExcellent;
    if (accuracy >= 0.3) return l.statsWellDone;
    return l.statsKeepTrying;
  }

  IconData _icon(double accuracy) {
    if (accuracy >= 1.0) return Icons.auto_awesome_rounded;
    if (accuracy >= 0.9) return Icons.star_rounded;
    if (accuracy >= 0.8) return Icons.emoji_events_rounded;
    if (accuracy >= 0.3) return Icons.check_circle_rounded;
    return Icons.replay_rounded;
  }

  Color _color(double accuracy) {
    if (accuracy >= 1.0) return PremiumColors.streakOrange;
    if (accuracy >= 0.9) return PremiumColors.xpColor;
    if (accuracy >= 0.8) return PremiumColors.success;
    if (accuracy >= 0.3) return PremiumColors.primary;
    return PremiumColors.warning;
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '--:--';
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final lesson = ref.watch(firstLessonProvider);

    if (!lesson.isComplete || lesson.questions.isEmpty) {
      return Scaffold(
        backgroundColor: dark
            ? PremiumColors.deepBackground
            : PremiumColors.lightBg,
        body: Center(child: Text(l.statsNoData)),
      );
    }

    final acc = lesson.accuracy;
    final title = _title(acc, l);
    final icon = _icon(acc);
    final color = _color(acc);

    return Scaffold(
      backgroundColor: dark
          ? PremiumColors.deepBackground
          : PremiumColors.lightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                child: ExcludeSemantics(
                  child: Icon(icon, size: 40, color: color),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                title,
                style: AppTextStyle.headlineLarge.copyWith(
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatBadge(
                    icon: Icons.auto_awesome_rounded,
                    value: '+${lesson.earnedXp}',
                    label: l.profileXpLabel,
                    color: PremiumColors.xpColor,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatBadge(
                    icon: Icons.check_circle_rounded,
                    value: '${(acc * 100).toInt()}%',
                    label: l.resultAccuracy,
                    color: PremiumColors.success,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _StatBadge(
                    icon: Icons.timer_rounded,
                    value: _formatDuration(lesson.elapsedTime),
                    label: l.statsSpeed,
                    color: PremiumColors.splashBlue,
                  ),
                ],
              ),
              const Spacer(flex: 3),
              if (lesson.path != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    color: PremiumColors.primary.withValues(alpha: 0.08),
                    border: Border.all(
                      color: PremiumColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          lesson.recommendedStage == 1
                              ? Icons.school_rounded
                              : Icons.rocket_launch_rounded,
                          size: 28,
                          color: PremiumColors.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        lesson.recommendedStage == 1
                            ? l.statsStartStage1
                            : l.statsStartStage2,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Semantics(
                button: true,
                label: l.statsReceiveXp,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: onRecibirXp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      l.statsReceiveXp,
                      style: AppTextStyle.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ).animate().fadeIn(),
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: color.withValues(alpha: 0.08),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 22, color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyle.title.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          Text(
            label,
            style: AppTextStyle.label.copyWith(color: context.textTertiary),
          ),
        ],
      ),
    );
  }
}
