import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sagen/l10n/app_localizations.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/connectivity_service.dart';

import '../../core/theme/theme_constants.dart';

/// Animated offline banner that drops elastically from the top of the screen
/// when connectivity is lost, with a blurred backdrop effect.
class OfflineBanner extends ConsumerStatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final ConnectivityService _cs;
  bool _online = true;
  int _lastSaveCount = 0;

  static const double _bannerHeight = 44;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, _bannerHeight),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _cs = ref.read(connectivityServiceProvider);
    _online = _cs.online.value;
    _lastSaveCount = _cs.offlineSaveCount.value;
    _cs.online.addListener(_onConnectivityChanged);
    _cs.offlineSaveCount.addListener(_onOfflineSave);
  }

  void _onConnectivityChanged() {
    if (!mounted) return;
    final online = _cs.online.value;
    if (online == _online) return;
    setState(() => _online = online);
    if (online) {
      _ctrl.reverse();
      final count = _cs.offlineSaveCount.value;
      if (count > _lastSaveCount) {
        _lastSaveCount = count;
        _showSyncMessage();
      }
    } else {
      _ctrl.forward();
    }
  }

  void _onOfflineSave() {
    if (!mounted || !_online) {
      _showSavedOfflineMessage();
    }
  }

  void _showSavedOfflineMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_upload_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.offlineSavedForLater,
              style: AppTextStyle.subtitle,
            ),
          ],
        ),
        backgroundColor: PremiumColors.warning,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  void _showSyncMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.offlineSyncComplete,
              style: AppTextStyle.subtitle,
            ),
          ],
        ),
        backgroundColor: PremiumColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  void dispose() {
    _cs.online.removeListener(_onConnectivityChanged);
    _cs.offlineSaveCount.removeListener(_onOfflineSave);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _slide,
          builder: (_, child) => Positioned(
            top: -_bannerHeight + _slide.value.dy,
            left: 0,
            right: 0,
            height: _bannerHeight,
            child: child!,
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _online ? 0 : 4,
                sigmaY: _online ? 0 : 4,
              ),
              child: Container(
                color: cs.error.withValues(alpha: 0.85),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_rounded, size: 16, color: cs.onError),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.offlineNoConnection,
                      style: AppTextStyle.subtitle.copyWith(
                        color: cs.onError,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Semantics(
                      button: true,
                      label: AppLocalizations.of(context)!.retry,
                      child: GestureDetector(
                        onTap: () async {
                          HapticFeedback.lightImpact();
                          await _cs.checkConnectivity();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cs.onError.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.retry,
                            style: AppTextStyle.caption.copyWith(
                              color: cs.onError,
                              fontWeight: FontWeight.w600,
                            ),
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
    );
  }
}
