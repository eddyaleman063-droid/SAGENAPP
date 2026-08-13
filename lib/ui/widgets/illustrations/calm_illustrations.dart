import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

class CalmShieldPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;

  CalmShieldPainter({this.progress = 1.0, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.08 * progress);

    final path = Path();
    final cx = size.width / 2;
    final cy = size.height * 0.55;

    path.moveTo(cx, cy - size.height * 0.35 * progress);
    path.lineTo(
      cx + size.width * 0.3 * progress,
      cy - size.height * 0.1 * progress,
    );
    path.lineTo(
      cx + size.width * 0.25 * progress,
      cy + size.height * 0.25 * progress,
    );
    path.lineTo(cx, cy + size.height * 0.35 * progress);
    path.lineTo(
      cx - size.width * 0.25 * progress,
      cy + size.height * 0.25 * progress,
    );
    path.lineTo(
      cx - size.width * 0.3 * progress,
      cy - size.height * 0.1 * progress,
    );
    path.close();

    canvas.drawPath(path, paint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = primaryColor.withValues(alpha: 0.25 * progress);

    final innerPath = Path();
    final scale = 0.7 * progress;
    innerPath.moveTo(cx, cy - size.height * 0.35 * scale);
    innerPath.lineTo(
      cx + size.width * 0.3 * scale,
      cy - size.height * 0.1 * scale,
    );
    innerPath.lineTo(
      cx + size.width * 0.25 * scale,
      cy + size.height * 0.25 * scale,
    );
    innerPath.lineTo(cx, cy + size.height * 0.35 * scale);
    innerPath.lineTo(
      cx - size.width * 0.25 * scale,
      cy + size.height * 0.25 * scale,
    );
    innerPath.lineTo(
      cx - size.width * 0.3 * scale,
      cy - size.height * 0.1 * scale,
    );
    innerPath.close();
    canvas.drawPath(innerPath, innerPaint);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor.withValues(alpha: 0.15 * progress);

    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.08 * progress),
      4 * progress,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(CalmShieldPainter old) =>
      old.progress != progress || old.primaryColor != primaryColor;
}

class CalmShield extends StatelessWidget {
  final double size;
  final double progress;
  final Color? color;

  const CalmShield({
    super.key,
    this.size = 120,
    this.progress = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CalmShieldPainter(
          progress: progress,
          primaryColor: color ?? PremiumColors.primary,
        ),
      ),
    );
  }
}

class LearningBloomPainter extends CustomPainter {
  final double progress;
  final Color color;

  LearningBloomPainter({this.progress = 1.0, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.6;

    final stemPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.3 * progress);

    final stemPath = Path();
    stemPath.moveTo(cx, cy);
    stemPath.quadraticBezierTo(
      cx + 8 * progress,
      cy - size.height * 0.2 * progress,
      cx,
      cy - size.height * 0.35 * progress,
    );
    canvas.drawPath(stemPath, stemPaint);

    for (int i = 0; i < 5; i++) {
      final angle = (i / 5) * math.pi * 2 - math.pi / 2;
      final px = cx + math.cos(angle) * 18 * progress;
      final py =
          cy - size.height * 0.35 * progress + math.sin(angle) * 18 * progress;
      final petalPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = HSLColor.fromColor(color)
            .withLightness(0.55 + (i % 3) * 0.08)
            .toColor()
            .withValues(alpha: 0.2 * progress);
      canvas.drawCircle(Offset(px, py), 10 * progress, petalPaint);
    }

    final centerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.3 * progress);
    canvas.drawCircle(
      Offset(cx, cy - size.height * 0.35 * progress),
      6 * progress,
      centerPaint,
    );

    final leafPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.15 * progress);

    final leafPath = Path();
    leafPath.moveTo(cx - 4, cy - size.height * 0.12 * progress);
    leafPath.quadraticBezierTo(
      cx - 16 * progress,
      cy - size.height * 0.08 * progress,
      cx - 2,
      cy,
    );
    leafPath.close();
    canvas.drawPath(leafPath, leafPaint);
  }

  @override
  bool shouldRepaint(LearningBloomPainter old) =>
      old.progress != progress || old.color != color;
}

class LearningBloom extends StatelessWidget {
  final double size;
  final double progress;
  final Color? color;

  const LearningBloom({
    super.key,
    this.size = 120,
    this.progress = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: LearningBloomPainter(
          progress: progress,
          color: color ?? PremiumColors.primary,
        ),
      ),
    );
  }
}

class ProtectionNestPainter extends CustomPainter {
  final double progress;
  final Color color;

  ProtectionNestPainter({this.progress = 1.0, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 3; i++) {
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 - i * 0.5
        ..color = color.withValues(alpha: (0.12 - i * 0.03) * progress);
      canvas.drawCircle(Offset(cx, cy), (22 + i * 14) * progress, ringPaint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * math.pi * 2;
      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: (0.1 + (i % 3) * 0.05) * progress);
      canvas.drawCircle(
        Offset(
          cx + math.cos(angle) * 28 * progress,
          cy + math.sin(angle) * 28 * progress,
        ),
        3 * progress,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProtectionNestPainter old) =>
      old.progress != progress || old.color != color;
}

class ProtectionNest extends StatelessWidget {
  final double size;
  final double progress;
  final Color? color;

  const ProtectionNest({
    super.key,
    this.size = 120,
    this.progress = 1.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: ProtectionNestPainter(
          progress: progress,
          color: color ?? PremiumColors.primary,
        ),
      ),
    );
  }
}

class SageGlowPainter extends CustomPainter {
  final double progress;
  final Color color;

  SageGlowPainter({this.progress = 1.0, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (int i = 0; i < 4; i++) {
      final alpha = ((0.08 - i * 0.015) * progress).clamp(0.0, 1.0);
      final glowPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(cx, cy), (20 + i * 10) * progress, glowPaint);
    }

    const dotCount = 6;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * math.pi * 2 + progress * 0.5;
      final dist = 32 * progress;
      final dotPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: (0.12 + (i % 3) * 0.04) * progress);
      canvas.drawCircle(
        Offset(cx + math.cos(angle) * dist, cy + math.sin(angle) * dist),
        2.5 * progress,
        dotPaint,
      );
    }

    final facePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.3 * progress);

    final smilePath = Path();
    smilePath.moveTo(cx - 5, cy + 2);
    smilePath.quadraticBezierTo(cx, cy + 6, cx + 5, cy + 2);
    canvas.drawPath(smilePath, facePaint);

    canvas.drawCircle(
      Offset(cx - 4, cy - 3),
      1.5,
      facePaint..color = Colors.white.withValues(alpha: 0.25 * progress),
    );
    canvas.drawCircle(Offset(cx + 4, cy - 3), 1.5, facePaint);
  }

  @override
  bool shouldRepaint(SageGlowPainter old) =>
      old.progress != progress || old.color != color;
}

class SageGlow extends StatelessWidget {
  final double size;
  final double progress;
  final Color? color;

  const SageGlow({super.key, this.size = 120, this.progress = 1.0, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: SageGlowPainter(
          progress: progress,
          color: color ?? PremiumColors.primary,
        ),
      ),
    );
  }
}
