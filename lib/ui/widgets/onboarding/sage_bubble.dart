import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/sage_emotion_service.dart';
import '../common/sage_emotion_widget.dart';

class SageBubble extends StatelessWidget {
  final SageEmotion emotion;
  final String text;
  final double sageSize;

  const SageBubble({
    super.key,
    required this.emotion,
    required this.text,
    this.sageSize = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: RepaintBoundary(
            child: SageEmotionWidget(
              emotion: emotion,
              size: sageSize,
              animated: true,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: PremiumColors.primary.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(AppRadius.xl),
                bottomRight: Radius.circular(AppRadius.xl),
              ),
              border: Border.all(
                color: PremiumColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyle.bodyMd.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
