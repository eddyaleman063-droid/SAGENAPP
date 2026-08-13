import 'package:flutter/material.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;
  final bool enabled;
  final bool reduceAnimations;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.95,
    this.duration = const Duration(milliseconds: 120),
    this.enabled = true,
    this.reduceAnimations = false,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotion.resolve(
        widget.duration,
        reduceAnimations: widget.reduceAnimations,
      ),
    );
    _anim = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(TapScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.reduceAnimations != oldWidget.reduceAnimations ||
        widget.duration != oldWidget.duration) {
      _ctrl.duration = AppMotion.resolve(
        widget.duration,
        reduceAnimations: widget.reduceAnimations,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      child: GestureDetector(
        onTapDown: (_) {
          ExperienceService.instance.lightHaptic();
          _ctrl.forward();
        },
        onTapUp: (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _anim,
          builder: (context, child) =>
              Transform.scale(scale: _anim.value, child: child),
          child: widget.child,
        ),
      ),
    );
  }
}
