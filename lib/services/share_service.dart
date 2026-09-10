import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'analytics_service.dart';
import 'app_logger.dart';

/// Shares images and text via platform share sheet.
class ShareService {
  static final ShareService _instance = ShareService._();
  static ShareService get instance => _instance;
  ShareService._({
    AnalyticsService? analytics,
    Future<void> Function(ShareParams params)? shareOverride,
  }) : _analytics = analytics ?? AnalyticsService.instance,
       _logger = AppLogger(),
       _shareOverride = shareOverride;

  /// Test-only constructor replacing the platform share call and analytics.
  @visibleForTesting
  factory ShareService.test({
    AnalyticsService? analytics,
    Future<void> Function(ShareParams params)? shareOverride,
  }) {
    return ShareService._(analytics: analytics, shareOverride: shareOverride);
  }

  final AppLogger _logger;
  final AnalyticsService _analytics;
  final Future<void> Function(ShareParams params)? _shareOverride;

  Future<void> _share(ShareParams params) {
    final override = _shareOverride;
    if (override != null) return override(params);
    return SharePlus.instance.share(params);
  }

  Future<bool> shareImage(
    Uint8List imageBytes, {
    required String text,
    String? source,
  }) async {
    File? file;
    try {
      final dir = await getTemporaryDirectory();
      final fileName =
          'sagen_flex_card_${DateTime.now().millisecondsSinceEpoch}.png';
      file = File('${dir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await _share(ShareParams(files: [XFile(file.path)], text: text));
      if (source != null) {
        _analytics.trackFlexCardShared(source);
      }
      return true;
    } catch (e, stack) {
      _logger.error('Share failed', e, stack);
      return false;
    } finally {
      try {
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        _logger.warning('ShareService: failed to delete temp file: $e');
      }
    }
  }

  Future<bool> shareText(String text, {String? source}) async {
    try {
      await _share(ShareParams(text: text));
      if (source != null) {
        _analytics.trackFlexCardShared(source);
      }
      return true;
    } catch (e, stack) {
      _logger.error('Share text failed', e, stack);
      return false;
    }
  }
}
