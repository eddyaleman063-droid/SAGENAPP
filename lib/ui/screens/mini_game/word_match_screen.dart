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

const int _totalPairs = 6;

class WordMatchScreen extends ConsumerStatefulWidget {
  final MiniGameConfig config;
  const WordMatchScreen({super.key, required this.config});

  @override
  ConsumerState<WordMatchScreen> createState() => _WordMatchScreenState();
}

class _WordMatchScreenState extends ConsumerState<WordMatchScreen> {
  List<_MatchItem> _items = [];
  List<(String, String)> _pairs = [];
  int? _selectedTermIndex;
  int? _wrongIndex;
  int _matches = 0;
  int _mistakes = 0;
  bool _gameComplete = false;
  bool _rewarded = false;
  bool _completing = false;
  Timer? _timer;
  int _timeRemaining = 60;

  static List<(String, String)> _buildPairs(AppLocalizations l) => [
    ('Phishing', l.miniGamePhishingDef),
    ('Malware', l.miniGameMalwareDef),
    ('Firewall', l.miniGameFirewallDef),
    (l.miniGameEncryptionTerm, l.miniGameEncryptionDef),
    ('VPN', l.miniGameVpnDef),
    ('Backup', l.miniGameBackupDef),
  ];

  @override
  void initState() {
    super.initState();
    // Will be initialized in didChangeDependencies when context is available
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_items.isEmpty) {
      final l = AppLocalizations.of(context)!;
      _initGame(_buildPairs(l));
    }
  }

  void _initGame(List<(String, String)> pairs) {
    _timer?.cancel();
    _pairs = pairs;
    final terms = pairs.map((p) => p.$1).toList();
    final definitions = pairs.map((p) => p.$2).toList();
    terms.shuffle(Random());
    definitions.shuffle(Random());

    _items = [
      ...terms.map((t) => _MatchItem(text: t, isTerm: true)),
      ...definitions.map((d) => _MatchItem(text: d, isTerm: false)),
    ]..shuffle(Random());

    _selectedTermIndex = null;
    _matches = 0;
    _mistakes = 0;
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
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTap(int index) {
    if (_gameComplete || _items[index].matched) return;
    ExperienceService.instance.lightHaptic();

    setState(() {
      if (_items[index].isTerm) {
        _selectedTermIndex = index;
      } else if (_selectedTermIndex != null) {
        final termItem = _items[_selectedTermIndex!];
        final isCorrect = _checkMatch(termItem.text, _items[index].text);
        if (isCorrect) {
          _items[_selectedTermIndex!].matched = true;
          _items[index].matched = true;
          _matches++;
          if (_matches == _totalPairs) {
            _timer?.cancel();
            _completeGame();
          }
        } else {
          _mistakes++;
          _wrongIndex = index;
          ExperienceService.instance.errorHaptic();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _wrongIndex = null);
          });
        }
        _selectedTermIndex = null;
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
      final xp = _matches * 15;
      await ref.read(learningProvider.notifier).addXp(xp, reason: 'mini_game');
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

  bool _checkMatch(String term, String definition) {
    for (final pair in _pairs) {
      if (pair.$1 == term && pair.$2 == definition) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return ExitConfirmationWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.miniGameWord),
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
                          label: l.miniGameMatches,
                          value: '$_matches/$_totalPairs',
                        ),
                        StatChip(
                          label: l.miniGameMistakes,
                          value: '$_mistakes',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.5,
                          ),
                      itemCount: _items.length,
                      itemBuilder: (ctx, i) => _buildItem(i),
                    ).animate().fadeIn(duration: 300.ms),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final isSelected = _selectedTermIndex == index;
    final isWrong = _wrongIndex == index;
    return Semantics(
      button: true,
      selected: isSelected,
      label: item.text,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          _onItemTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: item.matched
                ? PremiumColors.success.withValues(alpha: 0.15)
                : isWrong
                ? PremiumColors.error.withValues(alpha: 0.15)
                : isSelected
                ? PremiumColors.primary.withValues(alpha: 0.2)
                : context.surfaceTinted,
            border: Border.all(
              color: item.matched
                  ? PremiumColors.success
                  : isWrong
                  ? PremiumColors.error
                  : isSelected
                  ? PremiumColors.primary
                  : context.borderSubtle,
            ),
          ),
          child: Center(
            child: Text(
              item.text,
              textAlign: TextAlign.center,
              style: AppTextStyle.subtitle.copyWith(
                fontWeight: item.isTerm ? FontWeight.w600 : FontWeight.normal,
                color: item.matched
                    ? PremiumColors.success
                    : context.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResult(AppLocalizations l) {
    final xp = _matches * 15;
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
                    _matches >= _totalPairs
                        ? Icons.emoji_events_rounded
                        : Icons.star_rounded,
                    size: 64,
                    color: _matches >= _totalPairs
                        ? PremiumColors.accentYellow
                        : PremiumColors.primary,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _matches >= _totalPairs ? l.miniGameComplete : l.miniGameOver,
            style: AppTextStyle.headline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l.miniGameMatches}: $_matches/$_totalPairs  |  ${l.miniGameMistakes}: $_mistakes',
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
              tween: IntTween(begin: 0, end: xp),
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
                      '$value XP',
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
                setState(() => _initGame(_pairs));
              },
              child: Text(l.miniGamePlayAgain),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchItem {
  final String text;
  final bool isTerm;
  bool matched = false;
  _MatchItem({required this.text, required this.isTerm});
}
