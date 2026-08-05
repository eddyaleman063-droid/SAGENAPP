import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration.
///
/// Build requirements:
///   `--dart-define=FIREBASE_API_KEY=key`
///   `--dart-define=FIREBASE_IOS_APP_ID=ios_id`   (required for iOS)
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: '1:583676030808:android:b9cfed0a6f9959b8107f2d',
    messagingSenderId: '583676030808',
    projectId: 'sagen-bdd3f',
    storageBucket: 'sagen-bdd3f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: '583676030808',
    projectId: 'sagen-bdd3f',
    storageBucket: 'sagen-bdd3f.firebasestorage.app',
  );
}
