import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/theme_constants.dart';

/// Spectacular floating "+N gems" animation with particle burst.
class GemRewardAnimation extends StatefulWidget {
  final int amount;
  final VoidCallback? onComplete;

  const GemRewardAnimation({super.key, required this.amount, this.onComplete});

  static void show(BuildContext context, int amount) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) =>
          GemRewardAnimation(amount: amount, onComplete: () => entry.remove()),
    );
    overlay.insert(entry);
  }

  @override
  State<GemRewardAnimation> createState() => _GemRewardAnimationState();
}

class _GemRewardAnimationState extends State<GemRewardAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    final rng = Random();
    _particles = List.generate(12, (_) {
      final angle = rng.nextDouble() * 2 * pi;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      return _Particle(
        angle: angle,
        speed: speed,
        size: 4 + rng.nextDouble() * 6,
        color: [
          PremiumColors.accentCyan,
          PremiumColors.deepPurple,
          PremiumColors.accentYellow,
          PremiumColors.premiumIce,
        ][rng.nextInt(4)],
      );
    });

    _ctrl.forward().then((_) => widget.onComplete?.call());
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final fadeOut = t > 0.6
              ? 1.0 - ((t - 0.6) / 0.4).clamp(0.0, 1.0)
              : 1.0;
          final scale = t < 0.15
              ? (t / 0.15) * 0.5 + 0.5
              : (t < 0.3
                    ? 1.0 + (t - 0.15) / 0.15 * 0.2
                    : 1.2 - (t - 0.3) * 0.5);
          final slideY = t < 0.3 ? 0 : -(t - 0.3) * 120;

          return Positioned(
            top: MediaQuery.sizeOf(context).height * 0.35 + slideY,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: fadeOut,
              child: Transform.scale(
                scale: scale.clamp(0.3, 1.5),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Particle burst
                    for (int i = 0; i < _particles.length; i++)
                      _ParticleWidget(particle: _particles[i], progress: t),
                    // Main badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            PremiumColors.accentCyan,
                            PremiumColors.deepPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: PremiumColors.accentCyan.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                          BoxShadow(
                            color: PremiumColors.deepPurple.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 32,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.rotate(
                            angle: 0.785 + t * 0.5,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.white,
                                    PremiumColors.surfaceTintLight,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '+${widget.amount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              shadows: [
                                Shadow(color: Colors.black26, blurRadius: 6),
                                Shadow(
                                  color: PremiumColors.accentCyan,
                                  blurRadius: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;
  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}

class _ParticleWidget extends StatelessWidget {
  final _Particle particle;
  final double progress;
  const _ParticleWidget({required this.particle, required this.progress});

  @override
  Widget build(BuildContext context) {
    final t = progress.clamp(0.0, 0.8) / 0.8;
    final dx = cos(particle.angle) * particle.speed * t * 80;
    final dy = sin(particle.angle) * particle.speed * t * 80;
    final opacity = (1.0 - t).clamp(0.0, 1.0);
    final scale = (1.0 - t * 0.5).clamp(0.2, 1.0);

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: particle.size,
            height: particle.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [particle.color, particle.color.withValues(alpha: 0.3)],
              ),
              boxShadow: [
                BoxShadow(
                  color: particle.color.withValues(alpha: 0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
