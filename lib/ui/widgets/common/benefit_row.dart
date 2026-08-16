import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';

class BenefitRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color? textColor;

  const BenefitRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = PremiumColors.streakOrange,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyle.subtitle.copyWith(
              color: textColor ?? context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
