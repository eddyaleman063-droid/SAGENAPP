import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chest_type.dart';
import '../repositories/inventory_repository.dart';
import '../services/chest_event_bus.dart';
import 'service_providers.dart';

class InventoryState {
  final Map<ChestType, int> chestsOpened;
  final int xpBoostsCollected;
  final int bonusMultipliersCollected;
  final int totalChestsOpened;

  const InventoryState({
    this.chestsOpened = const {},
    this.xpBoostsCollected = 0,
    this.bonusMultipliersCollected = 0,
    this.totalChestsOpened = 0,
  });

  InventoryState copyWith({
    Map<ChestType, int>? chestsOpened,
    int? xpBoostsCollected,
    int? bonusMultipliersCollected,
    int? totalChestsOpened,
  }) {
    return InventoryState(
      chestsOpened: chestsOpened ?? this.chestsOpened,
      xpBoostsCollected: xpBoostsCollected ?? this.xpBoostsCollected,
      bonusMultipliersCollected:
          bonusMultipliersCollected ?? this.bonusMultipliersCollected,
      totalChestsOpened: totalChestsOpened ?? this.totalChestsOpened,
    );
  }
}

class InventoryNotifier extends Notifier<InventoryState> {
  late final InventoryRepository _repo;

  @override
  InventoryState build() {
    InventoryProvider.recordDelegate = (data) => recordChestOpened(data);
    ref.onDispose(() {
      InventoryProvider.recordDelegate = null;
    });
    _repo = ref.read(inventoryRepositoryProvider);
    return _load();
  }

  InventoryState _load() {
    return InventoryState(
      chestsOpened: _repo.chestsOpened,
      totalChestsOpened: _repo.totalChestsOpened,
      xpBoostsCollected: _repo.xpBoostsCollected,
      bonusMultipliersCollected: _repo.bonusMultipliersCollected,
    );
  }

  void _save(InventoryState current) {
    _repo.saveAll(
      InventoryData(
        chestsOpened: current.chestsOpened,
        totalChestsOpened: current.totalChestsOpened,
        xpBoostsCollected: current.xpBoostsCollected,
        bonusMultipliersCollected: current.bonusMultipliersCollected,
      ),
    );
  }

  int get totalChestsAllTime =>
      state.chestsOpened.values.fold(0, (a, b) => a + b);

  void recordChestOpened(ChestRewardData data) {
    final updated = Map<ChestType, int>.from(state.chestsOpened);
    updated[data.type] = (updated[data.type] ?? 0) + 1;
    final next = state.copyWith(
      chestsOpened: updated,
      totalChestsOpened: state.totalChestsOpened + 1,
      xpBoostsCollected: state.xpBoostsCollected + (data.xpBoost ? 1 : 0),
      bonusMultipliersCollected:
          state.bonusMultipliersCollected + (data.streakShields ?? 0),
    );
    _save(next);
    state = next;
  }
}

// Backward-compat wrapper for non-Riverpod consumers (chest_listener, main.dart)
class InventoryProvider {
  InventoryProvider._();

  static InventoryProvider? _instance;
  static InventoryProvider get instance {
    return _instance ??= InventoryProvider._();
  }

  void recordChestOpened(ChestRewardData data) => _recordDelegate?.call(data);

  static void Function(ChestRewardData)? _recordDelegate;
  static set recordDelegate(void Function(ChestRewardData)? fn) =>
      _recordDelegate = fn;
}
