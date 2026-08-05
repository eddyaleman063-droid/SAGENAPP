import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _visible = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    // Debounce: show after 300ms to prevent flash
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _visible = true);
        _ctrl.repeat();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    return Semantics(
      label: AppLocalizations.of(context)?.chatTypingIndicator ?? '',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl + 36, 0, AppSpacing.xxl, AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return AnimatedBuilder(
              animation: _ctrl,
              builder: (_, child) {
                final t = (_ctrl.value - i * 0.2).clamp(0.0, 1.0);
                final scale = 0.4 + 0.6 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Transform.scale(scale: scale, child: child);
              },
              child: Padding(
                padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.textTertiary,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}