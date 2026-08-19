import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/repositories/gem_repository.dart';

class GemHistoryScreen extends ConsumerWidget {
  const GemHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final gemState = ref.watch(gemProvider);
    final transactions = gemState.transactions;

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: PremiumColors.accentCyan,
            leading: Semantics(
              button: true,
              label: l.closeButton,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              ),
            ),
            title: Text(
              l.gemHistoryTitle,
              style: AppTextStyle.titleLg.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [PremiumColors.accentCyan, PremiumColors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.lg,
                AppSpacing.xxl,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  _SummaryChip(
                    icon: Icons.diamond_rounded,
                    value: '${gemState.balance}',
                    label: l.gems,
                    color: PremiumColors.accentCyan,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryChip(
                    icon: Icons.trending_up_rounded,
                    value: '${gemState.totalEarned}',
                    label: l.profileGemsEarned,
                    color: PremiumColors.success,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _SummaryChip(
                    icon: Icons.shopping_cart_rounded,
                    value: '${gemState.totalSpent}',
                    label: l.profileGemsSpent,
                    color: PremiumColors.deepPurple,
                  ),
                ],
              ),
            ),
          ),
          if (transactions.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.diamond_rounded,
                      size: 48,
                      color: context.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.gemHistoryEmpty,
                      style: AppTextStyle.bodyLg.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final tx = transactions[index];
                final isEarned = tx.amount > 0;
                final color = isEarned
                    ? PremiumColors.success
                    : PremiumColors.error;
                final icon = isEarned
                    ? Icons.add_circle_rounded
                    : Icons.remove_circle_rounded;
                final date = tx.timestamp;
                final now = DateTime.now();
                final dateLabel = _formatDate(date, now, l);

                  return _TransactionTile(
                    tx: tx,
                    color: color,
                    icon: icon,
                    dateLabel: dateLabel,
                  ).animate().fadeIn(
                  delay: Duration(milliseconds: index * 30),
                  duration: 300.ms,
                );
              }, childCount: transactions.length),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date, DateTime now, AppLocalizations l) {
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return l.gemHistoryJustNow;
    if (diff.inHours < 1) return l.gemHistoryMinutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l.gemHistoryHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l.gemHistoryYesterday;
    return l.gemHistoryDaysAgo(diff.inDays);
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.subtleBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: AppTextStyle.title.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyle.caption.copyWith(color: context.textTertiary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final GemTransaction tx;
  final Color color;
  final IconData icon;
  final String dateLabel;

  const _TransactionTile({
    required this.tx,
    required this.color,
    required this.icon,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reasonLabel = _reasonLabel(tx.reason, l);
    final isEarned = tx.amount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: 4,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: context.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: context.subtleBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reasonLabel,
                    style: AppTextStyle.bodyMd.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: AppTextStyle.caption.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isEarned ? "+" : ""}${tx.amount}',
              style: AppTextStyle.title.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _reasonLabel(String reason, AppLocalizations l) {
    return switch (reason) {
      'lesson' => l.gemReasonLesson,
      'perfect_lesson' => l.gemReasonPerfectLesson,
      'first_lesson_of_day' => l.gemReasonFirstLesson,
      'daily_bonus' => l.gemReasonDailyBonus,
      'streak_milestone' => l.gemReasonStreakMilestone,
      'achievement' => l.gemReasonAchievement,
      'mission' => l.gemReasonMission,
      'shop' => l.gemReasonShop,
      _ => reason,
    };
  }
}
