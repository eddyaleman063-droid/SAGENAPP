/// Abstract interface for economic (donation/XP) operations.
/// All economic mutations MUST go through Cloud Functions.
abstract class IEconomicFunctionsService {
  Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required int xpEarned,
    int? correctCount,
    int? totalQuestions,
    bool? perfect,
  });
  Future<Map<String, dynamic>?> processDonation({
    required double amount,
    required String method,
    required String idempotencyKey,
  });
  Future<Map<String, dynamic>?> addXp({
    required String reason,
    String? lessonId,
    String? idempotencyKey,
    String? achievementId,
  });

  /// Genera una clave idempotente segura (prefijada con el uid) para
  /// reutilizarla entre el intento online y su reintento offline.
  String createIdempotencyKey([String? prefix]);
  Future<Map<String, dynamic>?> incrementStreak({
    bool freezeUsed = false,
    bool checkIn = true,
    String? itemUsed,
    // NUEVO-fix (streak backfill): día UTC del último check-in local previo y
    // racha consecutiva previa. El servidor los usa para recuperar días
    // offline probados (ecuación de continuidad + ventana acotada) en vez de
    // colapsar la racha a 1.
    String? activityDay,
    int? activityStreak,
  });
  Future<Map<String, dynamic>?> recordDonation({
    required double amount,
    required String method,
  });

  /// Reclama un escudo gratis de racha vía servidor (con tope diario anti-farm).
  /// El servidor acredita `streak_shields` de forma autoritativa; el cliente
  /// solo aplica el bump local optimista tras confirmación.
  Future<Map<String, dynamic>?> claimFreeStreakShield();
}
