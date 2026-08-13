import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/hardware_tier_provider.dart';
import '../../../services/app_logger.dart';

class AmbientBackground extends ConsumerStatefulWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  ConsumerState<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends ConsumerState<AmbientBackground>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;
  Animation<double>? _fadeAnim;
  bool _initialized = false;

  static const _darkA = PremiumColors.darkBg;
  static const _darkB = PremiumColors.ambientDark;
  static const _lightA = PremiumColors.lightBg;
  static const _lightB = PremiumColors.ambientLight;

  void _setupAnimation() {
    final reduce = ref.read(reduceAnimationsProvider);
    if (!reduce && !_initialized) {
      _initialized = true;
      _ctrl = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 8),
      );
      _fadeAnim = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _ctrl!, curve: Curves.easeInOutSine));
      try {
        _ctrl!.repeat(reverse: true);
      } catch (e) {
        AppLogger().warning('AmbientBackground: failed to start animation: $e');
      }
    } else if (reduce && _initialized) {
      _initialized = false;
      _ctrl?.stop();
      _ctrl?.dispose();
      _ctrl = null;
      _fadeAnim = null;
    }
  }

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch reactively so we respond when tier detection completes
    ref.watch(reduceAnimationsProvider);
    _setupAnimation();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? const [_darkA, _darkB] : const [_lightA, _lightB];

    if (_ctrl == null || !_ctrl!.isAnimating) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: widget.child,
      );
    }

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim!,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const [_darkB, Colors.transparent]
                    : const [_lightB, Colors.transparent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
