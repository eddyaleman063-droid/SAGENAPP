import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/special_item.dart';
import '../repositories/item_repository.dart';
import 'providers.dart';

class ItemState {
  final Map<SpecialItemType, int> quantities;
  final Map<SpecialItemType, DateTime?> activeUntil;

  const ItemState({this.quantities = const {}, this.activeUntil = const {}});

  ItemState copyWith({
    Map<SpecialItemType, int>? quantities,
    Map<SpecialItemType, DateTime?>? activeUntil,
  }) {
    return ItemState(
      quantities: quantities ?? this.quantities,
      activeUntil: activeUntil ?? this.activeUntil,
    );
  }

  int quantity(SpecialItemType type) => quantities[type] ?? 0;
  bool isActive(SpecialItemType type) {
    final until = activeUntil[type];
    return until != null && DateTime.now().isBefore(until);
  }
}

class ItemNotifier extends Notifier<ItemState> {
  late final ItemRepository _repo;

  @override
  ItemState build() {
    _repo = ref.read(itemRepositoryProvider);
    return _load();
  }

  ItemState _load() {
    return ItemState(
      quantities: _repo.getAllQuantities(),
      activeUntil: {
        for (final type in SpecialItemType.values)
          type: _repo.getActiveUntil(type),
      },
    );
  }

  void addItem(SpecialItemType type, {int count = 1}) {
    final current = _repo.getQuantity(type);
    final maxLimit = type.maxLimit;
    final newQty = (current + count).clamp(0, maxLimit);
    _repo.setQuantity(type, newQty);
    _save();
  }

  bool useItem(SpecialItemType type) {
    final current = _repo.getQuantity(type);
    if (current <= 0) return false;
    _repo.setQuantity(type, current - 1);
    _save();
    return true;
  }

  bool hasItem(SpecialItemType type) => _repo.getQuantity(type) > 0;

  bool consumeItem(SpecialItemType type) => useItem(type);

  void activateFocusElixir() {
    _repo.setActiveUntil(
      SpecialItemType.focusElixir,
      DateTime.now().add(const Duration(minutes: 15)),
    );
    _save();
  }

  bool isFocusElixirActive() => state.isActive(SpecialItemType.focusElixir);

  void activateSageMonocle() {
    _repo.setActiveUntil(
      SpecialItemType.sageMonocle,
      DateTime.now().add(const Duration(hours: 1)),
    );
    _save();
  }

  bool isSageMonocleActive() => state.isActive(SpecialItemType.sageMonocle);

  void activateLuckBoost() {
    _repo.setActiveUntil(
      SpecialItemType.luckBoost,
      DateTime.now().add(const Duration(minutes: 30)),
    );
    _save();
  }

  bool isLuckBoostActive() => state.isActive(SpecialItemType.luckBoost);

  void activateTimeWarp() {
    _repo.setActiveUntil(
      SpecialItemType.timeWarp,
      DateTime.now().add(const Duration(minutes: 10)),
    );
    _save();
  }

  bool isTimeWarpActive() => state.isActive(SpecialItemType.timeWarp);

  bool hasPhoenixFeather() =>
      _repo.getQuantity(SpecialItemType.phoenixFeather) > 0;

  bool hasTitaniumShield() =>
      _repo.getQuantity(SpecialItemType.titaniumShield) > 0;

  bool usePhoenixFeather() {
    if (!hasPhoenixFeather()) return false;
    _repo.setQuantity(
      SpecialItemType.phoenixFeather,
      _repo.getQuantity(SpecialItemType.phoenixFeather) - 1,
    );
    _save();
    return true;
  }

  bool useTitaniumShield() {
    if (!hasTitaniumShield()) return false;
    _repo.setQuantity(
      SpecialItemType.titaniumShield,
      _repo.getQuantity(SpecialItemType.titaniumShield) - 1,
    );
    _save();
    return true;
  }

  void _save() {
    _repo.save();
    state = _load();
  }
}
