import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme_constants.dart';
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

  @override
  Widget build(BuildContext context) {
    final s = size.clamp(40.0, 200.0);

    return RepaintBoundary(
      child: Semantics(
        label: semanticLabel ?? emotion.name,
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
    ProviderScope.containerOf(context).read(sageEmotionServiceProvider).ensurePrecached(emotion);
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
      child: Icon(
        Icons.pets,
        color: Colors.white54,
        size: size * 0.5,
      ),
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
    with TickerProviderStateMixin {
  late AnimationController _transCtrl;

  AnimationController? _breatheCtrl;
  SageEmotion _displayed = SageEmotion.calm;
  bool _idleBreathe = false;
  int _decodeSize = 0;

  @override
  void initState() {
    super.initState();
    _displayed = widget.emotion;
    ref.read(sageEmotionServiceProvider).ensurePrecached(widget.emotion);
    _transCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _transCtrl.forward();
    _updateBreathing();
  }

  @override
  void didUpdateWidget(_LiveSageImage old) {
    super.didUpdateWidget(old);
    if (old.emotion == widget.emotion) return;
    final service = ref.read(sageEmotionServiceProvider);
    if (!service.shouldAnimateEmotionChange(old.emotion, widget.emotion)) {
      _displayed = widget.emotion;
      _updateBreathing();
      if (mounted) setState(() {});
      return;
    }
    if (service.isSignificantMoodShift(old.emotion, widget.emotion)) {
      ExperienceService.instance.lightHaptic();
    }
    _displayed = widget.emotion;
    _transCtrl.reset();
    _transCtrl.forward();
    _updateBreathing();
  }

  void _updateBreathing() {
    final shouldBreathe = ref.read(sageEmotionServiceProvider).canIdleBreathe(_displayed);
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
    _transCtrl.dispose();
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

  Listenable get _listenable {
    if (_breatheCtrl != null) return Listenable.merge([_transCtrl, _breatheCtrl!]);
    return _transCtrl;
  }

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    _decodeSize = (widget.size * dpr).round().clamp(0, 600);

    return AnimatedBuilder(
      animation: _listenable,
      builder: (context, child) {
        return Transform.scale(
          scale: _computeScale(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return ScaleTransition(
                scale: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
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
          ),
        );
      },
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
      child: Icon(
        Icons.pets,
        color: Colors.white54,
        size: widget.size * 0.5,
      ),
    );
  }
}
