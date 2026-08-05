import 'dart:math' as math;
import 'package:flutter/material.dart';

enum SagenMood {
  neutral,
  happy,
  sad,
  surprised,
  angry,
}

class SagenLogo extends StatefulWidget {
  final double size;
  final SagenMood mood;
  final bool animated;
  final double neonPulseSpeed;

  const SagenLogo({
    super.key,
    this.size = 120,
    this.mood = SagenMood.neutral,
    this.animated = true,
    this.neonPulseSpeed = 1.0,
  });

  @override
  State<SagenLogo> createState() => _SagenLogoState();
}

class _SagenLogoState extends State<SagenLogo> with SingleTickerProviderStateMixin {
  AnimationController? _pulseCtrl;

  @override
  void initState() {
    super.initState();
    if (widget.animated) {
      final speed = widget.neonPulseSpeed.clamp(0.1, 10.0);
      _pulseCtrl = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (3000 / speed).round()),
      )..repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(SagenLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animated != oldWidget.animated) {
      _pulseCtrl?.dispose();
      if (widget.animated) {
        final speed = widget.neonPulseSpeed.clamp(0.1, 10.0);
        _pulseCtrl = AnimationController(
          vsync: this,
          duration: Duration(milliseconds: (3000 / speed).round()),
        )..repeat(reverse: true);
      } else {
        _pulseCtrl = null;
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _pulseCtrl ?? Listenable.merge([]),
          builder: (context, _) {
            final pulseVal = _pulseCtrl?.value ?? 0.5;
            final neonIntensity = 0.7 + pulseVal * 0.3;
            return CustomPaint(
              painter: _SagenLogoPainter(
                mood: widget.mood,
                neonIntensity: neonIntensity,
              ),
              size: Size(widget.size, widget.size),
            );
          },
        ),
      ),
    );
  }
}

class _SagenLogoPainter extends CustomPainter {
  final SagenMood mood;
  final double neonIntensity;

  const _SagenLogoPainter({
    required this.mood,
    this.neonIntensity = 1.0,
  });

  static const _bgCenter = Color(0xFF7FFFD4);
  static const _bgEdge = Color(0xFF00E5EE);
  static const _maskBase = Color(0xFF1E3A5F);
  static const _neon = Color(0xFF00FFFF);
  static const _iris = Color(0xFF00CED1);
  static const _pupil = Color(0xFF000000);
  static const _highlight = Color(0xFFFFFFFF);
  static final _squirclePaint = Paint()
    ..shader = const RadialGradient(
      center: Alignment(0, 0),
      radius: 1.0,
      colors: [_bgCenter, _bgEdge],
      stops: [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));
  static final _maskPaint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _maskBase.withValues(alpha: 0.92),
        _maskBase,
        _maskBase.withValues(alpha: 0.85),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(const Rect.fromLTWH(0, 0, 1, 1));
  static final _pupilPaint = Paint()..color = _pupil;
  static final _lidPaint = Paint()..color = _maskBase;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);

    _drawSquircle(canvas, c, r);
    final maskPath = _buildMaskPath(r);
    _drawMask(canvas, maskPath, r);
    _drawNeonGlow(canvas, maskPath, r);

    final eyeR = r * 0.09;
    final leftEye = Offset(c.dx - r * 0.19, c.dy - r * 0.08);
    final rightEye = Offset(c.dx + r * 0.19, c.dy - r * 0.08);
    _drawEye(canvas, leftEye, eyeR);
    _drawEye(canvas, rightEye, eyeR);
    _drawEyelids(canvas, leftEye, rightEye, eyeR, r);
    _drawMouth(canvas, c, r);
  }

  void _drawSquircle(Canvas canvas, Offset c, double r) {
    final path = Path();
    const n = 4.0;
    const steps = 80;
    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * math.pi;
      final cosT = math.cos(t).abs();
      final sinT = math.sin(t).abs();
      final rr = r / math.pow(math.pow(cosT, n) + math.pow(sinT, n), 1 / n);
      final x = c.dx + rr * math.cos(t);
      final y = c.dy + rr * math.sin(t);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    _squirclePaint.shader = const RadialGradient(
      center: Alignment(0, 0),
      radius: 1.0,
      colors: [_bgCenter, _bgEdge],
      stops: [0.0, 1.0],
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawPath(path, _squirclePaint);
  }

  Path _buildMaskPath(double r) {
    final path = Path();
    path.moveTo(r * 0.50, r * 0.12);
    path.cubicTo(r * 0.40, r * 0.06, r * 0.20, r * 0.04, r * 0.18, r * 0.10);
    path.cubicTo(r * 0.14, r * 0.20, r * 0.10, r * 0.40, r * 0.18, r * 0.62);
    path.cubicTo(r * 0.24, r * 0.76, r * 0.38, r * 0.86, r * 0.50, r * 0.86);
    path.cubicTo(r * 0.62, r * 0.86, r * 0.76, r * 0.76, r * 0.82, r * 0.62);
    path.cubicTo(r * 0.90, r * 0.40, r * 0.86, r * 0.20, r * 0.82, r * 0.10);
    path.cubicTo(r * 0.80, r * 0.04, r * 0.60, r * 0.06, r * 0.50, r * 0.12);
    path.close();
    return path;
  }

  void _drawMask(Canvas canvas, Path maskPath, double r) {
    _maskPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _maskBase.withValues(alpha: 0.92),
        _maskBase,
        _maskBase.withValues(alpha: 0.85),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(0, 0, r * 2, r * 2));
    canvas.drawPath(maskPath, _maskPaint);
  }

  void _drawNeonGlow(Canvas canvas, Path maskPath, double r) {
    final pw = r * 0.025;

    for (int i = 3; i >= 0; i--) {
      canvas.drawPath(
        maskPath,
        Paint()
          ..color = _neon.withValues(alpha: (0.15 * neonIntensity - i * 0.035).clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = pw * (2 + i * 1.5)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, pw * (1 + i * 0.8)),
      );
    }

    canvas.drawPath(
      maskPath,
      Paint()
        ..color = Color.lerp(_neon, Colors.white, 0.15)!
        ..style = PaintingStyle.stroke
        ..strokeWidth = pw * 1.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawPath(
      maskPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45 * neonIntensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = pw * 0.4
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawEye(Canvas canvas, Offset center, double eyeR) {
    final irisGradient = RadialGradient(
      center: const Alignment(-0.2, -0.3),
      radius: 1.0,
      colors: [
        _iris.withValues(alpha: 0.9),
        _iris,
        _iris.withValues(alpha: 0.7),
      ],
    );
    canvas.drawCircle(
      center,
      eyeR,
      Paint()
        ..shader = irisGradient.createShader(
          Rect.fromCenter(center: center, width: eyeR * 2, height: eyeR * 2),
        ),
    );

    final textR = eyeR * 0.95;
    final pupilR = eyeR * 0.35;
    final seed = (center.dx * 31 + center.dy * 37).toInt();

    final irisLinePaint = Paint()..strokeWidth = 0.6;
    for (int i = 0; i < 72; i++) {
      final angle = (i / 72) * 2 * math.pi;
      final noise = ((seed * (i + 1) * 7) % 100) / 100;
      final noise2 = ((seed * (i + 1) * 13) % 100) / 100;
      final endDist = textR * (0.65 + noise * 0.35);
      irisLinePaint
        ..color = Colors.white.withValues(alpha: 0.10 + noise2 * 0.20)
        ..strokeWidth = 0.4 + noise * 0.8;
      canvas.drawLine(
        Offset(center.dx + (pupilR + eyeR * 0.05) * math.cos(angle),
            center.dy + (pupilR + eyeR * 0.05) * math.sin(angle)),
        Offset(center.dx + endDist * math.cos(angle),
            center.dy + endDist * math.sin(angle)),
        irisLinePaint,
      );
    }

    canvas.drawCircle(center, pupilR, _pupilPaint);

    canvas.drawCircle(
      center,
      pupilR * 1.6,
      Paint()
        ..color = _iris.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    final ref1 = Offset(center.dx - eyeR * 0.30, center.dy - eyeR * 0.30);
    canvas.drawOval(
      Rect.fromCenter(center: ref1, width: eyeR * 0.55, height: eyeR * 0.45),
      Paint()
        ..color = _highlight.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5),
    );

    final ref2 = Offset(center.dx + eyeR * 0.25, center.dy + eyeR * 0.25);
    canvas.drawOval(
      Rect.fromCenter(center: ref2, width: eyeR * 0.25, height: eyeR * 0.20),
      Paint()
        ..color = _highlight.withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1),
    );

    canvas.drawCircle(
      center,
      eyeR * 1.15,
      Paint()
        ..color = _iris.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _drawEyelids(Canvas canvas, Offset leftEye, Offset rightEye, double eyeR, double r) {
    switch (mood) {
      case SagenMood.happy:
        _drawLid(canvas, leftEye, eyeR, -eyeR * 0.35);
        _drawLid(canvas, rightEye, eyeR, -eyeR * 0.35);
        _drawBlush(canvas, leftEye, rightEye, r);
      case SagenMood.sad:
        _drawLid(canvas, leftEye, eyeR, -eyeR * 0.10);
        _drawLid(canvas, rightEye, eyeR, -eyeR * 0.10);
      case SagenMood.angry:
        _drawLid(canvas, leftEye, eyeR, -eyeR * 0.55);
        _drawLid(canvas, rightEye, eyeR, -eyeR * 0.55);
        _drawAngryBrow(canvas, leftEye, rightEye, r);
      case SagenMood.surprised:
        final bg = Paint()
          ..color = _neon.withValues(alpha: 0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(leftEye, eyeR * 1.4, bg);
        canvas.drawCircle(rightEye, eyeR * 1.4, bg);
      case SagenMood.neutral:
        _drawLid(canvas, leftEye, eyeR, -eyeR * 0.22);
        _drawLid(canvas, rightEye, eyeR, -eyeR * 0.22);
    }
  }

  void _drawLid(Canvas canvas, Offset ec, double eyeR, double topY) {
    final path = Path()
      ..moveTo(ec.dx - eyeR * 1.6, ec.dy + eyeR * 0.1)
      ..quadraticBezierTo(ec.dx - eyeR * 0.5, ec.dy + topY, ec.dx, ec.dy + topY)
      ..quadraticBezierTo(ec.dx + eyeR * 0.5, ec.dy + topY, ec.dx + eyeR * 1.6, ec.dy + eyeR * 0.1)
      ..lineTo(ec.dx + eyeR * 1.6, ec.dy - eyeR * 1.5)
      ..lineTo(ec.dx - eyeR * 1.6, ec.dy - eyeR * 1.5)
      ..close();
    canvas.drawPath(path, _lidPaint);
  }

  void _drawBlush(Canvas canvas, Offset leftEye, Offset rightEye, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFF6D00).withValues(alpha: 0.12)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.05);
    canvas.drawCircle(Offset(leftEye.dx, leftEye.dy + r * 0.14), r * 0.08, paint);
    canvas.drawCircle(Offset(rightEye.dx, rightEye.dy + r * 0.14), r * 0.08, paint);
  }

  void _drawAngryBrow(Canvas canvas, Offset leftEye, Offset rightEye, double r) {
    final p = Paint()
      ..color = _maskBase
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.025
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(leftEye.dx - r * 0.10, leftEye.dy - r * 0.14),
      Offset(leftEye.dx + r * 0.10, leftEye.dy - r * 0.28), p);
    canvas.drawLine(
      Offset(rightEye.dx + r * 0.10, rightEye.dy - r * 0.14),
      Offset(rightEye.dx - r * 0.10, rightEye.dy - r * 0.28), p);
  }

  void _drawMouth(Canvas canvas, Offset c, double r) {
    final mY = c.dy + r * 0.24;
    final mW = r * 0.28;
    final path = Path();

    switch (mood) {
      case SagenMood.happy:
        path.moveTo(c.dx - mW, mY - r * 0.02);
        path.cubicTo(c.dx - mW * 0.6, mY + r * 0.10, c.dx + mW * 0.6, mY + r * 0.10, c.dx + mW, mY - r * 0.02);
      case SagenMood.sad:
        path.moveTo(c.dx - mW, mY + r * 0.02);
        path.cubicTo(c.dx - mW * 0.6, mY - r * 0.06, c.dx + mW * 0.6, mY - r * 0.06, c.dx + mW, mY + r * 0.02);
      case SagenMood.surprised:
        canvas.drawOval(
          Rect.fromCenter(center: Offset(c.dx, mY + r * 0.04), width: mW * 0.7, height: mW * 0.8),
          Paint()..color = _pupil);
        canvas.drawOval(
          Rect.fromCenter(center: Offset(c.dx - mW * 0.05, mY + r * 0.02),
              width: mW * 0.15, height: mW * 0.25),
          Paint()
            ..color = _highlight.withValues(alpha: 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1));
        return;
      case SagenMood.angry:
        path.moveTo(c.dx - mW * 0.7, mY);
        path.lineTo(c.dx + mW * 0.7, mY);
      case SagenMood.neutral:
        path.moveTo(c.dx - mW * 0.8, mY);
        path.cubicTo(c.dx - mW * 0.4, mY + r * 0.02, c.dx + mW * 0.4, mY + r * 0.02, c.dx + mW * 0.8, mY);
    }

    canvas.drawPath(path, Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.018
      ..strokeCap = StrokeCap.round);

    canvas.drawPath(path, Paint()
      ..color = _highlight.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.008
      ..strokeCap = StrokeCap.round);

    canvas.drawPath(path, Paint()
      ..color = _maskBase.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.012
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_SagenLogoPainter old) => old.mood != mood || old.neonIntensity != neonIntensity;
}
