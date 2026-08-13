import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/sagen_pass.dart';
import 'package:sagen/providers/streak_provider.dart';
import 'package:sagen/services/icon_manager.dart';
import 'package:sagen/services/streak_service.dart';

const _iconChannel = MethodChannel('flutter_dynamic_icon_plus');

StreakState streak({
  int current = 5,
  int freezes = 0,
  bool atRisk = false,
}) {
  return StreakState(
    status: StreakStatus(
      currentStreak: current,
      longestStreak: current,
      lastActivityDate: DateTime(2026, 1, 1),
      streakFreezes: freezes,
      isAtRisk: atRisk,
      message: 'msg',
      tier: 'basic',
    ),
    totalCheckIns: current,
    perfectWeeks: 0,
    missionCompleted: false,
    weeklyStats: const {},
    heatmapData: const {},
    monthlyData: const {},
    streakHistory: const [],
    emotionalMessages: const [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <String>[];

  setUp(() {
    calls.clear();
    IconManager.instance.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_iconChannel, (MethodCall call) async {
      calls.add(call.method);
      if (call.method == 'supportsAlternateIcons') return true;
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_iconChannel, null);
  });

  group('IconManager._evaluateIcon', () {
    test('frozen streak wins over everything', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 10, freezes: 1, atRisk: true),
        SagenPass(),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageFrozen);
    });

    test('zero streak returns crying', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 0),
        SagenPass(),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageCrying);
    });

    test('100+ streak with premium pass returns golden', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 150),
        SagenPass(currentLevel: 30),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageGolden);
    });

    test('100+ streak without premium returns on fire', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 100),
        SagenPass(currentLevel: 5),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageOnFire);
    });

    test('premium pass with 7+ streak returns golden', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 7),
        SagenPass(currentLevel: 25),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageGolden);
    });

    test('premium pass under 7 streak is not golden', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(current: 6),
        SagenPass(currentLevel: 25),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, isNot(SageAppIcon.sageGolden));
    });

    test('late night hours return sleeping', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(),
        SagenPass(),
        now: DateTime(2026, 1, 1, 3),
      );
      expect(result, SageAppIcon.sageSleeping);
    });

    test('midday hours return curious', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(),
        SagenPass(),
        now: DateTime(2026, 1, 1, 13),
      );
      expect(result, SageAppIcon.sageCurious);
    });

    test('at-risk evening hours return annoyed', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(atRisk: true),
        SagenPass(),
        now: DateTime(2026, 1, 1, 20),
      );
      expect(result, SageAppIcon.sageAnnoyed);
    });

    test('at-risk late night hours return furious', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(atRisk: true),
        SagenPass(),
        now: DateTime(2026, 1, 1, 23),
      );
      expect(result, SageAppIcon.sageFurious);
    });

    test('default icon otherwise', () {
      final result = IconManager.instance.evaluateIconForTesting(
        streak(atRisk: true),
        SagenPass(),
        now: DateTime(2026, 1, 1, 9),
      );
      expect(result, SageAppIcon.sageDefault);
    });
  });

  group('IconManager.evaluateAndApply', () {
    test('applies an icon via platform channel', () async {
      IconManager.instance.evaluateAndApply(
        streak(current: 150),
        SagenPass(currentLevel: 30),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(calls, contains('setAlternateIconName'));
    });

    test('resets to default icon when evaluating default', () async {
      final s = streak();
      IconManager.instance.evaluateAndApply(s, SagenPass(currentLevel: 30));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      IconManager.instance.reset();
      final callsAfterReset = calls.length;
      IconManager.instance.evaluateAndApply(s, SagenPass(currentLevel: 30));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(calls.length, greaterThan(callsAfterReset));
    });
  });
}
