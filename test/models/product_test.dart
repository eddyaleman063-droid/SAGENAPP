import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/product.dart';

const _testProducts = [
  Product(id: 'donation_5', title: 'Donation 5', description: 'Donation', price: 5.00, supporterLevel: 1),
  Product(id: 'donation_10', title: 'Donation 10', description: 'Donation', price: 9.00, supporterLevel: 2, discount: 0.10, badge: 'Offer'),
  Product(id: 'donation_20', title: 'Donation 20', description: 'Donation', price: 16.00, supporterLevel: 3, discount: 0.20, badge: 'Popular'),
  Product(id: 'donation_50', title: 'Donation 50', description: 'Donation', price: 35.00, supporterLevel: 3, discount: 0.30, badge: 'Best'),
  Product(id: 'donation_100', title: 'Donation 100', description: 'Donation', price: 60.00, supporterLevel: 3, discount: 0.40, badge: 'Ultra'),
  Product(id: 'bundle_protector', title: 'Protector Pack', description: 'Protector', price: 12.00, supporterLevel: 2, bonuses: [ProductBonus(type: ProductBonusType.streakProtector, quantity: 1, label: 'Protector')], discount: 0.20, badge: 'Protector'),
  Product(id: 'bundle_xp', title: 'Boost Pack', description: 'XP boost', price: 20.00, supporterLevel: 3, bonuses: [ProductBonus(type: ProductBonusType.xpBoost, quantity: 1, label: 'XP Boost')], badge: 'Boost'),
  Product(id: 'bundle_multiplier', title: 'Fortune Pack', description: 'Multiplier', price: 28.00, supporterLevel: 3, bonuses: [ProductBonus(type: ProductBonusType.xpBoost, quantity: 2, label: 'XP Multiplier')], badge: 'Fortune'),
  Product(id: 'bundle_luck', title: 'Luck Pack', description: 'Luck boost', price: 24.00, supporterLevel: 3, bonuses: [ProductBonus(type: ProductBonusType.luckBoost, quantity: 1, label: 'Luck Boost')], badge: 'Luck'),
];

void main() {
  group('Product.isBundle', () {
    test('returns false for donation-only products', () {
      expect(_testProducts.firstWhere((p) => p.id == 'donation_5').isBundle, isFalse);
    });

    test('returns true for bundle products', () {
      expect(_testProducts.firstWhere((p) => p.id == 'bundle_protector').isBundle, isTrue);
    });
  });

  group('Product.hasStreakProtector', () {
    test('returns false for donation products', () {
      expect(_testProducts.firstWhere((p) => p.id == 'donation_50').hasStreakProtector, isFalse);
    });

    test('returns true for bundle_protector', () {
      expect(_testProducts.firstWhere((p) => p.id == 'bundle_protector').hasStreakProtector, isTrue);
    });
  });

  group('testProducts', () {
    test('has 9 products', () {
      expect(_testProducts.length, 9);
    });

    test('all have valid IDs', () {
      for (final p in _testProducts) {
        expect(p.id, isNotEmpty);
      }
    });

    test('all have positive prices', () {
      for (final p in _testProducts) {
        expect(p.price, greaterThan(0));
      }
    });

    test('discounted products have badge', () {
      final discounted = _testProducts.where((p) => p.discount != null);
      for (final p in discounted) {
        expect(p.badge, isNotNull);
      }
    });
  });
}
