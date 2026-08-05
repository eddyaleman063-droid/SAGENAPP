import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/protection_level.dart';

void main() {
  group('protectionLevelForScore', () {
    test('returns 1 for score 0', () {
      expect(protectionLevelForScore(0), 1);
    });

    test('returns 5 for score 200', () {
      expect(protectionLevelForScore(200), 5);
    });

    test('returns 10 for score 500', () {
      expect(protectionLevelForScore(500), 10);
    });

    test('returns 20 for score 1200', () {
      expect(protectionLevelForScore(1200), 20);
    });

    test('returns 35 for score 2500', () {
      expect(protectionLevelForScore(2500), 35);
    });

    test('returns 50 for score 5000', () {
      expect(protectionLevelForScore(5000), 50);
    });

    test('returns max tier for score above 5000', () {
      expect(protectionLevelForScore(10000), 50);
    });

    test('returns previous tier for score between tiers', () {
      expect(protectionLevelForScore(100), 1);
    });
  });

  group('protectionNameForLevel', () {
    test('returns Basic for level 1', () {
      expect(protectionNameForLevel(1), 'Basic');
    });

    test('returns Protected for level 5', () {
      expect(protectionNameForLevel(5), 'Protected');
    });

    test('returns Guardian for level 10', () {
      expect(protectionNameForLevel(10), 'Guardian');
    });

    test('returns Cyber Shield for level 20', () {
      expect(protectionNameForLevel(20), 'Cyber Shield');
    });

    test('returns Secure Mind for level 35', () {
      expect(protectionNameForLevel(35), 'Secure Mind');
    });

    test('returns Elite Protection for level 50', () {
      expect(protectionNameForLevel(50), 'Elite Protection');
    });
  });

  group('protectionProgress', () {
    test('returns 0.0 at tier start', () {
      expect(protectionProgress(0, 1), 0.0);
    });

    test('returns 1.0 at max tier', () {
      expect(protectionProgress(5000, 50), 1.0);
    });

    test('returns fractional progress between tiers', () {
      final progress = protectionProgress(350, 5);
      expect(progress, greaterThan(0.0));
      expect(progress, lessThan(1.0));
    });
  });

  group('kProtectionTiers', () {
    test('has 6 tiers', () {
      expect(kProtectionTiers.length, 6);
    });

    test('tiers are in ascending order', () {
      for (int i = 1; i < kProtectionTiers.length; i++) {
        expect(
          kProtectionTiers[i].level,
          greaterThan(kProtectionTiers[i - 1].level),
        );
      }
    });
  });
}
