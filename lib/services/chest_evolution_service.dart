import 'package:cloud_functions/cloud_functions.dart';
import '../core/interfaces/i_chest_evolution_service.dart';
import '../models/chest_type.dart';
import '../models/chest_evolution.dart';
import 'app_logger.dart';

/// Handles chest tier evolution logic via Cloud Functions.
class ChestEvolutionService implements IChestEvolutionService {
  ChestEvolutionService._();
  static final ChestEvolutionService instance = ChestEvolutionService._();
  final _logger = AppLogger();
  final _functions = FirebaseFunctions.instance;

  /// Single server-side gacha roll. Used by the gacha widget per-tap.
  Future<SingleEvolutionResult> rollSingleEvolution(ChestType current) async {
    if (current == ChestType.legendary) {
      return const SingleEvolutionResult(newTier: ChestType.legendary, evolved: false);
    }

    try {
      final result = await _functions
          .httpsCallable('rollChestEvolution')
          .call({'currentTier': current.name})
          .timeout(const Duration(seconds: 10));

      final data = result.data as Map<String, dynamic>;
      final evolved = data['evolved'] as bool? ?? false;
      final newTierName = data['newTier'] as String? ?? current.name;
      final newType = ChestType.values.firstWhere(
        (t) => t.name == newTierName,
        orElse: () => current,
      );

      return SingleEvolutionResult(newTier: newType, evolved: evolved);
    } catch (e) {
      _logger.error('rollSingleEvolution error', e);
      return SingleEvolutionResult(newTier: current, evolved: false);
    }
  }

  /// Runs gacha via server-side Cloud Function for tamper-proof rolls.
  /// Sends currentTier and receives { newTier, evolved } for each roll.
  /// Each chest gets up to 3 evolution attempts.
  @override
  Future<ChestEvolutionResult> runGacha(ChestType initialType) async {
    final attempts = <EvolutionAttempt>[];
    var currentType = initialType;

    try {
      for (int i = 0; i < 3; i++) {
        final typeBefore = currentType;

        if (currentType == ChestType.legendary) {
          attempts.add(EvolutionAttempt(
            index: i,
            typeBefore: typeBefore,
            typeAfter: currentType,
            upgraded: false,
            isFinal: i == 2,
          ));
          continue;
        }

        final result = await _functions
            .httpsCallable('rollChestEvolution')
            .call({'currentTier': currentType.name})
            .timeout(const Duration(seconds: 10));

        final data = result.data as Map<String, dynamic>;
        final evolved = data['evolved'] as bool? ?? false;
        final newTierName = data['newTier'] as String? ?? currentType.name;
        final newType = ChestType.values.firstWhere(
          (t) => t.name == newTierName,
          orElse: () => currentType,
        );

        if (evolved) currentType = newType;

        attempts.add(EvolutionAttempt(
          index: i,
          typeBefore: typeBefore,
          typeAfter: currentType,
          upgraded: evolved,
          isFinal: i == 2,
        ));
      }
    } catch (e) {
      _logger.error('Gacha Cloud Function error', e);
      // Preserve partial progress on error — add failed attempt for current index
      final failedIndex = attempts.isEmpty ? 0 : attempts.last.index + 1;
      if (failedIndex < 3) {
        attempts.add(EvolutionAttempt(
          index: failedIndex,
          typeBefore: currentType,
          typeAfter: currentType,
          upgraded: false,
          isFinal: failedIndex == 2,
        ));
      }
    }

    _logger.info('Gacha: $initialType → $currentType '
        '(${attempts.where((a) => a.upgraded).length} upgrades)');
    return ChestEvolutionResult(finalType: currentType, attempts: attempts);
  }
}
