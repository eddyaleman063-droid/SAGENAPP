import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/services/chest_evolution_service.dart';

import '../helpers/firebase_test_helper.dart';

const _cloudFunctionsChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call',
  StandardMessageCodec(),
);

class _FakeCoreHostApi extends TestFirebaseCoreHostApi {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async => [];

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async => CoreFirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      );

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async =>
      CoreInitializeResponse(
        name: appName,
        options: initializeAppRequest,
        isAutomaticDataCollectionEnabled: true,
        pluginConstants: <String, Object?>{},
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ChestEvolutionService service;
  final requests = <Map?>[];
  final queue = <Object?>[];

  void setQueue(List<Object?> responses) {
    queue
      ..clear()
      ..addAll(responses);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
            (Object? message) async {
      requests.add(((message as List)[0] as Map)['parameters'] as Map?);
      return <Object?>[queue.removeAt(0)];
    });
  }

  void setError() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
            (Object? message) async {
      requests.add(((message as List)[0] as Map)['parameters'] as Map?);
      return <Object?>[
        'unavailable',
        'down',
        <String, Object?>{'code': 'functions/unavailable'},
      ];
    });
  }

  void clearMock() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
  }

  setUp(() async {
    requests.clear();
    queue.clear();
    clearMock();
    TestFirebaseCoreHostApi.setUp(_FakeCoreHostApi());
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    setupFirebaseMocks();
    service = ChestEvolutionService.instance;
  });

  tearDown(clearMock);

  group('rollSingleEvolution', () {
    test('legendary chest skips the server call', () async {
      final result = await service.rollSingleEvolution(ChestType.legendary);
      expect(result.evolved, isFalse);
      expect(result.newTier, ChestType.legendary);
      expect(requests, isEmpty);
    });

    test('evolves when the server says so', () async {
      setQueue([
        <String, Object?>{'evolved': true, 'newTier': 'gold'},
      ]);
      final result = await service.rollSingleEvolution(ChestType.bronze);
      expect(result.evolved, isTrue);
      expect(result.newTier, ChestType.gold);
      expect(requests.single?['currentTier'], 'bronze');
    });

    test('does not evolve when the server says no', () async {
      setQueue([
        <String, Object?>{'evolved': false, 'newTier': 'bronze'},
      ]);
      final result = await service.rollSingleEvolution(ChestType.bronze);
      expect(result.evolved, isFalse);
      expect(result.newTier, ChestType.bronze);
    });

    test('falls back to current tier when newTier is unknown', () async {
      setQueue([
        <String, Object?>{'evolved': true, 'newTier': 'diamond'},
      ]);
      final result = await service.rollSingleEvolution(ChestType.silver);
      expect(result.evolved, isTrue);
      expect(result.newTier, ChestType.silver);
    });

    test('uses defaults when fields are missing', () async {
      setQueue([<String, Object?>{}]);
      final result = await service.rollSingleEvolution(ChestType.silver);
      expect(result.evolved, isFalse);
      expect(result.newTier, ChestType.silver);
    });

    test('returns current tier on error', () async {
      setError();
      final result = await service.rollSingleEvolution(ChestType.silver);
      expect(result.evolved, isFalse);
      expect(result.newTier, ChestType.silver);
    });
  });

  group('runGacha', () {
    test('evolves step by step over three attempts', () async {
      setQueue([
        <String, Object?>{'evolved': true, 'newTier': 'silver'},
        <String, Object?>{'evolved': true, 'newTier': 'gold'},
        <String, Object?>{'evolved': true, 'newTier': 'legendary'},
      ]);
      final result = await service.runGacha(ChestType.bronze);
      expect(result.finalType, ChestType.legendary);
      expect(result.attempts.length, 3);
      expect(result.attempts.every((a) => a.upgraded), isTrue);
      expect(requests[0]?['currentTier'], 'bronze');
      expect(requests[1]?['currentTier'], 'silver');
      expect(requests[2]?['currentTier'], 'gold');
    });

    test('does not call the server when starting at legendary', () async {
      final result = await service.runGacha(ChestType.legendary);
      expect(result.finalType, ChestType.legendary);
      expect(result.attempts.length, 3);
      expect(result.attempts.every((a) => a.upgraded), isFalse);
      expect(requests, isEmpty);
    });

    test('records partial progress when the server fails mid-way', () async {
      setQueue([
        <String, Object?>{'evolved': true, 'newTier': 'gold'},
      ]);
      final result = await service.runGacha(ChestType.bronze);
      expect(result.finalType, ChestType.gold);
      expect(result.attempts.length, 2);
      expect(result.attempts[0].upgraded, isTrue);
      expect(result.attempts[0].typeAfter, ChestType.gold);
      expect(result.attempts[1].upgraded, isFalse);
      expect(result.attempts[1].isFinal, isFalse);
    });

    test('records a failed attempt when the first call fails', () async {
      setError();
      final result = await service.runGacha(ChestType.bronze);
      expect(result.finalType, ChestType.bronze);
      expect(result.attempts.length, 1);
      expect(result.attempts[0].upgraded, isFalse);
    });
  });
}
