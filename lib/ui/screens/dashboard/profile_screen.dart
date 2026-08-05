import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';

import 'package:sagen/ui/widgets/common/premium_loader.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/profile/achievement_card.dart';
import 'package:sagen/ui/widgets/profile/flex_card_share_sheet.dart';
import 'package:sagen/ui/widgets/profile/profile_header_widget.dart';
import 'package:sagen/ui/widgets/profile/settings_actions.dart';
import 'package:sagen/ui/widgets/profile/stat_card_widget.dart';
import 'package:sagen/ui/widgets/store/sagen_support_card.dart';
import 'package:sagen/core/theme/app_colors.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with AutomaticKeepAliveClientMixin {
  void _showFlexCard(BuildContext context, WidgetRef ref) {
    ref.read(experienceServiceProvider).lightHaptic();
    final auth = ref.read(authProvider);
    final learning = ref.read(learningProvider);
    final streak = ref.read(streakProvider);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FlexCardShareSheet(
        displayName: auth.displayName,
        photoUrl: auth.photoUrl,
        level: learning.currentLevel,
        xp: learning.totalXpEarned,
        streak: streak.currentStreak,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final displayName = ref.watch(authProvider.select((a) => a.displayName));
    final photoUrl = ref.watch(authProvider.select((a) => a.photoUrl));
    final learning = ref.watch(learningProvider);
    final currentStreak = ref.watch(streakProvider.select((s) => s.currentStreak));
    final achievements = ref.watch(achievementProvider);

    if (learning.isLoading) {
      return PremiumLoader(
        loading: true,
        message: l.loading,
        child: Scaffold(
          backgroundColor: context.surfaceBackground,
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      floatingActionButton: Semantics(
        button: true,
        label: l.shareProfile,
        child: FloatingActionButton(
          onPressed: () => _showFlexCard(context, ref),
          backgroundColor: PremiumColors.splashBlue,
          child: const Icon(Icons.share_rounded, color: Colors.white),
        ),
      ),
      body: RepaintBoundary(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(learningProvider);
            ref.invalidate(achievementProvider);
          },
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileHeaderWidget(
              displayName: displayName,
              photoUrl: photoUrl,
              currentLevel: learning.currentLevel,
              xp: learning.totalXpEarned,
              nextLevelXp: learning.nextLevelXp,
              hasGoldFrame: ref.watch(shopProvider.select((s) => s.items.any((i) => i.id == 'gold_frame' && i.isOwned))),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
              child: Row(
                children: [
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.local_fire_department_rounded,
                      value: '$currentStreak',
                      label: l.profileStreak,
                      iconColor: PremiumColors.streakOrange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: StatCardWidget(
                      icon: Icons.auto_awesome_rounded,
                      value: '${learning.totalXpEarned}',
                      label: l.profileXpLabel,
                      iconColor: PremiumColors.xpColor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                   Expanded(
                    child: StatCardWidget(
                      icon: Icons.volunteer_activism_rounded,
                      value: '${l.currencySymbol}${learning.totalDonated.toStringAsFixed(2)}',
                      label: l.profileDonations,
                      iconColor: PremiumColors.achievementEnd,
                      accentColor: PremiumColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
              child: SagenSupportCard(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
              child: Row(
                children: [
                  const ExcludeSemantics(child: Icon(Icons.emoji_events_rounded, size: 18, color: PremiumColors.achievementStart)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l.profileAchievements,
                    style: AppTextStyle.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${achievements.unlockedCount}/${achievements.totalCount}',
                    style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
                  ),
                ],
              ),
            ),
          ),
          if (achievements.totalCount == 0)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(
                      child: SageEmotionWidget(emotion: SageEmotion.thinking),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.emptyProfile,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.bodyMd.copyWith(color: context.textTertiary),
                    ),
                  ],
                ),
              ),
            )
          else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, 0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 0.85,
              ),
                delegate: SliverChildBuilderDelegate(
                (ctx, i) => AchievementCard(achievement: achievements.achievements[i], dark: dark),
                childCount: achievements.achievements.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, 32),
              child: SettingsActions(dark: dark),
            ),
          ),
        ],
      ),
      ),
        ),
    );
  }
}


