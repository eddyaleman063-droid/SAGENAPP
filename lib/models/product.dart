import '../l10n/app_localizations.dart';

enum ProductBonusType { streakProtector, xpBoost, luckBoost }

/// A bonus included in a product bundle.
class ProductBonus {
  final ProductBonusType type;
  final int quantity;
  final String label;

  const ProductBonus({
    required this.type,
    required this.quantity,
    required this.label,
  });
}

/// Represents a purchasable product or donation tier.
class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final int supporterLevel;
  final List<ProductBonus> bonuses;
  final String? badge;
  final double? discount;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.supporterLevel,
    this.bonuses = const [],
    this.badge,
    this.discount,
  });

  bool get isBundle => bonuses.isNotEmpty;

  bool get hasStreakProtector =>
      bonuses.any((b) => b.type == ProductBonusType.streakProtector);
}

List<Product> allProductsLocalized(AppLocalizations l) => [
  Product(
    id: 'donation_basic',
    title: l.productDonationBasic,
    description: l.productDonationDesc,
    price: 3.00,
    supporterLevel: 1,
    badge: l.productSupporter,
  ),
  Product(
    id: 'donation_standard',
    title: l.productDonationStandard,
    description: l.productDonationDesc,
    price: 5.00,
    supporterLevel: 2,
    badge: l.productPopular,
  ),
  Product(
    id: 'donation_premium',
    title: l.productDonationPremium,
    description: l.productDonationDesc,
    price: 10.00,
    supporterLevel: 3,
    badge: l.productBestOffer,
  ),
  Product(
    id: 'bundle_protector',
    title: l.productProtectorPack,
    description: l.productProtectorPackDesc,
    price: 12.00,
    supporterLevel: 2,
    bonuses: [
      ProductBonus(
        type: ProductBonusType.streakProtector,
        quantity: 1,
        label: l.productStreakProtectorDesc,
      ),
    ],
    discount: 0.20,
    badge: l.productProtector,
  ),
  Product(
    id: 'bundle_xp',
    title: l.productBoostPack,
    description: l.productBoostPackDesc,
    price: 20.00,
    supporterLevel: 3,
    bonuses: [
      ProductBonus(
        type: ProductBonusType.xpBoost,
        quantity: 1,
        label: l.productXpBoostDesc,
      ),
    ],
    badge: l.productBoost,
  ),
  Product(
    id: 'bundle_luck',
    title: l.productLuckPack,
    description: l.productLuckPackDesc,
    price: 24.00,
    supporterLevel: 3,
    bonuses: [
      ProductBonus(
        type: ProductBonusType.luckBoost,
        quantity: 1,
        label: l.productLuckBoostDesc,
      ),
    ],
    badge: l.productLuck,
  ),
];
