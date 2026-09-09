import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/services/inventory_service.dart';

import '../helpers/firebase_test_helper.dart';

const _cloudFunctionsChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call',
  StandardMessageCodec(),
);

class _FakeCoreHostApi extends TestFirebaseCoreHostApi {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async => [];

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async =>
      CoreFirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      );

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async => CoreInitializeResponse(
    name: appName,
    options: initializeAppRequest,
    isAutomaticDataCollectionEnabled: true,
    pluginConstants: <String, Object?>{},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InventoryService service;
  final requests = <Map<Object?, Object?>>[];
  final queue = <Object?>[];

  void setQueue(List<Object?> responses) {
    queue
      ..clear()
      ..addAll(responses);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? message,
        ) async {
          requests.add(((message as List)[0] as Map).cast<Object?, Object?>());
          return <Object?>[queue.removeAt(0)];
        });
  }

  void setError() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? message,
        ) async {
          requests.add(((message as List)[0] as Map).cast<Object?, Object?>());
          throw Exception('boom');
        });
  }

  Map<Object?, Object?>? lastRequest() =>
      requests.isEmpty ? null : requests.last;
  Object? lastFn() => lastRequest()?['functionName'];
  Map? lastParams() => lastRequest()?['parameters'] as Map?;

  setUp(() async {
    requests.clear();
    queue.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
    TestFirebaseCoreHostApi.setUp(_FakeCoreHostApi());
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    setupFirebaseMocks();
    service = InventoryService.instance;
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
  });

  group('InventoryService', () {
    test('fetchQuantities returns quantities from the snapshot', () async {
      setQueue([
        {
          'specialItems': {'focusElixir': 3, 'timeWarp': 1},
          'cosmetics': <String>[],
          'purchasedXpBoosts': 2,
        },
      ]);
      final result = await service.fetchQuantities();
      expect(result, {
        SpecialItemType.focusElixir: 3,
        SpecialItemType.timeWarp: 1,
      });
      expect(lastFn(), 'getInventory');
    });

    test('fetchSnapshot maps quantities, cosmetics and boosts', () async {
      setQueue([
        {
          'specialItems': {'focusElixir': 2, 'unknown_item': 99},
          'cosmetics': <String>['avatarFrameNeon', 'bogus_name'],
          'purchasedXpBoosts': 4,
        },
      ]);
      final snapshot = await service.fetchSnapshot();
      expect(snapshot, isNotNull);
      expect(snapshot!.quantities[SpecialItemType.focusElixir], 2);
      expect(snapshot.quantities[SpecialItemType.avatarFrameNeon], 1);
      expect(
        snapshot.quantities.containsKey(SpecialItemType.titleCyberSage),
        isFalse,
      );
      expect(snapshot.purchasedXpBoosts, 4);
    });

    test(
      'fetchSnapshot defaults purchasedXpBoosts to 0 when missing',
      () async {
        setQueue([
          {
            'specialItems': {'phoenixFeather': 1},
            'cosmetics': <String>[],
          },
        ]);
        final snapshot = await service.fetchSnapshot();
        expect(snapshot!.purchasedXpBoosts, 0);
      },
    );

    test('fetchSnapshot tolerates malformed purchasedXpBoosts', () async {
      setQueue([
        {
          'specialItems': {'phoenixFeather': 1},
          'cosmetics': <String>[],
          'purchasedXpBoosts': 'lots',
        },
      ]);
      final snapshot = await service.fetchSnapshot();
      expect(snapshot!.purchasedXpBoosts, 0);
    });

    test('fetchSnapshot ignores non-numeric quantities', () async {
      setQueue([
        {
          'specialItems': {'focusElixir': 'many'},
          'cosmetics': <String>[],
        },
      ]);
      final snapshot = await service.fetchSnapshot();
      expect(snapshot!.quantities[SpecialItemType.focusElixir], 0);
    });

    test('fetchSnapshot returns null on non-map data', () async {
      setQueue(['nope']);
      expect(await service.fetchSnapshot(), isNull);
    });

    test('fetchSnapshot returns null when specialItems is not a map', () async {
      setQueue([
        {'specialItems': 'not-a-map', 'cosmetics': <String>[]},
      ]);
      expect(await service.fetchSnapshot(), isNull);
    });

    test('fetchSnapshot returns null on transport error', () async {
      setError();
      expect(await service.fetchSnapshot(), isNull);
      expect(lastFn(), 'getInventory');
    });

    test('fetchQuantities returns null when snapshot is null', () async {
      setError();
      expect(await service.fetchQuantities(), isNull);
    });

    test('useItem sends itemName and quantity', () async {
      setQueue([
        {'success': true},
      ]);
      final ok = await service.useItem(SpecialItemType.titaniumShield);
      expect(ok, isTrue);
      expect(lastFn(), 'useInventoryItem');
      expect(lastParams()?['itemName'], 'titaniumShield');
      expect(lastParams()?['quantity'], 1);
    });

    test('useItem sends an explicit quantity', () async {
      setQueue([
        {'success': true},
      ]);
      final ok = await service.useItem(
        SpecialItemType.focusElixir,
        quantity: 2,
      );
      expect(ok, isTrue);
      expect(lastParams()?['quantity'], 2);
    });

    test('useItem returns false when success flag is missing', () async {
      setQueue([
        {'ok': true},
      ]);
      expect(await service.useItem(SpecialItemType.timeWarp), isFalse);
    });

    test('useItem returns false on non-map data', () async {
      setQueue(['nope']);
      expect(await service.useItem(SpecialItemType.luckBoost), isFalse);
    });

    test('useItem returns false on transport error', () async {
      setError();
      expect(await service.useItem(SpecialItemType.sageMonocle), isFalse);
      expect(lastFn(), 'useInventoryItem');
    });
  });
}
