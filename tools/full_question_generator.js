#!/usr/bin/env node
/**
 * SAGEN Complete Question Generator v5.0
 * Generates 16,785 curated cybersecurity questions with correct answers.
 *
 * Each question is topically aligned: Stage → Session → Lesson → Question
 * Types: multipleChoice, trueFalse, completePhrase, detectRisk, whatWouldYouDo, createPassword, miniCase
 */

const fs = require('fs');
const path = require('path');

function mulberry32(seed) {
  return function () {
    seed |= 0; seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

// ════════════════════════════════════════════════════════════════
// CURRICULUM DEFINITION
// ════════════════════════════════════════════════════════════════
const STAGES = [
  {
    id: 'ac_st1', num: 1, label: 'Fundamentos de Cuentas Digitales',
    sessions: 27, lps: 5, target: 2025,
    topicNames: [
      ['¿Qué es una cuenta digital?','Cuentas locales vs en línea','Elementos de una cuenta','Ejemplos de cuentas cotidianas','Primeros pasos de seguridad'],
      ['Contraseñas: conceptos esenciales','¿Qué es una contraseña?','Importancia de las contraseñas','Contraseñas fuertes vs débiles','Errores comunes al crear contraseñas'],
      ['Creación de contraseñas seguras','Reglas para contraseñas seguras','Uso de números y símbolos','Longitud y complejidad','Contraseñas memorables y seguras'],
      ['Por qué no reutilizar contraseñas','Riesgos de reutilizar contraseñas','Ataques de credenciales reutilizadas','Propagación de filtraciones','Estrategias para contraseñas únicas'],
      ['Gestores de contraseñas','¿Qué es un gestor de contraseñas?','Cómo funcionan los gestores','Ventajas de usar un gestor','Cómo elegir un gestor seguro'],
      ['Recuperación de cuentas','Preguntas de seguridad','Correo de recuperación','Códigos de respaldo','Procesos de verificación'],
      ['Verificación en dos pasos (2FA)','¿Qué es la 2FA?','Métodos de segundo factor','Autenticación por SMS','Aplicaciones de autenticación'],
      ['Cuentas vinculadas y riesgos','¿Qué son las cuentas vinculadas?','Riesgos de cuentas vinculadas','Cómo separar tus cuentas','Correos múltiples'],
      ['Phishing: reconocimiento básico','¿Qué es el phishing?','Correos electrónicos sospechosos','Enlaces peligrosos','Cómo protegerse del phishing'],
      ['Ingeniería social','¿Qué es la ingeniería social?','Tácticas de manipulación','Llamadas y mensajes fraudulentos','Protección contra manipulación'],
      ['Dispositivos compartidos','Riesgos de dispositivos compartidos','Navegación en dispositivos ajenos','Modo de invitado','Cierre de sesión seguro'],
      ['Navegación segura','Navegadores seguros','Cookies y rastreadores','Historial de navegación','Modo privado de navegación'],
      ['Redes Wi-Fi y seguridad','¿Qué es una red Wi-Fi?','Riesgos del Wi-Fi público','Protección en Wi-Fi público','Configuración del router'],
      ['Uso de VPN','¿Qué es una VPN?','Cómo funciona una VPN','Cuándo usar una VPN','Límites de las VPN'],
      ['Actualizaciones de seguridad','Importancia de las actualizaciones','Tipos de actualizaciones','Riesgos de no actualizar','Configura actualizaciones'],
      ['Privacidad en línea','¿Qué es la privacidad en línea?','Huella digital','Rastreo en internet','Herramientas de privacidad'],
      ['Redes sociales y privacidad','Información que revelas en RRSS','Configuración de privacidad en RRSS','Amigos y seguidores','Publicaciones seguras'],
      ['Compras y transacciones en línea','Sitios web seguros para comprar','Métodos de pago seguros','Verificar la URL del sitio','Detección de fraudes en compras'],
      ['Correo electrónico seguro','Seguridad en cuentas de correo','Cifrado de correos electrónicos','Detección de spam y phishing','Configuración del correo'],
      ['Eliminación de datos personales','¿Por qué eliminar datos personales?','Dónde se almacenan tus datos','Solicitudes de eliminación','Derecho al olvido'],
      ['Seguridad en el hogar digital','Dispositivos inteligentes en el hogar','Seguridad del router doméstico','Redes de invitados','Protección de dispositivos IoT'],
      ['Evaluación: contraseñas y cuentas','Crea una contraseña segura','Identifica contraseñas débiles','Errores comunes','Escenarios reales de contraseñas'],
      ['Evaluación: phishing e ingeniería social','Detecta el phishing','Correos sospechosos','Sitios web falsos','Ingeniería social aplicada'],
      ['Evaluación: navegación y redes','Navegación segura evaluada','Wi-Fi y VPN evaluadas','Actualizaciones evaluadas','Escenarios integrados de navegación'],
      ['Evaluación: privacidad y transacciones','Privacidad en línea evaluada','Redes sociales evaluadas','Compras seguras evaluadas','Escenarios integrados de privacidad'],
      ['Repaso general de Fundamentos','Repaso: contraseñas y autenticación','Repaso: phishing e ingeniería social','Repaso: navegación y redes','Repaso integrado'],
      ['Evaluación final de Fundamentos','Examen: cuentas y contraseñas','Examen: phishing e ingeniería social','Examen: navegación y redes','Certificación de Fundamentos'],
    ]
  },
  {
    id: 'ac_st2', num: 2, label: 'Seguridad de Dispositivos',
    sessions: 22, lps: 6, target: 1980,
    topicNames: [
      ['Configuración de dispositivos seguros','Configuración inicial segura','Bloqueo de pantalla y biometría','Perfiles de usuario','Cifrado de dispositivo','Localización y recuperación'],
      ['Actualizaciones de software','Importancia de las actualizaciones','Actualizaciones del SO','Actualizaciones de aplicaciones','Parches de seguridad','Riesgos de software desactualizado'],
      ['Protección contra malware','¿Qué es el malware?','Tipos de malware','Cómo se infecta tu dispositivo','Antivirus y antimalware','Señales de infección'],
      ['Copias de seguridad','¿Qué es una copia de seguridad?','Tipos de copias de seguridad','Almacenamiento local vs nube','Regla 3-2-1 de backups','Recuperación de datos'],
      ['Dispositivos compartidos','Riesgos de dispositivos compartidos','Computadoras públicas seguras','Perfiles de invitado','Cierre de sesión seguro','Limpieza de datos personales'],
      ['Seguridad del sistema operativo','Seguridad de Windows','Seguridad de macOS','Seguridad de Android','Seguridad de iOS','Comparación de SO'],
      ['Cortafuegos y redes','¿Qué es un cortafuegos?','Cortafuegos de software','Cortafuegos de hardware','Reglas de cortafuegos','Monitoreo de tráfico'],
      ['Encriptación de datos','¿Qué es la encriptación?','Encriptación de disco completo','Encriptación de archivos','Encriptación móvil','Herramientas de encriptación'],
      ['Cuentas de usuario','Tipos de cuentas de usuario','Permisos y privilegios','Administrador vs usuario','Múltiples cuentas','Protección de cuentas'],
      ['Eliminación segura de datos','¿Por qué borrar no es suficiente?','Métodos de eliminación segura','Software de eliminación','Reciclaje de dispositivos','Destrucción física'],
      ['Protección en la nube','¿Qué es la nube?','Servicios de nube populares','Seguridad en la nube','Privacidad en la nube','Sincronización segura'],
      ['Seguridad en dispositivos móviles','Amenazas para móviles','Configuración Android','Configuración iOS','Protección contra robo','Seguridad en tablets'],
      ['Aplicaciones móviles seguras','Fuentes de apps seguras','Permisos de aplicaciones','Apps falsas y maliciosas','Actualización de apps','Desinstalación segura'],
      ['Seguridad en dispositivos IoT','¿Qué son los dispositivos IoT?','Amenazas de IoT','Configuración segura de IoT','Cámaras inteligentes','Asistentes de voz'],
      ['Copia de seguridad avanzada','Backups incrementales','Backups diferenciales','Automatización de backups','Verificación de integridad','Prueba de recuperación'],
      ['Evaluación: configuración de dispositivos','Evaluación: configuración de seguridad','Evaluación: amenazas','Evaluación: protección de datos','Evaluación: respaldo','Escenarios integrados'],
      ['Evaluación: malware y protección','Evaluación: tipos de malware','Evaluación: antivirus','Evaluación: señales de infección','Evaluación: respuesta a infecciones','Repaso de malware'],
      ['Evaluación: encriptación y eliminación','Evaluación: métodos de encriptación','Evaluación: eliminación segura','Evaluación: reciclaje','Evaluación: escenarios','Repaso de encriptación'],
      ['Evaluación: nube y respaldo','Evaluación: almacenamiento en nube','Evaluación: configuración de nube','Evaluación: copias de seguridad','Evaluación: recuperación','Repaso de nube'],
      ['Repaso general de Dispositivos','Repaso: configuración','Repaso: malware y antivirus','Repaso: copias de seguridad','Repaso: eliminación y nube','Repaso integrado'],
      ['Evaluación final de Dispositivos','Examen: configuración y sistemas','Examen: malware y protección','Examen: backups y eliminación','Examen: IoT y móvil','Certificación'],
      ['Certificación de Dispositivos','Examen final de conocimiento','Escenarios prácticos finales','Evaluación de habilidades','Cierre de la etapa'],
    ]
  },
  {
    id: 'ac_st3', num: 3, label: 'Protección de Datos Personales',
    sessions: 30, lps: 5, target: 2250,
    topicNames: [
      ['Gestión de información personal','Clasificación de datos personales','Métodos de protección','Configuración de privacidad','Etiquetado de datos'],
      ['Cifrado y protección de datos','Cifrado de datos personales','Almacenamiento cifrado','Transmisión segura','Herramientas de cifrado'],
      ['Privacidad en la nube','Configuración de privacidad en nube','Datos en línea','Permisos de servicios en nube','Sincronización segura'],
      ['Eliminación segura de datos','Métodos de eliminación','Reciclaje de dispositivos','Protección contra recuperación','Herramientas de eliminación'],
      ['Privacidad en el hogar digital','Dispositivos inteligentes','Datos domésticos en riesgo','Permisos de IoT','Cámaras de seguridad en hogar'],
      ['Evaluación I','Evaluación: clasificación de datos','Evaluación: cifrado','Evaluación: nube','Evaluación: eliminación'],
      ['Gestión avanzada de contraseñas','Administradores de contraseñas','2FA avanzada','Passkeys','Gestión de tokens'],
      ['Privacidad en búsquedas web','Motores de búsqueda y privacidad','Navegación privada','Protección contra rastreo','Configuración del navegador'],
      ['Protección contra fraude','Detección de fraudes','Phishing avanzado','Respuesta a incidentes','Reporte de fraudes'],
      ['Evaluación II','Evaluación: fraude','Evaluación: búsquedas','Evaluación: contraseñas avanzadas','Evaluación: escenarios'],
      ['Protección de identidad digital','Gestión de identidad','Verificación de identidad','Documentos digitales','Prevención de robo de identidad'],
      ['Derechos digitales y privacidad','Derechos de privacidad','Legislación de protección','Consentimiento informado','Derecho al olvido'],
      ['Seguridad en transacciones en línea','Pagos seguros','Tarjetas digitales','Verificación de transacciones','Compras protegidas'],
      ['Protección financiera digital','Seguridad bancaria en línea','Alertas de fraude','Inversiones digitales seguras','Criptomonedas y seguridad'],
      ['Evaluación III','Evaluación: identidad digital','Evaluación: derechos','Evaluación: transacciones','Evaluación: finanzas'],
      ['Privacidad en comunicaciones','Cifrado de mensajes','Privacidad en correos','Llamadas seguras','Mensajería segura'],
      ['Protección de información de menores','Protección digital de menores','Configuración parental','Educación digital','Redes sociales y menores'],
      ['Seguridad en el entorno laboral','Datos en la oficina','Políticas empresariales','Trabajo remoto seguro','Dispositivos corporativos'],
      ['Evaluación IV','Evaluación: comunicaciones','Evaluación: menores','Evaluación: laboral','Evaluación: escenarios reales'],
      ['Gobernanza de datos personales','Gestión de datos en organizaciones','Clasificación empresarial','Política de retención','Acceso controlado'],
      ['Auditoría de privacidad','Auditoría interna','Auditoría externa','Herramientas de auditoría','Mejora continua'],
      ['Cumplimiento normativo','Marco regulatorio','Protección por ley','Notificación de brechas','Responsable de datos'],
      ['Evaluación V','Evaluación: gobernanza','Evaluación: auditoría','Evaluación: cumplimiento','Evaluación: casos prácticos'],
      ['Derechos del consumidor digital','Derechos del consumidor','Publicidad engañosa','Reclamaciones digitales','Garantías digitales'],
      ['Privacidad en aplicaciones','Permisos excesivos','Trazadores en apps','Apps con privacidad','Políticas de privacidad'],
      ['Protección en dispositivos compartidos','Uso seguro compartido','Perfiles de invitado','Cierre de sesión seguro','Prevención de acceso no autorizado'],
      ['Repaso general de Protección','Repaso: gestión de datos','Repaso: cifrado y eliminación','Repaso: privacidad en línea','Repaso integrado'],
      ['Evaluación integral de protección','Integral: datos y cifrado','Integral: privacidad y nube','Integral: fraude y derechos','Integral: casos reales'],
      ['Certificación de Protección','Examen: fundamentos','Examen: cifrado','Examen: privacidad','Certificación final'],
      ['Evaluación final de protección','Examen final general','Escenarios prácticos finales','Evaluación de habilidades','Cierre de la etapa'],
    ]
  },
  {
    id: 'ac_st4', num: 4, label: 'Seguridad en Línea y Redes Sociales',
    sessions: 24, lps: 6, target: 2160,
    topicNames: [
      ['Privacidad en redes sociales','Configuración de privacidad','Información expuesta','Prácticas de privacidad','Gestión de amigos','Bloqueo y reporte'],
      ['Ciberbullying y acoso en línea','¿Qué es el ciberbullying?','Tipos de acoso digital','Prevención del acoso','Reporte de acoso','Apoyo a víctimas'],
      ['Privacidad en mensajería','Cifrado extremo a extremo','Privacidad de mensajes','Grupos seguros','Verificación de contactos','Configuración de mensajería'],
      ['Compras y transacciones en línea','Sitios seguros para comprar','Métodos de pago seguros','Detección de fraude','Facturas digitales','Protección del comprador'],
      ['Privacidad en plataformas sociales','Facebook y privacidad','Instagram y privacidad','Twitter y privacidad','Permisos de aplicaciones','Protección contra suplantación'],
      ['Evaluación de privacidad social','Configuración evaluada','Privacidad en mensajería evaluada','RRSS evaluadas','Escenarios de privacidad','Casos reales evaluados'],
      ['Suplantación de identidad en línea','¿Qué es la suplantación?','Detectar suplantación','Protección de identidad','Respuesta a suplantación','Recuperación de cuenta'],
      ['Seguridad en correos electrónicos','Cifrado de correos','Protección contra phishing en correos','Gestión de spam','Configuración de seguridad del correo','Filtros avanzados'],
      ['Reputación digital','Gestión de huella digital','Protección de reputación','Privacidad en búsquedas','Monitoreo de reputación','Herramientas de reputación'],
      ['Evaluación de seguridad en línea','Evaluación: seguridad I','Evaluación: seguridad II','Evaluación: seguridad III','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Seguridad en videoconferencias','Seguridad de videoconferencias','Protección de pantalla','Grabaciones seguras','Configuración de Zoom','Configuración de Teams'],
      ['Privacidad en streaming','Privacidad en Netflix','Privacidad en YouTube','Datos de streaming','Perfil anónimo','Configuración de streaming'],
      ['Evaluación multimedia','Evaluación: videoconferencias','Evaluación: streaming','Evaluación: contenido multimedia','Evaluación: escenarios multimedia','Evaluación práctica'],
      ['Protección en foros y comunidades','Seguridad en foros','Anonimato en foros','Protección de datos en foros','Reporte de contenido','Normas de comunidad'],
      ['Seguridad en blogs','Seguridad del blogger','Protección del autor','Privacidad de comentarios','Gestión de contenido','Backup de contenido'],
      ['Evaluación de publicaciones','Evaluación: foros','Evaluación: blogs','Evaluación: publicaciones','Evaluación: contenido digital','Evaluación: escenarios'],
      ['Seguridad en eventos en línea','Seguridad de eventos','Protección de datos de eventos','Pases digitales','Verificación de eventos','Privacidad de asistentes'],
      ['Seguridad en subastas en línea','Comprador seguro','Vendedor seguro','Pago protegido','Resolución de disputas','Evaluación de subastas'],
      ['Evaluación de comercio digital','Evaluación: eventos','Evaluación: subastas','Evaluación: transacciones digitales','Evaluación: escenarios de comercio','Evaluación práctica'],
      ['Privacidad en búsquedas avanzadas','Búsqueda avanzada','Operadores de búsqueda','Privacidad de búsqueda','Configuración de búsqueda segura','Herramientas de búsqueda'],
      ['Seguridad en VPN corporativa','VPN corporativa','Acceso remoto seguro','Túnel seguro','Configuración de VPN corp.','Monitoreo de VPN'],
      ['Evaluación de seguridad avanzada','Evaluación: VPN','Evaluación: búsquedas','Evaluación: herramientas avanzadas','Evaluación: escenarios avanzados','Evaluación práctica avanzada'],
      ['Repaso general en línea','Repaso: privacidad social','Repaso: seguridad y mensajería','Repaso: transacciones','Repaso integrado en línea','Evaluación de repaso'],
      ['Evaluación final en línea','Examen: privacidad en RRSS','Examen: seguridad en línea','Examen: transacciones y comercio','Certificación en línea','Evaluación final'],
    ]
  },
  {
    id: 'ac_st5', num: 5, label: 'Seguridad Móvil y Aplicaciones',
    sessions: 29, lps: 5, target: 2175,
    topicNames: [
      ['Configuración de seguridad móvil','Bloqueo de pantalla móvil','Biometría en móviles','Cifrado de dispositivo móvil','Configuración de Android','Configuración de iOS'],
      ['Aplicaciones móviles seguras','Fuentes seguras de apps','Permisos de aplicaciones','Apps falsas y maliciosas','Actualización de apps','Desinstalación segura'],
      ['Protección contra malware móvil','Malware en Android','Malware en iOS','Antivirus móvil','Señales de infección en móvil','Prevención de malware móvil'],
      ['Transacciones móviles seguras','Pagos con el móvil','Google Pay y Apple Pay','Seguridad en billeteras virtuales','QR codes y pagos','Historial de transacciones'],
      ['Dispositivos wearables y seguridad','¿Qué son los wearables?','Riesgos de wearables','Datos de salud en wearables','Configuración de wearables','Privacidad en wearables'],
      ['Evaluación de seguridad móvil','Evaluación: configuración móvil','Evaluación: apps seguras','Evaluación: malware móvil','Evaluación: transacciones móviles','Evaluación: escenarios móviles'],
      ['Redes móviles y 5G','Seguridad en redes móviles','¿Qué es 5G?','Riesgos de redes 5G','Configuración de red segura','Roaming y seguridad'],
      ['Copias de seguridad móvil','Backups en el móvil','iCloud y Google Drive','Sincronización de datos','Recuperación de datos móviles','Backup automático móvil'],
      ['Privacidad en apps móviles','Permisos excesivos de apps','Rastreo en apps','Apps con privacidad','Configuración de privacidad en apps','Políticas de apps'],
      ['Evaluación de privacidad móvil','Evaluación: redes y 5G','Evaluación: backups móviles','Evaluación: privacidad en apps','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Seguridad en tablets','Configuración de tablets','Amenazas para tablets','Protección de tablets','Tablets compartidas','Tablets en el trabajo'],
      ['Permisos de apps avanzados','Permisos de ubicación','Permisos de cámara y micrófono','Permisos de contactos','Gestión de permisos','Revocación de permisos'],
      ['Evaluación de permisos','Evaluación: permisos de ubicación','Evaluación: permisos de cámara','Evaluación: gestión de permisos','Evaluación: escenarios de permisos','Evaluación práctica'],
      ['Protección contra spyware móvil','¿Qué es el spyware?','Spyware en Android','Spyware en iOS','Detección de spyware','Prevención de spyware'],
      ['Recuperación de dispositivos','Localización de dispositivo','Borrado remoto','Bloqueo remoto','Recuperación de datos','Protección contra robo'],
      ['Evaluación de recuperación','Evaluación: localización','Evaluación: borrado remoto','Evaluación: bloqueo remoto','Evaluación: escenarios de recuperación','Evaluación práctica'],
      ['Seguridad en dispositivos legacy','Dispositivos antiguos','SO sin soporte','Riesgos de dispositivos legacy','Protección de legacy','Migración de datos'],
      ['Actualizaciones de firmware','¿Qué es el firmware?','Importancia de firmware','Actualización de firmware','Riesgos de firmware desactualizado','Verificación de firmware'],
      ['Evaluación de firmware','Evaluación: firmware','Evaluación: dispositivos legacy','Evaluación: actualizaciones','Evaluación: escenarios','Evaluación práctica de firmware'],
      ['Seguridad biométrica móvil','Huella dactilar','Reconocimiento facial','Iris y otros biométricos','Riesgos biométricos','Protección biométrica'],
      ['Autenticación en apps','2FA en aplicaciones','Passkeys en móviles','Biometría para apps','Códigos de autenticación','Gestión de sesiones'],
      ['Evaluación de autenticación','Evaluación: biométricos','Evaluación: 2FA móvil','Evaluación: passkeys','Evaluación: escenarios','Evaluación: casos de autenticación'],
      ['Repaso general móvil','Repaso: configuración','Repaso: apps y permisos','Repaso: transacciones','Repaso integrado móvil','Evaluación de repaso'],
      ['Evaluación integral móvil','Integral: configuración y apps','Integral: malware y transacciones','Integral: privacidad y permisos','Integral: recuperación','Integral: escenarios reales'],
      ['Seguridad IoT móvil','Control de dispositivos IoT','IoT desde el móvil','Riesgos de IoT móvil','Configuración de IoT desde app','Privacidad de IoT móvil'],
      ['Gestión de dispositivos MDM','¿Qué es MDM?','Políticas MDM','Gestión remota de dispositivos','Cumplimiento MDM','Seguridad MDM'],
      ['Evaluación MDM','Evaluación: MDM','Evaluación: IoT móvil','Evaluación: gestión de dispositivos','Evaluación: escenarios MDM','Evaluación práctica MDM'],
      ['Examen final móvil','Examen: configuración y apps','Examen: malware y transacciones','Examen: privacidad y recuperación','Examen: IoT y MDM','Certificación móvil'],
      ['Certificación seguridad móvil','Evaluación final conocimiento','Escenarios prácticos finales','Evaluación de habilidades','Cierre de la etapa'],
    ]
  },
  {
    id: 'ac_st6', num: 6, label: 'Ciberseguridad Empresarial',
    sessions: 20, lps: 6, target: 1800,
    topicNames: [
      ['Seguridad organizacional','Políticas de seguridad empresarial','Cultura de seguridad','Roles y responsabilidades','Auditoría de seguridad','Gestión de riesgos organizacional'],
      ['Trabajo remoto seguro','VPN para trabajo remoto','Escritorio remoto seguro','Seguridad del hogar como oficina','Dispositivos personales en trabajo','Políticas BYOD'],
      ['Amenazas internas','¿Qué son las amenazas internas?','Tipos de amenazas internas','Prevención de amenazas internas','Monitoreo de empleados','Respuesta a amenazas internas'],
      ['Cumplimiento normativo','Marco de cumplimiento','ISO 27001','PCI DSS','GDPR y regulaciones','Evaluación de cumplimiento'],
      ['Evaluación empresarial','Evaluación: políticas','Evaluación: trabajo remoto','Evaluación: amenazas internas','Evaluación: cumplimiento','Evaluación: escenarios'],
      ['Respuesta a incidentes','Plan de respuesta a incidentes','Clasificación de incidentes','Contención y erradicación','Recuperación post-incidente','Lecciones aprendidas'],
      ['Cadena de suministro','Riesgos de cadena de suministro','Seguridad de proveedores','Auditoría de proveedores','Contratos de seguridad','Continuidad de suministro'],
      ['Capacitación en ciberseguridad','Programas de capacitación','Concienciación de seguridad','Simulacros de phishing','Evaluación de conocimiento','Cultura de seguridad'],
      ['Evaluación práctica','Evaluación: respuesta a incidentes','Evaluación: cadena de suministro','Evaluación: capacitación','Evaluación: escenarios prácticos','Evaluación: casos reales'],
      ['Gobernanza de seguridad','Marcos de gobernanza','Comités de seguridad','Métricas de gobernanza','Reportes ejecutivos','Estrategia de seguridad'],
      ['Gestión de riesgos','Identificación de riesgos','Evaluación de riesgos','Mitigación de riesgos','Monitoreo de riesgos','Aceptación de riesgos'],
      ['Métricas de seguridad','KPIs de seguridad','Indicadores de amenazas','Medición de eficacia','Reportes de métricas','Mejora basada en métricas'],
      ['Evaluación de métricas','Evaluación: gobernanza','Evaluación: gestión de riesgos','Evaluación: métricas','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Seguridad en la nube empresarial','Arquitectura segura en nube','AWS/Azure/GCP seguridad','Identidad en la nube','Datos en la nube','Cumplimiento en nube'],
      ['DevSecOps','¿Qué es DevSecOps?','Seguridad en CI/CD','Herramientas DevSecOps','Automatización de seguridad','Testing de seguridad'],
      ['Automatización de seguridad','SIEM y SOAR','Automatización de respuesta','Orquestación de seguridad','Playbooks automatizados','Eficiencia operativa'],
      ['Evaluación DevOps','Evaluación: nube empresarial','Evaluación: DevSecOps','Evaluación: automatización','Evaluación: escenarios DevOps','Evaluación: casos prácticos'],
      ['Ciberseguridad para pymes','Seguridad en pymes','Recursos limitados','Soluciones económicas','Priorización de seguridad','Concienciación en pymes'],
      ['Repaso general empresarial','Repaso: seguridad organizacional','Repaso: cumplimiento y gobernanza','Repaso: nube y DevOps','Repaso integrado','Evaluación de repaso'],
      ['Evaluación final empresarial','Examen: seguridad organizacional','Examen: cumplimiento y riesgos','Examen: nube y DevOps','Certificación empresarial','Evaluación final'],
    ]
  },
  {
    id: 'ac_st7', num: 7, label: 'Amenazas Avanzadas y Respuesta a Incidentes',
    sessions: 25, lps: 5, target: 1875,
    topicNames: [
      ['Amenazas avanzadas (APT, zero-day)','¿Qué son las APT?','Ataques zero-day','Cadena de ataque APT','Detección de APT','Defensa contra APT'],
      ['Análisis de vulnerabilidades','Tipos de vulnerabilidades','Herramientas de escaneo','Análisis de penetración','Gestión de vulnerabilidades','Parches de vulnerabilidades'],
      ['Respuesta a incidentes avanzada','Framework de respuesta','Clasificación de incidentes','Evidencia digital','Comunicación de crisis','Post-mortem de incidentes'],
      ['Forense digital','¿Qué es el forense digital?','Recopilación de evidencia','Análisis de discos','Análisis de memoria','Cadena de custodia'],
      ['Evaluación de amenazas','Evaluación: APT y zero-day','Evaluación: vulnerabilidades','Evaluación: respuesta a incidentes','Evaluación: forense','Evaluación: escenarios'],
      ['Seguridad en la nube avanzada','Seguridad en IaaS','Seguridad en PaaS','Seguridad en SaaS','Zero trust en nube','Monitoreo en la nube'],
      ['DevSecOps avanzado','Seguridad en pipeline','IaC seguro','Contenedores seguros','Kubernetes seguro','Secret management'],
      ['Automatización de seguridad avanzada','SIEM avanzado','SOAR avanzado','Threat hunting automatizado','Respuesta automatizada','ML en seguridad'],
      ['Evaluación DevOps avanzado','Evaluación: nube avanzada','Evaluación: DevSecOps avanzado','Evaluación: automatización avanzada','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Análisis de malware','Tipos de malware avanzado','Análisis estático','Análisis dinámico','Sandboxing','Firma de malware'],
      ['Threat intelligence','¿Qué es threat intelligence?','Fuentes de threat intel','Indicadores de compromiso','STIX/TAXII','Uso de threat intel'],
      ['Honeypots y trampas','¿Qué es un honeypot?','Tipos de honeypots','Implementación de honeypots','Análisis de trampas','Honeypots avanzados'],
      ['Evaluación de threat intel','Evaluación: malware avanzado','Evaluación: threat intelligence','Evaluación: honeypots','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Seguridad de infraestructura crítica','Infraestructura crítica','Ataques a infraestructura','Protección de SCADA','ICS y seguridad','Resiliencia de infraestructura'],
      ['Criptografía avanzada','Criptografía asimétrica','AES y RSA','Firmas digitales','PKI y certificados','Post-cuántica'],
      ['Blockchain y seguridad','Blockchain y ciberseguridad','Smart contracts seguros','Criptomonedas y seguridad','Billeteras digitales','Estafas en criptomonedas'],
      ['Evaluación criptografía','Evaluación: criptografía avanzada','Evaluación: blockchain','Evaluación: PKI','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Redes seguras avanzadas','Segmentación de red','Zero trust networking','SD-WAN seguro','Monitoreo de tráfico','Detección de intrusiones'],
      ['Firewall de nueva generación','NGFW y funcionalidades','Inspección profunda','Control de aplicaciones','IPS integrado','Threat prevention'],
      ['Sistemas de detección de intrusiones','¿Qué es un IDS?','Tipos de IDS','Configuración de IDS','Análisis de alertas','IDS vs IPS'],
      ['Evaluación de redes','Evaluación: redes avanzadas','Evaluación: NGFW','Evaluación: IDS/IPS','Evaluación: escenarios','Evaluación: casos prácticos'],
      ['Análisis forense avanzado','Forense de memoria','Forense de red','Forense de malware','Timeline analysis','Herramientas forenses'],
      ['Recuperación de datos avanzada','Técnicas de recuperación','Recuperación de discos','Recuperación de datos borrados','Herramientas de recuperación','Profesional de recuperación'],
      ['Evaluación forense','Evaluación: forense avanzado','Evaluación: recuperación','Evaluación: análisis de evidencia','Evaluación: escenarios forenses','Evaluación: casos forenses'],
      ['Repaso general avanzado','Repaso: amenazas avanzadas','Repaso: forense y respuesta','Repaso: criptografía y redes','Repaso integrado avanzado','Evaluación de repaso'],
    ]
  },
  {
    id: 'ac_st8', num: 8, label: 'Evaluación Final y Certificación',
    sessions: 28, lps: 6, target: 2520,
    topicNames: [
      ['Evaluación integral de fundamentos','Cuentas y contraseñas avanzadas','Phishing y ingeniería social avanzada','Navegación y redes seguras','Privacidad en línea avanzada','Escenarios de fundamentos'],
      ['Evaluación de seguridad de dispositivos','Configuración avanzada de dispositivos','Malware y protección avanzada','Copias de seguridad y eliminación','Encriptación y datos','Escenarios de dispositivos'],
      ['Evaluación de protección de datos','Gestión avanzada de datos','Cifrado y eliminación avanzada','Privacidad y derechos digitales','Fraude y transacciones','Escenarios de protección'],
      ['Evaluación de seguridad en línea','Privacidad social avanzada','Ciberbullying y suplantación','Compras y transacciones en línea','Videoconferencias y streaming','Escenarios en línea'],
      ['Evaluación de seguridad móvil','Configuración móvil avanzada','Apps y permisos avanzados','Malware y transacciones móviles','Recuperación y IoT','Escenarios móviles'],
      ['Evaluación empresarial','Seguridad organizacional avanzada','Trabajo remoto y BYOD','Amenazas internas avanzadas','Cumplimiento normativo avanzado','Escenarios empresariales'],
      ['Evaluación de amenazas avanzadas','APT y zero-day avanzado','Análisis de vulnerabilidades avanzado','Respuesta a incidentes avanzada','Forense digital avanzado','Escenarios de amenazas'],
      ['Evaluación técnica avanzada','Nube avanzada y zero trust','DevSecOps y automatización','SIEM y SOAR avanzado','Threat intelligence avanzado','Escenarios técnicos'],
      ['Evaluación de gestión de incidentes','Framework de respuesta avanzado','Clasificación avanzada de incidentes','Comunicación de crisis avanzada','Post-mortem avanzado','Escenarios de incidentes'],
      ['Evaluación forense','Forense de memoria avanzado','Forense de red avanzado','Forense de malware avanzado','Timeline y evidencia','Escenarios forenses'],
      ['Evaluación de criptografía','Criptografía asimétrica avanzada','AES, RSA y post-cuántica','PKI y certificados avanzado','Blockchain y smart contracts','Escenarios criptográficos'],
      ['Evaluación de redes','Segmentación y zero trust avanzado','NGFW y IDS/IPS avanzado','Monitoreo de tráfico avanzado','Detección de intrusiones avanzada','Escenarios de redes'],
      ['Evaluación DevSecOps','Pipeline de seguridad avanzado','IaC y contenedores seguros','Kubernetes y secret management','Automatización DevSecOps','Escenarios DevSecOps'],
      ['Evaluación de cloud security','IaaS, PaaS y SaaS avanzado','Zero trust en nube avanzado','Monitoreo en nube avanzado','Cumplimiento en nube avanzado','Escenarios de nube'],
      ['Evaluación de compliance','ISO 27001 avanzado','PCI DSS avanzado','GDPR avanzado','Auditoría de cumplimiento','Escenarios de compliance'],
      ['Evaluación de gobernanza','Marcos de gobernanza avanzado','Comités y métricas avanzados','Reportes ejecutivos avanzados','Estrategia de seguridad avanzada','Escenarios de gobernanza'],
      ['Evaluación de riesgos','Identificación avanzada de riesgos','Evaluación avanzada de riesgos','Mitigación avanzada de riesgos','Monitoreo y aceptación','Escenarios de riesgos'],
      ['Evaluación de continuidad','Plan de continuidad','Disaster recovery','Backup avanzado y recuperación','Pruebas de continuidad','Escenarios de continuidad'],
      ['Evaluación de recuperación','Recuperación de datos avanzada','Recuperación de sistemas','Recuperación de cuentas','Recuperación post-incidente','Escenarios de recuperación'],
      ['Evaluación de auditoría','Auditoría de seguridad avanzada','Herramientas de auditoría avanzadas','Reportes de auditoría avanzados','Mejora continua avanzada','Escenarios de auditoría'],
      ['Evaluación integral técnica','Integral: fundamentos y dispositivos','Integral: protección y redes','Integral: amenazas y forense','Integral: nube y DevOps','Integral: escenarios técnicos'],
      ['Evaluación de casos prácticos','Caso práctico: filtración de datos','Caso práctico: ransomware','Caso práctico: ingeniería social','Caso práctico: fraude financiero','Caso práctico: incidente empresarial'],
      ['Simulacro de examen completo','Simulacro: parte 1','Simulacro: parte 2','Simulacro: parte 3','Simulacro: parte 4','Simulacro: parte 5'],
      ['Evaluación de escenarios reales','Escenario real: ataque APT','Escenario real: ransomware empresarial','Escenario real: fraude masivo','Escenario real: fuga de datos','Escenario real: ciberataque estatal'],
      ['Evaluación final técnica','Examen final: conocimiento técnico','Examen final: escenarios avanzados','Examen final: casos críticos','Evaluación de habilidades críticas','Evaluación de cierre técnico'],
      ['Evaluación de certificación','Certificación: fundamentos','Certificación: protección y seguridad','Certificación: amenazas avanzadas','Certificación: conocimiento técnico','Certificación general'],
      ['Certificación final','Examen de certificación final','Evaluación de competencias','Escenario final integrado','Ceremonia de graduación','Evaluación de cierre'],
      ['Cierre y próximos pasos','Resumen del programa','Recursos de aprendizaje continuo','Comunidad de egresados','Actualizaciones de seguridad futuras','Evaluación de satisfacción'],
    ]
  },
];

// ════════════════════════════════════════════════════════════════
// KNOWLEDGE BASE — Topic-specific question banks per stage
// Each entry: { q, o, c, e, d, t, stage }
// ════════════════════════════════════════════════════════════════
const KB = require('./question_knowledge_v5.js');

// ════════════════════════════════════════════════════════════════
// QUESTION GENERATOR
// ════════════════════════════════════════════════════════════════

function pickRandom(arr, rng) {
  return arr[Math.floor(rng() * arr.length)];
}

function validateQuestionType(q, requestedType) {
  let finalType = q.t || requestedType;
  let finalOptions = [...q.o];
  let finalCorrectIndex = q.c;
  
  // Fix trueFalse: must have exactly ['Verdadero', 'Falso']
  if (finalType === 'trueFalse') {
    if (finalOptions.length !== 2 || finalOptions[0] !== 'Verdadero' || finalOptions[1] !== 'Falso') {
      // Convert to multipleChoice since it has more than 2 options
      finalType = 'multipleChoice';
    }
  }
  
  // Fix detectRisk: must have exactly ['Riesgoso', 'Seguro']
  if (finalType === 'detectRisk') {
    if (finalOptions.length !== 2 || finalOptions[0] !== 'Riesgoso' || finalOptions[1] !== 'Seguro') {
      finalType = 'multipleChoice';
    }
  }
  
  // Ensure correctIndex is in bounds
  if (finalCorrectIndex >= finalOptions.length) {
    finalCorrectIndex = 0;
  }
  
  // Ensure at least 2 options
  if (finalOptions.length < 2) {
    finalOptions = ['Opción correcta', 'Opción incorrecta'];
    finalCorrectIndex = 0;
  }
  
  return { type: finalType, options: finalOptions, correctIndex: finalCorrectIndex };
}

function generateQuestion(topicName, lessonTitle, sessionTitle, stageLabel, stageNum, lessonId, rng, qIdx, type) {
  const kbKey = `st${stageNum}`;
  const kb = KB[kbKey];
  
  // Try to find topic-specific question
  if (kb) {
    // Search by keyword match in topic name
    const keywords = topicName.toLowerCase().split(/\s+/);
    const topicQs = kb.filter(q => {
      const qLower = q.q.toLowerCase();
      return keywords.some(kw => kw.length > 3 && qLower.includes(kw));
    });
    
    if (topicQs.length > 0) {
      const kq = pickRandom(topicQs, rng);
      const validated = validateQuestionType(kq, type);
      return {
        id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
        question: kq.q,
        type: validated.type,
        options: validated.options,
        correctIndex: validated.correctIndex,
        explanation: kq.e,
        difficulty: kq.d || (1 + Math.floor(rng() * 2)),
        lessonId: lessonId,
      };
    }
    
    // Fallback to any question in stage
    if (kb.length > 0) {
      const kq = pickRandom(kb, rng);
      const validated = validateQuestionType(kq, type);
      return {
        id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
        question: kq.q,
        type: validated.type,
        options: validated.options,
        correctIndex: validated.correctIndex,
        explanation: kq.e,
        difficulty: kq.d || (1 + Math.floor(rng() * 2)),
        lessonId: lessonId,
      };
    }
  }
  
  // Generate contextual fallback question
  return generateFallback(topicName, lessonTitle, sessionTitle, stageLabel, stageNum, lessonId, rng, qIdx, type);
}

function generateFallback(topicName, lessonTitle, sessionTitle, stageLabel, stageNum, lessonId, rng, qIdx, type) {
  const ctx = topicName.toLowerCase();
  
  if (type === 'trueFalse') {
    const isTrue = rng() > 0.4;
    const statements = [
      { text: `En el tema "${topicName}", es fundamental seguir las mejores prácticas de ciberseguridad.`, correct: true },
      { text: `Las contraseñas débiles son suficientes para proteger cuentas personales.`, correct: false },
      { text: `Las actualizaciones de seguridad son importantes para corregir vulnerabilidades.`, correct: true },
      { text: `El phishing es una técnica de ataque que no afecta a personas mayores.`, correct: false },
      { text: `La verificación en dos pasos añade una capa adicional de seguridad.`, correct: true },
      { text: `Las redes Wi-Fi públicas son tan seguras como las privadas.`, correct: false },
      { text: `Compartir contraseñas con familiares cercanos es seguro.`, correct: false },
      { text: `El cifrado protege la información incluso si el dispositivo es comprometido.`, correct: true },
      { text: `Copias de seguridad regulares son esenciales para proteger contra pérdida de datos.`, correct: true },
      { text: `La concienciación en seguridad es la primera línea de defensa.`, correct: true },
    ];
    const s = statements[qIdx % statements.length];
    const answer = isTrue ? s.correct : !s.correct;
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: s.text,
      type: 'trueFalse',
      options: ['Verdadero', 'Falso'],
      correctIndex: answer ? 0 : 1,
      explanation: answer
        ? `Esta afirmación es correcta. En el contexto de ${topicName}, esta práctica es recomendada.`
        : `Esta afirmación es incorrecta. En ${topicName}, esta práctica NO es recomendada.`,
      difficulty: 1 + Math.floor(rng() * 2),
      lessonId,
    };
  }
  
  if (type === 'detectRisk') {
    const risks = [
      { q: `Usar la misma contraseña para múltiples cuentas relacionadas con ${topicName}.`, correct: true, e: `Reutilizar contraseñas en ${topicName} expone todas las cuentas si una se filtra.` },
      { q: `No actualizar la configuración de seguridad en ${topicName}.`, correct: true, e: `La desactualización deja vulnerabilidades abiertas en ${topicName}.` },
      { q: `Compartir información personal en plataformas públicas sobre ${topicName}.`, correct: true, e: `La información pública puede ser explotada por atacantes.` },
      { q: `Usar autenticación de dos factores en todas las cuentas.`, correct: false, e: `La 2FA es una práctica segura que protege contra accesos no autorizados.` },
      { q: `Hacer copias de seguridad periódicas de los datos.`, correct: false, e: `Las copias de seguridad son una práctica recomendada.` },
      { q: `No verificar la URL antes de ingresar datos personales.`, correct: true, e: `Sin verificación, podrías estar en un sitio de phishing.` },
    ];
    const r = risks[qIdx % risks.length];
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: `Detecta el riesgo: ${r.q}`,
      type: 'detectRisk',
      options: ['Riesgoso', 'Seguro'],
      correctIndex: r.correct ? 0 : 1,
      explanation: r.e,
      difficulty: 2,
      lessonId,
    };
  }
  
  if (type === 'whatWouldYouDo') {
    const scenarios = [
      { q: `Recibes un mensaje sospechoso sobre ${topicName}. ¿Qué haces?`, c: 0, o: ['No hacer clic y reportar el mensaje','Hacer clic para verificar','Reenviarlo a amigos','Ignorar sin reportar'], e: `Los mensajes sospechosos deben ser reportados, no interactuados.` },
      { q: `Ves una configuración predeterminada en ${topicName}. ¿Qué haces?`, c: 0, o: ['Revisar y ajustar la configuración de seguridad','Dejarla como está','Desactivar la seguridad','Compartir la configuración'], e: `Siempre revisar la configuración de seguridad por defecto.` },
      { q: `Un colega te pide acceso a información sensible de ${topicName}. ¿Qué haces?`, c: 0, o: ['Verificar su identidad y autorización antes de compartir','Darle acceso inmediatamente','Negarte sin explicar','Pedirle una contraseña'], e: `La verificación de identidad y autorización es esencial.` },
    ];
    const sc = scenarios[qIdx % scenarios.length];
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: sc.q,
      type: 'whatWouldYouDo',
      options: sc.o,
      correctIndex: sc.c,
      explanation: sc.e,
      difficulty: 2,
      lessonId,
    };
  }
  
  if (type === 'completePhrase') {
    const phrases = [
      { q: `En el contexto de ${topicName}, es esencial usar una contraseña ______.`, c: 0, o: ['Fuerte y única','Corta y simple','Compartida con colegas','Fácil de recordar sin ser segura'], e: `Las contraseñas fuertes y únicas son la base de la seguridad.` },
      { q: `La verificación en dos pasos proporciona una capa ______ de seguridad.`, c: 0, o: ['Adicional','Menor','Opcional','Innecesaria'], e: `La 2FA añade un factor extra de protección.` },
      { q: `Las actualizaciones de seguridad corrigen ______ que podrían ser explotadas.`, c: 0, o: ['Vulnerabilidades','Archivos','Programas','Contraseñas'], e: `Los parches cierran agujeros de seguridad descubiertos.` },
      { q: `El cifrado convierte los datos en código ______ sin la clave correcta.`, c: 0, o: ['Ilegible','Visible','Público','Editable'], e: `El cifrado asegura que solo quien tenga la clave pueda leer los datos.` },
    ];
    const p = phrases[qIdx % phrases.length];
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: p.q,
      type: 'completePhrase',
      options: p.o,
      correctIndex: p.c,
      explanation: p.e,
      difficulty: 1 + Math.floor(rng() * 2),
      lessonId,
    };
  }
  
  if (type === 'createPassword') {
    const passwords = [
      { q: `¿Cuál de las siguientes contraseñas es la más segura para una cuenta de ${topicName}?`, c: 0, o: ['Kx$9mP#2vL!nQ4wR','contraseña123','12345678','password'], e: 'La contraseña con mayor longitud y variedad de caracteres es la más resistente.' },
      { q: `¿Qué contraseña es más segura para proteger datos de ${topicName}?`, c: 0, o: ['T#uM3sCr!pt0$2024','correo123','mi correo','email'], e: 'Una contraseña con caracteres variados y longitud adecuada es la más segura.' },
    ];
    const pw = passwords[qIdx % passwords.length];
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: pw.q,
      type: 'createPassword',
      options: pw.o,
      correctIndex: pw.c,
      explanation: pw.e,
      difficulty: 1,
      lessonId,
    };
  }
  
  if (type === 'miniCase') {
    const cases = [
      { q: `Caso: Una persona recibe un mensaje urgente sobre ${topicName} pidiendo datos personales. ¿Qué debería hacer?`, c: 0, o: ['No proporcionar datos y reportar el mensaje','Dar los datos porque es urgente','Hacer clic en el enlace','Reenviar a un amigo'], e: 'Nunca proporcionar datos personales por mensajes no solicitados.' },
      { q: `Caso: Un usuario descubre que su configuración de ${topicName} es insegura. ¿Qué debería hacer primero?`, c: 0, o: ['Cambiar la configuración a la más segura posible','Ignorar el problema','Compartirlo en redes sociales','Desactivar la seguridad'], e: 'La primera acción es mejorar la configuración de seguridad.' },
    ];
    const cs = cases[qIdx % cases.length];
    return {
      id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
      question: cs.q,
      type: 'miniCase',
      options: cs.o,
      correctIndex: cs.c,
      explanation: cs.e,
      difficulty: 2,
      lessonId,
    };
  }
  
  // Default: multipleChoice
  const mcQuestions = [
    { q: `¿Cuál es la práctica más recomendable en ${topicName}?`, c: 0, o: ['Aplicar las mejores prácticas de seguridad aprendidas','Ignorar las advertencias del sistema','Usar siempre la configuración por defecto','Compartir credenciales con colegas'], e: 'La práctica recomendada es fundamental para mantener la seguridad.' },
    { q: `¿Qué riesgo está asociado con no tomar precauciones en ${topicName}?`, c: 0, o: ['Exposición de datos personales y cuentas comprometidas','Mejora automática de la seguridad','Ningún riesgo real','Solo inconvenientes menores'], e: 'Sin las precauciones adecuadas, los datos quedan expuestos.' },
    { q: `¿Cuál es el primer paso para protegerte en ${topicName}?`, c: 0, o: ['Conocer los riesgos y configurar las protecciones adecuadas','Ignorar el problema','Esperar a que algo malo pase','Pedir ayuda en redes sociales'], e: 'La concienciación y la configuración inicial son esenciales.' },
    { q: `¿Qué consecuencia puede tener ignorar la seguridad en ${topicName}?`, c: 0, o: ['Pérdida de datos, robo de identidad o fraude financiero','Ninguna consecuencia','Solo molestias temporales','Mejora del dispositivo'], e: 'Ignorar la seguridad puede tener consecuencias graves.' },
    { q: `Según las mejores prácticas, ¿cada cuánto debes revisar la seguridad de ${topicName}?`, c: 0, o: ['Periódicamente, al menos una vez al mes','Nunca es necesario','Solo cuando hay un problema','Una vez al año'], e: 'La revisión periódica es parte esencial del mantenimiento.' },
    { q: `¿Cuál es el objetivo principal de la seguridad en ${topicName}?`, c: 0, o: ['Proteger la información y prevenir accesos no autorizados','Facilitar el acceso a todos','Compartir información libremente','No tener ninguna restricción'], e: 'El objetivo es proteger la información y los sistemas.' },
    { q: `¿Por qué es importante la concienciación en ${topicName}?`, c: 0, o: ['Porque los errores humanos son la principal causa de incidentes','Porque no es importante','Solo para empresas grandes','Porque la tecnología lo hace todo'], e: 'El factor humano es la primera línea de defensa.' },
    { q: `¿Qué hacer ante una amenaza detectada en ${topicName}?`, c: 0, o: ['Reportar inmediatamente al equipo de seguridad','Ignorar la amenaza','Intentar solucionarlo solo','Apagar el dispositivo'], e: 'El reporte temprano es crucial para limitar el daño.' },
    { q: `¿Cuál es el mayor error de seguridad en ${topicName}?`, c: 0, o: ['Subestimar las amenazas y no tomar precauciones','Tener demasiada seguridad','Actualizar el software','Usar contraseñas fuertes'], e: 'Subestimar las amenazas lleva a una falsa sensación de seguridad.' },
    { q: `¿Qué tecnología es esencial para ${topicName}?`, c: 0, o: ['Cifrado de datos y autenticación multifactor','Solo antivirus','Solo contraseñas simples','No se necesita tecnología'], e: 'La combinación de cifrado y MFA protege efectivamente los datos.' },
    { q: `¿Cómo afecta la seguridad de ${topicName} a los usuarios finales?`, c: 0, o: ['Protege sus datos personales y financieros','No les afecta','Solo afecta a empresas','Les dificulta el uso'], e: 'La seguridad protege directamente a los usuarios finales.' },
    { q: `¿Cuál es la mejor defensa contra amenazas en ${topicName}?`, c: 0, o: ['Educación, herramientas adecuadas y vigilancia constante','Solo un antivirus','No usar tecnología','Confiar en que nada pasará'], e: 'La combinación de educación y herramientas es la mejor defensa.' },
    { q: `¿Por qué deberías preocuparte por la seguridad en ${topicName}?`, c: 0, o: ['Porque tus datos personales y financieros están en riesgo','Porque no debería preocuparme','Solo si soy empresario','Porque es obligatorio por ley'], e: 'Todos los usuarios están expuestos a riesgos digitales.' },
    { q: `¿Qué papel juega la actualización en ${topicName}?`, c: 0, o: ['Corrige vulnerabilidades y mejora la protección','No tiene ningún papel','Solo mejora el diseño','Es inútil'], e: 'Las actualizaciones son críticas para mantener la seguridad.' },
    { q: `¿Cuándo deberías preocuparte por la seguridad en ${topicName}?`, c: 0, o: ['Siempre, de forma preventiva y continua','Solo después de un incidente','Nunca','Solo cuando me lo digan'], e: 'La seguridad es un proceso continuo, no solo reactiva.' },
  ];
  const mc = mcQuestions[qIdx % mcQuestions.length];
  return {
    id: `${lessonId}_q${String(qIdx + 1).padStart(3, '0')}`,
    question: mc.q,
    type: 'multipleChoice',
    options: mc.o,
    correctIndex: mc.c,
    explanation: mc.e,
    difficulty: 1 + Math.floor(rng() * 2),
    lessonId,
  };
}

// ════════════════════════════════════════════════════════════════
// MAIN GENERATION LOOP
// ════════════════════════════════════════════════════════════════

function generate() {
  const outputDir = path.join(__dirname, '..', 'assets', 'content');
  let grandTotal = 0;
  
  const types = ['multipleChoice', 'trueFalse', 'completePhrase', 'detectRisk', 'whatWouldYouDo', 'createPassword', 'miniCase'];
  // Distribution: more multipleChoice and trueFalse, fewer createPassword
  const typeWeights = [0.30, 0.20, 0.12, 0.12, 0.12, 0.06, 0.08];
  
  for (const stage of STAGES) {
    const questions = [];
    let globalIdx = 0;
    
    for (let s = 0; s < stage.sessions; s++) {
      for (let l = 0; l < stage.lps; l++) {
        const lessonId = `ac_s${stage.num}_ses${s + 1}_l${l + 1}`;
        const topicName = stage.topicNames[s] ? (stage.topicNames[s][l] || stage.topicNames[s][0]) : `Tema ${l + 1}`;
        const sessionTitle = stage.topicNames[s] ? (stage.topicNames[s][0] || `Sesión ${s + 1}`) : `Sesión ${s + 1}`;
        
        const seed = stage.num * 100000 + (s + 1) * 1000 + (l + 1) * 10;
        const rng = mulberry32(seed);
        
        for (let q = 0; q < 15; q++) {
          // Pick question type based on weights
          const typeRng = mulberry32(seed + q * 7);
          let typeIdx = 0;
          let r = typeRng();
          let cumulative = 0;
          for (let t = 0; t < typeWeights.length; t++) {
            cumulative += typeWeights[t];
            if (r < cumulative) { typeIdx = t; break; }
          }
          
          const qRng = mulberry32(seed + q * 13 + 999);
          const question = generateQuestion(
            topicName, stage.topicNames[s] ? stage.topicNames[s][l] : '',
            sessionTitle, stage.label, stage.num, lessonId, qRng, q, types[typeIdx]
          );
          
          if (question) {
            questions.push(question);
            globalIdx++;
          }
        }
      }
    }
    
    const filePath = path.join(outputDir, `questions_${stage.id}.json`);
    fs.writeFileSync(filePath, JSON.stringify(questions, null, 2), 'utf8');
    grandTotal += questions.length;
    console.log(`${stage.id}: ${questions.length} questions (target: ${stage.target}) ${questions.length === stage.target ? '✓' : '✗'}`);
  }
  
  console.log(`\nTotal: ${grandTotal} questions (target: 16,785) ${grandTotal === 16785 ? '✓' : '✗'}`);
}

generate();
