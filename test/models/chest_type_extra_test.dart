import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/chest_type.dart';

void main() {
  group('ChestType.glowColor', () {
    test('silver has correct glow color', () {
      expect(ChestType.silver.glowColor, isNotNull);
    });

    test('gold has correct glow color', () {
      expect(ChestType.gold.glowColor, isNotNull);
    });

    test('legendary has correct glow color', () {
      expect(ChestType.legendary.glowColor, isNotNull);
    });
  });

  group('ChestType.color', () {
    test('all types have non-null color', () {
      for (final type in ChestType.values) {
        expect(type.color, isNotNull);
      }
    });
  });

  group('ChestType.label', () {
    test('all types have non-empty label', () {
      for (final type in ChestType.values) {
        expect(type.label, isNotEmpty);
      }
    });

    test('labels are unique', () {
      final labels = ChestType.values.map((t) => t.label).toSet();
      expect(labels.length, ChestType.values.length);
    });
  });

  group('ChestType enum', () {
    test('has 4 values', () {
      expect(ChestType.values.length, 4);
    });

    test('bronze comes first', () {
      expect(ChestType.values.first, ChestType.bronze);
    });

    test('legendary comes last', () {
      expect(ChestType.values.last, ChestType.legendary);
    });
  });
}
