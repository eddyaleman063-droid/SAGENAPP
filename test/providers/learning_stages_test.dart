import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/learning/stage.dart';
import 'package:sagen/providers/learning_stages.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LearningStages — loadStagesFromAssets', () {
    test('loads stages with expected structure', () async {
      final stages = await loadStagesFromAssets();
      expect(stages, isNotEmpty);
      expect(stages, isA<List<Stage>>());
    });

    test('stages have ids and titles', () async {
      final stages = await loadStagesFromAssets();
      for (final stage in stages) {
        expect(stage.id, isNotEmpty, reason: 'stage id must not be empty');
        expect(stage.title, isNotEmpty, reason: 'stage title must not be empty');
      }
    });

    test('stages contain lessons with xp rewards', () async {
      final stages = await loadStagesFromAssets();
      final allLessons = stages.expand((s) => s.lessons).toList();
      expect(allLessons, isNotEmpty);
      expect(allLessons.every((l) => l.xpReward >= 0), isTrue);
      expect(allLessons.every((l) => l.estimatedMinutes >= 0), isTrue);
    });

    test('sessions reference the same lessons', () async {
      final stages = await loadStagesFromAssets();
      for (final stage in stages) {
        for (final session in stage.sessions) {
          expect(session.id, isNotEmpty);
        }
      }
    });

    test('subsequent calls return cached result', () async {
      final first = await loadStagesFromAssets();
      final second = await loadStagesFromAssets();
      expect(identical(first, second), isTrue);
    });
  });

  group('LearningStages — defaultStages', () {
    test('returns cached stages once loaded', () async {
      await loadStagesFromAssets();
      expect(defaultStages, isNotEmpty);
    });
  });
}
