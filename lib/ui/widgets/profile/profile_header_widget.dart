import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String displayName;
  final String? photoUrl;
  final int currentLevel;
  final int xp;
  final int nextLevelXp;
  final bool hasGoldFrame;

  const ProfileHeaderWidget({
    super.key,
    required this.displayName,
    this.photoUrl,
    required this.currentLevel,
    required this.xp,
    required this.nextLevelXp,
    this.hasGoldFrame = false,
  });

  double get _levelProgress =>
      nextLevelXp > 0 ? (xp % nextLevelXp) / nextLevelXp : 0.0;
  int get _xpInLevel => xp % nextLevelXp;

  String _rank(AppLocalizations l) {
    if (currentLevel >= 50) return l.rankCybersecurityLegend;
    if (currentLevel >= 30) return l.rankEliteDefender;
    if (currentLevel >= 20) return l.rankExperiencedWarrior;
    if (currentLevel >= 10) return l.rankActiveLearner;
    return l.rankNovice;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PremiumColors.primaryDark,
            PremiumColors.deepBackground,
            PremiumColors.deepBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.xxl),
          bottomRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.xl,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Column(
            children: [
              _buildAvatar(context),
              const SizedBox(height: AppSpacing.lg),
              _buildName(l),
              const SizedBox(height: AppSpacing.xs),
              _buildRank(l),
              const SizedBox(height: AppSpacing.lg),
              _buildLevelBar(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gold frame ring
          if (hasGoldFrame)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      PremiumColors.gold,
                      PremiumColors.goldDark,
                      PremiumColors.gold,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumColors.gold.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ExcludeSemantics(
            child: CircularProgressIndicator(
              value: _levelProgress.clamp(0.0, 1.0),
              strokeWidth: 3.5,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                hasGoldFrame ? PremiumColors.gold : PremiumColors.splashBlue,
              ),
            ),
          ),
          Semantics(
            label: AppLocalizations.of(context)!.profilePhoto,
            excludeSemantics: true,
            child: Center(
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: photoUrl != null && photoUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl!,
                          fit: BoxFit.cover,
                          memCacheWidth: 156,
                          memCacheHeight: 156,
                          placeholder: (_, _) => _fallbackAvatar(),
                          errorWidget: (_, _, _) => _fallbackAvatar(),
                        )
                      : _fallbackAvatar(),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: PremiumColors.splashBlue,
              ),
              child: Center(
                child: Text(
                  '$currentLevel',
                  style: AppTextStyle.caption.copyWith(
                    fontWeight: FontWeight.bold,
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

  Widget _fallbackAvatar() {
    return ExcludeSemantics(
      child: Container(
        color: Colors.white.withValues(alpha: 0.1),
        child: const Icon(
          Icons.shield_rounded,
          size: 40,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildName(AppLocalizations l) {
    return Text(
      displayName.isNotEmpty ? displayName : l.profileDefaultName,
      style: AppTextStyle.headlineMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildRank(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        color: Colors.white.withValues(alpha: 0.1),
      ),
      child: Text(
        _rank(l),
        style: AppTextStyle.caption.copyWith(
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildLevelBar(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: Colors.white.withValues(alpha: 0.08),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l.profileLevelValue(currentLevel),
                style: AppTextStyle.subtitle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$_xpInLevel / ${l.xpValue(nextLevelXp)}',
                style: AppTextStyle.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Semantics(
              label: l.levelProgress((_levelProgress * 100).round()),
              value: '${(_levelProgress * 100).round()}',
              child: LinearProgressIndicator(
                value: _levelProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  PremiumColors.splashBlue,
                ),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
