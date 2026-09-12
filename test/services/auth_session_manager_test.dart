import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/services/auth_session_manager.dart';

void main() {
  late AuthSessionManager sessionManager;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    sessionManager = AuthSessionManager();
  });

  group('AuthSessionManager', () {
    test('restoreSession returns null when no session saved', () async {
      final user = await sessionManager.restoreSession();
      expect(user, isNull);
    });

    test('save -> restore round-trip preserves all fields', () async {
      const user = AppUser(
        uid: '456',
        displayName: 'Cycle Test',
        email: 'cycle@test.com',
        photoUrl: 'https://example.com/photo.png',
      );
      await sessionManager.saveSession(user);

      final restored = await sessionManager.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.uid, '456');
      expect(restored.displayName, 'Cycle Test');
      expect(restored.email, 'cycle@test.com');
      expect(restored.photoUrl, 'https://example.com/photo.png');
    });

    test('restoreSession fills defaults when only uid is persisted', () async {
      FlutterSecureStorage.setMockInitialValues({'ss_auth_fb_uid': '777'});

      final restored = await sessionManager.restoreSession();
      expect(restored, isNotNull);
      expect(restored!.uid, '777');
      expect(restored.displayName, 'Estudiante');
      expect(restored.email, '');
      expect(restored.photoUrl, isNull);
    });

    test('saveSession with null photoUrl does not leave stale photo', () async {
      const first = AppUser(uid: '1', photoUrl: 'https://old/avatar.png');
      const second = AppUser(uid: '2', displayName: 'No photo');
      await sessionManager.saveSession(first);
      await sessionManager.saveSession(second);

      final restored = await sessionManager.restoreSession();
      expect(restored!.uid, '2');
      expect(restored.photoUrl, '');
    });

    test('clearSession removes persisted session', () async {
      const user = AppUser(uid: '123', displayName: 'Test User');
      await sessionManager.saveSession(user);
      expect(await sessionManager.restoreSession(), isNotNull);

      await sessionManager.clearSession();
      expect(await sessionManager.restoreSession(), isNull);
    });

    test('saveSession with minimal AppUser fields does not throw', () async {
      const user = AppUser();
      await expectLater(
        () => sessionManager.saveSession(user),
        returnsNormally,
      );
    });
  });
}
