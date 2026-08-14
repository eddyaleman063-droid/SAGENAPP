import 'package:shared_preferences/shared_preferences.dart';

/// Abstract interface for gem balance persistence.
abstract class GemRepository {
  int get balance;
  int get totalEarned;
  int get totalSpent;

  void addGems(int amount);
  bool spendGems(int amount);
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

  int _balance = 0;
  int _totalEarned = 0;
  int _totalSpent = 0;

  GemRepositoryImpl(this._prefs) {
    _load();
  }

  void _load() {
    _balance = _prefs.getInt(_keyBalance) ?? 0;
    _totalEarned = _prefs.getInt(_keyTotalEarned) ?? 0;
    _totalSpent = _prefs.getInt(_keyTotalSpent) ?? 0;
  }

  @override
  int get balance => _balance;

  @override
  int get totalEarned => _totalEarned;

  @override
  int get totalSpent => _totalSpent;

  @override
  void addGems(int amount) {
    if (amount <= 0) return;
    _balance = (_balance + amount).clamp(0, 100000);
    _totalEarned += amount;
  }

  @override
  bool spendGems(int amount) {
    if (amount <= 0 || _balance < amount) return false;
    _balance -= amount;
    _totalSpent += amount;
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
  }
}
