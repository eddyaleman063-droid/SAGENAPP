import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/models/learning/challenge.dart';
import 'package:sagen/models/learning/quiz_result.dart';
import 'package:sagen/models/learning/quiz_score.dart';
import 'package:sagen/models/special_item.dart';
import '../common/localization_helper.dart';
import 'package:sagen/services/app_logger.dart';
import 'package:sagen/ui/widgets/learning/quiz_progress_header.dart';
import 'package:sagen/ui/widgets/learning/quiz_question_card.dart';
import 'package:sagen/ui/widgets/learning/quiz_option_button.dart';
import 'package:sagen/ui/widgets/learning/quiz_feedback_card.dart';

export 'package:sagen/models/learning/quiz_result.dart' show QuizResult;

class QuizSession extends ConsumerStatefulWidget {
  final List<Challenge> challenges;
  final String stageId;
  final String lessonId;
  final String lessonTitle;
  final ValueChanged<QuizResult> onComplete;

  const QuizSession({
    super.key,
    required this.challenges,
    required this.stageId,
    required this.lessonId,
    required this.lessonTitle,
    required this.onComplete,
  });

  @override
  ConsumerState<QuizSession> createState() => _QuizSessionState();
}

class _QuizSessionState extends ConsumerState<QuizSession>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int _correctCount = 0;
  int? _selectedIndex;
  bool _answered = false;
  bool _monocleUsed = false;
  late final DateTime _startTime;
  late AnimationController _feedbackCtrl;
  late Animation<double> _feedbackAnim;
  late AnimationController _questionCtrl;
  late Animation<double> _questionSlide;
  late AnimationController _optionCtrl;
  late Animation<double> _optionStagger;

  static const _prefix = 'quiz_progress_';

  Challenge get _current => widget.challenges[_currentIndex];
  bool get _isLast => _currentIndex >= widget.challenges.length - 1;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    _feedbackCtrl = AnimationController(vsync: this, duration: AppMotion.fast);
    _feedbackAnim = CurvedAnimation(
      parent: _feedbackCtrl,
      curve: AppEasing.entrance,
    );
    _questionCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );
    _questionSlide = Tween<double>(begin: 0.08, end: 0.0).animate(
      CurvedAnimation(parent: _questionCtrl, curve: AppEasing.entrance),
    );
    _optionCtrl = AnimationController(vsync: this, duration: AppMotion.normal);
    _optionStagger = CurvedAnimation(
      parent: _optionCtrl,
      curve: AppEasing.entrance,
    );
    _loadProgress();
    _questionCtrl.forward();
    _optionCtrl.forward();
  }

  String get _progressKey => '$_prefix${widget.lessonId}';

  Future<void> _saveProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      final ids = widget.challenges.map((c) => c.id).toList();
      await prefs.setStringList(_progressKey, [
        widget.stageId,
        _currentIndex.toString(),
        _correctCount.toString(),
        ids.join(','),
        DateTime.now().toIso8601String(),
      ]);
    } catch (e) {
      AppLogger().warning('QuizSession._saveProgress failed: $e');
    }
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      final data = prefs.getStringList(_progressKey);
      if (data == null || data.length < 5) return;
      final savedStageId = data[0];
      final savedIndex = int.tryParse(data[1]) ?? 0;
      final savedCorrect = int.tryParse(data[2]) ?? 0;
      final savedIds = data[3].split(',');
      final savedTime = DateTime.tryParse(data[4]);
      if (savedStageId != widget.stageId) return;
      if (savedTime != null &&
          DateTime.now().difference(savedTime).inMinutes > 30) {
        await _clearProgress();
        return;
      }
      final currentIds = widget.challenges.map((c) => c.id).toList();
      if (savedIds.length != currentIds.length) return;
      for (int i = 0; i < savedIds.length; i++) {
        if (savedIds[i] != currentIds[i]) return;
      }
      if (savedIndex > 0 && savedIndex < widget.challenges.length) {
        if (!mounted) return;
        setState(() {
          _currentIndex = savedIndex;
          _correctCount = savedCorrect;
        });
      }
    } catch (e) {
      AppLogger().warning('QuizSession._loadProgress failed: $e');
    }
  }

  Future<void> _clearProgress() async {
    try {
      final prefs = ref.read(prefsProvider);
      await prefs.remove(_progressKey);
    } catch (e) {
      AppLogger().warning('QuizSession._clearProgress failed: $e');
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    _questionCtrl.dispose();
    _optionCtrl.dispose();
    super.dispose();
  }

  void _selectAnswer(int index) {
    if (_answered) return;
    // Validate correctIndex is within bounds; clamp if corrupted
    final validCorrectIndex = _current.isCorrectIndexValid
        ? _current.correctIndex
        : 0.clamp(0, _current.options.length - 1);
    final correct = index == validCorrectIndex;
    ExperienceService.instance.mediumHaptic();
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (correct) _correctCount++;
    });
    _saveProgress();
    _feedbackCtrl.forward();
    if (!correct) {
      ExperienceService.instance.errorHaptic();
      try {
        final learning = ref.read(learningProvider);
        final stage = learning.stages
            .where((s) => s.id == widget.stageId)
            .firstOrNull;
        if (stage == null) return;
        ref
            .read(reviewProvider.notifier)
            .recordMistake(_current.id, stage.title);
      } catch (e) {
        AppLogger().error('QuizSession: failed to record mistake', e);
      }
    }
  }

  List<int> _getMonocleFilteredIndices() {
    if (!_monocleUsed) return List.generate(_current.options.length, (i) => i);
    final validCorrectIndex = _current.isCorrectIndexValid
        ? _current.correctIndex
        : 0.clamp(0, _current.options.length - 1);
    final wrongIndices = <int>[];
    for (int i = 0; i < _current.options.length; i++) {
      if (i != validCorrectIndex) wrongIndices.add(i);
    }
    wrongIndices.shuffle();
    final removeCount = wrongIndices.length >= 2 ? 2 : wrongIndices.length;
    final removed = wrongIndices.take(removeCount).toSet();
    return <int>[
      for (int i = 0; i < _current.options.length; i++)
        if (!removed.contains(i)) i,
    ];
  }

  void _useMonocle() {
    if (_monocleUsed || _answered) return;
    final items = ref.read(itemProvider.notifier);
    if (!items.hasItem(SpecialItemType.sageMonocle)) return;
    items.consumeItem(SpecialItemType.sageMonocle);
    setState(() => _monocleUsed = true);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _feedbackCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
        _monocleUsed = false;
      });
      _saveProgress();
      _optionCtrl.reset();
      _questionCtrl.reset();
      _questionCtrl.forward();
      _optionCtrl.forward();
    });
  }

  void _finish() {
    _clearProgress();
    final timeTaken = DateTime.now().difference(_startTime);
    final total = widget.challenges.length;
    final correct = _correctCount;

    final score = QuizScoreCalculator(
      correctCount: correct,
      totalQuestions: total,
      timeSpentSeconds: timeTaken.inSeconds,
    );

    widget.onComplete(
      QuizResult(
        totalQuestions: total,
        correctAnswers: correct,
        xpEarned: score.xp,
        perfect: score.isPerfect,
        timeTaken: timeTaken,
        stageId: widget.stageId,
        lessonId: widget.lessonId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.challenges.isEmpty
        ? 1.0
        : (_currentIndex / widget.challenges.length).clamp(0.0, 1.0);

    return Column(
      children: [
        QuizProgressHeader(
          current: _currentIndex + 1,
          total: widget.challenges.length,
          progress: progress,
          title: widget.lessonTitle,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.sm,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedBuilder(
                  animation: _questionSlide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * _questionSlide.value),
                      child: Opacity(
                        opacity: 1.0 - _questionSlide.value,
                        child: child,
                      ),
                    );
                  },
                  child: QuizQuestionCard(
                    challenge: _current,
                    index: _currentIndex,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Sage Monocle button — visible when user owns monocles
                if (!_answered &&
                    !_monocleUsed &&
                    ref
                        .read(itemProvider.notifier)
                        .hasItem(SpecialItemType.sageMonocle))
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _useMonocle,
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: Text(
                          AppLocalizations.of(context)!.sageMonocleButton,
                          style: AppTextStyle.label,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PremiumColors.premiumBlue,
                          side: BorderSide(
                            color: PremiumColors.premiumBlue.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                if (_monocleUsed && !_answered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PremiumColors.premiumBlue.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xxl),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.visibility_rounded,
                              size: 16,
                              color: PremiumColors.premiumBlue,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              AppLocalizations.of(context)!.sageMonocleActive,
                              style: AppTextStyle.label.copyWith(
                                color: PremiumColors.premiumBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ...List.generate(_current.options.length, (i) {
                  final visibleIndices = _getMonocleFilteredIndices();
                  if (!visibleIndices.contains(i)) {
                    return const SizedBox.shrink();
                  }
                  return AnimatedBuilder(
                    animation: _optionStagger,
                    builder: (context, child) {
                      final delay = (i * 0.12).clamp(0.0, 1.0);
                      final slideProgress =
                          ((_optionStagger.value - delay) / (1.0 - delay))
                              .clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, 12 * (1.0 - slideProgress)),
                        child: Opacity(opacity: slideProgress, child: child),
                      );
                    },
                    child: QuizOptionButton(
                      index: i,
                      text: _current.options[i],
                      selected: _selectedIndex == i,
                      correct: _current.correctIndex == i,
                      revealed: _answered,
                      onTap: () => _selectAnswer(i),
                    ),
                  );
                }),
                if (_answered) ...[
                  FadeTransition(
                    opacity: _feedbackAnim,
                    child: QuizFeedbackCard(
                      correct: _selectedIndex == _current.correctIndex,
                      explanation: _current.explanation,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Semantics(
                      button: true,
                      label: _isLast
                          ? l10n(context).firstLessonSeeResults
                          : l10n(context).nextText,
                      child: ElevatedButton.icon(
                        onPressed: _next,
                        icon: Icon(
                          _isLast
                              ? Icons.check_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                        label: Text(
                          _isLast
                              ? l10n(context).firstLessonSeeResults
                              : l10n(context).nextText,
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
