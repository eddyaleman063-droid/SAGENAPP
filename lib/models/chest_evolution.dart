import 'chest_type.dart';

/// Represents one chest evolution roll attempt.
class EvolutionAttempt {
  final int index;
  final ChestType typeBefore;
  final ChestType typeAfter;
  final bool upgraded;
  final bool isFinal;

  const EvolutionAttempt({
    required this.index,
    required this.typeBefore,
    required this.typeAfter,
    required this.upgraded,
    required this.isFinal,
  });
}

/// Final result of all chest evolution attempts.
class ChestEvolutionResult {
  final ChestType finalType;
  final List<EvolutionAttempt> attempts;

  const ChestEvolutionResult({required this.finalType, required this.attempts});
}

/// Result of a single chest evolution roll.
class SingleEvolutionResult {
  final ChestType newTier;
  final bool evolved;

  const SingleEvolutionResult({required this.newTier, required this.evolved});
}
