import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class FlipCounterWidget extends StatefulWidget {
  final int value;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final Duration flipDuration;
  final int digitCount;
  final double digitWidth;
  final double digitHeight;

  const FlipCounterWidget({
    super.key,
    required this.value,
    this.textStyle,
    this.backgroundColor,
    this.flipDuration = const Duration(milliseconds: 500),
    this.digitCount = 2,
    this.digitWidth = 48,
    this.digitHeight = 64,
  });

  @override
  State<FlipCounterWidget> createState() => _FlipCounterWidgetState();
}

class _FlipCounterWidgetState extends State<FlipCounterWidget>
    with TickerProviderStateMixin {
  List<int> _displayed = [];
  late List<AnimationController> _controllers;

  List<int> _digitsOf(int n) {
    return n
        .toString()
        .padLeft(widget.digitCount, '0')
        .split('')
        .map(int.parse)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _displayed.addAll(_digitsOf(widget.value));
    _controllers = List.generate(
      widget.digitCount,
      (_) => AnimationController(vsync: this, duration: widget.flipDuration),
    );
  }

  @override
  void didUpdateWidget(FlipCounterWidget old) {
    super.didUpdateWidget(old);
    if (old.digitCount != widget.digitCount) {
      setState(() {
        _displayed = _digitsOf(widget.value);
      });
      return;
    }
    if (old.value == widget.value) return;
    final newDigits = _digitsOf(widget.value);
    for (int i = 0; i < widget.digitCount; i++) {
      if (newDigits[i] != _displayed[i]) {
        _displayed[i] = newDigits[i];
        _controllers[i].forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.digitCount, (i) {
        return Padding(
          padding: EdgeInsets.only(right: i < widget.digitCount - 1 ? 4 : 0),
          child: _FlipDigitCard(
            digit: _displayed[i],
            controller: _controllers[i],
            textStyle: widget.textStyle,
            backgroundColor: widget.backgroundColor,
            width: widget.digitWidth,
            height: widget.digitHeight,
          ),
        );
      }),
    );
  }
}

class _FlipDigitCard extends StatelessWidget {
  final int digit;
  final AnimationController controller;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final double width;
  final double height;

  const _FlipDigitCard({
    required this.digit,
    required this.controller,
    this.textStyle,
    this.backgroundColor,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final anim = controller.value;
            if (anim == 0.0) {
              return _renderHalf(digit, 1.0, Alignment.center);
            }

            const mid = 0.5;
            if (anim < mid) {
              final t = anim / mid;
              final angle = t * pi * 0.5;
              final scaleY = cos(angle);
              return ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: scaleY,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(1, 1, scaleY)
                      ..setEntry(3, 1, 0.001),
                    alignment: Alignment.bottomCenter,
                    child: _renderHalf(digit, 1.0, Alignment.bottomCenter),
                  ),
                ),
              );
            } else {
              final t = (anim - mid) / mid;
              final angle = (1.0 - t) * pi * 0.5;
              final scaleY = cos(angle);
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: scaleY,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(1, 1, scaleY)
                      ..setEntry(3, 1, 0.001),
                    alignment: Alignment.topCenter,
                    child: _renderHalf(digit, 1.0, Alignment.topCenter),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _renderHalf(int digit, double heightFactor, Alignment alignment) {
    return Align(
      alignment: alignment,
      heightFactor: heightFactor,
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? PremiumColors.darkSurface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text('$digit', style: textStyle),
      ),
    );
  }
}
