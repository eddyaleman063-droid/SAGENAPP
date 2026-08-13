import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/core/result.dart';
import 'package:sagen/services/gamification_cloud_service.dart';

import '../helpers/firebase_test_helper.dart';

const _cloudFunctionsChannel = BasicMessageChannel<Object?>(
  'dev.flutter.pigeon.cloud_functions_platform_interface.CloudFunctionsHostApi.call',
  StandardMessageCodec(),
);

void mockFunctionsResult(Object? payload) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
          (Object? message) async => <Object?>[payload]);
}

void mockFunctionsError(PlatformException error) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
          (Object? message) async => <Object?>[error.code, error.message, error.details]);
}

void resetFunctionsMock() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
}

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

  late GamificationCloudService service;

  setUp(() async {
    resetFunctionsMock();
    TestFirebaseCoreHostApi.setUp(_FakeCoreHostApi());
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    setupFirebaseMocks();
    service = GamificationCloudService.instance;
  });

  group('claimDailyChestResult', () {
    test('returns default rewards when response is not already claimed', () async {
      mockFunctionsResult({'xp': 25, 'chestType': 'silver'});
      final result = await service.claimDailyChestResult();
      expect(result.isOk, isTrue);
      expect(result.value, {'xp': 25, 'chestType': 'silver', 'alreadyClaimed': false});
    });

    test('falls back to defaults when xp/chestType are missing', () async {
      mockFunctionsResult(<String, Object?>{});
      final result = await service.claimDailyChestResult();
      expect(result.value, {'xp': 10, 'chestType': 'bronze', 'alreadyClaimed': false});
    });

    test('handles non-map response as already claimed', () async {
      mockFunctionsResult('not-a-map');
      final result = await service.claimDailyChestResult();
      expect(result.value, {'alreadyClaimed': true});
    });

    test('returns alreadyClaimed when flag is true', () async {
      mockFunctionsResult({'alreadyClaimed': true});
      final result = await service.claimDailyChestResult();
      expect(result.value, {'alreadyClaimed': true});
    });

    test('returns alreadyClaimed on null response', () async {
      mockFunctionsResult(null);
      final result = await service.claimDailyChestResult();
      expect(result.value, {'alreadyClaimed': true});
    });

    test('returns error when function throws', () async {
      mockFunctionsError(PlatformException(
        code: 'unavailable',
        message: 'down',
        details: {'code': 'functions/unavailable'},
      ));
      final result = await service.claimDailyChestResult();
      expect(result.isError, isTrue);
      expect(result.error, isA<NetworkError>());
    });
  });

  group('claimAdRewardResult', () {
    test('returns default xp when limit is not reached', () async {
      mockFunctionsResult({'xp': 75});
      final result = await service.claimAdRewardResult();
      expect(result.isOk, isTrue);
      expect(result.value, {'xp': 75, 'limitReached': false});
    });

    test('falls back to 50 xp when missing', () async {
      mockFunctionsResult(<String, Object?>{});
      final result = await service.claimAdRewardResult();
      expect(result.value, {'xp': 50, 'limitReached': false});
    });

    test('returns limitReached when flag is true', () async {
      mockFunctionsResult({'limitReached': true});
      final result = await service.claimAdRewardResult();
      expect(result.value, {'limitReached': true});
    });

    test('returns error on non-Firebase exception', () async {
      mockFunctionsError(PlatformException(code: 'boom'));
      final result = await service.claimAdRewardResult();
      expect(result.isError, isTrue);
      expect(result.error, isA<NetworkError>());
    });
  });

  group('earnSPResult', () {
    test('returns sp and level', () async {
      mockFunctionsResult({'sp': 42, 'level': 3});
      final result = await service.earnSPResult();
      expect(result.isOk, isTrue);
      expect(result.value, {'sp': 42, 'level': 3});
    });

    test('falls back to level 1', () async {
      mockFunctionsResult({'sp': 10});
      final result = await service.earnSPResult();
      expect(result.value, {'sp': 10, 'level': 1});
    });

    test('passes through the reason and does not send an amount', () async {
      Map? captured;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
              (Object? message) async {
        captured = ((message as List)[0] as Map)['parameters'] as Map?;
        return <Object?>[
          <String, Object?>{'sp': 5, 'level': 1},
        ];
      });
      await service.earnSPResult(reason: 'challenge');
      expect(captured?['amount'], isNull);
      expect(captured?['reason'], 'challenge');
    });

    test('defaults reason to lesson', () async {
      Map? captured;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel,
              (Object? message) async {
        captured = ((message as List)[0] as Map)['parameters'] as Map?;
        return <Object?>[
          <String, Object?>{'sp': 5, 'level': 1},
        ];
      });
      await service.earnSPResult();
      expect(captured?['reason'], 'lesson');
    });

    test('returns SyncError on null response', () async {
      mockFunctionsResult(null);
      final result = await service.earnSPResult();
      expect(result.isError, isTrue);
      expect(result.error, isA<SyncError>());
    });

    test('returns error when function throws', () async {
      mockFunctionsError(PlatformException(
        code: 'unavailable',
        message: 'down',
        details: {'code': 'functions/unavailable'},
      ));
      final result = await service.earnSPResult();
      expect(result.isError, isTrue);
      expect(result.error, isA<NetworkError>());
    });
  });

  group('claimPassRewardResult', () {
    test('returns reward data', () async {
      mockFunctionsResult({
        'reward': 'xp',
        'amount': 100,
        'claimedLevels': [1],
        'seasonStart': 1,
      });
      final result = await service.claimPassRewardResult(1);
      expect(result.isOk, isTrue);
      expect(result.value?['reward'], 'xp');
      expect(result.value?['amount'], 100);
      expect(result.value?['alreadyClaimed'], isFalse);
    });

    test('falls back to xp reward and amount 0', () async {
      mockFunctionsResult(<String, Object?>{});
      final result = await service.claimPassRewardResult(1);
      expect(result.value?['reward'], 'xp');
      expect(result.value?['amount'], 0);
    });

    test('returns alreadyClaimed when flag is true', () async {
      mockFunctionsResult({'alreadyClaimed': true});
      final result = await service.claimPassRewardResult(1);
      expect(result.value, {'alreadyClaimed': true});
    });

    test('returns error when function throws', () async {
      mockFunctionsError(PlatformException(
        code: 'unavailable',
        message: 'down',
        details: {'code': 'functions/unavailable'},
      ));
      final result = await service.claimPassRewardResult(1);
      expect(result.isError, isTrue);
      expect(result.error, isA<NetworkError>());
    });
  });

  group('getSagenPassSeasonResult', () {
    test('returns season data', () async {
      mockFunctionsResult({'seasonStart': 42, 'level': 4, 'sp': 9, 'claimed': [1, 2]});
      final result = await service.getSagenPassSeasonResult();
      expect(result.isOk, isTrue);
      expect(result.value?['seasonStart'], 42);
      expect(result.value?['level'], 4);
      expect(result.value?['sp'], 9);
      expect(result.value?['claimed'], [1, 2]);
    });

    test('falls back to level 1', () async {
      mockFunctionsResult(<String, Object?>{});
      final result = await service.getSagenPassSeasonResult();
      expect(result.value?['level'], 1);
      expect(result.value?['sp'], 0);
    });

    test('returns SyncError on null response', () async {
      mockFunctionsResult(null);
      final result = await service.getSagenPassSeasonResult();
      expect(result.isError, isTrue);
      expect(result.error, isA<SyncError>());
    });
  });

  group('legacy methods', () {
    test('claimDailyChest returns value when ok', () async {
      mockFunctionsResult({'xp': 10});
      final value = await service.claimDailyChest();
      expect(value, isNotNull);
      expect(value?['alreadyClaimed'], isFalse);
    });

    test('claimDailyChest returns null on error', () async {
      mockFunctionsError(PlatformException(code: 'boom'));
      expect(await service.claimDailyChest(), isNull);
    });

    test('claimAdReward returns value when ok', () async {
      mockFunctionsResult({'xp': 50});
      expect(await service.claimAdReward(), isNotNull);
    });

    test('earnSP returns value when ok', () async {
      mockFunctionsResult({'sp': 5, 'level': 1});
      expect(await service.earnSP(), isNotNull);
    });

    test('claimPassReward returns value when ok', () async {
      mockFunctionsResult({'reward': 'xp'});
      expect(await service.claimPassReward(1), isNotNull);
    });

    test('getSagenPassSeason returns value when ok', () async {
      mockFunctionsResult({'level': 1});
      expect(await service.getSagenPassSeason(), isNotNull);
    });
  });
}
