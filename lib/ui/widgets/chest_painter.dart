import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import '../../models/chest_type.dart';
import 'chest_config.dart';

const _anticipationEnd = 0.30;

class ChestPainter extends CustomPainter {
  final ChestType type;
  final double progress;
  final bool isOpen;
  final bool isAnimating;

  ChestPainter({
    required this.type,
    required this.progress,
    required this.isOpen,
    required this.isAnimating,
  }) : _cfg = _buildConfig(type);

  final ChestConfig _cfg;

  final Paint _p = Paint()..isAntiAlias = true;
  final Paint _strokeP = Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final t = isAnimating ? progress : (isOpen ? 1.0 : 0.0);

    final cL = s * 0.18;
    final cR = s * 0.82;
    final bT = _cfg.bodyTop * s;
    final bB = _cfg.bodyBottom * s;
    final lT = _cfg.lidTop * s;
    final bR = s * _cfg.bodyRadius;
    final cx = c.dx;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(cL, bT, cR, bB),
      Radius.circular(bR),
    );

    _drawGlow(canvas, s, c, t);
    _drawShadow(canvas, s, c);
    _drawBodyInterior(canvas, cL, cR, bT, bB, bR, t);
    _drawBody(canvas, bodyRect);
    _drawBodySheen(canvas, bodyRect);
    _drawBodyBorder(canvas, bodyRect);
    _drawBodyBands(canvas, s, cL, cR, cx, bT, bB);
    _drawLock(canvas, cx, bT, bB, cL, cR);
    _drawLidInterior(canvas, s, cL, cR, lT, bT, cx, t);
    _drawLid(canvas, s, cL, cR, lT, bT, cx, t);
    _drawOpeningGlow(canvas, s, cL, cR, bT, bB, bR, t);
    _drawShineSweep(canvas, cL, cR, bT, bB, s, t);
    _drawParticleBurst(canvas, s, c, t);
    _drawTierEffects(canvas, s, c, t, cL, cR, bT, bB);
    _drawOpenFlash(canvas, c, s, t);
  }

  static ChestConfig _buildConfig(ChestType t) {
    switch (t) {
      case ChestType.bronze:
        return const ChestConfig(
          bodyColor: PremiumColors.chestBronzeBody,
          accentColor: PremiumColors.chestBronzeAccent,
          glowColor: PremiumColors.chestBronzeGlow,
          lidTop: 0.18,
          bodyTop: 0.46,
          bodyBottom: 0.82,
          bodyRadius: 0.035,
          bandCount: 1,
          bandWidth: 2.5,
          hasArch: false,
          lockGem: false,
          lockSize: 0.055,
          particleColor: PremiumColors.chestBronzeBody,
        );
      case ChestType.silver:
        return const ChestConfig(
          bodyColor: PremiumColors.chestSilverBody,
          accentColor: PremiumColors.chestSilverAccent,
          glowColor: PremiumColors.chestSilverGlow,
          lidTop: 0.16,
          bodyTop: 0.44,
          bodyBottom: 0.82,
          bodyRadius: 0.040,
          bandCount: 2,
          bandWidth: 3.0,
          hasArch: true,
          lockGem: false,
          lockSize: 0.060,
          particleColor: PremiumColors.chestSilverParticle,
        );
      case ChestType.gold:
        return const ChestConfig(
          bodyColor: PremiumColors.chestGoldBody,
          accentColor: PremiumColors.chestGoldAccent,
          glowColor: PremiumColors.chestGoldGlow,
          lidTop: 0.14,
          bodyTop: 0.42,
          bodyBottom: 0.83,
          bodyRadius: 0.045,
          bandCount: 3,
          bandWidth: 3.5,
          hasArch: true,
          lockGem: true,
          lockSize: 0.065,
          particleColor: PremiumColors.chestGoldParticle,
        );
      case ChestType.legendary:
        return const ChestConfig(
          bodyColor: PremiumColors.chestLegendaryBody,
          accentColor: PremiumColors.deepPurple,
          glowColor: PremiumColors.chestLegendaryGlow2,
          lidTop: 0.12,
          bodyTop: 0.40,
          bodyBottom: 0.84,
          bodyRadius: 0.050,
          bandCount: 2,
          bandWidth: 3.0,
          hasArch: true,
          lockGem: true,
          lockSize: 0.070,
          particleColor: PremiumColors.chestLegendaryParticle,
        );
    }
  }

  void _drawGlow(Canvas canvas, double s, Offset c, double t) {
    final r = s * 0.40 * (1.0 + 0.08 * math.sin(t * math.pi * 6));
    final gp = t < _anticipationEnd ? t / _anticipationEnd : 1.0;
    final ga = (0.12 + 0.10 * gp).clamp(0.0, 1.0);
    _p.shader = RadialGradient(
      colors: [
        _cfg.glowColor.withValues(alpha: ga),
        _cfg.glowColor.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: c, radius: r));
    canvas.drawCircle(c, r, _p);
  }

  void _drawShadow(Canvas canvas, double s, Offset c) {
    final sy = s * 0.83;
    _p.shader = RadialGradient(
      colors: [
        Colors.black.withValues(alpha: 0.20),
        Colors.black.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(c.dx, sy), radius: s * 0.25));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, sy),
        width: s * 0.50,
        height: s * 0.10,
      ),
      _p,
    );
  }

  void _drawBodyInterior(
    Canvas canvas,
    double cL,
    double cR,
    double bT,
    double bB,
    double bR,
    double t,
  ) {
    final rt = _openProgress(t);
    if (rt <= 0) return;
    final a = (rt * 0.60).clamp(0.0, 1.0);
    _p.shader = null;
    _p.style = PaintingStyle.fill;
    _p.color = PremiumColors.chestDarkBg.withValues(alpha: a);
    final inner = RRect.fromRectAndRadius(
      Rect.fromLTRB(cL + 4, bT + 2, cR - 4, bB - 4),
      Radius.circular(bR * 0.5),
    );
    canvas.drawRRect(inner, _p);
  }

  void _drawBody(Canvas canvas, RRect rect) {
    _p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _cfg.bodyColor,
        _cfg.bodyColor.withValues(alpha: 0.70),
        _cfg.bodyColor.withValues(alpha: 0.85),
        _cfg.bodyColor,
      ],
    ).createShader(rect.outerRect);
    canvas.drawRRect(rect, _p);
  }

  void _drawBodySheen(Canvas canvas, RRect rect) {
    _p.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.15),
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(rect.outerRect);
    canvas.drawRRect(rect, _p);
  }

  void _drawBodyBorder(Canvas canvas, RRect rect) {
    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.40);
    _strokeP.strokeWidth = 1.5;
    canvas.drawRRect(rect, _strokeP);
  }

  void _drawBodyBands(
    Canvas canvas,
    double s,
    double cL,
    double cR,
    double cx,
    double bT,
    double bB,
  ) {
    _strokeP.strokeWidth = _cfg.bandWidth;
    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.50);

    for (var i = 0; i < _cfg.bandCount; i++) {
      final frac = (i + 1) / (_cfg.bandCount + 1);
      final by = bT + (bB - bT) * frac;
      if (_cfg.bandCount <= 2) {
        final path = Path()
          ..moveTo(cL + s * 0.02, by)
          ..quadraticBezierTo(cx, by + s * 0.01, cR - s * 0.02, by);
        canvas.drawPath(path, _strokeP);
      } else {
        final off = (i - 1) * s * 0.01;
        canvas.drawLine(
          Offset(cL + s * 0.02, by + off),
          Offset(cR - s * 0.02, by + off),
          _strokeP,
        );
      }
    }

    _strokeP.strokeWidth = 1.5;
    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.30);
    canvas.drawLine(
      Offset(cx, bT + s * 0.02),
      Offset(cx, bB - s * 0.02),
      _strokeP,
    );
  }

  void _drawLock(
    Canvas canvas,
    double cx,
    double bT,
    double bB,
    double cL,
    double cR,
  ) {
    final lc = Offset(cx, bT + (bB - bT) * 0.45);
    final lr = (cR - cL) * _cfg.lockSize;

    _p.style = PaintingStyle.fill;
    _p.shader = RadialGradient(
      colors: [_cfg.accentColor, _cfg.accentColor.withValues(alpha: 0.60)],
    ).createShader(Rect.fromCircle(center: lc, radius: lr));
    canvas.drawCircle(lc, lr, _p);

    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.80);
    _strokeP.strokeWidth = 1.5;
    canvas.drawCircle(lc, lr, _strokeP);

    _p.shader = null;
    _p.style = PaintingStyle.fill;
    _p.color = Colors.black38;
    canvas.drawCircle(lc, lr * 0.35, _p);

    if (_cfg.lockGem) {
      final gr = lr * 0.28;
      _p.color = type == ChestType.legendary
          ? PremiumColors.chestLegendaryParticle
          : PremiumColors.chestLegendaryRed;
      canvas.drawCircle(Offset(cx, lc.dy - lr * 0.4), gr, _p);
      _p.color = Colors.white.withValues(alpha: 0.30);
      canvas.drawCircle(
        Offset(cx - gr * 0.2, lc.dy - lr * 0.4 - gr * 0.2),
        gr * 0.35,
        _p,
      );
    }
  }

  void _drawLidInterior(
    Canvas canvas,
    double s,
    double cL,
    double cR,
    double lT,
    double bT,
    double cx,
    double t,
  ) {
    final angle = _lidAngle(t);
    if (angle > -0.05) return;

    canvas.save();
    canvas.translate(cx, lT);
    canvas.rotate(angle);
    canvas.translate(-cx, -lT);

    _p.style = PaintingStyle.fill;
    _p.shader = null;
    _p.color = PremiumColors.chestDarkLine;
    canvas.drawRect(Rect.fromLTRB(cL, lT, cR, bT), _p);

    _p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.black.withValues(alpha: 0.40),
        Colors.black.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTRB(cL, lT, cR, bT));
    canvas.drawRect(Rect.fromLTRB(cL, lT, cR, bT), _p);

    canvas.restore();
  }

  void _drawLid(
    Canvas canvas,
    double s,
    double cL,
    double cR,
    double lT,
    double bT,
    double cx,
    double t,
  ) {
    final angle = _lidAngle(t);
    final lr = Rect.fromLTRB(cL, lT, cR, bT);

    canvas.save();
    canvas.translate(cx, lT);
    canvas.rotate(angle);
    canvas.translate(-cx, -lT);

    _p.style = PaintingStyle.fill;
    _p.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        _cfg.bodyColor.withValues(alpha: 0.85),
        _cfg.bodyColor,
        _cfg.bodyColor.withValues(alpha: 0.90),
      ],
    ).createShader(lr);
    canvas.drawRect(lr, _p);

    _p.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.20),
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.10),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(lr);
    canvas.drawRect(lr, _p);

    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.50);
    _strokeP.strokeWidth = 1.5;
    canvas.drawRect(lr, _strokeP);

    _strokeP.strokeWidth = 2.0;
    _strokeP.color = _cfg.accentColor.withValues(alpha: 0.40);
    final lby = lT + (bT - lT) * 0.45;
    final lbPath = Path()
      ..moveTo(cL + s * 0.03, lby)
      ..quadraticBezierTo(cx, lby - s * 0.008, cR - s * 0.03, lby);
    canvas.drawPath(lbPath, _strokeP);

    if (_cfg.hasArch) {
      _strokeP.strokeWidth = 3.0;
      _strokeP.color = _cfg.accentColor.withValues(alpha: 0.60);
      final arch = Path()
        ..moveTo(cL, lT)
        ..quadraticBezierTo(cx, lT - s * 0.05, cR, lT);
      canvas.drawPath(arch, _strokeP);
    }

    if (type == ChestType.legendary) {
      _strokeP.strokeWidth = 1.5;
      _strokeP.color = _cfg.accentColor.withValues(alpha: 0.35);
      final inner = Path()
        ..moveTo(cL + s * 0.06, lT + s * 0.02)
        ..quadraticBezierTo(cx, lT - s * 0.03, cR - s * 0.06, lT + s * 0.02);
      canvas.drawPath(inner, _strokeP);
    }

    if (type == ChestType.bronze && angle > -0.05) {
      _p.style = PaintingStyle.fill;
      _p.shader = null;
      _p.color = _cfg.accentColor.withValues(alpha: 0.60);
      for (var i = 0; i < 4; i++) {
        final rx = cL + (cR - cL) * (0.2 + i * 0.2);
        canvas.drawCircle(Offset(rx, lT + s * 0.035), s * 0.008, _p);
      }
    }

    canvas.restore();
  }

  void _drawOpeningGlow(
    Canvas canvas,
    double s,
    double cL,
    double cR,
    double bT,
    double bB,
    double bR,
    double t,
  ) {
    final rt = _openProgress(t);
    if (rt <= 0) return;
    final a = (rt * 0.50).clamp(0.0, 1.0);
    _p.shader = null;
    _p.style = PaintingStyle.fill;
    _p.color = Colors.white.withValues(alpha: a * 0.20);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          cL + s * 0.04,
          bT + s * 0.02,
          cR - s * 0.04,
          bB - s * 0.02,
        ),
        Radius.circular(bR * 0.5),
      ),
      _p,
    );

    _p.shader =
        RadialGradient(
          colors: [
            _cfg.particleColor.withValues(alpha: a * 0.25),
            _cfg.particleColor.withValues(alpha: 0.0),
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset((cL + cR) / 2, (bT + bB) / 2),
            radius: s * 0.20,
          ),
        );
    canvas.drawRect(Rect.fromLTRB(cL, bT, cR, bB), _p);
  }

  void _drawShineSweep(
    Canvas canvas,
    double cL,
    double cR,
    double bT,
    double bB,
    double s,
    double t,
  ) {
    final sweep = (t * 1.5) % 1.0;
    final x = cL + (cR - cL) * sweep;
    final halfW = (cR - cL) * 0.12;

    _p.shader = LinearGradient(
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTRB(x - halfW, bT, x + halfW, bB));
    canvas.drawRect(Rect.fromLTRB(x - halfW, bT, x + halfW, bB), _p);
  }

  void _drawParticleBurst(Canvas canvas, double s, Offset c, double t) {
    final rt = _openProgress(t);
    if (rt <= 0) return;

    _p.style = PaintingStyle.fill;
    _p.shader = null;

    final count = type == ChestType.legendary
        ? 10
        : (type == ChestType.gold ? 8 : 6);
    for (var i = 0; i < count; i++) {
      final seed = i * 1.618;
      final angle = -math.pi / 2 + (seed - 0.5) * math.pi * 0.7;
      final dist = rt * s * (0.2 + 0.15 * (seed % 1.0));
      final size = s * (0.008 + 0.006 * ((seed * 7) % 1.0));
      final alpha = ((1.0 - rt) * 0.9).clamp(0.0, 1.0);

      final px = c.dx + dist * math.cos(angle) + (seed - 0.5) * s * 0.05;
      final py = c.dy - s * 0.05 + dist * math.sin(angle) - rt * rt * s * 0.10;

      _p.color = _cfg.particleColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(px, py), size, _p);

      if (i % 2 == 0) {
        _p.color = Colors.white.withValues(alpha: alpha * 0.40);
        canvas.drawCircle(Offset(px, py), size * 0.4, _p);
      }
    }
  }

  void _drawTierEffects(
    Canvas canvas,
    double s,
    Offset c,
    double t,
    double cL,
    double cR,
    double bT,
    double bB,
  ) {
    if (type == ChestType.legendary) {
      final sa = (0.3 + 0.3 * math.sin(t * math.pi * 8)).clamp(0.0, 1.0);
      _p.style = PaintingStyle.fill;
      _p.shader = null;
      _p.color = Colors.white.withValues(alpha: sa * 0.5);
      for (var i = 0; i < 6; i++) {
        final angle = t * 2.0 + i * math.pi / 3;
        final dist = s * 0.42 + 0.04 * s * math.sin(t * math.pi * 5 + i * 1.2);
        final px = c.dx + dist * math.cos(angle);
        final py = c.dy - s * 0.05 + dist * math.sin(angle);
        canvas.drawCircle(
          Offset(px, py),
          s * (0.010 + 0.004 * math.sin(t * math.pi * 7 + i)),
          _p,
        );
      }

      final ra = (0.2 + 0.2 * math.sin(t * math.pi * 3)).clamp(0.0, 1.0);
      _p.color = Colors.white.withValues(alpha: ra * 0.3);
      for (final y in [bT + s * 0.12, bB - s * 0.12]) {
        for (final x in [cL + s * 0.06, cR - s * 0.06]) {
          canvas.drawCircle(Offset(x, y), s * 0.008, _p);
        }
      }
    }
    if (type == ChestType.gold) {
      final sa = (0.1 + 0.1 * math.sin(t * math.pi * 10)).clamp(0.0, 1.0);
      _p.style = PaintingStyle.fill;
      _p.shader = null;
      _p.color = Colors.white.withValues(alpha: sa);
      final x =
          cL +
          (cR - cL) * (0.3 + 0.4 * (0.5 + 0.5 * math.sin(t * math.pi * 4)));
      canvas.drawCircle(Offset(x, s * 0.30), s * 0.025, _p);
    }
  }

  void _drawOpenFlash(Canvas canvas, Offset c, double s, double t) {
    final rt = _openProgress(t);
    if (rt < 0.85 || rt >= 1.0) return;
    final fa = ((rt - 0.85) / 0.15);
    final alpha = (1.0 - fa) * 0.12;
    _p.shader = null;
    _p.style = PaintingStyle.fill;
    _p.color = Colors.white.withValues(alpha: alpha);
    canvas.drawCircle(c, s * 0.50 * (1.0 + fa * 0.3), _p);
  }

  double _lidAngle(double t) {
    if (t <= _anticipationEnd) return 0.0;
    final ot = (t - _anticipationEnd) / (1.0 - _anticipationEnd);
    return -math.pi / 2.2 * Curves.easeOutCubic.transform(ot);
  }

  double _openProgress(double t) {
    if (t <= _anticipationEnd) return 0.0;
    return ((t - _anticipationEnd) / (1.0 - _anticipationEnd)).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(ChestPainter old) {
    if (isAnimating != old.isAnimating) return true;
    if (!isAnimating && !old.isAnimating) return false;
    return old.progress != progress || old.isOpen != isOpen || old.type != type;
  }
}
