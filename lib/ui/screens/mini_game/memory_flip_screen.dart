import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/mini_game.dart';
import 'package:sagen/providers/learning_provider.dart';
import 'package:sagen/ui/widgets/mini_game/mini_game_shared_widgets.dart';
import 'package:sagen/ui/widgets/common/confetti_widget.dart';

class MemoryFlipScreen extends ConsumerStatefulWidget {
  final MiniGameConfig config;
  const MemoryFlipScreen({super.key, required this.config});

  @override
  ConsumerState<MemoryFlipScreen> createState() => _MemoryFlipScreenState();
}

class _MemoryFlipScreenState extends ConsumerState<MemoryFlipScreen> {
  late List<String> _cards;
  late List<bool> _flipped;
  late List<bool> _matched;
  int? _firstFlippedIndex;
  int _moves = 0;
  int _matches = 0;
  bool _gameComplete = false;
  bool _rewarded = false;
  bool _completing = false;
  Timer? _timer;
  int _timeRemaining = 60;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _timer?.cancel();
    final pairs = ['lock', 'shield', 'key', 'eye', 'bug', 'globe'];
    _cards = [...pairs, ...pairs]..shuffle(Random());
    _flipped = List.filled(12, false);
    _matched = List.filled(12, false);
    _firstFlippedIndex = null;
    _moves = 0;
    _matches = 0;
    _gameComplete = false;
    _rewarded = false;
    _timeRemaining = widget.config.timeLimit.inSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_timeRemaining <= 0) {
        t.cancel();
        _completeGame();
      } else {
        setState(() => _timeRemaining--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _completeGame() async {
    setState(() {
      _gameComplete = true;
      _completing = true;
    });
    if (!_rewarded) {
      _rewarded = true;
      final xp = _matches * 10;
      await ref.read(learningProvider.notifier).addXp(xp, reason: 'mini_game');
      if (!mounted) return;
      setState(() { _completing = false; });
    } else {
      setState(() { _completing = false; });
    }
  }

  void _onCardTap(int index) {
    if (_gameComplete || _flipped[index] || _matched[index]) return;
    if (_firstFlippedIndex != null && index == _firstFlippedIndex) return;

    ExperienceService.instance.lightHaptic();
    setState(() {
      _flipped[index] = true;
      if (_firstFlippedIndex == null) {
        _firstFlippedIndex = index;
      } else {
        _moves++;
        if (_cards[_firstFlippedIndex!] == _cards[index]) {
          _matched[_firstFlippedIndex!] = true;
          _matched[index] = true;
          _matches++;
          _firstFlippedIndex = null;
          if (_matches == 6) {
            _timer?.cancel();
            _completeGame();
          }
        } else {
          final first = _firstFlippedIndex!;
          _firstFlippedIndex = null;
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _flipped[first] = false;
                _flipped[index] = false;
              });
            }
          });
        }
      }
    });
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'lock': return Icons.lock_rounded;
      case 'shield': return Icons.shield_rounded;
      case 'key': return Icons.key_rounded;
      case 'eye': return Icons.visibility_rounded;
      case 'bug': return Icons.bug_report_rounded;
      case 'globe': return Icons.language_rounded;
      default: return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l.miniGameExitTitle),
            content: Text(l.miniGameExitContent),
            actions: [
              TextButton(onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(ctx); }, child: Text(l.cancel)),
              TextButton(
                onPressed: () { HapticFeedback.lightImpact(); Navigator.pop(ctx); Navigator.pop(context); },
                child: Text(l.exitText),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(l.miniGameMemory),
        actions: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(children: [
              Icon(Icons.timer_rounded, size: 18, color: _timeRemaining < 10 ? PremiumColors.error : context.textPrimary),
              const SizedBox(width: AppSpacing.xxs),
              Text('$_timeRemaining', style: AppTextStyle.titleSmall.copyWith(fontWeight: FontWeight.bold, color: context.textPrimary)),
            ]),
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
                      StatChip(label: l.miniGameMoves, value: '$_moves'),
                      StatChip(label: l.miniGameMatches, value: '$_matches/6'),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 8, crossAxisSpacing: 8),
                    itemCount: 12,
                    itemBuilder: (ctx, i) => _buildCard(i),
                  ).animate().fadeIn(duration: 300.ms),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildCard(int index) {
    final isRevealed = _flipped[index] || _matched[index];
    return Semantics(
      button: true,
      label: isRevealed ? _cards[index] : AppLocalizations.of(context)!.miniGameHiddenCard,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onCardTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: _matched[index]
                ? PremiumColors.success.withValues(alpha: 0.2)
                : isRevealed
                    ? context.surfaceTinted
                    : PremiumColors.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: _matched[index] ? PremiumColors.success : PremiumColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isRevealed
                  ? Icon(_iconFor(_cards[index]), key: ValueKey('revealed_$index'), size: 32, color: PremiumColors.primary)
                  : Icon(Icons.question_mark_rounded, key: ValueKey('hidden_$index'), size: 24, color: context.textTertiary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppLocalizations l) {
    final xp = _matches * 10;
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
                ExcludeSemantics(child: Icon(_matches >= 6 ? Icons.emoji_events_rounded : Icons.star_rounded, size: 64, color: _matches >= 6 ? PremiumColors.accentYellow : PremiumColors.primary)).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(_matches >= 6 ? l.miniGameComplete : l.miniGameOver, style: AppTextStyle.headline),
          const SizedBox(height: AppSpacing.sm),
          Text('${l.miniGameMoves}: $_moves', style: AppTextStyle.body.copyWith(color: context.textSecondary)),
          const SizedBox(height: AppSpacing.lg),
          if (_completing)
            const Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else ...[
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: xp),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOut,
              builder: (context, value, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.pill), gradient: const LinearGradient(colors: [PremiumColors.primary, PremiumColors.primaryAccent])),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const ExcludeSemantics(child: Icon(Icons.star_rounded, size: 18, color: Colors.white)),
                  const SizedBox(width: AppSpacing.xs),
                  Text('$value XP', style: AppTextStyle.bodyBold.copyWith(color: Colors.white)),
                ]),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Semantics(
            button: true,
            label: l.miniGamePlayAgain,
            child: FilledButton(onPressed: () { HapticFeedback.lightImpact(); setState(() => _initGame()); }, child: Text(l.miniGamePlayAgain)),
          ),
        ],
      ),
    );
  }
}


