import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/providers/service_providers.dart';
import 'package:sagen/services/device_tier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // NUEVO-fix (ronda 19): el tier por defecto es highEnd; si la detección
  // asíncrona cambia el tier, el puente debe invalidar hardwareTierProvider y
  // los dependientes (isLowEndDeviceProvider, reduce*) deben recomputar.
  test('providers refresh after async detection changes the tier', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Detector sin inicializar → tier por defecto highEnd.
    expect(container.read(hardwareTierProvider), DeviceTier.highEnd);
    expect(container.read(reduceAnimationsProvider), isFalse);

    // Detección real (compute en isolate) sobre el singleton compartido.
    await LowEndDeviceDetector.instance.init();
    final detectedTier = LowEndDeviceDetector.instance.tier;

    // Tras la invalidation, hardwareTierProvider expone el tier detectado.
    expect(container.read(hardwareTierProvider), detectedTier);
    expect(
      container.read(reduceAnimationsProvider),
      container.read(lowEndDeviceDetectorProvider).reduceAnimations,
    );
  });

  test('debugOverrideTier forces a live refresh of dependent providers', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Detector ya inicializado (tier detectado); forzamos low-end.
    LowEndDeviceDetector.instance.debugOverrideTier(DeviceTier.lowEnd);

    expect(container.read(hardwareTierProvider), DeviceTier.lowEnd);
    expect(container.read(isLowEndDeviceProvider), isTrue);
    expect(container.read(reduceAnimationsProvider), isTrue);
    expect(container.read(reduceBlurProvider), isTrue);
    expect(container.read(reduceShadowsProvider), isTrue);
    expect(container.read(reduceParticlesProvider), isTrue);

    // Volvemos a high-end: todo revierte.
    LowEndDeviceDetector.instance.debugOverrideTier(DeviceTier.highEnd);

    expect(container.read(hardwareTierProvider), DeviceTier.highEnd);
    expect(container.read(isLowEndDeviceProvider), isFalse);
    expect(container.read(reduceAnimationsProvider), isFalse);
    expect(container.read(reduceBlurProvider), isFalse);
    expect(container.read(reduceShadowsProvider), isFalse);
    expect(container.read(reduceParticlesProvider), isFalse);
  });

  test('init joins an in-flight detection future instead of skipping', () async {
    // Primera llamada arranca la detección; una segunda llamada concurrente no
    // debe "escaparse" sino esperar el mismo Future.
    final first = LowEndDeviceDetector.instance.init();
    final second = LowEndDeviceDetector.instance.init();
    expect(identical(first, second), isTrue);
    await second;
    await first;
  });
}
