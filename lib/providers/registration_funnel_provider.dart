import 'package:flutter_riverpod/flutter_riverpod.dart';

final _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
final _passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$');

class RegistrationFunnelState {
  final bool isGuest;
  final int age;
  final String authMethod;
  final String email;
  final String name;
  final String surname;
  final String _password;

  const RegistrationFunnelState({
    this.isGuest = false,
    this.age = 0,
    this.authMethod = '',
    this.email = '',
    String password = '',
    this.name = '',
    this.surname = '',
  }) : _password = password;

  String get password => _password;

  RegistrationFunnelState copyWith({
    bool? isGuest,
    int? age,
    String? authMethod,
    String? email,
    String? password,
    String? name,
    String? surname,
  }) {
    return RegistrationFunnelState(
      isGuest: isGuest ?? this.isGuest,
      age: age ?? this.age,
      authMethod: authMethod ?? this.authMethod,
      email: email ?? this.email,
      password: password ?? _password,
      name: name ?? this.name,
      surname: surname ?? this.surname,
    );
  }
}

class RegistrationFunnelNotifier extends Notifier<RegistrationFunnelState> {
  @override
  RegistrationFunnelState build() => const RegistrationFunnelState();

  void skipToHome() {
    state = state.copyWith(isGuest: true);
  }

  void setAge(int value) {
    state = state.copyWith(age: value);
  }

  void setAuthMethod(String method) {
    state = state.copyWith(authMethod: method);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value.trim());
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setSurname(String value) {
    state = state.copyWith(surname: value);
  }

  void reset() {
    state = const RegistrationFunnelState();
  }

  void clearSensitiveData() {
    state = state.copyWith(password: '', email: '');
  }

  /// Limpia SOLO la contraseña (la credencial), manteniendo email/name/surname
  /// para poder reintentar el registro sin volver a teclear los datos. Se usa
  /// cuando ocurre un error inesperado, de modo que la credencial no quede
  /// residiendo en el estado global más tiempo del necesario.
  void clearPassword() {
    state = state.copyWith(password: '');
  }
}

final registrationFunnelProvider =
    NotifierProvider<RegistrationFunnelNotifier, RegistrationFunnelState>(
      RegistrationFunnelNotifier.new,
    );

final funnelAgeValidProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(registrationFunnelProvider);
  return state.age >= 13;
});

final funnelEmailValidProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(registrationFunnelProvider);
  return _emailRegex.hasMatch(state.email.trim());
});

final funnelPasswordValidProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(registrationFunnelProvider);
  return _passwordRegex.hasMatch(state.password);
});

final funnelNameValidProvider = Provider.autoDispose<bool>((ref) {
  final state = ref.watch(registrationFunnelProvider);
  return state.name.trim().isNotEmpty && state.surname.trim().isNotEmpty;
});
