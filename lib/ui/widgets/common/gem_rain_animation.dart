import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

/// Spectacular gem rain animation for chest rewards.
/// Gems fall from the top and accumulate in a pile at the bottom.
class GemRainAnimation extends StatefulWidget {
  final int gemCount;
  final VoidCallback? onComplete;

  const GemRainAnimation({super.key, required this.gemCount, this.onComplete});

  static Future<void> show(BuildContext context, {required int gemCount}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: AppLocalizations.of(context)?.gemRainAnimationLabel ?? '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a, b) => GemRainAnimation(gemCount: gemCount),
    );
  }

  @override
  State<GemRainAnimation> createState() => _GemRainAnimationState();
}

class _GemRainAnimationState extends State<GemRainAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rainCtrl;
  late AnimationController _pileCtrl;
  late AnimationController _glowCtrl;
  late List<_FallingGem> _gems;
  int _landedCount = 0;
  bool _showTotal = false;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    final count = widget.gemCount.clamp(5, 50);

    _gems = List.generate(count, (i) {
      return _FallingGem(
        x: 0.1 + _rng.nextDouble() * 0.8,
        delay: _rng.nextDouble() * 0.6,
        speed: 0.7 + _rng.nextDouble() * 0.6,
        size: 14.0 + _rng.nextDouble() * 10.0,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 4,
        hue: _rng.nextDouble() * 40 - 20,
      );
    });

    _rainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _pileCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _rainCtrl.addListener(() {
      final landed = _gems.where((g) => g.hasLanded(_rainCtrl.value)).length;
      if (landed != _landedCount) {
        HapticFeedback.lightImpact();
        setState(() => _landedCount = landed);
      }
    });

    _rainCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pileCtrl.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            HapticFeedback.heavyImpact();
            setState(() => _showTotal = true);
            _glowCtrl.forward();
          }
        });
        Future.delayed(const Duration(milliseconds: 2800), () {
          if (mounted) {
            Navigator.of(context).pop();
            widget.onComplete?.call();
          }
        });
      }
    });

    _rainCtrl.forward();
  }

  @override
  void dispose() {
    _rainCtrl.dispose();
    _pileCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Stack(
        children: [
          // Falling gems
          AnimatedBuilder(
            animation: _rainCtrl,
            builder: (ctx, _) => RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _GemRainPainter(
                  gems: _gems,
                  progress: _rainCtrl.value,
                ),
              ),
            ),
          ),
          // Pile at bottom
          AnimatedBuilder(
            animation: _pileCtrl,
            builder: (ctx, _) => Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120 * _pileCtrl.value,
              child: _GemPile(count: _landedCount, progress: _pileCtrl.value),
            ),
          ),
          // Total counter
          if (_showTotal)
            Center(
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (ctx, child) {
                  return Transform.scale(
                    scale: 0.5 + _glowCtrl.value * 0.5,
                    child: Opacity(
                      opacity: _glowCtrl.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxxl,
                          vertical: AppSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              PremiumColors.accentCyan,
                              PremiumColors.deepPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.round),
                          boxShadow: [
                            BoxShadow(
                              color: PremiumColors.accentCyan.withValues(
                                alpha: 0.6,
                              ),
                              blurRadius: 40,
                              spreadRadius: 8,
                            ),
                            BoxShadow(
                              color: PremiumColors.deepPurple.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 60,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.rotate(
                              angle: 0.785,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.white,
                                      PremiumColors.surfaceTintLight,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: PremiumColors.accentCyan,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Semantics(
                              label: AppLocalizations.of(
                                context,
                              )!.rewardAdEarnedGems(widget.gemCount),
                              child: Text(
                                '+${widget.gemCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: PremiumColors.accentCyan,
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FallingGem {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final double hue;

  _FallingGem({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.hue,
  });

  bool hasLanded(double progress) {
    final t = (progress - delay).clamp(0.0, 1.0) / speed;
    return t >= 1.0;
  }

  double getY(double progress) {
    final t = ((progress - delay) / speed).clamp(0.0, 1.0);
    // Ease-in curve for natural fall
    return t * t * 0.75;
  }

  double getRotation(double progress) {
    final t = ((progress - delay) / speed).clamp(0.0, 1.0);
    return rotation + rotationSpeed * t;
  }

  double getOpacity(double progress) {
    final t = ((progress - delay) / speed).clamp(0.0, 1.0);
    if (t <= 0) return 0;
    if (t >= 0.9) return (1.0 - (t - 0.9) / 0.1).clamp(0.0, 1.0);
    return 1.0;
  }
}

class _GemRainPainter extends CustomPainter {
  final List<_FallingGem> gems;
  final double progress;

  _GemRainPainter({required this.gems, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..isAntiAlias = true;

    for (final gem in gems) {
      final opacity = gem.getOpacity(progress);
      if (opacity <= 0) continue;

      final y = gem.getY(progress) * size.height;
      final x = gem.x * size.width;
      final rot = gem.getRotation(progress);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);

      // Glow
      paint.color = PremiumColors.accentCyan.withValues(alpha: 0.3 * opacity);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: gem.size * 1.8,
          height: gem.size * 1.8,
        ),
        paint,
      );

      // Diamond body
      final gradient = LinearGradient(
        colors: [
          Color.fromARGB(
            255,
            (0 + gem.hue).round().clamp(0, 255),
            (229 + gem.hue * 0.5).round().clamp(0, 255),
            255,
          ),
          PremiumColors.deepPurple,
          Color.fromARGB(
            255,
            (0 + gem.hue).round().clamp(0, 255),
            (229 + gem.hue * 0.5).round().clamp(0, 255),
            255,
          ),
        ],
      );

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: gem.size, height: gem.size),
        const Radius.circular(2),
      );

      paint.shader = gradient.createShader(rect.outerRect);
      canvas.drawRRect(rect, paint);

      // Inner highlight
      paint.shader = null;
      paint.color = Colors.white.withValues(alpha: 0.6 * opacity);
      final highlight = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-gem.size * 0.1, -gem.size * 0.1),
          width: gem.size * 0.4,
          height: gem.size * 0.4,
        ),
        const Radius.circular(1),
      );
      canvas.drawRRect(highlight, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GemRainPainter old) => old.progress != progress;
}

class _GemPile extends StatelessWidget {
  final int count;
  final double progress;
  const _GemPile({required this.count, required this.progress});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _GemPilePainter(count: count, progress: progress),
    );
  }
}

class _GemPilePainter extends CustomPainter {
  final int count;
  final double progress;
  static final _paint = Paint()..isAntiAlias = true;
  static final _rng = Random(42);

  _GemPilePainter({required this.count, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final visibleCount = (count * progress).round();
    final pileWidth = size.width * 0.6;
    final startX = (size.width - pileWidth) / 2;

    for (int i = 0; i < visibleCount; i++) {
      final x = startX + _rng.nextDouble() * pileWidth;
      final row = i ~/ 8;
      final y = size.height - 20 - row * 12.0 - _rng.nextDouble() * 8;
      final gemSize = 12.0 + _rng.nextDouble() * 6.0;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(_rng.nextDouble() * 0.4 - 0.2);

      // Glow
      _paint.color = PremiumColors.accentCyan.withValues(alpha: 0.15);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: gemSize * 2,
          height: gemSize * 2,
        ),
        _paint,
      );

      // Diamond
      const gradient = LinearGradient(
        colors: [
          PremiumColors.accentCyan,
          PremiumColors.deepPurple,
          PremiumColors.accentCyan,
        ],
      );
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: gemSize, height: gemSize),
        const Radius.circular(2),
      );
      _paint.shader = gradient.createShader(rect.outerRect);
      canvas.drawRRect(rect, _paint);

      // Highlight
      _paint.shader = null;
      _paint.color = Colors.white.withValues(alpha: 0.5);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(-gemSize * 0.15, -gemSize * 0.15),
          width: gemSize * 0.3,
          height: gemSize * 0.3,
        ),
        _paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GemPilePainter old) =>
      old.progress != progress || old.count != count;
}
