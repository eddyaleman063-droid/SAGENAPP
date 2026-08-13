import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

class StatCardWidget extends StatefulWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;
  final Color? accentColor;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    this.accentColor,
  });

  @override
  State<StatCardWidget> createState() => _StatCardWidgetState();
}

class _StatCardWidgetState extends State<StatCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? widget.iconColor;
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: PremiumColors.darkCard,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.iconColor.withValues(alpha: 0.15),
              ),
              child: ExcludeSemantics(
                child: Icon(widget.icon, size: 18, color: widget.iconColor),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              widget.value,
              style: AppTextStyle.titleLg.copyWith(
                fontWeight: FontWeight.bold,
                color: accent.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              widget.label,
              style: AppTextStyle.label.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
