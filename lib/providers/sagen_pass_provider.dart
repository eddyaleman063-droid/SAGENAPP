import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chest_type.dart';
import '../models/sagen_pass.dart';
import '../repositories/sagen_pass_repository.dart';
import '../services/app_logger.dart';
import '../services/chest_drop_service.dart';
import '../services/chest_event_bus.dart';
import 'providers.dart';

final sagenPassProvider = NotifierProvider<SagenPassNotifier, SagenPass>(
  SagenPassNotifier.new,
);

class SagenPassNotifier extends Notifier<SagenPass> {
  late final SagenPassRepository _repo;
  List<int> _pendingChests = [];

  @override
  SagenPass build() {
    _repo = ref.watch(sagenPassRepositoryProvider);
    _pendingChests = _repo.passChestsPending;
    final local = _load();
    _checkSeasonReset(local);
    _reconcileWithServer();
    return local;
  }

  void _checkSeasonReset(SagenPass pass) {
    final now = DateTime.now();
    final seasonEnd = pass.seasonStart.add(
      Duration(days: pass.seasonDurationDays),
    );
    if (now.isAfter(seasonEnd)) {
      // Season expired - reset to level 1 with fresh state. Los cofres del
      // pass pendientes de rollo pertenecen a la temporada anterior (el banco
      // server-side se vacía al rotar) y nunca podrían abrirse: se limpian
      // para no reintentarlos en bucle.
      _pendingChests = [];
      _repo.savePassChestsPending([]);
      state = SagenPass(
        currentLevel: 1,
        currentSP: 0,
        claimedLevels: [],
        seasonStart: now,
        seasonDurationDays: pass.seasonDurationDays,
      );
      _save();
    }
  }

  SagenPass _load() {
    return SagenPass(
      currentLevel: _repo.currentLevel,
      currentSP: _repo.currentSP,
      claimedLevels: _repo.claimedLevels,
      seasonStart: _repo.seasonStart,
      // Precisión: propaga la duración persistida (no el default implícito del
      // modelo) para que _checkSeasonReset/_reconcileWithServer calculen la
      // ventana de temporada con el mismo valor que persistió el repositorio.
      seasonDurationDays: _repo.seasonDurationDays,
      premium: _repo.premium,
    );
  }

  /// Reconcile local state with server-side authoritative season data.
  Future<void> _reconcileWithServer() async {
    try {
      final serverData = await ref
          .read(gamificationCloudServiceProvider)
          .getSagenPassSeason();
      if (serverData == null) return;

      final serverSeasonStart = serverData['seasonStart'];
      var serverLevel = serverData['level'] as int? ?? state.currentLevel;
      var serverSP = serverData['sp'] as int? ?? state.currentSP;
      final serverClaimed = serverData['claimed'];
      final serverPremium = serverData['premium'] as bool? ?? state.premium;

      List<int> claimed;
      if (serverClaimed is List) {
        claimed = serverClaimed.whereType<int>().toList();
      } else {
        claimed = state.claimedLevels;
      }

      // Reconcile seasonStart from server (authoritative)
      DateTime? seasonStart;
      if (serverSeasonStart != null) {
        if (serverSeasonStart is String) {
          seasonStart = DateTime.tryParse(serverSeasonStart);
        }
      }

      // Rotación de temporada: si el servidor indica `rotated` (o devuelve un
      // seasonStart cuya ventana ya venció en un servidor legacy sin rotación),
      // los claimed/level/sp pertenecen a la temporada anterior y NO deben
      // importarse — evita heredar reclamaciones viejas tras el reset local.
      final now = DateTime.now();
      final serverRotated = serverData['rotated'] == true;
      final serverSeasonExpired =
          seasonStart != null &&
          now.isAfter(
            seasonStart.add(Duration(days: state.seasonDurationDays)),
          );
      if (serverRotated || serverSeasonExpired) {
        claimed = [];
        serverLevel = 1;
        serverSP = 0;
        seasonStart = now;
        _pendingChests = [];
        _repo.savePassChestsPending([]);
      }

      // Apply server values (server is source of truth)
      state = state.copyWith(
        currentLevel: serverLevel,
        currentSP: serverSP,
        claimedLevels: claimed,
        seasonStart: seasonStart,
        premium: serverPremium,
      );
      _save();
      // Reintenta cofres del pass pendientes (rollo interrumpido por red).
      await _flushPendingPassChests();
    } catch (e) {
      AppLogger().warning(
        'SagenPass: server reconciliation failed, using local: $e',
      );
    }
  }

  void _save() {
    _repo.save(
      state.currentLevel,
      state.currentSP,
      state.claimedLevels,
      state.seasonStart,
      state.premium,
    );
  }

  /// Claims a level reward via server-side Cloud Function.
  /// Server response is validated to prevent crashes from malformed data.
  Future<PassLevel?> claimLevel(int level) async {
    if (state.isLevelClaimed(level)) return null;
    if (level > state.currentLevel) return null;

    final result = await ref
        .read(gamificationCloudServiceProvider)
        .claimPassReward(level);
    if (result == null) return null;

    // Validate claimedLevels from server response
    final rawClaimed = result['claimedLevels'];
    List<int> claimed;
    if (rawClaimed is List) {
      claimed = rawClaimed.whereType<int>().toList();
    } else {
      // Fallback: add the level locally
      claimed = [...state.claimedLevels, level];
    }

    // Reconcile seasonStart from server if returned
    DateTime? seasonStart;
    final rawSeasonStart = result['seasonStart'];
    if (rawSeasonStart is String) {
      seasonStart = DateTime.tryParse(rawSeasonStart);
    }

    state = state.copyWith(
      claimedLevels: claimed,
      seasonStart: seasonStart ?? state.seasonStart,
    );
    _save();

    // Recompensas server-side: el servidor acreditó XP/escudos/cofre de forma
    // atómica e idempotente; aquí solo se reflejan en el estado local para no
    // duplicar nada. (NUEVO-fix: antes las recompensas del pass eran
    // decorativas y el cliente nunca recibía nada.)
    final rawReward = result['reward'];
    if (rawReward is Map<String, dynamic>) {
      final type = rawReward['type'] as String?;
      final granted = (rawReward['granted'] as num?)?.toInt() ?? 0;
      if (type == 'xp' && granted > 0) {
        ref.read(learningProvider.notifier).applyServerXp(granted);
      } else if (type == 'chest' && granted > 0) {
        _markPassChestPending(level);
        await _openPassChest(level);
      }
      // type == 'item' (Titanium Shield): el escudo se acreditó en el servidor
      // (streak_shields) y llega al cliente en el próximo sync de racha.
    }

    return getLevel(level);
  }

  void _markPassChestPending(int level) {
    if (!_pendingChests.contains(level)) {
      _pendingChests = [..._pendingChests, level];
    }
    _repo.savePassChestsPending(_pendingChests);
  }

  void _clearPassChestPending(int level) {
    _pendingChests = _pendingChests.where((l) => l != level).toList();
    _repo.savePassChestsPending(_pendingChests);
  }

  /// Reintenta abrir los cofres del pass que quedaron pendientes (rollo
  /// interrumpido por red). El servidor consume el cofre del banco solo cuando
  /// el rollo aterriza, así que reintentar es seguro.
  Future<void> _flushPendingPassChests() async {
    for (final level in List<int>.of(_pendingChests)) {
      try {
        await _openPassChest(level);
      } catch (e) {
        AppLogger().warning(
          'SagenPass: flush del cofre del nivel $level falló: $e',
        );
      }
    }
  }

  /// Abre el cofre del pass (golden/epic) que el servidor dejó en el banco
  /// cuando se reclamó el nivel. rollChestDrop lo consume una sola vez; el
  /// servidor decide el tier y el contenido. Se usa ChestDropService directo
  /// (sin fallback local del roller) para no fabricar recompensas: si el
  /// servidor no responde, el cofre queda en el banco y se reintenta luego.
  Future<void> _openPassChest(int level) async {
    final reward = await ChestDropService.instance.roll(
      ChestType.gold,
      contextId: 'pass_$level',
      source: 'sagen',
    );
    // Sin respuesta real del servidor: el banco sigue intacto server-side y el
    // nivel permanece en passChestsPending para reintentarlo al arrancar.
    if (reward.xp <= 0 && reward.chestType == null) return;

    // Acierto o duplicate (un roll previo ya consumió el banco): fin del lado
    // pendiente; el duplicado no vuelve a otorgar nada.
    _clearPassChestPending(level);
    if (reward.xp <= 0) return;

    // rollChestDrop ya acredita el XP y las gemas en el servidor; solo se
    // reflejan localmente.
    ref
        .read(learningProvider.notifier)
        .applyServerChestReward(reward.xp, reward.gems);
    ref
        .read(chestEventBusProvider)
        .fire(
          ChestRewardData(
            type: reward.chestType ?? ChestType.gold,
            xp: reward.xp,
            gems: reward.gems,
            streakShields: reward.streakShields,
            xpBoost: reward.xpBoost,
            specialItems: reward.specialItems,
            cosmeticUnlocks: reward.cosmeticUnlocks,
            source: 'pass',
          ),
        );
  }

  PassLevel? getLevel(int level) {
    try {
      return SagenPass.allLevels.firstWhere((l) => l.level == level);
    } catch (e) {
      AppLogger().warning('SagenPass: getLevel failed for level $level: $e');
      return null;
    }
  }
}
