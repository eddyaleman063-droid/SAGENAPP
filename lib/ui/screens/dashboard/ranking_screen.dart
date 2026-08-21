import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import '../../../core/theme/theme_constants.dart';

import '../../widgets/ranking/podium_widget.dart';
import '../../widgets/ranking/ranking_tile.dart';
import '../../widgets/ranking/current_user_rank_bar.dart';
import '../../widgets/common/sage_emotion_widget.dart';
import '../../../services/sage_emotion_service.dart';
import '../../widgets/profile/flex_card_widget.dart';
import '../../widgets/shimmer_loading.dart';
import 'package:sagen/core/theme/app_colors.dart';

class RankingScreen extends ConsumerStatefulWidget {
  const RankingScreen({super.key});

  @override
  ConsumerState<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends ConsumerState<RankingScreen>
    with AutomaticKeepAliveClientMixin {
  void _showFlexCard(
    BuildContext context,
    WidgetRef ref,
    LeaderboardEntry entry,
    int rank,
  ) {
    ref.read(experienceServiceProvider).lightHaptic();
    final auth = ref.read(authProvider);
    final learning = ref.read(learningProvider);
    final streak = ref.read(streakProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RankingFlexCardShareSheet(
        displayName: entry.displayName,
        photoUrl: entry.photoUrl ?? auth.photoUrl,
        level: learning.currentLevel,
        xp: entry.totalXp,
        streak: streak.currentStreak,
        rank: rank,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUid = ref.watch(authProvider.select((a) => a.uid));

    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.surfaceBackground,
      floatingActionButton: leaderboardAsync.when(
        loading: () => null,
        error: (err, stack) => null,
        data: (entries) {
          final currentIndex = entries.indexWhere((e) => e.uid == currentUid);
          if (currentIndex < 0) return null;
          return Semantics(
            button: true,
            label: l.shareRanking,
            child: FloatingActionButton(
              onPressed: () => _showFlexCard(
                context,
                ref,
                entries[currentIndex],
                currentIndex + 1,
              ),
              backgroundColor: PremiumColors.splashBlue,
              child: const Icon(Icons.share_rounded, color: Colors.white),
            ),
          );
        },
      ),
      body: SafeArea(
        child: leaderboardAsync.when(
          loading: () => const _RankingShimmer(),
          error: (err, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.error_outline,
                    size: 48,
                    color: PremiumColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l.rankingError,
                  style: AppTextStyle.body.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: () {
                    ExperienceService.instance.lightHaptic();
                    ref.invalidate(leaderboardProvider);
                  },
                  child: Text(l.retry),
                ),
              ],
            ),
          ),
          data: (entries) =>
              _RankingContent(entries: entries, currentUid: currentUid),
        ),
      ),
    );
  }
}

class _RankingContent extends ConsumerWidget {
  final List<LeaderboardEntry> entries;
  final String? currentUid;

  const _RankingContent({required this.entries, required this.currentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;

    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(
              child: SageEmotionWidget(emotion: SageEmotion.curious, size: 64),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l.rankingEmptyMessage,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMd.copyWith(color: context.textTertiary),
            ),
          ],
        ),
      );
    }

    final top3 = entries.length > 3 ? entries.sublist(0, 3) : entries;
    final rest = entries.length > 3 ? entries.sublist(3) : <LeaderboardEntry>[];

    final currentIndex = entries.indexWhere((e) => e.uid == currentUid);
    final currentEntry = currentIndex >= 0 ? entries[currentIndex] : null;
    final isInTop50 = currentIndex >= 0;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(leaderboardProvider);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              final horizontalPadding = isWide
                  ? AppSpacing.xxl * 2.0
                  : AppSpacing.xxl.toDouble();
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        MediaQuery.paddingOf(context).top + AppSpacing.xxl,
                        horizontalPadding,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l.rankingTitle,
                            style: AppTextStyle.headline.copyWith(
                              fontSize: isWide ? 30 : 26,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l.rankingSubtitle,
                            style: AppTextStyle.subtitle.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
                    ),
                  ),
                  if (top3.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                        child: PodiumWidget(top3: top3),
                      ),
                    ),
                  if (rest.isNotEmpty)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = rest[index];
                          final rank = index + 4;
                          return RankingTileWidget(
                                rank: rank,
                                entry: entry,
                                isCurrentUser: entry.uid == currentUid,
                              )
                              .animate()
                              .fadeIn(delay: (index * 40).ms, duration: 300.ms)
                              .slideX(begin: 0.05);
                        }, childCount: rest.length),
                      ),
                    ),
                  if (isInTop50 && currentIndex >= 3)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          AppSpacing.sm,
                          horizontalPadding,
                          AppSpacing.xxl,
                        ),
                        child: RankingTileWidget(
                          rank: currentIndex + 1,
                          entry: entries[currentIndex],
                          isCurrentUser: true,
                        ),
                      ),
                    ),
                  if (!isInTop50)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        child: Center(
                          child: Text(
                            l.rankingEmptyMessage,
                            style: AppTextStyle.subtitle.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
        if (!isInTop50 && currentEntry != null && entries.isNotEmpty)
          Positioned(
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            bottom: AppSpacing.xl,
            child: CurrentUserRankBar(
              rank: currentIndex + 1,
              totalXp: currentEntry.totalXp,
              xpToNext: currentIndex > 0
                  ? entries[currentIndex - 1].totalXp - currentEntry.totalXp
                  : 0,
            ),
          ),
      ],
    );
  }
}

class _RankingFlexCardShareSheet extends ConsumerStatefulWidget {
  final String displayName;
  final String? photoUrl;
  final int level;
  final int xp;
  final int streak;
  final int rank;

  const _RankingFlexCardShareSheet({
    required this.displayName,
    this.photoUrl,
    required this.level,
    required this.xp,
    required this.streak,
    required this.rank,
  });

  @override
  ConsumerState<_RankingFlexCardShareSheet> createState() =>
      _RankingFlexCardShareSheetState();
}

class _RankingFlexCardShareSheetState
    extends ConsumerState<_RankingFlexCardShareSheet> {
  final _flexCardKey = GlobalKey<FlexCardWidgetState>();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.85,
      margin: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        color: context.surfaceBackground,
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              color: context.subtle,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              child: FlexCardWidget(
                key: _flexCardKey,
                displayName: widget.displayName,
                photoUrl: widget.photoUrl,
                level: widget.level,
                xp: widget.xp,
                streak: widget.streak,
                rank: widget.rank,
                subtitleText: l.rankingShareSubtitle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.md,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Semantics(
                button: true,
                label: _sharing ? l.sharing : l.shareRanking,
                child: ElevatedButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? const ExcludeSemantics(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    _sharing ? l.rankingSharing : l.rankingShareButton,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.splashBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: PremiumColors.splashBlue
                        .withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final bytes = await _flexCardKey.currentState?.capture();
      if (!mounted) return;
      if (bytes != null) {
        await ref
            .read(shareServiceProvider)
            .shareImage(
              bytes,
              text: AppLocalizations.of(context)?.flexCardJoinAlliance,
              source: 'ranking',
            );
      }
      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}

class _RankingShimmer extends StatelessWidget {
  const _RankingShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          0,
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  width: 80,
                  height: 80,
                  borderRadius: AppRadius.pill,
                ),
                SizedBox(width: AppSpacing.md),
                ShimmerLoading(
                  width: 80,
                  height: 80,
                  borderRadius: AppRadius.pill,
                ),
                SizedBox(width: AppSpacing.md),
                ShimmerLoading(
                  width: 80,
                  height: 80,
                  borderRadius: AppRadius.pill,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            ...List.generate(
              5,
              (i) => const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.md),
                child: ShimmerLoading(
                  width: double.infinity,
                  height: 56,
                  borderRadius: AppRadius.lg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
