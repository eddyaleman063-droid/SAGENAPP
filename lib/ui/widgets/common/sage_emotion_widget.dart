import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/hardware_tier_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/app_logger.dart';
import '../../../services/experience_service.dart';
import '../../../services/sage_emotion_service.dart';
import '../../../l10n/app_localizations.dart';

class SageEmotionWidget extends StatelessWidget {
  final SageEmotion emotion;
  final double size;
  final String? semanticLabel;
  final bool animated;

  const SageEmotionWidget({
    super.key,
    required this.emotion,
    this.size = 90,
    this.semanticLabel,
    this.animated = true,
  });

  static final _nameCache = <SageEmotion, String>{};

  static String _friendlyName(SageEmotion e) {
    return _nameCache.putIfAbsent(e, () {
      final raw = e.name;
      final buf = StringBuffer(raw[0].toUpperCase());
      for (var i = 1; i < raw.length; i++) {
        final c = raw[i];
        if (c == c.toUpperCase() && raw[i - 1] != raw[i - 1].toUpperCase()) {
          buf.write(' ');
        }
        buf.write(c);
      }
      return buf.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = size.clamp(24.0, 200.0);
    final appL = AppLocalizations.of(context);
    final label =
        semanticLabel ??
        (appL != null ? emotion.localizedLabel(appL) : _friendlyName(emotion));

    return RepaintBoundary(
      child: Semantics(
        label: label,
        child: animated
            ? _LiveSageImage(emotion: emotion, size: s)
            : _StaticSageImage(emotion: emotion, size: s),
      ),
    );
  }
}

class _StaticSageImage extends StatefulWidget {
  final SageEmotion emotion;
  final double size;
  const _StaticSageImage({required this.emotion, required this.size});

  @override
  State<_StaticSageImage> createState() => _StaticSageImageState();
}

class _StaticSageImageState extends State<_StaticSageImage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      try {
        ProviderScope.containerOf(
          context,
          listen: false,
        ).read(sageEmotionServiceProvider).ensurePrecached(widget.emotion);
      } catch (e, stack) {
        AppLogger().error('SageEmotionWidget: precache failed', e, stack);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      widget.emotion.assetPath,
      width: widget.size,
      height: widget.size,
      cacheWidth: sageEmotionDecodeSize,
      cacheHeight: sageEmotionDecodeSize,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      fit: BoxFit.contain,
      isAntiAlias: true,
      errorBuilder: (ctx, _, _) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: PremiumColors.sagePlaceholder,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.pets, color: Colors.white54, size: widget.size * 0.5),
    );
  }
}

class _LiveSageImage extends ConsumerStatefulWidget {
  final SageEmotion emotion;
  final double size;
  const _LiveSageImage({required this.emotion, required this.size});

  @override
  ConsumerState<_LiveSageImage> createState() => _LiveSageImageState();
}

class _LiveSageImageState extends ConsumerState<_LiveSageImage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _breatheCtrl;
  late SageEmotion _displayed;
  bool _idleBreathe = false;
  bool _skipNextTransition = false;
  bool _reduceAnimations = false;
  bool _osReduceAnimations = false;
  bool _appVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _displayed = widget.emotion;
    _reduceAnimations = ref.read(reduceAnimationsProvider);
    ref.read(sageEmotionServiceProvider).ensurePrecached(widget.emotion);
    _updateBreathing();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _breatheCtrl?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final visible = state == AppLifecycleState.resumed;
    if (visible == _appVisible) return;
    _appVisible = visible;
    _updateBreathing();
  }

  @override
  void didUpdateWidget(_LiveSageImage old) {
    super.didUpdateWidget(old);
    if (old.emotion == widget.emotion) return;
    final service = ref.read(sageEmotionServiceProvider);
    service.ensurePrecached(widget.emotion);
    _skipNextTransition = !service.shouldAnimateEmotionChange(
      old.emotion,
      widget.emotion,
    );
    if (!_skipNextTransition &&
        service.isSignificantMoodShift(old.emotion, widget.emotion)) {
      ExperienceService.instance.lightHaptic();
    }
    _displayed = widget.emotion;
    _updateBreathing();
  }

  void _updateBreathing() {
    final reduced = _reduceAnimations || _osReduceAnimations;
    final shouldBreathe =
        !reduced &&
        _appVisible &&
        ref.read(sageEmotionServiceProvider).canIdleBreathe(_displayed);
    if (shouldBreathe == _idleBreathe) return;
    _idleBreathe = shouldBreathe;
    if (shouldBreathe) {
      // Reuse the controller and resume from its current position so the
      // breathing phase doesn't "pop" back to zero on every transition.
      _breatheCtrl ??= AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3200),
      );
      _breatheCtrl!.repeat(reverse: true);
    } else {
      _breatheCtrl?.stop();
    }
  }

  double _computeScale() {
    double s = 1.0;
    if (_idleBreathe && _breatheCtrl != null) {
      s += 0.04 * _breatheCtrl!.value;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(reduceAnimationsProvider, (_, reduced) {
      _reduceAnimations = reduced;
      _updateBreathing();
    });
    // Respect the OS-level "remove animations" accessibility setting too.
    final osReduce = MediaQuery.disableAnimationsOf(context);
    if (osReduce != _osReduceAnimations) {
      _osReduceAnimations = osReduce;
      _updateBreathing();
    }

    final skipTransition = _skipNextTransition || _reduceAnimations || osReduce;
    final imageChild = AnimatedSwitcher(
      duration: skipTransition ? Duration.zero : AppMotion.normal,
      transitionBuilder: skipTransition
          ? (child, _) => child
          : (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
      child: Image.asset(
        _displayed.assetPath,
        key: ValueKey(_displayed.assetPath),
        width: widget.size,
        height: widget.size,
        cacheWidth: sageEmotionDecodeSize,
        cacheHeight: sageEmotionDecodeSize,
        gaplessPlayback: true,
        filterQuality: FilterQuality.high,
        fit: BoxFit.contain,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      ),
    );

    if (_breatheCtrl == null) return imageChild;

    return AnimatedBuilder(
      animation: _breatheCtrl!,
      builder: (context, child) {
        return Transform.scale(scale: _computeScale(), child: child);
      },
      child: imageChild,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: PremiumColors.sagePlaceholder,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.pets, color: Colors.white54, size: widget.size * 0.5),
    );
  }
}
