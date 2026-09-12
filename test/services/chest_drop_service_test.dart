import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/services/chest_drop_service.dart';
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
    CoreFirebaseOptions options,
  ) async => CoreInitializeResponse(
    name: appName,
    options: options,
    isAutomaticDataCollectionEnabled: true,
    pluginConstants: <String, Object?>{},
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ChestDropService service;

  setUpAll(() async {
    TestFirebaseCoreHostApi.setUp(_FakeCoreHostApi());
    await Firebase.initializeApp();
    setupFirebaseMocks();
  });

  setUp(() async {
    service = ChestDropService.private();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
  });

  test('full reward parses correctly', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          _cloudFunctionsChannel,
          (Object? message) async => <Object?>[
            <String, Object?>{
              'xp': 25,
              'gems': {'added': 7},
              'streakShield': true,
              'xpBoost': true,
              'chestType': 'silver',
              'specialItems': ['luckBoost', 'focusElixir', 'noexiste'],
              'cosmeticUnlocks': ['titleCyberSage'],
            },
          ],
        );

    final result = await service.roll(
      ChestType.silver,
      contextId: 'ctx-1',
      source: 'chest',
      luckBoostActive: true,
    );
    expect(result.xp, 25);
    expect(result.gems, 7);
    expect(result.streakShields, 1);
    expect(result.xpBoost, isTrue);
    expect(result.chestType, ChestType.silver);
    expect(result.specialItems, [
      SpecialItemType.luckBoost,
      SpecialItemType.focusElixir,
    ]);
    expect(result.cosmeticUnlocks, [SpecialItemType.titleCyberSage]);
  });

  test('data without gems returns 0 gems', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          _cloudFunctionsChannel,
          (Object? message) async => <Object?>[
            <String, Object?>{'xp': 10},
          ],
        );

    final result = await service.roll(ChestType.bronze);
    expect(result.gems, 0);
    expect(result.xp, 10);
  });

  test('non-map data returns empty reward', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          _cloudFunctionsChannel,
          (Object? message) async => <Object?>['not a map'],
        );

    final result = await service.roll(ChestType.gold);
    expect(result.xp, 0);
  });

  test('retry succeeds on second attempt', () async {
    var calls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? message,
        ) async {
          calls++;
          if (calls == 1) {
            return <Object?>['functions/unavailable', 'network', null];
          }
          return <Object?>[
            <String, Object?>{'xp': 99},
          ];
        });

    final result = await service.roll(ChestType.bronze);
    expect(calls, 2);
    expect(result.xp, 99);
  });

  test('exhausted retries returns empty reward', () async {
    var calls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? message,
        ) async {
          calls++;
          return <Object?>['functions/unavailable', 'down', null];
        });

    final result = await service.roll(ChestType.legendary);
    expect(calls, 3);
    expect(result.xp, 0);
  });
}
