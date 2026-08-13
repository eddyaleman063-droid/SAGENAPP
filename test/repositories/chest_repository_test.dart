import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/repositories/chest_repository.dart';

void main() {
  late SharedPreferences prefs;
  late ChestRepositoryImpl repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = ChestRepositoryImpl(prefs);
  });

  group('ChestRepository — empty state', () {
    test('evolution history starts empty', () {
      expect(repo.evolutionHistory, isEmpty);
    });

    test('total chests opened is zero', () {
      expect(repo.totalChestsOpened, 0);
    });

    test('chest type counts start empty', () {
      expect(repo.chestTypeCounts, isEmpty);
    });
  });

  group('ChestRepository — evolution history', () {
    test('recordEvolution stores a single entry', () {
      repo.recordEvolution(
        initialType: ChestType.bronze,
        finalType: ChestType.gold,
        attempts: [
          {'step': 1},
          {'step': 2},
        ],
      );
      final history = repo.evolutionHistory;
      expect(history, hasLength(1));
      expect(history.first['initial'], 'bronze');
      expect(history.first['final'], 'gold');
      expect(history.first['attempts'], isA<List>());
      expect(history.first['timestamp'], isA<String>());
    });

    test('recordEvolution keeps only last 100 entries', () {
      for (var i = 0; i < 120; i++) {
        repo.recordEvolution(
          initialType: ChestType.bronze,
          finalType: ChestType.silver,
          attempts: const [],
        );
      }
      final history = repo.evolutionHistory;
      expect(history, hasLength(100));
    });

    test('corrupt evolution JSON is ignored', () {
      prefs.setString('chest_evolution_history', '{not valid json');
      expect(repo.evolutionHistory, isEmpty);
    });
  });

  group('ChestRepository — type counts', () {
    test('incrementChestCount accumulates per type', () {
      repo.incrementChestCount(ChestType.bronze);
      repo.incrementChestCount(ChestType.bronze);
      repo.incrementChestCount(ChestType.gold);
      expect(repo.chestTypeCounts[ChestType.bronze], 2);
      expect(repo.chestTypeCounts[ChestType.gold], 1);
      expect(repo.totalChestsOpened, 3);
    });

    test('unknown chest type in stored data is skipped', () {
      prefs.setString(
        'chest_type_counts',
        '{"bronze":3,"not_a_type":"x","gold":2}',
      );
      final counts = repo.chestTypeCounts;
      expect(counts, hasLength(2));
      expect(counts[ChestType.bronze], 3);
      expect(counts[ChestType.gold], 2);
    });

    test('corrupt counts JSON is ignored', () {
      prefs.setString('chest_type_counts', 'nope');
      expect(repo.chestTypeCounts, isEmpty);
      expect(repo.totalChestsOpened, 0);
    });
  });

  group('ChestRepository — clearHistory', () {
    test('clears history and counts', () {
      repo.incrementChestCount(ChestType.gold);
      repo.recordEvolution(
        initialType: ChestType.bronze,
        finalType: ChestType.gold,
        attempts: const [],
      );
      repo.clearHistory();
      expect(repo.evolutionHistory, isEmpty);
      expect(repo.chestTypeCounts, isEmpty);
    });
  });
}
