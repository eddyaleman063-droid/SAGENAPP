import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class ParticleBurst extends StatefulWidget {
  final Color color;
  final int count;
  final double radius;
  final Duration duration;

  const ParticleBurst({
    super.key,
    this.color = PremiumColors.particleBurst,
    this.count = 12,
    this.radius = 60,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  State<ParticleBurst> createState() => _ParticleBurstState();
}

class _ParticleBurstState extends State<ParticleBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _particles = List.generate(widget.count, (i) {
      final angle = (math.pi * 2 / widget.count) * i;
      final speed = 0.5 + math.Random().nextDouble() * 0.5;
      return _Particle(angle: angle, speed: speed);
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final progress = _ctrl.value;
        final opacity = (1 - progress).clamp(0.0, 1.0);
        return RepaintBoundary(
          child: CustomPaint(
            size: Size(widget.radius * 2, widget.radius * 2),
            painter: _ParticlePainter(
              particles: _particles,
              progress: progress,
              color: widget.color.withValues(alpha: opacity),
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  const _Particle({required this.angle, required this.speed});
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2;
    for (final p in particles) {
      final dist = maxR * p.speed * progress;
      final x = center.dx + dist * math.cos(p.angle);
      final y = center.dy + dist * math.sin(p.angle);
      final r = 3.0 * (1 - progress) + 1.0;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.progress != progress;
}
