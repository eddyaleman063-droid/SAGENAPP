import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

class AchievementItem {
  final Widget icon;
  final String title;
  final String subtitle;

  const AchievementItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class SagenAchievementTile extends StatelessWidget {
  final AchievementItem item;

  const SagenAchievementTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final iconColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: IconTheme.merge(
              data: IconThemeData(color: iconColor, size: 24),
              child: item.icon,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.55),
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
