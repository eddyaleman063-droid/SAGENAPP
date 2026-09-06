/// Recompensas de XP AUTHORITATIVAS del servidor, por `reason`.
///
/// El servidor (`functions/economic.js`) es la fuente de verdad: acredita una
/// cantidad FIJA segun el `reason` de la llamada e IGNORA el `amount` que le
/// manda el cliente. Para que la UI (bump optimista, rollback offline y
/// display del resultado) coincida exactamente con lo que el servidor va a
/// acreditar, el cliente debe usar estos mismos valores en vez de calcular
/// cantidades propias por puntuacion.
///
/// Mantener SINCronizadas con REASON_REWARDS en functions/economic.js.
library;

class RewardConstants {
  RewardConstants._();

  /// Recompensa fija por cada partida de mini-juego completada.
  static const int miniGameXp = 10;

  /// Recompensa fija por lograr de un logro.
  static const int achievementXp = 10;
}
