import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../models/learning/challenge.dart';
import '../../../models/learning/lesson_type.dart';
import 'package:sagen/providers/providers.dart';
import '../../../services/experience_service.dart';
import '../../../services/question_bank.dart';
import '../../../services/sage_emotion_service.dart';
import '../../../ui/widgets/common/ambient_background.dart';
import '../../../ui/widgets/common/sage_emotion_widget.dart';
import 'package:sagen/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with TickerProviderStateMixin {
  List<Challenge> _questions = [];
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  bool _completed = false;
  int _correctCount = 0;

  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late AnimationController _streakCtrl;
  late Animation<double> _streakGlow;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.normal,
    );
    _fadeAnim = CurvedAnimation(parent: _entryCtrl, curve: AppEasing.entrance);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryCtrl,
      curve: AppEasing.entrance,
    ));
    _streakCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _streakGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _streakCtrl, curve: Curves.easeOut),
    );
    _loadQuestions();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _streakCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final review = ref.read(reviewProvider.notifier);
    final ids = review.failedQuestionIds;
    final bank = QuestionBank.instance;
    try {
      final allQuestions = await bank.getByIds(ids);
      if (!mounted) return;
      final questions = allQuestions.take(5).toList();
      setState(() => _questions = questions);
      if (questions.isNotEmpty) _entryCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _questions = []);
    }
  }

  Challenge get _current => _questions[_currentIndex];

  String get _currentTopic {
    final review = ref.read(reviewProvider.notifier);
    return review.getTopicForQuestion(_current.id) ?? '';
  }

  void _selectOption(int index) {
    if (_showResult) return;
    ExperienceService.instance.lightHaptic();
    final correct = index == _current.correctIndex;
    setState(() {
      _selectedOption = index;
      _showResult = true;
      if (correct) _correctCount++;
    });
    if (correct) {
      _streakCtrl.forward(from: 0.0);
      ref.read(reviewProvider.notifier).recordCorrect(_current.id);
    }
  }

  Future<void> _next() async {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _showResult = false;
      });
      _entryCtrl.reset();
      _entryCtrl.forward();
    } else {
      final review = ref.read(reviewProvider.notifier);
      review.markReviewCompleted();
      await ref.read(learningProvider.notifier).addXp(Math.min(_correctCount * 5, 25), reason: 'review');
      ref.read(gemProvider.notifier).awardReviewGems();
      if (!mounted) return;
      setState(() => _completed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    if (_questions.isEmpty) {
      return AmbientBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: context.textSecondary,
            title: Text(l.reviewTitle, style: AppTextStyle.title),
            centerTitle: true,
            leading: Semantics(
              button: true,
              label: l.closeButton,
              child: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  ExperienceService.instance.lightHaptic();
                  context.pop();
                },
                tooltip: l.closeButton,
              ),
            ),
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SageEmotionWidget(
                  emotion: SageEmotion.calm,
                  size: 64,
                  animated: true,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l.reviewNoErrors,
                  style: AppTextStyle.body.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l.reviewKeepGoing,
                  style: AppTextStyle.caption.copyWith(
                    color: context.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_completed) {
      return _buildResult(context, l);
    }

    final accuracy = _questions.isEmpty
        ? 1.0
        : _correctCount / ((_currentIndex + (_showResult ? 1 : 0)).clamp(1, 9999));
    final sageEmotion = accuracy >= 0.8
        ? SageEmotion.excited
        : accuracy >= 0.5
            ? SageEmotion.happy
            : SageEmotion.calm;

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: context.textSecondary,
          title: Text(
            '${_currentIndex + 1} / ${_questions.length}',
            style: AppTextStyle.label,
          ),
          centerTitle: true,
          leading: Semantics(
            button: true,
            label: l.closeButton,
            child: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () {
                ExperienceService.instance.lightHaptic();
                context.pop();
              },
              tooltip: l.closeButton,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Semantics(
              label: l.questionProgress(_currentIndex + 1, _questions.length),
              child: LinearProgressIndicator(
                value: (_currentIndex + 1) / _questions.length,
                backgroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                valueColor: const AlwaysStoppedAnimation(PremiumColors.primary),
              ),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _current.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          _currentTopic.isNotEmpty ? _currentTopic : _current.type.label,
                          style: AppTextStyle.tiny.copyWith(
                            color: _current.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      SageEmotionWidget(
                        emotion: sageEmotion,
                        size: 32,
                        animated: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    _current.question,
                    style: AppTextStyle.question.copyWith(
                      color: context.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AnimatedBuilder(
                    animation: _streakGlow,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: _streakGlow.value > 0.01
                              ? [
                                  BoxShadow(
                                    color: PremiumColors.success
                                        .withValues(alpha: 0.15 * _streakGlow.value),
                                    blurRadius: 20 * _streakGlow.value,
                                    spreadRadius: 2 * _streakGlow.value,
                                  ),
                                ]
                              : null,
                        ),
                        child: child,
                      );
                    },
                    child: Column(
                      children: _current.options.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final opt = entry.value;
                        Color? bgColor;
                        Color? borderColor;

                        if (_showResult) {
                          if (idx == _current.correctIndex) {
                            bgColor = PremiumColors.success.withValues(alpha: 0.1);
                            borderColor = PremiumColors.success;
                          } else if (idx == _selectedOption &&
                              _selectedOption != _current.correctIndex) {
                            bgColor = PremiumColors.error.withValues(alpha: 0.1);
                            borderColor = PremiumColors.error;
                          }
                        }

                        return Semantics(
                          button: true,
                          label: opt,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                onTap: _showResult ? null : () => _selectOption(idx),
                                child: AnimatedContainer(
                                duration: AppMotion.fast,
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: BoxDecoration(
                                  color: bgColor ??
                                      context.surfaceCard,
                                  borderRadius: BorderRadius.circular(AppRadius.lg),
                                  border: Border.all(
                                    color: borderColor ??
                                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.15),
                                    width: borderColor != null ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: _selectedOption == idx
                                            ? (_showResult && idx == _current.correctIndex
                                                ? PremiumColors.success
                                                : _showResult && idx != _current.correctIndex
                                                    ? PremiumColors.error
                                                    : PremiumColors.primary)
                                            :                                         Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(AppRadius.sm),
                                      ),
                                      child: Center(
                                        child: _showResult && idx == _current.correctIndex
                                            ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                            : _showResult && idx == _selectedOption
                                                ? const Icon(Icons.close_rounded, color: Colors.white, size: 16)
                                                : Text('${idx + 1}',
                                                    style: AppTextStyle.caption.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                       color: _selectedOption == idx ? Colors.white : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                                                    )),
                                      ),
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
                        ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (_showResult) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: _selectedOption == _current.correctIndex
                            ? PremiumColors.success.withValues(alpha: 0.08)
                            : PremiumColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _selectedOption == _current.correctIndex
                                ? Icons.check_circle_rounded
                                : Icons.info_rounded,
                            color: _selectedOption == _current.correctIndex
                                ? PremiumColors.success
                                : PremiumColors.error,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _current.explanation,
                              style: AppTextStyle.subtitle.copyWith(
                                height: 1.4,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      button: true,
                      label: _currentIndex < _questions.length - 1 ? l.nextText : l.reviewFinish,
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                          child: ElevatedButton.icon(
                          onPressed: () {
                            ExperienceService.instance.lightHaptic();
                            _next();
                          },
                          icon: Icon(
                            _currentIndex < _questions.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.check_rounded,
                            size: 18,
                          ),
                          label: Text(
                            _currentIndex < _questions.length - 1
                                ? l.nextText
                                : l.reviewFinish,
                            style: AppTextStyle.bodyBold,
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
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context, AppLocalizations l) {
    final xpEarned = Math.min(_correctCount * 5, 25);

    SageEmotion emotion;
    String title;
    String sageMessage;

    if (_correctCount == _questions.length) {
      emotion = SageEmotion.excitedWave;
      title = l.reviewComplete;
      sageMessage = l.reviewSagePerfect;
    } else if (_correctCount >= (_questions.length / 2).ceil()) {
      emotion = SageEmotion.happy;
      title = l.reviewGoodProgress;
      sageMessage = l.reviewSageGood;
    } else {
      emotion = SageEmotion.calm;
      title = l.reviewKeepPracticing;
      sageMessage = l.reviewSageKeep;
    }

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SageEmotionWidget(emotion: emotion, size: 80, animated: true),
                  const SizedBox(height: AppSpacing.xl),
                  Text(title,
                      style: AppTextStyle.display.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: AppSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Text(
                      sageMessage,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.subtitle.copyWith(
                    color: context.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: PremiumColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$_correctCount / ${_questions.length}',
                          style: AppTextStyle.cardTitle.copyWith(
                            color: PremiumColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(l.reviewCorrect,
                            style: AppTextStyle.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    label: l.xpGainedLabel(xpEarned),
                    container: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            size: 18, color: PremiumColors.primary),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          '+$xpEarned XP',
                          style: AppTextStyle.cardTitle.copyWith(
                            color: PremiumColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Semantics(
                    button: true,
                    label: l.back,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                onPressed: () => context.pop(),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: Text(l.back, style: AppTextStyle.bodyBold),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PremiumColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          elevation: 0,
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

/// Minimal clamp utility to avoid importing dart:math.
class Math {
  static int min(int a, int b) => a < b ? a : b;
}
