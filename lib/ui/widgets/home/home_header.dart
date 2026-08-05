import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  final String displayName;
  final int streak;
  final String greeting;
  final double totalDonated;
  final int gems;

  const HomeHeader({
    super.key,
    required this.displayName,
    required this.streak,
    required this.greeting,
    this.totalDonated = 0.0,
    this.gems = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        MediaQuery.paddingOf(context).top + AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: PremiumColors.splashBlue.withValues(alpha: 0.2),
            child: Text(
              _initials,
              style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold,
                color: PremiumColors.splashBlue),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: AppTextStyle.caption.copyWith(color: context.textSecondary),
                ),
                Text(
                  displayName.isNotEmpty ? displayName : l.homeDefaultName,
                  style: AppTextStyle.title.copyWith(fontWeight: FontWeight.bold,
                    color: context.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _Pill(
            icon: Icons.local_fire_department_rounded,
            value: '$streak',
            label: l.daysLabel,
          ),
          const SizedBox(width: AppSpacing.sm),
          _GemPill(gems: gems),
          const SizedBox(width: AppSpacing.sm),
          _Pill(
            icon: Icons.favorite_rounded,
            value: totalDonated > 0 ? '\$${totalDonated.toStringAsFixed(0)}' : '0',
            label: l.profileDonations,
          ),
        ],
      ),
    );
  }

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || displayName.trim().isEmpty) return 'G';
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : 'G';
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _Pill({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.subtle,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 14, color: context.textSecondary),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            value,
            style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.bold,
              color: context.textPrimary),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            label,
            style: AppTextStyle.tiny.copyWith(color: context.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _GemPill extends StatelessWidget {
  final int gems;
  const _GemPill({required this.gems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.accentCyan.withValues(alpha: 0.12),
            PremiumColors.deepPurple.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: PremiumColors.accentCyan.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PremiumColors.accentCyan, PremiumColors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$gems',
            style: AppTextStyle.subtitle.copyWith(
              fontWeight: FontWeight.bold,
              color: PremiumColors.accentCyan,
            ),
          ),
        ],
      ),
    );
  }
}
