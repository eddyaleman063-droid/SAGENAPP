import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../core/theme/app_colors.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/experience_service.dart';

class LessonSessionScreen extends ConsumerStatefulWidget {
  final String stageId;
  final String lessonId;
  final String lessonTitle;
  const LessonSessionScreen({
    super.key,
    required this.stageId,
    required this.lessonId,
    required this.lessonTitle,
  });

  @override
  ConsumerState<LessonSessionScreen> createState() => _LessonSessionScreenState();
}

class _LessonSessionScreenState extends ConsumerState<LessonSessionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;
  bool _navigatedToResults = false;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).startSession(widget.stageId, widget.lessonId);
    });
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _triggerSlide() {
    _slideCtrl.reset();
    _slideCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    if (session.phase == SessionPhase.completed && !_navigatedToResults) {
      _navigatedToResults = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.goNamed(
            'lesson-results',
            pathParameters: {
              'stageId': widget.stageId,
              'lessonId': widget.lessonId,
            },
          );
        }
      });
    }

    if (session.phase == SessionPhase.gameOver) {
      return _GameOverOverlay(session: session);
    }

    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.exitText),
            content: Text(l.exitQuizContent),
            actions: [
              TextButton(onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(ctx); }, child: Text(l.cancel)),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: Text(l.exitText),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        backgroundColor: context.surfaceBackground,
        body: SafeArea(
          child: Column(
            children: [
              _HudBar(session: session, title: widget.lessonTitle),
              if (session.phase == SessionPhase.feedback)
                Expanded(child: _FeedbackBody(session: session, onContinue: _triggerSlide))
              else
                Expanded(child: _QuestionBody(session: session, animController: _slideCtrl, slideAnim: _slideAnim)),
              _BottomBar(session: session),
            ],
          ),
        ),
      ),
    );
  }
}

class _HudBar extends StatelessWidget {
  final SessionState session;
  final String title;
  const _HudBar({required this.session, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        boxShadow: AppShadows.card(color: context.subtle),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.closeButton,
                child: IconButton(
                  icon: Icon(Icons.close_rounded, color: context.textTertiary),
                  onPressed: () {
                    ExperienceService.instance.lightHaptic();
                    context.pop();
                  },
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  tooltip: AppLocalizations.of(context)!.closeButton,
                ),
              ),
              Text(
                title,
                style: AppTextStyle.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Semantics(
                label: AppLocalizations.of(context)!.livesRemainingLabel(session.lives),
                container: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (i) {
                    final filled = i < session.lives;
                    return Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Icon(
                        filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 18,
                        color: filled
                            ? PremiumColors.error
                            : context.subtle,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Semantics(
            label: AppLocalizations.of(context)!.lessonProgress((session.progress * 100).toInt()),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: LinearProgressIndicator(
                value: session.progress,
                backgroundColor: context.surfaceTinted,
                valueColor: AlwaysStoppedAnimation<Color>(
                  session.lives <= 1 ? PremiumColors.error : PremiumColors.primaryAccent,
                ),
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBody extends ConsumerWidget {
  final SessionState session;
  final AnimationController animController;
  final Animation<Offset> slideAnim;
  const _QuestionBody({
    required this.session,
    required this.animController,
    required this.slideAnim,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final challenge = session.currentChallenge;
    if (challenge == null) {
      return Center(child: Text(l.sessionLoading));
    }

    if (animController.value == 0 && !animController.isAnimating) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (animController.value == 0 && !animController.isAnimating) {
          animController.forward();
        }
      });
    }

    return SlideTransition(
      position: slideAnim,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              challenge.question,
              style: AppTextStyle.title.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ...challenge.options.asMap().entries.map((entry) {
              final i = entry.key;
              final opt = entry.value;
              final selected = session.feedbackSelected == i;
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _OptionTile(
                    index: i,
                    text: opt,
                    selected: selected,
                    onTap: () {
                  ExperienceService.instance.lightHaptic();
                  ref.read(sessionProvider.notifier).submitAnswer(i);
                },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _OptionTile({
    required this.index,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final letters = ['A', 'B', 'C', 'D'];
    return Semantics(
      button: true,
      selected: selected,
      label: text,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: selected
              ? PremiumColors.primaryAccent.withValues(alpha: 0.12)
               : context.surfaceCard,
          border: Border.all(
            color: selected
                ? PremiumColors.primaryAccent.withValues(alpha: 0.4)
                : context.subtleBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? PremiumColors.primaryAccent
                    : context.surfaceTinted,
              ),
              child: Center(
                child: Text(
                  letters[index % letters.length],
                    style: AppTextStyle.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? Colors.white
                          : context.textTertiary,
                    ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                text,
                style: AppTextStyle.bodyMd.copyWith(
                  color: context.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final SessionState session;
  const _BottomBar({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final isFeedback = session.phase == SessionPhase.feedback;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl),
      child: Semantics(
        button: true,
        label: isFeedback ? l.nextText : l.sessionSelectAnswer,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isFeedback
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(sessionProvider.notifier).onFeedbackDismissed();
                    ref.read(sessionProvider.notifier).nextQuestion();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isFeedback ? PremiumColors.primary : context.surfaceTinted,
              disabledBackgroundColor: context.surfaceTinted,
              foregroundColor: Colors.white,
              disabledForegroundColor: context.textDisabled,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
              elevation: 0,
            ),
            child: Text(
              isFeedback ? l.nextText : l.sessionSelectAnswer,
              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeedbackBody extends StatelessWidget {
  final SessionState session;
  final VoidCallback onContinue;
  const _FeedbackBody({required this.session, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final correct = session.feedbackCorrect;
    final challenge = session.currentChallenge;
    if (challenge == null) return const SizedBox.shrink();
    final correctOption = challenge.options[challenge.correctIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.xl),
              color: (correct ? PremiumColors.success : PremiumColors.error).withValues(alpha: 0.08),
              border: Border.all(
                color: (correct ? PremiumColors.success : PremiumColors.error).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                ExcludeSemantics(child: Icon(
                  correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 48,
                  color: correct ? PremiumColors.success : PremiumColors.error,
                ),),
                const SizedBox(height: AppSpacing.md),
                Text(
                  correct ? l.sessionCorrect : l.sessionIncorrect,
                  style: AppTextStyle.titleLg.copyWith(
                    fontWeight: FontWeight.bold,
                    color: correct ? PremiumColors.success : PremiumColors.error,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (!correct) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      color: PremiumColors.success.withValues(alpha: 0.1),
                    ),
                    child: Text(
                      l.sessionCorrectAnswer(correctOption),
                      style: AppTextStyle.subtitle.copyWith(fontWeight: FontWeight.w500, color: PremiumColors.success),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Text(
                  challenge.explanation,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.subtitle.copyWith(
                    height: 1.4,
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameOverOverlay extends ConsumerWidget {
  final SessionState session;
  const _GameOverOverlay({required this.session});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Icon(Icons.hourglass_empty_rounded, size: 64, color: PremiumColors.error.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l.sessionLivesExhausted,
                style: AppTextStyle.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.sessionLivesExhaustedDesc,
                textAlign: TextAlign.center,
                style: AppTextStyle.bodyMd.copyWith(color: context.textTertiary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l.sessionScore(session.correctCount, session.totalQuestions),
                  style: AppTextStyle.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: PremiumColors.primaryAccent,
                  ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Semantics(
                button: true,
                label: l.sessionRetry,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(sessionProvider.notifier).retry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PremiumColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                    ),
                    child: Text(l.sessionRetry, style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Semantics(
                button: true,
                label: l.sessionBackToMap,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    l.sessionBackToMap,
                    style: AppTextStyle.bodyMd.copyWith(color: context.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
