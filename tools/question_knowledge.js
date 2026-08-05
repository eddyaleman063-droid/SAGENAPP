/**
 * Question Knowledge Base — topic-specific questions per stage.
 * Each entry: { q: question, o: options, c: correctIndex, e: explanation, d: difficulty, t: type, stage: stageNum, lessonId: 'sesX_lY' }
 */

module.exports = {
  ac_st1: [
    // Session 1: Qué es una cuenta digital
    { q: '¿Qué es una cuenta digital?', o: ['Un registro en línea que identifica al usuario ante un servicio', 'Un archivo en la computadora', 'Un programa de seguridad', 'Un tipo de contraseña'], c: 0, e: 'Una cuenta digital asocia un usuario con un servicio en línea.', d: 1, t: 'multipleChoice', stage: 1 },
    { q: 'Las cuentas digitales se acceden exclusivamente por internet.', o: ['Verdadero', 'Falso'], c: 0, e: 'Las cuentas digitales se diseñan para accederse por internet.', d: 1, stage: 1 },
    { q: '¿Cuál de las siguientes es una cuenta digital?', o: ['Cuenta de correo electrónico', 'Cuenta de electricidad', 'Cuenta de agua', 'Cuenta bancaria física'], c: 0, e: 'El correo electrónico es un ejemplo de cuenta digital.', d: 1, stage: 1 },
    { q: '¿Qué diferencia hay entre una cuenta local y una en línea?', o: ['La local solo funciona en el dispositivo; la línea requiere internet', 'No hay diferencia', 'La línea es más segura siempre', 'La local no necesita contraseña'], c: 0, e: 'Las cuentas locales almacenan datos solo en el dispositivo.', d: 1, stage: 1 },
    { q: 'Detecta el riesgo: Compartir tu contraseña con un amigo cercano.', o: ['Riesgoso', 'Seguro'], c: 0, e: 'Nunca se debe compartir contraseñas.', d: 1, stage: 1 },

    // Session 2: Contraseñas conceptos
    { q: '¿Qué es una contraseña?', o: ['Una cadena de caracteres que autentica tu identidad', 'Un nombre de usuario', 'Un código postal', 'Un tipo de encriptación'], c: 0, e: 'La contraseña verifica la identidad del usuario.', d: 1, stage: 1 },
    { q: 'La contraseña es la primera barrera de protección de una cuenta.', o: ['Verdadero', 'Falso'], c: 0, e: 'Sin contraseña, cualquier persona podría acceder.', d: 1, stage: 1 },
    { q: 'Caso: Carlos usa solo su fecha de nacimiento como contraseña. ¿Es seguro?', o: ['No, es fácil de adivinar', 'Sí, porque es personal', 'Sí, si no se la dice a nadie', 'No, porque es muy larga'], c: 0, e: 'Las fechas de nacimiento son datos fáciles de obtener.', d: 2, stage: 1 },

    // Session 3: Contraseñas seguras
    { q: '¿Cuál es la regla número uno para crear una contraseña segura?', o: ['Que sea única para cada cuenta', 'Que sea corta', 'Que use solo números', 'Que sea fácil de recordar'], c: 0, e: 'La unicidad es fundamental para que una filtración no comprometa todas tus cuentas.', d: 1, stage: 1 },
    { q: '¿Qué caracteres debe tener una contraseña segura?', o: ['Letras mayúsculas, minúsculas, números y símbolos', 'Solo letras', 'Solo números', 'Solo mayúsculas'], c: 0, e: 'La combinación aumenta exponencialmente la seguridad.', d: 1, stage: 1 },
    { q: 'Una contraseña de 16 caracteres es más segura que una de 8.', o: ['Verdadero', 'Falso'], c: 0, e: 'Duplicar la longitud aumenta las combinaciones posibles.', d: 1, stage: 1 },

    // Session 4: Reutilización
    { q: '¿Cuál es el mayor riesgo de reutilizar contraseñas?', o: ['Si una se filtra, todas quedan comprometidas', 'Ninguno es seguro', 'Solo afecta a una cuenta', 'Mejora la organización'], c: 0, e: 'La reutilización crea un efecto dominó.', d: 1, stage: 1 },
    { q: 'Si tu contraseña de redes sociales se filtra, tu banco también está en riesgo si reutilizas.', o: ['Verdadero', 'Falso'], c: 0, e: 'Los atacantes prueban credenciales filtradas en múltiples servicios.', d: 2, stage: 1 },

    // Session 5: Gestores
    { q: '¿Qué es un gestor de contraseñas?', o: ['Un programa que almacena y genera contraseñas seguras', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los gestores gestionan credenciales de forma segura.', d: 1, stage: 1 },
    { q: 'Solo necesitas recordar una contraseña: la maestra del gestor.', o: ['Verdadero', 'Falso'], c: 0, e: 'La maestra es la única que memorizas.', d: 1, stage: 1 },

    // Session 6: Recuperación
    { q: '¿Qué es una pregunta de seguridad?', o: ['Una pregunta personal que usas para recuperar tu cuenta', 'Una contraseña alternativa', 'Un código de verificación', 'Un tipo de 2FA'], c: 0, e: 'Las preguntas de seguridad verifican tu identidad.', d: 1, stage: 1 },
    { q: 'Las preguntas de seguridad deben tener respuestas que solo tú conozcas.', o: ['Verdadero', 'Falso'], c: 0, e: 'Si alguien más conoce la respuesta, puede comprometer tu cuenta.', d: 1, stage: 1 },

    // Session 7: 2FA
    { q: '¿Qué es la verificación en dos pasos (2FA)?', o: ['Un método que requiere dos factores para acceder', 'Un tipo de contraseña', 'Un antivirus', 'Un gestor'], c: 0, e: 'La 2FA añade una segunda capa de seguridad.', d: 1, stage: 1 },
    { q: 'La 2FA protege tu cuenta aunque tu contraseña sea filtrada.', o: ['Verdadero', 'Falso'], c: 0, e: 'El segundo factor impide el acceso sin el dispositivo.', d: 1, stage: 1 },

    // Session 8: Phishing por correo
    { q: '¿Qué es el phishing por correo electrónico?', o: ['Correos falsos que intentan robar información', 'Correos con virus', 'Correos de marketing', 'Correos automáticos'], c: 0, e: 'El phishing usa correos falsos para suplantar entidades.', d: 1, stage: 1 },
    { q: 'Nunca debes hacer clic en enlaces de correos no solicitados.', o: ['Verdadero', 'Falso'], c: 0, e: 'Los enlaces pueden dirigir a sitios falsos.', d: 1, stage: 1 },

    // Session 9: Navegación segura
    { q: '¿Qué es HTTPS?', o: ['Un protocolo que cifra la conexión entre tu navegador y el sitio', 'Un tipo de virus', 'Un navegador', 'Un servicio de correo'], c: 0, e: 'HTTPS cifra los datos transmitidos.', d: 1, stage: 1 },
    { q: 'El candado en la barra de direcciones indica conexión cifrada.', o: ['Verdadero', 'Falso'], c: 0, e: 'El candado indica HTTPS, pero no garantiza que el sitio sea legítimo.', d: 1, stage: 1 },

    // Session 10: Wi-Fi y redes públicas
    { q: '¿Cuál es el riesgo principal de usar Wi-Fi público?', o: ['Interceptación de datos por terceros', 'Mejora de la velocidad', 'Ahorro de datos', 'Ninguno'], c: 0, e: 'El Wi-Fi público puede ser interceptado fácilmente.', d: 1, stage: 1 },
    { q: 'Debes evitar acceder a tu banca en línea desde Wi-Fi público.', o: ['Verdadero', 'Falso'], c: 0, e: 'Las credenciales bancarias pueden ser interceptadas.', d: 1, stage: 1 },

    // Session 11: Dispositivos y contraseñas
    { q: '¿Qué es el bloqueo de pantalla?', o: ['Una función que impide el acceso no autorizado', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'El bloqueo es la primera barrera física.', d: 1, stage: 1 },
    { q: 'Un PIN de 4 dígitos como 1234 es seguro para desbloquear el teléfono.', o: ['Verdadero', 'Falso'], c: 1, e: '1234 es el PIN más predecible del mundo.', d: 1, stage: 1 },

    // Session 12: Redes sociales
    { q: '¿Qué información NO deberías compartir en redes sociales?', o: ['Dirección completa y número de teléfono', 'Fotos de mascotas', 'Opiniones sobre películas', 'Lugar de nacimiento'], c: 0, e: 'La información personal puede ser usada para suplantación.', d: 1, stage: 1 },
    { q: 'Las redes sociales son seguras por defecto.', o: ['Verdadero', 'Falso'], c: 1, e: 'Debes configurar activamente la privacidad.', d: 1, stage: 1 },

    // Session 13: Tiendas en línea
    { q: '¿Cómo verificar si una tienda en línea es legítima?', o: ['Buscar reseñas y verificar dominio', 'Si tiene ofertas buenas', 'Si aparece en Google', 'Si tiene muchos productos'], c: 0, e: 'Las tiendas legítimas tienen presencia verificable.', d: 1, stage: 1 },
    { q: 'Nunca debes ingresar datos bancarios en un sitio sin HTTPS.', o: ['Verdadero', 'Falso'], c: 0, e: 'Sin HTTPS, tus datos viajan en texto plano.', d: 1, stage: 1 },

    // Session 14: Bancos en línea
    { q: '¿Qué es un token de acceso en banca en línea?', o: ['Un código temporal que验证 tu identidad', 'Una contraseña permanente', 'Un tipo de virus', 'Un navegador'], c: 0, e: 'El token genera códigos temporales para mayor seguridad.', d: 2, stage: 1 },
    { q: '¿Qué hacer si ves una transferencia que no reconoces en tu cuenta bancaria?', o: ['Contactar al banco inmediatamente', 'Esperar a ver si se resuelve', 'No hacer nada', 'Cerrar la cuenta'], c: 0, e: 'Actuar rápido es crucial para limitar el daño financiero.', d: 1, stage: 1 },

    // Session 15: Almacenamiento en la nube
    { q: '¿Qué es la nube?', o: ['Servidores remotos que almacenan datos por internet', 'Un tipo de almacenamiento físico', 'Un programa', 'Un navegador'], c: 0, e: 'La nube permite acceder a datos desde cualquier dispositivo.', d: 1, stage: 1 },
    { q: 'Los datos en la nube están siempre seguros sin configuración adicional.', o: ['Verdadero', 'Falso'], c: 1, e: 'Sin cifrado, los datos pueden ser accesados.', d: 1, stage: 1 },

    // Session 16: Actualizaciones
    { q: '¿Por qué es importante actualizar tu dispositivo?', o: ['Las actualizaciones corrigen vulnerabilidades', 'Para tener más apps', 'Para mejorar el diseño', 'No es importante'], c: 0, e: 'Los parches corrigen agujeros de seguridad.', d: 1, stage: 1 },
    { q: 'Ignorar actualizaciones deja tu dispositivo expuesto a ataques conocidos.', o: ['Verdadero', 'Falso'], c: 0, e: 'Las vulnerabilidades sin parchear son objetivo de atacantes.', d: 1, stage: 1 },

    // Session 17: Antivirus
    { q: '¿Qué es un virus informático?', o: ['Software malicioso que se replica y daña el sistema', 'Un programa útil', 'Un tipo de contraseña', 'Un navegador'], c: 0, e: 'Los virus están diseñados para dañar o comprometer sistemas.', d: 1, stage: 1 },
    { q: 'Un antivirus gratuito puede ser tan efectivo como uno de pago.', o: ['Verdadero', 'Falso'], c: 0, e: 'Muchos antivirus gratuitos ofrecen protección sólida.', d: 1, stage: 1 },

    // Session 18: Firewall
    { q: '¿Qué es un firewall?', o: ['Un sistema que bloquea conexiones no autorizadas', 'Un tipo de virus', 'Un navegador', 'Un antivirus'], c: 0, e: 'El firewall actúa como barrera entre tu red y el tráfico no autorizado.', d: 1, stage: 1 },
    { q: '¿Cuáles son los dos tipos principales de firewall?', o: ['Hardware y software', 'Gratuito y de pago', 'Local y en la nube', 'Windows y Mac'], c: 0, e: 'Los firewalls pueden ser dispositivos físicos o programas.', d: 2, stage: 1 },

    // Session 19: Cifrado básico
    { q: '¿Qué es el cifrado de datos?', o: ['Convertir datos en código ilegible sin la clave', 'Comprimir datos', 'Eliminar datos', 'Copiar datos'], c: 0, e: 'El cifrado protege datos para que solo quien tenga la clave pueda leerlos.', d: 1, stage: 1 },
    { q: '¿Qué es el cifrado de extremo a extremo?', o: ['Solo el remitente y receptor pueden leer el mensaje', 'El proveedor puede leerlo', 'Es un tipo de contraseña', 'No existe'], c: 0, e: 'E2EE garantiza que ni el proveedor pueda acceder al contenido.', d: 2, stage: 1 },

    // Session 20: Copias de seguridad
    { q: '¿Qué es una copia de seguridad?', o: ['Una copia de tus datos en caso de pérdida', 'Un tipo de contraseña', 'Un programa', 'Un navegador'], c: 0, e: 'Los backups protegen contra pérdida de datos.', d: 1, stage: 1 },
    { q: '¿Cuál es la regla 3-2-1 de backups?', o: ['3 copias, en 2 medios diferentes, 1 fuera del sitio', '3 dispositivos, 2 contraseñas, 1 usuario', 'No existe'], c: 0, e: 'La regla 3-2-1 es el estándar de protección de datos.', d: 2, stage: 1 },

    // Session 21: Privacidad en línea
    { q: '¿Qué es la huella digital?', o: ['El rastro de datos que dejas al usar internet', 'Una contraseña', 'Un virus', 'Un navegador'], c: 0, e: 'Cada acción en línea deja un rastro que puede ser rastreado.', d: 1, stage: 1 },
    { q: '¿Qué son las cookies de rastreo?', o: ['Archivos que siguen tu actividad entre sitios web', 'Galletas comestibles', 'Contraseñas', 'Archivos de sistema'], c: 0, e: 'Las cookies de rastreo permiten a anunciantes seguir tu navegación.', d: 1, stage: 1 },

    // Session 22: Suplantación de identidad
    { q: '¿Qué es el phishing?', o: ['Técnica para robar información haciéndose pasar por una entidad legítima', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El phishing engaña al usuario para que revele información.', d: 1, stage: 1 },
    { q: '¿Cómo reconocer un intento de phishing?', o: ['Urgencia excesiva, errores ortográficos, remitente sospechoso', 'Si tiene imágenes', 'Si es largo', 'Si viene de un amigo'], c: 0, e: 'Las señales de phishing incluyen urgencia y remitentes falsos.', d: 1, stage: 1 },

    // Session 23: Seguridad en mensajería
    { q: '¿Qué apps de mensajería ofrecen cifrado de extremo a extremo?', o: ['Signal y WhatsApp', 'SMS estándar', 'Correo electrónico', 'Ninguna'], c: 0, e: 'Signal y WhatsApp usan E2EE para proteger las conversaciones.', d: 1, stage: 1 },
    { q: 'Los mensajes de texto (SMS) son cifrados de extremo a extremo.', o: ['Verdadero', 'Falso'], c: 1, e: 'Los SMS viajan en texto plano y pueden ser interceptados.', d: 1, stage: 1 },

    // Session 24: Calendario y recordatorios
    { q: '¿Por qué crear recordatorios de seguridad?', o: ['Para mantener las contraseñas y configuraciones actualizadas', 'No es necesario', 'Solo para empresas', 'Para complicar la vida'], c: 0, e: 'Los recordatorios aseguran que la seguridad no se deje de lado.', d: 1, stage: 1 },

    // Session 25: Testament digital
    { q: '¿Qué es un testament digital?', o: ['Plan para el manejo de cuentas digitales tras tu fallecimiento', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'Permite que tus seres queridos gestionen tus cuentas digitales.', d: 2, stage: 1 },

    // Session 26: Simulacro
    { q: '¿Por qué hacer un simulacro de seguridad personal?', o: ['Para identificar vulnerabilidades en tus cuentas actuales', 'No es necesario', 'Para perder tiempo', 'Para competir con amigos'], c: 0, e: 'Un simulacro revela debilidades que debes corregir.', d: 1, stage: 1 },

    // Session 27: Repaso
    { q: '¿Cuál es el elemento más importante de la seguridad digital?', o: ['La concienciación y los hábitos seguros', 'Solo un antivirus', 'Solo una contraseña fuerte', 'No hay elemento más importante'], c: 0, e: 'La concienciación es la base de todas las demás protecciones.', d: 1, stage: 1 },
  ],

  ac_st2: [
    { q: '¿Por qué actualizar el sistema operativo de tu dispositivo?', o: ['Para corregir vulnerabilidades de seguridad', 'Solo para nuevo diseño', 'No es necesario', 'Para tener más apps'], c: 0, e: 'Las actualizaciones del SO corrigen vulnerabilidades críticas.', d: 1, stage: 2 },
    { q: 'El cifrado completo de disco protege tus datos si te roban el dispositivo.', o: ['Verdadero', 'Falso'], c: 0, e: 'Con disco cifrado, los datos son inaccesibles sin la contraseña.', d: 1, stage: 2 },
    { q: '¿Qué es Play Protect?', o: ['El sistema de seguridad de Google Play', 'Un antivirus de terceros', 'Un navegador', 'Un gestor'], c: 0, e: 'Play Protect escanea apps en busca de malware.', d: 1, stage: 2 },
    { q: '¿Por qué no instalar apps de fuentes no oficiales?', o: ['Pueden contener malware', 'Son más lentas', 'No funcionan', 'Ocupan más espacio'], c: 0, e: 'Las tiendas oficiales revisan las apps.', d: 1, stage: 2 },
    { q: 'Antes de vender un dispositivo, ¿qué debes hacer?', o: ['Borrar todos los datos y desvincular cuentas', 'Solo borrar fotos', 'Darlo con datos intactos', 'Venderlo sin preocupaciones'], c: 0, e: 'El restablecimiento de fábrica elimina tus datos.', d: 1, stage: 2 },
    { q: '¿Qué es WPA3?', o: ['El estándar de seguridad más reciente para Wi-Fi', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'WPA3 ofrece la mejor protección para redes inalámbricas.', d: 2, stage: 2 },
    { q: '¿Qué riesgo tiene el Bluetooth abierto?', o: ['Permite conexiones no autorizadas a tu dispositivo', 'Ninguno', 'Solo consume batería', 'Solo afecta a audífonos'], c: 0, e: 'El Bluetooth puede ser explotado para acceder al dispositivo.', d: 1, stage: 2 },
    { q: '¿Qué es un hotspot personal?', o: ['Compartir tu conexión de datos móviles con otros dispositivos', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El hotspot crea una red Wi-Fi desde tu teléfono.', d: 1, stage: 2 },
    { q: '¿Qué es el restablecimiento de fábrica?', o: ['Borrar todos los datos y volver al estado original del dispositivo', 'Actualizar el software', 'Instalar una app', 'Cambiar la contraseña'], c: 0, e: 'El factory reset elimina todos los datos personales.', d: 1, stage: 2 },
    { q: '¿Qué es un PIN de tarjeta SIM?', o: ['Una contraseña que protege el acceso a tu línea telefónica', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El PIN SIM impide que alguien use tu SIM en otro teléfono.', d: 1, stage: 2 },
    { q: '¿Cuál es la diferencia entre hardware y software de firewall?', o: ['El hardware es un dispositivo físico; el software es un programa', 'No hay diferencia', 'El hardware es más barato', 'El software es más seguro'], c: 0, e: 'Ambos tipos protegen la red pero de formas diferentes.', d: 2, stage: 2 },
    { q: '¿Qué es el cifrado de dispositivos?', o: ['Proteger los datos del dispositivo con una clave de cifrado', 'Actualizar el software', 'Instalar un antivirus', 'Cambiar la contraseña'], c: 0, e: 'El cifrado hace que los datos sean inaccesibles sin la clave.', d: 1, stage: 2 },
    { q: '¿Por qué desactivar Wi-Fi y Bluetooth cuando no los usas?', o: ['Para evitar ataques y ahorrar batería', 'No es necesario', 'Para que el teléfono vaya más rápido', 'Por estética'], c: 0, e: 'Las conexiones inalámbricas activas son vulnerables a explotación.', d: 1, stage: 2 },
    { q: '¿Qué es un dispositivo IoT?', o: ['Un dispositivo conectado a internet como domótica', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los dispositivos IoT incluyen asistentes de voz, cámaras y termostatos inteligentes.', d: 2, stage: 2 },
    { q: '¿Por qué es importante la segmentación de red doméstica?', o: ['Para limitar el acceso de dispositivos IoT y proteger los principales', 'No es importante', 'Para que internet vaya más rápido', 'Para ahorrar dinero'], c: 0, e: 'La segmentación contiene posibles compromisos.', d: 2, stage: 2 },
    { q: '¿Qué es un disco de recuperación?', o: ['Un medio que permite restaurar el sistema operativo', 'Un tipo de backup', 'Un antivirus', 'Un navegador'], c: 0, e: 'El disco de recuperación es esencial para reparar el sistema.', d: 1, stage: 2 },
    { q: '¿Qué es el modo seguro?', o: ['Un modo de arranque con solo los componentes esenciales', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El modo seguro carga solo drivers esenciales para diagnosticar problemas.', d: 2, stage: 2 },
    { q: '¿Por qué usar cuentas de usuario separadas en una computadora compartida?', o: ['Para que cada usuario tenga sus archivos y configuraciones privados', 'No es necesario', 'Para que vaya más rápido', 'Por estética'], c: 0, e: 'Las cuentas separadas protegen la privacidad de cada usuario.', d: 1, stage: 2 },
    { q: '¿Qué es un perfil de invitado?', o: ['Una cuenta temporal con acceso limitado', 'Una cuenta de administrador', 'Un tipo de virus', 'Un navegador'], c: 0, e: 'El perfil de invitado protege los datos del usuario principal.', d: 1, stage: 2 },
    { q: '¿Por qué es importante la limpieza de archivos temporales?', o: ['Libera espacio y puede mejorar el rendimiento', 'No es importante', 'Para que el antivirus funcione', 'Para conectarse a internet'], c: 0, e: 'Los archivos temporales acumulados afectan el rendimiento.', d: 1, stage: 2 },
  ],

  ac_st3: [
    { q: '¿Qué son los datos personales?', o: ['Información que identifica o puede identificar a una persona', 'Solo el nombre', 'Solo el correo', 'Solo la dirección'], c: 0, e: 'Los datos personales incluyen nombre, correo, dirección, teléfono, etc.', d: 1, stage: 3 },
    { q: '¿Qué son los datos sensibles?', o: ['Información sobre salud, origen étnico, religión, orientación sexual', 'Solo el nombre', 'No existen'], c: 0, e: 'Los datos sensibles reciben protección legal especial.', d: 2, stage: 3 },
    { q: '¿Qué es el consentimiento informado?', o: ['Autorización explícita del titular para procesar sus datos', 'Una contraseña', 'Un tipo de encriptación', 'Un contrato'], c: 0, e: 'Debe ser libre, específico e informado.', d: 2, stage: 3 },
    { q: '¿Qué son los derechos ARCO?', o: ['Acceso, Rectificación, Cancelación y Oposición', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'ARCO son los derechos fundamentales del titular de datos.', d: 2, stage: 3 },
    { q: 'Las empresas pueden vender tus datos sin tu permiso.', o: ['Verdadero', 'Falso'], c: 1, e: 'La venta no autorizada viola la ley.', d: 1, stage: 3 },
    { q: '¿Qué es la minimización de datos?', o: ['Recopilar solo los datos necesarios', 'Recopilar todos los datos', 'No recopilar datos', 'Vender datos'], c: 0, e: 'Menos datos = menos riesgo de exposición.', d: 1, stage: 3 },
    { q: '¿Qué es la huella digital?', o: ['El rastro de datos que dejas al usar internet', 'Una contraseña', 'Un virus', 'Un navegador'], c: 0, e: 'Cada acción en línea deja un rastro.', d: 1, stage: 3 },
    { q: '¿Qué son las cookies de rastreo?', o: ['Archivos que siguen tu actividad entre sitios web', 'Galletas comestibles', 'Contraseñas', 'Archivos de sistema'], c: 0, e: 'Las cookies de rastreo permiten a anunciantes seguirte.', d: 1, stage: 3 },
    { q: '¿Qué es el derecho al olvido?', o: ['Tu derecho a solicitar eliminación de tus datos', 'Olvidar contraseñas', 'Borrar historial', 'No tener internet'], c: 0, e: 'El derecho al olvido permite solicitar eliminación de datos.', d: 2, stage: 3 },
    { q: '¿Por qué no compartir tu ubicación en tiempo real en redes sociales?', o: ['Permite que personas malintencionadas te localicen', 'No importa', 'Para no molestar', 'Porque las redes lo prohíben'], c: 0, e: 'La ubicación en tiempo real puede ser explotada por delincuentes.', d: 2, stage: 3 },
    { q: '¿Qué es la portabilidad de datos?', o: ['Tu derecho a exportar datos de un servicio a otro', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'La portabilidad evita el vendor lock-in.', d: 2, stage: 3 },
    { q: '¿Por qué es importante la retención de datos?', o: ['Para no conservar datos más tiempo del necesario', 'Para guardar todo para siempre', 'No es importante', 'Para vender más'], c: 0, e: 'Conservar datos innecesariamente aumenta el riesgo.', d: 2, stage: 3 },
    { q: '¿Qué es el reconocimiento facial y por qué es riesgoso?', o: ['Identifica personas por su rostro; puede usarse para vigilancia', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'El reconocimiento facial puede ser usado sin consentimiento.', d: 2, stage: 3 },
    { q: '¿Qué es un deepfake?', o: ['Contenido audiovisual sintético que parece real pero es falso', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los deepfakes pueden usarse para desinformación.', d: 2, stage: 3 },
    { q: '¿Por qué los datos de menores requieren protección especial?', o: ['Porque son más vulnerables y no pueden consentir', 'No requieren', 'Solo en Europa', 'No es importante'], c: 0, e: 'Los menores no tienen la madurez para entender consecuencias.', d: 1, stage: 3 },
    { q: '¿Qué es COPPA?', o: ['Ley de protección de privacidad de niños en EE.UU.', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'COPPA restringe recopilación de datos de menores de 13 años.', d: 2, stage: 3 },
    { q: '¿Qué es la navegación anónima?', o: ['Navegar sin que tu identidad quede registrada', 'Navegar sin internet', 'Navegar sin contraseña', 'Navegar sin navegador'], c: 0, e: 'Herramientas como Tor permiten navegar de forma más anónima.', d: 1, stage: 3 },
    { q: '¿Qué es la configuración de privacidad en redes sociales?', o: ['Opciones que controlan quién puede ver tu información', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'Configurar la privacidad limita quién accede a tu información.', d: 1, stage: 3 },
    { q: '¿Por qué es importante la transparencia de datos?', o: ['Para que sepas qué datos recopilan y cómo los usan', 'No es importante', 'Para complicar las cosas', 'Solo para empresas'], c: 0, e: 'La transparencia es un principio fundamental de protección de datos.', d: 1, stage: 3 },
  ],

  ac_st4: [
    { q: '¿Qué es el phishing avanzado?', o: ['Técnicas sofisticadas de suplantación de identidad en línea', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El phishing avanzado usa personalización y técnicas elaboradas.', d: 1, stage: 4 },
    { q: '¿Qué es el spear phishing?', o: ['Phishing dirigido a una persona específica usando información personal', 'Phishing masivo', 'Phishing por SMS', 'Phishing en redes sociales'], c: 0, e: 'El spear phishing personaliza el ataque.', d: 2, stage: 4 },
    { q: '¿Qué es el whaling?', o: ['Phishing dirigido a ejecutivos y altos cargos', 'Phishing masivo', 'Phishing por SMS', 'Phishing en redes sociales'], c: 0, e: 'El whaling apunta a objetivos de alto valor.', d: 2, stage: 4 },
    { q: '¿Qué es el malware?', o: ['Software malicioso diseñado para dañar o comprometer sistemas', 'Un tipo de antivirus', 'Un navegador', 'Una contraseña'], c: 0, e: 'Malware es el término paraguas para todo software malicioso.', d: 1, stage: 4 },
    { q: '¿Qué es el ransomware?', o: ['Malware que cifra archivos y exige rescate', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El ransomware bloquea datos hasta que se pague.', d: 1, stage: 4 },
    { q: '¿Qué es la ingeniería social?', o: ['Manipular personas para obtener información confidencial', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'La ingeniería social explota la confianza humana.', d: 1, stage: 4 },
    { q: '¿Qué es el spoofing?', o: ['Suplantación de identidad en sitios web o correos', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El spoofing crea sitios o correos falsos que parecen legítimos.', d: 2, stage: 4 },
    { q: '¿Por qué las redes sociales son un vector de ataque?', o: ['Porque la información pública facilita la ingeniería social', 'No son un vector', 'Solo para empresas', 'No es importante'], c: 0, e: 'La información pública se usa para personalizar ataques.', d: 1, stage: 4 },
    { q: '¿Qué es el ciberbullying?', o: ['Acoso a través de medios digitales', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El ciberbullying usa tecnología para acosar y amenazar.', d: 1, stage: 4 },
    { q: '¿Cómo verificar una tienda en línea legítima?', o: ['Buscar reseñas, verificar dominio y política de privacidad', 'Si tiene ofertas buenas', 'Si aparece en Google', 'Si tiene muchos productos'], c: 0, e: 'Las tiendas legítimas tienen presencia verificable.', d: 1, stage: 4 },
    { q: '¿Qué es una VPN?', o: ['Una red privada virtual que cifra tu conexión', 'Un tipo de Wi-Fi', 'Un antivirus', 'Un navegador'], c: 0, e: 'La VPN crea un túnel cifrado para tu tráfico.', d: 1, stage: 4 },
    { q: '¿Qué es el Business Email Compromise?', o: ['Suplantación de correos corporativos para estafar', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'BEC es una estafa que suplanta a ejecutivos para transferencias.', d: 2, stage: 4 },
    { q: '¿Por qué es importante reportar intentos de phishing?', o: ['Para proteger a otros usuarios y ayudar a detener la amenaza', 'No es importante', 'Solo para empresas', 'Para que te paguen'], c: 0, e: 'Reportar ayuda a proteger a la comunidad.', d: 1, stage: 4 },
    { q: '¿Qué es un deepfake y cómo se usa en ataques?', o: ['Contenido sintético para suplantación y desinformación', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los deepfakes pueden suplantar voces y rostros.', d: 2, stage: 4 },
    { q: '¿Qué es la seguridad en el trabajo remoto?', o: ['Proteger datos y sistemas al trabajar desde casa', 'No existe', 'Solo para empresas', 'No es importante'], c: 0, e: 'El trabajo remoto presenta desafíos únicos de seguridad.', d: 1, stage: 4 },
    { q: '¿Qué es el cifrado de extremo a extremo?', o: ['Solo el remitente y receptor pueden leer el mensaje', 'El proveedor puede leerlo', 'Es un tipo de contraseña', 'No existe'], c: 0, e: 'E2EE garantiza privacidad total.', d: 2, stage: 4 },
    { q: '¿Por qué usar VPN en Wi-Fi público?', o: ['Para proteger tu tráfico de la interceptación', 'No es necesario', 'Para que internet vaya más rápido', 'Para ahorrar datos'], c: 0, e: 'La VPN cifra tu conexión en redes no seguras.', d: 1, stage: 4 },
    { q: '¿Qué es el modo privado del navegador?', o: ['No guarda historial local, pero no oculta tu actividad al proveedor', 'Te hace invisible', 'Borra todo permanentemente', 'Te protege de malware'], c: 0, e: 'El modo privado tiene limitaciones importantes.', d: 1, stage: 4 },
    { q: '¿Qué es la denuncia de ciberdelitos en Perú?', o: ['Reportar delitos informáticos ante la INCIBI o policía', 'No se puede denunciar', 'Solo en España', 'No es necesario'], c: 0, e: 'La INCIBI y la policía nacional reciben denuncias de ciberdelitos.', d: 2, stage: 4 },
    { q: '¿Qué son las amenazas emergentes en ciberseguridad?', o: ['Nuevas técnicas de ataque que aparecen constantemente', 'No existen', 'Solo son teoría', 'No son relevantes'], c: 0, e: 'Las amenazas evolucionan continuamente, requiriendo actualización.', d: 1, stage: 4 },
  ],

  ac_st5: [
    { q: '¿Cuál es la amenaza más común en dispositivos móviles?', o: ['Apps maliciosas y phishing por SMS', 'Falta de batería', 'Pantalla rota', 'Sin conexión'], c: 0, e: 'El malware móvil y smishing son las amenazas más frecuentes.', d: 1, stage: 5 },
    { q: 'Google Play Protect escanea tu teléfono en busca de malware.', o: ['Verdadero', 'Falso'], c: 0, e: 'Play Protect es el escáner de seguridad integrado.', d: 1, stage: 5 },
    { q: '¿Qué es el SIM swapping?', o: ['Robo de tu número para interceptar códigos 2FA', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El SIM swapping permite recibir tus códigos de verificación.', d: 2, stage: 5 },
    { q: '¿Cuál es la forma segura de hacer pagos con el teléfono?', o: ['Usar Google Pay o Apple Pay con biometría', 'Enviar dinero por WhatsApp', 'Compartir datos por mensaje'], c: 0, e: 'Las billeteras virtuales usan tokenización.', d: 1, stage: 5 },
    { q: 'Las fotos con metadatos GPS pueden revelar tu ubicación exacta.', o: ['Verdadero', 'Falso'], c: 0, e: 'Los metadatos EXIF incluyen coordenadas GPS.', d: 1, stage: 5 },
    { q: '¿Por qué configurar el PIN de la tarjeta SIM?', o: ['Para evitar que usen tu SIM en otro teléfono', 'No es necesario', 'Para que el teléfono vaya más rápido', 'Por estética'], c: 0, e: 'El PIN SIM protege contra robo de número.', d: 1, stage: 5 },
    { q: '¿Qué es la carpeta segura en los teléfonos?', o: ['Un espacio cifrado para archivos sensibles', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'La carpeta segura aísla archivos sensibles.', d: 1, stage: 5 },
    { q: '¿Por qué desactivar Bluetooth cuando no lo usas?', o: ['Para evitar ataques y ahorrar batería', 'No es necesario', 'Para que vaya más rápido', 'Por estética'], c: 0, e: 'El Bluetooth activo puede ser explotado.', d: 1, stage: 5 },
    { q: '¿Qué es el sideloading?', o: ['Instalar apps de fuentes no oficiales', 'Actualizar el teléfono', 'Usar Wi-Fi', 'Configurar contraseñas'], c: 0, e: 'El sideloading instala apps sin verificación de la tienda oficial.', d: 1, stage: 5 },
    { q: '¿Por qué es importante actualizar tu teléfono?', o: ['Las actualizaciones corrigen vulnerabilidades', 'Para tener nuevos emojis', 'No es necesario', 'Para que vaya más rápido'], c: 0, e: 'Los parches del SO corrigen vulnerabilidades críticas.', d: 1, stage: 5 },
    { q: '¿Qué es el control parental en dispositivos móviles?', o: ['Herramientas para supervisar la actividad de menores', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'El control parental filtra contenido y limita tiempo.', d: 1, stage: 5 },
    { q: '¿Qué es un wearable y qué riesgos tiene?', o: ['Dispositivo vestible que recopila datos de salud y actividad', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los wearables recopilan datos personales sensibles.', d: 2, stage: 5 },
    { q: '¿Por qué usar solo tiendas oficiales para descargar apps?', o: ['Las oficiales revisan las apps antes de publicarlas', 'No es necesario', 'Para que vaya más rápido', 'Por estética'], c: 0, e: 'Las tiendas oficiales ofrecen mayor seguridad.', d: 1, stage: 5 },
    { q: '¿Qué es el roaming y cómo afecta la seguridad?', o: ['Conexión a redes extranjeras que puede ser menos segura', 'No afecta', 'Solo cuesta dinero', 'No es relevante'], c: 0, e: 'Las redes de roaming pueden tener configuraciones menos seguras.', d: 2, stage: 5 },
    { q: '¿Por qué no guardar contraseñas en el navegador del teléfono?', o: ['El navegador puede ser vulnerable al robo del dispositivo', 'No es necesario', 'Para que vaya más rápido', 'Por estética'], c: 0, e: 'Los navegadores móviles tienen menor protección que gestores dedicados.', d: 1, stage: 5 },
    { q: '¿Qué es el cifrado de dispositivos móviles?', o: ['Proteger los datos con una clave de cifrado en el teléfono', 'Actualizar el software', 'Instalar un antivirus', 'Cambiar la contraseña'], c: 0, e: 'El cifrado hace los datos inaccesibles sin la clave.', d: 1, stage: 5 },
    { q: '¿Por qué usar VPN en el teléfono?', o: ['Para proteger tu conexión en redes públicas', 'No es necesario', 'Para que internet vaya más rápido', 'Para ahorrar datos'], c: 0, e: 'La VPN cifra tu tráfico en Wi-Fi público.', d: 1, stage: 5 },
    { q: '¿Qué es la sincronización segura entre dispositivos?', o: ['Transferir datos entre dispositivos de forma cifrada', 'Copiar datos sin cifrar', 'No sincronizar nada', 'Compartir por Wi-Fi'], c: 0, e: 'La sincronización segura protege datos en tránsito.', d: 1, stage: 5 },
    { q: '¿Por qué revisar permisos de apps después de instalarlas?', o: ['Algunas apps piden permisos innecesarios', 'No es necesario', 'Para que vaya más rápido', 'Por estética'], c: 0, e: 'Los permisos excesivos comprometen la privacidad.', d: 1, stage: 5 },
    { q: '¿Qué es la localización del dispositivo y cómo configurarla?', o: ['Servicio que permite encontrar el teléfono perdido', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'La localización permite encontrar y bloquear el teléfono remotamente.', d: 1, stage: 5 },
  ],

  ac_st6: [
    { q: '¿Qué es la ciberseguridad empresarial?', o: ['La protección de sistemas y datos de una organización', 'Un tipo de antivirus', 'Un navegador', 'Una contraseña'], c: 0, e: 'Incluye políticas, procesos y tecnologías para proteger activos.', d: 1, stage: 6 },
    { q: '¿Por qué las pymes son objetivo de ciberataques?', o: ['Suelen tener menos protección que grandes empresas', 'No son objetivo', 'Tienen mejor seguridad'], c: 0, e: 'Las pymes carecen de recursos de seguridad dedicados.', d: 1, stage: 6 },
    { q: '¿Qué es el principio de mínimo privilegio?', o: ['Dar solo el acceso necesario para realizar una tarea', 'Dar acceso total', 'No dar acceso', 'Compartir contraseñas'], c: 0, e: 'Limitar accesos reduce el daño en caso de compromiso.', d: 2, stage: 6 },
    { q: '¿Qué es BYOD?', o: ['Traer tu propio dispositivo al trabajo', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'BYOD permite usar dispositivos personales en el trabajo.', d: 1, stage: 6 },
    { q: '¿Qué es un plan de respuesta a incidentes?', o: ['Pasos predefinidos para manejar brechas de seguridad', 'Un tipo de antivirus', 'Un navegador', 'Una contraseña'], c: 0, e: 'Un plan claro minimiza el tiempo de respuesta.', d: 2, stage: 6 },
    { q: '¿Qué es la segmentación de red?', o: ['Dividir la red para limitar el movimiento de atacantes', 'No es importante', 'Para que internet vaya más rápido', 'Para ahorrar dinero'], c: 0, e: 'La segmentación contiene el impacto de un compromiso.', d: 2, stage: 6 },
    { q: '¿Qué es el cumplimiento normativo?', o: ['Cumplir leyes y regulaciones de protección de datos', 'No tener regulaciones', 'Solo para empresas grandes'], c: 0, e: 'El cumplimiento evita sanciones y protege la reputación.', d: 1, stage: 6 },
    { q: '¿Qué es ISO 27001?', o: ['Estándar internacional de gestión de seguridad', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'ISO 27001 certifica la gestión adecuada de seguridad.', d: 2, stage: 6 },
    { q: '¿Qué es una auditoría de seguridad?', o: ['Evaluación sistemática de la seguridad de una organización', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Las auditorías identifican debilidades y verifican cumplimiento.', d: 1, stage: 6 },
    { q: '¿Por qué es importante la capacitación en seguridad?', o: ['La concienciación del personal es la primera línea de defensa', 'No es importante', 'Solo para empresas grandes', 'Para complicar la vida'], c: 0, e: 'El error humano causa la mayoría de incidentes.', d: 1, stage: 6 },
    { q: '¿Qué es el Business Email Compromise?', o: ['Suplantación de correos corporativos para estafar', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'BEC suplanta ejecutivos para transferencias fraudulentas.', d: 2, stage: 6 },
    { q: '¿Qué es un incidente de seguridad?', o: ['Evento que compromete confidencialidad, integridad o disponibilidad', 'Una actualización', 'Un cambio de contraseña', 'Una copia de seguridad'], c: 0, e: 'Los incidentes incluyen filtraciones, malware y accesos no autorizados.', d: 1, stage: 6 },
    { q: '¿Por qué las auditorías de seguridad deben ser periódicas?', o: ['Para mantener la seguridad actualizada ante nuevas amenazas', 'No es necesario', 'Solo una vez', 'Para complicar la vida'], c: 0, e: 'La regularidad asegura que la seguridad se mantiene efectiva.', d: 1, stage: 6 },
    { q: '¿Qué es la gestión de vulnerabilidades?', o: ['Identificar, evaluar y corregir debilidades en sistemas', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La gestión proactiva previene exploits.', d: 2, stage: 6 },
    { q: '¿Qué es la continuidad del negocio?', o: ['Capacidad de mantener operaciones críticas durante incidentes', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La continuidad minimiza el impacto de interrupciones.', d: 2, stage: 6 },
    { q: '¿Por qué es importante la gestión de terceros?', o: ['Los proveedores pueden ser puntos débiles en la cadena de seguridad', 'No es importante', 'Solo para empresas grandes'], c: 0, e: 'Un compromise de proveedor afecta a todos sus clientes.', d: 2, stage: 6 },
    { q: '¿Qué es Zero Trust en seguridad empresarial?', o: ['No confiar en ningún usuario o dispositivo por defecto', 'Confiar en todos', 'No usar internet'], c: 0, e: 'Zero Trust verifica cada acceso, sin importar origen.', d: 2, stage: 6 },
    { q: '¿Por qué documentar las políticas de seguridad?', o: ['Para demostrar cumplimiento y guiar al personal', 'No es necesario', 'Para complicar la vida'], c: 0, e: 'La documentación es esencial para auditorías y capacitación.', d: 1, stage: 6 },
    { q: '¿Qué es la gestión de riesgos en seguridad?', o: ['Identificar, evaluar y mitigar riesgos de seguridad', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La gestión de riesgos prioriza las protecciones más efectivas.', d: 2, stage: 6 },
    { q: '¿Por qué es importante el offboarding seguro?', o: ['Para evitar que ex empleados accedan a sistemas', 'No es importante', 'Solo para empresas grandes'], c: 0, e: 'El offboarding previene accesos no autorizados post-empleo.', d: 1, stage: 6 },
  ],

  ac_st7: [
    { q: '¿Qué es un APT?', o: ['Ataque sofisticado y sostenido de larga duración', 'Un tipo de virus simple', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los APT son ataques por actores estatales o grupos organizados.', d: 2, stage: 7 },
    { q: '¿Qué es el ransomware como servicio (RaaS)?', o: ['Modelo donde se alquila ransomware a otros criminals', 'Un servicio de respaldo', 'Un antivirus', 'Un navegador'], c: 0, e: 'RaaS democratiza el ransomware.', d: 2, stage: 7 },
    { q: 'La doble extorsión significa amenazar con publicar datos además de cifrar.', o: ['Verdadero', 'Falso'], c: 0, e: 'La doble extorsión aumenta la presión para pagar.', d: 2, stage: 7 },
    { q: '¿Qué es un ataque a la cadena de suministro?', o: ['Comprometer un proveedor para acceder a sus clientes', 'Un ataque físico', 'Un tipo de virus', 'Un navegador'], c: 0, e: 'El ataque SolarWinds es un ejemplo famoso.', d: 2, stage: 7 },
    { q: '¿Qué es un zero-day?', o: ['Vulnerabilidad explotada antes de que exista un parche', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los zero-day son peligrosos porque no hay defensa conocida.', d: 2, stage: 7 },
    { q: '¿Qué es el cryptojacking?', o: ['Uso no autorizado de tu dispositivo para minar criptomonedas', 'Un tipo de ransomware', 'Un antivirus', 'Un navegador'], c: 0, e: 'El cryptojacking roba recursos de tu dispositivo.', d: 2, stage: 7 },
    { q: '¿Qué es MITRE ATT&CK?', o: ['Marco de conocimiento sobre tácticas y técnicas de ataque', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'MITRE ATT&CK cataloga técnicas usadas por atacantes reales.', d: 2, stage: 7 },
    { q: '¿Por qué las criptomonedas son populares entre ciberdelincuentes?', o: ['Permiten pagos anónimos difíciles de rastrear', 'Son más rápidas', 'Son gratuitas', 'No tienen valor'], c: 0, e: 'La pseudo-anonimización facilita el lavado de dinero.', d: 2, stage: 7 },
    { q: '¿Qué es el hacking ético?', o: ['Probar la seguridad con autorización del propietario', 'Hackear sin permiso', 'Un tipo de virus', 'Un navegador'], c: 0, e: 'El hacking ético busca mejorar la seguridad.', d: 1, stage: 7 },
    { q: '¿Qué es un pentest?', o: ['Prueba de penetración autorizada para identificar vulnerabilidades', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los pentests simulan ataques reales.', d: 2, stage: 7 },
    { q: '¿Qué es la cadena de custodia?', o: ['Proceso para mantener integridad de evidencia digital', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'La evidencia debe preservarse correctamente.', d: 2, stage: 7 },
    { q: '¿Qué es el análisis forense digital?', o: ['Examen de dispositivos para encontrar evidencia', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El análisis forense determina qué pasó y qué datos fueron afectados.', d: 2, stage: 7 },
    { q: '¿Qué es la contención en respuesta a incidentes?', o: ['Detener el spread del incidente antes de erradicar', 'Pagar al atacante', 'Borrar todo', 'Ignorar'], c: 0, e: 'La contención minimiza el daño antes de la recuperación.', d: 2, stage: 7 },
    { q: '¿Por qué son importantes las lecciones aprendidas?', o: ['Permiten mejorar procesos y prevenir futuros incidentes', 'No son importantes', 'Solo para historial'], c: 0, e: 'Cada incidente es una oportunidad de mejora.', d: 1, stage: 7 },
    { q: '¿Qué es un simulacro de incidentes?', o: ['Práctica simulada para probar la preparación del equipo', 'Un ataque real', 'Un tipo de virus', 'Un navegador'], c: 0, e: 'Los simulacros identifican debilidades sin daño real.', d: 1, stage: 7 },
    { q: '¿Qué es la inteligencia de amenazas?', o: ['Información proactiva sobre amenazas potenciales', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La inteligencia permite anticipar amenazas.', d: 2, stage: 7 },
    { q: '¿Qué es un IOC?', o: ['Indicador de Compromiso que señala actividad maliciosa', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los IOCs incluyen hashes, IPs y dominios maliciosos.', d: 2, stage: 7 },
    { q: '¿Por qué la defensa en capas es importante?', o: ['Si una capa falla, las demás siguen protegiendo', 'No es importante', 'Solo una capa es suficiente'], c: 0, e: 'Ninguna defensa es perfecta; las capas compensan debilidades.', d: 2, stage: 7 },
    { q: '¿Qué es el software de cazarrecompensas?', o: ['Programa que recompensa por descubrimiento de vulnerabilidades', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los bug bounty programs incentivan la mejora de seguridad.', d: 2, stage: 7 },
    { q: '¿Qué es la microsegmentación?', o: ['Dividir la red en segmentos pequeños para limitar movimiento', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'La microsegmentación contiene compromisos.', d: 2, stage: 7 },
  ],

  ac_st8: [
    { q: '¿Cuál es la contraseña más segura?', o: ['Combinación de letras, números y símbolos con más de 12 caracteres', 'Solo números', 'Solo letras', 'Una palabra común'], c: 0, e: 'La complejidad y longitud son clave.', d: 1, stage: 8 },
    { q: '¿Qué es la verificación en dos pasos?', o: ['Método que requiere dos factores para acceder', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'La 2FA añade una segunda capa de seguridad.', d: 1, stage: 8 },
    { q: '¿Qué es el phishing?', o: ['Técnica para robar información haciéndose pasar por entidad legítima', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El phishing engaña para revelar información.', d: 1, stage: 8 },
    { q: '¿Por qué actualizar el sistema operativo?', o: ['Para corregir vulnerabilidades de seguridad', 'Solo para nuevo diseño', 'No es necesario'], c: 0, e: 'Las actualizaciones corrigen agujeros de seguridad.', d: 1, stage: 8 },
    { q: '¿Qué es el cifrado de datos?', o: ['Convertir datos en código ilegible sin la clave', 'Comprimir datos', 'Eliminar datos', 'Copiar datos'], c: 0, e: 'El cifrado protege datos.', d: 1, stage: 8 },
    { q: '¿Qué es una VPN?', o: ['Red privada virtual que cifra tu conexión', 'Un tipo de Wi-Fi', 'Un antivirus', 'Un navegador'], c: 0, e: 'La VPN crea un túnel cifrado.', d: 1, stage: 8 },
    { q: '¿Qué es un backup?', o: ['Copia de tus datos en caso de pérdida', 'Un tipo de contraseña', 'Un programa', 'Un navegador'], c: 0, e: 'Los backups protegen contra pérdida de datos.', d: 1, stage: 8 },
    { q: '¿Qué es el ransomware?', o: ['Malware que cifra archivos y exige rescate', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El ransomware bloquea datos.', d: 1, stage: 8 },
    { q: '¿Qué son los derechos ARCO?', o: ['Acceso, Rectificación, Cancelación y Oposición', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'ARCO son derechos fundamentales del titular.', d: 2, stage: 8 },
    { q: '¿Qué es el principio de mínimo privilegio?', o: ['Dar solo el acceso necesario', 'Dar acceso total', 'No dar acceso', 'Compartir contraseñas'], c: 0, e: 'Limitar accesos reduce riesgos.', d: 2, stage: 8 },
    { q: '¿Qué es un plan de respuesta a incidentes?', o: ['Pasos predefinidos para manejar brechas', 'Un tipo de antivirus', 'Un navegador', 'Una contraseña'], c: 0, e: 'Un plan claro minimiza el daño.', d: 2, stage: 8 },
    { q: '¿Qué es el cumplimiento normativo?', o: ['Cumplir leyes de protección de datos', 'No tener regulaciones', 'Solo para empresas grandes'], c: 0, e: 'El cumplimiento evita sanciones.', d: 1, stage: 8 },
    { q: '¿Qué es un pentest?', o: ['Prueba de penetración autorizada', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'Los pentests identifican vulnerabilidades.', d: 2, stage: 8 },
    { q: '¿Qué es la inteligencia de amenazas?', o: ['Información proactiva sobre amenazas', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La inteligencia permite anticipar ataques.', d: 2, stage: 8 },
    { q: '¿Qué es Zero Trust?', o: ['No confiar en ningún usuario por defecto', 'Confiar en todos', 'No usar internet'], c: 0, e: 'Zero Trust verifica cada acceso.', d: 2, stage: 8 },
    { q: '¿Por qué la concienciación es importante?', o: ['El error humano causa la mayoría de incidentes', 'No es importante', 'Solo para empresas'], c: 0, e: 'La educación es la primera línea de defensa.', d: 1, stage: 8 },
    { q: '¿Qué es el modelo de responsabilidad compartida en la nube?', o: ['El proveedor protege la nube; el cliente sus datos', 'Todo es del proveedor', 'Todo es del cliente', 'No existe'], c: 0, e: 'Ambos comparten la responsabilidad.', d: 2, stage: 8 },
    { q: '¿Qué es la cadena de custodia?', o: ['Proceso para mantener integridad de evidencia', 'Un tipo de contraseña', 'Un antivirus', 'Un navegador'], c: 0, e: 'La evidencia debe preservarse correctamente.', d: 2, stage: 8 },
    { q: '¿Qué es el análisis forense?', o: ['Examen de dispositivos para encontrar evidencia', 'Un tipo de virus', 'Un antivirus', 'Un navegador'], c: 0, e: 'El forense determina qué pasó.', d: 2, stage: 8 },
    { q: '¿Qué es la continuidad del negocio?', o: ['Mantener operaciones críticas durante incidentes', 'No existe', 'Solo para empresas grandes'], c: 0, e: 'La continuidad minimiza interrupciones.', d: 2, stage: 8 },
  ],
};
