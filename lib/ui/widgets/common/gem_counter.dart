import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/providers/providers.dart';

/// Spectacular gem counter with animated sparkle effect.
/// Shows the user's gem balance with a glowing diamond icon.
class GemCounter extends ConsumerStatefulWidget {
  final bool compact;
  final bool showLabel;

  const GemCounter({
    super.key,
    this.compact = false,
    this.showLabel = true,
  });

  @override
  ConsumerState<GemCounter> createState() => _GemCounterState();
}

class _GemCounterState extends ConsumerState<GemCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleCtrl;
  late Animation<double> _sparkleAnim;
  int _prevBalance = -1;

  @override
  void initState() {
    super.initState();
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _sparkleAnim = CurvedAnimation(
      parent: _sparkleCtrl,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _sparkleCtrl.dispose();
    super.dispose();
  }

  void _onBalanceChanged(int newBalance) {
    if (_prevBalance >= 0 && newBalance > _prevBalance) {
      _sparkleCtrl.forward(from: 0.0);
    }
    _prevBalance = newBalance;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gemProvider, (prev, next) {
      _onBalanceChanged(next.balance);
    });
    final balance = ref.watch(gemProvider).balance;

    if (_prevBalance < 0) {
      _prevBalance = balance;
    }

    if (widget.compact) {
      return _CompactGemBadge(balance: balance);
    }

    return Semantics(
      label: 'Gemas: $balance',
      container: true,
      child: AnimatedBuilder(
        animation: _sparkleAnim,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PremiumColors.accentCyan.withValues(alpha: 0.15),
                  PremiumColors.deepPurple.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                color: PremiumColors.accentCyan.withValues(alpha: 0.3 + _sparkleAnim.value * 0.3),
                width: 1.0,
              ),
              boxShadow: [
                if (_sparkleAnim.value > 0)
                  BoxShadow(
                    color: PremiumColors.accentCyan.withValues(alpha: 0.4 * _sparkleAnim.value),
                    blurRadius: 16 * _sparkleAnim.value,
                    spreadRadius: 3 * _sparkleAnim.value,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.0 + _sparkleAnim.value * 0.2,
                  child: _GemIcon(sparkle: _sparkleAnim.value),
                ),
                if (widget.showLabel) ...[
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: AppTextStyle.bodyBold.copyWith(
                      color: PremiumColors.accentCyan,
                      fontSize: widget.compact ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                    child: Text('$balance'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GemIcon extends StatelessWidget {
  final double sparkle;
  const _GemIcon({this.sparkle = 0.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glow effect
          if (sparkle > 0)
            Container(
              width: 28 + sparkle * 12,
              height: 28 + sparkle * 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    PremiumColors.accentCyan.withValues(alpha: 0.5 * sparkle),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          // Diamond shape
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [PremiumColors.accentCyan, PremiumColors.deepPurple, PremiumColors.accentCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.accentCyan.withValues(alpha: 0.6),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
          // Inner highlight
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.7),
                    Colors.white.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Sparkle particles
          if (sparkle > 0.3) ...[
            _SparkleParticle(angle: 0, distance: 14, size: 3, opacity: sparkle),
            _SparkleParticle(angle: pi / 2, distance: 12, size: 2, opacity: sparkle * 0.8),
            _SparkleParticle(angle: pi, distance: 14, size: 3, opacity: sparkle * 0.6),
            _SparkleParticle(angle: 3 * pi / 2, distance: 12, size: 2, opacity: sparkle * 0.9),
          ],
        ],
      ),
    );
  }
}

class _SparkleParticle extends StatelessWidget {
  final double angle;
  final double distance;
  final double size;
  final double opacity;
  const _SparkleParticle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 14 + cos(angle) * distance - size / 2,
      top: 14 + sin(angle) * distance - size / 2,
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: PremiumColors.accentCyan,
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactGemBadge extends StatelessWidget {
  final int balance;
  const _CompactGemBadge({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Gemas: $balance',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: PremiumColors.accentCyan.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [PremiumColors.accentCyan, PremiumColors.deepPurple],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$balance',
              style: AppTextStyle.label.copyWith(
                color: PremiumColors.accentCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
