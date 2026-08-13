import 'package:flutter/material.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'shimmer_scope.dart';

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  AnimationController? _ownCtrl;
  AnimationController? _sharedCtrl;

  AnimationController get _ctrl => _sharedCtrl ?? _ownCtrl!;

  @override
  void initState() {
    super.initState();
    _sharedCtrl = ShimmerScope.maybeOf(context);
    if (_sharedCtrl == null) {
      _ownCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      _ownCtrl!.repeat();
    }
  }

  @override
  void dispose() {
    _ownCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anim = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));

    final base = widget.baseColor ?? context.surfaceTinted;
    final highlight = widget.highlightColor ?? context.borderSubtle;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                colors: [base, highlight, base],
                stops: const [0.0, 0.5, 1.0],
                begin: Alignment(anim.value - 1, 0),
                end: Alignment(anim.value + 1, 0),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ShimmerBlock extends StatelessWidget {
  final int lines;
  final double spacing;
  final double lineHeight;

  const ShimmerBlock({
    super.key,
    this.lines = 3,
    this.spacing = 12,
    this.lineHeight = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < lines - 1 ? spacing : 0),
          child: ShimmerLoading(
            width: i == lines - 1 ? 0.6 : 0.9,
            height: lineHeight,
          ),
        );
      }),
    );
  }
}
