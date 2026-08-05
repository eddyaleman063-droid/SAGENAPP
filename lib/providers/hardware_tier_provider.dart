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
  return ref.read(lowEndDeviceDetectorProvider).reduceAnimations;
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
