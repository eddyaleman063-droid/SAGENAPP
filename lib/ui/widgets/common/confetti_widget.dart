import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';

enum ConfettiType {
  level,
  streak,
  chest,
  achievement,
}

class ConfettiWidget extends StatefulWidget {
  final Duration duration;
  final int particleCount;
  final List<Color> colors;
  final ConfettiType? type;

  const ConfettiWidget({
    super.key,
    this.duration = const Duration(milliseconds: 2500),
    this.particleCount = 50,
    this.colors = const [],
    this.type,
  });

  static List<Color> get _levelColors => PremiumColors.confettiFresh;

  static List<Color> get _streakColors => PremiumColors.confettiWarm;

  static List<Color> get _chestColors => PremiumColors.confettiExtra;

  static List<Color> get _achievementColors => PremiumColors.confettiSoft;

  static List<Color> get _defaultColors => PremiumColors.confettiMixed;

  List<Color> get _effectiveColors {
    if (colors.isNotEmpty) return colors;
    switch (type) {
      case ConfettiType.level:
        return _levelColors;
      case ConfettiType.streak:
        return _streakColors;
      case ConfettiType.chest:
        return _chestColors;
      case ConfettiType.achievement:
        return _achievementColors;
      case null:
        return _defaultColors;
    }
  }

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    final rng = Random();
    final palette = widget._effectiveColors;
    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: rng.nextDouble(),
        startY: -0.1 - rng.nextDouble() * 0.2,
        speedY: 0.4 + rng.nextDouble() * 0.6,
        speedX: (rng.nextDouble() - 0.5) * 0.3,
        rotation: rng.nextDouble() * 2 * pi,
        rotationSpeed: (rng.nextDouble() - 0.5) * 8,
        size: 4 + rng.nextDouble() * 6,
        color: palette[rng.nextInt(palette.length)],
        shape: rng.nextBool() ? _Shape.rect : _Shape.circle,
        wobbleAmp: 0.02 + rng.nextDouble() * 0.04,
        wobbleFreq: 2 + rng.nextDouble() * 3,
      );
    });
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ConfettiPainter(particles: _particles, progress: _ctrl.value),
            );
          },
        ),
      ),
    );
  }
}

enum _Shape { rect, circle }

class _Particle {
  final double x;
  final double startY;
  final double speedY;
  final double speedX;
  double rotation;
  final double rotationSpeed;
  final double size;
  final Color color;
  final _Shape shape;
  final double wobbleAmp;
  final double wobbleFreq;

  _Particle({
    required this.x,
    required this.startY,
    required this.speedY,
    required this.speedX,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.shape,
    required this.wobbleAmp,
    required this.wobbleFreq,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  static final _paint = Paint();

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = progress;
      final y = (p.startY + p.speedY * t) * size.height;
      final wobble = sin(t * p.wobbleFreq * pi * 2) * p.wobbleAmp * size.width;
      final x = (p.x * size.width) + p.speedX * t * size.width + wobble;
      final alpha = t < 0.7 ? 1.0 : (1.0 - (t - 0.7) / 0.3).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.rotation + p.rotationSpeed * t);

      _paint.color = p.color.withValues(alpha: alpha);

      if (p.shape == _Shape.rect) {
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size * 0.6,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(1)),
          _paint,
        );
      } else {
        canvas.drawCircle(Offset.zero, p.size / 2, _paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
