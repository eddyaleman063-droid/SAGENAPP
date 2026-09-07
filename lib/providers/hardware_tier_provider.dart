import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/device_tier.dart';
import 'service_providers.dart';

// NUEVO-fix (ronda 19): escuchamos las notificaciones del detector (ChangeNotifier)
// y nos auto-invalidamos cuando la detección asíncrona termina. Sin esto el tier
// quedaba "congelado" en el valor por defecto (highEnd) aunque el dispositivo fuera
// low-end. Al invalidar(se), los dependientes (isLowEndDeviceProvider, reduce*)
// recomputan con el tier real.
final hardwareTierProvider = Provider<DeviceTier>((ref) {
  final detector = ref.read(lowEndDeviceDetectorProvider);
  void onChange() => ref.invalidateSelf();
  detector.addListener(onChange);
  ref.onDispose(() => detector.removeListener(onChange));
  detector.init();
  return detector.tier;
});

final isLowEndDeviceProvider = Provider<bool>((ref) {
  return ref.watch(hardwareTierProvider) == DeviceTier.lowEnd;
});

final reduceAnimationsProvider = Provider<bool>((ref) {
  // NUEVO-fix (ronda 17): el flag del usuario (Ajustes → Reducir animaciones)
  // se combina con la reducción automática por tier del hardware. El watch del
  // puente + contador hace que al alternar el toggle el valor se recalcule en
  // vivo.
  // NUEVO-fix (ronda 19): watch de hardwareTierProvider — se invalida cuando la
  // detección asíncrona termina, evitando que el valor quede fijado en el tier
  // por defecto (highEnd) en dispositivos low-end.
  ref.watch(experienceServiceBridgeProvider);
  ref.watch(experienceChangeCounterProvider);
  ref.watch(hardwareTierProvider);
  final userReduced = ref.watch(experienceServiceProvider).reduceAnimations;
  return userReduced || ref.read(lowEndDeviceDetectorProvider).reduceAnimations;
});

final reduceBlurProvider = Provider<bool>((ref) {
  ref.watch(hardwareTierProvider);
  return ref.read(lowEndDeviceDetectorProvider).reduceBlur;
});

final reduceShadowsProvider = Provider<bool>((ref) {
  ref.watch(hardwareTierProvider);
  return ref.read(lowEndDeviceDetectorProvider).reduceShadows;
});

final reduceParticlesProvider = Provider<bool>((ref) {
  ref.watch(hardwareTierProvider);
  return ref.read(lowEndDeviceDetectorProvider).reduceParticles;
});
