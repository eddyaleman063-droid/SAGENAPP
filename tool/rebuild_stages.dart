// ignore_for_file: avoid_print, prefer_const_declarations

// Run: dart tool/rebuild_stages.dart
//
// Regenerates assets/content/stages.json AND assets/content/manifest.json so
// that the in-app curriculum matches the question banks EXACTLY:
//
//   st1: 27 sesiones x 5 lecciones   st2: 22 x 6   st3: 30 x 5
//   st4: 24 x 6   st5: 29 x 5   st6: 20 x 6   st7: 25 x 5   st8: 28 x 6
//
// Every lesson id in the output is derived from the banks
// (assets/content/questions_ac_stN.json), so each lesson maps to exactly
// 15 questions. Existing real titles are reused by lesson/session id; missing
// sessions and lessons are authored here (no "Práctica N" placeholders).
//
// SAFE: this tool NEVER writes to the question files. It only rewrites
// stages.json + manifest.json.

import 'dart:convert';
import 'dart:io';

const _stages = <String, Map<String, int>>{
  'ac_st1': {'sessions': 27, 'lessons': 5},
  'ac_st2': {'sessions': 22, 'lessons': 6},
  'ac_st3': {'sessions': 30, 'lessons': 5},
  'ac_st4': {'sessions': 24, 'lessons': 6},
  'ac_st5': {'sessions': 29, 'lessons': 5},
  'ac_st6': {'sessions': 20, 'lessons': 6},
  'ac_st7': {'sessions': 25, 'lessons': 5},
  'ac_st8': {'sessions': 28, 'lessons': 6},
};

final _stageMeta = <String, Map<String, dynamic>>{
  'ac_st1': {
    'title': 'Fundamentos',
    'subtitle': 'Bases para proteger tus cuentas',
    'accent': '#FF6F00',
    'icon': 58330,
  },
  'ac_st2': {
    'title': 'Contraseñas Maestras',
    'subtitle': 'Crea y gestiona claves invencibles',
    'accent': '#1565C0',
    'icon': 58330,
  },
  'ac_st3': {
    'title': '2FA y Autenticación',
    'subtitle': 'Añade una segunda capa de protección',
    'accent': '#00BCD4',
    'icon': 58330,
  },
  'ac_st4': {
    'title': 'Gestores de Contraseñas',
    'subtitle': 'Solo necesitas recordar una clave',
    'accent': '#7C4DFF',
    'icon': 58330,
  },
  'ac_st5': {
    'title': 'Monitoreo y Alertas',
    'subtitle': 'Detecta actividad sospechosa a tiempo',
    'accent': '#FF6D00',
    'icon': 58330,
  },
  'ac_st6': {
    'title': 'Recuperación y Respaldo',
    'subtitle': 'Prepárate para recuperar el acceso',
    'accent': '#2E7D32',
    'icon': 58330,
  },
  'ac_st7': {
    'title': 'Dispositivos y Sesiones',
    'subtitle': 'Gestiona desde dónde accedes',
    'accent': '#6A1B9A',
    'icon': 58330,
  },
  'ac_st8': {
    'title': 'Evaluación Final',
    'subtitle': 'Demuestra todo lo aprendido',
    'accent': '#FFD600',
    'icon': 58330,
  },
};

/// Títulos de sesión para las sesiones que hoy son genéricas ("Sesión
/// adicional N") o no existen. Key: stageId -> número de sesión -> título.
final _authoredSessionTitles = <String, Map<int, String>>{
  'ac_st1': {
    21: 'Seguridad en redes sociales',
    22: 'Compras y pagos en línea seguros',
    23: 'Seguridad en tu celular',
    24: 'Seguridad en el trabajo',
    25: 'Protección de tu información personal',
    26: 'Tu plan de seguridad personal',
    27: 'Evaluación final de fundamentos',
  },
  'ac_st2': {
    21: 'Buenas prácticas en la vida real',
    22: 'Evaluación final de contraseñas',
  },
  'ac_st3': {
    21: '2FA en streaming y entretenimiento',
    22: '2FA en compras y tiendas en línea',
    23: '2FA en dispositivos y sistemas operativos',
    24: 'Autenticación para personas mayores',
    25: 'Auditoría de tu autenticación',
    26: 'Elige tu mejor segunda capa',
    27: 'Plan de contingencia sin tu celular',
    28: '2FA en la vida cotidiana',
    29: 'Simulación de configuración completa',
    30: 'Evaluación final de autenticación',
  },
  'ac_st4': {
    21: 'El gestor con tu familia',
    22: 'Protege el acceso a tu gestor',
    23: 'Respaldo y recuperación del gestor',
    24: 'Evaluación final de gestores',
  },
  'ac_st5': {
    21: 'Alertas de ubicación',
    22: 'Monitoreo de cuentas de salud',
    23: 'Respuesta rápida a alertas',
    24: 'Monitoreo proactivo semanal',
    25: 'Dashboard familiar compartido',
    26: 'Herramientas avanzadas de monitoreo',
    27: 'Interpretar alertas complejas',
    28: 'Automatización con reglas',
    29: 'Evaluación final de monitoreo',
  },
  'ac_st7': {
    21: 'Seguridad en dispositivos de trabajo',
    22: 'Gestión de dispositivos familiares',
    23: 'Dispositivos inteligentes del hogar',
    24: 'Auditoría completa de dispositivos',
    25: 'Evaluación final de dispositivos',
  },
  'ac_st8': {
    20: 'Repaso general integrador',
    21: 'Caso práctico 5: Estafa de soporte',
    22: 'Caso práctico 6: Robo de dispositivo',
    23: 'Simulación de auditoría completa',
    24: 'Evaluación por escenarios',
    25: 'Reto final decisivo',
    26: 'Examen integral del curso',
    27: 'Defensa de tu plan personal',
    28: 'Certificación y cierre',
  },
};

/// Lecciones (en orden l1..lN) de las sesiones nuevas/completas.
/// Key: stageId -> número de sesión -> lista de títulos.
final _authoredLessons = <String, Map<int, List<String>>>{
  'ac_st1': {
    21: [
      'Privacidad en tus perfiles sociales',
      'Qué no publicar jamás',
      'Ajustes de seguridad de cada red',
      'Identificar cuentas y bots falsos',
      'Reportar y bloquear cuentas sospechosas',
    ],
    22: [
      'Reconocer tiendas en línea confiables',
      'Métodos de pago seguros',
      'Phishing de ofertas y sorteos',
      'Proteger los datos de tu tarjeta',
      'Comprobar reseñas y reputación',
    ],
    23: [
      'El celular como puerta de entrada',
      'Mantener el sistema actualizado',
      'Instalar apps solo desde fuentes oficiales',
      'Revisar permisos de apps',
      'Detectar apps falsas',
    ],
    24: [
      'Cuentas y contraseñas laborales',
      'Conexiones VPN en el trabajo',
      'No compartir credenciales',
      'Políticas internas de seguridad',
      'Acceso remoto seguro',
    ],
    25: [
      'Datos personales más sensibles',
      'DNI y documentos críticos',
      'Información de tus familiares',
      'Minimizar la exposición de datos',
      'Derechos sobre tus datos',
    ],
    26: [
      'Evaluar tu nivel de seguridad',
      'Crear tu plan paso a paso',
      'Priorizar las acciones',
      'Calendario de seguridad mensual',
      'Metas realistas de mejora',
    ],
    27: [
      'Repaso integral del módulo',
      'Práctica de detección de riesgos',
      'Caso práctico de protección',
      'Verificación de conceptos clave',
      'Cierre y certificación de fundamentos',
    ],
  },
  'ac_st2': {
    21: [
      'Reúso de claves: consecuencias reales',
      'Contraseñas en dispositivos públicos',
      'Cuándo y cómo cambiar por servicio',
      'Tu estrategia de viaje segura',
      'Responder a un chantaje de contraseña',
      'Contagiar buenos hábitos a tu entorno',
    ],
    22: [
      'Repaso de los pilares de contraseñas',
      'Práctica de creación de claves',
      'Ejercicio de rotación segura',
      'Caso práctico de filtración',
      'Simulación de gestión completa',
      'Certificación del módulo',
    ],
  },
  'ac_st3': {
    21: [
      'Cuentas de Netflix, Spotify y juegos',
      'Configurar 2FA en cada plataforma',
      'Proteger la cuenta compartida del hogar',
      'Riesgos de cuentas de juegos',
      '2FA en consolas',
    ],
    22: [
      'Seguridad en marketplaces',
      '2FA en Amazon y tiendas',
      'Proteger billeteras y pagos',
      'Alertas de carrito y envíos',
      'Compras con cuenta segura',
    ],
    23: [
      'Inicio de sesión en Windows, Mac y móviles',
      '2FA en la cuenta del sistema',
      'Proteger archivos en la nube',
      '2FA en tablets y relojes',
      'Verificar el 2FA del sistema',
    ],
    24: [
      'Explicar 2FA de forma sencilla',
      'Configurar códigos para padres y abuelos',
      'Métodos accesibles de segundo factor',
      'Acompañamiento en la configuración',
      'Revisión periódica con ellos',
    ],
    25: [
      'Inventario de tus métodos 2FA',
      'Detectar métodos débiles',
      'Eliminar métodos que no usas',
      'Unificar y simplificar tu 2FA',
      'Registro de seguridad de inicio a fin',
    ],
    26: [
      'Comparar apps frente a llaves físicas',
      'SMS como último recurso',
      'Passkeys como el futuro',
      'Combinar factores para cuentas críticas',
      'Tu estrategia personal de 2FA',
    ],
    27: [
      'Qué hacer si pierdes el teléfono',
      'Códigos de respaldo siempre a mano',
      'Recuperar cuentas sin el móvil',
      'Preparar un segundo dispositivo',
      'Probar tu plan de emergencia',
    ],
    28: [
      'Autenticación en tu rutina diaria',
      'Momentos donde más te protege',
      'Equilibrio entre comodidad y seguridad',
      'Compartir métodos con la familia',
      'Revisar que todo está activo',
    ],
    29: [
      'Configurar 2FA de cero',
      'Probar la recuperación',
      'Simular pérdida del segundo factor',
      'Evaluar la solidez del resultado',
      'Ajustes finales',
    ],
    30: [
      'Repaso integral de 2FA',
      'Práctica de tipos de segundo factor',
      'Caso práctico de configuración',
      'Verificación de conocimiento',
      'Certificación del módulo',
    ],
  },
  'ac_st4': {
    21: [
      'Bóveda familiar compartida',
      'Permisos para cada miembro',
      'Agregar a nuevos integrantes',
      'Quitar acceso de forma segura',
      'Acuerdos de uso en casa',
      'Revisión familiar del gestor',
    ],
    22: [
      'Habilitar 2FA del gestor',
      'La clave maestra y su respaldo',
      'Biometría para desbloquear',
      'Bloqueo automático y sesiones',
      'Detectar accesos extraños',
      'Auditoría de tu propio gestor',
    ],
    23: [
      'Importancia de un backup',
      'Exportar copia cifrada',
      'Recuperar el acceso perdido',
      'Restaurar desde el respaldo',
      'Probar la recuperación real',
      'Emergencia de clave maestra perdida',
    ],
    24: [
      'Repaso integral del módulo',
      'Práctica de organización',
      'Caso práctico de migración',
      'Verificación de conceptos clave',
      'Auditoría de cierre',
      'Certificación del módulo',
    ],
  },
  'ac_st5': {
    21: [
      'Notificaciones geográficas',
      'Detectar inicios de sesión lejanos',
      'Configurar alertas por región',
      'Responder a una alerta de ubicación',
      'Proteger cuentas en viajes',
    ],
    22: [
      'Aplicaciones de salud y ejercicio',
      'Configurar alertas de cambio',
      'Proteger datos médicos',
      'Alertas del seguro',
      'Revisar accesos de apps de salud',
    ],
    23: [
      'Identificar alertas reales',
      'Actuar en los primeros minutos',
      'Escalar incidentes graves',
      'Registrar lo ocurrido',
      'Evitar el pánico informado',
    ],
    24: [
      'Tu rutina de revisión semanal',
      'Revisar inicios de sesión',
      'Revisar permisos y sesiones',
      'Confirmar métodos de recuperación',
      'Documentar la revisión',
    ],
    25: [
      'Centralizar alertas del hogar',
      'Roles familiares de monitoreo',
      'Reunión mensual de seguridad',
      'Alertas para los más pequeños',
      'Evaluar el dashboard en conjunto',
    ],
    26: [
      'Servicios premium de monitoreo',
      'Monitoreo de identidad integral',
      'Alertas personalizadas',
      'Pruebas de seguridad personales',
      'Elegir tu stack de monitoreo',
    ],
    27: [
      'Alertas combinadas',
      'Falsos positivos comunes',
      'Correlacionar eventos',
      'Cuándo marcar una alerta',
      'Sistema de prioridades',
    ],
    28: [
      'Crear reglas de filtrado',
      'Respuestas automáticas de seguridad',
      'Integración entre servicios',
      'Alertas por umbral',
      'Auditar tus automatizaciones',
    ],
    29: [
      'Repaso integral del módulo',
      'Práctica de respuesta a incidentes',
      'Caso práctico de alerta crítica',
      'Verificación de conceptos',
      'Certificación del módulo',
    ],
  },
  'ac_st7': {
    21: [
      'Separar trabajo y personal',
      'Cumplir políticas del empleador',
      'Gestionar dispositivos prestados',
      'Acceso remoto a la empresa',
      'Borrar datos al devolverlos',
    ],
    22: [
      'Dispositivos de los hijos',
      'Perfiles infantiles',
      'Control parental efectivo',
      'Reglas de uso en casa',
      'Revisión familiar de dispositivos',
    ],
    23: [
      'Habilitar el 2FA en IoT',
      'Red dedicada para dispositivos',
      'Actualizar firmware',
      'Alertas de actividad en casa',
      'Limitar acceso de asistentes',
    ],
    24: [
      'Inventario total',
      'Revisar apps y permisos',
      'Cerrar sesiones de todos',
      'Actualizar todo el parque',
      'Plan de renovación',
    ],
    25: [
      'Repaso integral del módulo',
      'Práctica de cierre de sesiones',
      'Caso práctico de robo',
      'Verificación de conceptos',
      'Certificación del módulo',
    ],
  },
  'ac_st8': {
    20: [
      'Fundamentos y contraseñas',
      'Autenticación y gestores',
      'Monitoreo y alertas',
      'Recuperación y dispositivos',
      'Habilidades combinadas',
      'Autoevaluación global',
    ],
    21: [
      'Reconocer falsos soportes',
      'No compartir credenciales',
      'Verificar con la empresa',
      'Reportar la estafa',
      'Recuperar el control',
      'Prevenir futuras estafas',
    ],
    22: [
      'Actuar con rapidez',
      'Bloquear y localizar',
      'Cambiar las cuentas críticas',
      'Cerrar sesiones remotas',
      'Denunciar y documentar',
      'Evitar el próximo robo',
    ],
    23: [
      'Revisar cuentas una a una',
      'Reforzar 2FA en todo',
      'Depurar permisos de terceros',
      'Verificar métodos de recuperación',
      'Resultados y plan de acción',
      'Seguimiento de la mejora',
    ],
    24: [
      'Escenario de suplantación',
      'Escenario de fraude bancario',
      'Escenario de filtración',
      'Escenario de caída de plataforma',
      'Escenario de chantaje',
      'Calificar tus respuestas',
    ],
    25: [
      'Preguntas rápidas globales',
      'Caso complejo integrado',
      'Identificar múltiples riesgos',
      'Responder bajo presión',
      'Evaluación de desempeño',
      'Veredicto final',
    ],
    26: [
      'Los pilares de la seguridad',
      'Gestión de emergencias',
      'Práctica de decisiones',
      'Aplicación de políticas',
      'Revisión de conceptos clave',
      'Resultado del examen',
    ],
    27: [
      'Presentar tu plan',
      'Justificar tus decisiones',
      'Recibir retroalimentación',
      'Ajustar según necesidades',
      'Comprometerte con la mejora',
      'Tu manifiesto de seguridad',
    ],
    28: [
      'Resumen del curso completo',
      'Reconocimiento de logros',
      'Recomendaciones de continuación',
      'Recursos finales',
      'Celebración y cierre',
      'Tu certificado digital',
    ],
  },
};

/// Lección suelta extra (l6) para sesiones que hoy tienen 5 lecciones pero
/// cuya etapa es par (6 lecciones por sesión). Key: stageId -> sesión -> título.
final _extraLessonTitles = <String, Map<int, String>>{
  'ac_st2': {
    12: 'Fortaleza de las claves de tu red',
    13: 'PINs de llamadas y mensajería',
    14: 'Plantilla de respuestas de seguridad',
    15: 'Plan de emergencia de contraseñas',
    16: 'Evitar futuras filtraciones',
    17: 'Contraseñas en el trabajo remoto',
    18: 'Contraseñas compartidas con menores',
    19: 'Hábitos en dispositivos compartidos',
    20: 'Reto final de contraseñas',
  },
  'ac_st4': {
    13: 'Roles y permisos de administrador',
    14: 'Sincronización entre navegadores',
    15: 'Compatibilidad de archivos CSV',
    16: 'Leer el reporte de auditoría',
    17: 'Calendario de revisión de alertas',
    18: 'Cuándo conviene quedarse con el navegador',
    19: 'Comprobar la migración completa',
    20: 'Examen final de gestores',
  },
  'ac_st6': {
    12: 'Preparar tu expediente de soporte',
    13: 'Verificación alternativa sin documentos',
    14: 'Recuperar tu correo de respaldo',
    15: 'Recuperación con otro dispositivo',
    16: 'Guardar tu plan en un lugar seguro',
    17: 'Registro de transferencia de cuentas',
    18: 'Calendario de pruebas del plan',
    19: 'Simular una emergencia total',
    20: 'Examen final de recuperación',
  },
  'ac_st8': {
    13: 'Plan de estudios sobre estafas',
    14: 'Participar en comunidades seguras',
    15: 'Reflejos contra phishing',
    16: 'Razonamiento de seguridad avanzado',
    17: 'Caso de estafa digital real',
    18: 'Ensayo práctico de seguridad',
    19: 'Proyecto final del curso',
  },
};

/// Corrección ortográfica aplicada a títulos reutilizados (typos históricos
/// en el archivo actual sin perder títulos reales).
const _orthographicFixes = <String, String>{
  'Actualizaciónes': 'Actualizaciones',
  'Sesiónes': 'Sesiones',
  'lecciónes': 'lecciones',
  'Lecciónes': 'Lecciones',
  'Evaluacion': 'Evaluación',
  'carácteres': 'caracteres',
  'opciónes': 'opciones',
  'internaciónales': 'internacionales',
  'situaciónes': 'situaciones',
  'funciónes': 'funciones',
  'Razónamiento': 'Razonamiento',
  'razónamiento': 'razonamiento',
  'Navegacion': 'Navegación',
  'Rotacion': 'Rotación',
  'Sincronizacion': 'Sincronización',
  'Gestion': 'Gestión',
  'Auditoria': 'Auditoría',
  'Automatizacion': 'Automatización',
  'suplantacion': 'suplantación',
  'Simulacion': 'Simulación',
  'simulacion': 'simulación',
  'Desafio': 'Desafío',
  'desafio': 'desafío',
  'provedores': 'proveedores',
  'Revocacion': 'Revocación',
  'Certificacion': 'Certificación',
  'Características': 'Características',
  'Carácterísticas': 'Características',
  'credito': 'crédito',
  'fisico': 'físico',
  'publicas': 'públicas',
  'moviles': 'móviles',
  'ninios': 'niños',
  'biometricas': 'biométricas',
  'Introduccion': 'Introducción',
  'Restriccion': 'Restricción',
  'Combinaciónes': 'Combinaciones',
  'Funciónes': 'Funciones',
  'Autenticación': 'Autenticación',
  'sesiónes': 'sesiones',
  'Sesion ': 'Sesión ',
};

String _fix(String input) {
  var out = input;
  for (final e in _orthographicFixes.entries) {
    out = out.replaceAll(e.key, e.value);
  }
  return out;
}

void main() {
  final stages = <Map<String, dynamic>>[];
  var grandTotalQ = 0;
  var grandTotalLessons = 0;

  // Existing stages.json, used for title reuse keyed by exact id.
  final oldStagesFile = File('assets/content/stages.json');
  final existingStages = oldStagesFile.existsSync()
      ? (jsonDecode(oldStagesFile.readAsStringSync()) as List)
      : <dynamic>[];
  final oldSessionsById = <String, Map<String, dynamic>>{};
  final oldLessonsById = <String, Map<String, dynamic>>{};
  for (final stage in existingStages) {
    final s = stage as Map<String, dynamic>;
    for (final ses in s['sessions'] as List) {
      final sm = ses as Map<String, dynamic>;
      oldSessionsById[sm['id'] as String] = sm;
      for (final l in sm['lessons'] as List) {
        final lm = l as Map<String, dynamic>;
        oldLessonsById[lm['id'] as String] = lm;
      }
    }
  }

  final stageOrder = _stages.keys.toList();
  for (final stageId in stageOrder) {
    final spec = _stages[stageId]!;
    final count = spec['sessions']!;
    final lessonsPerSession = spec['lessons']!;
    final meta = _stageMeta[stageId]!;

    // Derive the exact ordered lesson set from the bank.
    final match = RegExp(r'^ac_st(\d+)$').firstMatch(stageId)!;
    final stageNum = match.group(1)!;
    final bankFile = File('assets/content/questions_ac_st$stageNum.json');
    if (!bankFile.existsSync()) {
      throw StateError('Missing bank file for $stageId');
    }
    final bank = jsonDecode(bankFile.readAsStringSync()) as List;

    final lessonsBySession = <int, Map<int, Map<String, dynamic>>>{};
    for (final q in bank) {
      final qm = q as Map<String, dynamic>;
      final qid = (qm['lessonId'] as String?) ?? '';
      final lm = RegExp(r'^ac_s\d+_ses(\d+)_l(\d+)$').firstMatch(qid);
      if (lm == null) continue;
      final sesNum = int.parse(lm.group(1)!);
      final lNum = int.parse(lm.group(2)!);
      lessonsBySession
              .putIfAbsent(sesNum, () => {})
              .putIfAbsent(lNum, () => {})['q'] =
          qm;
    }

    // The bank grid must match the stage spec exactly.
    final foundSessions = lessonsBySession.keys.toList()..sort();
    if (foundSessions.length != count) {
      throw StateError(
        '$stageId: bank has ${foundSessions.length} sessions, spec wants $count',
      );
    }
    for (var i = 1; i <= count; i++) {
      final lessonNums = (lessonsBySession[i]?.keys ?? <int>{}).toList()
        ..sort();
      if (lessonNums.length != lessonsPerSession) {
        throw StateError(
          '$stageId ses$i: bank has ${lessonNums.length} lessons, '
          'spec wants $lessonsPerSession',
        );
      }
      for (var j = 1; j <= lessonsPerSession; j++) {
        final q = lessonsBySession[i]![j]?['q'];
        if (q == null) {
          throw StateError('$stageId ses$i l$j missing from bank');
        }
      }
    }

    final sessions = <Map<String, dynamic>>[];
    for (var i = 1; i <= count; i++) {
      final sesNum = i;
      final sesId = 'ac_s${stageNum}_ses$sesNum';
      // Title: reuse an existing real one, else authored.
      final existingSes = oldSessionsById[sesId];
      final existingSesTitle = (existingSes?['title'] as String?) ?? '';
      final isGeneric =
          existingSesTitle.startsWith('Sesión adicional') ||
          existingSesTitle.startsWith('Práctica');
      final authoredSesTitle = _authoredSessionTitles[stageId]?[sesNum] ?? '';
      final sesTitle = !isGeneric && existingSesTitle.isNotEmpty
          ? _fix(existingSesTitle)
          : authoredSesTitle;

      final lessons = <Map<String, dynamic>>[];
      for (var j = 1; j <= lessonsPerSession; j++) {
        final lNum = j;
        final lessonId = 'ac_s${stageNum}_ses${sesNum}_l$lNum';
        // Reuse a real existing title if present.
        final existingLesson = oldLessonsById[lessonId];
        final existingTitle = (existingLesson?['title'] as String?) ?? '';
        final existingSub = (existingLesson?['subtitle'] as String?) ?? '';
        final existingMinutes =
            (existingLesson?['estimatedMinutes'] as int?) ?? 3;

        String title;
        String subtitle;
        int estimatedMinutes;
        final isFillerLesson = RegExp(
          r'^Práctica \d+$',
        ).hasMatch(existingTitle);
        if (existingTitle.isNotEmpty && !isFillerLesson) {
          title = _fix(existingTitle);
          subtitle = _fix(existingSub);
          estimatedMinutes = existingMinutes;
        } else {
          title = '';
          // l6 extra for even stages.
          final extra = _extraLessonTitles[stageId]?[sesNum] ?? '';
          if (lNum == lessonsPerSession && extra.isNotEmpty) {
            title = extra;
          } else {
            final authored = _authoredLessons[stageId]?[sesNum] ?? const [];
            if (lNum <= authored.length && authored[lNum - 1].isNotEmpty) {
              title = authored[lNum - 1];
            }
          }
          subtitle = 'Lección $lNum de la sesión $sesNum';
          estimatedMinutes = 3;
        }
        if (title.isEmpty) {
          throw StateError('No title for $lessonId — cannot place Práctica');
        }

        final lesson = <String, dynamic>{
          'id': lessonId,
          'title': title,
          'subtitle': subtitle,
          'challenges': <dynamic>[],
          'xpReward': 15,
          'gemReward': 5,
          'estimatedMinutes': estimatedMinutes,
          'completed': false,
          'questionCount': 15,
        };
        lessons.add(lesson);
        grandTotalLessons++;
      }

      sessions.add(<String, dynamic>{
        'id': sesId,
        'title': sesTitle,
        'subtitle': 'Sesión $sesNum · ${lessons.length} lecciones',
        'lessons': lessons,
        'completed': false,
      });
    }

    final stage = <String, dynamic>{
      'id': stageId,
      'title': meta['title'],
      'subtitle': meta['subtitle'],
      'accent': meta['accent'],
      'icon': meta['icon'],
      'sessions': sessions,
      'unlocked': false,
      'bonus': false,
    };
    stages.add(stage);

    final stageTotalQ = count * lessonsPerSession * 15;
    grandTotalQ += stageTotalQ;
    print(
      '$stageId: $count sesiones x $lessonsPerSession = '
      '${count * lessonsPerSession} lecciones ($stageTotalQ preguntas)',
    );
  }

  final stagesJson = const JsonEncoder.withIndent('  ').convert(stages);
  File('assets/content/stages.json').writeAsStringSync(stagesJson, flush: true);

  final manifest = {
    'version': '2.0.0',
    'stages': stages.map((s) => s['id']).toList(),
  };
  File('assets/content/manifest.json').writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(manifest),
    flush: true,
  );

  print('---');
  print('Total lecciones: $grandTotalLessons');
  print('Total preguntas (15/lección): $grandTotalQ');
  print('Wrote assets/content/stages.json + manifest.json');
}
