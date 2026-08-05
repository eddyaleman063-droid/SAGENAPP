import 'package:firebase_performance/firebase_performance.dart';
import 'app_logger.dart';

/// Wraps Firebase Performance Monitoring with graceful fallback.
class PerformanceService {
  static final PerformanceService instance = PerformanceService._();
  PerformanceService._();
  final AppLogger _logger = AppLogger();

  FirebasePerformance? _performance;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      _performance = FirebasePerformance.instance;
      final perf = _performance;
      if (perf == null) return;
      await perf.setPerformanceCollectionEnabled(true);
      _initialized = true;
    } catch (e) {
      _logger.warning('PerformanceService.init failed: $e');
    }
  }

  Trace startTrace(String name) {
    final trace = _performance?.newTrace(name);
    trace?.start();
    return trace ?? _NoOpTrace();
  }

  Future<void> traceAsync(String name, Future<void> Function() action) async {
    final trace = startTrace(name);
    try {
      await action();
      trace.putAttribute('success', 'true');
    } catch (e) {
      trace.putAttribute('success', 'false');
      trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      trace.stop();
    }
  }

  void reportScreenLoad(String screenName, int durationMs) {
    final trace = _performance?.newTrace('screen_load_$screenName');
    trace?.start();
    trace?.setMetric('duration_ms', durationMs);
    trace?.stop();
  }

  void reportNetworkRequest(String url, int durationMs, {int? responseCode}) {
    final trace = _performance?.newTrace('network_request');
    trace?.start();
    trace?.putAttribute('url', url);
    trace?.setMetric('duration_ms', durationMs);
    if (responseCode != null) {
      trace?.setMetric('response_code', responseCode);
    }
    trace?.stop();
  }
}

class _NoOpTrace implements Trace {
  @override
  Future<void> start() async {}
  @override
  Future<void> stop() async {}
  @override
  void incrementMetric(String metricName, int incrementBy) {}
  @override
  void putAttribute(String attributeName, String value) {}
  void putMetric(String metricName, int value) {}
  @override
  void setMetric(String metricName, int value) {}
  @override
  void removeAttribute(String attributeName) {}
  @override
  String? getAttribute(String attributeName) => null;
  @override
  int getMetric(String metricName) => 0;
  @override
  Map<String, String> getAttributes() => {};
  Map<String, int> getMetrics() => {};
}
