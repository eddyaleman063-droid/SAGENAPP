import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../models/learning/stage.dart';

import '../../../ui/widgets/common/skip_to_content.dart';
import '../../../ui/widgets/home/home_header.dart';
import '../../../ui/widgets/home/hero_mission_card.dart';
import '../../../ui/widgets/home/learning_track_tile.dart';
import '../../../ui/widgets/shimmer_loading.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';

/// Bottom padding for scrollable content (accounts for bottom nav bar)
const double _kBottomNavPadding = 100;

class DashboardHomeScreen extends ConsumerStatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  ConsumerState<DashboardHomeScreen> createState() =>
      _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends ConsumerState<DashboardHomeScreen>
    with AutomaticKeepAliveClientMixin {
  Map<String, Stage>? _lessonStageCache;
  final _contentKey = GlobalKey();

  StageStatus _stageStatus(Stage stage) {
    if (!stage.unlocked) return StageStatus.locked;
    if (stage.isComplete) return StageStatus.completed;
    return StageStatus.inProgress;
  }

  Stage? _findStage(List<Stage> stages, String lessonId) {
    _lessonStageCache = {
      for (final s in stages)
        for (final l in s.lessons) l.id: s,
    };
    return _lessonStageCache![lessonId];
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final dash = ref.watch(
      dashboardProvider.select(
        (d) => (
          displayName: d.displayName,
          currentStreak: d.currentStreak,
          nextLesson: d.nextLesson,
          nextLessonStageTitle: d.nextLessonStageTitle,
        ),
      ),
    );
    final learning = ref.watch(
      learningProvider.select(
        (l) => (
          stages: l.stages,
          isLoading: l.isLoading,
          errorMessage: l.errorMessage,
          totalDonated: l.totalDonated,
        ),
      ),
    );

    final l = AppLocalizations.of(context)!;

    if (learning.errorMessage != null) {
      return Scaffold(
        backgroundColor: context.surfaceBackground,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(learningProvider);
            ref.invalidate(streakProvider);
            ref.invalidate(dashboardProvider);
          },
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Semantics(
                    label: l.errorGeneric,
                    child: Icon(
                      Icons.cloud_off_rounded,
                      size: 64,
                      color: context.subtle,
                    ),
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

    final hour = DateTime.now().hour;
    final String greeting;
    if (hour < 12) {
      greeting = l.greetingMorning;
    } else if (hour < 18) {
      greeting = l.greetingAfternoon;
    } else {
      greeting = l.greetingEvening;
    }

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: learning.isLoading
          ? const _DashboardShimmer()
          : SafeArea(
              child: RepaintBoundary(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(learningProvider);
                    ref.invalidate(streakProvider);
                    ref.invalidate(dashboardProvider);
                  },
                  child: CustomScrollView(
                    key: const ValueKey('dashboard_scroll'),
                    slivers: [
                      SliverToBoxAdapter(
                        child: SkipToContent(targetKey: _contentKey),
                      ),
                      SliverToBoxAdapter(
                        key: _contentKey,
                        child:
                            HomeHeader(
                                  displayName: dash.displayName,
                                  streak: dash.currentStreak,
                                  greeting: greeting,
                                  totalDonated: learning.totalDonated,
                                  gems: ref.watch(
                                    gemProvider.select((g) => g.balance),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 350.ms, curve: Curves.easeOut)
                                .slideY(
                                  begin: -0.05,
                                  end: 0,
                                  duration: 350.ms,
                                  curve: Curves.easeOut,
                                ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.sm,
                            bottom: AppSpacing.xxl,
                          ),
                          child: Semantics(
                            button: true,
                            label: dash.nextLesson != null
                                ? l.continueLesson(dash.nextLesson!.title)
                                : l.viewAchievements,
                            child: HeroMissionCard(
                              title: dash.nextLesson != null
                                  ? dash.nextLesson!.title
                                  : l.homeAllComplete,
                              subtitle: dash.nextLesson != null
                                  ? '${dash.nextLessonStageTitle ?? ''} · ${l.minutes(dash.nextLesson!.estimatedMinutes)}'
                                  : l.homeAllCompleteDesc,
                              actionLabel: dash.nextLesson != null
                                  ? l.homeContinue
                                  : l.homeViewAchievements,
                              onAction: () {
                                ref
                                    .read(experienceServiceProvider)
                                    .lightHaptic();
                                if (dash.nextLesson != null) {
                                  final lesson = dash.nextLesson!;
                                  final stage = _findStage(
                                    learning.stages,
                                    lesson.id,
                                  );
                                  if (stage != null) {
                                    ref
                                        .read(sessionProvider.notifier)
                                        .startSession(stage.id, lesson.id);
                                    context.pushNamed(
                                      'lesson-session',
                                      pathParameters: {
                                        'stageId': stage.id,
                                        'lessonId': lesson.id,
                                      },
                                      extra: lesson.title,
                                    );
                                  }
                                } else {
                                  context.pushNamed('achievements');
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                        ),
                        sliver: SliverToBoxAdapter(
                          child:
                              Text(
                                    l.homeLearningPath,
                                    style: AppTextStyle.body.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.textSecondary,
                                    ),
                                  )
                                  .animate(delay: 200.ms)
                                  .fadeIn(
                                    duration: 300.ms,
                                    curve: Curves.easeOut,
                                  )
                                  .slideX(
                                    begin: -0.03,
                                    end: 0,
                                    duration: 300.ms,
                                  ),
                        ),
                      ),
                      if (learning.stages.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ExcludeSemantics(
                                  child: Icon(
                                    Icons.school_rounded,
                                    size: 48,
                                    color: context.subtle,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  l.noLessonsAvailable,
                                  style: AppTextStyle.bodyMd.copyWith(
                                    color: context.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            AppSpacing.md,
                            AppSpacing.xxl,
                            _kBottomNavPadding,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final stage = learning.stages[index];
                              final status = _stageStatus(stage);
                              return Semantics(
                                button: true,
                                label: l.goToLesson(stage.title),
                                child: LearningTrackTile(
                                  stage: stage,
                                  status: status,
                                  index: index,
                                  isLast: index == learning.stages.length - 1,
                                  onTap: () {
                                    ref
                                        .read(experienceServiceProvider)
                                        .lightHaptic();
                                    context.pushNamed('lessons');
                                  },
                                ),
                              );
                            }, childCount: learning.stages.length),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _DashboardShimmer extends StatelessWidget {
  const _DashboardShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                MediaQuery.paddingOf(context).top + AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.lg,
              ),
              child: const Row(
                children: [
                  ShimmerLoading(
                    width: 44,
                    height: 44,
                    borderRadius: AppRadius.pill,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(width: 80, height: 12),
                        SizedBox(height: AppSpacing.xxs),
                        ShimmerLoading(width: 120, height: 18),
                      ],
                    ),
                  ),
                  ShimmerLoading(
                    width: 60,
                    height: 28,
                    borderRadius: AppRadius.pill,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  ShimmerLoading(
                    width: 60,
                    height: 28,
                    borderRadius: AppRadius.pill,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  ShimmerLoading(
                    width: 60,
                    height: 28,
                    borderRadius: AppRadius.pill,
                  ),
                ],
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            sliver: SliverToBoxAdapter(
              child: ShimmerLoading(
                width: double.infinity,
                height: 140,
                borderRadius: AppRadius.xl,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              0,
              AppSpacing.xxl,
              _kBottomNavPadding,
            ),
            sliver: SliverToBoxAdapter(
              child: ShimmerLoading(
                width: double.infinity,
                height: 200,
                borderRadius: AppRadius.xl,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
