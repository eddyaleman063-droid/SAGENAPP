import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sagen/core/theme/theme_constants.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/services/app_logger.dart';

/// Phases of the flame animation.
enum FlamePhase { idle, charge, explode, float, frozen, defrosting }

/// Unified flame widget that uses Rive when available, falling back to a
/// platform-aware implementation (AndroidView on Android, icon on others).
///
/// Place a file at `assets/animations/flame.riv` with artboards named
/// `idle`, `charge`, `explode`, `float`, `frozen`, `defrosting` to
/// enable Rive rendering (cross-platform iOS/Android).
class RiveFlameWidget extends StatefulWidget {
  final FlamePhase? phase;
  final int? streak;

  const RiveFlameWidget({super.key, this.phase, this.streak});

  @override
  State<RiveFlameWidget> createState() => _RiveFlameWidgetState();
}

class _RiveFlameWidgetState extends State<RiveFlameWidget> {
  static bool? _cachedRiveAvailable;

  @override
  void initState() {
    super.initState();
    if (_cachedRiveAvailable != null) {
      _riveAvailable = _cachedRiveAvailable!;
    } else {
      _checkRiveAsset();
    }
  }

  bool _riveAvailable = false;

  Future<void> _checkRiveAsset() async {
    try {
      await rootBundle.load('assets/animations/flame.riv');
      _cachedRiveAvailable = true;
      if (mounted) setState(() => _riveAvailable = true);
    } catch (e) {
      _cachedRiveAvailable = false;
      AppLogger().warning('RiveFlame: flame.riv not available: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_riveAvailable) {
      return _RiveBody(phase: widget.phase, streak: widget.streak);
    }
    return _FlameFallbackWidget(phase: widget.phase);
  }
}

class _RiveBody extends StatefulWidget {
  final FlamePhase? phase;
  final int? streak;
  const _RiveBody({this.phase, this.streak});

  @override
  State<_RiveBody> createState() => _RiveBodyState();
}

class _RiveBodyState extends State<_RiveBody> {
  String get _artboardName {
    switch (widget.phase ?? FlamePhase.idle) {
      case FlamePhase.idle:
        return 'idle';
      case FlamePhase.charge:
        return 'charge';
      case FlamePhase.explode:
        return 'explode';
      case FlamePhase.float:
        return 'float';
      case FlamePhase.frozen:
        return 'frozen';
      case FlamePhase.defrosting:
        return 'defrosting';
    }
  }

  @override
  Widget build(BuildContext context) {
    return rive.RiveWidgetBuilder(
      fileLoader: rive.FileLoader.fromAsset(
        'assets/animations/flame.riv',
        riveFactory: rive.Factory.flutter,
      ),
      artboardSelector: rive.ArtboardNamed(_artboardName),
      builder: (context, state) {
        return switch (state) {
          rive.RiveLoaded(:final controller) => rive.RiveWidget(
            controller: controller,
            fit: rive.Fit.contain,
          ),
          rive.RiveLoading() => const SizedBox.shrink(),
          rive.RiveFailed() => const SizedBox.shrink(),
        };
      },
    );
  }
}

/// Fallback flame widget used when Rive asset is not available.
/// On Android, uses a native AndroidView via MethodChannel.
/// On other platforms, uses an animated icon fallback.
class _FlameFallbackWidget extends StatefulWidget {
  final FlamePhase? phase;
  const _FlameFallbackWidget({this.phase});

  @override
  State<_FlameFallbackWidget> createState() => _FlameFallbackWidgetState();
}

class _FlameFallbackWidgetState extends State<_FlameFallbackWidget>
    with SingleTickerProviderStateMixin {
  static const _channel = MethodChannel('com.sagen.app/flame_animation');
  late AnimationController _ctrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (defaultTargetPlatform != TargetPlatform.android) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_FlameFallbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phase != widget.phase && widget.phase != null) {
      _sendPhase(widget.phase!);
    }
  }

  void _sendPhase(FlamePhase phase) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      _channel.invokeMethod<void>('setPhase', {
        'phase': phase.name.toUpperCase(),
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _flameColor(FlamePhase phase) {
    switch (phase) {
      case FlamePhase.frozen:
        return PremiumColors.flameFrozen;
      case FlamePhase.defrosting:
        return PremiumColors.flameDefrosting;
      case FlamePhase.explode:
        return PremiumColors.streakOrange;
      default:
        return PremiumColors.flameActive;
    }
  }

  Widget _buildIconFallback() {
    final phase = widget.phase ?? FlamePhase.idle;
    final color = _flameColor(phase);
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        return Transform.scale(
          scale: _pulseAnim.value,
          child: Semantics(
            label: phase == FlamePhase.frozen || phase == FlamePhase.defrosting
                ? l.streakShieldActive
                : l.streakFlame,
            child: Icon(
              phase == FlamePhase.frozen || phase == FlamePhase.defrosting
                  ? Icons.ac_unit_rounded
                  : Icons.local_fire_department_rounded,
              size: 48,
              color: color,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'com.sagen.app/flame_animation',
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: (_) {
          if (widget.phase != null) {
            _sendPhase(widget.phase!);
          }
        },
      );
    }
    return _buildIconFallback();
  }
}
