import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/services/remote_config_service.dart';
import 'package:sagen/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

class _DonationsLearningNotifier extends MockLearningNotifier {
  void setDonations(double value) {
    state = state.copyWith(totalDonated: value);
  }
}

void main() {
  group('ShopNotifier', () {
    late ProviderContainer container;
    late _DonationsLearningNotifier learning;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      learning = _DonationsLearningNotifier();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
          remoteConfigServiceProvider.overrideWithValue(
            RemoteConfigService.instance,
          ),
          learningProvider.overrideWith(() => learning),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('build loads the full default catalog', () {
      final shop = container.read(shopProvider);
      expect(shop.items, isNotEmpty);
      final ids = shop.items.map((i) => i.id).toSet();
      expect(ids, contains('xp_boost'));
      expect(ids, contains('focus_elixir'));
      expect(ids, contains('theme_dark_fire'));
      expect(shop.xpBoostActive, isFalse);
    });

    test('unlockItem marks an item owned and persists it', () async {
      final notifier = container.read(shopProvider.notifier);
      notifier.unlockItem('xp_boost');
      expect(
        container
            .read(shopProvider)
            .items
            .firstWhere((i) => i.id == 'xp_boost')
            .isOwned,
        isTrue,
      );
      // Persistencia: un nuevo container sobre las mismas prefs recuerda el unlock.
      final prefs = await SharedPreferences.getInstance();
      final fresh = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
          remoteConfigServiceProvider.overrideWithValue(
            RemoteConfigService.instance,
          ),
          learningProvider.overrideWith(() => _DonationsLearningNotifier()),
        ],
      );
      expect(
        fresh
            .read(shopProvider)
            .items
            .firstWhere((i) => i.id == 'xp_boost')
            .isOwned,
        isTrue,
      );
      fresh.dispose();
    });

    test('relockItem reverts ownership', () {
      final notifier = container.read(shopProvider.notifier);
      notifier.unlockItem('theme_dark_fire');
      notifier.relockItem('theme_dark_fire');
      expect(
        container
            .read(shopProvider)
            .items
            .firstWhere((i) => i.id == 'theme_dark_fire')
            .isOwned,
        isFalse,
      );
    });

    test(
      'canUnlock gates every item behind the supporter tier from donations',
      () {
        final shop = container.read(shopProvider);
        final notifier = container.read(shopProvider.notifier);
        final consumable = shop.items.firstWhere((i) => i.id == 'xp_boost');
        final theme = shop.items.firstWhere((i) => i.id == 'theme_dark_fire');

        // Tier 0 (sin donaciones): todos los ítems requieren al menos tier 1.
        container.read(learningProvider);
        learning.setDonations(0);
        expect(notifier.canUnlock(consumable), isFalse);
        expect(notifier.canUnlock(theme), isFalse);

        // Tier 1 (donación de $1): los ítems con requisito 1 se desbloquean.
        learning.setDonations(5);
        expect(notifier.canUnlock(consumable), isTrue);

        // Tier 2 (>= $20): abre los requisitos tier 2.
        learning.setDonations(25);
        expect(notifier.canUnlock(theme), isTrue);

        // Tier 3 (>= $50): abre los requisitos tier 3.
        learning.setDonations(50);
        expect(notifier.canUnlock(theme), isTrue);
      },
    );

    test('activateXpBoost/deactivateXpBoost toggle the flag', () {
      final notifier = container.read(shopProvider.notifier);
      notifier.activateXpBoost();
      expect(container.read(shopProvider).xpBoostActive, isTrue);
      notifier.deactivateXpBoost();
      expect(container.read(shopProvider).xpBoostActive, isFalse);
    });

    test('syncXpBoostFromServer re-arms when boosts exist and flag is off', () {
      final notifier = container.read(shopProvider.notifier);
      notifier.syncXpBoostFromServer(1);
      expect(container.read(shopProvider).xpBoostActive, isTrue);
    });

    test('syncXpBoostFromServer disarms when counter is 0 and flag is on', () {
      final notifier = container.read(shopProvider.notifier);
      notifier.activateXpBoost();
      notifier.syncXpBoostFromServer(0);
      expect(container.read(shopProvider).xpBoostActive, isFalse);
    });

    test('syncXpBoostFromServer is a no-op when states already match', () {
      final notifier = container.read(shopProvider.notifier);
      notifier.activateXpBoost();
      notifier.syncXpBoostFromServer(3);
      expect(container.read(shopProvider).xpBoostActive, isTrue);
      notifier.deactivateXpBoost();
      notifier.syncXpBoostFromServer(0);
      expect(container.read(shopProvider).xpBoostActive, isFalse);
    });
  });
}
