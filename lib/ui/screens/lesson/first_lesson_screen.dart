import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../models/learning/challenge.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/premium_loader.dart';
import 'package:sagen/ui/widgets/shimmer_loading.dart';
import 'package:sagen/services/sage_emotion_service.dart';
import 'package:sagen/ui/widgets/common/sage_emotion_widget.dart';

class FirstLessonScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const FirstLessonScreen({super.key, required this.onComplete});

  @override
  ConsumerState<FirstLessonScreen> createState() => _FirstLessonScreenState();
}

class _FirstLessonScreenState extends ConsumerState<FirstLessonScreen> {
  String? _loadError;
  Timer? _timeoutTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lesson = ref.read(firstLessonProvider);
      if (lesson.questions.isEmpty) {
        _startLessonWithTimeout();
      }
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startLessonWithTimeout() {
    final path = ref.read(diagnosticPathProvider);
    ref.read(firstLessonProvider.notifier).startLesson(path: path);
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      final updated = ref.read(firstLessonProvider);
      if (updated.questions.isEmpty && mounted) {
        setState(
          () => _loadError = AppLocalizations.of(context)!.errorLoadQuestions,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final lesson = ref.watch(firstLessonProvider);
    final notifier = ref.read(firstLessonProvider.notifier);

    ref.listen(firstLessonProvider, (prev, next) {
      if (next.isComplete && mounted) {
        widget.onComplete();
      }
    });

    if (_loadError != null) {
      return Scaffold(
        backgroundColor: dark
            ? PremiumColors.deepBackground
            : PremiumColors.lightBg,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ExcludeSemantics(
                child: SageEmotionWidget(emotion: SageEmotion.worried),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                _loadError!,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.retry,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _loadError = null;
                    });
                    _startLessonWithTimeout();
                  },
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (lesson.questions.isEmpty) {
      return Scaffold(
        backgroundColor: dark
            ? PremiumColors.deepBackground
            : PremiumColors.lightBg,
        body: const _FirstLessonShimmer(),
      );
    }

    if (lesson.isComplete) {
      return PremiumLoader(
        loading: true,
        message: AppLocalizations.of(context)!.loading,
        child: Scaffold(
          backgroundColor: dark
              ? PremiumColors.deepBackground
              : PremiumColors.lightBg,
        ),
      );
    }

    final q = lesson.currentChallenge;
    if (q == null) return const SizedBox.shrink();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.exitText),
            content: Text(l.exitQuizTitle),
            actions: [
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: Text(l.cancel),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: Text(l.exitText),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: dark
            ? PremiumColors.deepBackground
            : PremiumColors.lightBg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.school_rounded,
                        color: PremiumColors.splashBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      l.firstLessonProgress(
                        lesson.currentIndex + 1,
                        lesson.totalQuestions,
                      ),
                      style: AppTextStyle.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: context.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${lesson.totalQuestions > 0 ? ((lesson.currentIndex / lesson.totalQuestions) * 100).toInt() : 0}%',
                      style: AppTextStyle.subtitle.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PremiumColors.splashBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  label: l.firstLessonProgress(
                    lesson.currentIndex + 1,
                    lesson.totalQuestions,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: lesson.totalQuestions > 0
                          ? lesson.currentIndex / lesson.totalQuestions
                          : 0.0,
                      backgroundColor: context.surfaceTinted,
                      valueColor: const AlwaysStoppedAnimation(
                        PremiumColors.splashBlue,
                      ),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _QuestionBody(
                      key: ValueKey(lesson.currentIndex),
                      question: q,
                      showFeedback: lesson.showFeedback,
                      selectedAnswer: lesson.selectedAnswer,
                      answeredCorrectly: lesson.answeredCorrectly,
                      isLastQuestion:
                          lesson.currentIndex + 1 >= lesson.totalQuestions,
                      onSelect: (index) => notifier.submitAnswer(index),
                      onNext: () => notifier.nextQuestion(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstLessonShimmer extends StatelessWidget {
  const _FirstLessonShimmer();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShimmerLoading(width: 280, height: 20),
          SizedBox(height: AppSpacing.xxl),
          ShimmerLoading(
            width: double.infinity,
            height: 56,
            borderRadius: AppRadius.lg,
          ),
          SizedBox(height: AppSpacing.md),
          ShimmerLoading(
            width: double.infinity,
            height: 56,
            borderRadius: AppRadius.lg,
          ),
          SizedBox(height: AppSpacing.md),
          ShimmerLoading(
            width: double.infinity,
            height: 56,
            borderRadius: AppRadius.lg,
          ),
        ],
      ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  final Challenge question;
  final bool showFeedback;
  final int? selectedAnswer;
  final bool answeredCorrectly;
  final bool isLastQuestion;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  const _QuestionBody({
    super.key,
    required this.question,
    required this.showFeedback,
    required this.selectedAnswer,
    required this.answeredCorrectly,
    required this.isLastQuestion,
    required this.onSelect,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.question,
          style: AppTextStyle.title.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        ...List.generate(question.options.length, (i) {
          final opt = question.options[i];
          final isSelected = selectedAnswer == i;
          final isCorrect = i == question.correctIndex;

          Color? tileColor;
          Color? borderColor;
          if (showFeedback) {
            if (isCorrect) {
              tileColor = PremiumColors.success.withValues(alpha: 0.12);
              borderColor = PremiumColors.success;
            } else if (isSelected && !isCorrect) {
              tileColor = PremiumColors.error.withValues(alpha: 0.12);
              borderColor = PremiumColors.error;
            } else {
              tileColor = context.subtle;
              borderColor = context.subtleBorder;
            }
          } else {
            tileColor = context.subtle;
            borderColor = context.subtleBorder;
          }

          return Semantics(
            button: true,
            label: opt,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GestureDetector(
                onTap: showFeedback
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onSelect(i);
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    color: tileColor,
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        showFeedback && isCorrect
                            ? Icons.check_circle_rounded
                            : showFeedback && isSelected && !isCorrect
                            ? Icons.cancel_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 20,
                        color: showFeedback && isCorrect
                            ? PremiumColors.success
                            : showFeedback && isSelected && !isCorrect
                            ? PremiumColors.error
                            : context.textTertiary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          opt,
                          style: AppTextStyle.body.copyWith(
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (showFeedback) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              color: answeredCorrectly
                  ? PremiumColors.success.withValues(alpha: 0.08)
                  : PremiumColors.error.withValues(alpha: 0.08),
              border: Border.all(
                color: answeredCorrectly
                    ? PremiumColors.success.withValues(alpha: 0.2)
                    : PremiumColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  answeredCorrectly
                      ? Icons.check_circle_rounded
                      : Icons.info_rounded,
                  size: 18,
                  color: answeredCorrectly
                      ? PremiumColors.success
                      : PremiumColors.error,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: AppTextStyle.subtitle.copyWith(
                      color: answeredCorrectly
                          ? (context.isDark
                                ? PremiumColors.successLight
                                : PremiumColors.success)
                          : context.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Semantics(
            button: true,
            label: isLastQuestion ? l.firstLessonSeeResults : l.nextText,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PremiumColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  isLastQuestion
                      ? l.firstLessonSeeResults
                      : l.nextText.toUpperCase(),
                  style: AppTextStyle.body.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}
