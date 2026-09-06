import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_logger.dart';

/// Repository for Sagen Pass (battle pass) data persistence.
/// Tracks SP, level, claimed rewards, and season info.
abstract class SagenPassRepository {
  int get currentLevel;
  int get currentSP;
  List<int> get claimedLevels;
  DateTime get seasonStart;
  int get seasonDurationDays;
  bool get premium;

  void save(
    int level,
    int sp,
    List<int> claimedLevels,
    DateTime seasonStart,
    bool premium,
  );
  void saveLevel(int level);
  void saveSP(int sp);
  void saveClaimedLevels(List<int> levels);

  /// Niveles del pass cuyo cofre (golden/epic) quedó en el banco del servidor
  /// pero aún no se abrió en el cliente (rollo fallido por red). Se reintentan
  /// en el próximo arranque/recnciliación hasta que el servidor confirme.
  List<int> get passChestsPending;
  void savePassChestsPending(List<int> levels);
}

class SagenPassRepositoryImpl implements SagenPassRepository {
  final SharedPreferences _prefs;

  static const _keyPass = 'sagen_pass_v1';
  Map<String, dynamic>? _cachedRaw;

  SagenPassRepositoryImpl(this._prefs);

  Map<String, dynamic> _loadRaw() {
    if (_cachedRaw != null) return _cachedRaw!;
    final raw = _prefs.getString(_keyPass);
    if (raw == null || raw.isEmpty) return {};
    try {
      _cachedRaw = jsonDecode(raw) as Map<String, dynamic>;
      return _cachedRaw!;
    } catch (e) {
      AppLogger().warning('SagenPassRepository: corrupt JSON, resetting: $e');
      return {};
    }
  }

  void _invalidateCache() => _cachedRaw = null;

  @override
  int get currentLevel => (_loadRaw()['level'] as int?) ?? 1;

  @override
  int get currentSP => (_loadRaw()['sp'] as int?) ?? 0;

  @override
  List<int> get claimedLevels {
    final raw = _loadRaw()['claimed'];
    if (raw is List) return raw.whereType<int>().toList();
    return [];
  }

  @override
  DateTime get seasonStart {
    final raw = _loadRaw()['seasonStart'];
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime(2026);
    return DateTime(2026);
  }

  @override
  int get seasonDurationDays => (_loadRaw()['duration'] as int?) ?? 90;

  @override
  bool get premium => (_loadRaw()['premium'] as bool?) ?? false;

  @override
  List<int> get passChestsPending {
    final raw = _loadRaw()['pendingChests'];
    if (raw is List) return raw.whereType<int>().toList();
    return [];
  }

  @override
  void savePassChestsPending(List<int> levels) {
    final data = _loadRaw();
    data['pendingChests'] = levels;
    _invalidateCache();
    _prefs.setString(_keyPass, jsonEncode(data));
  }

  @override
  void save(
    int level,
    int sp,
    List<int> claimedLevels,
    DateTime seasonStart,
    bool premium,
  ) {
    // Capturar los valores ANTES de invalidar el caché: los getters que
    // recargan _cachedRaw con el decode anterior dejarían datos viejos si se
    // evalúan después del _invalidateCache().
    final pending = passChestsPending;
    final duration = seasonDurationDays;
    _invalidateCache();
    _prefs.setString(
      _keyPass,
      jsonEncode({
        'level': level,
        'sp': sp,
        'claimed': claimedLevels,
        'seasonStart': seasonStart.toIso8601String(),
        'duration': duration,
        'premium': premium,
        'pendingChests': pending,
      }),
    );
  }

  @override
  void saveLevel(int level) {
    final data = _loadRaw();
    data['level'] = level;
    _invalidateCache();
    _prefs.setString(_keyPass, jsonEncode(data));
  }

  @override
  void saveSP(int sp) {
    final data = _loadRaw();
    data['sp'] = sp;
    _invalidateCache();
    _prefs.setString(_keyPass, jsonEncode(data));
  }

  @override
  void saveClaimedLevels(List<int> levels) {
    final data = _loadRaw();
    data['claimed'] = levels;
    _invalidateCache();
    _prefs.setString(_keyPass, jsonEncode(data));
  }
}
