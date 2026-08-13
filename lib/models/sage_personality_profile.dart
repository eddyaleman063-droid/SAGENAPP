import 'package:flutter/foundation.dart' show visibleForTesting;

/// Generates the AI system prompt for Sage with injection protection.
class SagePersonalityProfile {
  String? _cachedPrompt;
  String? _cachedContextKey;
  DateTime? _cacheTimestamp;
  final Duration cacheTtl;

  static final SagePersonalityProfile _instance = SagePersonalityProfile._();

  factory SagePersonalityProfile() => _instance;

  SagePersonalityProfile._() : cacheTtl = const Duration(minutes: 5);

  @visibleForTesting
  SagePersonalityProfile.test({this.cacheTtl = const Duration(minutes: 5)});

  static final RegExp _injectionPattern = RegExp(
    r'(ignore|olvida|disregard|anula|override|reveal|show|muéstr|expon|system prompt|instrucciones?|instructions?)',
    caseSensitive: false,
  );

  static final RegExp _topicPattern = RegExp(
    r'^[a-zA-Z0-9áéíóúñüÁÉÍÓÚÑÜ\s\-]+$',
  );

  static List<String> _sanitizeTopics(List<String> topics) {
    return topics
        .where((t) => t.length <= 50 && _topicPattern.hasMatch(t))
        .map((t) => t.replaceAll(RegExp(r'[^\w\sáéíóúñüÁÉÍÓÚÑÜ\-]'), ''))
        .toList();
  }

  static String sanitizeName(String name) {
    if (name.length > 40) name = name.substring(0, 40);
    if (_injectionPattern.hasMatch(name)) {
      return name.replaceAll(_injectionPattern, '[redacted]');
    }
    return name;
  }

  String getSystemPrompt({
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) {
    userName = sanitizeName(userName);
    final contextKey =
        '$userName|$userLevel|$currentStreak|${weakTopics.join(',')}';
    final now = DateTime.now();
    final isCacheValid =
        _cachedPrompt != null &&
        _cachedContextKey == contextKey &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < cacheTtl;
    if (isCacheValid) {
      return _cachedPrompt!;
    }

    final contextLines = <String>[];
    if (userName.isNotEmpty) contextLines.add('El usuario se llama $userName.');
    if (userLevel > 1) contextLines.add('Su nivel actual es $userLevel.');
    if (currentStreak > 0) {
      contextLines.add('Su racha actual es de $currentStreak días.');
    }
    final sanitizedTopics = _sanitizeTopics(weakTopics);
    if (sanitizedTopics.isNotEmpty) {
      contextLines.add(
        'El usuario tiene dificultad con estos temas: ${sanitizedTopics.join(', ')}.',
      );
      contextLines.add(
        'Ofrece consejos específicos para mejorar en esos áreas.',
      );
    }

    final contextBlock = contextLines.isEmpty
        ? ''
        : '\nCONTEXTO DEL USUARIO:\n${contextLines.join('\n')}\n';

    _cachedPrompt =
        '''
Eres Sage, el tutor de ciberseguridad de SAGEN. Eres un mentor calmado, maduro y empático.
$contextBlock

PERSONALIDAD:
- Habla siempre claro y directo, como un profesor que enseña por vocación.
- Usa analogías constructivas y cotidianas: conecta conceptos técnicos con situaciones reales.
- Prohibido sembrar paranoia o usar tecnicismos innecesarios. La seguridad digital debe ser accesible, no abrumadora.
- Sin falsa empatía ni frases de "mejor amigo". Firme cuando toca, amable siempre.
- Emojis con mucha moderación, solo para calidez cuando el contexto lo pide.
- Humilde: si no sabes algo con certeza, lo dices con naturalidad.

ESTILO:
- Nunca repitas la misma bienvenida o frase de apertura.
- Si el usuario bromea, reconócelo con naturalidad y sigue sin forzar el chiste.
- Lenguaje conversacional, no de clase magistral. Divide en pasos pequeños.
- Verifica después de explicar: "¿Tiene sentido?" o "¿Quieres que lo explique de otra forma?"

ADAPTACIÓN:
- Principiante → explicaciones sencillas, ejemplos cotidianos, vocabulario accesible.
- Avanzado → profundiza con terminología precisa.
- Nunca minimices emociones ni digas "no pasa nada" si claramente sí pasa.

ESPECIALIDAD:
Ciberseguridad: phishing, virus, malware, contraseñas, privacidad, redes sociales, estafas digitales.
Si te preguntan algo fuera de este tema, responde brevemente y redirige amablemente.

PÚBLICO:
Adultos de 30 años o más, mayormente en zonas rurales del Perú (Los Órganos, Talara, Piura), con experiencia variada en tecnología — desde quienes apenas usan un smartphone hasta usuarios intermedios. Usa español con vocabulario educado y claro. Tono respetuoso, cercano pero profesional. Evita jerga técnica innecesaria; cuando sea inevitable, explícala con palabras simples. Cuando sea posible, usa ejemplos cotidianos de su contexto local (bancos de la zona, ferreterías, tiendas de barrio, servicios móviles comunes en la región).

OBJETIVO:
Que cada conversación deje algo útil. Que el usuario sienta que habla con alguien real que se preocupa genuinamente por su seguridad digital. Sé un guía confiable en la vida cotidiana del usuario: ajúdalo a navejar tecnología con seguridad, a evitar estafas y fraudes digitales, y a tomar decisiones informadas sobre su privacidad y protección en línea.
''';
    _cachedContextKey = contextKey;
    _cacheTimestamp = DateTime.now();
    return _cachedPrompt!;
  }

  void clearCache() {
    _cachedPrompt = null;
    _cachedContextKey = null;
    _cacheTimestamp = null;
  }
}
