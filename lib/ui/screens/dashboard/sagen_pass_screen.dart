import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/sagen_pass.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/ui/widgets/common/sagen_notification.dart';

/// SAGEN Pass season screen: season progress, SP earning tips and the
/// 50-level reward track with claimable rewards.
class SagenPassScreen extends ConsumerStatefulWidget {
  const SagenPassScreen({super.key});

  @override
  ConsumerState<SagenPassScreen> createState() => _SagenPassScreenState();
}

class _SagenPassScreenState extends ConsumerState<SagenPassScreen> {
  final Set<int> _claiming = {};

  Future<void> _claimLevel(int level) async {
    if (_claiming.contains(level)) return;
    final l = AppLocalizations.of(context)!;
    final haptics = ref.read(experienceServiceProvider);
    setState(() => _claiming.add(level));
    try {
      final rewarded = await ref.read(sagenPassProvider.notifier).claimLevel(level);
      if (!mounted) return;
      if (rewarded != null) {
        haptics.successHaptic();
        SagenNotification.show(
          context,
          message: '${l.passRewardClaimed} ${rewarded.localizedRewardName(l)}',
          type: NotificationType.success,
        );
      } else {
        haptics.errorHaptic();
        SagenNotification.show(
          context,
          message: l.passClaimFailed,
          type: NotificationType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _claiming.remove(level));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final pass = ref.watch(sagenPassProvider);
    final levels = SagenPass.allLevels;

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(sagenPassProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 240,
              backgroundColor: context.surfaceBackground,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.pin,
                background: _PassHeader(pass: pass),
              ),
            ),
            SliverToBoxAdapter(
              child: _HowToEarnCard().animate().fadeIn(delay: 100.ms, duration: 350.ms),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.md),
                child: Row(
                  children: [
                    const ExcludeSemantics(child: Icon(Icons.card_giftcard_rounded, size: 18, color: PremiumColors.accentYellow)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l.passLevelsTitle,
                        style: AppTextStyle.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      l.passRewards(pass.claimedLevels.length, SagenPass.maxLevel),
                      style: AppTextStyle.subtitle.copyWith(color: context.textTertiary),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              sliver: SliverToBoxAdapter(
                child: _LegendRow(),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(top: AppSpacing.md)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final level = levels[i];
                  final reached = level.level <= pass.currentLevel;
                  final claimed = pass.isLevelClaimed(level.level);
                  final claimable = reached && !claimed;
                  return _PassLevelTile(
                    level: level,
                    reached: reached,
                    claimed: claimed,
                    isLoading: _claiming.contains(level.level),
                    onTap: claimable ? () => _claimLevel(level.level) : null,
                  );
                }, childCount: levels.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassHeader extends StatelessWidget {
  final SagenPass pass;

  const _PassHeader({required this.pass});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    final isMax = pass.isMaxLevel;
    final required = pass.spForNextLevel;
    final progress = isMax ? 1.0 : pass.progressFraction;
    final now = DateTime.now();
    final seasonEnd = pass.seasonStart.add(Duration(days: pass.seasonDurationDays));
    final daysLeft = seasonEnd.difference(now).inDays.clamp(0, 9999);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? [PremiumColors.gradientPromoDark1, PremiumColors.gradientPromoDark2]
              : [PremiumColors.gradientSupportLight1, PremiumColors.gradientSupportLight2],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xs, AppSpacing.xxl, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Icon(Icons.diamond_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.sagenPassTitle,
                          style: AppTextStyle.titleLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l.passEarnSp,
                          style: AppTextStyle.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${pass.currentLevel}',
                    style: AppTextStyle.hero.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      isMax ? l.passMaxLevel : l.passLevel(pass.currentLevel + 1),
                      style: AppTextStyle.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ),
                  const Spacer(),
                  if (!isMax)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        l.passProgress(pass.currentSP, required),
                        style: AppTextStyle.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(PremiumColors.accentYellow),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.passDaysLeft(daysLeft),
                style: AppTextStyle.caption.copyWith(color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowToEarnCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.xl, AppSpacing.xxl, 0),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: context.surfaceCard,
          border: Border.all(color: context.subtleBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ExcludeSemantics(child: Icon(Icons.bolt_rounded, size: 18, color: PremiumColors.accentYellow)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l.passHowToEarnTitle,
                    style: AppTextStyle.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _TipRow(icon: Icons.school_rounded, text: l.passHowToEarnLesson),
            _TipRow(icon: Icons.star_rounded, text: l.passHowToEarnPerfect),
            _TipRow(icon: Icons.replay_rounded, text: l.passHowToEarnReview),
            _TipRow(icon: Icons.task_alt_rounded, text: l.passHowToEarnMission),
            const Divider(height: AppSpacing.xl),
            _TipRow(icon: Icons.info_outline_rounded, text: l.passHowToEarnDailyLimit),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: context.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.caption.copyWith(color: context.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Row(
      children: [
        _LegendDot(color: context.subtle, label: l.passLocked),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: PremiumColors.accentCyan, label: l.passReached),
        const SizedBox(width: AppSpacing.lg),
        _LegendDot(color: PremiumColors.success, label: l.passClaimedLabel),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: AppTextStyle.caption.copyWith(color: context.textTertiary)),
      ],
    );
  }
}

class _PassLevelTile extends StatelessWidget {
  final PassLevel level;
  final bool reached;
  final bool claimed;
  final bool isLoading;
  final VoidCallback? onTap;

  const _PassLevelTile({
    required this.level,
    required this.reached,
    required this.claimed,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    final Color contentColor;
    final Color background;
    final Color borderColor;

    if (claimed) {
      contentColor = context.textTertiary;
      background = context.surfaceCard;
      borderColor = context.subtleBorder;
    } else if (reached) {
      contentColor = Colors.white;
      background = Colors.transparent;
      borderColor = PremiumColors.accentCyan.withValues(alpha: 0.6);
    } else {
      contentColor = context.textTertiary;
      background = context.surfaceCard;
      borderColor = context.subtleBorder;
    }

    return Semantics(
      key: ValueKey('pass_tile_${level.level}'),
      button: onTap != null,
      label: '${l.passLevel(level.level)} · ${level.localizedRewardName(l)}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            gradient: reached && !claimed
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [PremiumColors.primary, PremiumColors.primaryAccent],
                  )
                : null,
            color: reached && !claimed ? null : background,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: reached && !claimed
                  ? PremiumColors.accentCyan.withValues(alpha: 0.6)
                  : borderColor,
              width: reached && !claimed ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${level.level}',
                      style: AppTextStyle.label.copyWith(
                        color: claimed || !reached ? contentColor : Colors.white,
                        fontWeight: reached && !claimed ? FontWeight.bold : FontWeight.w600,
                      ),
                    ),
                    ExcludeSemantics(
                      child: Icon(
                        _iconForReward(level.rewardType),
                        size: 20,
                        color: claimed
                            ? context.textTertiary
                            : reached
                                ? Colors.white
                                : context.subtle,
                      ),
                    ),
                  ],
                ),
              ),
              if (claimed)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: const BoxDecoration(
                      color: PremiumColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                  ),
                ),
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _iconForReward(PassRewardType type) {
  switch (type) {
    case PassRewardType.title:
      return Icons.badge_rounded;
    case PassRewardType.avatarFrame:
      return Icons.filter_frames_rounded;
    case PassRewardType.cosmetic:
      return Icons.whatshot_rounded;
    case PassRewardType.chest:
      return Icons.inventory_2_rounded;
    case PassRewardType.donation:
      return Icons.favorite_rounded;
    case PassRewardType.xp:
      return Icons.bolt_rounded;
    case PassRewardType.item:
      return Icons.shield_rounded;
  }
}
