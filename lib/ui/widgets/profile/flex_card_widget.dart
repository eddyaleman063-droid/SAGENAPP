import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class FlexCardWidget extends ConsumerStatefulWidget {
  final String displayName;
  final String? photoUrl;
  final int level;
  final int xp;
  final int streak;
  final int? rank;
  final String? subtitleText;

  const FlexCardWidget({
    super.key,
    required this.displayName,
    this.photoUrl,
    required this.level,
    required this.xp,
    required this.streak,
    this.rank,
    this.subtitleText,
  });

  @override
  ConsumerState<FlexCardWidget> createState() => FlexCardWidgetState();
}

class FlexCardWidgetState extends ConsumerState<FlexCardWidget> {
  final _repaintKey = GlobalKey();

  Future<Uint8List?> capture() async {
    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  String get _initials {
    final parts = widget.displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return widget.displayName.isNotEmpty ? widget.displayName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return RepaintBoundary(
      key: _repaintKey,
      child: Container(
        width: 360,
        height: 640,
        decoration: const BoxDecoration(
          color: PremiumColors.deepBackground,
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.2,
            colors: [
Color(0x334AC2DD),
              PremiumColors.deepBackground,
              PremiumColors.deepBackground,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),
              CircleAvatar(
                radius: 48,
                backgroundColor: PremiumColors.darkCard,
                backgroundImage: widget.photoUrl != null ? NetworkImage(widget.photoUrl!) : null,
                child: widget.photoUrl == null
                    ? Text(_initials, style: AppTextStyle.displayMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.white))
                    : null,
              ),
                const SizedBox(height: AppSpacing.lg),
              Text(
                widget.displayName,
                style: AppTextStyle.headlineLarge.copyWith(fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xxl),
                  color: const Color(0x334AC2DD),
                  border: Border.all(color: const Color(0x664AC2DD)),
                ),
                child: Text(
                  l.profileLevelValue(widget.level),
                    style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.w600,
                    color: PremiumColors.splashBlue),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.local_fire_department_rounded, color: PremiumColors.streakOrange, size: 24),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${widget.streak}',
                    style: AppTextStyle.displayLarge.copyWith(
                      color: PremiumColors.streakOrange,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    widget.streak == 1 ? l.profileDay : l.profileDays,
                    style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.5)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const ExcludeSemantics(
                    child: Icon(Icons.auto_awesome_rounded, color: PremiumColors.xpColor, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${widget.xp} XP',
                    style: AppTextStyle.title.copyWith(fontWeight: FontWeight.w600,
                      color: PremiumColors.xpColor),
                  ),
                ],
              ),
              if (widget.rank != null) ...[
              const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.xxl),
                    color: const Color(0x33FFD700),
                    border: Border.all(color: const Color(0x44FFD700)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ExcludeSemantics(
                        child: Icon(Icons.emoji_events_rounded, color: PremiumColors.gold, size: 16),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l.rankingPosition(widget.rank!),
                        style: AppTextStyle.bodyMd.copyWith(fontWeight: FontWeight.w600,
                          color: PremiumColors.gold),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(flex: 3),
              Text(
                widget.subtitleText ?? l.flexCardJoinAlliance,
                style: AppTextStyle.caption.copyWith(fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 1.0),
              ),
              const SizedBox(height: AppSpacing.xxxl),
            ],
          ),
        ),
      ),
    );
  }
}
