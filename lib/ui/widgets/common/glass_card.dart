import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:sagen/core/theme/theme_constants.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double sigmaX;
  final double sigmaY;
  final List<Color>? borderGradient;
  final double borderRadius;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final bool enableBlur;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.sigmaX = 8,
    this.sigmaY = 8,
    this.borderGradient,
    this.borderRadius = AppRadius.xl,
    this.backgroundColor,
    this.boxShadow,
    this.enableBlur = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? cs.surfaceContainerHighest;
    final borderColors = borderGradient ??
        [cs.outlineVariant.withValues(alpha: 0.5),
         cs.outlineVariant.withValues(alpha: 0.3)];

    final content = Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: bgColor,
        border: Border.all(
          color: borderColors.first,
        ),
        boxShadow: boxShadow ?? AppShadows.card(color: cs.shadow.withValues(alpha: 0.12)),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColors.length > 1 ? borderColors[1] : borderColors.first,
        ),
      ),
      child: child,
    );

    return Container(
      margin: margin ?? EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: enableBlur
            ? BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
                child: content,
              )
            : content,
      ),
    );
  }
}
