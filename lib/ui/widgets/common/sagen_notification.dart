import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

enum NotificationType { success, error, info, warning }

class SagenNotification {
  SagenNotification._();

  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color backgroundColor;
    final Color textColor;
    final IconData icon;

    switch (type) {
      case NotificationType.success:
        backgroundColor = PremiumColors.success;
        textColor = Colors.white;
        icon = Icons.check_circle_rounded;
      case NotificationType.error:
        backgroundColor = PremiumColors.error;
        textColor = Colors.white;
        icon = Icons.error_rounded;
      case NotificationType.warning:
        backgroundColor = PremiumColors.warning;
        textColor = Colors.white;
        icon = Icons.warning_amber_rounded;
      case NotificationType.info:
        backgroundColor = isDark ? PremiumColors.darkSurface : Colors.white;
        textColor = isDark ? PremiumColors.textLight : PremiumColors.textDark;
        icon = Icons.info_rounded;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            ExcludeSemantics(child: Icon(icon, color: textColor, size: 18)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTextStyle.subtitle.copyWith(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        duration: duration,
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
      ),
    );
  }
}
