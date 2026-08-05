import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';

class CurrentUserRankBar extends StatelessWidget {
  final int rank;
  final int totalXp;
  final int xpToNext;

  const CurrentUserRankBar({
    super.key,
    required this.rank,
    required this.totalXp,
    required this.xpToNext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: context.surfaceCard,
        border: Border.all(color: PremiumColors.splashBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.person_rounded, size: 20, color: PremiumColors.splashBlue),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.rankingYourPosition(rank, _formatXp(totalXp)),
                style: AppTextStyle.subtitle.copyWith(color: context.textSecondary, fontWeight: FontWeight.w600),
              ),
              if (xpToNext > 0)
                Text(
                  l.rankingXpToTop50(_formatXp(xpToNext)),
                  style: AppTextStyle.label.copyWith(color: context.textTertiary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}
