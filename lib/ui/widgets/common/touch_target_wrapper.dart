import 'package:flutter/material.dart';

/// Enforces a minimum touch target size of 48x48 for accessibility.
/// Wraps any widget and ensures it meets WCAG guidelines.
class TouchTargetWrapper extends StatelessWidget {
  final Widget child;
  final double minSize;

  const TouchTargetWrapper({
    super.key,
    required this.child,
    this.minSize = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minSize,
        minHeight: minSize,
      ),
      child: child,
    );
  }
}
