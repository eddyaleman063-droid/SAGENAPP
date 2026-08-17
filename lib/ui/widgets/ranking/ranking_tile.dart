import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/leaderboard_provider.dart';
import 'package:sagen/utils/string_utils.dart';

class RankingTileWidget extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const RankingTileWidget({
    super.key,
    required this.rank,
    required this.entry,
    this.isCurrentUser = false,
  });

  String get _initials => userInitials(entry.displayName);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: context.surfaceCard,
        border: Border.all(
          color: isCurrentUser
              ? PremiumColors.splashBlue.withValues(alpha: 0.3)
              : context.borderSubtle,
        ),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '#$rank',
                style: AppTextStyle.subtitle.copyWith(
                  color: isCurrentUser
                      ? PremiumColors.splashBlue
                      : context.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            CircleAvatar(
              radius: 16,
              backgroundColor: isCurrentUser
                  ? PremiumColors.splashBlue.withValues(alpha: 0.2)
                  : dark
                  ? PremiumColors.darkSurface
                  : context.surfaceCard,
              child: Text(
                _initials,
                style: AppTextStyle.label.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textSecondary,
                ),
              ),
            ),
          ],
        ),
        title: Text(
          entry.displayName.isNotEmpty
              ? entry.displayName
              : AppLocalizations.of(context)!.unknownLabel,
          style: AppTextStyle.bodyMd.copyWith(
            color: isCurrentUser
                ? PremiumColors.splashBlue
                : context.textSecondary,
            fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.bolt_rounded,
                size: 16,
                color: PremiumColors.streakOrange.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              _formatXp(entry.totalXp),
              style: AppTextStyle.subtitle.copyWith(
                color: context.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 0,
        ),
        dense: true,
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}
