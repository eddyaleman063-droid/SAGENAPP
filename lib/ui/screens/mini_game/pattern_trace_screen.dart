import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import '../../widgets/common/exit_confirmation_wrapper.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/providers/learning_provider.dart';
import 'package:sagen/ui/widgets/mini_game/mini_game_shared_widgets.dart';
import 'package:sagen/ui/widgets/common/confetti_widget.dart';

class PatternTraceScreen extends ConsumerStatefulWidget {
  final MiniGameConfig config;
  const PatternTraceScreen({super.key, required this.config});

  @override
  ConsumerState<PatternTraceScreen> createState() => _PatternTraceScreenState();
}

class _PatternTraceScreenState extends ConsumerState<PatternTraceScreen> {
  late List<int> _pattern;
  late List<int> _userInput;
  int _round = 0;
  final int _maxRounds = 5;
  bool _showingPattern = false;
  bool _gameComplete = false;
  bool _rewarded = false;
  bool _completing = false;
  bool _waitingForInput = false;
  int? _highlightedIndex;
  Timer? _timer;
  int _timeRemaining = 60;
  int _score = 0;

  Timer? _patternTimer;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _patternTimer?.cancel();
    super.dispose();
  }

  void _initGame() {
    _timer?.cancel();
    _patternTimer?.cancel();
    _round = 0;
    _score = 0;
    _gameComplete = false;
    _rewarded = false;
    _timeRemaining = widget.config.timeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_timeRemaining <= 0) {
        t.cancel();
        _completeGame();
      } else {
        setState(() => _timeRemaining--);
      }
    });
    _startRound();
  }

  void _startRound() {
    final length = min(3 + _round, 9);
    _pattern = List.generate(length, (i) => i)..shuffle(Random());
    _userInput = [];
    _showingPattern = true;
    _waitingForInput = false;
    _showPatternSequence();
  }

  void _showPatternSequence() {
    int i = 0;
    _patternTimer?.cancel();
    _patternTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (i >= _pattern.length) {
        t.cancel();
        setState(() {
          _showingPattern = false;
          _waitingForInput = true;
        });
        return;
      }
      setState(() => _highlightedIndex = _pattern[i]);
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _highlightedIndex = null);
      });
      i++;
    });
  }

  void _onDotTap(int index) {
    if (!_waitingForInput || _gameComplete) return;
    ExperienceService.instance.lightHaptic();

    setState(() {
      _userInput.add(index);
      final currentStep = _userInput.length - 1;

      if (_userInput[currentStep] != _pattern[currentStep]) {
        _waitingForInput = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _completeGame();
        });
        return;
      }

      if (_userInput.length == _pattern.length) {
        _score += _round * 10;
        _round++;
        _waitingForInput = false;
        if (_round >= _maxRounds) {
          _timer?.cancel();
          _completeGame();
        } else {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) _startRound();
          });
        }
      }
    });
  }

  Future<void> _completeGame() async {
    setState(() {
      _gameComplete = true;
      _completing = true;
    });
    if (!_rewarded) {
      _rewarded = true;
      await ref
          .read(learningProvider.notifier)
          .addXp(_score, reason: 'mini_game');
      if (!mounted) return;
      setState(() {
        _completing = false;
      });
    } else {
      setState(() {
        _completing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ExitConfirmationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.miniGamePattern),
          actions: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 18,
                    color: _timeRemaining < 10
                        ? PremiumColors.error
                        : context.textPrimary,
                  ),
                  const SizedBox(width: AppSpacing.xxs),
                  Text(
                    '$_timeRemaining',
                    style: AppTextStyle.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _gameComplete
            ? _buildResult(l)
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatChip(
                          label: l.miniGameRound,
                          value: '${_round + 1}/$_maxRounds',
                        ),
                        StatChip(label: l.miniGameScore, value: '$_score'),
                        if (_showingPattern)
                          StatChip(label: l.miniGameWatch, value: ''),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 280,
                        height: 280,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                              ),
                          itemCount: 9,
                          itemBuilder: (ctx, i) => _buildDot(i),
                        ),
                      ),
                    ),
                  ),
                  if (_waitingForInput)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        '${l.miniGameYourTurn} (${_userInput.length}/${_pattern.length})',
                        style: AppTextStyle.body.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ).animate().fadeIn(duration: 300.ms),
      ),
    );
  }

  Widget _buildDot(int index) {
    final isHighlighted = _highlightedIndex == index;
    final isCompleted = _userInput.contains(index);
    return Semantics(
      button: true,
      label: AppLocalizations.of(context)!.dot(index + 1),
      child: GestureDetector(
        onTap: () => _onDotTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isHighlighted
                ? PremiumColors.primary
                : isCompleted
                ? PremiumColors.primary.withValues(alpha: 0.3)
                : context.surfaceTinted,
            border: Border.all(
              color: isHighlighted
                  ? PremiumColors.primary
                  : context.borderSubtle,
              width: isHighlighted ? 3 : 1,
            ),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: PremiumColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const ConfettiWidget(type: ConfettiType.level),
                ExcludeSemantics(
                  child: Icon(
                    _score >= 40
                        ? Icons.emoji_events_rounded
                        : Icons.star_rounded,
                    size: 64,
                    color: _score >= 40
                        ? PremiumColors.accentYellow
                        : PremiumColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _round >= _maxRounds ? l.miniGameComplete : l.miniGameOver,
            style: AppTextStyle.headline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l.miniGameScore}: $_score',
            style: AppTextStyle.body.copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_completing)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: ExcludeSemantics(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: _score),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              builder: (context, value, _) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  gradient: const LinearGradient(
                    colors: [
                      PremiumColors.primary,
                      PremiumColors.primaryAccent,
                    ],
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      l.xpValue(value),
                      style: AppTextStyle.bodyBold.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Semantics(
            button: true,
            label: l.miniGamePlayAgain,
            child: FilledButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _initGame());
              },
              child: Text(l.miniGamePlayAgain),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }
}
