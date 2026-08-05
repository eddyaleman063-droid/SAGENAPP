import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../models/chest_type.dart';
import 'chest_painter.dart';

const _anticipationEnd = 0.30;

class ChestWidget extends StatefulWidget {
  final ChestType type;
  final bool open;
  final double size;
  final bool animate;
  final VoidCallback? onOpenComplete;

  const ChestWidget({
    super.key,
    required this.type,
    this.open = false,
    this.size = 120,
    this.animate = true,
    this.onOpenComplete,
  });

  @override
  State<ChestWidget> createState() => _ChestWidgetState();
}

class _ChestWidgetState extends State<ChestWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  bool _showingOpen = false;
  bool _openedOnce = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ctrl.addListener(_onAnimate);
    _ctrl.addStatusListener(_onStatus);
    if (widget.open && widget.animate) _open();
  }

  @override
  void didUpdateWidget(ChestWidget old) {
    super.didUpdateWidget(old);
    if (!old.open && widget.open && !_openedOnce) _open();
  }

  void _open() {
    _openedOnce = true;
    _ctrl.forward();
  }

  void _onAnimate() {
    if (_ctrl.value >= _anticipationEnd && !_showingOpen) {
      _showingOpen = true;
      HapticFeedback.mediumImpact();
      if (mounted) setState(() {});
    }
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      widget.onOpenComplete?.call();
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onAnimate);
    _ctrl.removeStatusListener(_onStatus);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context)?.chestTreasureLabel(widget.type.name) ?? '',
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: ChestPainter(
            type: widget.type,
            progress: _ctrl.value,
            isOpen: _showingOpen || (!widget.animate && widget.open),
            isAnimating: widget.animate,
          ),
        ),
      ),
    );
  }
}
