import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';

class MiniGameHub extends StatelessWidget {
  const MiniGameHub({super.key});

  static const _games = [
    (MiniGameType.memoryFlip, Icons.grid_view_rounded, PremiumColors.xpColor),
    (MiniGameType.wordMatch, Icons.swap_horiz_rounded, PremiumColors.gameBlue),
    (MiniGameType.speedSort, Icons.sort_rounded, PremiumColors.gameOrange),
    (MiniGameType.patternTrace, Icons.pattern_rounded, PremiumColors.success),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = [
      l.miniGameMemory,
      l.miniGameWord,
      l.miniGameSpeed,
      l.miniGamePattern,
    ];
    final descriptions = [
      l.miniGameMemoryDesc,
      l.miniGameWordDesc,
      l.miniGameSpeedDesc,
      l.miniGamePatternDesc,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l.miniGameTitle)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.miniGameSubtitle,
              style: AppTextStyle.bodyMd.copyWith(color: context.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 4,
                    itemBuilder: (ctx, i) =>
                        _GameCard(
                              icon: _games[i].$2,
                              color: _games[i].$3,
                              title: labels[i],
                              description: descriptions[i],
                              onTap: () {
                                ExperienceService.instance.mediumHaptic();
                                context.push('/mini-game/${_games[i].$1.name}');
                              },
                            )
                            .animate()
                            .fadeIn(delay: (i * 100).ms, duration: 400.ms)
                            .scale(begin: const Offset(0.9, 0.9)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GameCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title - $description',
      child: GestureDetector(
        onTap: () {
          ExperienceService.instance.lightHaptic();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            color: context.surfaceCard,
            border: Border.all(color: color.withValues(alpha: 0.2)),
            boxShadow: AppShadows.card(color: context.subtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: color.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTextStyle.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                description,
                style: AppTextStyle.caption.copyWith(
                  color: context.textTertiary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
