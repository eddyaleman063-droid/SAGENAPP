import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/achievement_service.dart';

class AchievementCard extends StatelessWidget {
  final AchievementModel achievement;
  final bool dark;
  const AchievementCard({
    super.key,
    required this.achievement,
    required this.dark,
  });

  static final _rarityGradients = <int, List<Color>>{
    10: [PremiumColors.achievementTier10, PremiumColors.achievementTier20],
    20: [PremiumColors.achievementTier10, PremiumColors.achievementTier20Light],
    25: [PremiumColors.rarityLegendary, PremiumColors.achievementTier25],
    30: [PremiumColors.rarityLegendary, PremiumColors.achievementTier30],
    40: [PremiumColors.deepPurple, PremiumColors.achievementTier40],
    50: [PremiumColors.deepPurple, PremiumColors.achievementTier40],
    60: [PremiumColors.achievementTier60, PremiumColors.rarityLegendary],
    100: [PremiumColors.achievementTier60, PremiumColors.achievementTier25],
    200: [
      PremiumColors.achievementTier60,
      PremiumColors.achievementTier200Light,
    ],
  };

  List<Color> get _gradient {
    for (final entry in _rarityGradients.entries) {
      if (achievement.xpReward <= entry.key) return entry.value;
    }
    return _rarityGradients.values.last;
  }

  String _rarityLabel(AppLocalizations l) {
    if (achievement.xpReward <= 20) return l.raritySilver;
    if (achievement.xpReward <= 40) return l.rarityGold;
    return l.rarityPlatinum;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final unlocked = achievement.unlocked;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: unlocked ? PremiumColors.darkCard : context.subtle,
        border: Border.all(
          color: unlocked
              ? _gradient.first.withValues(alpha: 0.2)
              : context.subtleBorder,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: unlocked ? LinearGradient(colors: _gradient) : null,
                  color: unlocked ? null : context.subtle,
                ),
                child: ExcludeSemantics(
                  child: Icon(
                    achievement.icon,
                    size: 20,
                    color: unlocked ? Colors.white : context.textTertiary,
                  ),
                ),
              ),
              if (!unlocked)
                Positioned(
                  top: 2,
                  right: 2,
                  child: ExcludeSemantics(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 12,
                      color: context.textTertiary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _localizedTitle(achievement.id, l),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: unlocked ? context.textPrimary : context.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            unlocked
                ? _localizedDescription(achievement.id, l)
                : l.achievementLocked,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.tiny.copyWith(
              color: unlocked ? context.textTertiary : context.subtle,
            ),
          ),
          if (unlocked) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                gradient: LinearGradient(colors: _gradient),
              ),
              child: Text(
                _rarityLabel(l),
                style: AppTextStyle.micro.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _localizedTitle(String id, AppLocalizations l) =>
      _titles[id]?.call(l) ?? id;

  static String _localizedDescription(String id, AppLocalizations l) =>
      _descriptions[id]?.call(l) ?? id;

  static final Map<String, String Function(AppLocalizations)> _titles = {
    'first_lesson': (l) => l.achievementFirstShield,
    'five_lessons': (l) => l.achievementLearner,
    'ten_lessons': (l) => l.achievementDigitalStudent,
    'twenty_five_lessons': (l) => l.achievementGuardian,
    'fifty_lessons': (l) => l.achievementCyberGuardian,
    'stage_complete': (l) => l.achievementConqueror,
    'all_stages': (l) => l.achievementDigitalMaster,
    'streak_3': (l) => l.achievementConstant,
    'streak_7': (l) => l.achievementDigitalWeek,
    'streak_30': (l) => l.achievementLegendaryStreak,
    'perfect_lesson': (l) => l.achievementPerfect,
    'sage_talk': (l) => l.achievementCurious,
  };

  static final Map<String, String Function(AppLocalizations)> _descriptions = {
    'first_lesson': (l) => l.achievementFirstShieldDesc,
    'five_lessons': (l) => l.achievementLearnerDesc,
    'ten_lessons': (l) => l.achievementDigitalStudentDesc,
    'twenty_five_lessons': (l) => l.achievementGuardianDesc,
    'fifty_lessons': (l) => l.achievementCyberGuardianDesc,
    'stage_complete': (l) => l.achievementConquerorDesc,
    'all_stages': (l) => l.achievementDigitalMasterDesc,
    'streak_3': (l) => l.achievementConstantDesc,
    'streak_7': (l) => l.achievementDigitalWeekDesc,
    'streak_30': (l) => l.achievementLegendaryStreakDesc,
    'perfect_lesson': (l) => l.achievementPerfectDesc,
    'sage_talk': (l) => l.achievementCuriousDesc,
  };
}
