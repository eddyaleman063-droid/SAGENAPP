import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/hardware_tier_provider.dart';
import 'package:sagen/services/device_tier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Ensure the shared detector finishes detection before providers are read.
    await LowEndDeviceDetector.instance.init();
  });

  test('hardwareTierProvider exposes the detected tier', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tier = container.read(hardwareTierProvider);
    expect(DeviceTier.values, contains(tier));
  });

  test('isLowEndDeviceProvider is a boolean', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(isLowEndDeviceProvider), isA<bool>());
  });

  test('reduce providers expose booleans', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(reduceAnimationsProvider), isA<bool>());
    expect(container.read(reduceBlurProvider), isA<bool>());
    expect(container.read(reduceShadowsProvider), isA<bool>());
    expect(container.read(reduceParticlesProvider), isA<bool>());
  });

  test('tier and flags are consistent for the detected tier', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final tier = container.read(hardwareTierProvider);
    final isLowEnd = container.read(isLowEndDeviceProvider);

    if (tier == DeviceTier.lowEnd) {
      expect(isLowEnd, isTrue);
      expect(container.read(reduceAnimationsProvider), isTrue);
      expect(container.read(reduceShadowsProvider), isTrue);
      expect(container.read(reduceParticlesProvider), isTrue);
    } else {
      expect(isLowEnd, isFalse);
      expect(container.read(reduceAnimationsProvider), isFalse);
      expect(container.read(reduceShadowsProvider), isFalse);
      expect(container.read(reduceParticlesProvider), isFalse);
    }
  });

  test('LowEndDeviceDetector exposes tier helpers', () {
    final detector = LowEndDeviceDetector.instance;
    final tier = detector.tier;
    expect(detector.isLowEnd, tier == DeviceTier.lowEnd);
    expect(detector.isMidRange, tier == DeviceTier.midRange);
    expect(detector.reduceGlow, tier != DeviceTier.highEnd);
    expect(detector.reduceTransparency, tier != DeviceTier.highEnd);
    expect(detector.useSimpleAnimations, tier != DeviceTier.highEnd);
    expect(detector.disableParallax, tier == DeviceTier.lowEnd);
  });
}
