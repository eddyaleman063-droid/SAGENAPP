import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/providers/leaderboard_provider.dart';

const Color podiumSilver = PremiumColors.silver;
const Color podiumGold = PremiumColors.gold;
const Color podiumBronze = PremiumColors.bronze;

class PodiumWidget extends StatelessWidget {
  final List<LeaderboardEntry> top3;

  const PodiumWidget({super.key, required this.top3});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (second != null)
                  Expanded(
                    child: _PodiumAvatar(
                      entry: second,
                      rank: 2,
                      color: podiumSilver,
                      height: 140,
                    ),
                  ),
                if (first != null)
                  Expanded(
                    child: _PodiumAvatar(
                      entry: first,
                      rank: 1,
                      color: podiumGold,
                      height: 180,
                      crown: true,
                    ),
                  ),
                if (third != null)
                  Expanded(
                    child: _PodiumAvatar(
                      entry: third,
                      rank: 3,
                      color: podiumBronze,
                      height: 110,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PodiumAvatar extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final Color color;
  final double height;
  final bool crown;

  const _PodiumAvatar({
    required this.entry,
    required this.rank,
    required this.color,
    required this.height,
    this.crown = false,
  });

  String get _initials {
    final parts = entry.displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.length == 1 && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (crown)
          ExcludeSemantics(
            child: Icon(
              Icons.workspace_premium_rounded,
              color: color,
              size: 28,
            ),
          ),
        const SizedBox(height: AppSpacing.xxs),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2.5),
          ),
          child: CircleAvatar(
            backgroundColor: dark
                ? PremiumColors.darkCard
                : context.surfaceCard,
            child: Text(
              _initials,
              style: AppTextStyle.title.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          width: 80,
          child: Text(
            entry.displayName.isNotEmpty
                ? entry.displayName.split(' ').first
                : '???',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption.copyWith(
              color: context.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          '${_formatXp(entry.totalXp)} XP',
          style: AppTextStyle.label.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 48,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
      ],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) return '${(xp / 1000).toStringAsFixed(1)}k';
    return xp.toString();
  }
}
