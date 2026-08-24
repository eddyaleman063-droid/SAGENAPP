import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/sage_emotion_service.dart';

void main() {
  final service = SageEmotionService();

  group('emotion helpers', () {
    test('shouldAnimateEmotionChange returns false for identical emotions', () {
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.happy,
          SageEmotion.happy,
        ),
        isFalse,
      );
    });

    test('animates on crying/furious transitions', () {
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.crying,
          SageEmotion.calm,
        ),
        isTrue,
      );
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.furious,
          SageEmotion.sad,
        ),
        isTrue,
      );
    });

    test('does not animate within neutral or close sets', () {
      expect(
        service.shouldAnimateEmotionChange(SageEmotion.calm, SageEmotion.happy),
        isFalse,
      );
      expect(
        service.shouldAnimateEmotionChange(
          SageEmotion.excited,
          SageEmotion.laughing,
        ),
        isFalse,
      );
    });

    test('isSignificantMoodShift detects intense emotions', () {
      expect(
        service.isSignificantMoodShift(SageEmotion.calm, SageEmotion.furious),
        isTrue,
      );
      expect(
        service.isSignificantMoodShift(SageEmotion.crying, SageEmotion.calm),
        isTrue,
      );
      expect(
        service.isSignificantMoodShift(SageEmotion.happy, SageEmotion.excited),
        isFalse,
      );
    });

    test('canIdleBreathe allows calm idle emotions', () {
      expect(service.canIdleBreathe(SageEmotion.calm), isTrue);
      expect(service.canIdleBreathe(SageEmotion.whistling), isTrue);
      expect(service.canIdleBreathe(SageEmotion.wink), isFalse);
      expect(service.canIdleBreathe(SageEmotion.excited), isFalse);
    });
  });

  group('asset paths', () {
    test('every emotion maps to a png asset path', () {
      for (final emotion in SageEmotion.values) {
        expect(
          emotion.assetPath,
          startsWith('assets/mascot/emotions/sage_'),
          reason: 'Unexpected path for $emotion',
        );
        expect(emotion.assetPath, endsWith('.png'));
      }
    });

    test('duplicate file names are intentional aliases', () {
      expect(SageEmotion.happy.assetPath, SageEmotion.happyWings.assetPath);
      expect(SageEmotion.excited.assetPath, SageEmotion.excitedWave.assetPath);
    });
  });
}
