import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration.
///
/// The Android options below are the canonical values from the project's
/// `android/app/google-services.json`. The API key is not committed here: it
/// is provided at build time via `--dart-define=FIREBASE_API_KEY=...` (see
/// `.env.example`). The key is public in every client build (it ships inside
/// the APK by design), but it stays out of the repo for hygiene.
class DefaultFirebaseOptions {
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: ''),
    appId: '1:583676030808:android:b9cfed0a6f9959b8107f2d',
    messagingSenderId: '583676030808',
    projectId: 'sagen-bdd3f',
    storageBucket: 'sagen-bdd3f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: String.fromEnvironment('FIREBASE_IOS_API_KEY', defaultValue: ''),
    appId: String.fromEnvironment('FIREBASE_IOS_APP_ID', defaultValue: ''),
    messagingSenderId: '583676030808',
    projectId: 'sagen-bdd3f',
    storageBucket: 'sagen-bdd3f.firebasestorage.app',
  );
}
