import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/learning/stage.dart';
import '../services/app_logger.dart';
import '../services/learning_stage_service.dart';

const _checksumSalt = 'sagen_v5_integrity';

abstract class LearningRepository {
  List<Stage> get stages;
  double get totalDonated;
  int get xp;
  int get currentLevel;
  int get lessonsCompleted;
  List<String> get achievements;
  int get totalXpEarned;
  int get sageTalks;
  bool get isSupporter;

  Future<void> load();
  Future<List<Stage>> fetchStages();
  void saveStages(List<Stage> stages);
  void saveTotalDonated(double amount);
  void saveXp(int amount);
  void saveLevel(int level);
  void saveLessonsCompleted(int count);
  void saveAchievements(List<String> achievements);
  void saveTotalXp(int amount);
  void saveSageTalks(int count);
  void saveIsSupporter(bool value);
  void saveAll({
    required List<Stage> stages,
    required double totalDonated,
    required int xp,
    required int level,
    required int lessonsCompleted,
    required List<String> achievements,
    required int totalXp,
    required int sageTalks,
    required bool isSupporter,
  });
  void saveIntegrity();
  bool get needsServerReconciliation;
  void markReconciled();
}

class LearningRepositoryImpl implements LearningRepository {
  final SharedPreferences _prefs;
  final LearningStageService _stageService;

  double _totalDonated = 0;
  int _xp = 0;
  int _currentLevel = 1;
  int _lessonsCompleted = 0;
  final List<Stage> _stages = [];
  final List<String> _achievements = [];
  int _totalXpEarned = 0;
  int _sageTalks = 0;
  bool _isSupporter = false;
  bool _needsServerReconciliation = false;

  LearningRepositoryImpl(
    this._prefs, [
    LearningStageService? stageService,
  ]) : _stageService = stageService ?? const LearningStageService();

  int _computeChecksum() => Object.hashAll([
    _totalDonated,
    _xp,
    _isSupporter,
    _totalXpEarned,
    _lessonsCompleted,
    _currentLevel,
    _checksumSalt,
  ]);

  void _saveChecksum() {
    _prefs.setInt('learning_integrity', _computeChecksum());
  }

  bool _verifyChecksum() {
    final stored = _prefs.getInt('learning_integrity');
    if (stored == null) return true;
    final expected = _computeChecksum();
    if (stored != expected) {
      AppLogger().warning(
        'Integrity check failed: stored=$stored expected=$expected',
      );
      return false;
    }
    return true;
  }

  @override
  double get totalDonated => _totalDonated;

  @override
  int get xp => _xp;

  @override
  int get currentLevel => _currentLevel;

  @override
  int get lessonsCompleted => _lessonsCompleted;

  @override
  List<Stage> get stages => List.unmodifiable(_stages);

  @override
  List<String> get achievements => List.unmodifiable(_achievements);

  @override
  int get totalXpEarned => _totalXpEarned;

  @override
  int get sageTalks => _sageTalks;

  @override
  bool get isSupporter => _isSupporter;

  @override
  bool get needsServerReconciliation => _needsServerReconciliation;

  @override
  void markReconciled() {
    _needsServerReconciliation = false;
    _saveChecksum();
  }

  @override
  Future<void> load() async {
    // Try atomic snapshot first (new format)
    final snapshotRaw = _prefs.getString('learning_snapshot');
    if (snapshotRaw != null && snapshotRaw.isNotEmpty) {
      try {
        final snapshot = jsonDecode(snapshotRaw) as Map<String, dynamic>;
        _totalDonated = (snapshot['learning_total_donated'] as num?)?.toDouble() ?? 0.0;
        _xp = snapshot['learning_xp'] as int? ?? 0;
        _currentLevel = snapshot['learning_level'] as int? ?? 1;
        _lessonsCompleted = snapshot['learning_lessons_completed'] as int? ?? 0;
        _totalXpEarned = snapshot['learning_total_xp'] as int? ?? 0;
        _sageTalks = snapshot['learning_sage_talks'] as int? ?? 0;
        _isSupporter = snapshot['learning_is_supporter'] as bool? ?? false;

        final stagesList = snapshot['learning_stages'] as List?;
        if (stagesList != null) {
          _stages..clear()..addAll(stagesList.map((j) => Stage.fromJson(j as Map<String, dynamic>)));
        } else {
          _stages.clear();
        }

        final ach = snapshot['learning_achievements'] as String? ?? '';
        _achievements..clear()..addAll(ach.split(',').where((s) => s.isNotEmpty));
      } catch (e) {
        AppLogger().warning('learning_snapshot corrupted, falling back to legacy keys: $e');
        _loadLegacy();
      }
    } else {
      _loadLegacy();
    }

    final needsRechecksum = _prefs.getBool('learning_needs_rechecksum') ?? false;
    if (needsRechecksum) {
      await _prefs.setBool('learning_needs_rechecksum', false);
      _saveChecksum();
    } else if (!_verifyChecksum()) {
      AppLogger().warning('Integrity check failed — possible data tampering, flagging for server reconciliation');
      _needsServerReconciliation = true;
    }
  }

  void _loadLegacy() {
    _totalDonated = _prefs.getDouble('learning_total_donated') ?? 0.0;
    _xp = _prefs.getInt('learning_xp') ?? 0;
    _currentLevel = _prefs.getInt('learning_level') ?? 1;
    _lessonsCompleted = _prefs.getInt('learning_lessons_completed') ?? 0;
    _totalXpEarned = _prefs.getInt('learning_total_xp') ?? 0;
    _sageTalks = _prefs.getInt('learning_sage_talks') ?? 0;
    _isSupporter = _prefs.getBool('learning_is_supporter') ?? false;

    final raw = _prefs.getString('learning_stages');
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List;
        _stages..clear()..addAll(list.map((j) => Stage.fromJson(j as Map<String, dynamic>)));
      } catch (_) {
        AppLogger().warning('LearningRepository: failed to parse legacy stages JSON');
        _stages.clear();
      }
    } else {
      _stages.clear();
    }

    final ach = _prefs.getString('learning_achievements') ?? '';
    _achievements..clear()..addAll(ach.split(',').where((s) => s.isNotEmpty));
  }

  @override
  Future<List<Stage>> fetchStages() async {
    try {
      final fresh = await _stageService.fetchStages();
      if (fresh.isNotEmpty) return fresh;
    } catch (e) {
      AppLogger().warning('Failed to fetch stages from network: $e');
    }
    return [];
  }

  @override
  void saveStages(List<Stage> stages) {
    _stages
      ..clear()
      ..addAll(stages);
    _prefs.setString(
      'learning_stages',
      jsonEncode(stages.map((s) => s.toJson()).toList()),
    );
  }

  @override
  void saveTotalDonated(double amount) {
    _totalDonated = amount;
    _prefs.setDouble('learning_total_donated', amount);
  }

  @override
  void saveXp(int amount) {
    _xp = amount;
    _prefs.setInt('learning_xp', amount);
  }

  @override
  void saveLevel(int level) {
    _currentLevel = level;
    _prefs.setInt('learning_level', level);
  }

  @override
  void saveLessonsCompleted(int count) {
    _lessonsCompleted = count;
    _prefs.setInt('learning_lessons_completed', count);
  }

  @override
  void saveAchievements(List<String> achievements) {
    _achievements
      ..clear()
      ..addAll(achievements);
    _prefs.setString('learning_achievements', achievements.join(','));
  }

  @override
  void saveTotalXp(int amount) {
    _totalXpEarned = amount;
    _prefs.setInt('learning_total_xp', amount);
  }

  @override
  void saveSageTalks(int count) {
    _sageTalks = count;
    _prefs.setInt('learning_sage_talks', count);
  }

  @override
  void saveIsSupporter(bool value) {
    _isSupporter = value;
    _prefs.setBool('learning_is_supporter', value);
  }

  @override
  void saveAll({
    required List<Stage> stages,
    required double totalDonated,
    required int xp,
    required int level,
    required int lessonsCompleted,
    required List<String> achievements,
    required int totalXp,
    required int sageTalks,
    required bool isSupporter,
  }) {
    _stages..clear()..addAll(stages);
    _totalDonated = totalDonated;
    _xp = xp;
    _currentLevel = level;
    _lessonsCompleted = lessonsCompleted;
    _achievements..clear()..addAll(achievements);
    _totalXpEarned = totalXp;
    _sageTalks = sageTalks;
    _isSupporter = isSupporter;

    // Atomic write: serialize all fields to a single JSON blob, then write once
    final snapshot = {
      'learning_stages': stages.map((s) => s.toJson()).toList(),
      'learning_total_donated': totalDonated,
      'learning_xp': xp,
      'learning_level': level,
      'learning_lessons_completed': lessonsCompleted,
      'learning_achievements': achievements.join(','),
      'learning_total_xp': totalXp,
      'learning_sage_talks': sageTalks,
      'learning_is_supporter': isSupporter,
    };
    _prefs.setString('learning_snapshot', jsonEncode(snapshot));
    _saveChecksum();
  }

  @override
  void saveIntegrity() {
    _saveChecksum();
  }

}
