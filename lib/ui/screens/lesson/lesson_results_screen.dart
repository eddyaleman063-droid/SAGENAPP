import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/app_logger.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';

import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/learning/lesson.dart';
import '../../widgets/common/premium_loader.dart';
import '../../widgets/rive_flame_widget.dart';

class LessonResultsScreen extends ConsumerWidget {
  final String stageId;
  final String lessonId;
  const LessonResultsScreen({
    super.key,
    required this.stageId,
    required this.lessonId,
  });

  Future<void> _finishLesson(
    BuildContext context,
    WidgetRef ref,
    SessionState session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final exp = ref.read(experienceServiceProvider);
    exp.successHaptic();
    try {
      // Acredita la lección ANTES del checkIn de racha: tanto el badge de XP como
      // completeLesson leen xpForLesson del MISMO multiplicador de racha.
      // Del orden contrario, en el borde racha 9->10 (mult 1.0->1.1) el badge
      // mostraría +15 y el servidor/cliente acreditarían round(15*1.1)=+17.
      // NUEVO-fix (ronda 9, P1): completeLesson es Future<void> y antes se
      // descartaba por completo — un throw síncrono dentro del notifier se
      // convertía en excepción async huérfana mientras la navegación ya había
      // salido de la pantalla (lección posiblemente sin acreditar). Ahora se
      // await y se navega SOLO si todo el bloque tuvo éxito.
      await ref
          .read(learningProvider.notifier)
          .completeLesson(
            stageId,
            lessonId,
            perfectLesson: session.isPerfect,
            correctAnswers: session.correctCount,
            totalQuestions: session.totalQuestions,
          );
      ref.read(streakProvider.notifier).checkIn();
    } catch (e, stack) {
      AppLogger().error('LessonResultsScreen._finishLesson failed', e, stack);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.tryAgain)));
      }
      return;
    }
    // Navegación determinista: se llega aquí tras `goNamed('lesson-results')`,
    // que deja la pila con una sola página (go_router construye las páginas solo
    // a partir de los matches). `context.pop()` en ese caso lanza
    // GoError('There is nothing to pop') y clavaba al usuario en la pantalla de
    // resultados. Volvemos siempre al mapa de lecciones.
    if (context.mounted) {
      context.goNamed('lessons');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final session = ref.watch(sessionProvider);

    Lesson? currentLesson;
    for (final s in ref.watch(learningProvider.select((l) => l.stages))) {
      for (final ls in s.lessons) {
        if (ls.id == lessonId) {
          currentLesson = ls;
          break;
        }
      }
      if (currentLesson != null) break;
    }
    final awardedXp = currentLesson == null
        ? session.earnedXp
        : ref.read(learningProvider.notifier).xpForLesson(currentLesson);

    if (session.phase == SessionPhase.intro) {
      return PremiumLoader(
        loading: true,
        message: l.lessonResultsPreparing,
        child: Scaffold(backgroundColor: context.surfaceBackground),
      );
    }

    return Scaffold(
      backgroundColor: context.surfaceBackground,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(bottom: 60),
                child: RiveFlameWidget(phase: null),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  if (session.isPerfect) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        gradient: const LinearGradient(
                          colors: PremiumColors.gradientAchievement,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l.resultPerfectBadge,
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  ExcludeSemantics(
                    child: Icon(
                      session.isPerfect
                          ? Icons.emoji_events_rounded
                          : Icons.check_circle_rounded,
                      size: 72,
                      color: session.isPerfect
                          ? PremiumColors.streakOrange
                          : PremiumColors.success,
                    ),
                  ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    session.isPerfect
                        ? l.resultPerfectTitle
                        : l.resultCompleteTitle,
                    style: AppTextStyle.headline.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    session.isPerfect
                        ? l.resultPerfectDesc
                        : l.resultNotPerfectDesc,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyMd.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ResultBadge(
                            icon: Icons.auto_awesome_rounded,
                            value: '+$awardedXp',
                            label: l.profileXpLabel,
                            color: PremiumColors.xpColor,
                            semanticsLabel: l.resultXpGained('$awardedXp'),
                          )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 300.ms,
                          ),
                      const SizedBox(width: AppSpacing.lg),
                      _ResultBadge(
                            icon: Icons.check_circle_rounded,
                            value: '${(session.accuracy * 100).toInt()}%',
                            label: l.resultAccuracy,
                            color: PremiumColors.success,
                            semanticsLabel: l.resultAccuracyLabel(
                              '${(session.accuracy * 100).toInt()}',
                            ),
                          )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 300.ms,
                          ),
                      const SizedBox(width: AppSpacing.lg),
                      _ResultBadge(
                            icon: Icons.favorite_rounded,
                            value: '${session.lives}',
                            label: l.resultLives,
                            color: PremiumColors.error,
                            semanticsLabel: l.resultLivesLabel(
                              '${session.lives}',
                            ),
                          )
                          .animate(delay: 500.ms)
                          .fadeIn(duration: 300.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 300.ms,
                          ),
                    ],
                  ),
                  const Spacer(flex: 3),
                  Semantics(
                    button: true,
                    label: l.continueText,
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => _finishLesson(context, ref, session),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          l.continueText,
                          style: AppTextStyle.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final String? semanticsLabel;
  const _ResultBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel ?? '$label $value',
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: color.withValues(alpha: 0.08),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 22, color: color)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyle.title.copyWith(
                fontWeight: FontWeight.bold,
                color: context.textPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyle.label.copyWith(color: context.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}
