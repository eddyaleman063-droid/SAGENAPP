import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/app_logger.dart';

import '../../../core/theme/theme_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/learning/challenge.dart';
import '../../../models/learning/quiz_score.dart';
import '../../widgets/common/localization_helper.dart';
import '../../widgets/common/sagen_notification.dart';

enum _AnswerState { idle, correct, incorrect }

const int _lowTimeThresholdSeconds = 30;

class CyberQuizScreen extends StatefulWidget {
  final List<Challenge> questions;
  final String lessonTitle;
  final int timeBudgetSeconds;

  const CyberQuizScreen({
    super.key,
    required this.questions,
    this.lessonTitle = '',
    this.timeBudgetSeconds = 300,
  });

  @override
  State<CyberQuizScreen> createState() => _CyberQuizScreenState();
}

class _CyberQuizScreenState extends State<CyberQuizScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  int _selectedAnswer = -1;
  _AnswerState _answerState = _AnswerState.idle;
  int _correctCount = 0;
  DateTime? _sessionStart;
  Timer? _quizTimer;
  int _timeRemaining = 300;

  late AnimationController _shakeCtrl;
  late AnimationController _pulseCtrl;

  static const _progressPrefix = 'quiz_progress_';
  static const _progressExpiry = Duration(hours: 24);

  String get _progressKey => '$_progressPrefix${widget.lessonTitle}';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sessionStart = DateTime.now();
    _timeRemaining = widget.timeBudgetSeconds;
    _quizTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timeRemaining <= 0) {
        t.cancel();
        _finishQuiz();
      } else {
        setState(() => _timeRemaining--);
      }
    });
    _loadSavedProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _quizTimer?.cancel();
    _shakeCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _saveProgress();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final answers = <int>[];
      for (int i = 0; i < _currentIndex; i++) {
        answers.add(-1);
      }
      final data = {
        'currentIndex': _currentIndex,
        'score': _correctCount,
        'answers': answers,
        'startTime': _sessionStart?.toIso8601String(),
        'timestamp': DateTime.now().toIso8601String(),
        'timeRemaining': _timeRemaining,
      };
      await prefs.setString(_progressKey, jsonEncode(data));
    } catch (e) {
      AppLogger().warning('CyberQuiz: failed to save quiz progress: $e');
    }
  }

  Future<void> _loadSavedProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final raw = prefs.getString(_progressKey);
      if (raw == null) return;
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final savedTime = DateTime.tryParse(data['timestamp'] as String? ?? '');
      if (savedTime != null &&
          DateTime.now().difference(savedTime) > _progressExpiry) {
        await prefs.remove(_progressKey);
        if (!mounted) return;
        SagenNotification.show(
          context,
          message: l10n(context).quizProgressExpired,
          type: NotificationType.info,
        );
        return;
      }

      final savedIndex = data['currentIndex'] as int? ?? 0;
      final savedScore = data['score'] as int? ?? 0;
      final savedTimeRemaining =
          data['timeRemaining'] as int? ?? widget.timeBudgetSeconds;

      if (savedIndex > 0 && savedIndex < widget.questions.length) {
        if (!mounted) return;
        _quizTimer?.cancel();
        final result = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              backgroundColor: ctx.surfaceCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              title: Text(
                l10n(context).resumeQuiz,
                style: AppTextStyle.titleLg.copyWith(color: ctx.textPrimary),
              ),
              content: Text(
                l10n(context).savedQuizProgress,
                style: AppTextStyle.bodyMd.copyWith(color: ctx.textSecondary),
              ),
              actions: [
                Semantics(
                  button: true,
                  label: l10n(context).quizStartOver,
                  child: TextButton(
                    onPressed: () => context.pop(false),
                    child: Text(
                      l10n(context).quizStartOver,
                      style: AppTextStyle.bodyBold.copyWith(
                        color: PremiumColors.error,
                      ),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: l10n(context).quizResumeButton,
                  child: TextButton(
                    onPressed: () => context.pop(true),
                    child: Text(
                      l10n(context).quizResumeButton,
                      style: AppTextStyle.bodyBold.copyWith(
                        color: PremiumColors.primaryAccent,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        if (result == true && mounted) {
          setState(() {
            _currentIndex = savedIndex;
            _correctCount = savedScore;
            _timeRemaining = savedTimeRemaining;
          });
          _quizTimer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (!mounted) {
              t.cancel();
              return;
            }
            if (_timeRemaining <= 0) {
              t.cancel();
              _finishQuiz();
            } else {
              setState(() => _timeRemaining--);
            }
          });
        } else {
          await prefs.remove(_progressKey);
        }
      }
    } catch (e) {
      AppLogger().warning('CyberQuiz: failed to load saved progress: $e');
    }
  }

  Future<void> _clearProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_progressKey);
    } catch (_) {
      AppLogger().warning('CyberQuiz: failed to clear quiz progress');
    }
  }

  Challenge get _question => widget.questions[_currentIndex];
  bool get _isLast => _currentIndex >= widget.questions.length - 1;
  bool get _canCheck =>
      _selectedAnswer >= 0 && _answerState == _AnswerState.idle;
  bool get _isCorrect => _answerState == _AnswerState.correct;

  void _onSelect(int index) {
    if (_answerState != _AnswerState.idle) return;
    setState(() => _selectedAnswer = index);
    ExperienceService.instance.lightHaptic();
  }

  void _onCheck() {
    if (!_canCheck) return;
    // Validate correctIndex is within bounds; clamp if corrupted
    final validCorrectIndex = _question.isCorrectIndexValid
        ? _question.correctIndex
        : 0.clamp(0, _question.options.length - 1);
    final correct = _selectedAnswer == validCorrectIndex;
    setState(() {
      _answerState = correct ? _AnswerState.correct : _AnswerState.incorrect;
      if (correct) _correctCount++;
    });
    if (correct) {
      ExperienceService.instance.mediumHaptic();
      _pulseCtrl.forward(from: 0);
    } else {
      ExperienceService.instance.errorHaptic();
      _shakeCtrl.forward(from: 0);
    }
  }

  void _onContinue() {
    if (_answerState == _AnswerState.idle) return;
    ExperienceService.instance.lightHaptic();
    if (_isLast) {
      _finishQuiz();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = -1;
        _answerState = _AnswerState.idle;
      });
    }
  }

  void _finishQuiz() {
    _quizTimer?.cancel();
    _clearProgress();
    if (_sessionStart == null) return;
    final spent = DateTime.now().difference(_sessionStart!).inSeconds;
    final score = QuizScoreCalculator(
      correctCount: _correctCount,
      totalQuestions: widget.questions.length,
      timeSpentSeconds: spent,
      timeBudgetSeconds: widget.timeBudgetSeconds,
    );
    context.goNamed('quiz-summary', extra: score);
  }

  Future<bool> _onWillPop() async {
    if (_answerState != _AnswerState.idle ||
        _currentIndex > 0 ||
        _selectedAnswer >= 0) {
      final l = l10n(context);
      final result = await showDialog<bool>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            backgroundColor: ctx.surfaceCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            title: Text(
              l.quizAbandonTitle,
              style: AppTextStyle.titleLg.copyWith(color: ctx.textPrimary),
            ),
            content: Text(
              l.quizAbandonContent,
              style: AppTextStyle.bodyMd.copyWith(color: ctx.textSecondary),
            ),
            actions: [
              Semantics(
                button: true,
                label: l.quizAbandonStay,
                child: TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(
                    l.quizAbandonStay,
                    style: AppTextStyle.bodyBold.copyWith(
                      color: PremiumColors.primaryAccent,
                    ),
                  ),
                ),
              ),
              Semantics(
                button: true,
                label: l.quizAbandonExit,
                child: TextButton(
                  onPressed: () => context.pop(true),
                  child: Text(
                    l.quizAbandonExit,
                    style: AppTextStyle.bodyBold.copyWith(
                      color: PremiumColors.error,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
      if (result == true) {
        _clearProgress();
      }
      return result ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: context.surfaceBackground,
        body: SafeArea(
          child: Column(
            children: [
              _HudBar(
                currentIndex: _currentIndex,
                total: widget.questions.length,
                title: widget.lessonTitle,
                onClose: () async {
                  final shouldPop = await _onWillPop();
                  if (shouldPop && context.mounted) context.pop();
                },
                shakeValue: _shakeCtrl,
                timeRemaining: _timeRemaining,
              ),
              Expanded(child: _buildBody()),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final shakeX = sin(_shakeCtrl.value * 6 * pi) * 8 * (1 - _shakeCtrl.value);

    return Transform.translate(
      offset: Offset(shakeX, 0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),
            Text(
              _question.question,
              textAlign: TextAlign.center,
              style: AppTextStyle.headlineMedium.copyWith(
                color: context.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            ...List.generate(_question.options.length, (i) {
              final opt = _question.options[i];
              final isSelected = _selectedAnswer == i;
              final isCorrectAnswer = i == _question.correctIndex;
              Color bgColor;
              Color borderColor;
              Color textColor;
              IconData? icon;

              if (_answerState == _AnswerState.idle) {
                bgColor = isSelected
                    ? PremiumColors.primaryAccent.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.04);
                borderColor = isSelected
                    ? PremiumColors.primaryAccent.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.06);
                textColor = isSelected
                    ? context.textPrimary
                    : context.textSecondary;
                icon = isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded;
              } else {
                if (isCorrectAnswer) {
                  bgColor = PremiumColors.success.withValues(alpha: 0.15);
                  borderColor = PremiumColors.success;
                  textColor = context.textPrimary;
                  icon = Icons.check_circle_rounded;
                } else if (isSelected && !isCorrectAnswer) {
                  bgColor = PremiumColors.error.withValues(alpha: 0.15);
                  borderColor = PremiumColors.error;
                  textColor = context.textPrimary;
                  icon = Icons.cancel_rounded;
                } else {
                  bgColor = Colors.white.withValues(alpha: 0.03);
                  borderColor = Colors.white.withValues(alpha: 0.04);
                  textColor = Colors.white.withValues(alpha: 0.3);
                  icon = Icons.radio_button_unchecked_rounded;
                }
              }

              return Semantics(
                button: true,
                label: opt,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: GestureDetector(
                    onTap: _answerState == _AnswerState.idle
                        ? () => _onSelect(i)
                        : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md + 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        color: bgColor,
                        border: Border.all(
                          color: borderColor,
                          width:
                              _answerState != _AnswerState.idle &&
                                  (isCorrectAnswer ||
                                      (isSelected && !isCorrectAnswer))
                              ? 2.5
                              : 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, size: 22, color: textColor),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              opt,
                              style: AppTextStyle.body.copyWith(
                                color: textColor,
                                height: 1.3,
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
          ],
        ).animate().fadeIn(duration: 200.ms),
      ),
    );
  }

  Widget _buildFooter() {
    final l = l10n(context);
    String label;
    Color bgColor;
    final String? verdictLabel;
    if (_answerState == _AnswerState.idle) {
      label = l.quizCheckAnswer;
      bgColor = PremiumColors.primaryAccent;
      verdictLabel = null;
    } else if (_isCorrect) {
      label = l.quizContinue;
      bgColor = PremiumColors.success;
      verdictLabel = l.quizVerdictCorrect;
    } else {
      label = l.quizContinue;
      bgColor = PremiumColors.error;
      verdictLabel = l.quizVerdictIncorrect;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Live region announcing the correct/incorrect verdict to screen
        // readers. Hidden visually (Opacity 0) but kept in the tree.
        if (verdictLabel != null)
          Semantics(
            liveRegion: true,
            label: verdictLabel,
            child: ExcludeSemantics(
              child: Opacity(
                opacity: 0,
                child: Text(verdictLabel, style: AppTextStyle.caption),
              ),
            ),
          ),
        Semantics(
          container: true,
          button: true,
          label: label,
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.xxl,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: bgColor.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _answerState == _AnswerState.idle
                      ? _onCheck
                      : _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bgColor,
                    disabledBackgroundColor: Colors.white.withValues(
                      alpha: 0.06,
                    ),
                    disabledForegroundColor: Colors.white.withValues(
                      alpha: 0.25,
                    ),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HudBar extends StatelessWidget {
  final int currentIndex;
  final int total;
  final String title;
  final VoidCallback onClose;
  final AnimationController shakeValue;
  final int timeRemaining;

  const _HudBar({
    required this.currentIndex,
    required this.total,
    required this.title,
    required this.onClose,
    required this.shakeValue,
    required this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final l = l10n(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.surfaceCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                button: true,
                label: l.closeButton,
                child: GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.surfaceTinted,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: context.textTertiary,
                    ),
                  ),
                ),
              ),
              Text(
                title,
                style: AppTextStyle.bodyMd.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textSecondary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExcludeSemantics(
                    child: Icon(
                      Icons.timer_rounded,
                      size: 16,
                      color: timeRemaining < _lowTimeThresholdSeconds
                          ? PremiumColors.error
                          : context.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Live region so screen readers announce the remaining time.
                  Semantics(
                    liveRegion: true,
                    label: l10n(context).quizTimeRemaining(
                      '${timeRemaining ~/ 60}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                    ),
                    child: ExcludeSemantics(
                      child: Text(
                        '${timeRemaining ~/ 60}:${(timeRemaining % 60).toString().padLeft(2, '0')}',
                        style: AppTextStyle.bodyMd.copyWith(
                          fontWeight: FontWeight.w600,
                          color: timeRemaining < _lowTimeThresholdSeconds
                              ? PremiumColors.error
                              : context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            label: l10n(context).cyberQuizProgress(currentIndex + 1, total),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(
                  begin: 0,
                  end: total > 0 ? (currentIndex + 1) / total : 0,
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  backgroundColor: context.surfaceTinted,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    PremiumColors.splashBlue,
                  ),
                  minHeight: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
