import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class TiltWidget extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final double sensitivity;

  const TiltWidget({
    super.key,
    required this.child,
    this.maxTilt = 0.05,
    this.sensitivity = 2.0,
  });

  @override
  State<TiltWidget> createState() => _TiltWidgetState();
}

class _TiltWidgetState extends State<TiltWidget> {
  double _tiltX = 0;
  double _tiltY = 0;
  StreamSubscription? _sub;
  DateTime _lastUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _sub = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      if (now.difference(_lastUpdate).inMilliseconds < 33) return; // ~30fps throttle
      _lastUpdate = now;
      final clampedX = (-event.y / 10).clamp(-1.0, 1.0) * widget.sensitivity;
      final clampedY = (event.x / 10).clamp(-1.0, 1.0) * widget.sensitivity;
      if (!mounted) return;
      setState(() {
        _tiltX = clampedX * widget.maxTilt;
        _tiltY = clampedY * widget.maxTilt;
      });
    }, onError: (_) {
      _tiltX = 0;
      _tiltY = 0;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_tiltX)
        ..rotateY(_tiltY),
      alignment: Alignment.center,
      child: widget.child,
    );
  }
}
