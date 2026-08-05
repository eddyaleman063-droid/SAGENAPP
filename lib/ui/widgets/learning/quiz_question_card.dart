import 'package:flutter/material.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../models/learning/challenge.dart';
import '../../../models/learning/lesson_type.dart';
import '../common/localization_helper.dart';

class QuizQuestionCard extends StatelessWidget {
  final Challenge challenge;
  final int index;

  const QuizQuestionCard({
    super.key,
    required this.challenge,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final typeLabel = _typeLabel(challenge.type, context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            challenge.color.withValues(alpha: 0.08),
            challenge.color.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: challenge.color.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                decoration: BoxDecoration(
                  color: challenge.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  typeLabel,
                  style: AppTextStyle.label.copyWith(fontWeight: FontWeight.bold,
                    color: challenge.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            challenge.question,
            style: AppTextStyle.bodyLg.copyWith(fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
              height: 1.4),
          ),
        ],
      ),
    );
  }

  String _typeLabel(LessonType type, BuildContext context) {
    final l = l10n(context);
    switch (type) {
      case LessonType.trueFalse: return l.challengeTrueFalse;
      case LessonType.multipleChoice: return l.challengeMultiple;
      case LessonType.completePhrase: return l.challengeComplete;
      case LessonType.detectRisk: return l.challengeDetectRisk;
      case LessonType.createPassword: return l.challengeCreatePassword;
      case LessonType.whatWouldYouDo: return l.challengeWhatWouldYouDo;
      case LessonType.miniCase: return l.challengeMiniCase;
    }
  }
}
