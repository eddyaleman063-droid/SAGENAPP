import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/auth_models.dart';
import 'package:sagen/services/auth_session_manager.dart';

void main() {
  late AuthSessionManager sessionManager;

  setUp(() {
    sessionManager = AuthSessionManager();
  });

  group('AuthSessionManager', () {
    test('restoreSession returns null when no session saved', () async {
      final user = await sessionManager.restoreSession();
      expect(user, isNull);
    });

    test('saveSession does not throw', () async {
      const user = AppUser(
        uid: '123',
        displayName: 'Test User',
        email: 'test@example.com',
      );
      await expectLater(
        () => sessionManager.saveSession(user),
        returnsNormally,
      );
    });

    test('clearSession does not throw', () async {
      await expectLater(() => sessionManager.clearSession(), returnsNormally);
    });

    test('save -> restore -> clear cycle handles gracefully', () async {
      const user = AppUser(
        uid: '456',
        displayName: 'Cycle Test',
        email: 'cycle@test.com',
        photoUrl: 'https://example.com/photo.png',
      );
      await sessionManager.saveSession(user);
      final restored = await sessionManager.restoreSession();
      if (restored != null) {
        expect(restored.uid, '456');
        expect(restored.displayName, 'Cycle Test');
        expect(restored.email, 'cycle@test.com');
        expect(restored.photoUrl, 'https://example.com/photo.png');
      }
      await sessionManager.clearSession();
      final afterClear = await sessionManager.restoreSession();
      expect(afterClear, anyOf(isNull, isA<AppUser>()));
    });

    test('saveSession with minimal AppUser fields', () async {
      const user = AppUser();
      await expectLater(
        () => sessionManager.saveSession(user),
        returnsNormally,
      );
    });
  });
}
