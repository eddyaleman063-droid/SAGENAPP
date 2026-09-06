const functions = require('firebase-functions');

// ══════════════════════════════════════════════════════════════════
// AUTH GUARD — server-side email verification enforcement
// La verificación de email no puede depender solo del cliente: un token
// de Firebase estándar (como el que firma el cliente) no prueba que el
// usuario haya verificado su email. El claim `email_verified` del token
// es la fuente autoritativa.
//
// Regla de oro de la economía: las mutaciones monetarias (XP, gemas,
// streak, pagos) solo deben ser ejecutables por cuentas que hayan
// verificado su email, para impedir farmear recompensas con cuentas
// quemadas sin dueño real del inbox.
// ══════════════════════════════════════════════════════════════════

/**
 * Valida que el llamador esté autenticado Y tenga el email verificado.
 * Lanza un HttpsError si no. Reemplaza el boilerplate previo
 * `if (!context.auth) { throw ... }` en los callables.
 *
 * @param {object} context Contexto de Firebase Callable (https.onCall).
 * @returns {object} context.auth con .uid ya garantizado.
 */
function requireVerifiedUser(context) {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Debes iniciar sesión'
    );
  }

  const token = context.auth.token;
  if (!token || token.email_verified !== true) {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Debes verificar tu email antes de continuar'
    );
  }

  return context.auth;
}

module.exports = { requireVerifiedUser };
