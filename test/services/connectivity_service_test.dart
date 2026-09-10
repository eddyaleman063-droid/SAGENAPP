import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/services/connectivity_service.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockConnectivity conn;
  late StreamController<List<ConnectivityResult>> stream;

  setUp(() {
    conn = _MockConnectivity();
    stream = StreamController<List<ConnectivityResult>>.broadcast();
    addTearDown(stream.close);
    when(() => conn.onConnectivityChanged).thenAnswer((_) => stream.stream);
    when(() => conn.checkConnectivity()).thenAnswer((_) async => const []);
    ConnectivityService.instance.overrideConnectivityForTesting(conn);
  });

  tearDown(() {
    ConnectivityService.instance.stop();
  });

  group('ConnectivityService', () {
    test('singleton returns same instance', () {
      final a = ConnectivityService.instance;
      final b = ConnectivityService.instance;
      expect(identical(a, b), isTrue);
    });

    test('online defaults to false before start', () {
      final service = ConnectivityService.instance;
      expect(service.online.value, isFalse);
    });

    test('offlineSaveCount defaults to 0', () {
      final service = ConnectivityService.instance;
      expect(service.offlineSaveCount.value, 0);
    });

    test('offlineSavedForLater returns current count', () {
      final service = ConnectivityService.instance;
      expect(service.offlineSavedForLater, 0);
    });

    test('start is idempotent — subscribes only once', () async {
      final service = ConnectivityService.instance;
      service.start();
      service.start();
      await Future<void>.delayed(Duration.zero);
      verify(() => conn.onConnectivityChanged).called(1);
    });

    test('start reflects wifi/mobile/ethernet as online', () async {
      final service = ConnectivityService.instance;
      service.start();
      stream.add(const [ConnectivityResult.wifi, ConnectivityResult.mobile]);
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isTrue);

      stream.add(const [ConnectivityResult.ethernet]);
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isTrue);
    });

    test('non-network results set the device offline', () async {
      final service = ConnectivityService.instance;
      service.start();
      stream.add(const [ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isFalse);

      stream.add(const [ConnectivityResult.bluetooth]);
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isFalse);
    });

    test('stream errors are logged and do not crash', () async {
      final service = ConnectivityService.instance;
      service.start();
      stream.addError(StateError('identity_changed'));
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isFalse);
    });

    test('checkConnectivity through onAppResume updates the state', () async {
      final service = ConnectivityService.instance;
      when(
        () => conn.checkConnectivity(),
      ).thenAnswer((_) async => [ConnectivityResult.wifi]);
      service.onAppResume();
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isTrue);
    });

    test('checkConnectivity failures are tolerated', () async {
      final service = ConnectivityService.instance;
      service.start();
      stream.add(const [ConnectivityResult.none]);
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isFalse);

      when(() => conn.checkConnectivity()).thenThrow(Exception('boom'));
      await service.checkConnectivity();
      await Future<void>.delayed(Duration.zero);
      expect(service.online.value, isFalse);
    });

    test('stop cancels the subscription and allows restart', () async {
      final service = ConnectivityService.instance;
      service.start();
      service.stop();
      service.start();
      await Future<void>.delayed(Duration.zero);
      verify(() => conn.onConnectivityChanged).called(2);
    });
  });
}
