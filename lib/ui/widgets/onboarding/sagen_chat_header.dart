import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';

class SagenChatHeader extends StatelessWidget {
  final Widget avatar;
  final String message;

  const SagenChatHeader({
    super.key,
    required this.avatar,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isDark
        ? PremiumColors.chatHeaderDark
        : Colors.white;
    final textColor = isDark
        ? PremiumColors.chatHeaderLight
        : PremiumColors.chatLockedDark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xs),
          child: SizedBox(
            width: 48,
            height: 48,
            child: avatar,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipPath(
            clipper: _BubbleClipper(),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                  bottomRight: Radius.circular(AppRadius.xl),
                  bottomLeft: Radius.circular(AppRadius.xl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const triangleWidth = 12.0;
    const triangleHeight = 14.0;

    path.moveTo(triangleWidth, 0);
    path.lineTo(triangleWidth, size.height);
    path.lineTo(0, triangleHeight + 8);
    path.close();

    path.addRRect(RRect.fromRectAndCorners(
      Rect.fromLTWH(triangleWidth, 0, size.width - triangleWidth, size.height),
      topRight: const Radius.circular(AppRadius.xl),
      bottomRight: const Radius.circular(AppRadius.xl),
      bottomLeft: const Radius.circular(AppRadius.xl),
      topLeft: const Radius.circular(AppRadius.xl),
    ));

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
