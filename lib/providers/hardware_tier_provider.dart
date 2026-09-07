import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/device_tier.dart';
import 'service_providers.dart';

final hardwareTierProvider = Provider<DeviceTier>((ref) {
  final detector = ref.read(lowEndDeviceDetectorProvider);
  detector.init();
  return detector.tier;
});

final isLowEndDeviceProvider = Provider<bool>((ref) {
  return ref.watch(hardwareTierProvider) == DeviceTier.lowEnd;
});

final reduceAnimationsProvider = Provider<bool>((ref) {
  // NUEVO-fix (ronda 17): el flag del usuario (Ajustes → Reducir animaciones)
  // se combina con la reducción automática por tier del hardware. Antes solo
  // se respetaba la del dispositivo y la preferencia persistida era inerte.
  // El watch del puente + contador hace que al alternar el toggle el valor
  // se recalcule en vivo (los demás dependientes se invalidan).
  ref.watch(experienceServiceBridgeProvider);
  ref.watch(experienceChangeCounterProvider);
  final userReduced = ref.watch(experienceServiceProvider).reduceAnimations;
  return userReduced || ref.read(lowEndDeviceDetectorProvider).reduceAnimations;
});

final reduceBlurProvider = Provider<bool>((ref) {
  return ref.read(lowEndDeviceDetectorProvider).reduceBlur;
});

final reduceShadowsProvider = Provider<bool>((ref) {
  return ref.read(lowEndDeviceDetectorProvider).reduceShadows;
});

final reduceParticlesProvider = Provider<bool>((ref) {
  return ref.read(lowEndDeviceDetectorProvider).reduceParticles;
});
