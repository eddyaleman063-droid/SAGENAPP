import '../../models/chest_type.dart';
import '../../models/chest_evolution.dart';

/// Abstract interface for chest evolution operations.
/// Enables dependency injection and testability.
abstract class IChestEvolutionService {
  Future<ChestEvolutionResult> runGacha(ChestType initialType);
}
