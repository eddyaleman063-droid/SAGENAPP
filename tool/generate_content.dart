// ignore_for_file: avoid_print, prefer_const_declarations

// Run: dart tool/generate_content.dart
// Generates assets/content/ from learning_data.dart + assets/questions.json

import 'dart:convert';
import 'dart:io';

void main() {
  final contentDir = Directory('assets/content');
  if (!contentDir.existsSync()) contentDir.createSync();

  // ── 1. Build stages.json from hardcoded data ──
  final stages = _buildStages();
  File(
    'assets/content/stages.json',
  ).writeAsStringSync(jsonEncode(stages), flush: true);
  print('Wrote assets/content/stages.json (${stages.length} stages)');

  // ── 2. Build manifest.json ──
  final manifest = {
    'version': '1.0.0',
    'stages': stages.map((s) => s['id']).toList(),
  };
  File(
    'assets/content/manifest.json',
  ).writeAsStringSync(jsonEncode(manifest), flush: true);
  print('Wrote assets/content/manifest.json');

  // ── 3. Split questions.json into per-stage files ──
  final questionsPath = 'assets/questions.json';
  if (!File(questionsPath).existsSync()) {
    print('WARNING: $questionsPath not found — no questions generated');
    return;
  }
  final raw =
      jsonDecode(File(questionsPath).readAsStringSync())
          as Map<String, dynamic>;

  // Per-stage questions
  final stagePools = raw['stagePools'] as Map<String, dynamic>?;
  if (stagePools != null) {
    for (final entry in stagePools.entries) {
      File(
        'assets/content/questions_${entry.key}.json',
      ).writeAsStringSync(jsonEncode(entry.value), flush: true);
      final list = entry.value as List;
      print('  ${entry.key}: ${list.length} questions');
    }
  }

  // Write fallback topic pool questions (lessons not in stage pools)
  final topicPools = raw['topicPools'] as Map<String, dynamic>?;
  if (topicPools != null) {
    // Flatten all topic pools into a single "default" stage file
    final allTopic = <Map<String, dynamic>>[];
    for (final entry in topicPools.entries) {
      if (entry.key == 'default') {
        allTopic.addAll((entry.value as List).cast());
      }
    }
    File(
      'assets/content/questions_default.json',
    ).writeAsStringSync(jsonEncode(allTopic), flush: true);
    print('  default: ${allTopic.length} topic-pool questions');
  }

  // By-type questions (for randomForType)
  final byType = raw['questionsByType'] as Map<String, dynamic>?;
  if (byType != null) {
    File(
      'assets/content/questions_by_type.json',
    ).writeAsStringSync(jsonEncode(byType), flush: true);
    final total = byType.values.fold<int>(0, (s, l) => s + (l as List).length);
    print('  by_type: $total questions');
  }

  print('Done — all content assets generated.');
}

List<Map<String, dynamic>> _buildStages() {
  final List<Map<String, dynamic>> stages = [];

  void addStage(
    int num,
    String id,
    String title,
    String subtitle,
    String accent,
    List<String> sessionTitles,
    List<List<String>> lessonsBySession,
    int count,
  ) {
    final sessions = <Map<String, dynamic>>[];
    for (int i = 0; i < count; i++) {
      final sesNum = i + 1;
      final lessonTitles = i < lessonsBySession.length
          ? lessonsBySession[i]
          : List.generate(5, (j) => 'Práctica ${j + 1}');
      final lessons = lessonTitles.asMap().entries.map((e) {
        final lNum = e.key + 1;
        return <String, dynamic>{
          'id': 'ac_s${num}_ses${sesNum}_l$lNum',
          'title': e.value,
          'subtitle': 'Lección $lNum de la sesión $sesNum',
          'challenges': <dynamic>[],
          'xpReward': 15,
          'gemReward': 5,
          'estimatedMinutes': 3,
          'completed': false,
        };
      }).toList();
      sessions.add(<String, dynamic>{
        'id': 'ac_s${num}_ses$sesNum',
        'title': i < sessionTitles.length
            ? sessionTitles[i]
            : 'Sesión adicional $sesNum',
        'subtitle': 'Sesión $sesNum · ${lessons.length} lecciones',
        'lessons': lessons,
        'completed': false,
        'questionCount': 15,
      });
    }
    stages.add(<String, dynamic>{
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'accent': accent,
      'icon': _iconCode('shield'),
      'sessions': sessions,
      'unlocked': false,
      'bonus': false,
    });
  }

  addStage(
    1,
    'ac_st1',
    'Fundamentos',
    'Bases para proteger tus cuentas',
    '#FF6F00',
    [
      '¿Qué es una cuenta digital?',
      'Tipos de cuentas que usas a diario',
      'Riesgos básicos al crear cuentas',
      'La importancia de la privacidad',
      'Tu identidad digital',
      'Huella digital y cuentas',
      'Datos sensibles en tus cuentas',
      'Correo electrónico: la clave maestra',
      'Números de teléfono y verificación',
      'Preguntas de seguridad básicas',
      'Configuración inicial de privacidad',
      'Notificaciones de seguridad',
      'Dispositivos vinculados',
      'Copias de seguridad básicas',
      'Cierre de sesión seguro',
      'Actualizaciones de seguridad',
      'Phishing básico: no todo es lo que parece',
      'Enlaces sospechosos',
      'Extensiones y apps de terceros',
      'Evaluación de fundamentos',
    ],
    [
      [
        'Introducción a las cuentas digitales',
        '¿Qué hace segura a una cuenta?',
        'Diferencias entre cuenta local y en línea',
        'Ejemplos de cuentas digitales cotidianas',
        'Elementos básicos de una cuenta segura',
      ],
      [
        'Cuentas de correo',
        'Redes sociales',
        'Bancos y finanzas',
        'Streaming y compras',
        'Identificar todas tus cuentas activas',
      ],
      [
        'Contraseñas débiles',
        'Reúso de contraseñas',
        'Falta de 2FA',
        'Exceso de información personal en el perfil',
        'No leer términos y condiciones',
      ],
      [
        'Qué información no compartir',
        'Configura quién ve tu perfil',
        'Ajustes de privacidad esenciales',
        'Información que nunca debes publicar',
        'Privacidad en fotos y etiquetas',
      ],
      [
        'Qué es la identidad digital',
        'Cómo se construye con tus cuentas',
        'Reputación en línea',
        'Identidad digital vs identidad real',
        'Construir una identidad digital positiva',
      ],
      [
        'Rastros que dejas al navegar',
        'Cómo se vinculan tus cuentas',
        'Cookies y tracking',
        'Huella en buscadores y redes',
        'Minimizar tu huella digital',
      ],
      [
        'Dirección, DNI, fechas',
        'Por qué cuidarlos en cada cuenta',
        'Números de tarjeta y cuentas bancarias',
        'Fotos y documentos personales',
        'Datos de menores en tus cuentas',
      ],
      [
        'Por qué tu correo es la llave de todo',
        'Protege tu bandeja de entrada',
        'Correo de recuperación alternativo',
        'Filtros antispam y reglas',
        'Dos pasos en tu correo',
      ],
      [
        'Verificación por SMS',
        'Riesgos del SIM swapping',
        'Verificación por llamada',
        'Cambiar número en todas tus cuentas',
        'Alternativas al SMS como 2FA',
      ],
      [
        'Cómo elegir preguntas difíciles de adivinar',
        'Preguntas comunes y sus riesgos',
        'Respuestas que no están en redes',
        'Múltiples preguntas de seguridad',
        'Alternativas a las preguntas de seguridad',
      ],
      [
        'Privacidad mínima recomendada',
        'Revisión periódica',
        'Configurar privacidad en redes sociales',
        'Privacidad en motores de búsqueda',
        'Verificación de configuración de privacidad',
      ],
      [
        'Alertas de inicio de sesión',
        'Activar notificaciones',
        'Notificaciones de cambios de configuración',
        'Alertas de dispositivos nuevos',
        'Personalizar preferencias de notificaciones',
      ],
      [
        'Revisar dispositivos conectados',
        'Eliminar los que no usas',
        'Identificar dispositivos autorizados',
        'Sesiones activas en dispositivos antiguos',
        'Cómo vincular un dispositivo nuevo',
      ],
      [
        'Guardar información de respaldo',
        'Métodos de recuperación',
        'Respaldar contactos y fotos',
        'Copias de seguridad automáticas',
        'Verificar que tu respaldo funciona',
      ],
      [
        'Cerrar sesión en dispositivos compartidos',
        'Navegación privada',
        'Cerrar sesión de forma remota',
        'Uso de modo incógnito',
        'Historial y caché después de cerrar sesión',
      ],
      [
        'Por qué son importantes',
        'Mantener apps actualizadas',
        'Actualizaciones automáticas vs manuales',
        'Actualizaciones del sistema operativo',
        'Verificar versiones de seguridad',
      ],
      [
        'Correos que piden tu contraseña',
        'No hagas clic sin verificar',
        'Suplantación de identidad en mensajes',
        'Phishing en redes sociales y SMS',
        'Reportar intentos de phishing',
      ],
      [
        'Cómo identificar enlaces falsos',
        'Verifica antes de hacer clic',
        'URLs acortadas y engañosas',
        'Previsualizar enlaces sin abrirlos',
        'Extensiones antiphishing',
      ],
      [
        'Permisos de extensiones',
        'Apps que acceden a tus cuentas',
        'Revisar permisos periódicamente',
        'Extensiones peligrosas comunes',
        'Limitar acceso de apps a tus datos',
      ],
      ['Repaso de fundamentos', 'Práctica final del módulo'],
    ],
    20,
  );

  addStage(
    2,
    'ac_st2',
    'Contraseñas Maestras',
    'Crea y gestiona claves invencibles',
    '#1565C0',
    [
      'Características de una buena contraseña',
      'Errores comunes al elegir contraseñas',
      'Cómo crear contraseñas memorables',
      'Contraseñas únicas por servicio',
      'Longitud vs complejidad',
      'Frases de paso (passphrases)',
      'Patrones a evitar',
      'Rotación de contraseñas',
      'Almacenamiento seguro de contraseñas',
      'Compartir contraseñas de forma segura',
      'Contraseñas de dispositivos',
      'Contraseñas de redes WiFi',
      'PINs y códigos de acceso',
      'Preguntas de seguridad avanzadas',
      'Cambiar contraseñas después de un incidente',
      'Verificar si tu contraseña fue filtrada',
      'Política de contraseñas en el trabajo',
      'Contraseñas para menores de edad',
      'El factor humano: hábitos seguros',
      'Evaluación de contraseñas',
    ],
    [
      [
        'Longitud mínima',
        'Uso de caracteres especiales',
        'Evitar datos personales',
        'Combinación de mayúsculas y minúsculas',
        'Ejemplos de contraseñas seguras',
      ],
      [
        '123456, password, qwerty',
        'Cumpleaños y nombres',
        'Secuencias y repeticiones',
        'Palabras del diccionario',
        'Información disponible en redes sociales',
      ],
      [
        'Método de la frase',
        'Combinaciones personales',
        'Ejemplos prácticos',
        'Técnica de la primera letra de cada palabra',
        'Incorporar números y símbolos de forma creativa',
      ],
      [
        'Por qué no repetir claves',
        'Cómo gestionar muchas contraseñas',
        'Consecuencias de una contraseña repetida',
        'Técnicas para crear variaciones por servicio',
        'Verificar si repites contraseñas',
      ],
      [
        'Por qué 12+ caracteres importa más que los símbolos',
        'Longitud recomendada por servicio',
        'Comparación entre longitud y caracteres especiales',
        'Ejemplos de contraseñas largas y simples',
        'Cómo la longitud derrota a los ataques de fuerza bruta',
      ],
      [
        'Crear frases largas y fáciles de recordar',
        'Ejemplos de passphrases',
        'Ventajas de las frases frente a palabras sueltas',
        'Combinar frases con números y símbolos',
        'Passphrases para cuentas críticas',
      ],
      [
        'Patrones de teclado',
        'Sustituciones predecibles',
        'Patrones basados en fechas',
        'Secuencias alfanuméricas comunes',
        'Sustituciones comunes @ por a, 3 por e',
      ],
      [
        'Cada cuánto cambiarlas',
        'Cuándo NO es necesario cambiar',
        'Rotación recomendada por tipo de cuenta',
        'Señales de que debes cambiar ya',
        'Automatizar el recordatorio de cambio',
      ],
      [
        'Nunca en notas del celular',
        'Gestores de contraseñas',
        'Riesgos de guardar en el navegador sin protección',
        'Cifrado de extremo a extremo',
        'Backup cifrado de contraseñas',
      ],
      [
        'Compartir con familiares',
        'Uso de funciones de emergencia',
        'Métodos inseguros de compartir',
        'Compartir mediante gestor de contraseñas',
        'Cuándo compartir y cuándo no',
      ],
      [
        'PIN del celular',
        'Patrones de desbloqueo',
        'Contraseña de computadora',
        'Configurar bloqueo automático',
        'Diferencia entre PIN y contraseña',
      ],
      [
        'Claves WiFi seguras',
        'Cambiar la clave por defecto del router',
        'Estándares de cifrado WiFi (WPA2, WPA3)',
        'Crear una red de invitados',
        'Contraseña del panel de administración del router',
      ],
      [
        'PIN de tarjetas',
        'Códigos de apps bancarias',
        'PINs numéricos seguros',
        'PIN vs contraseña: cuándo usar cada uno',
        'Proteger códigos de apps financieras',
      ],
      [
        'Respuestas que no están en redes sociales',
        'Crear respuestas falsas seguras',
        'Preguntas de seguridad en distintos servicios',
        'Documentar respuestas de forma segura',
        'Evaluar la seguridad de tus preguntas actuales',
      ],
      [
        'Pasos tras una filtración',
        'Priorizar cuentas críticas',
        'Detectar si tu cuenta estuvo en una filtración',
        'Cambiar contraseñas en cadena',
        'Verificar que el cambio fue exitoso',
      ],
      [
        'How secure is my password',
        'Have I Been Pwned',
        'Firefox Monitor',
        'Google Password Checkup',
        'Qué hacer si tu contraseña está filtrada',
      ],
      [
        'Políticas empresariales',
        '2FA obligatorio en el trabajo',
        'Gestor de contraseñas corporativo',
        'Contraseñas compartidas en equipo',
        'Cumplimiento de normativas',
      ],
      [
        'Cómo enseñar a los niños',
        'Controles parentales',
        'Contraseñas adaptadas por edad',
        'Supervisión sin invadir privacidad',
        'Crear hábitos desde pequeños',
      ],
      [
        'No escribir en papelitos',
        'No guardar en el navegador sin protección',
        'Revisión periódica de tus contraseñas',
        'Automatizar buenos hábitos',
        'Educar a tu círculo cercano',
      ],
      ['Repaso y práctica de contraseñas', 'Ejercicio final del módulo'],
    ],
    25,
  );

  addStage(
    3,
    'ac_st3',
    '2FA y Autenticación',
    'Añade una segunda capa de protección',
    '#00BCD4',
    [
      '¿Qué es la autenticación en dos pasos?',
      'Tipos de segundo factor',
      '2FA por SMS',
      '2FA por apps de autenticación',
      'Claves de seguridad físicas',
      'Códigos de respaldo',
      'Biometría: huella y rostro',
      'Notificaciones push de autenticación',
      '2FA en redes sociales',
      '2FA en correo electrónico',
      '2FA en banca y finanzas',
      '2FA en cuentas de trabajo',
      'Desactivar 2FA de forma segura',
      'Recuperar acceso sin segundo factor',
      'Autenticación sin contraseña (passkeys)',
      'Passkeys en Apple, Google y Microsoft',
      'Tokens y llaves de seguridad',
      '2FA para familiares',
      'Mantener tus métodos 2FA actualizados',
      'Evaluación de autenticación',
    ],
    [
      [
        'Qué problemas resuelve',
        'Por qué contraseña + algo más es mejor',
        'Cómo funciona el segundo factor',
        'Ejemplos cotidianos de 2FA',
        'Ventajas frente a solo contraseña',
      ],
      [
        'Algo que sabes, tienes, eres',
        'Cada método tiene sus ventajas',
        'Factores de conocimiento vs posesión vs herencia',
        'Comparativa de seguridad de cada tipo',
        'Elegir el segundo factor adecuado',
      ],
      [
        'Cómo funciona',
        'Riesgos de SIM swapping',
        'Cuándo usarlo y cuándo no',
        'Alternativas más seguras al SMS',
        'Configurar 2FA por SMS correctamente',
      ],
      [
        'Google Authenticator',
        'Microsoft Authenticator',
        'Authy',
        'Duo Mobile y otras alternativas',
        'Sincronizar códigos entre dispositivos',
      ],
      [
        'YubiKey, Titan Key',
        'Cómo configurarlas',
        'Cuándo usarlas',
        'Ventajas frente a métodos digitales',
        'Compatibilidad con servicios y dispositivos',
      ],
      [
        'Guardar códigos de recuperación',
        'Dónde almacenarlos',
        'Generar nuevos códigos de respaldo',
        'Usar un código de respaldo correctamente',
        'Cifrar y proteger tus códigos de respaldo',
      ],
      [
        'Huella dactilar en apps bancarias',
        'Face ID para cuentas',
        'Límites de la biometría',
        'Configurar biometría en dispositivos',
        'Biometría como segundo factor en apps',
      ],
      [
        'Aprobación desde el celular',
        'Ejemplos: Google, Microsoft',
        'Ventajas de las notificaciones push',
        'Configurar aprobación push',
        'Identificar notificaciones falsas',
      ],
      [
        'Facebook, Instagram, Twitter (X)',
        'LinkedIn, TikTok',
        '2FA en WhatsApp y Telegram',
        'Configuración paso a paso en cada red',
        'Verificar que el 2FA está activo',
      ],
      [
        'Gmail, Outlook, ProtonMail',
        'Activación paso a paso',
        '2FA en Yahoo Mail y otros',
        'Correo como destino de códigos 2FA',
        'Recuperación de correo con 2FA',
      ],
      [
        'Apps de bancos',
        'Billeteras digitales',
        'Cripto exchanges',
        'Token físico vs app bancaria',
        '2FA en Yape, Plin y billeteras móviles',
      ],
      [
        'Cuentas corporativas',
        'Acceso VPN con 2FA',
        'Políticas 2FA empresariales',
        'Dispositivos corporativos y 2FA',
        'Solución de problemas con 2FA laboral',
      ],
      [
        'Pasos para desactivar temporalmente',
        'Recuperar acceso si pierdes el segundo factor',
        'Cuándo desactivar 2FA',
        'Reactivar 2FA después de desactivarlo',
        'Alternativas mientras solucionas problemas',
      ],
      [
        'Usar códigos de respaldo',
        'Contactar soporte',
        'Recuperación de cuenta',
        'Proceso de verificación manual',
        'Esperar período de recuperación',
      ],
      [
        'Qué son los passkeys',
        'Cómo funcionan sin contraseña',
        'Ventajas de los passkeys sobre contraseñas',
        'Passkeys vs 2FA tradicional',
        'Dispositivos compatibles con passkeys',
      ],
      [
        'Passkeys en iCloud Keychain',
        'Passkeys en Google Password Manager',
        'Passkeys en Windows Hello',
        'Sincronizar passkeys entre dispositivos',
        'Passkeys en servicios web compatibles',
      ],
      [
        'Tokens OTP',
        'Llaves USB de seguridad',
        'Tokens físicos vs apps',
        'Estándar FIDO2 y WebAuthn',
        'Configurar llave de seguridad en cuentas',
      ],
      [
        'Configurar 2FA a padres',
        'Proteger cuentas familiares',
        'Explicar 2FA a personas no técnicas',
        'Ayudar con la configuración remota',
        'Mantener el 2FA familiar actualizado',
      ],
      [
        'Revisar métodos activos',
        'Actualizar apps de autenticación',
        'Revisar dispositivos 2FA vinculados',
        'Agregar nuevo método antes de eliminar el antiguo',
        'Calendario de revisión de 2FA',
      ],
      ['Repaso de 2FA', 'Práctica final del módulo'],
    ],
    26,
  );

  addStage(
    4,
    'ac_st4',
    'Gestores de Contraseñas',
    'Solo necesitas recordar una clave',
    '#7C4DFF',
    [
      '¿Qué es un gestor de contraseñas?',
      'Cómo funciona un gestor',
      'Ventajas de usar un gestor',
      'Gestores populares: comparativa',
      'Instalación y configuración inicial',
      'La contraseña maestra',
      'Guardar tu primera contraseña',
      'Autocompletado en navegador y apps',
      'Generador de contraseñas integrado',
      'Organizar por categorías y carpetas',
      'Compartir contraseñas de forma segura',
      'Notas seguras y documentos',
      'Gestor de familia o equipo',
      'Sincronización entre dispositivos',
      'Exportar e importar contraseñas',
      'Auditoría de seguridad integrada',
      'Alertas de contraseñas vulnerables',
      'Gestor vs navegador: diferencias clave',
      'Migrar a un gestor: paso a paso',
      'Evaluación de gestores',
    ],
    [
      [
        'Bóveda digital',
        'Cifrado de extremo a extremo',
        'Cómo se diferencia de guardar en el navegador',
        'Tipos de gestores: locales vs en la nube',
        'Seguridad del cifrado en gestores',
      ],
      [
        'Arquitectura de cero conocimiento',
        'Cómo se cifran tus datos',
        'Proceso de cifrado y descifrado',
        'Sincronización entre dispositivos',
        'El modelo de amenazas de un gestor',
      ],
      [
        'No recordar 100 claves',
        'Contraseñas únicas y complejas',
        'Autocompletado seguro',
        'Detección de phishing integrada',
        'Auditoría de seguridad automática',
      ],
      [
        'Bitwarden, 1Password, Dashlane, Proton Pass',
        'Cuál elegir según tus necesidades',
        'Comparativa de precios y funciones',
        'Gestores gratuitos recomendados',
        'Cómo probar un gestor antes de comprarlo',
      ],
      [
        'Crear cuenta',
        'Extensión del navegador',
        'App móvil',
        'Configurar desbloqueo biométrico',
        'Primera importación de contraseñas',
      ],
      [
        'Cómo elegir una clave maestra fuerte',
        'Qué pasa si la olvidas',
        'Requisitos de una buena clave maestra',
        'Dónde guardar la clave maestra de respaldo',
        'Cambiar la clave maestra',
      ],
      [
        'Agregar manualmente',
        'Importar desde el navegador',
        'Capturar mientras navegas',
        'Organizar entradas desde el inicio',
        'Verificar que se guardó correctamente',
      ],
      [
        'Configurar autocompletado',
        'Usar en Android y iOS',
        'Autocompletado en Windows y Mac',
        'Solución de problemas de autocompletado',
        'Seguridad del autocompletado',
      ],
      [
        'Generar claves aleatorias',
        'Personalizar longitud y caracteres',
        'Generar contraseñas fáciles de escribir',
        'Historial de contraseñas generadas',
        'Usar el generador en cualquier sitio',
      ],
      [
        'Carpetas personales, trabajo, finanzas',
        'Etiquetas y favoritos',
        'Crear estructura de carpetas lógica',
        'Usar campos personalizados',
        'Filtrar y buscar contraseñas eficientemente',
      ],
      [
        'Funciones de uso compartido',
        'Cuándo compartir y con quién',
        'Compartir con expiración',
        'Revocar acceso compartido',
        'Compartir contraseñas sin gestor en emergencias',
      ],
      [
        'Guardar códigos 2FA',
        'Documentos de identidad',
        'Tarjetas de crédito',
        'Notas seguras con información sensible',
        'Adjuntar archivos cifrados',
      ],
      [
        'Planes familiares',
        'Compartir con personas de confianza',
        'Crear una bóveda compartida',
        'Permisos y roles en equipo',
        'Gestor para pequeñas empresas',
      ],
      [
        'Sincronizar entre celular, tablet y PC',
        'Resolución de conflictos',
        'Configurar sincronización en tiempo real',
        'Sincronización offline',
        'Verificar que todos los dispositivos están actualizados',
      ],
      [
        'Exportar desde otro gestor',
        'Importar CSV',
        'Hacer backup',
        'Exportar copia de seguridad cifrada',
        'Restaurar desde una copia de seguridad',
      ],
      [
        'Analizador de contraseñas débiles',
        'Detección de reúsos',
        'Identificar contraseñas expiradas',
        'Auditar 2FA habilitado por cuenta',
        'Plan de acción tras la auditoría',
      ],
      [
        'Notificaciones de filtraciones',
        'Cambiar contraseñas comprometidas',
        'Configurar alertas automáticas',
        'Priorizar cambios por nivel de riesgo',
        'Verificar el estado de la alerta',
      ],
      [
        'Por qué un gestor es más seguro',
        'Limitaciones del autocompletado del navegador',
        'Cifrado del gestor frente al navegador',
        'Sincronización entre distintos navegadores',
        'Migración gradual del navegador al gestor',
      ],
      [
        'Plan de migración',
        'Verificar que todo funcione',
        'Exportar desde navegadores',
        'Importar en el nuevo gestor',
        'Probar el inicio de sesión en cada cuenta importante',
      ],
      ['Repaso de gestores', 'Práctica final del módulo'],
    ],
    25,
  );

  addStage(
    5,
    'ac_st5',
    'Monitoreo y Alertas',
    'Detecta actividad sospechosa a tiempo',
    '#FF6D00',
    [
      '¿Por qué monitorear tus cuentas?',
      'Alertas de inicio de sesión',
      'Notificaciones de dispositivos nuevos',
      'Historial de actividad de cuenta',
      'Detección de accesos no autorizados',
      'Monitoreo de la dark web',
      'Servicios de monitoreo de identidad',
      'Alertas de cambio de contraseña',
      'Monitoreo de transacciones financieras',
      'Alertas de retiros y transferencias',
      'Configurar alertas en redes sociales',
      'Monitoreo de cuentas de trabajo',
      'Alertas de correo electrónico',
      'Herramientas de monitoreo gratuitas',
      'Dashboard de seguridad personal',
      'Responder a una alerta',
      'Reportar actividad sospechosa',
      'Monitoreo familiar',
      'Automatizar la seguridad',
      'Evaluación de monitoreo',
    ],
    [
      [
        'Prevenir antes que lamentar',
        'Detección temprana de intrusiones',
        'Reducir el tiempo de exposición',
        'Conocer el estado de tus cuentas',
        'Crear una rutina de monitoreo',
      ],
      [
        'Configurar en Google, Facebook, Twitter',
        'Recibir notificaciones en tiempo real',
        'Alertas en dispositivos no reconocidos',
        'Personalizar sensibilidad de alertas',
        'Responder a una alerta de inicio de sesión',
      ],
      [
        'Identificar dispositivos desconocidos',
        'Eliminar acceso inmediatamente',
        'Aprobar o denegar dispositivos nuevos',
        'Notificaciones con ubicación y horario',
        'Mantener lista de dispositivos autorizados',
      ],
      [
        'Revisar inicios de sesión recientes',
        'Ubicaciones y horarios sospechosos',
        'Historial de cambios de configuración',
        'Identificar patrones de acceso normal',
        'Exportar historial para análisis',
      ],
      [
        'Señales de que alguien entró',
        'Qué hacer si detectas un acceso',
        'Cambios en ajustes que no hiciste',
        'Mensajes enviados sin tu conocimiento',
        'Pasos para recuperar el control',
      ],
      [
        'Have I Been Pwned',
        'Firefox Monitor',
        'Google Dark Web Report',
        'Monitoreo incluido en gestores de contraseñas',
        'Interpretar los resultados del monitoreo',
      ],
      [
        'LifeLock, Experian',
        'Protección de identidad en Perú',
        'Monitoreo de DNI y documentos',
        'Alertas de crédito y financieras',
        'Servicios gratuitos vs de pago',
      ],
      [
        'Recibir alerta cuando se cambia la clave',
        'Verificar si fuiste tú',
        'Configurar alertas en servicios clave',
        'Notificar cambios en correo de recuperación',
        'Confirmar cambios con segundo factor',
      ],
      [
        'Alertas del banco por app o SMS',
        'Configurar montos mínimos de alerta',
        'Monitoreo de tarjetas de crédito y débito',
        'Alertas de transacciones internacionales',
        'Revisar estados de cuenta periódicamente',
      ],
      [
        'Notificaciones de Yape, Plin',
        'Transferencias internacionales',
        'Configurar topes de transferencia',
        'Alertas de nuevos beneficiarios',
        'Confirmación de dos pasos para transferencias',
      ],
      [
        'Inicios de sesión en Instagram, TikTok',
        'Cambios de perfil sospechosos',
        'Alertas de intentos de recuperación',
        'Notificaciones de etiquetas no autorizadas',
        'Privacidad y alertas en LinkedIn',
      ],
      [
        'Monitoreo de cuentas corporativas',
        'Alertas de administrador',
        'Políticas de monitoreo empresarial',
        'Accesos remotos a la red corporativa',
        'Reportar incidentes al departamento de TI',
      ],
      [
        'Alertas de reenvío de correos',
        'Filtros y reglas sospechosas',
        'Detectar reglas de reenvío automático',
        'Actividad de recuperación de cuenta',
        'Inicios de sesión desde ubicaciones inusuales',
      ],
      [
        'Google Security Checkup',
        'Facebook Security Checkup',
        'Microsoft Security Dashboard',
        'Apple ID Security Check',
        'Crear un checklist mensual de seguridad',
      ],
      [
        'Centralizar alertas de todas tus cuentas',
        'Revisión semanal',
        'Priorizar alertas por criticidad',
        'Usar apps de gestión de seguridad',
        'Automatizar la recopilación de alertas',
      ],
      [
        'Pasos inmediatos',
        'Cambiar contraseña',
        'Cerrar sesiones activas',
        'Revisar actividad reciente completa',
        'Notificar a contactos afectados',
      ],
      [
        'Reportar a la plataforma',
        'Denunciar ante autoridades',
        'INDECOPI',
        'Reportar phishing a Google/Microsoft',
        'Documentar evidencia del incidente',
      ],
      [
        'Configurar alertas para hijos',
        'Monitoreo de cuentas de menores',
        'Educar a la familia sobre alertas',
        'Revisión familiar de seguridad mensual',
        'Herramientas de monitoreo familiar',
      ],
      [
        'IFTTT para seguridad',
        'Zapier para alertas personalizadas',
        'Automatizar comprobaciones de seguridad',
        'Recordatorios automáticos de revisión',
        'Scripts y herramientas de automatización',
      ],
      ['Repaso de monitoreo', 'Práctica final del módulo'],
    ],
    30,
  );

  addStage(
    6,
    'ac_st6',
    'Recuperación y Respaldo',
    'Prepárate para recuperar el acceso',
    '#2E7D32',
    [
      'Plan de recuperación de cuentas',
      'Correo de recuperación',
      'Teléfono de recuperación',
      'Códigos de recuperación',
      'Preguntas de seguridad',
      'Recuperar cuenta de Google',
      'Recuperar cuenta de Facebook/Instagram',
      'Recuperar cuenta de banco',
      'Recuperar cuenta de trabajo',
      'Respaldar información de cuentas',
      'Exportar datos de tus cuentas',
      'Contactar soporte técnico',
      'Verificación de identidad',
      'Recuperación sin acceso al correo',
      'Recuperación sin acceso al celular',
      'Prevenir pérdida de acceso',
      'Heredar cuentas digitales',
      'Checklist de recuperación',
      'Simular una recuperación',
      'Evaluación de recuperación',
    ],
    [
      [
        'Por qué necesitas un plan',
        'Documentar sin comprometer seguridad',
        'Elementos clave de un plan de recuperación',
        'Compartir el plan con personas de confianza',
        'Actualizar el plan periódicamente',
      ],
      [
        'Configurar correo alternativo',
        'Mantenerlo actualizado',
        'Elegir un proveedor confiable para el correo de respaldo',
        'Verificar que el correo alternativo funciona',
        'Proteger el correo de recuperación con 2FA',
      ],
      [
        'Número de respaldo',
        'Verificar que funciona',
        'Agregar número de un familiar de confianza',
        'Cambiar número en todas tus cuentas',
        'Verificar recepción de SMS periódicamente',
      ],
      [
        'Guardar códigos offline',
        'Dónde almacenarlos de forma segura',
        'Generar nuevos códigos de recuperación',
        'Organizar códigos por servicio',
        'Cifrar el archivo de códigos de recuperación',
      ],
      [
        'Elegir preguntas que solo tú sepas',
        'Respuestas que no cambien con el tiempo',
        'Evaluar la seguridad de tus respuestas actuales',
        'Respuestas falsas pero memorables',
        'Documentar respuestas de forma segura',
      ],
      [
        'Paso a paso para Gmail',
        'Restablecer acceso a YouTube y fotos',
        'Usar el proceso de recuperación de Google',
        'Recuperación sin acceso al celular',
        'Verificación de identidad en Google',
      ],
      [
        'Proceso de verificación de Meta',
        'Recuperar con amigos de confianza',
        'Contactar soporte de Meta',
        'Verificación de identidad con documentos',
        'Recuperar cuentas vinculadas',
      ],
      [
        'Proceso con el banco',
        'Oficina física vs digital',
        'Documentación necesaria para recuperación',
        'Llamar a la banca telefónica',
        'Recuperar acceso a apps bancarias',
      ],
      [
        'Contactar al departamento de TI',
        'Políticas de recuperación empresarial',
        'Conocer el proceso de recuperación de tu empresa',
        'Credenciales de emergencia corporativas',
        'Acceso a recursos críticos sin contraseña',
      ],
      [
        'Guardar información de cuentas críticas',
        'Bitácora de recuperación',
        'Qué información respaldar de cada cuenta',
        'Formato seguro para la bitácora',
        'Actualizar el respaldo periódicamente',
      ],
      [
        'Google Takeout',
        'Facebook Download',
        'Descargar datos',
        'Exportar datos de Apple y Microsoft',
        'Organizar y almacenar datos exportados',
      ],
      [
        'Cuándo contactar soporte',
        'Qué información tener lista',
        'Canales de soporte de cada servicio',
        'Cómo verificar tu identidad ante soporte',
        'Escalar el caso si no hay respuesta',
      ],
      [
        'Documentos necesarios',
        'Proceso de verificación de identidad',
        'Fotos y documentos aceptados por cada servicio',
        'Verificación por video llamada',
        'Fraudes de verificación de identidad',
      ],
      [
        'Recuperar correo sin SMS',
        'Usar códigos de respaldo',
        'Métodos alternativos por servicio',
        'Verificación por preguntas de seguridad',
        'Contactar soporte sin acceso al correo',
      ],
      [
        'Métodos alternativos de verificación',
        'Recuperación por tiempo',
        'Usar correo de recuperación como alternativa',
        'Códigos de respaldo impresos',
        'Período de espera de recuperación',
      ],
      [
        'Mantener datos actualizados',
        'Revisar opciones de recuperación',
        'Actualizar métodos de recuperación periódicamente',
        'Verificar que los métodos funcionan',
        'Agregar múltiples opciones de recuperación',
      ],
      [
        'Planificar qué pasa con tus cuentas',
        'Gestor de herencia digital',
        'Designar beneficiario de cuentas',
        'Documentar instrucciones póstumas',
        'Herramientas de herencia digital en gestores',
      ],
      [
        'Lista de verificación mensual',
        'Probar tu plan de recuperación',
        'Checklist de verificación de métodos activos',
        'Simular recuperación de cuenta crítica',
        'Documentar el resultado de la verificación',
      ],
      [
        'Ejercicio práctico de recuperación',
        'Sin riesgo real',
        'Crear un entorno de prueba seguro',
        'Simular recuperación de Google paso a paso',
        'Evaluar el tiempo y éxito de la simulación',
      ],
      ['Repaso de recuperación', 'Práctica final del módulo'],
    ],
    22,
  );

  addStage(
    7,
    'ac_st7',
    'Dispositivos y Sesiones',
    'Gestiona desde dónde accedes',
    '#6A1B9A',
    [
      'Tus dispositivos y tus cuentas',
      'Revisar dispositivos conectados',
      'Cerrar sesiones remotas',
      'Gestión de sesiones activas',
      'Dispositivos confiables vs desconocidos',
      'App passwords o contraseñas de aplicación',
      'Tokens y permisos de apps',
      'Acceso de terceros a tus cuentas',
      'Revocar acceso de apps antiguas',
      'Dispositivos perdidos o robados',
      'Bloqueo remoto de dispositivos',
      'Borrado remoto de datos',
      'Find My Device y cerraduras remotas',
      'Seguridad en dispositivos compartidos',
      'Perfiles de usuario en dispositivos',
      'Mantener dispositivos actualizados',
      'Cifrado de dispositivos',
      'Pantalla de bloqueo y biometría',
      'Redes WiFi y dispositivos IoT',
      'Evaluación de dispositivos',
    ],
    [
      [
        'Cuántos dispositivos usas',
        'Cada uno es una puerta de entrada',
        'Inventario de tus dispositivos',
        'Dispositivos principales vs secundarios',
        'Seguridad básica en cada dispositivo',
      ],
      [
        'Google, Facebook, Apple, Microsoft',
        'Identificar dispositivos activos',
        'Revisar dispositivos en redes sociales',
        'Frecuencia recomendada de revisión',
        'Eliminar dispositivos que no reconoces',
      ],
      [
        'Cerrar sesión en dispositivos viejos',
        'Terminar sesiones activas',
        'Cerrar sesión desde el panel de seguridad',
        'Forzar cierre en todos los dispositivos',
        'Verificar que las sesiones se cerraron',
      ],
      [
        'Dónde ver sesiones activas',
        'Cuándo cerrar todas las sesiones',
        'Sesiones activas en servicios de streaming',
        'Sesiones activas en apps de mensajería',
        'Programar cierres de sesión periódicos',
      ],
      [
        'Qué hace a un dispositivo confiable',
        'Cómo manejar dispositivos públicos',
        'Marcar dispositivos como confiables',
        'Riesgos de marcar muchos dispositivos',
        'Usar dispositivos públicos de forma segura',
      ],
      [
        'Generar claves para apps',
        'Cuándo usarlas en vez de tu contraseña',
        'Servicios que requieren app passwords',
        'Revocar app passwords que no usas',
        'App passwords vs OAuth',
      ],
      [
        'Permisos de OAuth',
        'Apps vinculadas a Google, Facebook, Apple',
        'Revisar apps con acceso a tu cuenta',
        'Tipos de permisos de OAuth',
        'Revocar permisos de apps sospechosas',
      ],
      [
        'Apps que pueden publicar por ti',
        'Acceso a tu cámara, contactos, ubicación',
        'Permisos de calendario y contactos',
        'Apps con acceso a tu cuenta de Google',
        'Auditar accesos de terceros trimestralmente',
      ],
      [
        'Revisión trimestral',
        'Eliminar apps que ya no usas',
        'Identificar apps con acceso antiguo',
        'Apps de servicios que ya no usas',
        'Revocar acceso de apps de juegos y pruebas',
      ],
      [
        'Pasos inmediatos',
        'Cambiar contraseñas',
        'Cerrar sesiones',
        'Reportar el robo a las autoridades',
        'Notificar a tu operador móvil',
      ],
      [
        'Android: Find My Device',
        'Apple: Find My iPhone',
        'Bloquear desde lejos',
        'Windows: Find My Device',
        'Configurar localización antes de perderlo',
      ],
      [
        'Borrar datos de forma remota',
        'Prepararse antes de perder el dispositivo',
        'Activar borrado remoto automático',
        'Qué datos se borran y cuáles no',
        'Restaurar datos después del borrado remoto',
      ],
      [
        'Configurar cerradura remota',
        'Activar localización',
        'Mostrar mensaje en pantalla bloqueada',
        'Reproducir sonido en dispositivo perdido',
        'Verificar ubicación desde otro dispositivo',
      ],
      [
        'Computadoras compartidas',
        'Navegación privada y perfiles',
        'Perfiles de usuario separados en PC',
        'Cuentas de invitado en dispositivos',
        'Borrar datos al terminar de usar',
      ],
      [
        'Cuentas de usuario separadas',
        'Control parental',
        'Crear perfil infantil en dispositivos',
        'Restricciones de apps y navegación',
        'Perfiles de trabajo en dispositivos personales',
      ],
      [
        'Actualizaciones de seguridad',
        'Sistema operativo y apps',
        'Configurar actualizaciones automáticas',
        'Verificar versión de seguridad actual',
        'Actualizar el firmware del router',
      ],
      [
        'Cifrado del disco',
        'Cifrado del celular',
        'Verificar que el cifrado está activado',
        'Cifrado de unidades externas y USB',
        'Rendimiento vs seguridad del cifrado',
      ],
      [
        'Configurar bloqueo automático',
        'Huella y Face ID',
        'Tipos de bloqueo: PIN, patrón, contraseña',
        'Tiempo de bloqueo automático recomendado',
        'Agregar múltiples huellas o rostros',
      ],
      [
        'Seguridad en redes WiFi',
        'Dispositivos inteligentes en casa',
        'Configurar red WiFi separada para invitados',
        'Seguridad en cámaras y sensores IoT',
        'Actualizar firmware de dispositivos IoT',
      ],
      ['Repaso de dispositivos', 'Práctica final del módulo'],
    ],
    27,
  );

  addStage(
    8,
    'ac_st8',
    'Evaluación Final',
    'Demuestra todo lo aprendido',
    '#FFD600',
    [
      'Repaso de fundamentos y contraseñas',
      'Repaso de 2FA y gestores',
      'Repaso de monitoreo y alertas',
      'Repaso de recuperación y dispositivos',
      'Caso práctico 1: Cuenta comprometida',
      'Caso práctico 2: Migración a gestor',
      'Caso práctico 3: Configuración completa',
      'Caso práctico 4: Plan familiar',
      'Simulación de ataque',
      'Auditoría de seguridad personal',
      'Plan de mejora continua',
      'Certificación del curso',
      'Próximos pasos',
      'Comunidad y recursos',
      'Reto final de velocidad',
      'Preguntas avanzadas',
      'Escenarios reales',
      'Evaluación escrita',
      'Graduación',
    ],
    [
      [
        'Conceptos clave',
        'Lo que más debes recordar',
        'Errores comunes de fundamentos',
        'Ejercicio práctico de contraseñas',
        'Autoevaluación rápida',
      ],
      [
        'Métodos de autenticación',
        'Gestores y buenas prácticas',
        'Comparativa de métodos 2FA',
        'Migración a gestor: checklist',
        'Ejercicio de configuración de 2FA',
      ],
      [
        'Alertas y monitoreo',
        'Responder a incidentes',
        'Configurar alertas clave',
        'Simulación de respuesta a incidente',
        'Dashboard personal de seguridad',
      ],
      [
        'Recuperación de acceso',
        'Gestión de dispositivos',
        'Plan de recuperación exprés',
        'Ejercicio de sesiones remotas',
        'Autoevaluación de dispositivos',
      ],
      [
        'Detectar y responder a una intrusión',
        'Pasos para recuperar la cuenta',
        'Identificar señales de compromiso',
        'Contener el daño inmediatamente',
        'Prevenir futuros compromisos',
      ],
      [
        'Configurar Bitwarden/1Password',
        'Importar y organizar todo',
        'Elegir el gestor adecuado para ti',
        'Migrar contraseñas desde el navegador',
        'Verificar y probar la migración',
      ],
      [
        '2FA en todas tus cuentas',
        'Monitoreo y alertas activadas',
        'Auditoría inicial de seguridad',
        'Configurar gestor de contraseñas',
        'Crear plan de recuperación',
      ],
      [
        'Proteger cuentas de toda tu familia',
        'Configurar gestor compartido',
        'Evaluar necesidades de cada miembro',
        'Configurar controles parentales',
        'Educar a la familia en seguridad digital',
      ],
      [
        'Identificar phishing avanzado',
        'Responder correctamente',
        'Analizar un correo sospechoso paso a paso',
        'Simular ataque de ingeniería social',
        'Evaluar tu respuesta al ataque',
      ],
      [
        'Evaluar tu nivel actual',
        'Identificar áreas de mejora',
        'Checklist de auditoría de seguridad completa',
        'Analizar resultados y priorizar acciones',
        'Crear línea base de seguridad',
      ],
      [
        'Metas de seguridad a 30, 60, 90 días',
        'Mantener hábitos seguros',
        'Definir metas SMART de seguridad',
        'Establecer recordatorios y rutinas',
        'Recursos para aprendizaje continuo',
      ],
      [
        'Completar el curso',
        'Obtener tu certificado digital',
        'Requisitos para obtener la certificación',
        'Preparación para el examen final',
        'Celebrar tu logro y compartirlo',
      ],
      [
        'Preparación para el curso de estafas',
        'Conceptos que vienen',
        'Estafas digitales más comunes hoy',
        'Cómo aplicar lo aprendido a estafas',
        'Recursos previos sobre estafas',
      ],
      [
        'Grupos de ayuda',
        'Canales de seguridad digital',
        'Foros y comunidades de seguridad en línea',
        'Canales de YouTube y podcasts recomendados',
        'Libros y guías de seguridad digital',
      ],
      [
        'Responder preguntas contra reloj',
        'Poner a prueba tus reflejos',
        'Preguntas rápidas de fundamentos',
        'Preguntas rápidas de 2FA y contraseñas',
        'Desafío de identificación de riesgos',
      ],
      [
        'Preguntas que combinan múltiples temas',
        'Razonamiento complejo',
        'Escenarios de seguridad con múltiples factores',
        'Análisis de casos complejos de recuperación',
        'Preguntas de razonamiento crítico',
      ],
      [
        'Casos basados en situaciones reales',
        'Aplicar todo lo aprendido',
        'Caso real de phishing evadiendo 2FA',
        'Caso real de robo de identidad digital',
        'Lecciones aprendidas de incidentes reales',
      ],
      [
        'Evaluación teórica final',
        'Demostrar comprensión completa',
        'Preguntas de desarrollo de conceptos clave',
        'Preguntas de aplicación práctica',
        'Autoevaluación y reflexión',
      ],
      ['Celebración y cierre del curso', 'Siguientes pasos en tu aprendizaje'],
    ],
    25,
  );

  return stages;
}

int _iconCode(String name) {
  // Material Icons codepoints
  const icons = <String, int>{
    'shield': 0xe3da, // Icons.shield_rounded
  };
  return icons[name] ?? 0xe3da;
}
