import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/performance_service.dart';

void main() {
  group('PerformanceService', () {
    test('singleton returns same instance', () {
      final a = PerformanceService.instance;
      final b = PerformanceService.instance;
      expect(identical(a, b), isTrue);
    });

    test('init does not throw when Firebase unavailable', () async {
      final service = PerformanceService.instance;
      await service.init();
    });

    test('startTrace returns trace object', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('test_trace');
      expect(trace, isNotNull);
    });

    test('traceAsync completes successfully', () async {
      final service = PerformanceService.instance;
      var called = false;
      await service.traceAsync('test', () async {
        called = true;
      });
      expect(called, isTrue);
    });

    test('traceAsync rethrows on error', () async {
      final service = PerformanceService.instance;
      expect(
        () => service.traceAsync('test', () async {
          throw Exception('test error');
        }),
        throwsException,
      );
    });

    test('reportScreenLoad does not throw', () {
      final service = PerformanceService.instance;
      expect(() => service.reportScreenLoad('home', 150), returnsNormally);
    });

    test('reportNetworkRequest does not throw', () {
      final service = PerformanceService.instance;
      expect(
        () => service.reportNetworkRequest('https://example.com', 200, responseCode: 200),
        returnsNormally,
      );
    });
  });

  group('_NoOpTrace', () {
    test('start completes without error', () async {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      await trace.start();
    });

    test('stop completes without error', () async {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      await trace.stop();
    });

    test('putAttribute does not throw', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      trace.putAttribute('key', 'value');
    });

    test('setMetric does not throw', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      trace.setMetric('metric', 42);
    });

    test('incrementMetric does not throw', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      trace.incrementMetric('metric', 1);
    });

    test('removeAttribute does not throw', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      trace.removeAttribute('key');
    });

    test('getAttribute returns null', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      expect(trace.getAttribute('key'), isNull);
    });

    test('getMetric returns 0', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      expect(trace.getMetric('metric'), 0);
    });

    test('getAttributes returns empty map', () {
      final service = PerformanceService.instance;
      final trace = service.startTrace('noop');
      expect(trace.getAttributes(), isEmpty);
    });
  });
}
