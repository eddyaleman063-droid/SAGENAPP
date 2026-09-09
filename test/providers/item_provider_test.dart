import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/models/special_item.dart';
import 'package:sagen/providers/providers.dart';
import 'package:sagen/repositories/item_repository.dart';
import 'package:sagen/services/inventory_service.dart';
import 'package:sagen/services/remote_config_service.dart';
import 'package:sagen/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/mock_learning_provider.dart';

class FakeItemRepository implements ItemRepository {
  final Map<SpecialItemType, int> quantities = {};
  final Map<SpecialItemType, DateTime?> activeUntil = {};
  int saveCount = 0;

  @override
  int getQuantity(SpecialItemType type) => quantities[type] ?? 0;

  @override
  DateTime? getActiveUntil(SpecialItemType type) => activeUntil[type];

  @override
  void setQuantity(SpecialItemType type, int quantity) {
    quantities[type] = quantity.clamp(0, type.maxLimit);
  }

  @override
  void setActiveUntil(SpecialItemType type, DateTime? until) {
    activeUntil[type] = until;
  }

  @override
  Map<SpecialItemType, int> getAllQuantities() => Map.unmodifiable(quantities);

  @override
  void save() => saveCount++;
}

class FakeInventoryService implements InventoryService {
  FakeInventoryService({Map<SpecialItemType, int>? quantities, int xp = 0})
    : _quantities = quantities ?? {},
      _xp = xp;

  Map<SpecialItemType, int> _quantities;
  int _xp;
  bool useResult = true;

  @override
  Future<Map<SpecialItemType, int>?> fetchQuantities() async => _quantities;

  @override
  Future<({Map<SpecialItemType, int> quantities, int purchasedXpBoosts})?>
  fetchSnapshot() async => (quantities: _quantities, purchasedXpBoosts: _xp);

  @override
  Future<bool> useItem(SpecialItemType type, {int quantity = 1}) async {
    return useResult;
  }
}

void main() {
  group('ItemState', () {
    test('quantity returns 0 for unknown types', () {
      const state = ItemState();
      expect(state.quantity(SpecialItemType.focusElixir), 0);
      expect(state.isActive(SpecialItemType.focusElixir), isFalse);
    });

    test('isActive is true for future dates and false for past', () {
      final state = ItemState(
        activeUntil: {
          SpecialItemType.focusElixir: DateTime.now().add(
            const Duration(minutes: 5),
          ),
          SpecialItemType.sageMonocle: DateTime.now().subtract(
            const Duration(minutes: 5),
          ),
        },
      );
      expect(state.isActive(SpecialItemType.focusElixir), isTrue);
      expect(state.isActive(SpecialItemType.sageMonocle), isFalse);
    });

    test('copyWith replaces the quantities map', () {
      const base = ItemState(quantities: {SpecialItemType.focusElixir: 1});
      final updated = base.copyWith(quantities: {SpecialItemType.luckBoost: 2});
      expect(updated.quantities[SpecialItemType.focusElixir], isNull);
      expect(updated.quantities[SpecialItemType.luckBoost], 2);
      expect(base.quantities[SpecialItemType.focusElixir], 1);
    });
  });

  group('ItemNotifier', () {
    late ProviderContainer container;
    late FakeItemRepository repo;
    late FakeInventoryService inventory;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repo = FakeItemRepository();
      inventory = FakeInventoryService();
      container = ProviderContainer(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          itemRepositoryProvider.overrideWithValue(repo),
          inventoryServiceProvider.overrideWithValue(inventory),
          storageServiceProvider.overrideWithValue(StorageService(prefs)),
          remoteConfigServiceProvider.overrideWithValue(
            RemoteConfigService.instance,
          ),
          learningProvider.overrideWith(() => MockLearningNotifier()),
        ],
      );
    });

    test('addItem respects the max limit', () {
      final notifier = container.read(itemProvider.notifier);
      notifier.addItem(SpecialItemType.focusElixir, count: 5);
      notifier.addItem(SpecialItemType.focusElixir, count: 999);
      const type = SpecialItemType.focusElixir;
      expect(container.read(itemProvider).quantity(type), type.maxLimit);
    });

    test('useItem decrements and returns false when empty', () {
      final notifier = container.read(itemProvider.notifier);
      repo.setQuantity(SpecialItemType.focusElixir, 2);
      notifier.addItem(SpecialItemType.focusElixir, count: 0);
      expect(notifier.useItem(SpecialItemType.focusElixir), isTrue);
      expect(
        container.read(itemProvider).quantity(SpecialItemType.focusElixir),
        1,
      );
      expect(notifier.useItem(SpecialItemType.focusElixir), isTrue);
      expect(notifier.useItem(SpecialItemType.focusElixir), isFalse);
    });

    test(
      'syncFromServer overwrites local quantities from the server',
      () async {
        repo.setQuantity(SpecialItemType.focusElixir, 3);
        inventory._quantities = {SpecialItemType.luckBoost: 4};
        inventory._xp = 1;
        final notifier = container.read(itemProvider.notifier);
        await notifier.syncFromServer();
        final state = container.read(itemProvider);
        expect(state.quantity(SpecialItemType.focusElixir), 0);
        expect(state.quantity(SpecialItemType.luckBoost), 4);
      },
    );

    test('syncFromServer is coalesced while in flight', () async {
      inventory._quantities = {SpecialItemType.luckBoost: 7};
      inventory._xp = 2;
      final notifier = container.read(itemProvider.notifier);
      final first = notifier.syncFromServer();
      final second = notifier.syncFromServer();
      expect(identical(first, second), isTrue);
      await first;
    });

    test('useItemServer consumes via the server when it accepts', () async {
      inventory._quantities = {SpecialItemType.focusElixir: 2};
      repo.setQuantity(SpecialItemType.focusElixir, 2);
      final notifier = container.read(itemProvider.notifier);
      final ok = await notifier.useItemServer(SpecialItemType.focusElixir);
      expect(ok, isTrue);
      expect(
        container.read(itemProvider).quantity(SpecialItemType.focusElixir),
        1,
      );
    });

    test('useItemServer keeps the count when the server rejects', () async {
      inventory.useResult = false;
      repo.setQuantity(SpecialItemType.focusElixir, 2);
      final notifier = container.read(itemProvider.notifier);
      final ok = await notifier.useItemServer(SpecialItemType.focusElixir);
      expect(ok, isFalse);
      expect(
        container.read(itemProvider).quantity(SpecialItemType.focusElixir),
        2,
      );
    });

    test('useItemServer is a no-op without stock', () async {
      final notifier = container.read(itemProvider.notifier);
      expect(
        await notifier.useItemServer(SpecialItemType.focusElixir),
        isFalse,
      );
    });

    test('boost activators set an active window and report active', () {
      final notifier = container.read(itemProvider.notifier);
      notifier.activateFocusElixir();
      expect(notifier.isFocusElixirActive(), isTrue);
      notifier.activateSageMonocle();
      expect(notifier.isSageMonocleActive(), isTrue);
      notifier.activateLuckBoost();
      expect(notifier.isLuckBoostActive(), isTrue);
      notifier.activateTimeWarp();
      expect(notifier.isTimeWarpActive(), isTrue);
    });

    test('phoenix feather and titanium shield consume only when owned', () {
      final notifier = container.read(itemProvider.notifier);
      expect(notifier.hasPhoenixFeather(), isFalse);
      expect(notifier.usePhoenixFeather(), isFalse);

      repo.setQuantity(SpecialItemType.phoenixFeather, 1);
      notifier.addItem(SpecialItemType.phoenixFeather, count: 0);
      expect(notifier.hasPhoenixFeather(), isTrue);
      expect(notifier.usePhoenixFeather(), isTrue);
      expect(notifier.hasPhoenixFeather(), isFalse);

      repo.setQuantity(SpecialItemType.titaniumShield, 1);
      notifier.addItem(SpecialItemType.titaniumShield, count: 0);
      expect(notifier.hasTitaniumShield(), isTrue);
      expect(notifier.useTitaniumShield(), isTrue);
      expect(notifier.hasTitaniumShield(), isFalse);
    });

    test('hasItem and consumeItem delegate to quantity', () {
      final notifier = container.read(itemProvider.notifier);
      expect(notifier.hasItem(SpecialItemType.focusElixir), isFalse);
      repo.setQuantity(SpecialItemType.focusElixir, 1);
      notifier.addItem(SpecialItemType.focusElixir, count: 0);
      expect(notifier.hasItem(SpecialItemType.focusElixir), isTrue);
      expect(notifier.consumeItem(SpecialItemType.focusElixir), isTrue);
    });
  });
}
