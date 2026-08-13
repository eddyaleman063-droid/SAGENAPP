import 'package:flutter/material.dart';

class ShimmerScope extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const ShimmerScope({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  static AnimationController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ShimmerInherited>()
        ?.controller;
  }

  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
}

class _ShimmerScopeState extends State<ShimmerScope>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerInherited(controller: _ctrl, child: widget.child);
  }
}

class _ShimmerInherited extends InheritedWidget {
  final AnimationController controller;

  const _ShimmerInherited({required this.controller, required super.child});

  @override
  bool updateShouldNotify(_ShimmerInherited old) => false;
}
