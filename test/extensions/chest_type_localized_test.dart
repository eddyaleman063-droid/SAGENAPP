import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';

void main() {
  group('ChestType', () {
    test('label returns correct Spanish names', () {
      expect(ChestType.bronze.label, 'Bronce');
      expect(ChestType.silver.label, 'Plata');
      expect(ChestType.gold.label, 'Oro');
      expect(ChestType.legendary.label, 'Legendario');
    });

    test('label covers all enum values', () {
      for (final type in ChestType.values) {
        expect(type.label, isNotEmpty);
      }
    });

    test('color returns valid Color for each type', () {
      for (final type in ChestType.values) {
        final color = type.color;
        expect(color, isNotNull);
      }
    });

    test('glowColor returns valid Color for each type', () {
      for (final type in ChestType.values) {
        final glow = type.glowColor;
        expect(glow, isNotNull);
      }
    });

    test('all values covered in switch statements', () {
      expect(ChestType.values.length, 4);
    });

    test('legendary has distinct purple color', () {
      expect(ChestType.legendary.color, isNot(equals(ChestType.gold.color)));
    });
  });
}
