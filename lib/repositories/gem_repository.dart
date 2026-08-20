import 'dart:collection';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GemTransaction {
  final int amount;
  final String reason;
  final DateTime timestamp;
  final int balanceAfter;

  const GemTransaction({
    required this.amount,
    required this.reason,
    required this.timestamp,
    required this.balanceAfter,
  });

  String encode() => jsonEncode({
    'a': amount,
    'r': reason,
    't': timestamp.millisecondsSinceEpoch,
    'b': balanceAfter,
  });

  static GemTransaction? decode(String raw) {
    try {
      if (!raw.startsWith('{')) return null;
      final map = jsonDecode(raw);
      if (map is! Map<String, dynamic>) return null;
      final a = map['a'] as int?;
      final r = map['r'] as String?;
      final t = map['t'] as int?;
      final b = map['b'] as int?;
      if (a == null || r == null || t == null || b == null) return null;
      return GemTransaction(
        amount: a,
        reason: r,
        timestamp: DateTime.fromMillisecondsSinceEpoch(t),
        balanceAfter: b,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Abstract interface for gem balance persistence.
abstract class GemRepository {
  int get balance;
  int get totalEarned;
  int get totalSpent;
  List<GemTransaction> get transactions;

  void addGems(int amount, {String reason});
  bool spendGems(int amount, {String reason});
  void setBalance(int balance);
  void save();
}

/// SharedPreferences-backed implementation of [GemRepository].
///
/// Enforces upper-bound limits: balance ≤ 100 000, totals ≤ 1 000 000.
class GemRepositoryImpl implements GemRepository {
  final SharedPreferences _prefs;
  static const _keyBalance = 'gems_balance';
  static const _keyTotalEarned = 'gems_total_earned';
  static const _keyTotalSpent = 'gems_total_spent';
  static const _keyTransactions = 'gems_transactions';
  static const _maxTransactions = 200;

  int _balance = 0;
  int _totalEarned = 0;
  int _totalSpent = 0;
  List<GemTransaction> _transactions = [];

  GemRepositoryImpl(this._prefs) {
    _load();
  }

  void _load() {
    _balance = _prefs.getInt(_keyBalance) ?? 0;
    _totalEarned = _prefs.getInt(_keyTotalEarned) ?? 0;
    _totalSpent = _prefs.getInt(_keyTotalSpent) ?? 0;
    final raw = _prefs.getStringList(_keyTransactions) ?? [];
    _transactions = raw
        .map(GemTransaction.decode)
        .whereType<GemTransaction>()
        .toList();
  }

  @override
  int get balance => _balance;

  @override
  int get totalEarned => _totalEarned;

  @override
  int get totalSpent => _totalSpent;

  @override
  List<GemTransaction> get transactions => UnmodifiableListView(_transactions);

  void _logTransaction(int amount, String reason) {
    _transactions.insert(
      0,
      GemTransaction(
        amount: amount,
        reason: reason,
        timestamp: DateTime.now(),
        balanceAfter: _balance,
      ),
    );
    if (_transactions.length > _maxTransactions) {
      _transactions = _transactions.sublist(0, _maxTransactions);
    }
  }

  @override
  void addGems(int amount, {String reason = 'unknown'}) {
    if (amount <= 0) return;
    final before = _balance;
    _balance = (_balance + amount).clamp(0, 100000);
    _totalEarned += _balance - before;
    _logTransaction(amount, reason);
  }

  @override
  bool spendGems(int amount, {String reason = 'shop'}) {
    if (amount <= 0 || _balance < amount) return false;
    _balance -= amount;
    _totalSpent += amount;
    _logTransaction(-amount, reason);
    return true;
  }

  @override
  void setBalance(int balance) {
    _balance = balance.clamp(0, 100000);
  }

  @override
  void save() {
    _prefs.setInt(_keyBalance, _balance);
    _prefs.setInt(_keyTotalEarned, _totalEarned);
    _prefs.setInt(_keyTotalSpent, _totalSpent);
    _prefs.setStringList(
      _keyTransactions,
      _transactions.map((t) => t.encode()).toList(),
    );
  }
}
