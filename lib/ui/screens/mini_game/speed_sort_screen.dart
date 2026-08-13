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
import 'package:sagen/ui/widgets/common/confetti_widget.dart';

class SpeedSortScreen extends ConsumerStatefulWidget {
  final MiniGameConfig config;
  const SpeedSortScreen({super.key, required this.config});

  @override
  ConsumerState<SpeedSortScreen> createState() => _SpeedSortScreenState();
}

class _SpeedSortScreenState extends ConsumerState<SpeedSortScreen> {
  late List<_SortItem> _items;
  int _correct = 0;
  int _mistakes = 0;
  bool _gameComplete = false;
  bool _rewarded = false;
  bool _completing = false;
  Timer? _timer;
  int _timeRemaining = 45;

  Map<String, List<String>> _buildCategoryValues(AppLocalizations l) => {
    l.speedSortScamCategory: [
      l.speedSortFakeEmail,
      l.speedSortFraudulentCall,
      l.speedSortSmsLink,
    ],
    l.speedSortSecurityCategory: [
      l.speedSortStrongPassword,
      l.speedSort2fa,
      l.speedSortDataEncryption,
    ],
    l.speedSortProtectionCategory: [
      l.speedSortFirewall,
      l.speedSortVpn,
      l.speedSortAntivirus,
    ],
  };

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _timer?.cancel();
    final random = Random();
    final categories = _buildCategoryValues(AppLocalizations.of(context)!);
    final entries = categories.entries.toList()..shuffle(random);
    final selectedCategory = entries.first;
    final correctItems = List<String>.from(selectedCategory.value)
      ..shuffle(random);
    final wrongCategory = entries[1];
    final wrongItem =
        wrongCategory.value[random.nextInt(wrongCategory.value.length)];

    _items = [
      ...correctItems.map(
        (text) => _SortItem(
          text: text,
          category: selectedCategory.key,
          isCorrect: true,
        ),
      ),
      _SortItem(
        text: wrongItem,
        category: selectedCategory.key,
        isCorrect: false,
      ),
    ]..shuffle(random);

    _correct = 0;
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

  void _onSort(int index, bool accept) {
    if (_gameComplete || _items[index].sorted) return;
    ExperienceService.instance.lightHaptic();

    setState(() {
      if (accept == _items[index].isCorrect) {
        _items[index].sorted = true;
        _items[index].accepted = accept;
        _correct++;
        if (_correct >= 3) {
          _timer?.cancel();
          _completeGame();
        }
      } else {
        _mistakes++;
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
      final xp = _correct * 20;
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
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(ctx);
                },
                child: Text(l.cancel),
              ),
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
        appBar: AppBar(
          title: Text(l.miniGameSpeed),
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
                    child: Text(
                      l.miniGameSortInstruction,
                      style: AppTextStyle.bodyMd.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Row(
                      children: [
                        _SortZone(
                          label: l.miniGameCorrect,
                          color: PremiumColors.success,
                          icon: Icons.check_rounded,
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        _SortZone(
                          label: l.miniGameWrong,
                          color: PremiumColors.error,
                          icon: Icons.close_rounded,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.lg),
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
    if (item.sorted) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color:
                (item.accepted == true
                        ? PremiumColors.success
                        : PremiumColors.error)
                    .withValues(alpha: 0.1),
            border: Border.all(
              color: item.accepted == true
                  ? PremiumColors.success
                  : PremiumColors.error,
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.accepted == true
                    ? Icons.check_rounded
                    : Icons.close_rounded,
                size: 18,
                color: item.accepted == true
                    ? PremiumColors.success
                    : PremiumColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  item.text,
                  style: AppTextStyle.body.copyWith(color: context.textPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md),
                color: context.surfaceTinted,
              ),
              child: Text(
                item.text,
                style: AppTextStyle.body.copyWith(color: context.textPrimary),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.correct,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _onSort(index, true);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.success.withValues(alpha: 0.1),
                  border: Border.all(color: PremiumColors.success),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: PremiumColors.success,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: AppLocalizations.of(context)!.incorrect,
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _onSort(index, false);
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PremiumColors.error.withValues(alpha: 0.1),
                  border: Border.all(color: PremiumColors.error),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: PremiumColors.error,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(AppLocalizations l) {
    final xp = _correct * 20;
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
                    _correct >= 3
                        ? Icons.emoji_events_rounded
                        : Icons.star_rounded,
                    size: 64,
                    color: _correct >= 3
                        ? PremiumColors.accentYellow
                        : PremiumColors.primary,
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _correct >= 3 ? l.miniGameComplete : l.miniGameOver,
            style: AppTextStyle.headline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l.miniGameCorrect}: $_correct  |  ${l.miniGameMistakes}: $_mistakes',
            style: AppTextStyle.body.copyWith(color: context.textSecondary),
          ),
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
                setState(() => _initGame());
              },
              child: Text(l.miniGamePlayAgain),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortItem {
  final String text;
  final String category;
  final bool isCorrect;
  bool sorted = false;
  bool? accepted;
  _SortItem({
    required this.text,
    required this.category,
    required this.isCorrect,
  });
}

class _SortZone extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _SortZone({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: color.withValues(alpha: 0.05),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.xs),
            Text(label, style: AppTextStyle.bodyBold.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
