import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class LevelUpCelebration extends StatefulWidget {
  final int newLevel;
  final VoidCallback onComplete;
  const LevelUpCelebration({super.key, required this.newLevel, required this.onComplete});

  @override
  State<LevelUpCelebration> createState() => _LevelUpCelebrationState();
}

class _LevelUpCelebrationState extends State<LevelUpCelebration>
    with TickerProviderStateMixin {
  late AnimationController _mainCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _textCtrl;
  late AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    _mainCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _ringCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));

    _mainCtrl.forward();
    _ringCtrl.forward();
    _textCtrl.forward();
    _particleCtrl.repeat();

    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _ringCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Semantics(
      label: '¡Subiste de nivel! Nuevo nivel: ${widget.newLevel}',
      container: true,
      liveRegion: true,
      child: Material(
        color: Colors.black.withValues(alpha: 0.7),
        child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _mainCtrl,
          builder: (context, _) => Stack(
          children: [
            ...List.generate(24, (i) => _buildParticle(i)),
            Center(
              child: ScaleTransition(
                scale: CurvedAnimation(parent: _mainCtrl, curve: Curves.elasticOut),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _ringCtrl,
                          builder: (context, _) {
                            final ringOpacity = max(0.0, 1.0 - _ringCtrl.value);
                            final ringScale = 1.0 + _ringCtrl.value * 0.6;
                            return Transform.scale(
                              scale: ringScale,
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: PremiumColors.achievementEnd.withValues(alpha: ringOpacity * 0.6),
                                    width: 3,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                PremiumColors.achievementEnd.withValues(alpha: 0.3),
                                PremiumColors.achievementEnd.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${widget.newLevel}',
                              style: AppTextStyle.hero.copyWith(
                                color: PremiumColors.achievementEnd,
                                fontWeight: FontWeight.w900,
                                fontSize: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
                      child: Text(
                        l.profileLevelValue(widget.newLevel),
                        style: AppTextStyle.headlineLarge.copyWith(
                          color: PremiumColors.achievementEnd,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FadeTransition(
                      opacity: CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn),
                      child: Text(
                        l.xpLevelUp,
                        style: AppTextStyle.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildParticle(int index) {
    final rng = Random(index * 137);
    final colors = [
      PremiumColors.achievementEnd,
      PremiumColors.xpColor,
      PremiumColors.splashBlue,
      PremiumColors.success,
      PremiumColors.levelUpRed,
    ];
    return AnimatedBuilder(
      animation: _particleCtrl,
      builder: (context, _) {
        final t = _particleCtrl.value;
        final angle = (index / 24) * 2 * pi + t * pi * 0.3;
        final radius = 80.0 + t * 120.0 + rng.nextDouble() * 40;
        final opacity = max(0.0, 1.0 - t * 1.2);
        return Positioned(
          left: MediaQuery.of(context).size.width / 2 + cos(angle) * radius - 3,
          top: MediaQuery.of(context).size.height / 2 + sin(angle) * radius - 3,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors[index % colors.length],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Shows level-up celebration overlay. Call from any context.
void showLevelUpCelebration(BuildContext context, int newLevel) {
  Navigator.of(context).push(PageRouteBuilder(
    opaque: false,
    barrierDismissible: false,
    pageBuilder: (context, animation, secondaryAnimation) => LevelUpCelebration(
      newLevel: newLevel,
      onComplete: () => Navigator.of(context).pop(),
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  ));
}
