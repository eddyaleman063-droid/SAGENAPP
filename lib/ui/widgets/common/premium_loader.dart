import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/hardware_tier_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/sage_emotion_service.dart';
import 'sage_emotion_widget.dart';

class PremiumLoader extends ConsumerStatefulWidget {
  final Widget child;
  final bool loading;
  final String? message;
  const PremiumLoader({
    super.key,
    required this.child,
    this.loading = false,
    this.message,
  });

  @override
  ConsumerState<PremiumLoader> createState() => _PremiumLoaderState();
}

class _PremiumLoaderState extends ConsumerState<PremiumLoader>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  String _currentQuote = '';
  Timer? _quoteTimer;
  bool _overlayVisible = false;

  @override
  void initState() {
    super.initState();
    _currentQuote = ref.read(motivationalQuotesServiceProvider).random();
    final reduced = ref.read(reduceAnimationsProvider);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.resolve(
        const Duration(seconds: 3),
        reduceAnimations: reduced,
      ),
    );
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: AppMotion.resolve(AppMotion.normal, reduceAnimations: reduced),
    );
    if (widget.loading) {
      _overlayVisible = true;
      if (!reduced) _pulseCtrl.repeat(reverse: true);
      _fadeCtrl.forward();
      _startQuoteTimer();
    }
  }

  @override
  void didUpdateWidget(PremiumLoader old) {
    super.didUpdateWidget(old);
    if (widget.loading != old.loading) {
      final reduced = ref.read(reduceAnimationsProvider);
      if (widget.loading) {
        _overlayVisible = true;
        if (!reduced) _pulseCtrl.repeat(reverse: true);
        _fadeCtrl.forward();
        _startQuoteTimer();
      } else {
        _pulseCtrl.stop();
        _pulseCtrl.reset();
        _fadeCtrl.reverse().then((_) {
          if (mounted) setState(() => _overlayVisible = false);
        });
        _quoteTimer?.cancel();
        _quoteTimer = null;
      }
    }
  }

  void _startQuoteTimer() {
    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(
        () => _currentQuote = ref
            .read(motivationalQuotesServiceProvider)
            .random(),
      );
    });
  }

  @override
  void dispose() {
    _quoteTimer?.cancel();
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;

    return RepaintBoundary(
      child: Stack(
        children: [
          widget.child,
          if (_overlayVisible)
            FadeTransition(
              opacity: _fadeCtrl,
              child: Semantics(
                label: widget.message ?? 'Loading',
                explicitChildNodes: true,
                child: Container(
                  color: (dark ? PremiumColors.darkBg : Colors.white)
                      .withValues(alpha: 0.92),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, _) => Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: dark
                                  ? PremiumColors.darkCard
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: PremiumColors.primary.withValues(
                                    alpha: 0.1 + 0.15 * _pulseCtrl.value,
                                  ),
                                  blurRadius: 20 + 15 * _pulseCtrl.value,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Transform.scale(
                              scale: 0.85 + 0.15 * _pulseCtrl.value,
                              child: const SageEmotionWidget(
                                emotion: SageEmotion.thinking,
                                size: 76,
                                animated: false,
                              ),
                            ),
                          ),
                        ),
                        if (widget.message != null) ...[
                          const SizedBox(height: AppSpacing.xxl),
                          Text(
                            widget.message!,
                            style: AppTextStyle.subtitle.copyWith(
                              color: context.textTertiary,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.huge),
                        SizedBox(
                          width: 260,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            child: Text(
                              _currentQuote,
                              key: ValueKey(_currentQuote),
                              textAlign: TextAlign.center,
                              style: AppTextStyle.caption.copyWith(
                                color: context.textTertiary,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
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
        ],
      ),
    );
  }
}
