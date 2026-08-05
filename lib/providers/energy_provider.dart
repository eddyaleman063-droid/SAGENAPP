import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'prefs_provider.dart';
import 'package:sagen/services/app_logger.dart';

class EnergyState {
  final int energy;
  final DateTime lastRegen;

  const EnergyState({
    required this.energy,
    required this.lastRegen,
  });

  EnergyState copyWith({
    int? energy,
    DateTime? lastRegen,
  }) {
    return EnergyState(
      energy: energy ?? this.energy,
      lastRegen: lastRegen ?? this.lastRegen,
    );
  }
}

class EnergyNotifier extends Notifier<EnergyState> {
  late final StorageService _storage;
  Timer? _regenTimer;
  bool _consuming = false;

  static const _maxEnergy = 100;
  static const _lessonCost = 20;
  static const _regenInterval = Duration(minutes: 5);
  static const _regenAmount = 1;

  static const _keyEnergy = 'energy_current';
  static const _keyLastRegen = 'energy_last_regen';

  static int get maxEnergy => _maxEnergy;
  static int get lessonCost => _lessonCost;

  @override
  EnergyState build() {
    final prefs = ref.read(prefsProvider);
    _storage = StorageService(prefs);
    EnergyState initial;
    try {
      initial = _load();
    } catch (_) {
      AppLogger().warning('Failed to load energy state: operation failed');
      initial = EnergyState(energy: _maxEnergy, lastRegen: DateTime.now());
    }
    _startRegen();
    ref.onDispose(() => _regenTimer?.cancel());
    return initial;
  }

  EnergyState _load() {
    int energy = _storage.getInt(_keyEnergy, _maxEnergy).clamp(0, _maxEnergy);
    final last = _storage.getString(_keyLastRegen);
    DateTime lastRegen = DateTime.now();
    if (last.isNotEmpty) {
      final parsedLast = DateTime.tryParse(last);
      if (parsedLast != null) {
        lastRegen = parsedLast;
        final elapsed = DateTime.now().difference(parsedLast);
        final minutes = elapsed.inMinutes;
        if (minutes >= _regenInterval.inMinutes) {
          final regenCycles = minutes ~/ _regenInterval.inMinutes;
          energy = (energy + regenCycles * _regenAmount).clamp(0, _maxEnergy);
          lastRegen = parsedLast.add(Duration(minutes: regenCycles * _regenInterval.inMinutes));
        }
      }
    }
    _storage.setInt(_keyEnergy, energy);
    _storage.setString(_keyLastRegen, lastRegen.toIso8601String());
    return EnergyState(energy: energy, lastRegen: lastRegen);
  }

  void _startRegen() {
    _regenTimer?.cancel();
    if (state.energy >= _maxEnergy) return;
    _regenTimer = Timer.periodic(_regenInterval, (_) {
      if (state.energy >= _maxEnergy) {
        _regenTimer?.cancel();
        _regenTimer = null;
        return;
      }
      final next = (state.energy + _regenAmount).clamp(0, _maxEnergy);
      final now = DateTime.now();
      state = state.copyWith(energy: next, lastRegen: now);
      _storage.setInt(_keyEnergy, next);
      _storage.setString(_keyLastRegen, now.toIso8601String());
    });
  }

  int get energy => state.energy;
  double get fraction => state.energy / _maxEnergy;
  bool get canDoLesson => state.energy >= _lessonCost;

  bool consumeForLesson() {
    if (_consuming) return false;
    if (state.energy < _lessonCost) return false;
    _consuming = true;
    try {
      state = state.copyWith(energy: state.energy - _lessonCost);
      _save();
      return true;
    } finally {
      _consuming = false;
    }
  }

  void addEnergy(int amount) {
    final next = (state.energy + amount).clamp(0, _maxEnergy);
    state = state.copyWith(energy: next);
    _save();
  }

  void refill() {
    state = state.copyWith(energy: _maxEnergy);
    _save();
  }

  void _save() {
    _storage.setInt(_keyEnergy, state.energy);
    // Only update lastRegen on actual regen events, not on every save
    // The lastRegen is already set correctly in _load() and _startRegen()
    if (state.lastRegen.isAfter(DateTime.now().subtract(const Duration(seconds: 5)))) {
      _storage.setString(_keyLastRegen, state.lastRegen.toIso8601String());
    }
  }
}
