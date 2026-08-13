import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../common/sage_emotion_widget.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../services/sage_emotion_service.dart';

class WizardSageSection extends StatelessWidget {
  final SageEmotion emotion;
  final String message;

  const WizardSageSection({
    super.key,
    required this.emotion,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RepaintBoundary(
            child: SageEmotionWidget(
              emotion: emotion,
              size: 52,
              animated: true,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              message,
              style: AppTextStyle.bodyMd.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}

class WizardSageBubble extends StatelessWidget {
  final String message;

  const WizardSageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: PremiumColors.wizardOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: PremiumColors.wizardOrange.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 20,
              color: PremiumColors.wizardOrange.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyle.bodyMd.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05);
  }
}
