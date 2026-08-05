import 'dart:math';
import '../models/chat_message.dart';
import 'ai_service.dart';

/// Offline fallback AI service when Gemini is unreachable.
class LocalFallbackService implements AiService {
  final Random _random = Random();

  @override
  bool get isAvailable => true;

  @override
  void dispose() {}

  @override
  Future<String> generate(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async {
    final lastUser = messages.where((m) => m.role == ChatRole.user).lastOrNull;
    return _generateLocalResponse(lastUser?.text ?? '');
  }

  @override
  Stream<String> generateStream(
    List<ChatMessage> messages, {
    String userName = '',
    int userLevel = 1,
    int currentStreak = 0,
    List<String> weakTopics = const [],
  }) async* {
    final fullResponse = await generate(messages);
    for (int i = 0; i < fullResponse.length; i++) {
      yield fullResponse[i];
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  String _generateLocalResponse(String userMessage) {
    final msg = _removeDiacritics(userMessage.toLowerCase());

    if (msg.contains('hola') || msg.contains('buenos dias') ||
        msg.contains('buenas tardes') || msg.contains('buenas noches') ||
        msg.contains('que tal') || msg.contains('como estas') ||
        msg.contains('hello') || msg.contains('hi') || msg.contains('hey') ||
        msg.contains('good morning') || msg.contains('good afternoon') ||
        msg.contains('good evening') || msg.contains('greetings') ||
        msg.contains('howdy') || msg.contains('sup') ||
        msg.contains('whats up') || msg.contains('how are you')) {
      return [
        '¡Hola! Soy Sage, tu tutor de ciberseguridad. ¿Cómo puedo ayudarte hoy? Puedo explicarte sobre phishing, contraseñas seguras, privacidad en redes sociales, malware y mucho más. ¿Qué te gustaría aprender?',
        '¡Buenas! Me alegra verte por aquí. ¿Listo para aprender algo nuevo sobre seguridad digital? Puedo ayudarte con cualquier pregunta que tengas.',
        '¡Hola! Soy Sage, y estoy aquí para que aprendamos juntos a protegerte en línea. ¿Por dónde te gustaría empezar?',
      ][_random.nextInt(3)];
    }

    if (msg.contains('gracias') || msg.contains('thank you') ||
        msg.contains('thx') || msg.contains('muy util') ||
        msg.contains('muy util') || msg.contains('muchas gracias') ||
        msg.contains('thanks') || msg.contains('appreciate') ||
        msg.contains('very helpful') || msg.contains('thanks a lot') ||
        msg.contains('cheers') || msg.contains('grateful')) {
      return [
        '¡De nada! Para eso estoy aquí. Si alguna vez tienes otra pregunta sobre seguridad digital, no dudes en preguntar.',
        'Me alegra haber podido ayudar. Recuerda que la seguridad digital es un hábito que se construye día a día. ¿Hay algo más que te gustaría aprender?',
        '¡Un placer! Cuando quieras saber más sobre cómo protegerte en línea, estaré aquí.',
      ][_random.nextInt(3)];
    }

    if (msg.contains('adios') || msg.contains('hasta luego') ||
        msg.contains('nos vemos') || msg.contains('chau') ||
        msg.contains('bye') || msg.contains('goodbye') ||
        msg.contains('see you') || msg.contains('later') ||
        msg.contains('farewell') || msg.contains('take care') ||
        msg.contains('see ya') || msg.contains('gotta go')) {
      return [
        '¡Adiós! Recuerda aplicar lo que aprendiste para estar seguro en línea. ¡Cuídate mucho!',
        'Nos vemos pronto. Sigue protégiéndote y recuerda: cada clic cuenta. ¡Cuídate!',
        'Hasta la próxima. Si alguna vez tienes preguntas sobre seguridad digital, estaré aquí para ayudarte.',
      ][_random.nextInt(3)];
    }

    if (msg.contains('no entiendo') || msg.contains('confundido') ||
        msg.contains('explicar') || msg.contains('no claro') ||
        msg.contains('mas simple') || msg.contains('mas claro') ||
        msg.contains('repetir') || msg.contains('otra vez') ||
        msg.contains('que quieres decir') || msg.contains('puedes reformular') ||
        msg.contains("don't understand") || msg.contains('confused') ||
        msg.contains('explain') || msg.contains('unclear') ||
        msg.contains('simpler') || msg.contains('clearer') ||
        msg.contains('repeat') || msg.contains('again') ||
        msg.contains('what do you mean') || msg.contains('can you rephrase')) {
      return [
        'Claro, déjame decirlo de otra manera. Piensa en la ciberseguridad como las cerraduras de tu casa: cada medida de seguridad es una cerradura extra que pones para proteger lo que más importa. ¿Qué parte te gustaría que te explicara con más detalle?',
        'No te preocupes, estas cosas pueden ser confusas al principio. Vamos paso a paso. ¿Qué no quedó claro? Podemos empezar desde el principio o enfocarnos en la parte que te resulte más difícil.',
        'Entiendo, algunos conceptos pueden sonar complicados. Vamos a simplificarlo. La idea principal es que todo lo que haces en línea tiene riesgos, y aprender a identificarlos es como aprender las reglas de seguridad vial antes de conducir. ¿Esta explicación te ayuda o prefieres que lo veamos de otra manera?',
      ][_random.nextInt(3)];
    }

    if (msg.contains('como estas') || msg.contains('que tal') ||
        msg.contains('como vas') || msg.contains('todo bien') ||
        msg.contains('que haces') || msg.contains('que paso') ||
        msg.contains('como estas') || msg.contains('how are you') ||
        msg.contains("what's up") || msg.contains("how's it going") ||
        msg.contains('you okay') || msg.contains('what are you doing') ||
        msg.contains("what's new") || msg.contains("how've you been")) {
      return _defaultResponses[_random.nextInt(_defaultResponses.length)];
    }

    if (msg.contains('phishing') || msg.contains('phising') ||
        msg.contains('correo falso') || msg.contains('estafa por correo') ||
        msg.contains('suplantacion') || msg.contains('impersonation') ||
        msg.contains('fake email') || msg.contains('scam email') ||
        msg.contains('spoofing')) {
      return _getRandomResponse('phishing');
    }

    if (msg.contains('contraseña') || msg.contains('contrasena') ||
        msg.contains('clave') || msg.contains('password') ||
        msg.contains('passphrase') || msg.contains('pin') ||
        msg.contains('2fa') || msg.contains('two factor') ||
        msg.contains('two-factor') || msg.contains('autenticacion') ||
        msg.contains('authentication') || msg.contains('credential') ||
        msg.contains('credencial')) {
      return _getRandomResponse('passwords');
    }

    if (msg.contains('navegacion') || msg.contains('navegar') ||
        msg.contains('internet') || msg.contains('pagina web') ||
        msg.contains('sitio web') || msg.contains('https') ||
        msg.contains('certificado') || msg.contains('peligroso') ||
        msg.contains('descargar') || msg.contains('browsing') ||
        msg.contains('browse') || msg.contains('website') ||
        msg.contains('web page') || msg.contains('dangerous') ||
        (msg.contains('download') && !msg.contains('malware'))) {
      return _getRandomResponse('safe browsing');
    }

    if (msg.contains('redes sociales') || msg.contains('instagram') ||
        msg.contains('facebook') || msg.contains('tiktok') ||
        msg.contains('twitter') || msg.contains('x ') ||
        msg.contains('whatsapp') || msg.contains('privacidad') ||
        msg.contains('publicar') || msg.contains('etiquetar') ||
        msg.contains('perfil') || msg.contains('social media') ||
        msg.contains('posting') || msg.contains('tag') ||
        msg.contains('profile') || msg.contains('privacy')) {
      return _getRandomResponse('social media privacy');
    }

    if (msg.contains('wifi') || msg.contains('wi-fi') ||
        msg.contains('router') || msg.contains('inalambrico') ||
        msg.contains('vpn') || msg.contains('red publica') ||
        msg.contains('cafeteria') || msg.contains('conectar') ||
        msg.contains('wireless') || msg.contains('public network') ||
        msg.contains('cafe') || msg.contains('connect')) {
      return _getRandomResponse('wifi security');
    }

    if (msg.contains('virus') || msg.contains('malware') ||
        msg.contains('trojan') || msg.contains('ransomware') ||
        msg.contains('spyware') || msg.contains('antivirus') ||
        msg.contains('infectado') || msg.contains('infeccion') ||
        msg.contains('infected') || msg.contains('infection')) {
      return _getRandomResponse('malware');
    }

    if (msg.contains('identidad') || msg.contains('robo de datos') ||
        msg.contains('robar identidad') || msg.contains('robo de identidad') ||
        msg.contains('pasaporte') || msg.contains('documento') ||
        msg.contains('tarjeta de credito') || msg.contains('financiero') ||
        msg.contains('identity') || msg.contains('data theft') ||
        msg.contains('steal identity') || msg.contains('identity theft') ||
        msg.contains('passport') || msg.contains('credit card') ||
        msg.contains('financial')) {
      return _getRandomResponse('identity theft');
    }

    if (msg.contains('estafa') || msg.contains('fraude') ||
        msg.contains('truco') || msg.contains('dinero facil') ||
        msg.contains('premio') || msg.contains('loteria') ||
        msg.contains('falso') || msg.contains('engañar') ||
        msg.contains('scam') || msg.contains('con') ||
        msg.contains('easy money') || msg.contains('lottery') ||
        msg.contains('fake') || msg.contains('deceive')) {
      return _getRandomResponse('online scams');
    }

    if (msg.contains('huella digital') || msg.contains('rastro') ||
        msg.contains('permanente') || msg.contains('busqueda') ||
        msg.contains('google') || msg.contains('reputacion en linea') ||
        msg.contains('footprint') || msg.contains('trace') ||
        msg.contains('search') || msg.contains('online reputation')) {
      return _getRandomResponse('digital footprint');
    }

    if (msg.contains('ciberbullying') || msg.contains('acoso') ||
        msg.contains(' acosador') || msg.contains('humillar') ||
        msg.contains('amenazar') || msg.contains('insultar') ||
        msg.contains('intimidar') || msg.contains('bullying') ||
        msg.contains('harassment') || msg.contains('cyberbully') ||
        msg.contains('humiliate') || msg.contains('threaten') ||
        msg.contains('insult') || msg.contains('intimidate')) {
      return _getRandomResponse('cyberbullying');
    }

    return _defaultResponses[_random.nextInt(_defaultResponses.length)];
  }

  String _getRandomResponse(String topic) {
    final responses = _topicResponses[topic];
    if (responses == null || responses.isEmpty) {
      return _defaultResponses[_random.nextInt(_defaultResponses.length)];
    }
    return responses[_random.nextInt(responses.length)];
  }

  String _removeDiacritics(String input) {
    const diacritics = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'ü': 'u', 'ñ': 'n',
      'Á': 'a', 'É': 'e', 'Í': 'i', 'Ó': 'o', 'Ú': 'u',
      'Ü': 'u', 'Ñ': 'n',
    };
    var result = input;
    diacritics.forEach((original, replacement) {
      result = result.replaceAll(original, replacement);
    });
    return result;
  }

  static final Map<String, List<String>> _topicResponses = {
    'phishing': [
      'El phishing es cuando los ciberdelincuentes se hacen pasar por empresas conocidas o personas para robar tu información como contraseñas o datos de tarjetas de crédito. Lo hacen generalmente a través de correos electrónicos, mensajes de texto o llamadas falsas. ¿Cómo protegerte? Nunca hagas clic en enlaces de correos inesperados, siempre verifica la dirección del remitente y las empresas legítimas nunca te pedirán tu contraseña por mensaje. ¿Quieres saber más sobre algún aspecto del phishing?',
      '¡Excelente pregunta! El phishing es uno de los ataques más comunes y peligrosos en internet. Imagina esto: recibes un correo que parece ser de tu banco, diciendo que alguien accedió a tu cuenta y pidiéndote que hagas clic en un enlace para verificar tus datos. Pero ese enlace lleva a un sitio web falso, idéntico al real, que roba tu contraseña. Consejo clave: siempre verifica la URL, los sitios falsos suelen tener errores de ortografía o dominios extraños. ¿Tienes dudas sobre un correo o mensaje específico?',
      'El phishing es el arte del engaño digital. Los atacantes usan ingeniería social para manipularte. Algunas señales de alerta: saludos genéricos (Estimado cliente en lugar de tu nombre), errores de ortografía y gramática, enlaces acortados, o una sensación de urgencia (¡Tu cuenta será cerrada en 24 horas!). Lo más importante: si algo parece sospechoso, no respondas, no hagas clic y contacta a la empresa directamente a través de sus canales oficiales. ¿Te gustaría practicar identificando un correo de phishing?'
    ],
    'passwords': [
      'Tus contraseñas son las llaves de tu vida digital, así que debes cuidarlas bien. ¿Qué hace a una contraseña segura? Debe ser larga (12 caracteres o más), mezclar mayúsculas, minúsculas, números y símbolos, y NO usar información personal como tu nombre, fecha de nacimiento o 123456. Consejo extra: usa un gestor de contraseñas para crear y almacenar contraseñas únicas para cada cuenta. ¡Nunca reutilices contraseñas! ¿Quieres saber más sobre los gestores de contraseñas?',
      '¡Tema excelente! Aquí va un secreto: la longitud es más importante que la complejidad. Una contraseña como GatoDormido@2024 es mucho más segura que P@ssw0rd y más fácil de recordar. Otras reglas de oro: 1) Una contraseña diferente para cada sitio, 2) Nunca las compartas con nadie, 3) Activa la autenticación de dos factores (2FA) siempre que puedas. Y recuerda: si recibes un correo diciendo que tu contraseña está en riesgo, cámbiala INMEDIATAMENTE. ¿Sabes qué es la autenticación de dos factores?',
      'Las contraseñas débiles son como dejar la puerta de tu casa abierta. Los hackers usan programas que prueban millones de combinaciones por segundo. Las peores contraseñas del mundo siguen siendo: 123456, password, qwerty, 111111. No uses esas. Lo mejor que puedes hacer hoy: ve a la configuración de tu correo y redes sociales, y activa la verificación en dos pasos. Esa segunda capa de protección hace mucho más difícil que alguien acceda a tu cuenta. ¿Te gustaría que te explique cómo funciona la verificación en dos pasos?'
    ],
    'safe browsing': [
      'Navegar de forma segura es más fácil de lo que parece. Aquí van mis mejores consejos: 1) Siempre usa HTTPS, busca el candado en la URL, 2) Mantén tu navegador y sistema operativo actualizados (las actualizaciones corrigen fallas de seguridad), 3) Ten cuidado con lo que descargas, solo de sitios oficiales y confiables, 4) Usa un bloqueador de anuncios para evitar publicidad maliciosa. Y recuerda: si algo en un sitio web se ve raro, confía en tu instinto y cierra la página. ¿Hay algo específico que quieras saber?',
      '¡Navegar seguro es esencial! Aquí van consejos prácticos: Primero, aprende a leer URLs. El https:// significa que la conexión está cifrada, la s significa seguro. Si solo dice http:// (sin la s), NO ingreses datos sensibles ahí. Segundo: las ventanas emergentes que dicen ¡Tu computadora tiene un virus! casi siempre son estafas. No hagas clic en ellas. Tercero: considera usar DNS seguros o una VPN cuando estés en redes públicas. ¿Sabes qué es una VPN y cómo te protege?',
      'Navegar por internet es como caminar por una ciudad, hay zonas seguras y zonas peligrosas. ¿Cómo identificar las seguras? - Dominio que conoces y en el que confías - Candado en la barra de direcciones - Diseño profesional, sin errores extraños - Sin publicidad excesiva o engañosa Señales de alerta: - Sitios que prometen cosas demasiado buenas para ser verdad (películas recientes gratis, software pirata, apuestas) - Anuncios parpadeando y diciendo que ganaste un premio - URLs con errores de ortografía (faceb0ok.com, netfflix.com) ¿Has encontrado sitios sospechosos últimamente?'
    ],
    'social media privacy': [
      'Tu privacidad en redes sociales es tu tesoro digital. Así es como puedes protegerla: 1) Revisa y ajusta tu configuración de privacidad regularmente, las plataformas cambian sus opciones, 2) Piensa DOS VECES antes de publicar: ¿quieres que ese contenido sea público para siempre? 3) No aceptes solicitudes de amistad de personas que no conoces, 4) Ten cuidado con cuestionarios y juegos en redes sociales que piden permisos excesivos. ¿Sabías que lo que publicas hoy puede afectarte en una futura entrevista de trabajo?',
      '¡Muy importante! Las redes sociales son fantásticas para conectarse, pero debes usarlas con sabiduría. Consejo #1: Controla quién ve tus publicaciones. En casi todas las apps puedes configurar tus publicaciones para amigos solamente o más privadas. Consejo #2: NUNCA compartas tu ubicación en tiempo real o publiques fotos de tu escuela, hogar o rutina diaria que puedan usarse para encontrarte. Consejo #3: La información en tu perfil (fecha de nacimiento, teléfono, correo) no debería ser pública. ¿Has revisado tu configuración de privacidad últimamente?',
      'Las empresas y los hackers pueden aprender MUCHO sobre ti a partir de tus redes sociales. Cada me gusta, cada publicación, cada ubicación compartida crea un perfil detallado de quién eres, qué te gusta y dónde estás. Para protegerte: - Activa la autenticación de dos factores en todas tus cuentas de redes - Usa contraseñas fuertes y diferentes para cada red - Pregúntate: ¿Diría esto en voz alta frente a toda mi familia y escuela? Si la respuesta es no, mejor no lo publiques - Desactiva los servicios de ubicación para apps que no los necesitan. ¿Te gustaría saber cómo ver qué datos tienen las redes sociales sobre ti?'
    ],
    'wifi security': [
      'El WiFi es conveniente, pero puede ser peligroso si no te proteges. Aquí van mis consejos: En casa: 1) Cambia la contraseña predeterminada de tu router, 2) Usa WPA2 o WPA3 como tipo de seguridad (nunca WEP), 3) Ponle nombre a tu red para que no revele tu apellido o dirección. En redes públicas (cafeterías, centros comerciales): 1) NO hagas transferencias ni compras, 2) Considera usar una VPN, 3) Desactiva la conexión automática a redes abiertas. ¿Sabes qué es una VPN?',
      '¡Gran pregunta sobre seguridad WiFi! Déjame explicarte: Una red WiFi abierta (sin contraseña) es como tener una conversación en voz alta en un lugar público, cualquiera puede escuchar. Los hackers en redes públicas pueden usar herramientas para ver lo que haces en línea, robar tus contraseñas, o incluso crear redes falsas con nombres como WiFi Gratis para engañarte. Mis recomendaciones: - En casa: actualiza el firmware de tu router regularmente - En público: asume que alguien está observando. Evita acceder a sitios importantes como tu banco - Si usas WiFi público a menudo, busca información sobre VPNs, cifran tu conexión. ¿Quieres saber más sobre las VPNs?',
      'Tu WiFi en casa es la puerta de entrada a todos tus dispositivos. Si alguien se conecta a tu red sin permiso, puede: - Ver todo lo que haces en línea - Acceder a tus archivos compartidos - Instalar malware en tus dispositivos Para proteger tu red en casa: 1) Contraseña larga y única para el WiFi 2) Nombre de red (SSID) que no revele tu identidad 3) Desactiva WPS si no lo estás usando 4) Actualiza tu router ocasionalmente. Y consejo adicional: crea una red WiFi separada para invitados o dispositivos inteligentes (cámaras, parlantes). Así, si algo se ve comprometido, tu red principal se mantiene segura. ¿Tienes dispositivos inteligentes conectados a tu WiFi?'
    ],
    'malware': [
      'El malware (software malicioso) es cualquier programa diseñado para dañar o robar información de tu dispositivo. Hay muchos tipos: virus, troyanos, ransomware, spyware, adware... ¿Cómo te infectas? Generalmente a través de: - Archivos adjuntos de correos sospechosos - Descargas de sitios no oficiales - Enlaces peligrosos - Dispositivos USB de fuentes desconocidas ¿Cómo protegerte? 1) Ten un buen antivirus (y mantenlo actualizado) 2) No abras archivos de personas que no conoces 3) Mantén tu sistema y apps actualizadas 4) Haz copias de seguridad regularmente. ¿Quieres saber sobre algún tipo específico de malware?',
      '¡Excelente pregunta! El malware es como un virus biológico pero para computadoras. Uno de los más peligrosos hoy en día es el ransomware, cifra todos tus archivos y exige un pago (rescate) para devolvértelos. ¿Cómo prevenirlo? - Haz copias de seguridad CONSTANTEMENTE (en disco externo y/o nube) - No habilites macros en archivos de Office que no esperabas - Ten cuidado con archivos .zip, .exe, .bat de fuentes desconocidas Otro tipo común es el spyware, un programa que espía todo lo que haces y envía tus datos a un hacker. El mejor escudo: el sentido común y el software de seguridad. ¿Sabes qué hacer si crees que tienes malware?',
      'Todo el mundo debería saber esto sobre el malware: 1) Tu computadora no se infecta sola, siempre hay una acción del usuario (un clic, una descarga) que permite la entrada. 2) Los antivirus gratuitos a veces SON el malware. Solo descarga software de desarrolladores reconocidos. 3) Los teléfonos móviles también pueden infectarse con malware, solo descarga apps de tiendas oficiales (Google Play, App Store). 4) Si ves anuncios extraños apareciendo de la nada, o tu dispositivo está muy lento, o aparecen apps que no instalaste, podrías tener malware. Pasos: actualiza tu antivirus, ejecuta un escaneo completo, y si no se va, consulta a un profesional. ¿Ha pasado algo extraño con tu dispositivo últimamente?'
    ],
    'identity theft': [
      'El robo de identidad es cuando alguien usa tus datos personales (nombre, cédula, tarjeta de crédito, contraseñas) para hacerse pasar por ti. Pueden: abrir cuentas bancarias, solicitar préstamos, hacer compras, incluso cometer crímenes en tu nombre. ¿Cómo protegerte? 1) Nunca compartas tu número completo de cédula, contraseñas o códigos de verificación. 2) Revisa regularmente tus estados de cuenta bancarios y de tarjetos de crédito por cargos que no reconozcas. 3) Usa contraseñas fuertes y autenticación de dos factores. 4) Ten cuidado donde ingresas tus datos, solo en sitios seguros con HTTPS. ¿Quieres saber más sobre alguna medida de protección?',
      '¡Tema muy importante! El robo de identidad puede arruinar tu vida financiera y tomar años en solucionarse. Señales de advertencia de que algo está mal: - Recibes facturas de cosas que no compraste - Te niegan un crédito sin razón aparente - Agencias de cobranza llaman por deudas que no son tuyas - Notas cambios en tus cuentas que no realizaste Si crees que eres víctima: 1) INMEDIATAMENTE informa a tu banco y a las autoridades 2) Cambia TODAS tus contraseñas desde un dispositivo seguro 3) Guarda evidencia de todo (correos, mensajes, capturas de pantalla) La prevención es clave. ¿Sabes cómo los criminales roban identidades?',
      'Los ladrones de identidad usan muchas tácticas: Phishing: correos y mensajes que piden tus datos. Filtraciones de datos: cuando una empresa es hackeada y tus datos se filtran. Mirada sobre el hombro: alguien mirando por encima de tu hombro cuando ingresas tu PIN. Malware: programas que roban tu información. Búsqueda en basura: revisar tu basura buscando documentos con datos. ¿Cómo hacer más difícil el trabajo a los ladrones? - Destruye documentos con datos personales antes de tirarlos - No lleves tu cédula a menos que sea absolutamente necesario - Nunca respondas preguntas de verificación por teléfono si no iniciaste la llamada - Monitorea tus cuentas regularmente. ¿Alguna vez alguien ha intentado usar tus datos sin permiso?'
    ],
    'online scams': [
      'Las estafas en línea engañan a miles de personas cada día. Las más comunes: 1) Ganaste la lotería/regalo, te piden pagar impuestos para recibir tu premio. 2) Romance en línea: personas que crean perfiles falsos para que te enamores y luego piden dinero. 3) Trabajo desde casa gana dinero fácil y rápido, son pirámides o formas de robar tu dinero. 4) Soporte técnico falso llamando diciendo que tu computadora tiene un virus. Regla de oro: si algo suena demasiado bueno para ser verdad, PROBABLEMENTE es una estafa. Nunca pagues por adelantado por premios increíbles u oportunidades. ¿Has recibido mensajes así?',
      '¡Conocer las estafas es la mejor defensa! Déjame contarte sobre las más modernas: - La estafa del familiar: llaman diciendo que es tu primo/tío/amigo en problemas y necesita dinero urgentemente (sin poder hablar mucho por teléfono). - El trabajo falso: te contratan sin entrevista, te piden pagar por materiales de trabajo o abrir una cuenta de transferencias. - Criptomonedas falsas: plataformas que parecen inversiones pero son fraude. - Estafas de compras: en Facebook Marketplace, Instagram, etc., el vendedor pide pago por adelantado y desaparece. Mi consejo: siempre verifica la identidad de la otra persona. Busca en Google su nombre, su número de teléfono. Pide una videollamada. Si se niegan, señal de alerta. ¿Conoces a alguien que haya sido estafado en línea?',
      'Las estafas evolucionan, pero siempre siguen el mismo patrón: crean URGENCIA o CODICIA para que actúes sin pensar. Tienes 24 horas para reclamar tu herencia. Últimos cupos para este curso que te hará millonario. Tu paquete está retenido, paga \$50 para liberarlo. ¿Qué hacer cuando recibes algo sospechoso? 1) Detente. No respondas inmediatamente. 2) Piensa. ¿Tiene sentido? ¿Lo estabas esperando? 3) Verifica. Busca en Google el texto del mensaje + estafa. 4) Consulta con alguien de confianza. Cuéntale a un amigo o familiar lo que recibiste. Y recuerda: NINGUNA empresa legítima te pedirá pagar con tarjetas de regalo, criptomonedas o transferencias Western Union. Esas son señales SEGURAS de una estafa. ¿Alguna vez casi caes en una?'
    ],
    'digital footprint': [
      'Tu huella digital es TODO lo que haces, publicas y compartes en línea. Publicaciones en redes sociales, comentarios, me gusta, búsquedas que haces, fotos en las que te etiquetan, compras en línea... TODO. Lo más importante que debes saber: TU HUELLA DIGITAL ES PERMANENTE. Una vez que algo sale en internet, aunque lo borres después, puede haber sido guardado por alguien. Consecuencias: las universidades revisan perfiles de redes sociales, los empleadores buscan candidatos, incluso las relaciones futuras pueden verse afectadas por cosas que publicaste cuando eras más joven. Consejo: antes de publicar algo, pregúntate: ¿Quisiera que mi abuela, mi profesor o mi futuro jefe viera esto? ¿Te gustaría buscar tu propia huella digital?',
      '¡Concepto fundamental! Tu huella digital tiene dos partes: Activa: lo que TÚ publicas voluntariamente (fotos, estados, comentarios). Pasiva: lo que otros publican sobre ti (etiquetas, fotos), y lo que las empresas recopilan sobre ti (tus búsquedas, tu ubicación, cuánto tiempo pasas en cada app). Aquí va algo que te sorprenderá: cada vez que usas un motor de búsqueda gratuito, cada red social gratuita, cada app gratuita, TÚ ERES EL PRODUCTO. Tu atención, tus datos, tus preferencias... todo se vende a anunciantes. ¿Qué puedes hacer? - Usa motores de búsqueda que respeten tu privacidad (como DuckDuckGo) - Desactiva el rastreo de ubicación cuando no lo necesites - Pregúntate: ¿Estoy dispuesto a cambiar mi privacidad por este servicio gratuito? ¿Te gustaría saber más sobre privacidad y datos?',
      'Manejar tu huella digital es parte de ser un ciudadano digital responsable. Aquí va un ejercicio práctico para hacer hoy: 1) Busca tu nombre completo (entre comillas) en Google. Mira qué aparece. 2) Haz lo mismo en imágenes. 3) Ve a la configuración de privacidad de cada red social y revisa qué es público. Si encuentras algo que no te gusta: - Puedes pedirle a la persona que lo publicó que lo borre - Puedes reportarlo a la plataforma si es ofensivo - Para cosas que no puedes borrar de sitios de otros, intenta enterrarlas creando contenido positivo y profesional (un perfil de LinkedIn bien hecho, por ejemplo). Y recuerda: internet no olvida. Pero TÚ PUEDES decidir qué huella dejas. ¿Alguna vez has buscado tu nombre en Google?'
    ],
    'cyberbullying': [
      'El ciberbullying es acoso que ocurre a través de tecnologías digitales: mensajes amenazantes, rumores en redes sociales, creación de perfiles falsos para humillar a alguien, exclusión intencional de grupos... A diferencia del acoso físico, el ciberbullying puede seguirte A TODAS PARTES, 24 horas al día, y sentirse imposible de escapar. Si eres víctima: 1) NO ES TU CULPA 2) Tienes derecho a estar seguro 3) Cuéntale a un adulto de confianza (padre, profesor, orientador) 4) Bloquea y reporta al acosador en la plataforma 5) GUARDA EVIDENCIA (capturas de pantalla, mensajes guardados) te ayudará a probar lo que está pasando. ¿Te gustaría saber más sobre qué hacer si lo ves pasándole a alguien?',
      'Es extremadamente importante hablar de esto. El ciberbullying puede tener efectos devastadores: ansiedad, depresión, aislamiento, incluso pensamientos suicidas. Aquí van datos que debes saber: - Puede ser peor que el acoso tradicional porque siempre está presente y es público - Las víctimas a menudo no hablan por vergüenza o miedo a represalias - No tienes que ser el acosador directo para ser parte del problema, reírse, compartir o darle me gusta a contenido humillante también contribuye. Si ves a alguien siendo acosado: 1) No seas espectador silencioso 2) Muestra apoyo a la víctima 3) Reporta el contenido 4) Cuéntale a un adulto. Y si TÚ eres el que acosa: detente. Hay ayuda disponible. Habla con alguien que pueda guiarte. ¿Conoces las señales de que alguien está sufriendo ciberbullying?',
      'Nadie tiene derecho a hacerte sentir mal, especialmente a través de internet. Aquí va una guía práctica si experimentas ciberbullying: PASO 1: No respondas. Los acosadores quieren una reacción. Darles atención es lo que buscan. PASO 2: Bloquea. En todas las plataformas, juegos, apps. Bloquea sin dudar. PASO 3: GUARDA TODO. Capturas de pantalla, mensajes, correos, fechas. Esto es EVIDENCIA. PASO 4: Reporta. Usa las herramientas de reporte en cada app (Facebook, Instagram, TikTok, WhatsApp todas las tienen). PASO 5: CUÉNTALE A ALGUIEN. Cuéntale a alguien: mamá, papá, profesor, orientador, psicólogo. No estás solo. Y recuerda: el problema no eres TÚ, es el acosador. ¿Hay algo específico que te preocupa o que quieres compartir? Estoy aquí para escucharte sin juzgar.'
    ],
  };

  static final List<String> _defaultResponses = [
    '¡Hola! Soy Sage, tu asistente de ciberseguridad. Estoy aquí para ayudarte a protegerte en línea. ¿De qué te gustaría hablar hoy? Puedo ayudarte con temas como: contraseñas seguras, phishing, malware, privacidad en redes sociales, seguridad WiFi, estafas en línea y mucho más. ¿Qué tema te interesa más?',
    '¡Buenas! Me alegra que estés aquí hablando de ciberseguridad. Es el mejor regalo que puedes darte a ti mismo en el mundo digital. ¿Hay algo específico que te haya estado preocupando últimamente? O si prefieres, puedo sugerirte temas: - Cómo crear contraseñas que nadie pueda descifrar - Qué es el phishing y cómo evitarlo - Cómo configurar tu privacidad en Instagram - Por qué deberías activar la verificación en dos pasos ¿Qué te llama la atención?',
    '¡Bienvenido a un espacio seguro para aprender! La ciberseguridad no es solo para expertos, es para todos los que usamos internet (que somos casi todos). Cada clic, cada descarga, cada publicación... todo se puede hacer de forma más segura. ¿Te gustaría empezar por lo básico o tienes una situación específica que quieres resolver? Cuéntame y juntos encontraremos la mejor forma de protegerte.',
    'Entiendo que preguntas sobre ciberseguridad. Es un tema amplio pero muy importante. ¿Podrías contarme más específicamente qué te gustaría saber? Puedo ayudarte con phishing, contraseñas, malware, privacidad en redes sociales, seguridad WiFi y mucho más.',
    '¡Buena pregunta! La ciberseguridad puede parecer complicada al principio, pero te lo explicaré de forma simple. Cuéntame qué tema específico quieres aprender y te daré toda la información que necesitas.',
    'Me encanta que te interese protegerte en línea. Hay varios temas clave que deberías conocer: cómo crear contraseñas seguras, cómo detectar correos de phishing, cómo proteger tu privacidad en redes sociales, y más. ¿Con cuál te gustaría empezar?',
  ];
}
