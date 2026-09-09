import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/economic_functions_service.dart';

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

  late EconomicFunctionsService service;
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
          final request = ((message as List)[0] as Map)
              .cast<Object?, Object?>();
          requests.add(request);
          return <Object?>[queue.removeAt(0)];
        });
  }

  void mockFunctionsError({
    String code = 'unavailable',
    String message = 'down',
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? msg,
        ) async {
          requests.add(((msg as List)[0] as Map).cast<Object?, Object?>());
          throw FirebaseFunctionsException(code: code, message: message);
        });
  }

  void mockUnexpectedError() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, (
          Object? msg,
        ) async {
          requests.add(((msg as List)[0] as Map).cast<Object?, Object?>());
          throw Exception('boom');
        });
  }

  Map<Object?, Object?>? lastRequest() =>
      requests.isEmpty ? null : requests.last;
  Map? lastParams() => lastRequest()?['parameters'] as Map?;
  Object? lastFn() => lastRequest()?['functionName'];

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
    EconomicFunctionsService.uidOverride = () => 'user_42';
    service = EconomicFunctionsService.instance;
  });

  tearDown(() {
    EconomicFunctionsService.uidOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(_cloudFunctionsChannel, null);
  });

  group('EconomicFunctionsService', () {
    test('singleton instance exists', () {
      expect(service, isA<EconomicFunctionsService>());
    });

    test('singleton returns same instance', () {
      final b = EconomicFunctionsService.instance;
      expect(identical(service, b), isTrue);
    });

    test('no authenticated user short-circuits without calling', () async {
      EconomicFunctionsService.uidOverride = () => '';
      setQueue([
        <String, Object?>{'ok': true},
      ]);
      final result = await service.addXp(reason: 'lesson_completed');
      expect(result, isNull);
      expect(requests, isEmpty);
    });

    test('createIdempotencyKey is derived from the current uid', () {
      final key = service.createIdempotencyKey('xp');
      expect(key, startsWith('user_42_xp_'));
    });

    test('addXp sends reason and generated idempotency key', () async {
      setQueue([
        <String, Object?>{'xp': 20},
      ]);
      final result = await service.addXp(reason: 'lesson_completed');
      expect(result, {'xp': 20});
      expect(lastFn(), 'addXp');
      final params = lastParams();
      expect(params?['reason'], 'lesson_completed');
      expect(
        params?['idempotencyKey'],
        startsWith('user_42_lesson_completed_'),
      );
      expect(params?.containsKey('lessonId'), isFalse);
      expect(params?.containsKey('achievementId'), isFalse);
    });

    test('addXp passes optional lessonId and achievementId', () async {
      setQueue([<String, Object?>{}]);
      await service.addXp(
        reason: 'achievement_unlocked',
        lessonId: 'l1',
        achievementId: 'a1',
        idempotencyKey: 'fixed-key',
      );
      final params = lastParams();
      expect(params?['lessonId'], 'l1');
      expect(params?['achievementId'], 'a1');
      expect(params?['idempotencyKey'], 'fixed-key');
    });

    test('completeLesson sends full payload with fixed idempotency', () async {
      setQueue([
        <String, Object?>{'levelup': false},
      ]);
      final result = await service.completeLesson(
        lessonId: 'l9',
        xpEarned: 40,
        correctCount: 8,
        totalQuestions: 10,
        perfect: true,
      );
      expect(result, {'levelup': false});
      expect(lastFn(), 'completeLesson');
      final params = lastParams();
      expect(params?['lessonId'], 'l9');
      expect(params?['xpEarned'], 40);
      expect(params?['correctCount'], 8);
      expect(params?['totalQuestions'], 10);
      expect(params?['perfect'], true);
      expect(params?['idempotencyKey'], 'lesson_l9');
    });

    test(
      'completeLesson sends zero defaults when optional counts missing',
      () async {
        setQueue([<String, Object?>{}]);
        await service.completeLesson(lessonId: 'l1', xpEarned: 10);
        final params = lastParams();
        expect(params?['correctCount'], 0);
        expect(params?['totalQuestions'], 0);
        expect(params?['perfect'], false);
      },
    );

    test('processDonation sends amount, method and explicit key', () async {
      setQueue([
        <String, Object?>{'ok': true},
      ]);
      final result = await service.processDonation(
        amount: 2.5,
        method: 'stripe',
        idempotencyKey: 'don_1',
      );
      expect(result, {'ok': true});
      expect(lastFn(), 'processDonation');
      final params = lastParams();
      expect(params?['amount'], 2.5);
      expect(params?['method'], 'stripe');
      expect(params?['idempotencyKey'], 'don_1');
    });

    test('incrementStreak sends checkIn=false read-only by default', () async {
      setQueue([
        <String, Object?>{'streak': 3},
      ]);
      final result = await service.incrementStreak();
      expect(result, {'streak': 3});
      expect(lastFn(), 'incrementStreak');
      final params = lastParams();
      expect(params?['freezeUsed'], false);
      expect(params?['checkIn'], true);
      expect(params?.containsKey('itemUsed'), isFalse);
      expect(params?.containsKey('activityDay'), isFalse);
    });

    test('incrementStreak forwards shield and backfill fields', () async {
      setQueue([<String, Object?>{}]);
      await service.incrementStreak(
        freezeUsed: true,
        checkIn: true,
        itemUsed: 'titaniumShield',
        activityDay: '2026-09-09',
        activityStreak: 2,
      );
      final params = lastParams();
      expect(params?['freezeUsed'], true);
      expect(params?['checkIn'], true);
      expect(params?['itemUsed'], 'titaniumShield');
      expect(params?['activityDay'], '2026-09-09');
      expect(params?['activityStreak'], 2);
    });

    test('recordDonation sends amount, method and generated key', () async {
      setQueue([
        <String, Object?>{'ok': true},
      ]);
      final result = await service.recordDonation(
        amount: 1.0,
        method: 'paypal',
      );
      expect(result, {'ok': true});
      expect(lastFn(), 'recordDonation');
      final params = lastParams();
      expect(params?['amount'], 1.0);
      expect(params?['method'], 'paypal');
      expect(params?['idempotencyKey'], startsWith('user_42_donation_'));
    });

    test('claimFreeStreakShield sends empty payload', () async {
      setQueue([
        <String, Object?>{'granted': true},
      ]);
      final result = await service.claimFreeStreakShield();
      expect(result, {'granted': true});
      expect(lastFn(), 'claimFreeStreakShield');
      expect(lastParams(), isEmpty);
    });

    test('rethrows FirebaseFunctionsException from the server', () async {
      mockFunctionsError(code: 'not-found', message: 'nope');
      await expectLater(
        service.addXp(reason: 'lesson_completed'),
        throwsA(
          isA<FirebaseFunctionsException>().having(
            (e) => e.code,
            'code',
            'not-found',
          ),
        ),
      );
    });

    test('rethrows unexpected transport errors', () async {
      mockUnexpectedError();
      await expectLater(
        service.recordDonation(amount: 1.0, method: 'stripe'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'toString',
            contains('boom'),
          ),
        ),
      );
    });

    test('a null response is forwarded as null without crashing', () async {
      setQueue([null]);
      final result = await service.incrementStreak();
      expect(result, isNull);
    });
  });
}
