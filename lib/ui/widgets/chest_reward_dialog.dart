import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/chest_event_bus.dart';
import 'package:sagen/services/share_service.dart';
import 'package:sagen/ui/widgets/chest_widget.dart';
import 'package:sagen/ui/widgets/common/gem_rain_animation.dart';

class ChestRewardDialog extends StatefulWidget {
  final ChestRewardData reward;
  final VoidCallback? onDismiss;

  const ChestRewardDialog({super.key, required this.reward, this.onDismiss});

  static Future<void> show(BuildContext context, ChestRewardData reward) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChestRewardDialog(reward: reward),
    );
  }

  @override
  State<ChestRewardDialog> createState() => _ChestRewardDialogState();
}

class _ChestRewardDialogState extends State<ChestRewardDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealCtrl;
  bool _showRewards = false;
  bool _dismissed = false;
  bool _gemRainShown = false;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _onChestOpened() {
    if (_dismissed) return;
    final exp = ExperienceService.instance;
    exp.mediumHaptic();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_dismissed || !mounted) return;
      setState(() => _showRewards = true);
      _revealCtrl.forward();

      // Show gem rain if there are gems
      if (widget.reward.xp > 0 && !_gemRainShown) {
        _gemRainShown = true;
        final gemCount = (widget.reward.xp / 3).round().clamp(2, 75);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && !_dismissed) {
            GemRainAnimation.show(context, gemCount: gemCount);
          }
        });
      }
    });
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    widget.onDismiss?.call();
    context.pop();
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = context.isDark;
    final r = widget.reward;

    return Semantics(
      label: AppLocalizations.of(context)!.chestRewardDialog,
      child: PopScope(
        canPop: !_dismissed,
        child: Scaffold(
          backgroundColor: (dark ? PremiumColors.darkBg : Colors.white)
              .withValues(alpha: 0.96),
          body: SafeArea(
            child: Semantics(
              button: true,
              label: l.chestCollect,
              child: GestureDetector(
                onTap: _showRewards ? _dismiss : null,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 220,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ChestWidget(
                              key: ValueKey('chest_${r.type.name}'),
                              type: r.type,
                              size: 180,
                              animate: true,
                              onOpenComplete: _onChestOpened,
                            ),
                            if (!_showRewards &&
                                !ProviderScope.containerOf(context)
                                    .read(lowEndDeviceDetectorProvider)
                                    .reduceAnimations)
                              SizedBox(
                                width: 200,
                                height: 200,
                                child: Lottie.asset(
                                  'assets/animations/sparkle.json',
                                  repeat: true,
                                  animate: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            // Glow ring behind chest when opened
                            if (_showRewards)
                              AnimatedBuilder(
                                animation: _revealCtrl,
                                builder: (ctx, _) => Container(
                                  width: 200 + _revealCtrl.value * 40,
                                  height: 200 + _revealCtrl.value * 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        r.type.glowColor.withValues(
                                          alpha: 0.3 * _revealCtrl.value,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _showRewards
                            ? _RewardsPanel(
                                reward: r,
                                animation: _revealCtrl,
                                onDismiss: _dismiss,
                              )
                            : _TitlePanel(type: r.type, title: r.title),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitlePanel extends StatelessWidget {
  final ChestType type;
  final String? title;
  const _TitlePanel({required this.type, this.title});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title ?? l.chestTitle(type.localizedLabel(l)),
          style: AppTextStyle.headlineMedium.copyWith(
            color: PremiumColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l.chestTapToOpen,
          style: AppTextStyle.body.copyWith(color: context.textSecondary),
        ),
      ],
    );
  }
}

class _RewardsPanel extends StatelessWidget {
  final ChestRewardData reward;
  final AnimationController animation;
  final VoidCallback onDismiss;

  const _RewardsPanel({
    required this.reward,
    required this.animation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final r = reward;

    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            r.title ?? l.chestOpenedTitle(r.type.localizedLabel(l)),
            style: AppTextStyle.headline.copyWith(
              color: PremiumColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          if (r.message != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                r.message!,
                style: AppTextStyle.subtitle.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (r.xp > 0)
                _GemRewardChip(gemCount: (r.xp / 3).round().clamp(2, 75)),
              if (r.xp > 0)
                _RewardChip(
                  icon: Icons.auto_awesome_rounded,
                  label: '+${l.xpValue(r.xp)}',
                  color: PremiumColors.xpColor,
                ),
              if (r.streakShields != null && r.streakShields! > 0)
                _RewardChip(
                  icon: Icons.ac_unit_rounded,
                  label: '×${r.streakShields}',
                  color: PremiumColors.premiumBlue,
                ),
              if (r.xpBoost)
                _RewardChip(
                  icon: Icons.bolt_rounded,
                  label: '×2 ${l.profileXpLabel}',
                  color: PremiumColors.streakOrange,
                ),
              for (final itemType in r.specialItems)
                _SpecialItemChip(itemType: itemType),
              for (final cosmeticType in r.cosmeticUnlocks)
                _SpecialItemChip(itemType: cosmeticType),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (r.specialItems.isNotEmpty || r.cosmeticUnlocks.isNotEmpty)
                Semantics(
                  button: true,
                  label: l.shareProfile,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final items = [
                        ...r.specialItems.map((e) => e.displayName),
                        ...r.cosmeticUnlocks.map((e) => e.displayName),
                      ];
                      ShareService.instance.shareImage(
                        Uint8List(0),
                        text: l.chestRewardShareText(
                          items.join(', '),
                          r.type.name,
                        ),
                        source: 'chest_reward',
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18),
                    label: Text(l.shareProfile),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              if (r.specialItems.isNotEmpty || r.cosmeticUnlocks.isNotEmpty)
                const SizedBox(width: AppSpacing.md),
              SizedBox(
                width: 160,
                child: Semantics(
                  button: true,
                  label: l.chestCollect,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      onDismiss();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: r.type.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      elevation: 4,
                      shadowColor: r.type.color.withValues(alpha: 0.4),
                    ),
                    child: Text(l.chestCollect, style: AppTextStyle.cardTitle),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GemRewardChip extends StatelessWidget {
  final int gemCount;
  const _GemRewardChip({required this.gemCount});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '+$gemCount ${AppLocalizations.of(context)?.gems ?? "gems"}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [PremiumColors.accentCyan, PremiumColors.deepPurple],
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: PremiumColors.accentCyan.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, PremiumColors.surfaceTintLight],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '+$gemCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _RewardChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 16, color: color)),
            const SizedBox(width: AppSpacing.xxs),
            Text(label, style: AppTextStyle.bodyBold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _SpecialItemChip extends StatefulWidget {
  final SpecialItemType itemType;
  const _SpecialItemChip({required this.itemType});

  @override
  State<_SpecialItemChip> createState() => _SpecialItemChipState();
}

class _SpecialItemChipState extends State<_SpecialItemChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Color get _color {
    final tier = widget.itemType.rarityTier;
    switch (tier) {
      case 0:
        return PremiumColors.rarityCommon;
      case 1:
        return PremiumColors.rarityUncommon;
      case 2:
        return PremiumColors.rarityRare;
      case 3:
        return PremiumColors.rarityEpic;
      case 4:
        return PremiumColors.rarityLegendary;
      default:
        return PremiumColors.rarityCommon;
    }
  }

  IconData get _icon {
    switch (widget.itemType) {
      case SpecialItemType.focusElixir:
        return Icons.auto_awesome_rounded;
      case SpecialItemType.phoenixFeather:
        return Icons.local_fire_department_rounded;
      case SpecialItemType.sageMonocle:
        return Icons.visibility_rounded;
      case SpecialItemType.titaniumShield:
        return Icons.shield_rounded;
      case SpecialItemType.luckBoost:
        return Icons.casino_rounded;
      case SpecialItemType.timeWarp:
        return Icons.schedule_rounded;
      case SpecialItemType.avatarFrameNeon:
      case SpecialItemType.avatarFrameDragon:
      case SpecialItemType.avatarFrameCrystal:
      case SpecialItemType.avatarFrameSkull:
      case SpecialItemType.avatarFrameGalaxy:
        return Icons.filter_frames_rounded;
      case SpecialItemType.titleCyberSage:
      case SpecialItemType.titleNightGuardian:
      case SpecialItemType.titleDigitalPhoenix:
      case SpecialItemType.titleShadowHacker:
      case SpecialItemType.titleStormBreaker:
        return Icons.title_rounded;
      case SpecialItemType.themeDarkFire:
      case SpecialItemType.themeCyberNeon:
        return Icons.palette_rounded;
      case SpecialItemType.effectDigitalRain:
      case SpecialItemType.effectFireTrail:
        return Icons.auto_awesome_rounded;
    }
  }

  String get _rarityLabel {
    final tier = widget.itemType.rarityTier;
    switch (tier) {
      case 0:
        return '';
      case 1:
        return '★';
      case 2:
        return '★★';
      case 3:
        return '★★★';
      case 4:
        return '★★★★';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.itemType.displayName;
    return AnimatedBuilder(
      animation: _shimmerCtrl,
      builder: (ctx, _) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _color.withValues(alpha: 0.15),
                _color.withValues(alpha: 0.05),
                _color.withValues(alpha: 0.15),
              ],
              stops: [
                (_shimmerCtrl.value - 0.3).clamp(0.0, 1.0),
                _shimmerCtrl.value,
                (_shimmerCtrl.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _color.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _color.withValues(alpha: 0.15),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: Icon(_icon, size: 16, color: _color)),
              const SizedBox(width: 4),
              Text(name, style: AppTextStyle.bodyBold.copyWith(color: _color)),
              if (_rarityLabel.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.xxs),
                Text(
                  _rarityLabel,
                  style: AppTextStyle.label.copyWith(
                    color: _color.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
