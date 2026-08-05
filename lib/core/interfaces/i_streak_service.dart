import '../../services/streak_service.dart';

/// Abstract interface for streak operations.
/// Enables dependency injection and testability.
abstract class IStreakService {
  StreakStatus load();
  StreakStatus checkIn();
  bool shouldSendReminder(StreakStatus status);
}
