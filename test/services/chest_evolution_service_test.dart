import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';
import 'package:sagen/models/chest_evolution.dart';

void main() {
  group('EvolutionAttempt', () {
    test('construction with all fields', () {
      const attempt = EvolutionAttempt(
        index: 0,
        typeBefore: ChestType.bronze,
        typeAfter: ChestType.silver,
        upgraded: true,
        isFinal: false,
      );
      expect(attempt.index, 0);
      expect(attempt.typeBefore, ChestType.bronze);
      expect(attempt.typeAfter, ChestType.silver);
      expect(attempt.upgraded, true);
      expect(attempt.isFinal, false);
    });
  });

  group('ChestEvolutionResult', () {
    test('construction with attempts', () {
      const result = ChestEvolutionResult(
        finalType: ChestType.gold,
        attempts: [
          EvolutionAttempt(
            index: 0,
            typeBefore: ChestType.bronze,
            typeAfter: ChestType.silver,
            upgraded: true,
            isFinal: false,
          ),
          EvolutionAttempt(
            index: 1,
            typeBefore: ChestType.silver,
            typeAfter: ChestType.gold,
            upgraded: true,
            isFinal: true,
          ),
        ],
      );
      expect(result.finalType, ChestType.gold);
      expect(result.attempts, hasLength(2));
    });
  });

  group('SingleEvolutionResult', () {
    test('evolved result', () {
      const result = SingleEvolutionResult(
        newTier: ChestType.silver,
        evolved: true,
      );
      expect(result.newTier, ChestType.silver);
      expect(result.evolved, true);
    });

    test('no evolution result', () {
      const result = SingleEvolutionResult(
        newTier: ChestType.bronze,
        evolved: false,
      );
      expect(result.newTier, ChestType.bronze);
      expect(result.evolved, false);
    });
  });
}
