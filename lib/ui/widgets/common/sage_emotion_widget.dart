import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../providers/hardware_tier_provider.dart';
import '../../../providers/service_providers.dart';
import '../../../services/experience_service.dart';
import '../../../services/sage_emotion_service.dart';

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

    return RepaintBoundary(
      child: Semantics(
        label: semanticLabel ?? _friendlyName(emotion),
        child: animated
            ? _LiveSageImage(emotion: emotion, size: s)
            : _StaticSageImage(emotion: emotion, size: s),
      ),
    );
  }
}

class _StaticSageImage extends StatelessWidget {
  final SageEmotion emotion;
  final double size;
  const _StaticSageImage({required this.emotion, required this.size});

  @override
  Widget build(BuildContext context) {
    ProviderScope.containerOf(
      context,
    ).read(sageEmotionServiceProvider).ensurePrecached(emotion);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final decodeSize = (size * dpr).round().clamp(0, 600);
    return Image.asset(
      emotion.assetPath,
      width: size,
      height: size,
      cacheWidth: decodeSize,
      cacheHeight: decodeSize,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      fit: BoxFit.contain,
      isAntiAlias: true,
      errorBuilder: (ctx, _, _) => _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: PremiumColors.sagePlaceholder,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.pets, color: Colors.white54, size: size * 0.5),
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
    with SingleTickerProviderStateMixin {
  AnimationController? _breatheCtrl;
  SageEmotion _displayed = SageEmotion.calm;
  bool _idleBreathe = false;
  bool _skipNextTransition = false;
  int _decodeSize = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.emotion;
    ref.read(sageEmotionServiceProvider).ensurePrecached(widget.emotion);
    _updateBreathing();
  }

  @override
  void didUpdateWidget(_LiveSageImage old) {
    super.didUpdateWidget(old);
    if (old.emotion == widget.emotion) return;
    final service = ref.read(sageEmotionServiceProvider);
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
    final reduced = ref.read(reduceAnimationsProvider);
    final shouldBreathe =
        !reduced &&
        ref.read(sageEmotionServiceProvider).canIdleBreathe(_displayed);
    if (shouldBreathe == _idleBreathe) return;
    _idleBreathe = shouldBreathe;
    _breatheCtrl?.dispose();
    _breatheCtrl = null;
    if (_idleBreathe) {
      _breatheCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 3200),
      );
      _breatheCtrl!.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _breatheCtrl?.dispose();
    super.dispose();
  }

  double _computeScale() {
    double s = 1.0;
    if (_idleBreathe && _breatheCtrl != null) {
      s += 0.012 * _breatheCtrl!.value;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    _decodeSize = (widget.size * dpr).round().clamp(0, 600);

    final imageChild = AnimatedSwitcher(
      duration: _skipNextTransition
          ? Duration.zero
          : const Duration(milliseconds: 300),
      transitionBuilder: _skipNextTransition
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
        cacheWidth: _decodeSize,
        cacheHeight: _decodeSize,
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
