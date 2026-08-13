import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  const StatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: context.surfaceTinted,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyle.caption.copyWith(color: context.textTertiary),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyle.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class RewardBadge extends StatelessWidget {
  final int xp;
  const RewardBadge({super.key, required this.xp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        gradient: const LinearGradient(
          colors: [PremiumColors.primary, PremiumColors.primaryAccent],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ExcludeSemantics(
            child: Icon(Icons.star_rounded, size: 18, color: Colors.white),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$xp XP',
            style: AppTextStyle.bodyBold.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
