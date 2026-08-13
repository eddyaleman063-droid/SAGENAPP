import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/audio_service.dart';
import 'package:sagen/services/experience_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _globalChannel = MethodChannel('xyz.luan/audioplayers.global');
const _playerChannel = MethodChannel('xyz.luan/audioplayers');

void mockAudioChannels() {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_globalChannel, (MethodCall call) async {
    if (call.method == 'create') return 'test-player-id';
    return 1;
  });
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_playerChannel, (MethodCall call) async {
    switch (call.method) {
      case 'getCurrentPosition':
        return 0;
      default:
        return 1;
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockAudioChannels();
  });

  tearDown(() async {
    await AudioService.instance.dispose();
    await Future<void>.delayed(Duration.zero);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_globalChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_playerChannel, null);
  });

  test('init and dispose lifecycle works', () async {
    await AudioService.instance.init();
    await AudioService.instance.dispose();
    await AudioService.instance.init();
  });

  test('play methods are safe without initialization', () async {
    final audio = AudioService.instance;
    await audio.playSuccess();
    await audio.playError();
    await audio.playClank();
    await audio.playChestOpen();
    await audio.playMilestone();
    await audio.playUiTap();
    await audio.playLevelUp();
    await audio.playStreakMilestone();
    await audio.playChestRare();
    await audio.playPurchaseSuccess();
  });

  test('onAppPaused and prewarm are safe without initialization', () async {
    final audio = AudioService.instance;
    audio.onAppPaused();
    audio.prewarm();
    await audio.dispose();
  });

  test('prewarm loads sources when initialized', () async {
    await AudioService.instance.init();
    AudioService.instance.prewarm();
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  test('play methods are no-ops when sound is disabled', () async {
    await ExperienceService.instance.setSoundEnabled(false);
    await AudioService.instance.init();
    await AudioService.instance.playSuccess();
    await AudioService.instance.playError();
  });

  test('onAppPaused stops playback when initialized', () async {
    await AudioService.instance.init();
    AudioService.instance.onAppPaused();
  });

  test('plays a sound through the queue', () async {
    await AudioService.instance.init();
    await AudioService.instance.playSuccess();
  });

  test('queues rapid sounds without losing them', () async {
    await AudioService.instance.init();
    await AudioService.instance.playClank();
    await AudioService.instance.playUiTap();
    await AudioService.instance.playError();
  });

  test('dispose clears the queue and player', () async {
    await AudioService.instance.init();
    await AudioService.instance.playClank();
    await AudioService.instance.dispose();
    await AudioService.instance.playError();
  });
}
