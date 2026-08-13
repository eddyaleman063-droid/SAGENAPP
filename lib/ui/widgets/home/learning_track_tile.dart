import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/learning/stage.dart';
import '../../../providers/providers.dart';
import '../../../core/theme/app_colors.dart';

enum StageStatus { locked, inProgress, completed }

class LearningTrackTile extends ConsumerStatefulWidget {
  final Stage stage;
  final StageStatus status;
  final VoidCallback? onTap;
  final bool isLast;
  final int index;

  const LearningTrackTile({
    super.key,
    required this.stage,
    required this.status,
    this.onTap,
    this.isLast = false,
    this.index = 0,
  });

  @override
  ConsumerState<LearningTrackTile> createState() => _LearningTrackTileState();
}

class _LearningTrackTileState extends ConsumerState<LearningTrackTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.status == StageStatus.completed;
    final inProgress = widget.status == StageStatus.inProgress;
    final locked = widget.status == StageStatus.locked;

    final glowColor = inProgress
        ? PremiumColors.splashBlue
        : completed
        ? PremiumColors.achievementEnd
        : Colors.transparent;

    final tile = Semantics(
      button: !locked,
      enabled: !locked,
      label:
          '${widget.stage.title}. ${widget.stage.subtitle}. ${AppLocalizations.of(context)!.stageProgress((widget.stage.progress * 100).round())}',
      child: Opacity(
        opacity: locked ? 0.5 : 1.0,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.isLast ? 0 : AppSpacing.md),
          child: GestureDetector(
            onTapDown: locked ? null : (_) => _pressCtrl.reverse(),
            onTapUp: locked ? null : (_) => _pressCtrl.forward(),
            onTapCancel: locked ? null : () => _pressCtrl.forward(),
            onTap: locked
                ? null
                : () {
                    ref.read(experienceServiceProvider).lightHaptic();
                    widget.onTap?.call();
                  },
            child: ScaleTransition(
              scale: _pressCtrl,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  color: context.surfaceCard,
                  border: Border.all(
                    color: completed
                        ? PremiumColors.achievementEnd
                        : inProgress
                        ? PremiumColors.splashBlue
                        : context.borderSubtle,
                    width: inProgress ? 1.5 : 1.0,
                  ),
                  boxShadow: inProgress || completed
                      ? [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.15),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: completed
                            ? PremiumColors.achievementEnd.withValues(
                                alpha: 0.15,
                              )
                            : inProgress
                            ? PremiumColors.splashBlue.withValues(alpha: 0.15)
                            : context.subtle,
                      ),
                      child: Icon(
                        locked ? Icons.lock_rounded : widget.stage.icon,
                        size: 20,
                        color: completed
                            ? PremiumColors.achievementEnd
                            : inProgress
                            ? PremiumColors.splashBlue
                            : context.iconSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stage.title,
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: completed
                                  ? PremiumColors.achievementEnd
                                  : context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            widget.stage.subtitle,
                            style: AppTextStyle.label.copyWith(
                              color: context.textTertiary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            child: Semantics(
                              label: AppLocalizations.of(context)!
                                  .stageProgress(
                                    (widget.stage.progress * 100).round(),
                                  ),
                              value: '${(widget.stage.progress * 100).round()}',
                              child: LinearProgressIndicator(
                                value: widget.stage.progress,
                                backgroundColor: context.subtle,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  completed
                                      ? PremiumColors.achievementEnd
                                      : inProgress
                                      ? PremiumColors.splashBlue
                                      : Colors.white24,
                                ),
                                minHeight: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      completed
                          ? Icons.check_circle_rounded
                          : Icons.chevron_right_rounded,
                      size: 22,
                      color: completed
                          ? PremiumColors.achievementEnd
                          : context.textTertiary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return tile
        .animate(delay: (widget.index * 60).ms)
        .fadeIn(duration: 350.ms, curve: Curves.easeOut)
        .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}
