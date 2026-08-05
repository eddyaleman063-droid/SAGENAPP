/// Abstract interface for economic (donation/XP) operations.
/// All economic mutations MUST go through Cloud Functions.
abstract class IEconomicFunctionsService {
  Future<Map<String, dynamic>?> completeLesson({
    required String lessonId,
    required int xpEarned,
  });
  Future<Map<String, dynamic>?> processDonation({
    required double amount,
    required String method,
    required String idempotencyKey,
  });
  Future<Map<String, dynamic>?> addXp({
    required String reason,
    String? lessonId,
  });
  Future<Map<String, dynamic>?> incrementStreak();
  Future<Map<String, dynamic>?> recordDonation({
    required double amount,
    required String method,
  });
}
