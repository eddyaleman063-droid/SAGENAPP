import 'dart:async';
import 'dart:collection';
import '../models/chest_type.dart';
import '../models/special_item.dart';

/// Data payload for a chest reward event.
class ChestRewardData {
  final ChestType type;
  final int xp;
  final int? streakShields;
  final String? title;
  final String? message;
  final String source;
  final bool xpBoost;
  final List<SpecialItemType> specialItems;
  final List<SpecialItemType> cosmeticUnlocks;

  const ChestRewardData({
    required this.type,
    this.xp = 0,
    this.streakShields,
    this.title,
    this.message,
    required this.source,
    this.xpBoost = false,
    this.specialItems = const [],
    this.cosmeticUnlocks = const [],
  });

  bool get hasSpecialRewards =>
      specialItems.isNotEmpty || cosmeticUnlocks.isNotEmpty;
}

/// Singleton event bus for chest reward notifications.
class ChestEventBus {
  ChestEventBus._();
  static final ChestEventBus instance = ChestEventBus._();

  static const int _maxQueueSize = 10;
  final Queue<ChestRewardData> _queue = Queue<ChestRewardData>();
  StreamController<ChestRewardData> _controller =
      StreamController<ChestRewardData>.broadcast();
  bool _disposed = false;

  ChestRewardData? get pending => _queue.isNotEmpty ? _queue.first : null;

  Stream<ChestRewardData> get events => _controller.stream;

  void fire(ChestRewardData data) {
    if (_disposed) return;
    if (_queue.length >= _maxQueueSize) _queue.removeFirst();
    _queue.add(data);
    _controller.add(data);
  }

  void consume() {
    if (_queue.isNotEmpty) _queue.removeFirst();
  }

  void dispose() {
    _disposed = true;
    _controller.close();
  }

  void reset() {
    _queue.clear();
    _disposed = false;
    // Recreate the broadcast controller since close() can't be undone
    _controller = StreamController<ChestRewardData>.broadcast();
  }
}
