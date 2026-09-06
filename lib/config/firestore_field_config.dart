/// Centralized Firestore field configuration.
/// This file is the SINGLE SOURCE OF TRUTH for all Firestore field definitions.
/// Both client (FirestoreService, CloudSyncService) and server (firestore.rules)
/// MUST reference this file to prevent inconsistencies.
class FirestoreFieldConfig {
  FirestoreFieldConfig._();

  // ── Profile fields (client-writable) ─────────────────────────
  // These fields can be written directly by the authenticated client.
  // The server validates them via firestore.rules isProfileOnly().
  static const Set<String> profileFields = {
    'firstName',
    'lastName',
    'email',
    'age',
    'photoUrl',
    'lastLoginDate',
    'onboardingCompleted',
    'dailyGoalMinutes',
    'dailyLessonsGoal',
    'preferredLanguage',
    'referralSource',
    'routeType',
    'motivation',
    'updatedAt',
    'updatedBy',
  };

  // ── Server-only fields (NEVER writable by client) ────────────
  // These fields are updated exclusively by Cloud Functions (admin SDK).
  // They are BLOCKED in CloudSyncService and rejected by Firestore rules.
  static const Set<String> serverOnlyFields = {
    'total_donated',
    'is_supporter',
    'learning_gems',
    'learning_total_xp',
    'learning_level',
    'lessonsCompleted',
    'streakCurrent',
    'streakLongest',
    'streakFreezes',
    'streakFrozen',
    'streakLastActivity',
    'protectionScore',
    'sagenPassLevel',
    'sagenPassSP',
  };

  // ── Field type definitions ───────────────────────────────────
  // Maps each profile field to its expected Dart type.
  // Fields managed by FieldValue.serverTimestamp() use dynamic since
  // they are Timestamp on Firestore but String in SharedPreferences.
  static const Map<String, Type> profileFieldTypes = {
    'firstName': String,
    'lastName': String,
    'email': String,
    'age': int,
    'photoUrl': String,
    'lastLoginDate': dynamic, // Server-managed: FieldValue.serverTimestamp()
    'onboardingCompleted': bool,
    'dailyGoalMinutes': int,
    'dailyLessonsGoal': int,
    'preferredLanguage': String,
    'referralSource': String,
    'routeType': String,
    'motivation': String,
    'updatedAt': dynamic, // Server-managed: FieldValue.serverTimestamp()
    'updatedBy': String,
  };

  // ── Field validation rules ───────────────────────────────────
  static const Map<String, int> stringFieldMaxLengths = {
    'firstName': 50,
    'lastName': 50,
    'email': 254,
    'photoUrl': 500,
    'preferredLanguage': 10,
    'referralSource': 50,
    'routeType': 20,
    'motivation': 200,
  };

  static const Map<String, (int min, int max)> intFieldRanges = {
    'age': (13, 120),
    'dailyGoalMinutes': (0, 480),
    'dailyLessonsGoal': (0, 50),
  };

  // ── SharedPreferences ↔ Firestore mapping ────────────────────
  // Maps SP keys to their Firestore field names.
  // Only profile fields are synced by the client.
  static const Map<String, String> spToFirestoreMapping = {
    'firstName': 'firstName',
    'lastName': 'lastName',
    'email': 'email',
    'age': 'age',
    'photoUrl': 'photoUrl',
    'lastLoginDate': 'lastLoginDate',
    'onboardingCompleted': 'onboardingCompleted',
    'dailyGoalMinutes': 'dailyGoalMinutes',
    'dailyLessonsGoal': 'dailyLessonsGoal',
    'preferredLanguage': 'preferredLanguage',
    'referralSource': 'referralSource',
    'routeType': 'routeType',
    'motivation': 'motivation',
  };

  // ── Sync keys for CloudSyncService.saveAll ───────────────────
  static const List<String> syncKeys = [
    'firstName',
    'lastName',
    'email',
    'age',
    'photoUrl',
    'lastLoginDate',
    'onboardingCompleted',
    'dailyGoalMinutes',
    'dailyLessonsGoal',
    'preferredLanguage',
    'referralSource',
    'routeType',
    'motivation',
    'updatedAt',
  ];

  // ── Firestore → SharedPreferences mapping (read path) ────────
  // Maps server-side field names to their local SP keys when they differ.
  // Solo se incluyen campos que el cliente puede "espejar" pasivamente sin
  // romper ledgers con reconciliación propia:
  //   - learning_gems / learning_total_gems (ledger de gemas, server-authoritative)
  //   - lessonsCompleted (contador de lecciones)
  // EXPRESAMENTE EXCLUIDOS aquí: streakCurrent/longestStreak/streak_shields/
  // last_activity y sagen_pass_*, que tienen servicios dedicados con semántica
  // de "max/merge" (ver _reconcileServerStreak): un espejo pasivo podría
  // bajar el valor local de días ganados offline o reclamaciones legítimas.
  static const Map<String, String> firestoreToSpMapping = {
    'total_donated': 'learning_total_donated',
    'is_supporter': 'learning_is_supporter',
    'learning_gems': 'gems_balance',
    'learning_total_gems': 'gems_total_earned',
    'lessonsCompleted': 'learning_lessons_completed',
    // NUEVO-fix (chest desync): puente pasivo entre el ledger autoritativo
    // del servidor (users/{uid}.last_daily_chest) y la clave local usada por
    // GamificationRepository. Cuando el CloudSyncService recibe el snapshot del
    // usuario, esta entrada persiste la fecha server en SharedPreferences para
    // que canClaimDailyChest devuelva el valor correcto en el siguiente arranque
    // incluso si la reconciliación explícita (getDailyChestStatus) está offline.
    'last_daily_chest': 'gamification_last_claim_date',
  };

  /// Checks if a field is a server-only economic field.
  static bool isServerOnlyField(String field) =>
      serverOnlyFields.contains(field);

  /// Checks if a field is a client-writable profile field.
  static bool isProfileField(String field) => profileFields.contains(field);

  /// Validates that a value matches the expected type for a field.
  static bool validateFieldType(String field, dynamic value) {
    final expectedType = profileFieldTypes[field];
    if (expectedType == null) return true;
    if (expectedType == dynamic) return true;
    if (expectedType == String) return value is String;
    if (expectedType == int) return value is int;
    if (expectedType == bool) return value is bool;
    if (expectedType == double) return value is double;
    return value.runtimeType == expectedType;
  }

  /// Validates string length constraints.
  static bool validateStringLength(String field, String value) {
    final maxLength = stringFieldMaxLengths[field];
    if (maxLength == null) return true;
    return value.length <= maxLength;
  }

  /// Validates int range constraints.
  static bool validateIntRange(String field, int value) {
    final range = intFieldRanges[field];
    if (range == null) return true;
    return value >= range.$1 && value <= range.$2;
  }
}
