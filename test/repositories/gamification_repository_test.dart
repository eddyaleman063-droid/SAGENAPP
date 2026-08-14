import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/repositories/gamification_repository.dart';

void main() {
  late SharedPreferences prefs;
  late GamificationRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = GamificationRepositoryImpl(prefs);
  });

  group('Daily Chest - Midnight Reset', () {
    test('new day generates new chest', () {
      expect(repo.canClaimDailyChest, isTrue);
    });

    test('claiming chest marks it as claimed', () {
      repo.canClaimDailyChest; // triggers chest generation
      repo.claimDailyChest();
      expect(repo.canClaimDailyChest, isFalse);
    });

    test('claiming twice throws error', () {
      repo.canClaimDailyChest;
      repo.claimDailyChest();
      expect(() => repo.claimDailyChest(), throwsStateError);
    });
  });

  group('No-Acumulación', () {
    test('unclaimed chest expires at midnight', () {
      repo.canClaimDailyChest; // creates chest for today
      // Simulate midnight by changing stored date
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      prefs.setString(
        'gamification_last_claim_date',
        yesterday.toIso8601String().substring(0, 10),
      );
      repo.checkMidnightReset();
      // Chest should be expired
      repo = GamificationRepositoryImpl(prefs);
      repo.checkMidnightReset();
      // New day should generate a NEW chest, not carry over the old one
      expect(repo.canClaimDailyChest, isTrue);
    });
  });

  group('Anti-Cheat', () {
    test('future date blocks chest claim', () {
      repo.canClaimDailyChest;
      // Simulate clock manipulation by setting a future date (UTC-anchored,
      // matching the repository's UTC day key).
      final tomorrow = DateTime.now().toUtc().add(const Duration(days: 1));
      prefs.setString(
        'gamification_last_claim_date',
        tomorrow.toIso8601String().substring(0, 10),
      );
      repo = GamificationRepositoryImpl(prefs);
      repo.canClaimDailyChest; // re-evaluates
      expect(() => repo.claimDailyChest(), throwsA(isA<Exception>()));
    });
  });

  group('Missions', () {
    test('incrementMission updates progress', () {
      repo.incrementMission('analyze_links');
      expect(repo.isMissionComplete('analyze_links', target: 1), isTrue);
    });

    test('mission target not reached returns false', () {
      expect(repo.isMissionComplete('analyze_links', target: 3), isFalse);
      repo.incrementMission('analyze_links');
      expect(repo.isMissionComplete('analyze_links', target: 3), isFalse);
      repo.incrementMission('analyze_links');
      repo.incrementMission('analyze_links');
      expect(repo.isMissionComplete('analyze_links', target: 3), isTrue);
    });
  });
}
