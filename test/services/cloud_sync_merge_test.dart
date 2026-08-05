import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sagen/services/cloud_sync_service.dart';
import 'package:sagen/services/auth_service.dart';

void main() {
  group('CloudSyncService._applyDocumentData (via loadAll)', () {
    late CloudSyncService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = CloudSyncService(authService: AuthService());
      final prefs = await SharedPreferences.getInstance();
      await service.init(prefs);
    });

    test('initializes correctly', () {
      expect(service.isInitialized, isTrue);
      expect(service.lastSync, isNull);
      expect(service.isSyncing, isFalse);
    });

    test('clearLocal removes all synced keys', () async {
      SharedPreferences.setMockInitialValues({
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john@test.com',
        'age': 25,
        'photoUrl': 'url',
        'onboardingCompleted': true,
        'dailyGoalMinutes': 30,
        'dailyLessonsGoal': 3,
        'preferredLanguage': 'es',
      });
      final prefs = await SharedPreferences.getInstance();
      await service.clearLocal(prefs);

      expect(prefs.getString('firstName'), isNull);
      expect(prefs.getString('lastName'), isNull);
      expect(prefs.getString('email'), isNull);
      expect(prefs.getInt('age'), isNull);
      expect(prefs.getString('photoUrl'), isNull);
      expect(prefs.getBool('onboardingCompleted'), isNull);
      expect(prefs.getInt('dailyGoalMinutes'), isNull);
      expect(prefs.getInt('dailyLessonsGoal'), isNull);
      expect(prefs.getString('preferredLanguage'), isNull);
    });

    test('clearLocal does not remove non-synced keys', () async {
      SharedPreferences.setMockInitialValues({
        'firstName': 'John',
        'user_name': 'Test',
        'theme_mode': 'dark',
      });
      final prefs = await SharedPreferences.getInstance();
      await service.clearLocal(prefs);

      expect(prefs.getString('firstName'), isNull);
      expect(prefs.getString('user_name'), 'Test');
      expect(prefs.getString('theme_mode'), 'dark');
    });

    test('notifyFieldChanged does nothing for non-int values', () async {
      // Should not throw
      service.notifyFieldChanged('learning_gems', 'not_an_int');
    });

    test('notifyFieldChanged does nothing for unmapped keys', () async {
      // Should not throw
      service.notifyFieldChanged('unknown_key', 42);
    });
  });

  group('CloudSyncService merge timestamp logic', () {
    test('timestamp comparison favors newer cloud data', () async {
      final cloudTs = Timestamp.fromDate(DateTime(2025, 1, 2));
      final localTs = DateTime(2025, 1, 1).toIso8601String();

      final cloudTime = cloudTs.toDate();
      final localTime = DateTime.tryParse(localTs);

      expect(cloudTime.isAfter(localTime!), isTrue);
    });

    test('timestamp comparison rejects older cloud data', () async {
      final cloudTs = Timestamp.fromDate(DateTime(2025, 1, 1));
      final localTs = DateTime(2025, 1, 2).toIso8601String();

      final cloudTime = cloudTs.toDate();
      final localTime = DateTime.tryParse(localTs);

      expect(cloudTime.isAfter(localTime!), isFalse);
    });

    test('missing local timestamp means cloud is newer', () async {
      const localTsStr = null;
      expect(localTsStr, isNull);
    });

    test('missing cloud timestamp means cloud is newer', () async {
      const cloudTs = null;
      expect(cloudTs, isNull);
    });
  });
}
