import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/repositories/sagen_pass_repository.dart';

void main() {
  late SharedPreferences prefs;
  late SagenPassRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = SagenPassRepositoryImpl(prefs);
  });

  group('SagenPassRepository — defaults', () {
    test('defaults when nothing saved', () {
      expect(repo.currentLevel, 1);
      expect(repo.currentSP, 0);
      expect(repo.claimedLevels, isEmpty);
      expect(repo.seasonStart, DateTime(2026));
      expect(repo.seasonDurationDays, 90);
    });
  });

  group('SagenPassRepository — save', () {
    test('save persists all fields', () {
      final season = DateTime(2026, 3, 1);
      repo.save(12, 340, [3, 5, 10], season);
      expect(repo.currentLevel, 12);
      expect(repo.currentSP, 340);
      expect(repo.claimedLevels, [3, 5, 10]);
      expect(repo.seasonStart, season);
    });

    test('saveLevel updates only level', () {
      repo.save(1, 10, const [], DateTime(2026));
      repo.saveLevel(7);
      expect(repo.currentLevel, 7);
      expect(repo.currentSP, 10);
    });

    test('saveSP updates only sp', () {
      repo.save(1, 10, const [], DateTime(2026));
      repo.saveSP(55);
      expect(repo.currentSP, 55);
      expect(repo.currentLevel, 1);
    });

    test('saveClaimedLevels updates claimed list', () {
      repo.save(1, 0, const [], DateTime(2026));
      repo.saveClaimedLevels([1, 2, 3]);
      expect(repo.claimedLevels, [1, 2, 3]);
    });
  });

  group('SagenPassRepository — data robustness', () {
    test('corrupt JSON falls back to defaults', () {
      prefs.setString('sagen_pass_v1', '{{{{');
      repo = SagenPassRepositoryImpl(prefs);
      expect(repo.currentLevel, 1);
      expect(repo.currentSP, 0);
      expect(repo.claimedLevels, isEmpty);
    });

    test('non-list claimed field returns empty', () {
      prefs.setString('sagen_pass_v1', '{"level":3,"sp":9,"claimed":"bad"}');
      repo = SagenPassRepositoryImpl(prefs);
      expect(repo.claimedLevels, isEmpty);
      expect(repo.currentLevel, 3);
    });

    test('invalid seasonStart falls back to DateTime(2026)', () {
      prefs.setString('sagen_pass_v1', '{"seasonStart":"not-a-date"}');
      repo = SagenPassRepositoryImpl(prefs);
      expect(repo.seasonStart, DateTime(2026));
    });

    test('missing duration falls back to 90', () {
      prefs.setString('sagen_pass_v1', '{"level":2}');
      repo = SagenPassRepositoryImpl(prefs);
      expect(repo.seasonDurationDays, 90);
    });

    test('persisted data survives repository recreation', () {
      repo.save(9, 120, const [1], DateTime(2026, 6, 1));
      final fresh = SagenPassRepositoryImpl(prefs);
      expect(fresh.currentLevel, 9);
      expect(fresh.currentSP, 120);
      expect(fresh.claimedLevels, [1]);
    });
  });
}
