import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart'
    show CoreFirebaseOptions, CoreInitializeResponse, TestFirebaseCoreHostApi;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sagen/config/firestore_field_config.dart';
import 'package:sagen/services/firestore_service.dart';

import '../helpers/mock_firebase_firestore.dart';

class _FakeCoreHostApi extends TestFirebaseCoreHostApi {
  @override
  Future<List<CoreInitializeResponse>> initializeCore() async => [];

  @override
  Future<CoreFirebaseOptions> optionsFromResource() async =>
      CoreFirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project-id',
      );

  @override
  Future<CoreInitializeResponse> initializeApp(
    String appName,
    CoreFirebaseOptions initializeAppRequest,
  ) async => CoreInitializeResponse(
    name: appName,
    options: initializeAppRequest,
    isAutomaticDataCollectionEnabled: true,
    pluginConstants: <String, Object?>{'isCrashlyticsCollectionEnabled': true},
  );
}

class _MockFirestore extends Mock implements FirebaseFirestore {}

// ignore: subtype_of_sealed_class
class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class _MockDoc extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockFirestore mockDb;
  late _MockCollection mockColl;
  late _MockDoc mockDoc;
  late Map<String, dynamic> lastWrite;
  late StreamController<DocumentSnapshot<Map<String, dynamic>>> snapCtrl;
  var hasWrite = false;

  void stubChain() {
    hasWrite = false;
    when(() => mockDb.collection('users')).thenReturn(mockColl);
    when(() => mockColl.doc(any())).thenReturn(mockDoc);
  }

  void stubSet() {
    when(() => mockDoc.set(any())).thenAnswer((invocation) async {
      hasWrite = true;
      lastWrite = Map<String, dynamic>.from(
        invocation.positionalArguments.first as Map,
      );
    });
  }

  void stubUpdate() {
    when(() => mockDoc.update(any())).thenAnswer((invocation) async {
      hasWrite = true;
      lastWrite = Map<String, dynamic>.from(
        invocation.positionalArguments.first as Map,
      );
    });
  }

  setUpAll(() async {
    TestFirebaseCoreHostApi.setUp(_FakeCoreHostApi());
    registerFallbackValues();
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  });

  setUp(() {
    mockDb = _MockFirestore();
    mockColl = _MockCollection();
    mockDoc = _MockDoc();
    snapCtrl =
        StreamController<DocumentSnapshot<Map<String, dynamic>>>.broadcast();
    FirestoreService.instance.overrideDbInstance = mockDb;
    FirestoreService.crashReporterOverride = (e, stack, reason) async {};
  });

  tearDown(() async {
    FirestoreService.instance.overrideDbInstance = null;
    FirestoreService.crashReporterOverride = null;
    FirestoreService.instance.dispose();
    await snapCtrl.close();
  });

  group('FirestoreService.sanitize', () {
    test('removes HTML tags', () async {
      expect(
        await FirestoreService.sanitize('<script>alert(1)</script>'),
        'alert(1)',
      );
    });

    test('removes javascript: protocol', () async {
      expect(await FirestoreService.sanitize('javascript:void(0)'), 'void(0)');
    });

    test('removes event handlers', () async {
      expect(await FirestoreService.sanitize('onclick=alert(1)'), 'alert(1)');
    });

    test('removes data URIs', () async {
      expect(
        await FirestoreService.sanitize('data:text/html,<h1>hi</h1>'),
        'text/html,hi',
      );
    });

    test('removes base64 content', () async {
      expect(await FirestoreService.sanitize('base64,SGVsbG8='), 'SGVsbG8=');
    });

    test('escapes ampersand and quotes', () async {
      final result = await FirestoreService.sanitize('a&b"c\'d');
      expect(result, contains('&amp;'));
      expect(result, contains('&quot;'));
      expect(result, contains('&#x27;'));
    });

    test('removes control characters', () async {
      expect(await FirestoreService.sanitize('hello\x00world'), 'helloworld');
    });

    test('replaces multiline with space', () async {
      expect(
        await FirestoreService.sanitize('line1\nline2\r\nline3'),
        'line1 line2 line3',
      );
    });

    test('truncates to 100 characters', () async {
      final long = 'a' * 200;
      expect((await FirestoreService.sanitize(long)).length, 100);
    });

    test('trims whitespace', () async {
      expect(await FirestoreService.sanitize('  hello  '), 'hello');
    });

    test('handles empty string', () async {
      expect(await FirestoreService.sanitize(''), '');
    });

    test('blocks javascript URLs', () async {
      expect(
        await FirestoreService.sanitize('javascript:alert(1)'),
        'alert(1)',
      );
    });
  });

  group('FirestoreService.sanitizeUrl', () {
    test('returns valid HTTP URL', () {
      expect(
        FirestoreService.sanitizeUrl('https://example.com'),
        'https://example.com',
      );
    });

    test('returns valid FTP URL', () {
      expect(
        FirestoreService.sanitizeUrl('ftp://files.example.com'),
        'ftp://files.example.com',
      );
    });

    test('blocks javascript: URL', () {
      expect(FirestoreService.sanitizeUrl('javascript:alert(1)'), '');
    });

    test('blocks non-URL strings', () {
      expect(FirestoreService.sanitizeUrl('not a url'), '');
    });

    test('trims whitespace', () {
      expect(
        FirestoreService.sanitizeUrl('  https://example.com  '),
        'https://example.com',
      );
    });
  });

  group('FirestoreService.clampAge', () {
    test('clamps below minimum to 13', () {
      expect(FirestoreService.clampAge(5), 13);
    });

    test('clamps above maximum to 120', () {
      expect(FirestoreService.clampAge(200), 120);
    });

    test('allows valid age', () {
      expect(FirestoreService.clampAge(25), 25);
    });

    test('allows boundary values', () {
      expect(FirestoreService.clampAge(13), 13);
      expect(FirestoreService.clampAge(120), 120);
    });
  });

  group('FirestoreService.allowedUpdateFields', () {
    test('contains profile fields', () {
      expect(FirestoreService.allowedUpdateFields, contains('firstName'));
      expect(FirestoreService.allowedUpdateFields, contains('lastName'));
      expect(FirestoreService.allowedUpdateFields, contains('email'));
    });

    test('does not contain economic fields', () {
      expect(
        FirestoreService.allowedUpdateFields,
        isNot(contains('learning_gems')),
      );
      expect(
        FirestoreService.allowedUpdateFields,
        isNot(contains('learning_total_xp')),
      );
    });

    test('contains updatedBy metadata field required by Firestore rules', () {
      expect(FirestoreService.allowedUpdateFields, contains('updatedBy'));
      expect(
        FirestoreFieldConfig.validateFieldType('updatedBy', 'uid-123'),
        isTrue,
      );
      expect(FirestoreFieldConfig.validateFieldType('updatedBy', 5), isFalse);
    });
  });

  group('FirestoreService.createUserProfile', () {
    setUp(() {
      stubChain();
    });

    test('writes default profile with sanitized fields', () async {
      stubSet();
      await FirestoreService.instance.createUserProfile(
        uid: 'uid-1',
        firstName: '  Ana  ',
        lastName: 'García',
        email: '  ANA@TEST.COM ',
        age: 25,
      );
      expect(hasWrite, isTrue);
      expect(lastWrite['firstName'], 'Ana');
      expect(lastWrite['lastName'], 'García');
      expect(lastWrite['email'], 'ana@test.com');
      expect(lastWrite['age'], 25);
      expect(lastWrite['onboardingCompleted'], true);
      expect(lastWrite['updatedBy'], 'uid-1');
      expect(lastWrite['dailyGoalMinutes'], 30);
      expect(lastWrite['preferredLanguage'], 'es');
    });

    test('clamps age and truncates long names to 50 chars', () async {
      stubSet();
      await FirestoreService.instance.createUserProfile(
        uid: 'uid-2',
        firstName: 'A' * 200,
        lastName: 'B' * 80,
        email: 'a@test.com',
        age: 12,
      );
      expect(hasWrite, isTrue);
      expect(lastWrite['firstName'], 'A' * 50);
      expect(lastWrite['lastName'], 'B' * 50);
      expect(lastWrite['age'], 13);
    });

    test('throws ArgumentError for invalid data before writing', () async {
      stubSet();
      await expectLater(
        FirestoreService.instance.createUserProfile(
          uid: 'uid-3',
          firstName: '',
          lastName: 'García',
          email: 'a@test.com',
          age: 25,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(hasWrite, isFalse);
    });

    test('throws ArgumentError for invalid email', () async {
      stubSet();
      await expectLater(
        FirestoreService.instance.createUserProfile(
          uid: 'uid-4',
          firstName: 'Ana',
          lastName: 'García',
          email: 'not-an-email',
          age: 25,
        ),
        throwsA(isA<ArgumentError>()),
      );
      expect(hasWrite, isFalse);
    });

    test('rethrows Firestore failures', () async {
      when(
        () => mockDoc.set(any()),
      ).thenThrow(PlatformException(code: 'unavailable', message: 'boom'));
      await expectLater(
        FirestoreService.instance.createUserProfile(
          uid: 'uid-5',
          firstName: 'Ana',
          lastName: 'García',
          email: 'a@test.com',
          age: 25,
        ),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('FirestoreService.updateField', () {
    setUp(() {
      stubChain();
    });

    test('blocks disallowed fields', () async {
      stubUpdate();
      await FirestoreService.instance.updateField(
        'uid-1',
        'learning_gems',
        100,
      );
      expect(hasWrite, isFalse);
    });

    test('blocks type mismatches', () async {
      stubUpdate();
      await FirestoreService.instance.updateField('uid-1', 'age', 'old');
      expect(hasWrite, isFalse);
    });

    test('blocks strings that are too long', () async {
      stubUpdate();
      await FirestoreService.instance.updateField(
        'uid-1',
        'firstName',
        'A' * 51,
      );
      expect(hasWrite, isFalse);
    });

    test('blocks ints out of range', () async {
      stubUpdate();
      await FirestoreService.instance.updateField('uid-1', 'age', 500);
      expect(hasWrite, isFalse);
    });

    test('writes valid profile fields', () async {
      stubUpdate();
      await FirestoreService.instance.updateField(
        'uid-1',
        'motivation',
        'estudiar',
      );
      expect(hasWrite, isTrue);
      expect(lastWrite['motivation'], 'estudiar');
    });

    test('rethrows Firestore failures', () async {
      when(
        () => mockDoc.update(any()),
      ).thenThrow(PlatformException(code: 'unavailable', message: 'boom'));
      await expectLater(
        FirestoreService.instance.updateField('uid-1', 'age', 25),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('FirestoreService.updateFields', () {
    setUp(() {
      stubChain();
    });

    test('sanitizes strings and skips disallowed fields', () async {
      stubUpdate();
      await FirestoreService.instance.updateFields('uid-1', {
        'firstName': '  <b>Ana</b>  ',
        'learning_gems': 500,
        'motivation': 'const  ancia',
      });
      expect(hasWrite, isTrue);
      expect(lastWrite['firstName'], 'Ana');
      expect(lastWrite['motivation'], 'const  ancia');
      expect(lastWrite.containsKey('learning_gems'), isFalse);
    });

    test('passes through _ts_ metadata keys', () async {
      stubUpdate();
      await FirestoreService.instance.updateFields('uid-1', {
        'firstName': 'Ana',
        '_ts_lastLoginDate': 12345,
      });
      expect(hasWrite, isTrue);
      expect(lastWrite['_ts_lastLoginDate'], 12345);
    });

    test('skips the write when nothing is writable', () async {
      stubUpdate();
      await FirestoreService.instance.updateFields('uid-1', {
        'learning_gems': 500,
        'not_a_field': 'x',
      });
      expect(hasWrite, isFalse);
    });

    test('rethrows Firestore failures', () async {
      when(
        () => mockDoc.update(any()),
      ).thenThrow(PlatformException(code: 'unavailable', message: 'boom'));
      await expectLater(
        FirestoreService.instance.updateFields('uid-1', {'age': 25}),
        throwsA(isA<PlatformException>()),
      );
    });
  });

  group('FirestoreService stream listeners', () {
    setUp(() {
      stubChain();
    });

    void openSnapshots() {
      when(() => mockDoc.snapshots()).thenAnswer((_) => snapCtrl.stream);
    }

    Future<void> tick() => Future<void>.delayed(Duration.zero);

    test('emits an empty stream once the listener limit is reached', () async {
      openSnapshots();
      const limit = 5;
      final subs = <StreamSubscription<DocumentSnapshot>>[];
      for (var i = 0; i < limit; i++) {
        subs.add(FirestoreService.instance.streamUserDoc('u$i').listen((_) {}));
        await tick();
      }
      expect(FirestoreService.instance.activeListenerCount, limit);
      final overLimit = FirestoreService.instance.streamUserDoc('u6');
      expect(await overLimit.toList(), isEmpty);
      for (final s in subs) {
        await s.cancel();
      }
      await tick();
      expect(FirestoreService.instance.activeListenerCount, 0);
    });

    test('decrements the listener count when a subscriber cancels', () async {
      openSnapshots();
      final sub = FirestoreService.instance.streamUserDoc('u1').listen((_) {});
      await tick();
      expect(FirestoreService.instance.activeListenerCount, 1);
      await sub.cancel();
      await tick();
      expect(FirestoreService.instance.activeListenerCount, 0);
    });

    test('listener counting works across several subscribers', () async {
      openSnapshots();
      final subs = <StreamSubscription<DocumentSnapshot>>[];
      for (var i = 0; i < 3; i++) {
        subs.add(FirestoreService.instance.streamUserDoc('g$i').listen((_) {}));
        await tick();
      }
      expect(FirestoreService.instance.activeListenerCount, 3);
      for (final s in subs) {
        await s.cancel();
      }
      await tick();
      expect(FirestoreService.instance.activeListenerCount, 0);
    });

    test('surfaces snapshot errors and closes the controller', () async {
      openSnapshots();
      var isDone = false;
      final sub = FirestoreService.instance
          .streamUserDoc('e1')
          .listen(
            (_) {},
            onDone: () {
              isDone = true;
            },
          );
      await tick();
      snapCtrl.addError(PlatformException(code: 'offline'));
      await tick();
      expect(isDone, isTrue);
      expect(FirestoreService.instance.activeListenerCount, 0);
      await sub.cancel();
    });

    test('removeListener is a no-op for unknown ids', () async {
      FirestoreService.instance.removeListener('missing-id');
      expect(FirestoreService.instance.activeListenerCount, 0);
    });

    test('dispose resets the listener count', () async {
      openSnapshots();
      final subs = <StreamSubscription<DocumentSnapshot>>[];
      for (var i = 0; i < 2; i++) {
        subs.add(FirestoreService.instance.streamUserDoc('d$i').listen((_) {}));
        await tick();
      }
      expect(FirestoreService.instance.activeListenerCount, 2);
      FirestoreService.instance.dispose();
      expect(FirestoreService.instance.activeListenerCount, 0);
      for (final s in subs) {
        await s.cancel();
      }
    });
  });
}
