/**
 * SAGEN Question Bank Generator
 * Generates 16,785 cybersecurity education questions across 8 stages.
 * 
 * Structure per user specification:
 * - Stage 1: 27 sessions × 5 lessons × 15 questions = 2,025
 * - Stage 2: 22 sessions × 6 lessons × 15 questions = 1,980
 * - Stage 3: 30 sessions × 5 lessons × 15 questions = 2,250
 * - Stage 4: 24 sessions × 6 lessons × 15 questions = 2,160
 * - Stage 5: 29 sessions × 5 lessons × 15 questions = 2,175
 * - Stage 6: 20 sessions × 6 lessons × 15 questions = 1,800
 * - Stage 7: 25 sessions × 5 lessons × 15 questions = 1,875
 * - Stage 8: 28 sessions × 6 lessons × 15 questions = 2,520
 *   Total: 16,785 questions
 * 
 * RULES:
 * - All questions in perfect Spanish with accents
 * - Correct answers verified
 * - No circular/self-referential options
 * - Each option is a plausible distractor
 * - trueFalse = exactly ["Verdadero", "Falso"]
 */

const fs = require('fs');
const path = require('path');

// ════════════════════════════════════════════════════════════════
// CURRICULUM DEFINITION
// ════════════════════════════════════════════════════════════════

const CURRICULUM = {
  ac_st1: {
    title: "Fundamentos de Cuentas Digitales",
    sessions: [
      { id: "ac_s1_ses1", title: "¿Qué es una cuenta digital?", lessons: [
        { id: "ac_s1_ses1_l1", title: "Introducción a las cuentas digitales", topic: "que_es_cuenta_digital" },
        { id: "ac_s1_ses1_l2", title: "¿Qué hace segura a una cuenta?", topic: "seguridad_cuenta" },
        { id: "ac_s1_ses1_l3", title: "Cuentas locales vs en línea", topic: "cuentas_locales_vs_linea" },
        { id: "ac_s1_ses1_l4", title: "Ejemplos de cuentas cotidianas", topic: "ejemplos_cuentas" },
        { id: "ac_s1_ses1_l5", title: "Elementos básicos de seguridad", topic: "elementos_seguridad" },
      ]},
      { id: "ac_s1_ses2", title: "Contraseñas: conceptos esenciales", lessons: [
        { id: "ac_s1_ses2_l1", title: "¿Qué es una contraseña?", topic: "que_es_contrasena" },
        { id: "ac_s1_ses2_l2", title: "Por qué las contraseñas son importantes", topic: "importancia_contrasenas" },
        { id: "ac_s1_ses2_l3", title: "Contraseñas fuertes vs débiles", topic: "contrasenas_fuertes_debiles" },
        { id: "ac_s1_ses2_l4", title: "Errores comunes al crear contraseñas", topic: "errores_contrasenas" },
        { id: "ac_s1_ses2_l5", title: "Cómo recordar tus contraseñas", topic: "recordar_contrasenas" },
      ]},
      { id: "ac_s1_ses3", title: "Creación de contraseñas seguras", lessons: [
        { id: "ac_s1_ses3_l1", title: "Reglas para crear contraseñas seguras", topic: "reglas_contrasenas_seguras" },
        { id: "ac_s1_ses3_l2", title: "Uso de números y símbolos", topic: "numeros_y_simbolos" },
        { id: "ac_s1_ses3_l3", title: "Longitud y complejidad", topic: "longitud_complejidad" },
        { id: "ac_s1_ses3_l4", title: "Contraseñas memorables", topic: "contrasenas_memorables" },
        { id: "ac_s1_ses3_l5", title: "Evaluación de fortaleza de contraseñas", topic: "evaluacion_fortaleza" },
      ]},
      { id: "ac_s1_ses4", title: "Por qué no usar la misma contraseña", lessons: [
        { id: "ac_s1_ses4_l1", title: "Riesgos de reutilizar contraseñas", topic: "riesgos_reutilizar" },
        { id: "ac_s1_ses4_l2", title: "Ataques de credenciales reutilizadas", topic: "ataques_credenciales" },
        { id: "ac_s1_ses4_l3", title: "Cómo se propagan las filtraciones", topic: "propagacion_filtraciones" },
        { id: "ac_s1_ses4_l4", title: "Estrategias para tener contraseñas únicas", topic: "estrategias_unicas" },
        { id: "ac_s1_ses4_l5", title: "Gestores de contraseñas intro", topic: "intro_gestores" },
      ]},
      { id: "ac_s1_ses5", title: "Gestores de contraseñas", lessons: [
        { id: "ac_s1_ses5_l1", title: "¿Qué es un gestor de contraseñas?", topic: "que_es_gestor" },
        { id: "ac_s1_ses5_l2", title: "Cómo funcionan los gestores", topic: "funcionamiento_gestor" },
        { id: "ac_s1_ses5_l3", title: "Ventajas de usar un gestor", topic: "ventajas_gestor" },
        { id: "ac_s1_ses5_l4", title: "Cómo elegir un gestor seguro", topic: "elegir_gestor" },
        { id: "ac_s1_ses5_l5", title: "Práctica: configura tu gestor", topic: "practica_gestor" },
      ]},
      { id: "ac_s1_ses6", title: "Recuperación de cuentas", lessons: [
        { id: "ac_s1_ses6_l1", title: "Preguntas de seguridad", topic: "preguntas_seguridad" },
        { id: "ac_s1_ses6_l2", title: "Correo de recuperación", topic: "correo_recuperacion" },
        { id: "ac_s1_ses6_l3", title: "Códigos de respaldo", topic: "codigos_respaldo" },
        { id: "ac_s1_ses6_l4", title: "Procesos de verificación", topic: "procesos_verificacion" },
        { id: "ac_s1_ses6_l5", title: "Protección contra acceso no autorizado", topic: "proteccion_acceso" },
      ]},
      { id: "ac_s1_ses7", title: "Verificación en dos pasos (2FA)", lessons: [
        { id: "ac_s1_ses7_l1", title: "¿Qué es la verificación en dos pasos?", topic: "que_es_2fa" },
        { id: "ac_s1_ses7_l2", title: "Métodos de segundo factor", topic: "metodos_segundo_factor" },
        { id: "ac_s1_ses7_l3", title: "Autenticación por SMS", topic: "auth_sms" },
        { id: "ac_s1_ses7_l4", title: "Aplicaciones de autenticación", topic: "apps_autenticacion" },
        { id: "ac_s1_ses7_l5", title: "Passkeys y autenticación moderna", topic: "passkeys" },
      ]},
      { id: "ac_s1_ses8", title: "Cuentas vinculadas y riesgos", lessons: [
        { id: "ac_s1_ses8_l1", title: "¿Qué son las cuentas vinculadas?", topic: "cuentas_vinculadas" },
        { id: "ac_s1_ses8_l2", title: "Riesgos de cuentas vinculadas", topic: "riesgos_vinculadas" },
        { id: "ac_s1_ses8_l3", title: "Cómo separar tus cuentas", topic: "separar_cuentas" },
        { id: "ac_s1_ses8_l4", title: "Correos electrónicos múltiples", topic: "correos_multiples" },
        { id: "ac_s1_ses8_l5", title: "Gestión de cuentas personales", topic: "gestion_cuentas" },
      ]},
      { id: "ac_s1_ses9", title: "Phishing: reconocimiento básico", lessons: [
        { id: "ac_s1_ses9_l1", title: "¿Qué es el phishing?", topic: "que_es_phishing" },
        { id: "ac_s1_ses9_l2", title: "Correos electrónicos sospechosos", topic: "correos_sospechosos" },
        { id: "ac_s1_ses9_l3", title: "Enlaces peligrosos", topic: "enlaces_peligrosos" },
        { id: "ac_s1_ses9_l4", title: "Adjuntos maliciosos", topic: "adjuntos_maliciosos" },
        { id: "ac_s1_ses9_l5", title: "Cómo protegerse del phishing", topic: "proteccion_phishing" },
      ]},
      { id: "ac_s1_ses10", title: "Ingeniería social", lessons: [
        { id: "ac_s1_ses10_l1", title: "¿Qué es la ingeniería social?", topic: "que_es_ingenieria_social" },
        { id: "ac_s1_ses10_l2", title: "Tácticas de manipulación", topic: "tacticas_manipulacion" },
        { id: "ac_s1_ses10_l3", title: "Llamadas y mensajes fraudulentos", topic: "llamadas_fraudulentas" },
        { id: "ac_s1_ses10_l4", title: "Protección contra manipulación", topic: "proteccion_manipulacion" },
        { id: "ac_s1_ses10_l5", title: "Casos reales de ingeniería social", topic: "casos_reales_is" },
      ]},
      { id: "ac_s1_ses11", title: "Contraseñas en dispositivos compartidos", lessons: [
        { id: "ac_s1_ses11_l1", title: "Riesgos de dispositivos compartidos", topic: "riesgos_dispositivos" },
        { id: "ac_s1_ses11_l2", title: "Cómo navegar de forma segura", topic: "navegacion_segura" },
        { id: "ac_s1_ses11_l3", title: "Modo de invitado", topic: "modo_invitado" },
        { id: "ac_s1_ses11_l4", title: "Cierre de sesión seguro", topic: "cierre_sesion_seguro" },
        { id: "ac_s1_ses11_l5", title: "Limpiar historial y datos", topic: "limpiar_historial" },
      ]},
      { id: "ac_s1_ses12", title: "Examen práctico de contraseñas", lessons: [
        { id: "ac_s1_ses12_l1", title: "Evaluación: crea una contraseña segura", topic: "eval_crear_contrasena" },
        { id: "ac_s1_ses12_l2", title: "Evaluación: identifica contraseñas débiles", topic: "eval_identificar_debiles" },
        { id: "ac_s1_ses12_l3", title: "Evaluación: errores comunes", topic: "eval_errores" },
        { id: "ac_s1_ses12_l4", title: "Evaluación: escenarios reales", topic: "eval_escenarios" },
        { id: "ac_s1_ses12_l5", title: "Repaso de conceptos clave", topic: "repaso_conceptos" },
      ]},
      { id: "ac_s1_ses13", title: "Examen de phishing e ingeniería social", lessons: [
        { id: "ac_s1_ses13_l1", title: "Evaluación: detecta el phishing", topic: "eval_detectar_phishing" },
        { id: "ac_s1_ses13_l2", title: "Evaluación: correos sospechosos", topic: "eval_correos" },
        { id: "ac_s1_ses13_l3", title: "Evaluación: sitios web falsos", topic: "eval_sitios_falsos" },
        { id: "ac_s1_ses13_l4", title: "Evaluación: ingeniería social", topic: "eval_ingenieria_social" },
        { id: "ac_s1_ses13_l5", title: "Repaso de protección", topic: "repaso_proteccion" },
      ]},
      { id: "ac_s1_ses14", title: "Navegación segura y privacidad", lessons: [
        { id: "ac_s1_ses14_l1", title: "Navegadores seguros", topic: "navegadores_seguros" },
        { id: "ac_s1_ses14_l2", title: "Cookies y rastreadores", topic: "cookies_rastreadores" },
        { id: "ac_s1_ses14_l3", title: "Historial de navegación", topic: "historial_navegacion" },
        { id: "ac_s1_ses14_l4", title: "Modo privado de navegación", topic: "modo_privado" },
        { id: "ac_s1_ses14_l5", title: "Extensiones de seguridad", topic: "extensiones_seguridad" },
      ]},
      { id: "ac_s1_ses15", title: "Redes Wi-Fi y seguridad", lessons: [
        { id: "ac_s1_ses15_l1", title: "¿Qué es una red Wi-Fi?", topic: "que_es_wifi" },
        { id: "ac_s1_ses15_l2", title: "Riesgos del Wi-Fi público", topic: "riesgos_wifi_publico" },
        { id: "ac_s1_ses15_l3", title: "Cómo protegerte en Wi-Fi público", topic: "proteccion_wifi_publico" },
        { id: "ac_s1_ses15_l4", title: "Configuración segura de tu router", topic: "config_router" },
        { id: "ac_s1_ses15_l5", title: "VPN: qué es y para qué sirve", topic: "intro_vpn" },
      ]},
      { id: "ac_s1_ses16", title: "Uso de VPN", lessons: [
        { id: "ac_s1_ses16_l1", title: "¿Qué es una VPN?", topic: "que_es_vpn" },
        { id: "ac_s1_ses16_l2", title: "Cómo funciona una VPN", topic: "funcionamiento_vpn" },
        { id: "ac_s1_ses16_l3", title: "Cuándo usar una VPN", topic: "cuando_usar_vpn" },
        { id: "ac_s1_ses16_l4", title: "Elegir un servicio de VPN confiable", topic: "elegir_vpn" },
        { id: "ac_s1_ses16_l5", title: "Límites de las VPN", topic: "limites_vpn" },
      ]},
      { id: "ac_s1_ses17", title: "Actualizaciones de seguridad", lessons: [
        { id: "ac_s1_ses17_l1", title: "Por qué son importantes las actualizaciones", topic: "importancia_actualizaciones" },
        { id: "ac_s1_ses17_l2", title: "Tipos de actualizaciones", topic: "tipos_actualizaciones" },
        { id: "ac_s1_ses17_l3", title: "Actualizaciones automáticas vs manuales", topic: "automaticas_vs_manuales" },
        { id: "ac_s1_ses17_l4", title: "Riesgos de no actualizar", topic: "riesgos_no_actualizar" },
        { id: "ac_s1_ses17_l5", title: "Práctica: configura actualizaciones", topic: "practica_actualizaciones" },
      ]},
      { id: "ac_s1_ses18", title: "Examen de navegación y redes", lessons: [
        { id: "ac_s1_ses18_l1", title: "Evaluación: navegación segura", topic: "eval_navegacion" },
        { id: "ac_s1_ses18_l2", title: "Evaluación: Wi-Fi y VPN", topic: "eval_wifi_vpn" },
        { id: "ac_s1_ses18_l3", title: "Evaluación: actualizaciones", topic: "eval_actualizaciones" },
        { id: "ac_s1_ses18_l4", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_nav" },
        { id: "ac_s1_ses18_l5", title: "Repaso de navegación segura", topic: "repaso_navegacion" },
      ]},
      { id: "ac_s1_ses19", title: "Privacidad en línea", lessons: [
        { id: "ac_s1_ses19_l1", title: "¿Qué es la privacidad en línea?", topic: "que_es_privacidad_linea" },
        { id: "ac_s1_ses19_l2", title: "Huella digital", topic: "huella_digital" },
        { id: "ac_s1_ses19_l3", title: "Rastreo en internet", topic: "rastreo_internet" },
        { id: "ac_s1_ses19_l4", title: "Herramientas de privacidad", topic: "herramientas_privacidad" },
        { id: "ac_s1_ses19_l5", title: "Configuración de privacidad del navegador", topic: "config_privacidad_navegador" },
      ]},
      { id: "ac_s1_ses20", title: "Redes sociales y privacidad", lessons: [
        { id: "ac_s1_ses20_l1", title: "Información que revelas en redes sociales", topic: "info_revelada" },
        { id: "ac_s1_ses20_l2", title: "Configuración de privacidad", topic: "config_privacidad_rrss" },
        { id: "ac_s1_ses20_l3", title: "Amigos y seguidores: ¿quién ve tu info?", topic: "quien_ve_info" },
        { id: "ac_s1_ses20_l4", title: "Publicaciones seguras", topic: "publicaciones_seguras" },
        { id: "ac_s1_ses20_l5", title: "Suplantación de identidad en redes", topic: "suplantacion_identidad" },
      ]},
      { id: "ac_s1_ses21", title: "Compras y transacciones en línea", lessons: [
        { id: "ac_s1_ses21_l1", title: "Sitios web seguros para comprar", topic: "sitios_seguros" },
        { id: "ac_s1_ses21_l2", title: "Métodos de pago seguros", topic: "metodos_pago_seguros" },
        { id: "ac_s1_ses21_l3", title: "Verificar la URL del sitio", topic: "verificar_url" },
        { id: "ac_s1_ses21_l4", title: "Facturas y comprobantes digitales", topic: "facturas_digitales" },
        { id: "ac_s1_ses21_l5", title: "Detección de fraudes en compras", topic: "deteccion_fraude_compras" },
      ]},
      { id: "ac_s1_ses22", title: "Examen de privacidad y transacciones", lessons: [
        { id: "ac_s1_ses22_l1", title: "Evaluación: privacidad en línea", topic: "eval_privacidad" },
        { id: "ac_s1_ses22_l2", title: "Evaluación: redes sociales", topic: "eval_rrss" },
        { id: "ac_s1_ses22_l3", title: "Evaluación: compras seguras", topic: "eval_compras" },
        { id: "ac_s1_ses22_l4", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_priv" },
        { id: "ac_s1_ses22_l5", title: "Repaso de privacidad", topic: "repaso_privacidad" },
      ]},
      { id: "ac_s1_ses23", title: "Correo electrónico seguro", lessons: [
        { id: "ac_s1_ses23_l1", title: "Seguridad en cuentas de correo", topic: "seguridad_correo" },
        { id: "ac_s1_ses23_l2", title: "Cifrado de correos electrónicos", topic: "cifrado_correo" },
        { id: "ac_s1_ses23_l3", title: "Detección de spam y phishing", topic: "deteccion_spam" },
        { id: "ac_s1_ses23_l4", title: "Configuración de seguridad del correo", topic: "config_seguridad_correo" },
        { id: "ac_s1_ses23_l5", title: "Gestión de bandeja de entrada", topic: "gestion_bandeja" },
      ]},
      { id: "ac_s1_ses24", title: "Eliminación de datos personales", lessons: [
        { id: "ac_s1_ses24_l1", title: "¿Por qué eliminar datos personales?", topic: "por_que_eliminar" },
        { id: "ac_s1_ses24_l2", title: "Dónde se almacenan tus datos", topic: "donde_se_almacenan" },
        { id: "ac_s1_ses24_l3", title: "Solicitudes de eliminación de datos", topic: "solicitudes_eliminacion" },
        { id: "ac_s1_ses24_l4", title: "Eliminación de cuentas antiguas", topic: "eliminar_cuentas_antiguas" },
        { id: "ac_s1_ses24_l5", title: "Derecho al olvido", topic: "derecho_olvido" },
      ]},
      { id: "ac_s1_ses25", title: "Seguridad en el hogar digital", lessons: [
        { id: "ac_s1_ses25_l1", title: "Dispositivos inteligentes en el hogar", topic: "dispositivos_inteligentes" },
        { id: "ac_s1_ses25_l2", title: "Seguridad del router doméstico", topic: "seguridad_router" },
        { id: "ac_s1_ses25_l3", title: "Redes de invitados", topic: "redes_invitados" },
        { id: "ac_s1_ses25_l4", title: "Cámaras de seguridad y privacidad", topic: "camaras_seguridad" },
        { id: "ac_s1_ses25_l5", title: "Protección de dispositivos IoT", topic: "proteccion_iot" },
      ]},
      { id: "ac_s1_ses26", title: "Repaso general de Fundamentos", lessons: [
        { id: "ac_s1_ses26_l1", title: "Repaso: contraseñas y autenticación", topic: "repaso_contrasenas" },
        { id: "ac_s1_ses26_l2", title: "Repaso: phishing e ingeniería social", topic: "repaso_phishing" },
        { id: "ac_s1_ses26_l3", title: "Repaso: navegación y redes", topic: "repaso_navegacion_redes" },
        { id: "ac_s1_ses26_l4", title: "Repaso: privacidad y datos", topic: "repaso_privacidad_datos" },
        { id: "ac_s1_ses26_l5", title: "Repaso integrado de Fundamentos", topic: "repaso_integrado" },
      ]},
      { id: "ac_s1_ses27", title: "Evaluación final de Fundamentos", lessons: [
        { id: "ac_s1_ses27_l1", title: "Examen: cuentas y contraseñas", topic: "examen_cuentas" },
        { id: "ac_s1_ses27_l2", title: "Examen: phishing e ingeniería social", topic: "examen_phishing" },
        { id: "ac_s1_ses27_l3", title: "Examen: navegación y redes", topic: "examen_navegacion" },
        { id: "ac_s1_ses27_l4", title: "Examen: privacidad y transacciones", topic: "examen_privacidad" },
        { id: "ac_s1_ses27_l5", title: "Certificación de Fundamentos", topic: "certificacion" },
      ]},
    ]
  },
  ac_st2: {
    title: "Seguridad de Dispositivos",
    sessions: [
      { id: "ac_s2_ses1", title: "Configuración de dispositivos seguros", lessons: [
        { id: "ac_s2_ses1_l1", title: "Configuración inicial segura", topic: "config_inicial_segura" },
        { id: "ac_s2_ses1_l2", title: "Bloqueo de pantalla y biometría", topic: "bloqueo_pantalla" },
        { id: "ac_s2_ses1_l3", title: "Perfiles de usuario", topic: "perfiles_usuario" },
        { id: "ac_s2_ses1_l4", title: "Cifrado de dispositivo", topic: "cifrado_dispositivo" },
        { id: "ac_s2_ses1_l5", title: "Localización y recuperación", topic: "localizacion_recuperacion" },
        { id: "ac_s2_ses1_l6", title: "Práctica: configura tu dispositivo", topic: "practica_config_dispositivo" },
      ]},
      { id: "ac_s2_ses2", title: "Actualizaciones de software", lessons: [
        { id: "ac_s2_ses2_l1", title: "Importancia de las actualizaciones", topic: "importancia_updates" },
        { id: "ac_s2_ses2_l2", title: "Actualizaciones del sistema operativo", topic: "updates_sistema" },
        { id: "ac_s2_ses2_l3", title: "Actualizaciones de aplicaciones", topic: "updates_apps" },
        { id: "ac_s2_ses2_l4", title: "Parches de seguridad", topic: "parches_seguridad" },
        { id: "ac_s2_ses2_l5", title: "Riesgos de software desactualizado", topic: "riesgos_desactualizado" },
        { id: "ac_s2_ses2_l6", title: "Automatización de actualizaciones", topic: "automatizacion_updates" },
      ]},
      { id: "ac_s2_ses3", title: "Protección contra malware", lessons: [
        { id: "ac_s2_ses3_l1", title: "¿Qué es el malware?", topic: "que_es_malware" },
        { id: "ac_s2_ses3_l2", title: "Tipos de malware", topic: "tipos_malware" },
        { id: "ac_s2_ses3_l3", title: "Cómo se infecta tu dispositivo", topic: "como_se_infecta" },
        { id: "ac_s2_ses3_l4", title: "Software antivirus y antimalware", topic: "antivirus" },
        { id: "ac_s2_ses3_l5", title: "Señales de infección", topic: "senales_infeccion" },
        { id: "ac_s2_ses3_l6", title: "Práctica: protege tu dispositivo", topic: "practica_proteccion" },
      ]},
      { id: "ac_s2_ses4", title: "Copias de seguridad", lessons: [
        { id: "ac_s2_ses4_l1", title: "¿Qué es una copia de seguridad?", topic: "que_es_backup" },
        { id: "ac_s2_ses4_l2", title: "Tipos de copias de seguridad", topic: "tipos_backup" },
        { id: "ac_s2_ses4_l3", title: "Almacenamiento local vs en la nube", topic: "local_vs_nube" },
        { id: "ac_s2_ses4_l4", title: "Regla 3-2-1 de backups", topic: "regla_321" },
        { id: "ac_s2_ses4_l5", title: "Recuperación de datos", topic: "recuperacion_datos" },
        { id: "ac_s2_ses4_l6", title: "Práctica: crea tu copia de seguridad", topic: "practica_backup" },
      ]},
      { id: "ac_s2_ses5", title: "Dispositivos compartidos", lessons: [
        { id: "ac_s2_ses5_l1", title: "Riesgos de dispositivos compartidos", topic: "riesgos_compartidos" },
        { id: "ac_s2_ses5_l2", title: "Uso seguro de computadoras públicas", topic: "compus_publicas" },
        { id: "ac_s2_ses5_l3", title: "Perfiles de invitado", topic: "perfiles_invitado" },
        { id: "ac_s2_ses5_l4", title: "Cierre de sesión seguro", topic: "cierre_sesion" },
        { id: "ac_s2_ses5_l5", title: "Limpieza de datos personales", topic: "limpieza_datos" },
        { id: "ac_s2_ses5_l6", title: "Práctica: uso seguro compartido", topic: "practica_compartido" },
      ]},
      { id: "ac_s2_ses6", title: "Examen práctico de dispositivos", lessons: [
        { id: "ac_s2_ses6_l1", title: "Evaluación: configuración de seguridad", topic: "eval_config" },
        { id: "ac_s2_ses6_l2", title: "Evaluación: identificación de amenazas", topic: "eval_amenazas" },
        { id: "ac_s2_ses6_l3", title: "Evaluación: protección de datos", topic: "eval_proteccion" },
        { id: "ac_s2_ses6_l4", title: "Evaluación: respaldo y recuperación", topic: "eval_backup" },
        { id: "ac_s2_ses6_l5", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_dev" },
        { id: "ac_s2_ses6_l6", title: "Repaso de seguridad de dispositivos", topic: "repaso_dispositivos" },
      ]},
      { id: "ac_s2_ses7", title: "Seguridad del sistema operativo", lessons: [
        { id: "ac_s2_ses7_l1", title: "Configuración de seguridad de Windows", topic: "seguridad_windows" },
        { id: "ac_s2_ses7_l2", title: "Configuración de seguridad de macOS", topic: "seguridad_macos" },
        { id: "ac_s2_ses7_l3", title: "Configuración de seguridad de Android", topic: "seguridad_android" },
        { id: "ac_s2_ses7_l4", title: "Configuración de seguridad de iOS", topic: "seguridad_ios" },
        { id: "ac_s2_ses7_l5", title: "Configuración de seguridad de Linux", topic: "seguridad_linux" },
        { id: "ac_s2_ses7_l6", title: "Comparación de sistemas operativos", topic: "comparacion_sos" },
      ]},
      { id: "ac_s2_ses8", title: "Cortafuegos y redes", lessons: [
        { id: "ac_s2_ses8_l1", title: "¿Qué es un cortafuegos?", topic: "que_es_firewall" },
        { id: "ac_s2_ses8_l2", title: "Cortafuegos de software", topic: "firewall_software" },
        { id: "ac_s2_ses8_l3", title: "Cortafuegos de hardware", topic: "firewall_hardware" },
        { id: "ac_s2_ses8_l4", title: "Configuración de reglas de cortafuegos", topic: "reglas_firewall" },
        { id: "ac_s2_ses8_l5", title: "Monitoreo de tráfico de red", topic: "monitoreo_trafico" },
        { id: "ac_s2_ses8_l6", title: "Práctica: configura tu cortafuegos", topic: "practica_firewall" },
      ]},
      { id: "ac_s2_ses9", title: "Encriptación de datos", lessons: [
        { id: "ac_s2_ses9_l1", title: "¿Qué es la encriptación?", topic: "que_es_encriptacion" },
        { id: "ac_s2_ses9_l2", title: "Encriptación de disco completo", topic: "encriptacion_disco" },
        { id: "ac_s2_ses9_l3", title: "Encriptación de archivos individuales", topic: "encriptacion_archivos" },
        { id: "ac_s2_ses9_l4", title: "Encriptación de dispositivos móviles", topic: "encriptacion_movil" },
        { id: "ac_s2_ses9_l5", title: "Herramientas de encriptación", topic: "herramientas_encriptacion" },
        { id: "ac_s2_ses9_l6", title: "Práctica: encripta tus datos", topic: "practica_encriptacion" },
      ]},
      { id: "ac_s2_ses10", title: "Administración de cuentas de usuario", lessons: [
        { id: "ac_s2_ses10_l1", title: "Tipos de cuentas de usuario", topic: "tipos_cuentas" },
        { id: "ac_s2_ses10_l2", title: "Permisos y privilegios", topic: "permisos_privilegios" },
        { id: "ac_s2_ses10_l3", title: "Cuenta de administrador vs usuario", topic: "admin_vs_usuario" },
        { id: "ac_s2_ses10_l4", title: "Gestión de múltiples cuentas", topic: "gestion_multiples" },
        { id: "ac_s2_ses10_l5", title: "Protección de cuentas de usuario", topic: "proteccion_cuentas" },
        { id: "ac_s2_ses10_l6", title: "Práctica: configura tus cuentas", topic: "practica_cuentas" },
      ]},
      { id: "ac_s2_ses11", title: "Examen de seguridad del sistema", lessons: [
        { id: "ac_s2_ses11_l1", title: "Evaluación: sistemas operativos", topic: "eval_sos" },
        { id: "ac_s2_ses11_l2", title: "Evaluación: cortafuegos y redes", topic: "eval_firewall" },
        { id: "ac_s2_ses11_l3", title: "Evaluación: encriptación", topic: "eval_encriptacion" },
        { id: "ac_s2_ses11_l4", title: "Evaluación: cuentas de usuario", topic: "eval_cuentas_usuario" },
        { id: "ac_s2_ses11_l5", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_sos" },
        { id: "ac_s2_ses11_l6", title: "Repaso de seguridad del sistema", topic: "repaso_sistema" },
      ]},
      { id: "ac_s2_ses12", title: "Eliminación segura de datos", lessons: [
        { id: "ac_s2_ses12_l1", title: "¿Por qué borrar datos no es suficiente?", topic: "borrar_no_suficiente" },
        { id: "ac_s2_ses12_l2", title: "Métodos de eliminación segura", topic: "metodos_eliminacion" },
        { id: "ac_s2_ses12_l3", title: "Software de eliminación de datos", topic: "software_eliminacion" },
        { id: "ac_s2_ses12_l4", title: "Reciclaje de dispositivos electrónicos", topic: "reciclaje_dispositivos" },
        { id: "ac_s2_ses12_l5", title: "Destrucción física de almacenamiento", topic: "destruccion_fisica" },
        { id: "ac_s2_ses12_l6", title: "Práctica: elimina datos de forma segura", topic: "practica_eliminacion" },
      ]},
      { id: "ac_s2_ses13", title: "Protección de datos en la nube", lessons: [
        { id: "ac_s2_ses13_l1", title: "¿Qué es la almacenamiento en la nube?", topic: "que_es_nube" },
        { id: "ac_s2_ses13_l2", title: "Servicios de nube populares", topic: "servicios_nube" },
        { id: "ac_s2_ses13_l3", title: "Seguridad en la nube", topic: "seguridad_nube" },
        { id: "ac_s2_ses13_l4", title: "Configuración de privacidad en la nube", topic: "privacidad_nube" },
        { id: "ac_s2_ses13_l5", title: "Sincronización segura de datos", topic: "sincronizacion_segura" },
        { id: "ac_s2_ses13_l6", title: "Práctica: configura tu nube segura", topic: "practica_nube" },
      ]},
      { id: "ac_s2_ses14", title: "Examen de eliminación y nube", lessons: [
        { id: "ac_s2_ses14_l1", title: "Evaluación: eliminación de datos", topic: "eval_eliminacion" },
        { id: "ac_s2_ses14_l2", title: "Evaluación: almacenamiento en la nube", topic: "eval_nube" },
        { id: "ac_s2_ses14_l3", title: "Evaluación: reciclaje de dispositivos", topic: "eval_reciclaje" },
        { id: "ac_s2_ses14_l4", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_nube" },
        { id: "ac_s2_ses14_l5", title: "Repaso de eliminación y nube", topic: "repaso_eliminacion_nube" },
        { id: "ac_s2_ses14_l6", title: "Evaluación práctica", topic: "eval_practica_nube" },
      ]},
      { id: "ac_s2_ses15", title: "Seguridad en dispositivos móviles", lessons: [
        { id: "ac_s2_ses15_l1", title: "Amenazas específicas para móviles", topic: "amenazas_moviles" },
        { id: "ac_s2_ses15_l2", title: "Configuración de seguridad en Android", topic: "config_android" },
        { id: "ac_s2_ses15_l3", title: "Configuración de seguridad en iOS", topic: "config_ios" },
        { id: "ac_s2_ses15_l4", title: "Protección contra robo de dispositivos", topic: "proteccion_robo" },
        { id: "ac_s2_ses15_l5", title: "Seguridad en tablets", topic: "seguridad_tablets" },
        { id: "ac_s2_ses15_l6", title: "Práctica: asegura tu móvil", topic: "practica_movil" },
      ]},
      { id: "ac_s2_ses16", title: "Aplicaciones móviles seguras", lessons: [
        { id: "ac_s2_ses16_l1", title: "Fuentes de aplicaciones seguras", topic: "fuentes_seguras" },
        { id: "ac_s2_ses16_l2", title: "Permisos de aplicaciones", topic: "permisos_apps" },
        { id: "ac_s2_ses16_l3", title: "Aplicaciones falsas y maliciosas", topic: "apps_falsas" },
        { id: "ac_s2_ses16_l4", title: "Actualización de aplicaciones", topic: "actualizacion_apps" },
        { id: "ac_s2_ses16_l5", title: "Desinstalación segura de aplicaciones", topic: "desinstalacion_segura" },
        { id: "ac_s2_ses16_l6", title: "Práctica: evalúa tus aplicaciones", topic: "practica_evaluar_apps" },
      ]},
      { id: "ac_s2_ses17", title: "Examen de seguridad móvil", lessons: [
        { id: "ac_s2_ses17_l1", title: "Evaluación: configuración móvil", topic: "eval_config_movil" },
        { id: "ac_s2_ses17_l2", title: "Evaluación: aplicaciones seguras", topic: "eval_apps_seguras" },
        { id: "ac_s2_ses17_l3", title: "Evaluación: protección contra robo", topic: "eval_proteccion_robo" },
        { id: "ac_s2_ses17_l4", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_movil" },
        { id: "ac_s2_ses17_l5", title: "Repaso de seguridad móvil", topic: "repaso_movil" },
        { id: "ac_s2_ses17_l6", title: "Evaluación práctica móvil", topic: "eval_practica_movil" },
      ]},
      { id: "ac_s2_ses18", title: "Seguridad en dispositivos IoT", lessons: [
        { id: "ac_s2_ses18_l1", title: "¿Qué son los dispositivos IoT?", topic: "que_es_iot" },
        { id: "ac_s2_ses18_l2", title: "Amenazas de dispositivos IoT", topic: "amenazas_iot" },
        { id: "ac_s2_ses18_l3", title: "Configuración segura de dispositivos IoT", topic: "config_iot" },
        { id: "ac_s2_ses18_l4", title: "Cámaras de seguridad inteligentes", topic: "camaras_inteligentes" },
        { id: "ac_s2_ses18_l5", title: "Asistentes de voz y privacidad", topic: "asistentes_voz" },
        { id: "ac_s2_ses18_l6", title: "Práctica: asegura tus dispositivos IoT", topic: "practica_iot" },
      ]},
      { id: "ac_s2_ses19", title: "Copia de seguridad avanzada", lessons: [
        { id: "ac_s2_ses19_l1", title: "Copias de seguridad incrementales", topic: "backup_incremental" },
        { id: "ac_s2_ses19_l2", title: "Copias de seguridad diferenciales", topic: "backup_diferencial" },
        { id: "ac_s2_ses19_l3", title: "Automatización de backups", topic: "automatizacion_backup" },
        { id: "ac_s2_ses19_l4", title: "Verificación de integridad de backups", topic: "verificacion_backup" },
        { id: "ac_s2_ses19_l5", title: "Prueba de recuperación", topic: "prueba_recuperacion" },
        { id: "ac_s2_ses19_l6", title: "Práctica: backup automatizado", topic: "practica_backup_auto" },
      ]},
      { id: "ac_s2_ses20", title: "Examen de IoT y backups avanzados", lessons: [
        { id: "ac_s2_ses20_l1", title: "Evaluación: dispositivos IoT", topic: "eval_iot" },
        { id: "ac_s2_ses20_l2", title: "Evaluación: backups avanzados", topic: "eval_backups" },
        { id: "ac_s2_ses20_l3", title: "Evaluación: escenarios integrados", topic: "eval_escenarios_iot" },
        { id: "ac_s2_ses20_l4", title: "Evaluación: recuperación de datos", topic: "eval_recuperacion" },
        { id: "ac_s2_ses20_l5", title: "Repaso de IoT y backups", topic: "repaso_iot_backups" },
        { id: "ac_s2_ses20_l6", title: "Evaluación final práctica", topic: "eval_final_practica" },
      ]},
      { id: "ac_s2_ses21", title: "Repaso general de Seguridad de Dispositivos", lessons: [
        { id: "ac_s2_ses21_l1", title: "Repaso: configuración de dispositivos", topic: "repaso_config" },
        { id: "ac_s2_ses21_l2", title: "Repaso: malware y antivirus", topic: "repaso_malware" },
        { id: "ac_s2_ses21_l3", title: "Repaso: copias de seguridad", topic: "repaso_backups" },
        { id: "ac_s2_ses21_l4", title: "Repaso: eliminación y nube", topic: "repaso_eliminacion" },
        { id: "ac_s2_ses21_l5", title: "Repaso integrado de Dispositivos", topic: "repaso_integrado_dev" },
        { id: "ac_s2_ses21_l6", title: "Evaluación de repaso", topic: "eval_repaso" },
      ]},
      { id: "ac_s2_ses22", title: "Evaluación final de Seguridad de Dispositivos", lessons: [
        { id: "ac_s2_ses22_l1", title: "Examen: configuración y sistemas", topic: "examen_config" },
        { id: "ac_s2_ses22_l2", title: "Examen: malware y protección", topic: "examen_malware" },
        { id: "ac_s2_ses22_l3", title: "Examen: backups y eliminación", topic: "examen_backup" },
        { id: "ac_s2_ses22_l4", title: "Examen: dispositivos IoT y móvil", topic: "examen_iot_movil" },
        { id: "ac_s2_ses22_l5", title: "Certificación de Seguridad de Dispositivos", topic: "certificacion_dev" },
        { id: "ac_s2_ses22_l6", title: "Evaluación práctica final", topic: "eval_practica_final" },
      ]},
    ]
  },
  ac_st3: {
    title: "Protección de Datos Personales",
    sessions: (() => {
      const sessions = [];
      const topicPrefixes = [
        "Gestión de información personal",
        "Cifrado y protección de datos",
        "Privacidad en la nube",
        "Eliminación segura de datos",
        "Privacidad en el hogar",
        "Evaluación de protección",
        "Gestión avanzada de contraseñas",
        "Privacidad en búsquedas",
        "Protección contra fraude",
        "Evaluación de privacidad",
        "Protección de identidad",
        "Derechos digitales",
        "Seguridad en transacciones",
        "Protección financiera",
        "Evaluación financiera",
        "Privacidad en comunicaciones",
        "Protección de menores",
        "Seguridad en el trabajo",
        "Evaluación integral",
        "Gobernanza de datos",
        "Auditoría de privacidad",
        "Cumplimiento normativo",
        "Evaluación de cumplimiento",
        "Repaso general",
        "Evaluación final"
      ];
      const lessonsPerSession = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
      const sessionTitles = [
        "Gestión de información personal", "Cifrado y protección de datos",
        "Privacidad en la nube", "Eliminación segura de datos",
        "Privacidad en el hogar digital", "Evaluación de protección de datos",
        "Gestión avanzada de contraseñas", "Privacidad en búsquedas web",
        "Protección contra fraude y estafas", "Evaluación de privacidad",
        "Protección de identidad digital", "Derechos digitales y privacidad",
        "Seguridad en transacciones en línea", "Protección financiera digital",
        "Evaluación de seguridad financiera", "Privacidad en comunicaciones",
        "Protección de información de menores", "Seguridad en el entorno laboral",
        "Evaluación integral de protección", "Gobernanza de datos personales",
        "Auditoría de privacidad", "Cumplimiento normativo de protección",
        "Evaluación de cumplimiento", "Repaso general de protección",
        "Evaluación final de protección de datos",
        "Derechos del consumidor digital", "Privacidad en aplicaciones",
        "Protección en dispositivos compartidos", "Evaluación de escenarios reales",
        "Certificación de protección de datos"
      ];
      const lessonTopics = [
        "clasificacion_datos", "metodos_proteccion", "configuracion_privacidad",
        "etiquetado_datos", "politica_datos", "eval_clasificacion",
        "cifrado_datos", "almacenamiento_cifrado", "transmision_segura",
        "herramientas_cifrado", "cifrado_movil", "eval_cifrado",
        "config_nube", "datos_en_linea", "permisos_nube",
        "sincronizacion_segura", "backup_nube", "eval_nube",
        "metodos_eliminacion", "reciclaje_dispositivos", "proteccion_recuperacion",
        "herramientas_eliminacion", "eliminacion_remota", "eval_eliminacion",
        "dispositivos_inteligentes", "datos_domesticos", "permisos_iot",
        "camaras_hogar", "asistentes_voz", "eval_hogar",
        "administradores_contrasenas", "2fa_avanzada", "passkeys",
        "gestion_tokens", "recuperacion_cuentas", "eval_contrasenas",
        "motores_busqueda_seguros", "navegacion_privada", "proteccion_rastreo",
        "config_privacidad_web", "herramientas_privacidad", "eval_busquedas",
        "deteccion_fraude", "phishing_avanzado", "respuesta_incidentes",
        "proteccion_estafas", "reporte_fraude", "eval_fraude",
        "gestion_identidad", "verificacion_identidad", "proteccion_id",
        "documentos_digitales", "copia_id_segura", "eval_identidad",
        "derechos_privacidad", "legislacion_datos", "consentimiento",
        "acceso_datos", "portabilidad", "eval_derechos",
        "pagos_seguros", "tarjetas_digitales", "verificacion_transacciones",
        "compras_protegidas", "reembolsos", "eval_transacciones",
        "proteccion_bancaria", "alertas_fraude", "seguridad_inversiones",
        "criptomonedas_seguras", "banca_en_linea", "eval_financiera",
        "eval_fraude_avanzado", "eval_estafas", "eval_proteccion_fin",
        "eval_integrado_fin", "eval_practica_fin", "eval_casos_fin",
        "cifrado_mensajes", "privacidad_correo", "llamadas_seguras",
        "videoconferencias_seguras", "mensajeria_segura", "eval_comunicaciones",
        "proteccion_menores", "configuracion_parental", "educacion_digital",
        "redes_sociales_menores", "supervision_respetuosa", "eval_menores",
        "seguridad_oficina", "datos_empresa", "politicas_trabajo",
        "trabajo_remoto_seguro", "dispositivos_empresa", "eval_trabajo",
        "eval_integral_1", "eval_integral_2", "eval_integral_3",
        "eval_integral_4", "eval_integral_5", "eval_integral_6",
        "gestion_datos_empresa", "clasificacion_empresarial", "politica_retencion",
        "acceso_controlado", "auditoria_datos", "eval_gobernanza",
        "auditoria_interna", "auditoria_externa", "herramientas_auditoria",
        "reportes_auditor", "mejora_continua", "eval_auditoria",
        "cumplimiento_regulatorio", "proteccion_datos_ley", "notificacion_brechas",
        "responsable_datos", "dpo_funciones", "eval_cumplimiento",
        "eval_cumplimiento_1", "eval_cumplimiento_2", "eval_cumplimiento_3",
        "eval_cumplimiento_4", "eval_cumplimiento_5", "eval_cumplimiento_6",
        "repaso_gestion", "repaso_cifrado", "repaso_privacidad_nube",
        "repaso_identidad", "repaso_financiero", "repaso_integral",
        "final_proteccion_1", "final_proteccion_2", "final_proteccion_3",
        "final_proteccion_4", "final_proteccion_5", "final_proteccion_6",
        "consumidor_digital", "apps_privacidad", "dispositivos_compartidos",
        "escenarios_reales", "casos_practicos", "certificacion"
      ];
      let lessonIdx = 0;
      for (let i = 0; i < 30; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s3_ses${i+1}_l${j+1}`,
            title: `${topicPrefixes[i]} - Lección ${j+1}`,
            topic: lessonTopics[lessonIdx] || `topic_st3_${lessonIdx}`
          });
          lessonIdx++;
        }
        sessions.push({
          id: `ac_s3_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  },
  ac_st4: {
    title: "Seguridad en Línea y Redes Sociales",
    sessions: (() => {
      const sessions = [];
      const sessionTitles = [
        "Privacidad en redes sociales", "Ciberbullying y acoso en línea",
        "Privacidad en mensajería", "Compras y transacciones en línea",
        "Privacidad en plataformas sociales", "Evaluación de privacidad social",
        "Protección contra suplantación de identidad", "Seguridad en correos electrónicos",
        "Reputación digital", "Evaluación de seguridad en línea",
        "Seguridad en videoconferencias", "Privacidad en streaming",
        "Evaluación multimedia", "Protección en foros y comunidades",
        "Seguridad en blogs", "Evaluación de publicaciones",
        "Protección en eventos en línea", "Seguridad en subastas en línea",
        "Evaluación de comercio", "Privacidad en búsquedas avanzadas",
        "Seguridad en VPN corporativa", "Evaluación de seguridad avanzada",
        "Repaso general en línea", "Evaluación final en línea"
      ];
      const lessonTopicsBase = [
        "config_privacidad_rrss", "informacion_expuesta", "practicas_privacidad",
        "gestion_amigos", "bloqueo_reporte", "eval_privacidad_rrss",
        "que_es_ciberbullying", "tipos_acoso", "prevencion_acoso",
        "reporte_acoso", "apoyo_victimas", "eval_acoso",
        "cifrado_e2e", "privacidad_mensajes", "grupos_seguros",
        "verificacion_contactos", "config_mensajeria", "eval_mensajeria",
        "sitios_seguros", "metodos_pago", "deteccion_fraude_compras",
        "facturas_digitales", "proteccion_comprador", "eval_compras",
        "facebook_privacidad", "instagram_privacidad", "twitter_privacidad",
        "permisos_aplicaciones", "proteccion_suplantacion", "eval_plataformas",
        "config_privacidad_eval", "privacidad_mensajeria_eval", "privacidad_rrss_eval",
        "escenarios_privacidad", "casos_reales_eval", "eval_practica_social",
        "que_es_suplantacion", "detectar_suplantacion", "proteccion_identidad",
        "respuesta_suplantacion", "recuperacion_cuenta", "eval_suplantacion",
        "cifrado_correo", "proteccion_phishing_correo", "gestion_spam",
        "config_seguridad_correo", "filtros_avanzados", "eval_correo",
        "gestion_huella_digital", "proteccion_reputacion", "privacidad_busquedas",
        "monitor reputacion", "herramientas_reputacion", "eval_reputacion",
        "eval_seguridad_linea_1", "eval_seguridad_linea_2", "eval_seguridad_linea_3",
        "eval_seguridad_linea_4", "eval_seguridad_linea_5", "eval_seguridad_linea_6",
        "seguridad_videoconferencias", "proteccion_pantalla", "grabaciones_seguras",
        "config_zoom", "config_teams", "eval_videoconferencias",
        "privacidad_netflix", "privacidad_youtube", "datos_streaming",
        "perfil_anonimo", "config_streaming", "eval_streaming",
        "eval_multimedia_1", "eval_multimedia_2", "eval_multimedia_3",
        "eval_multimedia_4", "eval_multimedia_5", "eval_multimedia_6",
        "seguridad_foros", "anonimato_foros", "proteccion Datos_foros",
        "reporte_contenido", "normas_comunidad", "eval_foros",
        "seguridad blogs", "proteccion_autor", "privacidad_comentarios",
        "gestion_contenido", "backup_contenido", "eval_blogs",
        "eval_publicaciones_1", "eval_publicaciones_2", "eval_publicaciones_3",
        "eval_publicaciones_4", "eval_publicaciones_5", "eval_publicaciones_6",
        "seguridad_eventos_linea", "proteccion_datos_eventos", "pases_digitales",
        "verificacion_eventos", "privacidad_asistentes", "eval_eventos",
        "seguridad_subastas", "comprador_seguro", "vendedor_seguro",
        "pago_protegido", "resolucion_disputas", "eval_subastas",
        "eval_comercio_1", "eval_comercio_2", "eval_comercio_3",
        "eval_comercio_4", "eval_comercio_5", "eval_comercio_6",
        "busqueda_avanzada", "operadores_busqueda", "privacidad_busqueda",
        "config_busqueda_segura", "herramientas_busqueda", "eval_busqueda",
        "vpn_corporativa", "acceso_remoto", "tunel_seguro",
        "config_vpn_corp", "monitoreo_vpn", "eval_vpn_corp",
        "eval_seg_avanzada_1", "eval_seg_avanzada_2", "eval_seg_avanzada_3",
        "eval_seg_avanzada_4", "eval_seg_avanzada_5", "eval_seg_avanzada_6",
        "repaso_privacidad", "repaso_seguridad", "repaso_mensajeria",
        "repaso_transacciones", "repaso_reputacion", "repaso_integrado_linea",
        "final_linea_1", "final_linea_2", "final_linea_3",
        "final_linea_4", "final_linea_5", "final_linea_6"
      ];
      const lessonsPerSession = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6];
      let lessonIdx = 0;
      for (let i = 0; i < 24; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s4_ses${i+1}_l${j+1}`,
            title: `Lección ${j+1}`,
            topic: lessonTopicsBase[lessonIdx] || `topic_st4_${lessonIdx}`
          });
          lessonIdx++;
        }
        sessions.push({
          id: `ac_s4_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  },
  ac_st5: {
    title: "Seguridad Móvil y Aplicaciones",
    sessions: (() => {
      const sessions = [];
      const sessionTitles = [
        "Configuración de seguridad móvil", "Aplicaciones móviles seguras",
        "Protección contra malware móvil", "Transacciones móviles seguras",
        "Dispositivos wearables", "Evaluación de seguridad móvil",
        "Redes móviles y5G", "Copias de seguridad móvil",
        "Privacidad en apps móviles", "Evaluación de privacidad móvil",
        "Seguridad en tablets", "Permisos de apps avanzados",
        "Evaluación de permisos", "Protección contra spyware móvil",
        "Recuperación de dispositivos", "Evaluación de recuperación",
        "Seguridad en dispositivos legacy", "Actualizaciones de firmware",
        "Evaluación de firmware", "Seguridad biométrica móvil",
        "Autenticación en apps", "Evaluación de autenticación",
        "Repaso general móvil", "Evaluación integral móvil",
        "Seguridad IoT móvil", "Gestión de dispositivos MDM",
        "Evaluación MDM", "Examen final móvil",
        "Certificación seguridad móvil"
      ];
      const lessonsPerSession = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
      let counter = 0;
      for (let i = 0; i < 29; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s5_ses${i+1}_l${j+1}`,
            title: `Lección ${j+1}`,
            topic: `topic_st5_${counter++}`
          });
        }
        sessions.push({
          id: `ac_s5_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  },
  ac_st6: {
    title: "Ciberseguridad Empresarial",
    sessions: (() => {
      const sessions = [];
      const sessionTitles = [
        "Seguridad organizacional", "Trabajo remoto seguro",
        "Amenazas internas", "Cumplimiento normativo",
        "Evaluación empresarial", "Respuesta a incidentes",
        "Cadena de suministro", "Capacitación en ciberseguridad",
        "Evaluación práctica", "Gobernanza de seguridad",
        "Gestión de riesgos", "Métricas de seguridad",
        "Evaluación de métricas", "Seguridad en la nube empresarial",
        "DevSecOps", "Automatización de seguridad",
        "Evaluación DevOps", "Ciberseguridad para pymes",
        "Repaso general empresarial", "Evaluación final empresarial"
      ];
      const lessonsPerSession = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6];
      let counter = 0;
      for (let i = 0; i < 20; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s6_ses${i+1}_l${j+1}`,
            title: `Lección ${j+1}`,
            topic: `topic_st6_${counter++}`
          });
        }
        sessions.push({
          id: `ac_s6_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  },
  ac_st7: {
    title: "Amenazas Avanzadas y Respuesta a Incidentes",
    sessions: (() => {
      const sessions = [];
      const sessionTitles = [
        "Amenazas avanzadas (APT, zero-day)", "Análisis de vulnerabilidades",
        "Respuesta a incidentes", "Forense digital",
        "Evaluación de amenazas", "Seguridad en la nube avanzada",
        "DevSecOps avanzado", "Automatización de seguridad",
        "Evaluación DevOps avanzado", "Análisis de malware",
        "Threat intelligence", "Honeypots y trampas",
        "Evaluación de threat intel", "Seguridad de infraestructura crítica",
        "Criptografía avanzada", "Blockchain y seguridad",
        "Evaluación criptografía", "Redes seguras avanzadas",
        "Firewall de nueva generación", "Sistemas de detección de intrusiones",
        "Evaluación de redes", "Análisis forense avanzado",
        "Recuperación de datos", "Evaluación forense",
        "Repaso general avanzado"
      ];
      const lessonsPerSession = [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5];
      let counter = 0;
      for (let i = 0; i < 25; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s7_ses${i+1}_l${j+1}`,
            title: `Lección ${j+1}`,
            topic: `topic_st7_${counter++}`
          });
        }
        sessions.push({
          id: `ac_s7_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  },
  ac_st8: {
    title: "Evaluación Final y Certificación",
    sessions: (() => {
      const sessions = [];
      const sessionTitles = [
        "Evaluación integral de fundamentos", "Evaluación de seguridad de dispositivos",
        "Evaluación de protección de datos", "Evaluación de seguridad en línea",
        "Evaluación de seguridad móvil", "Evaluación empresarial",
        "Evaluación de amenazas avanzadas", "Evaluación técnica avanzada",
        "Evaluación de gestión de incidentes", "Evaluación forense",
        "Evaluación de criptografía", "Evaluación de redes",
        "Evaluación DevSecOps", "Evaluación de cloud security",
        "Evaluación de compliance", "Evaluación de gobernanza",
        "Evaluación de riesgos", "Evaluación de continuidad",
        "Evaluación de recuperación", "Evaluación de auditoría",
        "Evaluación integral técnica", "Evaluación de casos prácticos",
        "Simulacro de examen completo", "Evaluación de escenarios reales",
        "Evaluación final técnica", "Evaluación de certificación",
        "Certificación final", "Ceremonia de graduación"
      ];
      const lessonsPerSession = [6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6];
      let counter = 0;
      for (let i = 0; i < 28; i++) {
        const numLessons = lessonsPerSession[i];
        const lessons = [];
        for (let j = 0; j < numLessons; j++) {
          lessons.push({
            id: `ac_s8_ses${i+1}_l${j+1}`,
            title: `Lección ${j+1}`,
            topic: `topic_st8_${counter++}`
          });
        }
        sessions.push({
          id: `ac_s8_ses${i+1}`,
          title: sessionTitles[i] || `Sesión ${i+1}`,
          lessons
        });
      }
      return sessions;
    })()
  }
};

// Verify question counts
let totalQuestions = 0;
for (const [stageId, stage] of Object.entries(CURRICULUM)) {
  let stageQuestions = 0;
  for (const session of stage.sessions) {
    for (const lesson of session.lessons) {
      stageQuestions += 15;
    }
  }
  totalQuestions += stageQuestions;
  console.log(`${stageId}: ${stage.sessions.length} sessions, ${stageQuestions} questions`);
}
console.log(`Total: ${totalQuestions} questions`);

// Export for generation
module.exports = { CURRICULUM, totalQuestions };
