import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'analytics_service.dart';
import 'app_logger.dart';

/// Shares images and text via platform share sheet.
class ShareService {
  static final ShareService _instance = ShareService._();
  static ShareService get instance => _instance;
  ShareService._({AnalyticsService? analytics}) : _analytics = analytics ?? AnalyticsService.instance, _logger = AppLogger();
  final AppLogger _logger;
  final AnalyticsService _analytics;

  Future<bool> shareImage(Uint8List imageBytes, {String? text, String? source}) async {
    File? file;
    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'sagen_flex_card_${DateTime.now().millisecondsSinceEpoch}.png';
      file = File('${dir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: text ?? 'Join my alliance on SAGEN',
        ),
      );
      if (source != null) {
        _analytics.trackFlexCardShared(source);
      }
      return true;
    } catch (e) {
      _logger.error('Share failed', e);
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
}
