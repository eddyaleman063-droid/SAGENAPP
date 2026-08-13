import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sets up mock method channel handlers for Firebase services so that
/// tests can run without a real Firebase initialization.
///
/// Call [setupFirebaseMocks] at the top of [testExecutable] in
/// `flutter_test_config.dart`.
void setupFirebaseMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // firebase_core — returns a fake default app
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Firebase#initializeCore') {
            return <Object?>[
              <String, Object?>{
                'name': '[DEFAULT]',
                'options': <String, Object?>{
                  'apiKey': 'test-api-key',
                  'appId': 'test-app-id',
                  'messagingSenderId': 'test-sender-id',
                  'projectId': 'test-project-id',
                },
                'pluginConstants': <String, Object?>{},
              },
            ];
          }
          if (methodCall.method == 'Firebase#initializeApp') {
            return <String, Object?>{
              'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
              'options': methodCall.arguments['app'] ?? <String, Object?>{},
              'pluginConstants': <String, Object?>{},
            };
          }
          if (methodCall.method == 'Firebase#appName') {
            return '[DEFAULT]';
          }
          return null;
        },
      );

  // firebase_auth
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_auth'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Auth#signInAnonymously') {
            return <String, Object?>{
              'user': <String, Object?>{
                'uid': 'test-uid',
                'isAnonymous': true,
                'email': null,
                'displayName': null,
                'phoneNumber': null,
                'photoURL': null,
              },
            };
          }
          if (methodCall.method == 'Auth#signInWithEmailAndPassword') {
            return <String, Object?>{
              'user': <String, Object?>{
                'uid': 'test-uid',
                'isAnonymous': false,
                'email': 'test@test.com',
                'displayName': null,
                'phoneNumber': null,
                'photoURL': null,
              },
            };
          }
          if (methodCall.method == 'Auth#signOut') {
            return null;
          }
          if (methodCall.method == 'Auth#currentUser') {
            return null;
          }
          if (methodCall.method == 'Auth#sendPasswordResetEmail') {
            return null;
          }
          if (methodCall.method == 'Auth#verifyPhoneNumber') {
            return null;
          }
          if (methodCall.method == 'Auth#signInWithCredential') {
            return <String, Object?>{
              'user': <String, Object?>{
                'uid': 'test-uid',
                'isAnonymous': false,
                'email': null,
                'displayName': null,
                'phoneNumber': null,
                'photoURL': null,
              },
            };
          }
          return null;
        },
      );

  // cloud_firestore
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/cloud_firestore'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Firestore#readTimestamp') {
            return DateTime.now().millisecondsSinceEpoch;
          }
          if (methodCall.method == 'Firestore#enableNetwork') {
            return null;
          }
          if (methodCall.method == 'Firestore#disableNetwork') {
            return null;
          }
          if (methodCall.method == 'Query#get') {
            return <Object?>[];
          }
          if (methodCall.method == 'DocumentReference#get') {
            return <String, Object?>{
              'exists': false,
              'data': <String, Object?>{},
            };
          }
          if (methodCall.method == 'DocumentReference#set') {
            return null;
          }
          if (methodCall.method == 'DocumentReference#update') {
            return null;
          }
          if (methodCall.method == 'DocumentReference#delete') {
            return null;
          }
          if (methodCall.method == 'Query#addSnapshotListener') {
            return 0;
          }
          if (methodCall.method == 'DocumentReference#addSnapshotListener') {
            return 0;
          }
          return null;
        },
      );

  // firebase_functions (cloud_functions)
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_functions'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Functions#call') {
            return <String, Object?>{
              'result': <String, Object?>{'success': true},
            };
          }
          return null;
        },
      );

  // firebase_crashlytics
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_crashlytics'),
        (MethodCall methodCall) async {
          return null;
        },
      );

  // firebase_analytics
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_analytics'),
        (MethodCall methodCall) async {
          return null;
        },
      );

  // firebase_remote_config
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_remote_config'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'RemoteConfig#fetch') {
            return null;
          }
          if (methodCall.method == 'RemoteConfig#activate') {
            return true;
          }
          if (methodCall.method == 'RemoteConfig#get') {
            return '';
          }
          if (methodCall.method == 'RemoteConfig#setConfigSettings') {
            return null;
          }
          if (methodCall.method == 'RemoteConfig#setDefaults') {
            return null;
          }
          return null;
        },
      );

  // firebase_app_check
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_app_check'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'AppCheck#getToken') {
            return 'test-token';
          }
          if (methodCall.method ==
              'AppCheck#setAutomaticDataCollectionEnabled') {
            return null;
          }
          return null;
        },
      );

  // firebase_performance
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_performance'),
        (MethodCall methodCall) async {
          return null;
        },
      );
}
