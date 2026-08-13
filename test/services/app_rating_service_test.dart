import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/app_rating_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _reviewChannel = MethodChannel('dev.britannio.in_app_review');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <String>[];

  setUp(() {
    calls.clear();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_reviewChannel, (MethodCall call) async {
      calls.add(call.method);
      switch (call.method) {
        case 'isAvailable':
          return true;
        case 'requestReview':
          return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_reviewChannel, null);
  });

  test('does not prompt before 5 sessions', () async {
    final service = AppRatingService();
    for (int i = 0; i < 4; i++) {
      await service.onSessionCompleted();
    }
    expect(calls, isEmpty);
  });

  test('prompts at 5 sessions', () async {
    final service = AppRatingService();
    for (int i = 0; i < 5; i++) {
      await service.onSessionCompleted();
    }
    await pumpEventQueue();
    expect(calls, contains('isAvailable'));
    expect(calls, contains('requestReview'));
  });

  test('count is persisted across instances', () async {
    for (int i = 0; i < 4; i++) {
      await AppRatingService().onSessionCompleted();
    }
    await AppRatingService().onSessionCompleted();
    await pumpEventQueue();
    expect(calls, contains('requestReview'));
  });

  test('does not prompt after markRated', () async {
    final service = AppRatingService();
    await service.markRated();
    for (int i = 0; i < 10; i++) {
      await service.onSessionCompleted();
    }
    expect(calls, isEmpty);
  });

  test('does not prompt after markDismissed', () async {
    final service = AppRatingService();
    await service.markDismissed();
    for (int i = 0; i < 10; i++) {
      await service.onSessionCompleted();
    }
    expect(calls, isEmpty);
  });

  test('markRated persists across instances', () async {
    await AppRatingService().markRated();
    final service = AppRatingService();
    for (int i = 0; i < 5; i++) {
      await service.onSessionCompleted();
    }
    expect(calls, isEmpty);
  });

  test('does not prompt when review is unavailable', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_reviewChannel, (MethodCall call) async {
      calls.add(call.method);
      if (call.method == 'isAvailable') return false;
      return null;
    });
    final service = AppRatingService();
    for (int i = 0; i < 5; i++) {
      await service.onSessionCompleted();
    }
    await pumpEventQueue();
    expect(calls, contains('isAvailable'));
    expect(calls, isNot(contains('requestReview')));
  });
}
