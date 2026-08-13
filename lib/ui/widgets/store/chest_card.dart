import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';

class ChestCard extends StatelessWidget {
  final bool dark;
  final bool hasUnclaimed;
  final VoidCallback onClaim;
  const ChestCard({
    super.key,
    required this.dark,
    required this.hasUnclaimed,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          colors: [PremiumColors.streakOrange, PremiumColors.achievementEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card(),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: const ExcludeSemantics(
              child: Icon(
                Icons.inventory_2_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasUnclaimed ? l.storeChestAvailable : l.storeChestComeBack,
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  hasUnclaimed ? l.storeChestExpiresIn(2) : l.storeChestRenews,
                  style: AppTextStyle.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          if (hasUnclaimed)
            Semantics(
              button: true,
              label: l.storeOpen,
              child: GestureDetector(
                onTap: () {
                  ExperienceService.instance.mediumHaptic();
                  onClaim();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                  child: Text(
                    l.storeOpen,
                    style: AppTextStyle.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
