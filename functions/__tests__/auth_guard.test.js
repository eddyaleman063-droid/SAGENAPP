const { requireVerifiedUser } = require('../auth_guard');

describe('requireVerifiedUser', () => {
  test('lanza unauthenticated sin context.auth', () => {
    expect(() => requireVerifiedUser({})).toThrow(
      expect.objectContaining({ code: 'unauthenticated' })
    );
  });

  test('lanza failed-precondition sin token (contexto sin claim de verificación)', () => {
    expect(() => requireVerifiedUser({ auth: { uid: 'u1' } })).toThrow(
      expect.objectContaining({ code: 'failed-precondition' })
    );
  });

  test('lanza failed-precondition si email_verified es false', () => {
    expect(() =>
      requireVerifiedUser({ auth: { uid: 'u1', token: { email_verified: false } } })
    ).toThrow(expect.objectContaining({ code: 'failed-precondition' }));
  });

  test('devuelve auth cuando el email está verificado', () => {
    const auth = requireVerifiedUser({
      auth: { uid: 'u1', token: { email_verified: true } },
    });
    expect(auth.uid).toBe('u1');
  });
});
