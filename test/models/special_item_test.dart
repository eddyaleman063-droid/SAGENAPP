import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/special_item.dart';

void main() {
  group('SpecialItemType', () {
    test('has 20 item types', () {
      expect(SpecialItemType.values, hasLength(20));
    });

    test('every type has a non-empty display name', () {
      for (final type in SpecialItemType.values) {
        expect(type.displayName, isNotEmpty, reason: type.name);
      }
    });

    test('every type has a non-empty description', () {
      for (final type in SpecialItemType.values) {
        expect(type.description, isNotEmpty, reason: type.name);
      }
    });

    test('every type has a positive max limit', () {
      for (final type in SpecialItemType.values) {
        expect(type.maxLimit, greaterThan(0), reason: type.name);
      }
    });

    test('rarity tiers are within 0..4', () {
      for (final type in SpecialItemType.values) {
        expect(type.rarityTier, inInclusiveRange(0, 4), reason: type.name);
      }
    });

    test('consumables have higher limits than cosmetics', () {
      for (final type in SpecialItemType.values) {
        if (type.isCosmetic) {
          expect(type.maxLimit, 1, reason: 'cosmetic ${type.name} must be unique');
        } else {
          expect(type.maxLimit, greaterThanOrEqualTo(3),
              reason: 'consumable ${type.name} should allow stock');
        }
      }
    });

    test('isConsumable and isCosmetic are mutually exclusive', () {
      for (final type in SpecialItemType.values) {
        expect(type.isConsumable, isNot(type.isCosmetic), reason: type.name);
      }
    });

    test('all consumables are the six utility items', () {
      final consumables = SpecialItemType.values.where((t) => t.isConsumable).toSet();
      expect(consumables, {
        SpecialItemType.focusElixir,
        SpecialItemType.phoenixFeather,
        SpecialItemType.sageMonocle,
        SpecialItemType.titaniumShield,
        SpecialItemType.luckBoost,
        SpecialItemType.timeWarp,
      });
    });

    test('legendary items exist', () {
      final legendary = SpecialItemType.values.where((t) => t.rarityTier == 4).toSet();
      expect(legendary, isNotEmpty);
    });
  });

  group('SpecialItem', () {
    test('default quantity is 0 and inactive', () {
      const item = SpecialItem(type: SpecialItemType.focusElixir);
      expect(item.quantity, 0);
      expect(item.hasQuantity, isFalse);
      expect(item.isActive, isFalse);
    });

    test('hasQuantity is true when quantity > 0', () {
      const item = SpecialItem(type: SpecialItemType.focusElixir, quantity: 3);
      expect(item.hasQuantity, isTrue);
    });

    test('isActive depends on activeUntil vs now', () {
      final future = DateTime.now().add(const Duration(days: 1));
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(SpecialItem(type: SpecialItemType.focusElixir, activeUntil: future).isActive, isTrue);
      expect(SpecialItem(type: SpecialItemType.focusElixir, activeUntil: past).isActive, isFalse);
    });

    test('copyWith replaces quantity', () {
      const item = SpecialItem(type: SpecialItemType.focusElixir, quantity: 2);
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.type, SpecialItemType.focusElixir);
    });

    test('copyWith preserves quantity when not provided', () {
      const item = SpecialItem(type: SpecialItemType.focusElixir, quantity: 2);
      expect(item.copyWith().quantity, 2);
    });

    test('copyWith can clear activeUntil', () {
      final future = DateTime.now().add(const Duration(days: 1));
      final item = SpecialItem(
        type: SpecialItemType.focusElixir,
        activeUntil: future,
      );
      final cleared = item.copyWith(clearActive: true);
      expect(cleared.isActive, isFalse);
    });
  });
}
