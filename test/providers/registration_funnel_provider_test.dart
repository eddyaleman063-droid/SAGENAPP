import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/providers/providers.dart';

void main() {
  group('RegistrationFunnelState', () {
    test('initial state has correct defaults', () {
      const state = RegistrationFunnelState();
      expect(state.isGuest, false);
      expect(state.age, 0);
      expect(state.authMethod, '');
      expect(state.email, '');
      expect(state.password, '');
      expect(state.name, '');
      expect(state.surname, '');
    });

    test('copyWith updates only specified fields', () {
      const state = RegistrationFunnelState();
      final updated = state.copyWith(age: 25, name: 'Juan', authMethod: 'google');
      expect(updated.age, 25);
      expect(updated.name, 'Juan');
      expect(updated.authMethod, 'google');
      expect(updated.email, '');
    });
  });

  group('RegistrationFunnelNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('build returns default state', () {
      final state = container.read(registrationFunnelProvider);
      expect(state.age, 0);
      expect(state.isGuest, false);
    });

    test('skipToHome sets isGuest to true', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.skipToHome();
      expect(container.read(registrationFunnelProvider).isGuest, true);
    });

    test('setAge updates age', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.setAge(25);
      expect(container.read(registrationFunnelProvider).age, 25);
    });

    test('setAuthMethod updates auth method', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.setAuthMethod('google');
      expect(container.read(registrationFunnelProvider).authMethod, 'google');
    });

    test('setEmail and setPassword update credentials', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.setEmail('test@example.com');
      notifier.setPassword('secret123');
      expect(container.read(registrationFunnelProvider).email, 'test@example.com');
      expect(container.read(registrationFunnelProvider).password, 'secret123');
    });

    test('setName and setSurname update name fields', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.setName('Juan');
      notifier.setSurname('Pérez');
      expect(container.read(registrationFunnelProvider).name, 'Juan');
      expect(container.read(registrationFunnelProvider).surname, 'Pérez');
    });

    test('reset returns to initial state', () {
      final notifier = container.read(registrationFunnelProvider.notifier);
      notifier.setAge(25);
      notifier.setAuthMethod('email');
      notifier.setEmail('test@example.com');
      notifier.reset();
      final state = container.read(registrationFunnelProvider);
      expect(state.age, 0);
      expect(state.authMethod, '');
      expect(state.email, '');
    });
  });

  group('Funnel validation providers', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('funnelAgeValidProvider is false for age 0', () {
      expect(container.read(funnelAgeValidProvider), isFalse);
    });

    test('funnelAgeValidProvider is true for age >= 13', () {
      container.read(registrationFunnelProvider.notifier).setAge(14);
      expect(container.read(funnelAgeValidProvider), isTrue);
    });

    test('funnelEmailValidProvider validates email format', () {
      expect(container.read(funnelEmailValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setEmail('test');
      expect(container.read(funnelEmailValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setEmail('test@example.com');
      expect(container.read(funnelEmailValidProvider), isTrue);
    });

    test('funnelPasswordValidProvider checks minimum length and complexity', () {
      expect(container.read(funnelPasswordValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setPassword('abc');
      expect(container.read(funnelPasswordValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setPassword('abcdef');
      expect(container.read(funnelPasswordValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setPassword('Abcdef12');
      expect(container.read(funnelPasswordValidProvider), isTrue);
    });

    test('funnelNameValidProvider requires both name and surname', () {
      expect(container.read(funnelNameValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setName('Juan');
      expect(container.read(funnelNameValidProvider), isFalse);
      container.read(registrationFunnelProvider.notifier).setSurname('Pérez');
      expect(container.read(funnelNameValidProvider), isTrue);
    });
  });
}
