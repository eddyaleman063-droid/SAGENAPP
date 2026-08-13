import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/learning/lesson.dart';
import '../../../models/learning/session.dart';
import '../../../models/learning/stage.dart';

import '../../../ui/widgets/shimmer_loading.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../services/sage_emotion_service.dart';
import 'package:go_router/go_router.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  void _openLesson(
    WidgetRef ref,
    BuildContext context,
    String stageId,
    String lessonId,
    String title,
  ) {
    final exp = ref.read(experienceServiceProvider);
    exp.lightHaptic();
    ref.read(sessionProvider.notifier).startSession(stageId, lessonId);
    context.pushNamed(
      'lesson-session',
      pathParameters: {'stageId': stageId, 'lessonId': lessonId},
      extra: title,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final learning = ref.watch(learningProvider);
    final stages = learning.stages;

    if (learning.isLoading) {
      return Scaffold(
        backgroundColor: context.surfaceBackground,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerLoading(width: 140, height: 22),
                      const SizedBox(height: AppSpacing.lg),
                      const ShimmerLoading(width: 100, height: 14),
                      const SizedBox(height: AppSpacing.xs),
                      const ShimmerLoading(width: 50, height: 28),
                      const SizedBox(height: AppSpacing.md),
                      const ShimmerLoading(
                        width: double.infinity,
                        height: 4,
                        borderRadius: AppRadius.pill,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ...List.generate(
                        3,
                        (_) => const Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: ShimmerLoading(
                            width: double.infinity,
                            height: 120,
                            borderRadius: AppRadius.xl,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (learning.errorMessage != null) {
      return Scaffold(
        backgroundColor: context.surfaceBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(
                    child: SageEmotionWidget(emotion: SageEmotion.worried),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    learning.errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.body.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Semantics(
                    button: true,
                    label: l.retry,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          ref.read(learningProvider.notifier).reload(),
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: Text(l.tryAgain),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PremiumColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (stages.isEmpty) {
      return Scaffold(
        backgroundColor: context.surfaceBackground,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(
                    child: SageEmotionWidget(emotion: SageEmotion.curious),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l.noLessonsAvailable,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.body.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                0,
              ),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.map_rounded,
                      size: 20,
                      color: context.iconSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.lessonsYourPath,
                    style: AppTextStyle.titleLg.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Row(
                children: [
                  _StatChip(
                    icon: Icons.check_circle_rounded,
                    label: l.lessonsCompleted(learning.lessonsCompleted),
                    color: PremiumColors.success,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _StatChip(
                    icon: Icons.auto_awesome_rounded,
                    label: l.lessonsLevel(learning.currentLevel),
                    color: PremiumColors.xpColor,
                  ),
                  const Spacer(),
                  Text(
                    '${NumberFormat.decimalPattern().format((learning.overallProgress * 100).round())}%',
                    style: AppTextStyle.headline.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              label: l.courseProgressLabel(
                (learning.overallProgress * 100).toInt(),
              ),
              container: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: learning.overallProgress,
                  backgroundColor: context.subtleBorder,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    PremiumColors.success,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(learningProvider);
                },
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    0,
                    AppSpacing.xxl,
                    100,
                  ),
                  itemCount: stages.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (ctx, i) => KeyedSubtree(
                    key: ValueKey('stage_${stages[i].id}'),
                    child: _StageNode(
                      stage: stages[i],
                      index: i,
                      isLast: i == stages.length - 1,
                      onLessonTap: (sid, lid, title) =>
                          _openLesson(ref, context, sid, lid, title),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: color.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(child: Icon(icon, size: 14, color: color)),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

typedef _LessonTapCallback =
    void Function(String stageId, String lessonId, String title);

class _StageNode extends StatelessWidget {
  final Stage stage;
  final int index;
  final bool isLast;
  final _LessonTapCallback? onLessonTap;
  const _StageNode({
    required this.stage,
    required this.index,
    required this.isLast,
    this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = stage.isComplete;
    final unlocked = stage.unlocked;
    final hasProgress = stage.completedCount > 0 && !completed;

    final node = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: completed
                        ? PremiumColors.success
                        : unlocked
                        ? PremiumColors.primaryAccent
                        : context.subtle,
                    boxShadow: unlocked && !completed
                        ? [
                            BoxShadow(
                              color: PremiumColors.primaryAccent.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: ExcludeSemantics(
                    child: Icon(
                      completed
                          ? Icons.check_rounded
                          : unlocked
                          ? Icons.play_arrow_rounded
                          : Icons.lock_rounded,
                      size: 16,
                      color: completed || unlocked
                          ? Colors.white
                          : context.subtle,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: completed
                          ? PremiumColors.success.withValues(alpha: 0.4)
                          : context.borderSubtle,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                color: unlocked ? context.surfaceCard : context.surfaceTinted,
                border: Border.all(
                  color: completed
                      ? PremiumColors.success.withValues(alpha: 0.3)
                      : unlocked
                      ? PremiumColors.primaryAccent.withValues(alpha: 0.2)
                      : context.subtle,
                ),
                boxShadow: unlocked && !completed
                    ? AppShadows.glow(
                        color: PremiumColors.primaryAccent,
                        intensity: 0.06,
                        radius: 12,
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          stage.title,
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: unlocked
                                ? context.textPrimary
                                : context.textDisabled,
                          ),
                        ),
                      ),
                      if (hasProgress)
                        Text(
                          '${stage.completedCount}/${stage.lessons.length}',
                          style: AppTextStyle.caption.copyWith(
                            color: PremiumColors.primaryAccent.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      if (completed)
                        const ExcludeSemantics(
                          child: Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: PremiumColors.success,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    stage.subtitle,
                    style: AppTextStyle.caption.copyWith(
                      color: unlocked ? context.textTertiary : context.subtle,
                    ),
                  ),
                  if (!completed && unlocked && stage.completedCount > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Semantics(
                      label: AppLocalizations.of(
                        context,
                      )!.stageProgressLabel((stage.progress * 100).toInt()),
                      container: true,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: LinearProgressIndicator(
                          value: stage.progress,
                          backgroundColor: context.surfaceTinted,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            PremiumColors.primaryAccent,
                          ),
                          minHeight: 3,
                        ),
                      ),
                    ),
                  ],
                  if (unlocked) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (stage.sessions.isNotEmpty)
                      ...stage.sessions.map(
                        (session) => _SessionGroup(
                          session: session,
                          onLessonTap: onLessonTap,
                          stageId: stage.id,
                        ),
                      )
                    else
                      ...stage.lessons.map(
                        (lesson) => _LessonRow(
                          lesson: lesson,
                          onTap: stage.unlocked && !lesson.completed
                              ? () => onLessonTap?.call(
                                  stage.id,
                                  lesson.id,
                                  lesson.title,
                                )
                              : null,
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

    return Hero(
      tag: 'stage_${stage.id}',
      child: node
          .animate(delay: (index * 60).ms)
          .fadeIn(duration: 350.ms, curve: Curves.easeOut)
          .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut),
    );
  }
}

class _LessonRow extends ConsumerWidget {
  final Lesson lesson;
  final VoidCallback? onTap;
  const _LessonRow({required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Semantics(
      button: onTap != null,
      label: lesson.completed
          ? '${lesson.title}, ${l.statusCompleted}'
          : lesson.title,
      child: GestureDetector(
        onTap: onTap != null
            ? () {
                ref.read(experienceServiceProvider).lightHaptic();
                onTap?.call();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              ExcludeSemantics(
                child: Icon(
                  lesson.completed
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 16,
                  color: lesson.completed
                      ? PremiumColors.success
                      : context.subtle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  lesson.title,
                  style: AppTextStyle.subtitle.copyWith(
                    color: lesson.completed
                        ? context.textSecondary
                        : context.textPrimary,
                    decoration: lesson.completed
                        ? TextDecoration.lineThrough
                        : null,
                    decorationColor: context.textTertiary,
                  ),
                ),
              ),
              Text(
                l.minutes(lesson.estimatedMinutes),
                style: AppTextStyle.label.copyWith(color: context.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionGroup extends StatefulWidget {
  final Session session;
  final _LessonTapCallback? onLessonTap;
  final String stageId;
  const _SessionGroup({
    required this.session,
    this.onLessonTap,
    required this.stageId,
  });

  @override
  State<_SessionGroup> createState() => _SessionGroupState();
}

class _SessionGroupState extends State<_SessionGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final completedCount = widget.session.lessons
        .where((l) => l.completed)
        .length;
    final totalCount = widget.session.lessons.length;
    final isComplete = completedCount == totalCount && totalCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: context.surfaceTinted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            button: true,
            label: _expanded
                ? AppLocalizations.of(
                    context,
                  )!.collapseSession(widget.session.title)
                : AppLocalizations.of(
                    context,
                  )!.expandSession(widget.session.title),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _expanded = !_expanded);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    ExcludeSemantics(
                      child: Icon(
                        isComplete
                            ? Icons.check_circle_rounded
                            : Icons.play_circle_outline_rounded,
                        size: 16,
                        color: isComplete
                            ? PremiumColors.success
                            : context.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.session.title,
                            style: AppTextStyle.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                          if (widget.session.subtitle.isNotEmpty)
                            Text(
                              widget.session.subtitle,
                              style: AppTextStyle.label.copyWith(
                                color: context.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '$completedCount/$totalCount',
                      style: AppTextStyle.label.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ExcludeSemantics(
                      child: Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_expanded) ...[
            ...widget.session.lessons.map(
              (lesson) => _LessonRow(
                lesson: lesson,
                onTap: !lesson.completed
                    ? () => widget.onLessonTap?.call(
                        widget.stageId,
                        lesson.id,
                        lesson.title,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}
