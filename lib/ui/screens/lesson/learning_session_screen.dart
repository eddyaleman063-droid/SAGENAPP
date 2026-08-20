import 'package:flutter/material.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/providers/providers.dart';
import '../../../models/learning/challenge.dart';
import '../../../services/question_bank.dart';
import '../../../services/sage_emotion_service.dart';
import '../../../ui/widgets/common/ambient_background.dart';
import '../../../ui/widgets/common/premium_loader.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../ui/widgets/learning/quiz_session.dart';
import '../../../ui/widgets/learning/quiz_summary.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/ui/widgets/common/post_lesson_promo.dart';

class LearningSessionScreen extends ConsumerStatefulWidget {
  final String stageId;
  final String lessonId;
  final String lessonTitle;
  final int questionCount;

  const LearningSessionScreen({
    super.key,
    required this.stageId,
    required this.lessonId,
    required this.lessonTitle,
    this.questionCount = 5,
  });

  @override
  ConsumerState<LearningSessionScreen> createState() =>
      _LearningSessionScreenState();
}

class _LearningSessionScreenState extends ConsumerState<LearningSessionScreen> {
  bool _loading = true;
  List<Challenge>? _challenges;
  bool _showWelcome = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    ref
        .read(loggerProvider)
        .info(
          'LearningSessionScreen: loading questions for ${widget.lessonId}',
        );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await QuestionBank.instance.getQuestionsForLesson(
        widget.stageId,
        widget.lessonId,
        count: widget.questionCount,
      );
      ref
          .read(loggerProvider)
          .info('LearningSessionScreen: loaded ${questions.length} questions');
      if (!mounted) return;
      setState(() {
        _challenges = questions;
        _loading = false;
      });
    } catch (e) {
      ref
          .read(loggerProvider)
          .error('LearningSessionScreen: failed to load questions: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = AppLocalizations.of(context)?.errorLoadQuestions ?? '';
      });
    }
  }

  void _onComplete(QuizResult result) {
    final gemNotifier = ref.read(gemProvider.notifier);
    final gemsBase = result.correctAnswers * 5;
    final gemsPerfect = result.perfect ? 20 : 0;
    final gemsFirstLesson = gemNotifier.canAwardFirstLessonOfDay ? 10 : 0;
    final gemsEarned = gemsBase + gemsPerfect + gemsFirstLesson;

    ref
        .read(learningProvider.notifier)
        .completeLesson(
          widget.stageId,
          widget.lessonId,
          perfectLesson: result.perfect,
          correctAnswers: result.correctAnswers,
          totalQuestions: result.totalQuestions,
        );
    ref.read(streakProvider.notifier).checkIn();
    ref.read(energyProvider.notifier).consumeForLesson();

    if (!mounted) return;
    context.pushReplacement(
      '/quiz-summary',
      extra: _SummaryWrapper(
        result: QuizResult(
          totalQuestions: result.totalQuestions,
          correctAnswers: result.correctAnswers,
          xpEarned: result.xpEarned,
          gemsEarned: gemsEarned,
          perfect: result.perfect,
          timeTaken: result.timeTaken,
          stageId: result.stageId,
          lessonId: result.lessonId,
        ),
        stageId: widget.stageId,
        lessonId: widget.lessonId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PremiumLoader(
          loading: _loading,
          message: l.lessonPreparing,
          child: _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Semantics(
                          label:
                              AppLocalizations.of(context)?.errorGeneric ?? '',
                          child: const SageEmotionWidget(
                            emotion: SageEmotion.worried,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.bodyMd.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Semantics(
                          button: true,
                          label: l.retry,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _loading = true;
                                _errorMessage = null;
                              });
                              _loadQuestions();
                            },
                            child: Text(l.retry),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                )
              : _showWelcome && _challenges != null && _challenges!.isNotEmpty
              ? _PreTestWelcome(
                  lessonTitle: widget.lessonTitle,
                  questionCount: _challenges!.length,
                  onStart: () => setState(() => _showWelcome = false),
                  onSkip: () {
                    if (!mounted) return;
                    final navigator = Navigator.of(context);
                    final l = AppLocalizations.of(context)!;
                    showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l.closeButton),
                        content: Text(
                          '${l.sessionReadyToLearn} — ${widget.lessonTitle}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ExperienceService.instance.lightHaptic();
                              Navigator.of(ctx).pop(false);
                            },
                            child: Text(l.cancel),
                          ),
                          TextButton(
                            onPressed: () {
                              ExperienceService.instance.lightHaptic();
                              Navigator.of(ctx).pop(true);
                            },
                            child: Text(l.closeButton),
                          ),
                        ],
                      ),
                    ).then((confirmed) {
                      if (confirmed == true && mounted) {
                        setState(() {
                          _showWelcome = false;
                          _challenges = [];
                        });
                        navigator.pop();
                      }
                    });
                  },
                )
              : _challenges != null && _challenges!.isNotEmpty
              ? QuizSession(
                  challenges: _challenges!,
                  stageId: widget.stageId,
                  lessonId: widget.lessonId,
                  lessonTitle: widget.lessonTitle,
                  onComplete: _onComplete,
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const ExcludeSemantics(
                          child: SageEmotionWidget(
                            emotion: SageEmotion.thinking,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l.lessonNoQuestions,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.bodyMd.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Semantics(
                          button: true,
                          label: l.back,
                          child: ElevatedButton(
                            onPressed: () => context.pop(),
                            child: Text(l.back),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                ),
        ),
      ),
    );
  }
}

class _PreTestWelcome extends StatelessWidget {
  final String lessonTitle;
  final int questionCount;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  const _PreTestWelcome({
    required this.lessonTitle,
    required this.questionCount,
    required this.onStart,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Semantics(
                button: true,
                label: l.closeButton,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    l.closeButton,
                    style: AppTextStyle.body.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(flex: 2),
            const SageEmotionWidget(
              emotion: SageEmotion.happyWings,
              size: 100,
              animated: true,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l.sessionReadyToLearn,
              style: AppTextStyle.headline.copyWith(color: context.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              lessonTitle,
              textAlign: TextAlign.center,
              style: AppTextStyle.title.copyWith(color: PremiumColors.primary),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$questionCount ${l.sessionQuestionsToAnswer}',
              style: AppTextStyle.body.copyWith(color: context.textTertiary),
            ),
            const Spacer(flex: 3),
            Semantics(
              button: true,
              label: l.sessionStartQuiz,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    ExperienceService.instance.mediumHaptic();
                    onStart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PremiumColors.primaryAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    l.sessionStartQuiz,
                    style: AppTextStyle.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _SummaryWrapper extends StatelessWidget {
  final QuizResult result;
  final String stageId;
  final String lessonId;

  const _SummaryWrapper({
    required this.result,
    required this.stageId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return AmbientBackground(
      child: PostLessonPromo(
        showPromo: true,
        child: QuizSummaryScreen(
          result: result,
          onContinue: () {
            context.goNamed('main');
          },
          onRetry: () {
            context.goNamed(
              'learning-session',
              pathParameters: {'stageId': stageId, 'lessonId': lessonId},
              extra: '',
            );
          },
        ),
      ),
    );
  }
}
