import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/audio_service.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:sagen/services/feedback_coordinator.dart';

class _FakeExperience implements ExperienceService {
  _FakeExperience({this.haptic = true, this.sound = true});

  bool haptic;
  bool sound;

  @override
  bool get hapticEnabled => haptic;

  @override
  bool get soundEnabled => sound;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAudio implements AudioService {
  int successes = 0;
  int errors = 0;
  int chestOpens = 0;
  int chestRares = 0;
  int clanks = 0;

  @override
  Future<void> playSuccess() async => successes++;

  @override
  Future<void> playError() async => errors++;

  @override
  Future<void> playChestOpen() async => chestOpens++;

  @override
  Future<void> playChestRare() async => chestRares++;

  @override
  Future<void> playClank() async => clanks++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final hapticTypes = <String>[];

  setUp(() {
    hapticTypes.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'HapticFeedback.vibrate') {
            hapticTypes.add(call.arguments as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  test('success triggers haptic medium and success sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: audio,
    );
    coordinator.success();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.mediumImpact'));
    expect(audio.successes, 1);
  });

  test('success skips haptic when disabled but keeps sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(haptic: false),
      audio: audio,
    );
    coordinator.success();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, isEmpty);
    expect(audio.successes, 1);
  });

  test('success skips sound when disabled but keeps haptic', () async {
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(sound: false),
      audio: _FakeAudio(),
    );
    coordinator.success();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.mediumImpact'));
  });

  test('error triggers haptic heavy and error sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: audio,
    );
    coordinator.error();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.heavyImpact'));
    expect(audio.errors, 1);
  });

  test('chestOpen fires two haptics and chest sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: audio,
    );
    coordinator.chestOpen();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(hapticTypes.length, 2);
    expect(audio.chestOpens, 1);
  });

  test('chestEvolve fires heavy then medium and rare sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: audio,
    );
    coordinator.chestEvolve();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(hapticTypes.length, 2);
    expect(hapticTypes, contains('HapticFeedbackType.heavyImpact'));
    expect(hapticTypes, contains('HapticFeedbackType.mediumImpact'));
    expect(audio.chestRares, 1);
  });

  test('chestFail triggers light haptic and clank sound', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: audio,
    );
    coordinator.chestFail();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.lightImpact'));
    expect(audio.clanks, 1);
  });

  test('chestOpen does nothing when haptic and sound are disabled', () async {
    final audio = _FakeAudio();
    final coordinator = FeedbackCoordinator(
      experience: _FakeExperience(haptic: false, sound: false),
      audio: audio,
    );
    coordinator.chestOpen();
    await Future<void>.delayed(const Duration(milliseconds: 150));
    expect(hapticTypes, isEmpty);
    expect(audio.chestOpens, 0);
  });

  test('lightHaptic only fires when enabled', () async {
    FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: _FakeAudio(),
    ).lightHaptic();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.lightImpact'));

    hapticTypes.clear();
    FeedbackCoordinator(
      experience: _FakeExperience(haptic: false),
      audio: _FakeAudio(),
    ).lightHaptic();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, isEmpty);
  });

  test('mediumHaptic only fires when enabled', () async {
    FeedbackCoordinator(
      experience: _FakeExperience(),
      audio: _FakeAudio(),
    ).mediumHaptic();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, contains('HapticFeedbackType.mediumImpact'));

    hapticTypes.clear();
    FeedbackCoordinator(
      experience: _FakeExperience(haptic: false),
      audio: _FakeAudio(),
    ).mediumHaptic();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(hapticTypes, isEmpty);
  });
}
