import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/question_bank.dart';
import '../../../services/sage_emotion_service.dart';
import '../../../ui/widgets/common/ambient_background.dart';
import '../../../ui/widgets/common/premium_loader.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import '../../../ui/widgets/learning/quiz_session.dart';

/// Repaso inteligente (SM-2): refuerza las preguntas que más cuestan.
/// Recompensas server-side ya soportadas: +15 XP (reason 'review') y +6 gemas
/// (earnGems reason 'review').
class ReviewSessionScreen extends ConsumerStatefulWidget {
  const ReviewSessionScreen({super.key});

  @override
  ConsumerState<ReviewSessionScreen> createState() =>
      _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends ConsumerState<ReviewSessionScreen> {
  bool _loading = true;
  List<Challenge>? _challenges;
  bool _noDue = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadQuestions();
    });
  }

  Future<void> _loadQuestions() async {
    try {
      final ids = ref.read(reviewProvider.notifier).reviewQueueIds;
      if (ids.isEmpty) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _noDue = true;
        });
        return;
      }
      final questions = await QuestionBank.instance.getByIds(ids);
      // Si el banco resolvió menos IDs que los pedidos, algunos son stale
      // (contenido curateado eliminado). Se podan de los mapas SM-2 SOLO los
      // pedidos que no resolvieron; los debidos no servidos en este lote (tope
      // de 10) no se tocan. Así no se generan badges de repaso huecos.
      if (questions.length < ids.length) {
        ref
            .read(reviewProvider.notifier)
            .pruneMissingIds(ids, questions.map((q) => q.id));
      }
      if (!mounted) return;
      setState(() {
        _challenges = questions;
        _loading = false;
      });
    } catch (e) {
      ref
          .read(loggerProvider)
          .error('ReviewSessionScreen: failed to load review: $e');
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = AppLocalizations.of(context)?.errorLoadQuestions ?? '';
      });
    }
  }

  void _onComplete(QuizResult result) {
    ref.read(reviewProvider.notifier).markReviewCompleted();
    // Repasar también es actividad diaria: la racha no se rompe si el día se
    // dedica a reforzar lo débil. checkIn es idempotente por día; las lecciones
    // ya lo invocan en su screen de resultados.
    ref.read(streakProvider.notifier).checkIn();
    // +15 XP server-side (economic.js REASON_REWARDS.review).
    ref.read(learningProvider.notifier).addXp(15, reason: 'review');
    // +6 gemas server-side (gems.js GEM_REWARDS.review).
    ref.read(gemProvider.notifier).awardReviewGems();
    final passed =
        result.totalQuestions > 0 &&
        result.correctAnswers / result.totalQuestions >= 0.7;
    ref
        .read(learningMemoryProvider.notifier)
        .recordLessonResult(passed: passed, topic: 'review');

    if (!mounted) return;
    context.pushReplacement(
      '/review-summary',
      extra: QuizResult(
        totalQuestions: result.totalQuestions,
        correctAnswers: result.correctAnswers,
        xpEarned: 15,
        gemsEarned: 6,
        perfect: result.perfect,
        timeTaken: result.timeTaken,
        stageId: 'review',
        lessonId: 'review',
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
              ? _MessageState(
                  icon: SageEmotion.worried,
                  message: _errorMessage!,
                  actionLabel: l.retry,
                  onAction: () {
                    setState(() {
                      _loading = true;
                      _errorMessage = null;
                      _noDue = false;
                    });
                    _loadQuestions();
                  },
                )
              : _noDue
              ? _MessageState(
                  icon: SageEmotion.happyWings,
                  message: l.reviewNoneDue,
                  actionLabel: l.back,
                  onAction: () => context.pop(),
                )
              : _challenges != null && _challenges!.isNotEmpty
              ? QuizSession(
                  challenges: _challenges!,
                  stageId: 'review',
                  lessonId: 'review',
                  lessonTitle: l.reviewScreenTitle,
                  topicForReview: 'review',
                  onComplete: _onComplete,
                )
              : _MessageState(
                  icon: SageEmotion.thinking,
                  message: l.reviewNoneDue,
                  actionLabel: l.back,
                  onAction: () => context.pop(),
                ),
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final SageEmotion icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _MessageState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: SageEmotionWidget(emotion: icon)),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodyMd.copyWith(color: context.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Semantics(
              button: true,
              label: actionLabel,
              child: ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }
}

/// Resumen del repaso: muestra el rendimiento y las recompensas reales
/// (+15 XP, +6 gemas) ya acreditadas por el servidor.
class ReviewSummaryScreen extends StatelessWidget {
  final QuizResult result;
  final VoidCallback onContinue;

  const ReviewSummaryScreen({
    super.key,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final percent = (result.score * 100).round();

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ExcludeSemantics(
                    child: SageEmotionWidget(
                      emotion: SageEmotion.happyWings,
                      size: 90,
                      animated: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l.reviewCompleted,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.headline.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.correctAnswers(
                      result.correctAnswers,
                      result.totalQuestions,
                    ),
                    style: AppTextStyle.bodyMd.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$percent%',
                    style: AppTextStyle.displayMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: PremiumColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _RewardRow(
                    icon: Icons.auto_awesome_rounded,
                    label: l.reviewXpLabel,
                    value: '+${result.xpEarned}',
                    color: PremiumColors.achievementEnd,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RewardRow(
                    icon: Icons.diamond_rounded,
                    label: l.reviewGemsLabel,
                    value: '+${result.gemsEarned}',
                    color: PremiumColors.accentCyan,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Semantics(
                      button: true,
                      label: l.continueText,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ExperienceService.instance.lightHaptic();
                          onContinue();
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                        label: Text(
                          l.continueText,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 4,
                          shadowColor: PremiumColors.primary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RewardRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: ExcludeSemantics(child: Icon(icon, size: 18, color: color)),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyle.bodyMd.copyWith(color: context.textSecondary),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyle.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
