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
  };

  // ── Server-only fields (NEVER writable by client) ────────────
  // These fields are updated exclusively by Cloud Functions (admin SDK).
  // They are BLOCKED in CloudSyncService and rejected by Firestore rules.
  static const Set<String> serverOnlyFields = {
    'totalDonated',
    'isSupporter',
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
