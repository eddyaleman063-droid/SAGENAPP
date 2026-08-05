import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/core/theme/app_colors.dart';
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/models/chest_evolution.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/providers/service_providers.dart';
import 'chest_widget.dart';

enum _OrbState { idle, success, fail }

class ChestGachaWidget extends ConsumerStatefulWidget {
  final ChestType initialType;
  final ValueChanged<ChestEvolutionResult> onComplete;

  const ChestGachaWidget({
    super.key,
    required this.initialType,
    required this.onComplete,
  });

  @override
  ConsumerState<ChestGachaWidget> createState() => _ChestGachaWidgetState();
}

class _ChestGachaWidgetState extends ConsumerState<ChestGachaWidget>
    with TickerProviderStateMixin {
  int _currentAttempt = 0;
  bool _isProcessing = false;

  late AnimationController _chestPulse;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  late ChestType _displayType;
  String _statusKey = '';
  bool _showStatus = false;
  List<_OrbState> _orbStates = [];
  bool _showGlow = false;
  final List<EvolutionAttempt> _attempts = [];

  @override
  void initState() {
    super.initState();
    _displayType = widget.initialType;
    _orbStates = List.filled(3, _OrbState.idle);

    _chestPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _glowAnim = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _chestPulse.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (_isProcessing || _currentAttempt >= 3) return;

    setState(() => _isProcessing = true);

    try {
      // Call server-side gacha roll
      final result = await ref.read(chestEvolutionServiceProvider)
          .rollSingleEvolution(_displayType);

      if (!mounted) return;

      final upgraded = result.evolved;
      final newType = result.newTier;

      if (upgraded) {
        ref.read(experienceServiceProvider).chestEvolveHaptic();
      } else {
        ref.read(experienceServiceProvider).chestFailHaptic();
      }

      _orbStates[_currentAttempt] =
          upgraded ? _OrbState.success : _OrbState.fail;

      final attempt = EvolutionAttempt(
        index: _currentAttempt,
        typeBefore: _displayType,
        typeAfter: newType,
        upgraded: upgraded,
        isFinal: _currentAttempt == 2,
      );
      _attempts.add(attempt);

      final l = AppLocalizations.of(context)!;
      _statusKey = upgraded
          ? l.chestEvolvedTo(newType.localizedLabel(l))
          : l.chestNoChange;

      if (upgraded) {
        setState(() {
          _showGlow = true;
          _displayType = newType;
        });
        _glowCtrl.forward().then((_) {
          if (mounted) setState(() => _showGlow = false);
        });
      }

      _currentAttempt++;
      setState(() => _showStatus = true);

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        // If roll failed, end early — server idempotency means subsequent
        // rolls on the same tier return the same result (misleading to user)
        if (_currentAttempt >= 3 || !upgraded) {
          widget.onComplete(ChestEvolutionResult(
            finalType: _displayType,
            attempts: _attempts,
          ));
        } else {
          setState(() {
            _isProcessing = false;
            _showStatus = false;
          });
        }
      });
    } catch (e) {
      // On error, treat as no upgrade but notify user
      _orbStates[_currentAttempt] = _OrbState.fail;
      _attempts.add(EvolutionAttempt(
        index: _currentAttempt,
        typeBefore: _displayType,
        typeAfter: _displayType,
        upgraded: false,
        isFinal: _currentAttempt == 2,
      ));
      _currentAttempt++;
      _statusKey = AppLocalizations.of(context)!.connectionErrorRetry;
      setState(() {
        _isProcessing = false;
        _showStatus = true;
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        // End gacha on error — no point retrying same tier
        widget.onComplete(ChestEvolutionResult(
          finalType: _displayType,
          attempts: _attempts,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return RepaintBoundary(
      child: Semantics(
        label: l.gachaChestTap,
        button: true,
        child: GestureDetector(
          onTap: _isProcessing ? null : _onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildChestArea(),
              const SizedBox(height: AppSpacing.sm),
              _buildOrbs(),
              const SizedBox(height: AppSpacing.lg),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showStatus
                    ? _StatusBadge(key: ValueKey(_statusKey), text: _statusKey)
                    : Text(
                        l.chestTapToUpgrade,
                        key: const ValueKey('hint'),
                        style: AppTextStyle.subtitle.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChestArea() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _chestPulse,
            builder: (_, child) => Transform.scale(
              scale: 1.0 + _chestPulse.value * 0.03,
              child: child,
            ),
            child: ChestWidget(
              key: ValueKey('chest_${_displayType.name}'),
              type: _displayType,
              size: 160,
            ),
          ),
          if (_showGlow)
            FadeTransition(
              opacity: _glowAnim,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _displayType.color.withValues(alpha: 0.4),
                        _displayType.color.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrbs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) => _OrbWidget(
        index: i,
        state: _orbStates[i],
        isCurrent: i == _currentAttempt && !_isProcessing,
        color: _displayType.color,
        pulseAnim: _chestPulse,
      )),
    );
  }
}

class _OrbWidget extends StatelessWidget {
  final int index;
  final _OrbState state;
  final bool isCurrent;
  final Color color;
  final Animation<double> pulseAnim;

  const _OrbWidget({
    required this.index,
    required this.state,
    required this.isCurrent,
    required this.color,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget orb;
    switch (state) {
      case _OrbState.idle:
        orb = AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, child) {
            final scale = isCurrent ? 1.0 + pulseAnim.value * 0.15 : 1.0;
            final opacity = isCurrent ? 0.8 + pulseAnim.value * 0.2 : 0.4;
            return Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            );
          },
          child: _circle(
            color: isCurrent ? color : cs.onSurface.withValues(alpha: 0.38),
            size: isCurrent ? 36 : 28,
          ),
        );
      case _OrbState.success:
        orb = _circle(
          color: PremiumColors.success,
          child: Semantics(
            label: AppLocalizations.of(context)!.gachaOrbSuccess,
            child: const Icon(Icons.check_rounded, color: Colors.white, size: 16),
          ),
        );
      case _OrbState.fail:
        orb = _circle(
          color: context.textSecondary,
          child: Semantics(
            label: AppLocalizations.of(context)!.gachaOrbFail,
            child: const Icon(Icons.close_rounded, color: Colors.white54, size: 16),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          orb,
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${index + 1}',
            style: AppTextStyle.label.copyWith(
              color: state == _OrbState.idle
                  ? cs.onSurface.withValues(alpha: 0.38)
                  : Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle({required Color color, double size = 28, Widget? child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.25),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  const _StatusBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      builder: (_, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Text(
          text,
          style: AppTextStyle.bodyMdBold.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
