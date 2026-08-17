// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get aboutSage => 'Sobre Sage';

  @override
  String get aboutSection => 'Acerca de';

  @override
  String get achievementConqueror => 'Conquistador';

  @override
  String get achievementConquerorDesc => 'Completa tu primera etapa';

  @override
  String get achievementConstant => 'Constante';

  @override
  String get achievementConstantDesc => 'Racha de 3 días';

  @override
  String get achievementCurious => 'Curioso';

  @override
  String get achievementCuriousDesc => 'Habla con Sage 10 veces';

  @override
  String get achievementCyberGuardian => 'Guardián Cibernético';

  @override
  String get achievementCyberGuardianDesc => 'Completa 50 lecciones';

  @override
  String get achievementDigitalMaster => 'Maestro Digital';

  @override
  String get achievementDigitalMasterDesc => 'Completa todas las etapas';

  @override
  String get achievementDigitalStudent => 'Estudiante Digital';

  @override
  String get achievementDigitalStudentDesc => 'Completa 10 lecciones';

  @override
  String get achievementDigitalWeek => 'Semana Digital';

  @override
  String get achievementDigitalWeekDesc => 'Racha de 7 días';

  @override
  String get achievementFirstShield => 'Primer Escudo';

  @override
  String get achievementFirstShieldDesc => 'Completa tu primera lección';

  @override
  String get achievementGuardian => 'Guardián';

  @override
  String get achievementGuardianDesc => 'Completa 25 lecciones';

  @override
  String get achievementLearner => 'Aprendiz';

  @override
  String get achievementLearnerDesc => 'Completa 5 lecciones';

  @override
  String get achievementLegendaryStreak => 'Racha Legendaria';

  @override
  String get achievementLegendaryStreakDesc => 'Racha de 30 días';

  @override
  String get achievementLocked => '???';

  @override
  String get achievementPerfect => 'Perfecto';

  @override
  String get achievementPerfectDesc => 'Completa una lección sin errores';

  @override
  String get acquired => 'Obtenido';

  @override
  String get adminCreditDonationA11y => 'Acreditar Donaciones';

  @override
  String get adminCreditDonationButton => 'Acreditar Donaciones';

  @override
  String adminCreditDonationSuccess(Object gems, Object userId) {
    return '$gems donaciones acreditadas a $userId';
  }

  @override
  String get adminCreditDonationTitle => 'Admin — Acreditar Donaciones';

  @override
  String get adminCreditError =>
      'Error al acreditar. Verifica que tu usuario esté en la colección \"admins\" de Firestore.';

  @override
  String adminCreditSuccessNotification(Object gems, Object userId) {
    return '$gems donaciones acreditadas a $userId';
  }

  @override
  String get adminDonations => 'Donaciones';

  @override
  String get adminFieldAmount => 'Monto';

  @override
  String get adminFieldDonationAmount => 'Monto de donación';

  @override
  String get adminFieldUserId => 'User ID';

  @override
  String get adminInvalidInput => 'Ingresa un User ID válido y monto';

  @override
  String get adminMercadoPago => 'Mercado Pago';

  @override
  String get adminPaymentMethod => 'Método de pago';

  @override
  String get adminTitle => 'Admin — Donaciones de Crédito';

  @override
  String get adminUserId => 'ID de usuario';

  @override
  String get adminVerifyingPermissions =>
      'Verificando permisos de administrador…';

  @override
  String get adminWhatsapp => 'WhatsApp / Yape / Plin';

  @override
  String get analyzeFile => 'Analizar archivo';

  @override
  String get analyzeLink => 'Analizar enlace';

  @override
  String get analyzing => 'Analizando...';

  @override
  String get appName => 'SAGEN';

  @override
  String get appSlogan => 'Tu escudo digital';

  @override
  String get authAge => 'Edad';

  @override
  String get authBack => 'Volver';

  @override
  String get authCanceled => 'Inicio de sesión cancelado';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateAccountError => 'Error al crear cuenta';

  @override
  String get authCredentialExpired =>
      'La sesión ha expirado. Por favor, inicia sesión de nuevo.';

  @override
  String get authDefault => 'Error de autenticación';

  @override
  String get authDeleteAccountFailed =>
      'No se pudo eliminar la cuenta. Intenta de nuevo.';

  @override
  String get authEmailError => 'Ingresa tu correo';

  @override
  String get authEmailInUse => 'Ya existe una cuenta con este correo';

  @override
  String get authEmailInvalid => 'Correo electrónico inválido';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailVerificationSent =>
      'Revisa tu correo para verificar tu cuenta';

  @override
  String get authEnterEmailError => 'Ingresa tu correo electrónico';

  @override
  String get authFacebookButton => 'Continuar con Facebook';

  @override
  String get authFacebookError => 'Error al iniciar sesión con Facebook';

  @override
  String get authFirebaseUnavailable => 'Firebase no está disponible';

  @override
  String get authForgotPasswordButton => 'RESTABLECER CONTRASEÑA';

  @override
  String get authForgotPasswordDesc =>
      'Te enviaremos un enlace a tu correo para restablecer tu contraseña.';

  @override
  String get authForgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get authFullName => 'Nombre completo';

  @override
  String get authGoogleButton => 'Continuar con Google';

  @override
  String get authGoogleError => 'Error al iniciar sesión con Google';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get authInvalidCredential => 'Correo o contraseña incorrectos';

  @override
  String get authInvalidEmail => 'El formato del correo no es válido';

  @override
  String get authLoginButton => 'INGRESAR';

  @override
  String get authLoginError => 'Error al iniciar sesión';

  @override
  String get authLoginLink => 'Iniciar sesión';

  @override
  String get authLoginTitle => 'Ingresa tus datos';

  @override
  String get authNameError => 'Ingresa tu nombre';

  @override
  String get authNetworkError => 'Sin conexión a internet';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authNotAuthenticated => 'No hay usuario autenticado';

  @override
  String get authNotFound => 'No hay cuenta registrada con este correo';

  @override
  String get authNotFoundCancel => 'Cancelar';

  @override
  String get authNotFoundCreate => 'Crear cuenta';

  @override
  String authNotFoundMessage(Object email) {
    return 'No hay una cuenta registrada con $email. ¿Desea crear una nueva cuenta y empezar a aprender?';
  }

  @override
  String get authNotFoundTitle => 'Cuenta no encontrada';

  @override
  String get authNotVerified =>
      'Aún no has verificado tu correo. Revisa tu bandeja de entrada.';

  @override
  String get authNullToken => 'No se pudo obtener el token de Facebook';

  @override
  String get authNullUser => 'No se pudo obtener el usuario';

  @override
  String get authOrRegisterWith => 'o regístrate con';

  @override
  String get authPasswordError => 'Ingresa tu contraseña';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authPasswordMinError =>
      'La contraseña debe tener 8+ caracteres con mayúscula, minúscula y un número';

  @override
  String get authPasswordMinHint => 'Contraseña (8+ chars, A-Z, a-z, 0-9)';

  @override
  String get authPasswordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get authPrivacy => 'Tu información está protegida.';

  @override
  String get authRateLimited => 'Demasiados intentos. Espera unos segundos.';

  @override
  String get authReauthError =>
      'No se pudo verificar las credenciales. Intenta de nuevo.';

  @override
  String get authReauthRequiredForDelete =>
      'Ingresa tu contraseña para eliminar tu cuenta.';

  @override
  String get authRecoveryEmailSentDesc =>
      'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.';

  @override
  String get authRecoveryEmailSentMessage => 'Correo de recuperación enviado';

  @override
  String get authRecoveryEmailSentTitle => 'Correo enviado';

  @override
  String get authRecoveryError => 'No se pudo enviar el correo de recuperación';

  @override
  String get authRegisterFacebookError => 'Error al registrarse con Facebook';

  @override
  String get authRegisterGoogleError => 'Error al registrarse con Google';

  @override
  String get authRegisterTitle => 'Crea tu cuenta';

  @override
  String get authResendEmailError =>
      'No se pudo reenviar el correo de verificación';

  @override
  String get authSendEmailError => 'Error al enviar correo';

  @override
  String get authSendLink => 'Enviar enlace';

  @override
  String get authSubtitle =>
      'Aprende, protégete y navega internet de forma más segura.';

  @override
  String get authTitle => 'Tu protección digital comienza aquí';

  @override
  String get authTokenExpired =>
      'Sesión expirada. Por favor, inicia sesión de nuevo.';

  @override
  String get authTooManyRequests => 'Demasiados intentos. Espera un momento.';

  @override
  String get authUnknown => 'Ocurrió un error inesperado';

  @override
  String get authVerifyError => 'No se pudo verificar. Intenta de nuevo.';

  @override
  String get authWeakPassword =>
      'La contraseña debe tener al menos 6 caracteres';

  @override
  String get authWrongPassword => 'Contraseña incorrecta';

  @override
  String get back => 'Volver';

  @override
  String get backButton => 'Atrás';

  @override
  String get biometricPrompt => 'Desbloquea SAGEN para continuar';

  @override
  String get biometricReason => 'Desbloquea SAGEN para continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get careerCertifications => 'Certificaciones';

  @override
  String get careerDescription =>
      'Obtén certificaciones y desarrolla habilidades que te hacen valioso en la economía digital.';

  @override
  String get careerOpp1 => 'Consultor de Seguridad Digital';

  @override
  String get careerOpp1Desc => 'Ayuda a las empresas a proteger sus datos';

  @override
  String get careerOpp2 => 'Capacitador de Concienciación';

  @override
  String get careerOpp2Desc => 'Enseña a otros a estar seguros en línea';

  @override
  String get careerOpp3 => 'Auditor de seguridad freelance';

  @override
  String get careerOpp3Desc => 'Ofrece auditorías de seguridad a clientes';

  @override
  String get careerOpportunities => 'Oportunidades económicas';

  @override
  String get careerSkill1 => 'Seguridad de contraseñas';

  @override
  String get careerSkill2 => 'Detección de Phishing';

  @override
  String get careerSkill3 => 'Protección de Privacidad';

  @override
  String get careerSkill4 => 'Seguridad de Red';

  @override
  String get careerSkill5 => 'Respuesta a Incidentes';

  @override
  String get careerSkills => 'Habilidades que desarrollarás';

  @override
  String get careerSubtitle => 'Tu trayectoria profesional en ciberseguridad';

  @override
  String get careerTitle => 'Carrera y Certificaciones';

  @override
  String get challengeComplete => 'Completa la frase';

  @override
  String get challengeCreatePassword => 'Crear contraseña';

  @override
  String get challengeDetectRisk => 'Detectar riesgo';

  @override
  String get challengeMiniCase => 'Caso real';

  @override
  String get challengeMultiple => 'Opción múltiple';

  @override
  String get challengeSafe => 'Seguro';

  @override
  String get challengeSuspicious => 'Sospechoso';

  @override
  String get challengeTrueFalse => 'Verdadero / Falso';

  @override
  String get challengeWhatWouldYouDo => '¿Qué harías aquí?';

  @override
  String challenge_analyze_link_desc(Object count) {
    return 'Analiza $count enlace(s)';
  }

  @override
  String get challenge_analyze_link_title => 'Analizar Enlaces';

  @override
  String challenge_answer_questions_desc(Object count) {
    return 'Responde $count pregunta(s)';
  }

  @override
  String get challenge_answer_questions_title => 'Responder Preguntas';

  @override
  String challenge_check_in_desc(Object count) {
    return 'Regístrate $count vez(veces)';
  }

  @override
  String get challenge_check_in_title => 'Registro Diario';

  @override
  String challenge_complete_lesson_desc(Object count) {
    return 'Completa $count lección(es)';
  }

  @override
  String get challenge_complete_lesson_title => 'Completar Lecciones';

  @override
  String challenge_complete_session_desc(Object count) {
    return 'Completa $count sesión(es)';
  }

  @override
  String get challenge_complete_session_title => 'Sesiones de Aprendizaje';

  @override
  String get challenge_complete_stage_desc => 'Completa 1 etapa';

  @override
  String get challenge_complete_stage_title => 'Completar Etapa';

  @override
  String challenge_correct_streak_desc(Object count) {
    return 'Obtén $count respuestas correctas seguidas';
  }

  @override
  String get challenge_correct_streak_title => 'Racha Correcta';

  @override
  String challenge_detect_phishing_desc(Object count) {
    return 'Detecta $count intento(s) de phishing';
  }

  @override
  String get challenge_detect_phishing_title => 'Detectar Phishing';

  @override
  String challenge_earn_xp_desc(Object xp) {
    return 'Gana $xp XP';
  }

  @override
  String get challenge_earn_xp_title => 'Ganar XP';

  @override
  String challenge_learn_minutes_desc(Object count) {
    return 'Aprende durante $count minutos';
  }

  @override
  String get challenge_learn_minutes_title => 'Tiempo de Aprendizaje';

  @override
  String challenge_learn_topic_desc(Object count) {
    return 'Aprende $count tema(s)';
  }

  @override
  String get challenge_learn_topic_title => 'Aprender un Tema';

  @override
  String get challenge_perfect_lesson_desc =>
      'Completa una lección sin errores';

  @override
  String get challenge_perfect_lesson_title => 'Lección Perfecta';

  @override
  String challenge_privacy_check_desc(Object count) {
    return 'Revisa ajustes de privacidad $count vez(veces)';
  }

  @override
  String get challenge_privacy_check_title => 'Verificación de Privacidad';

  @override
  String challenge_quiz_night_desc(Object count) {
    return 'Completa $count mini quiz';
  }

  @override
  String get challenge_quiz_night_title => 'Mini Quiz';

  @override
  String challenge_review_tips_desc(Object count) {
    return 'Revisa $count consejo(s) de seguridad';
  }

  @override
  String get challenge_review_tips_title => 'Revisar Consejos';

  @override
  String challenge_security_audit_desc(Object count) {
    return 'Completa $count auditoría(s)';
  }

  @override
  String get challenge_security_audit_title => 'Auditoría de Seguridad';

  @override
  String challenge_share_knowledge_desc(Object count) {
    return 'Comparte $count consejo(s)';
  }

  @override
  String get challenge_share_knowledge_title => 'Compartir Conocimiento';

  @override
  String challenge_social_awareness_desc(Object count) {
    return 'Completa $count desafío(s) de conciencia social';
  }

  @override
  String get challenge_social_awareness_title => 'Conciencia Social';

  @override
  String challenge_streak_milestone_desc(Object count) {
    return 'Mantén una racha de $count días';
  }

  @override
  String get challenge_streak_milestone_title => 'Hito de Racha';

  @override
  String challenge_talk_sage_desc(Object count) {
    return 'Charla con Sage $count vez(veces)';
  }

  @override
  String get challenge_talk_sage_title => 'Charla con Sage';

  @override
  String challenge_test_password_desc(Object count) {
    return 'Prueba $count contraseña(s)';
  }

  @override
  String get challenge_test_password_title => 'Probar Contraseñas';

  @override
  String get challenge_use_dark_mode_desc => 'Usar modo oscuro';

  @override
  String get challenge_use_dark_mode_title => 'Modo Oscuro';

  @override
  String get changelogV4 => 'Fundamentos';

  @override
  String get changelogV4_1 => '8 etapas de aprendizaje con 1,099 lecciones';

  @override
  String get changelogV4_2 => 'Rachas diarias y desafíos';

  @override
  String get changelogV4_3 => 'Sistema de logros';

  @override
  String get changelogV5 => 'IA y Personalización';

  @override
  String get changelogV5Old => 'Sistema de Cofres y Gacha';

  @override
  String get changelogV5Old_1 =>
      'Sistema de evolución de cofres (Bronce → Legendaria)';

  @override
  String get changelogV5Old_2 => 'Botones 3D interactivos';

  @override
  String get changelogV5Old_3 => 'Rediseño de interfaz con Glassmorphism';

  @override
  String get changelogV5_1 => 'Chat de SAGE con IA para ayuda personalizada';

  @override
  String get changelogV5_2 => 'Máscaras dinámicas de emociones';

  @override
  String get changelogV5_3 => '17,157 preguntas de ciberseguridad';

  @override
  String get changelogV5_4 => 'Sociedad VIP para rachas de 30+ días';

  @override
  String get chatAskSage => 'Pregúntale a Sage';

  @override
  String get chatAskSageDesc =>
      'Haz una pregunta de ciberseguridad o elige una sugerencia rápida.';

  @override
  String get chatBlocked => 'Chat bloqueado';

  @override
  String get chatCancel => 'Cancelar';

  @override
  String get chatClear => 'Limpiar';

  @override
  String get chatClearAction => 'Borrar';

  @override
  String get chatClearMessage =>
      '¿Estás seguro de que quieres borrar esta conversación? Esta acción no se puede deshacer.';

  @override
  String get chatClearTitle => 'Borrar conversación';

  @override
  String get chatEmptyTitle => 'Inicia una conversación';

  @override
  String get chatFallback => 'Ahora mismo no pude responder. Intenta de nuevo.';

  @override
  String get chatFallbackSubtitle =>
      'Escribe cualquier duda sobre ciberseguridad o elige una sugerencia rápida.';

  @override
  String get chatFallbackTitle => 'Pregunta a Sage';

  @override
  String get chatGuideDesc => 'Tu guía de ciberseguridad';

  @override
  String get chatGuideSubtitle => 'Tu guía de ciberseguridad';

  @override
  String get chatHint => 'Pregúntale a Sage...';

  @override
  String get chatInputHint => 'Pregunta a Sage...';

  @override
  String get chatNewConversation => 'Nueva conversación';

  @override
  String get chatSageTutor => 'Tutor Sage';

  @override
  String get chatSageTutorLabel => 'Tutor Sage';

  @override
  String get checkInDesc => 'Check-in diario para mantener tu racha activa';

  @override
  String get checkInTitle => 'Registro diario';

  @override
  String get chestCollect => 'Recoger';

  @override
  String chestEvolvedTo(Object type) {
    return 'Evolucionó a $type';
  }

  @override
  String get chestNoChange => 'Sin cambios';

  @override
  String chestOpenedTitle(Object type) {
    return '¡Cofre $type!';
  }

  @override
  String get chestPityProgress => 'Legendario en';

  @override
  String get chestReminder => 'Recordatorios de cofres';

  @override
  String get chestReminderSubtitle =>
      'Recibe recordatorios para abrir tu cofre diario';

  @override
  String get chestRewardBronze => '¡Bronce!';

  @override
  String get chestRewardDefault => 'Recompensa';

  @override
  String get chestRewardDialog => 'Diálogo de recompensa del cofre';

  @override
  String get chestRewardGold => '¡Oro!';

  @override
  String get chestRewardLegendary => '¡Legendario!';

  @override
  String get chestRewardSilver => '¡Plata!';

  @override
  String get chestTapToOpen => 'Toca para abrir';

  @override
  String get chestTapToUpgrade => 'Toca para mejorar';

  @override
  String chestTitle(Object type) {
    return 'Cofre $type';
  }

  @override
  String chestTreasure(Object type) {
    return 'Cofre del tesoro $type';
  }

  @override
  String chestTreasureLabel(Object type) {
    return 'Tesoro $type';
  }

  @override
  String get chestTypeBronze => 'Bronce';

  @override
  String get chestTypeGold => 'Oro';

  @override
  String get chestTypeLegendary => 'Legendario';

  @override
  String get chestTypeSilver => 'Plata';

  @override
  String get chestXpBoost => 'x2 EXP';

  @override
  String get closeButton => 'Cerrar';

  @override
  String get cloudDataDeleted => 'Datos cloud eliminados';

  @override
  String get cloudSync => 'Cloud y sincronización';

  @override
  String get commit1Month => '1 mes';

  @override
  String get commit1Week => '1 semana';

  @override
  String get commit2Weeks => '2 semanas';

  @override
  String get commitButton => 'COMPROMETERME CON MI META';

  @override
  String get commitChooseGoal => 'Elige tu meta';

  @override
  String get commitChooseGoalDesc =>
      'Selecciona cuántos días seguirás tu plan de aprendizaje.';

  @override
  String commitDays(Object days) {
    return '$days días';
  }

  @override
  String commitGoalLabel(Object days) {
    return 'Tu meta: $days días';
  }

  @override
  String get commitSelected => 'SELECCIONADO';

  @override
  String commitYourGoal(Object days) {
    return 'Tu meta: $days días';
  }

  @override
  String get completePrevious => 'Completa la etapa anterior';

  @override
  String get connectionErrorRetry => 'Error de conexión. Intenta de nuevo.';

  @override
  String continueLesson(Object title) {
    return 'Continuar lección: $title';
  }

  @override
  String get continueText => 'Continuar';

  @override
  String get correct => 'Correcto';

  @override
  String get correctAnswer => 'Respuesta correcta';

  @override
  String correctAnswers(Object correct, Object total) {
    return '$correct de $total correctas';
  }

  @override
  String get currencySymbol => '\$';

  @override
  String cyberQuizProgress(Object current, Object total) {
    return 'Pregunta $current de $total';
  }

  @override
  String get dailyGoalIntense => 'Intenso';

  @override
  String dailyGoalMinutesPerDay(Object minutes) {
    return '$minutes min/día';
  }

  @override
  String get dailyGoalNormal => 'Normal';

  @override
  String get dailyGoalQuestion => '¿Cuál es tu meta de aprendizaje diario?';

  @override
  String get dailyGoalRelaxed => 'Relajado';

  @override
  String get dailyGoalSerious => 'Serio';

  @override
  String get dailyMissions => 'Misiones diarias';

  @override
  String get dailyMissionsAllCompleted => 'Todos los desafíos completados hoy';

  @override
  String get dailyMissionsDesc =>
      'Completa tus misiones para obtener recompensas';

  @override
  String get darkModeEnd => 'Termina modo oscuro';

  @override
  String darkModeScheduleInfo(Object end, Object start) {
    return 'El modo oscuro estará activo de $start:00 a $end:00';
  }

  @override
  String get darkModeStart => 'Inicia modo oscuro';

  @override
  String get dayAbbrFri => 'Vie';

  @override
  String get dayAbbrMon => 'Lun';

  @override
  String get dayAbbrSat => 'Sáb';

  @override
  String get dayAbbrSun => 'Dom';

  @override
  String get dayAbbrThu => 'Jue';

  @override
  String get dayAbbrTue => 'Mar';

  @override
  String get dayAbbrWed => 'Mié';

  @override
  String get dayShortFri => 'V';

  @override
  String get dayShortMon => 'L';

  @override
  String weekDayCompleted(Object day) {
    return '$day, completado';
  }

  @override
  String weekDayToday(Object day) {
    return 'Hoy, $day';
  }

  @override
  String get dayShortSat => 'S';

  @override
  String get dayShortSun => 'D';

  @override
  String get dayShortThu => 'J';

  @override
  String get dayShortTue => 'M';

  @override
  String get dayShortWed => 'M';

  @override
  String get streakStatusCompleted => 'completado';

  @override
  String get streakStatusToday => 'hoy';

  @override
  String get streakStatusPending => 'pendiente';

  @override
  String get daysLabel => 'días';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteAccountConfirm => 'Eliminar mi cuenta';

  @override
  String get deleteAccountDesc =>
      'Esto eliminará permanentemente todos tus datos. Esta acción no se puede deshacer.';

  @override
  String get deleteAccountReauthRequired =>
      'Autenticación reciente requerida para eliminar la cuenta';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get deleteCloudData => 'Eliminar datos cloud';

  @override
  String get deleteCloudDesc =>
      '¿Estás seguro? Esta acción eliminará permanentemente tu progreso guardado en la nube. Los datos locales no se verán afectados.';

  @override
  String get deleteCloudTitle => 'Eliminar datos cloud';

  @override
  String get deleteHistory => 'Borrar historial de análisis';

  @override
  String get deleteHistoryDesc =>
      'Se eliminarán todos los análisis de enlaces guardados. Esta acción no se puede deshacer.';

  @override
  String get deleteHistoryTitle => 'Borrar historial';

  @override
  String get demoModeLabel => 'DEMO MODE';

  @override
  String get demoStudentName => 'Demo Student';

  @override
  String get developedWith => 'Desarrollado con Flutter';

  @override
  String get donateToSupport => 'Donar para apoyar';

  @override
  String get donationBasic => 'Supporter';

  @override
  String get donationBasicDesc => 'Ayúdanos a mantener SAGEN gratis';

  @override
  String get donationLabel => 'Donación';

  @override
  String get donationPopular => 'Super Supporter';

  @override
  String get donationPopularDesc => 'Badge exclusivo + agradecimiento especial';

  @override
  String get donationPremium => 'Campeón';

  @override
  String get donationPremiumDesc =>
      'Todos los beneficios + tu nombre en créditos';

  @override
  String get donationValueLabel => 'Monto';

  @override
  String dot(Object number) {
    return 'Punto $number';
  }

  @override
  String get ecoCo2Saved => 'Emisiones de CO₂ evitadas';

  @override
  String get ecoComparison =>
      'SAGEN usa 99% menos recursos que la educación tradicional';

  @override
  String get ecoDescription =>
      'Cada lección que completas ahorra agua, reduce las emisiones de CO₂ y elimina el uso de papel.';

  @override
  String get ecoDigital => '📱 Digital: solo tu teléfono';

  @override
  String get ecoDigitalLearning => 'Aprendizaje 100% Digital';

  @override
  String get ecoDigitalLearningDesc =>
      'Sin papel, sin impresión, sin transporte necesario';

  @override
  String get ecoHowItWorks => 'Digital vs Tradicional';

  @override
  String get ecoLiters => 'litros';

  @override
  String get ecoPages => 'páginas';

  @override
  String get ecoPaperSaved => 'Papel ahorrado';

  @override
  String get ecoSubtitle => 'Aprende mientras cuidas el planeta';

  @override
  String get ecoTitle => 'Impacto Ambiental';

  @override
  String get ecoTraditional => '📚 Tradicional: papel, tinta, transporte';

  @override
  String get ecoTrees => 'árboles';

  @override
  String get ecoTreesEquivalent => 'Equivalente en árboles';

  @override
  String get ecoWaterSaved => 'Agua ahorrada';

  @override
  String get ecoYourImpact => 'Tu impacto ambiental';

  @override
  String get emotionPhrase1 => 'Ya detectas riesgos más rápido.';

  @override
  String get emotionPhrase2 => 'Tu hábito digital está mejorando.';

  @override
  String get emotionPhrase3 => 'Cada día entiendes mejor cómo protegerte.';

  @override
  String get emotionPhrase4 => 'Estás construyendo un instinto de seguridad.';

  @override
  String get emotionPhrase5 => 'Tu criterio digital se está afilando.';

  @override
  String get emotionPhrase6 => 'Estás aprendiendo a ver lo que otros no ven.';

  @override
  String get emotionPhrase7 => 'Tu mundo digital está más seguro gracias a ti.';

  @override
  String get emotionPhraseStart => 'Tu viaje digital comienza hoy.';

  @override
  String get emotionalPhrase1 => 'Detectas riesgos más rápido ahora.';

  @override
  String get emotionalPhrase2 => 'Tu hábito digital está mejorando.';

  @override
  String get emotionalPhrase3 => 'Cada día entiendes mejor cómo protegerte.';

  @override
  String get emotionalPhrase4 => 'Estás construyendo un instinto de seguridad.';

  @override
  String get emotionalPhrase5 => 'Tu juicio digital se está afilando.';

  @override
  String get emotionalPhrase6 => 'Estás aprendiendo a ver lo que otros no ven.';

  @override
  String get emotionalPhrase7 => 'Tu mundo digital es más seguro por ti.';

  @override
  String get emotionalPhraseStart => 'Tu viaje digital comienza hoy.';

  @override
  String get emptyChatSubtitle => 'Sage está listo para ayudarte';

  @override
  String get emptyProfile => 'Sin datos de perfil';

  @override
  String get emptyStore => 'La tienda está vacía';

  @override
  String get emptyUpdates => 'No hay actualizaciones disponibles';

  @override
  String get english => 'English';

  @override
  String get errorContentLoadFailed =>
      'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.';

  @override
  String get errorFeedback => 'Error al guardar comentario. Intenta de nuevo.';

  @override
  String get errorGeneric => 'Algo salió mal. Por favor, intenta de nuevo.';

  @override
  String get errorIntegrityCheck =>
      'Se detectó un problema de integridad. Tu progreso se ha guardado, pero por favor verifica que sea correcto.';

  @override
  String get errorLoadContent =>
      'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.';

  @override
  String get errorLoadProgress =>
      'No pudimos cargar tu progreso. Revisa tu conexión e intenta de nuevo.';

  @override
  String get errorLoadQuestions =>
      'Error al cargar preguntas. Intenta de nuevo.';

  @override
  String get errorNetwork => 'Sin conexión a internet. Revisa tu red.';

  @override
  String get errorPayment =>
      'Error al registrar el pago. Por favor, intenta de nuevo.';

  @override
  String get errorProgressLoadFailed =>
      'No pudimos cargar tu progreso. Verifica tu conexión e intenta de nuevo.';

  @override
  String get errorProgressReloadFailed =>
      'No pudimos recargar tu progreso. Intenta de nuevo.';

  @override
  String get errorReloadProgress =>
      'No pudimos recargar tu progreso. Intenta de nuevo.';

  @override
  String get errorRestartApp => 'Reiniciar app';

  @override
  String get errorRetry => 'Intentar de nuevo';

  @override
  String get errorShare => 'Error al compartir. Por favor, intenta de nuevo.';

  @override
  String get errorSomethingWrong => 'Algo salió mal';

  @override
  String get errorStreak => 'No se pudo guardar la racha.';

  @override
  String get errorUnexpected =>
      'Ocurrió un error inesperado. Puedes intentar de nuevo.';

  @override
  String get exitText => 'Salir';

  @override
  String get experience => 'Experiencia';

  @override
  String get exportData => 'Exportar mis datos';

  @override
  String get exportDataCopied => '¡Datos copiados al portapapeles!';

  @override
  String get exportDataCopy => 'Copiar al portapapeles';

  @override
  String get exportDataDesc => 'Descarga una copia de tus datos personales';

  @override
  String get exportDataLoading => 'Recopilando tus datos...';

  @override
  String get feedbackCatBug => 'Reportar un error';

  @override
  String get feedbackCatContent => 'Contenido';

  @override
  String get feedbackCatDesign => 'Diseño';

  @override
  String get feedbackCatFeature => 'Sugerir una función';

  @override
  String get feedbackCatGeneral => 'General';

  @override
  String get feedbackCategory => 'Categoría';

  @override
  String get feedbackChangelog => 'Novedades';

  @override
  String get feedbackComments => 'Comentarios';

  @override
  String get feedbackConfusing => 'Confundido';

  @override
  String get feedbackContinue => 'Continuar';

  @override
  String get feedbackExcellent => '¡Eres increíble!';

  @override
  String get feedbackGood => 'Bueno';

  @override
  String get feedbackHard => 'Difícil';

  @override
  String get feedbackHint => 'Cuéntanos qué piensas...';

  @override
  String get feedbackHowDidYouFeel => '¿Cómo te sentiste?';

  @override
  String get feedbackPerfect => 'Perfecto';

  @override
  String get feedbackPoor => 'Mejoraremos';

  @override
  String get feedbackRateExperience => 'Califica tu experiencia';

  @override
  String get feedbackSubmit => 'Enviar comentarios';

  @override
  String get feedbackTapStars => 'Toca una estrella para calificar';

  @override
  String get feedbackThanks => '¡Gracias!';

  @override
  String get feedbackThanksDesc =>
      'Tus comentarios nos ayudan a mejorar SAGEN para todos.';

  @override
  String get feedbackTitle => 'Comentarios y Historial de Cambios';

  @override
  String get fileAnalyzer => 'Analizar archivo';

  @override
  String get fileDangerous => 'Peligroso';

  @override
  String get fileHighRisk => 'Alto riesgo';

  @override
  String get fileLowRisk => 'Bajo riesgo';

  @override
  String get fileMediumRisk => 'Riesgo medio';

  @override
  String get fileSafe => 'Seguro';

  @override
  String get finishText => 'Finalizar';

  @override
  String firstLessonProgress(Object current, Object total) {
    return 'Lección $current de $total';
  }

  @override
  String get firstLessonSeeResults => 'VER RESULTADOS';

  @override
  String get flexCardJoinAlliance => 'Únete a mi alianza en SAGEN';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeSmall => 'Pequeño';

  @override
  String get fontSizeTitle => 'Tamaño del texto';

  @override
  String get fontSizeXLarge => 'Extra grande';

  @override
  String get forceSync => 'Forzar sincronización';

  @override
  String get free => 'Gratis';

  @override
  String get french => 'Francés';

  @override
  String get gachaChestTap => 'Cofre de gacha. Toca para mejorar.';

  @override
  String get gachaOrbFail => 'Sin cambios';

  @override
  String get gachaOrbSuccess => 'Mejora exitosa';

  @override
  String get gems => 'gemas';

  @override
  String goToLesson(Object title) {
    return 'Ir a lecciones: $title';
  }

  @override
  String get greetingAfternoon => 'Buenas tardes';

  @override
  String get greetingEvening => 'Buenas noches';

  @override
  String get greetingMorning => 'Buenos días';

  @override
  String get habitMsg1 =>
      '¡Gran trabajo! Ahora vamos a fortalecer tu disciplina diaria.';

  @override
  String get habitMsg2 =>
      'Primer paso listo. Vamos a construir el hábito que te llevará a tu meta.';

  @override
  String get habitMsg3 =>
      'Excelente rendimiento. El secreto ahora es la constancia.';

  @override
  String get habitMsg4 =>
      '¡Bien hecho! Ahora configuremos el ritmo de tu progreso diario.';

  @override
  String get habitMsg5 =>
      'Un comienzo perfecto. Aseguremos tu éxito construyendo un hábito inquebrantable.';

  @override
  String get habitTransition1 => 'Construyendo tu hábito diario...';

  @override
  String get habitTransition2 => 'La constancia es la clave';

  @override
  String get habitTransition3 => 'Estás progresando';

  @override
  String get habitTransition4 => '¡Sigue así!';

  @override
  String get habitTransition5 => '¡Ya casi!';

  @override
  String get hapticFeedback => 'Vibración háptica';

  @override
  String get hapticSubtitle => 'Respuesta háptica en interacciones';

  @override
  String get heatmapLess => 'Menos';

  @override
  String heatmapLessons(Object count) {
    return '$count lecciones';
  }

  @override
  String get heatmapMore => 'Más';

  @override
  String get heatmapTitle => 'Actividad reciente';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get historyDeleted => 'Historial eliminado';

  @override
  String get historyTitle => 'Historial';

  @override
  String get homeAllComplete => '¡Todo completo!';

  @override
  String get homeAllCompleteDesc => 'Has dominado todas las lecciones.';

  @override
  String get homeContinue => 'Seguir';

  @override
  String get homeDefaultName => 'Guardián';

  @override
  String levelUpCelebrationLabel(int level) {
    return '¡Subiste de nivel! Nuevo nivel: $level';
  }

  @override
  String get homeLearningPath => 'Ruta de aprendizaje';

  @override
  String get homeTitle => 'Tu escudo digital está activo';

  @override
  String get homeViewAchievements => 'Ver logros';

  @override
  String get howItWorks => 'Cómo funciona SAGEN';

  @override
  String get impactAch => 'Logros';

  @override
  String get impactActiveUsers => 'Usuarios activos';

  @override
  String get impactCommunity => 'Impacto Comunitario';

  @override
  String get impactCountriesReached => 'Países alcanzados';

  @override
  String get impactDonations => 'Total Donado';

  @override
  String get impactHoursLearned => 'Horas aprendidas';

  @override
  String get impactKnowledgeLevel => 'Conocimiento en ciberseguridad';

  @override
  String get impactLearningJourney => 'Tu Viaje de Aprendizaje';

  @override
  String get impactLessons => 'Lecciones completadas';

  @override
  String get impactLevelActiveLearner => 'Aprendiz activo';

  @override
  String get impactLevelAwareUser => 'Usuario consciente';

  @override
  String get impactLevelBeginner => 'Principiante';

  @override
  String get impactLevelCybersecurityExpert => 'Experto en Ciberseguridad';

  @override
  String get impactLevelDigitalGuardian => 'Guardián Digital';

  @override
  String impactProgressToNext(Object count) {
    return '$count lecciones para el siguiente nivel';
  }

  @override
  String get impactProtectedUsers => 'Usuarios protegidos';

  @override
  String get impactQuestionsAnswered => 'Preguntas respondidas';

  @override
  String get impactStreak => 'Racha actual';

  @override
  String get impactTestimonial => 'Lo que dicen los usuarios';

  @override
  String get impactTestimonial1 =>
      'SAGEN me ayudó a proteger a mi familia del phishing. ¡Las lecciones interactivas son increíbles!';

  @override
  String get impactTestimonial2 =>
      'Pasé de no saber nada de ciberseguridad a ayudar a mis colegas a mantenerse seguros en línea.';

  @override
  String get impactTestimonial3 =>
      'La gamificación hace que aprender sea divertido. ¡Completé 30 lecciones en solo 2 semanas!';

  @override
  String get impactTitle => 'Mi Impacto';

  @override
  String get impactTotalLessons => 'Lecciones completadas';

  @override
  String get impactXp => 'XP obtenidos';

  @override
  String get impactYourLevel => 'TU NIVEL';

  @override
  String get impactYourStats => 'Tus estadísticas';

  @override
  String get incorrect => 'Incorrecto';

  @override
  String get incorrectAnswer => 'Respuesta incorrecta';

  @override
  String get infoSection => 'Información';

  @override
  String get initialAction => 'Comienza aquí';

  @override
  String get inventoryFocusElixir => 'Elixir de Foco';

  @override
  String get inventoryFocusElixirActivated =>
      'Elixir de enfoque activado — x2 por 15 min';

  @override
  String get inventoryFocusElixirDesc => 'Multiplica EXP x2 durante 15 min';

  @override
  String get inventoryMonocleAvailable =>
      'Monocle de Sage disponible para el siguiente desafío';

  @override
  String get inventoryPhoenixFeather => 'Pluma de Fénix';

  @override
  String get inventoryPhoenixFeatherDesc =>
      'Revive tu racha si la perdiste hace menos de 24h';

  @override
  String get inventoryPhoenixFeatherRestored =>
      'Pluma de Fénix: racha restaurada';

  @override
  String get inventorySagesMonocle => 'Monóculo del Sabio';

  @override
  String get inventorySagesMonocleDesc =>
      'Elimina 2 respuestas incorrectas en un reto';

  @override
  String get inventoryShieldProtected => 'Escudo de Titanio: racha protegida';

  @override
  String get inventoryTitaniumShield => 'Escudo de Titanio';

  @override
  String get inventoryTitaniumShieldDesc =>
      'Protege tu racha automáticamente si faltas un día';

  @override
  String get inventoryTitle => 'Inventario';

  @override
  String get inventoryUse => 'Usar';

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageFrench => 'Francés';

  @override
  String get languagePortuguese => 'Portugués';

  @override
  String get lastSync => 'Última sincronización';

  @override
  String get learnSubtitle => 'Lecciones interactivas de seguridad digital';

  @override
  String get learnTitle => 'Aprender';

  @override
  String get learningPath => 'Tu camino de aprendizaje';

  @override
  String get legalAnd => ' y ';

  @override
  String get legalPrivacy => 'Acepto la política de privacidad';

  @override
  String get legalRegisterAgree => 'Al registrarte aceptas nuestros ';

  @override
  String get legalTerms => 'Términos';

  @override
  String get lessonComplete => 'Lección completada';

  @override
  String get lessonNoQuestions =>
      'No hay preguntas disponibles para esta lección';

  @override
  String get lessonNoQuestionsHint =>
      '¡Sage también tiene curiosidad! Vuelve pronto.';

  @override
  String get lessonPreparing => 'Preparando tus preguntas...';

  @override
  String lessonProgress(Object percent) {
    return 'Progreso: $percent%';
  }

  @override
  String get lessonResultsPreparing => 'Preparando resultados...';

  @override
  String lessonsCompleted(Object count) {
    return '$count lecciones completadas';
  }

  @override
  String lessonsCompletedPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# lecciones completadas',
      one: '# lección completada',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(Object count) {
    return '$count lecciones';
  }

  @override
  String lessonsLevel(Object level) {
    return 'Nivel $level';
  }

  @override
  String get lessonsNoAvailable =>
      'No hay lecciones disponibles. Vuelve pronto.';

  @override
  String get lessonsYourPath => 'Tu ruta de aprendizaje';

  @override
  String get levelAssessment0 => 'Principiante absoluto';

  @override
  String get levelAssessment1 => 'Principiante';

  @override
  String get levelAssessment2 => 'Intermedio';

  @override
  String get levelAssessment3 => 'Avanzado';

  @override
  String get levelAssessment4 => 'Experto';

  @override
  String get levelAssessmentQuestion =>
      '¿Cuál es tu nivel actual en ciberseguridad?';

  @override
  String levelProgress(Object percent) {
    return 'Progreso de nivel: $percent por ciento';
  }

  @override
  String get loading => 'Cargando';

  @override
  String get madeWithLove => 'Hecho con ♥ para estudiantes';

  @override
  String get miniGameBackupDef => 'Copia de seguridad';

  @override
  String get miniGameComplete => '¡Completado!';

  @override
  String get miniGameCorrect => 'Correcto';

  @override
  String get miniGameEncryptionDef => 'Protección de datos con clave';

  @override
  String get miniGameEncryptionTerm => 'Cifrado';

  @override
  String get miniGameFirewallDef => 'Barrera de seguridad de red';

  @override
  String get miniGameHiddenCard => 'Carta oculta';

  @override
  String get miniGameMalwareDef => 'Software malicioso';

  @override
  String get miniGameMatches => 'Aciertos';

  @override
  String get miniGameMemory => 'Juego de memoria';

  @override
  String get miniGameMemoryDesc => 'Encuentra las parejas coincidentes';

  @override
  String get miniGameMistakes => 'Errores';

  @override
  String get miniGameMoves => 'Movimientos';

  @override
  String get miniGameOver => '¡Buen intento!';

  @override
  String get miniGamePattern => 'Trazo de patrón';

  @override
  String get miniGamePatternDesc => 'Memoriza y reproduce patrones';

  @override
  String get miniGamePhishingDef => 'Correo falso que roba datos';

  @override
  String get miniGamePlayAgain => 'Jugar de nuevo';

  @override
  String get miniGameRound => 'Ronda';

  @override
  String get miniGameScore => 'Puntuación';

  @override
  String get miniGameSortInstruction =>
      'Toca para ordenar cada elemento en la categoría correcta';

  @override
  String get miniGameSpeed => 'Clasificación Veloz';

  @override
  String get miniGameSpeedDesc => 'Ordena los elementos rápidamente';

  @override
  String get miniGameSubtitle => 'Entrena tus habilidades de ciberseguridad';

  @override
  String get miniGameTitle => 'Minijuegos';

  @override
  String get miniGameVpnDef => 'Red privada virtual';

  @override
  String get miniGameWatch => 'Ver';

  @override
  String get miniGameWord => 'Palabras Iguales';

  @override
  String get miniGameWordDesc => 'Relaciona términos y definiciones';

  @override
  String get miniGameWrong => 'Incorrecto';

  @override
  String get miniGameYourTurn => 'Tu turno';

  @override
  String minutes(Object min) {
    return '$min min';
  }

  @override
  String minutesPerDay(Object count) {
    return '$count minutos por día';
  }

  @override
  String get missionActiveLearnerDesc => 'Completa 1 lección de seguridad.';

  @override
  String get missionActiveLearnerTitle => 'Aprendiz activo';

  @override
  String get missionActiveStreakDesc => 'Mantén tu racha de aprendizaje hoy.';

  @override
  String get missionActiveStreakTitle => 'Racha activa';

  @override
  String get missionChatWithSageDesc =>
      'Habla con Sage sobre seguridad digital.';

  @override
  String get missionChatWithSageTitle => 'Habla con Sage';

  @override
  String get missionConsistentProtectorDesc => 'Completa 3 lecciones hoy.';

  @override
  String get missionConsistentProtectorTitle => 'Protector constante';

  @override
  String get missionDigitalDetectiveDesc => 'Analiza un enlace sospechoso.';

  @override
  String get missionDigitalDetectiveTitle => 'Detective digital';

  @override
  String get missionExpressChallengeDesc =>
      'Completa un desafío rápido de 30 segundos.';

  @override
  String get missionExpressChallengeTitle => 'Desafío express';

  @override
  String get missionPerfectLessonDesc => 'Completa una lección sin errores.';

  @override
  String get missionPerfectLessonTitle => 'Lección perfecta';

  @override
  String get missionPhishingHunterDesc =>
      'Detecta correctamente un intento de phishing.';

  @override
  String get missionPhishingHunterTitle => 'Cazador de phishing';

  @override
  String missionProgress(Object percent) {
    return 'Progreso de misión: $percent por ciento';
  }

  @override
  String get missionThreeQueriesDesc =>
      'Habla con Sage 3 veces sobre diferentes temas.';

  @override
  String get missionThreeQueriesTitle => '3 consultas';

  @override
  String get monthApr => 'Abr';

  @override
  String get monthApril => 'Abril';

  @override
  String get monthAug => 'Ago';

  @override
  String get monthAugust => 'Agosto';

  @override
  String get monthDec => 'Dic';

  @override
  String get monthDecember => 'Diciembre';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthFebruary => 'Febrero';

  @override
  String get monthJan => 'Ene';

  @override
  String get monthJanuary => 'Enero';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthJuly => 'Julio';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJune => 'Junio';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthMarch => 'Marzo';

  @override
  String get monthMay => 'Mayo';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthNovember => 'Noviembre';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthOctober => 'Octubre';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthSeptember => 'Septiembre';

  @override
  String get motivationCareer => 'Carrera profesional';

  @override
  String get motivationConnect => 'Conectar con personas';

  @override
  String get motivationDialogMultiple => 'Múltiples motivaciones seleccionadas';

  @override
  String get motivationDialogNone => 'Sin motivación seleccionada';

  @override
  String get motivationFun => 'Divertirme';

  @override
  String get motivationMind => 'Entrenar mi mente';

  @override
  String get motivationOther => 'Otro';

  @override
  String get motivationStudies => 'Estudios';

  @override
  String get motivationTravel => 'Viajar';

  @override
  String get myAccount => 'Mi cuenta';

  @override
  String get navChest => 'Cofre';

  @override
  String get navHome => 'Inicio';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navRanking => 'Clasificación';

  @override
  String get navSage => 'Sage';

  @override
  String get never => 'Nunca';

  @override
  String get newBadge => 'NUEVO';

  @override
  String get newsUpdates => 'Novedades y actualizaciones';

  @override
  String get nextText => 'Siguiente';

  @override
  String get noConnection => 'Sin conexión a internet.';

  @override
  String get noLessonsAvailable => 'No hay lecciones disponibles';

  @override
  String get notFoundBackHome => 'Volver al inicio';

  @override
  String get notFoundDescription => 'La página que buscas no existe.';

  @override
  String get notFoundTitle => 'Página no encontrada';

  @override
  String get notificationReminder =>
      'Cinco minutos hoy pueden ayudarte mañana.';

  @override
  String get notificationStreakAlive => 'Tu racha sigue viva';

  @override
  String get notificationStreakLoss => 'Nunca es tarde para empezar otra vez.';

  @override
  String get notificationTip => 'Tu escudo digital te espera.';

  @override
  String get notificationsTitle => 'Notificaciones';

  @override
  String get offlineAction => 'Conéctate e inténtalo nuevamente.';

  @override
  String get offlineMessage => 'Sin conexión a internet.';

  @override
  String get offlineNoConnection => 'Sin conexión a internet';

  @override
  String get offlineSavedForLater =>
      'Guardado sin conexión. Sincronizaremos pronto.';

  @override
  String get offlineSyncComplete => '¡Sincronización completada!';

  @override
  String get onbDiagnosisMsg =>
      '¡Genial! Ajustaremos tu plan de entrenamiento para proteger tu conocimiento desde el primer día.';

  @override
  String get onbGoalCommit => 'MANTENTE COMPROMETIDO';

  @override
  String get onbGoalIntense => 'Intenso';

  @override
  String onbGoalMinPerDay(Object minutes) {
    return '$minutes min/día';
  }

  @override
  String get onbGoalNormal => 'Normal';

  @override
  String get onbGoalRelaxed => 'Relajado';

  @override
  String get onbGoalSerious => 'Serio';

  @override
  String get onbGoalTitle => '¿Cuál es tu meta de aprendizaje diario?';

  @override
  String get onbLevel0 => 'Cero absoluto (no sé qué es el phishing...)';

  @override
  String get onbLevel1 => 'Sé lo básico...';

  @override
  String get onbLevel2 => 'Nivel intermedio...';

  @override
  String get onbLevel3 => 'Nivel avanzado...';

  @override
  String get onbLevel4 => 'Experto en ciberseguridad...';

  @override
  String get onbLevelContinue => 'CONTINUAR';

  @override
  String get onbLevelQuestion => '¿Cuál es tu nivel actual en ciberseguridad?';

  @override
  String get onbLevelTitle => '¿Cuál es tu nivel actual en ciberseguridad?';

  @override
  String get onbMotivationCareer => 'Carrera profesional';

  @override
  String get onbMotivationCareerMsg => '¡Grandes razones para aprender!';

  @override
  String get onbMotivationConnect => 'Conecta con personas';

  @override
  String get onbMotivationConnectMsg => '¡Vamos a conectarte!';

  @override
  String get onbMotivationFun => 'Diviértete';

  @override
  String get onbMotivationFunMsg =>
      '¡Me encanta! Divertirme es mi especialidad.';

  @override
  String get onbMotivationMind => 'Entrenar mi mente';

  @override
  String get onbMotivationMindMsg => 'Es una decisión sabia.';

  @override
  String get onbMotivationOther => 'Otro';

  @override
  String get onbMotivationOtherMsg => '¡Entendido! Cuéntame más por el camino.';

  @override
  String get onbMotivationStudies => 'Estudios';

  @override
  String get onbMotivationStudiesMsg =>
      '¡Un mundo de oportunidades se abrirá para ti!';

  @override
  String get onbMotivationTitle => '¿Por qué quieres dominar el mundo digital?';

  @override
  String get onbMotivationTravel => 'Viajar';

  @override
  String get onbMotivationTravelMsg =>
      '¡Nada supera viajar con tus dispositivos 100% protegidos!';

  @override
  String get onbNotifActivate => 'ACTIVAR NOTIFICACIONES';

  @override
  String get onbNotifDesc =>
      'Activa las notificaciones para no perderte tu racha, los recordatorios diarios y los desafíos importantes.';

  @override
  String get onbNotifSkip => 'Ahora no';

  @override
  String get onbNotifTitle => '¿Recibir notificaciones?';

  @override
  String get onbProjHackerMind => 'Forja una mentalidad de hacker';

  @override
  String get onbProjHackerMindDesc =>
      'Recordatorios estratégicos, desafíos diarios y tácticas de defensa digital.';

  @override
  String get onbProjLockAccounts => 'Asegura tus cuentas';

  @override
  String get onbProjLockAccountsDesc =>
      'Protege tus cuentas de redes sociales y videojuegos contra hackeos y robos.';

  @override
  String get onbProjNavImmunity => 'Navega con inmunidad';

  @override
  String get onbProjNavImmunityDesc =>
      'Detecta estafas, enlaces maliciosos y phishing antes de hacer clic.';

  @override
  String get onbProjectionTitle => '¡Esto es lo que dominarás en 3 meses!';

  @override
  String onbQuizIntro(Object count) {
    return 'Responda $count preguntas rápidas antes de su primer entrenamiento digital';
  }

  @override
  String get onbRecommended => 'RECOMENDADO';

  @override
  String get onbReferralFriends => 'Referir amigos';

  @override
  String get onbReferralGoogle => 'Búsqueda de Google';

  @override
  String get onbReferralOther => 'Otro';

  @override
  String get onbReferralPlayStore => 'Play Store';

  @override
  String get onbReferralQuestion => '¿Cómo descubriste la existencia de SAGEN?';

  @override
  String get onbReferralSocial => 'Instagram / Facebook';

  @override
  String get onbReferralTiktok => 'TikTok';

  @override
  String get onbReferralTitle => '¿Cómo descubriste SAGEN?';

  @override
  String get onbReferralYoutube => 'YouTube';

  @override
  String get onbRouteAvailable => 'Rutas de entrenamiento disponibles:';

  @override
  String get onbRouteQuestion =>
      '¿Qué área del entorno digital te gustaría dominar primero?';

  @override
  String get onbRoutineMessage =>
      '¡Elige tu rutina de entrenamiento y blindaje!';

  @override
  String get onbRoutineTitle =>
      '¡Elige tu rutina de capacitación y protección!';

  @override
  String get onbStartingExperienced => '¿Ya tienes experiencia como hacker?';

  @override
  String get onbStartingExperiencedSub =>
      '¡Toma el test de nivel y salta lo básico!';

  @override
  String get onbStartingPerfecto =>
      '¡Perfecto! Veamos dónde empezar tu entrenamiento.';

  @override
  String get onbStartingSubtitle => 'Empieza desde cero y forja tu escudo';

  @override
  String get onbStartingTitle => '¿Es tu primera vez en ciberdefensa?';

  @override
  String get onbWelcomeMessage =>
      '¡Hola! Soy Sagen. Estoy aquí para entrenarte, blindar tu entorno digital y convertirte en un experto.';

  @override
  String get onbWelcomeMsg =>
      '¡Hola! Soy Sagen. Estoy aquí para entrenarte, proteger tu entorno digital y hacerte un experto.';

  @override
  String get onboardingCommitButton => 'MANTENER MI COMPROMISO';

  @override
  String get onboardingComplete => '¡Listo! Ya sabes detectar phishing básico.';

  @override
  String get onboardingDesc =>
      'Tu asistente personal de seguridad digital.\nAprende, analiza y protégete gratis.';

  @override
  String get onboardingError =>
      'Así actúan. Siempre verifican antes de confiar.';

  @override
  String get onboardingHaveAccount => 'Ya tengo una cuenta';

  @override
  String get onboardingSage50Days =>
      '50 días de dedicación. ¡Leyenda en formación!';

  @override
  String get onboardingSageExcellent => 'Excelentes motivos, ¡apunta alto!';

  @override
  String get onboardingSageMonth =>
      'Un mes de disciplina. Los hábitos se forjan.';

  @override
  String get onboardingSageStart => '¡Un gran comienzo! Cada día cuenta.';

  @override
  String get onboardingSageTwoWeeks =>
      'Dos semanas de constancia. ¡Eres imparable!';

  @override
  String get onboardingWelcome => 'Aprende a protegerte';

  @override
  String get onboardingWelcomeDesc =>
      'SAGEN te enseña a navegar, detectar riesgos y proteger tu información en internet.';

  @override
  String get ourMission => 'Nuestra misión';

  @override
  String get owned => 'Obtenido';

  @override
  String get passClaimFailed =>
      'No se pudo reclamar la recompensa. Inténtalo de nuevo.';

  @override
  String get passClaimedLabel => 'Reclamado';

  @override
  String passDaysLeft(Object count) {
    return 'Quedan $count días';
  }

  @override
  String get passEarnSp => 'Gana SP completando lecciones';

  @override
  String get passHowToEarnDailyLimit => 'Límite diario de SP';

  @override
  String get passHowToEarnLesson => 'Completa una lección: +10 SP';

  @override
  String get passHowToEarnMission => 'Completa misiones diarias: +5 SP';

  @override
  String get passHowToEarnPerfect => 'Lección perfecta: +15 SP';

  @override
  String get passHowToEarnReview => 'Repasa una lección';

  @override
  String get passHowToEarnTitle => 'Cómo ganar SP';

  @override
  String passLevel(Object level) {
    return 'Nivel $level';
  }

  @override
  String get passLevelsTitle => 'Niveles';

  @override
  String get passLocked => 'Bloqueado';

  @override
  String get passMaxLevel => '¡Nivel máximo!';

  @override
  String passProgress(Object current, Object required) {
    return 'SP: $current / $required';
  }

  @override
  String get passReached => 'Alcanzado';

  @override
  String get passRewardClaimed => '¡Recompensa reclamada!';

  @override
  String passRewards(Object current, Object max) {
    return 'Recompensas ($current/$max)';
  }

  @override
  String get paymentCredited => '¡Acreditado!';

  @override
  String get paymentGoHome => 'Ir al inicio';

  @override
  String get paymentMercadoPagoError =>
      'Error de conexión con MercadoPago. Por favor, intenta de nuevo.';

  @override
  String get paymentNotCompleted => 'Pago no completado';

  @override
  String get paymentPending => 'Pago pendiente';

  @override
  String get paymentPendingDescription =>
      'Tu pago está siendo procesado. Las donaciones se acreditarán una vez que el proveedor confirme el pago.';

  @override
  String get paymentReturnToSagen => 'Volver a SAGEN';

  @override
  String get paymentTryAgain => 'Intentar de nuevo';

  @override
  String get paywallBasic => 'Básico';

  @override
  String get paywallDescription =>
      'Elige tu paquete y te contactamos por WhatsApp para coordinar el pago.';

  @override
  String get paywallMercadoPago => 'Mercado Pago';

  @override
  String paywallPackageAmount(Object gems) {
    return '$gems donaciones';
  }

  @override
  String paywallPackageLabel(Object label) {
    return 'Paquete $label';
  }

  @override
  String paywallPackageSupporter(Object level) {
    return 'Nivel de Supporter $level';
  }

  @override
  String get paywallPaymentMethods =>
      'Paga con Yape, Plin, MercadoPago o transferencia';

  @override
  String get paywallPopular => 'Popular';

  @override
  String get paywallPremium => 'Premium';

  @override
  String get paywallSupportUs => 'Apoya a SAGEN';

  @override
  String paywallWhatsAppError(Object link) {
    return 'Error al abrir WhatsApp. Paga vía: $link';
  }

  @override
  String paywallWhatsAppFallback(Object message) {
    return 'Abre WhatsApp y envía: $message';
  }

  @override
  String paywallWhatsAppMessage(
    Object currencySymbol,
    Object supporterLevel,
    Object price,
    Object userId,
  ) {
    return 'Hola, quiero donar $currencySymbol$price a SAGEN (Supporter $supporterLevel). Mi ID de usuario es: $userId';
  }

  @override
  String get portuguese => 'Portugués';

  @override
  String get preferencesTitle => 'Preferencias';

  @override
  String get preparingResults => 'Preparando resultados...';

  @override
  String get privacyLegal => 'Privacidad y legal';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get privacyPolicyTitle => 'Política de Privacidad de SAGEN';

  @override
  String get privacyPolicyLastUpdate => 'Última actualización: Julio 2026';

  @override
  String get privacyPolicySection1Title => '1. Información que Recopilamos';

  @override
  String get privacyPolicySection1Body =>
      'Recopilamos información que nos proporcionas directamente, como tu nombre, correo electrónico y edad, así como datos de uso de la app como lecciones completadas, rachas y puntuaciones.';

  @override
  String get privacyPolicySection2Title => '2. Uso de la Información';

  @override
  String get privacyPolicySection2Body =>
      'Utilizamos tu información para personalizar tu experiencia de aprendizaje, mejorar nuestros servicios y enviarte notificaciones relevantes sobre tu progreso.';

  @override
  String get privacyPolicySection3Title => '3. Almacenamiento de Datos';

  @override
  String get privacyPolicySection3Body =>
      'Tus datos se almacenan de forma segura en servidores protegidos. Utilizamos encriptación para proteger tu información personal.';

  @override
  String get privacyPolicySection4Title => '4. Tus Derechos';

  @override
  String get privacyPolicySection4Body =>
      'Tienes derecho a acceder, rectificar o eliminar tus datos personales. Puede contactarnos para ejercer estos derechos.';

  @override
  String get privacyPolicySection5Title => '5. Terceros';

  @override
  String get privacyPolicySection5Body =>
      'No vendemos tu información a terceros. Podemos compartir datos anonimizados para mejorar nuestros servicios educativos.';

  @override
  String get privacyPolicySection6Title => '6. Privacidad de Menores';

  @override
  String get privacyPolicySection6Body =>
      'Nuestra app está dirigida a adultos. No recopilamos intencionalmente información de menores de 13 años.';

  @override
  String get privacyPolicySection7Title => '7. Seguridad';

  @override
  String get privacyPolicySection7Body =>
      'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información contra acceso no autorizado.';

  @override
  String get privacyPolicySection8Title => '8. Cambios en esta Política';

  @override
  String get privacyPolicySection8Body =>
      'Nos reservamos el derecho de actualizar esta política. Te notificaremos de cambios significativos a través de la app.';

  @override
  String get privacyPolicySection9Title => '9. Contacto';

  @override
  String get privacyPolicySection9Body =>
      'Si tienes preguntas sobre esta política, contáctanos en soporte@sagenapp.com';

  @override
  String get productBestOffer => 'Mejor oferta';

  @override
  String get productBoost => 'Impulso';

  @override
  String get productBoostPack => 'Pack Impulso';

  @override
  String get productBoostPackDesc => '200 donaciones + 1 Boost de XP';

  @override
  String get productDonationBasic => 'Supporter';

  @override
  String get productDonationDesc => 'Ayúdanos a mantener SAGEN gratis';

  @override
  String get productDonationPremium => 'Campeón';

  @override
  String get productDonationStandard => 'Super Supporter';

  @override
  String get productDonations => 'Donaciones';

  @override
  String get productDonationsDesc => 'Donaciones para potenciar tu aprendizaje';

  @override
  String get productFortune => 'Fortuna';

  @override
  String get productFortunePack => 'Pack Fortuna';

  @override
  String get productFortunePackDesc => '300 donaciones + 1 Multiplicador de XP';

  @override
  String get productLuck => 'Suerte';

  @override
  String get productLuckBoostDesc =>
      '1 Boost de Suerte (2x en cofres legendarios)';

  @override
  String get productLuckPack => 'Pack Suerte';

  @override
  String get productLuckPackDesc => '250 donaciones + 1 Boost de Suerte';

  @override
  String get productOffer => 'Oferta';

  @override
  String get productPopular => 'Popular';

  @override
  String get productProtector => 'Protector';

  @override
  String get productProtectorPack => 'Pack Protegido';

  @override
  String get productProtectorPackDesc =>
      '100 donaciones + 1 protector de racha';

  @override
  String get productStreakProtectorDesc => '1 Protector de racha';

  @override
  String get productSupporter => 'Supporter';

  @override
  String get productUltra => 'Ultra';

  @override
  String get productXpBoostDesc => '1 Boost de XP (2x en tu próxima lección)';

  @override
  String get productXpMultiplierDesc => '1 Multiplicador de XP (2x en cofres)';

  @override
  String get profileAchievements => 'Logros';

  @override
  String get profileDay => 'día';

  @override
  String get profileDays => 'días';

  @override
  String get profileDefaultFirstName => 'Guerrero';

  @override
  String get profileDefaultLastName => 'Anónimo';

  @override
  String get profileDefaultName => 'Guardián';

  @override
  String get profileDonations => 'Donaciones';

  @override
  String get profileError => 'Error al cargar perfil';

  @override
  String get profileLevel => 'Nivel';

  @override
  String profileLevelValue(Object level) {
    return 'Nivel $level';
  }

  @override
  String get profileStreak => 'Racha';

  @override
  String get profileTitle => 'Mi Perfil';

  @override
  String get profileTotalXp => 'XP Total';

  @override
  String get profileXpLabel => 'XP';

  @override
  String xpValue(int count) {
    return '$count XP';
  }

  @override
  String get progressRestored => 'Progreso restaurado desde la nube';

  @override
  String get projectionBenefit1Subtitle =>
      'Asegura tus redes sociales y correos';

  @override
  String get projectionBenefit1Title => 'Protege tus cuentas';

  @override
  String get projectionBenefit2Subtitle =>
      'Identifica phishing y enlaces maliciosos';

  @override
  String get projectionBenefit2Title => 'Detecta estafas';

  @override
  String get projectionBenefit3Subtitle => 'Navega internet con confianza';

  @override
  String get projectionBenefit3Title => 'Navega con seguridad';

  @override
  String get promoPostLessonSubtitle =>
      'Con SAGEN Pass obtienes beneficios exclusivos';

  @override
  String get promoPostLessonTitle => '¡Sigue así! Desbloquea más';

  @override
  String get protectionBasic => 'Básico';

  @override
  String get protectionBasicDesc => 'Empiezas a protegerte';

  @override
  String get protectionCyberShield => 'Cyber Shield';

  @override
  String get protectionCyberShieldDesc => 'Eres un escudo activo';

  @override
  String get protectionElite => 'Elite Protection';

  @override
  String get protectionEliteDesc => 'Máximo nivel de protección';

  @override
  String get protectionGuardian => 'Guardián';

  @override
  String get protectionGuardianDesc => 'Defiendes tu identidad digital';

  @override
  String get protectionProtected => 'Protegido';

  @override
  String get protectionProtectedDesc => 'Tus primeros hábitos digitales';

  @override
  String get protectionSecureMind => 'Secure Mind';

  @override
  String get protectionSecureMindDesc => 'La seguridad es parte de ti';

  @override
  String questionProgress(Object current, Object total) {
    return 'Pregunta $current de $total';
  }

  @override
  String questions(Object count) {
    return '$count preguntas';
  }

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get quickChallengeDetectPhishing => 'Detecta phishing';

  @override
  String get quickChallengeDetectRisk => 'Detecta el riesgo';

  @override
  String get quickChallengeSafePassword => 'Contraseña segura';

  @override
  String get quickChallengeTrueFalse => 'Verdadero o Falso';

  @override
  String get quickChallengeWhatWouldYouDo => '¿Qué harías?';

  @override
  String get quizAbandonContent => 'Perderás tu progreso actual.';

  @override
  String get quizAbandonExit => 'SALIR';

  @override
  String get quizAbandonMessage => 'Perderás tu progreso actual.';

  @override
  String get quizAbandonStay => 'CONTINUAR';

  @override
  String get quizAbandonTitle => '¿Salir?';

  @override
  String get quizBack => 'Atrás';

  @override
  String get quizCheck => 'VERIFICAR';

  @override
  String get quizCheckAnswer => 'VERIFICAR';

  @override
  String get quizContinue => 'CONTINUAR';

  @override
  String get quizContinueButton => 'CONTINUAR';

  @override
  String get quizDefaultTitle => 'Cuestionario';

  @override
  String get quizExit => 'SALIR';

  @override
  String get quizIntroAnswer => 'Responde';

  @override
  String get quizIntroBeforeTraining => 'Antes de tu entrenamiento';

  @override
  String get quizIntroFastQuestions => 'Preguntas rápidas';

  @override
  String quizProgress(Object percent) {
    return 'Progreso del cuestionario: $percent por ciento';
  }

  @override
  String get quizProgressExpired =>
      'El progreso del cuestionario ha expirado (más de 24 horas).';

  @override
  String get quizResumeButton => 'Reanudar';

  @override
  String get quizStartOver => 'Empezar de nuevo';

  @override
  String get quizTitleDefault => 'Cuestionario';

  @override
  String get rankActiveLearner => 'Aprendiz Activo';

  @override
  String get rankCybersecurityLegend => 'Leyenda de Ciberseguridad';

  @override
  String get rankEliteDefender => 'Defensor Élite';

  @override
  String get rankExperiencedWarrior => 'Guerrero Experimentado';

  @override
  String get rankNovice => 'Novato';

  @override
  String get rankingEmptyMessage => 'Completa lecciones para entrar al ranking';

  @override
  String get rankingError => 'Error al cargar clasificación';

  @override
  String rankingPosition(Object rank) {
    return 'Posición #$rank';
  }

  @override
  String get rankingShareButton => 'Compartir Flex Card';

  @override
  String get rankingShareSubtitle => 'Supera mi rango en SAGEN';

  @override
  String get rankingSharing => 'Compartiendo...';

  @override
  String get rankingSubtitle => 'Clasificación global · Top 50';

  @override
  String get rankingTitle => 'El Coliseo';

  @override
  String rankingXpToTop50(Object xp) {
    return 'Te faltan $xp XP para entrar al Top 50';
  }

  @override
  String rankingYourPosition(Object xp, Object rank) {
    return 'Tu posición: #$rank · $xp XP';
  }

  @override
  String get rarityGold => 'Oro';

  @override
  String get rarityPlatinum => 'Platino';

  @override
  String get raritySilver => 'Plata';

  @override
  String get reauthConfirm => 'Confirmar';

  @override
  String get reauthDesc =>
      'Por razones de seguridad, por favor ingresa tu contraseña nuevamente';

  @override
  String get reauthOAuthInfo =>
      'Iniciaste sesión con Google o Facebook. Confirma la eliminación de tu cuenta.';

  @override
  String get reauthTitle => 'Confirma tu contraseña';

  @override
  String get reauthWrongPassword => 'Contraseña incorrecta. Intenta de nuevo.';

  @override
  String get recommended => 'RECOMENDADO';

  @override
  String get reduceAnimations => 'Reducir animaciones';

  @override
  String get reduceAnimationsSubtitle => 'Reduce la intensidad de animaciones';

  @override
  String get referralSource1 => 'Recomendación de amigos';

  @override
  String get referralSource2 => 'Redes sociales';

  @override
  String get referralSource3 => 'Búsqueda de Google';

  @override
  String get referralSource4 => 'App Store';

  @override
  String get referralSource5 => 'YouTube';

  @override
  String get referralSource6 => 'TikTok';

  @override
  String get referralSource7 => 'Otro';

  @override
  String get regAgeQuestion => '¿Cuántos años tienes?';

  @override
  String get regAgeValidation => 'Por favor, ingresa tu verdadera edad';

  @override
  String get regChooseMethod => 'Elige un método para crear tu cuenta.';

  @override
  String get regCloudSave => 'Progreso guardado en la nube';

  @override
  String get regCreateProfile => 'CREAR PERFIL';

  @override
  String get regEmailDesc => 'Te enviaremos un código de verificación.';

  @override
  String get regEmailHint => 'ejemplo@correo.com';

  @override
  String get regEmailOption => 'Correo Electrónico';

  @override
  String get regEmailTitle => 'Tu correo electrónico';

  @override
  String get regHowContinue => '¿Cómo quieres continuar?';

  @override
  String get regLater => 'Más adelante';

  @override
  String get regMethodTitle => 'Elige tu método de registro';

  @override
  String get regNameHint => 'Nombre';

  @override
  String get regNameQuestion => '¿Cómo te llamas?';

  @override
  String get regPasswordDesc => 'Mínimo 6 caracteres para proteger tu cuenta.';

  @override
  String get regPasswordTitle => 'Crea una contraseña';

  @override
  String get regProfileAlmostReady => '¡Casi listo!';

  @override
  String get regProfileCreated => 'PERFIL CREADO';

  @override
  String get regProfileDesc =>
      'Crea un perfil para guardar tu progreso y no perder tu racha.';

  @override
  String get regReadyForLesson => 'Prepara para tu primera lección';

  @override
  String get regRewards => 'Recompensas y logros personales';

  @override
  String get regStreakSync => 'Racha sincronizada entre dispositivos';

  @override
  String get regSurnameHint => 'Apellido';

  @override
  String get regWelcomeSagen => '¡Bienvenido a SAGEN!';

  @override
  String get registerAgeEmpty => 'Por favor ingresa tu edad';

  @override
  String get registerAgeHint => 'Tu edad (mínimo 13)';

  @override
  String get registerAgeInvalid => 'Edad no válida';

  @override
  String get registerAgeMin => 'Debes tener al menos 13 años';

  @override
  String get registerWithApple => 'Regístrate con Apple';

  @override
  String get registerWithFacebook => 'Regístrate con Facebook';

  @override
  String get registerWithGoogle => 'Regístrate con Google';

  @override
  String get restartApp => 'Reiniciar app';

  @override
  String get restoreAction => 'Restaurar';

  @override
  String get restoreCloud => 'Restaurar desde la nube';

  @override
  String get restoreDesc =>
      '¿Quieres restaurar tu progreso desde la nube? Esto reemplazará los datos locales con los datos guardados en tu cuenta.';

  @override
  String get restoreTitle => 'Restaurar progreso';

  @override
  String get resultAccuracy => 'Precisión';

  @override
  String get resultCompleteTitle => '¡Lección completada!';

  @override
  String get resultLives => 'Vidas';

  @override
  String get resultNotPerfectDesc =>
      'Sigue practicando para lograr una sesión perfecta.';

  @override
  String get resultPerfectBadge => 'SESIÓN PERFECTA';

  @override
  String get resultPerfectDesc =>
      'No cometiste ningún error. Eres un guardián digital.';

  @override
  String get resultPerfectTitle => '¡Resultado impecable!';

  @override
  String get resumeQuiz => '¿Reanudar cuestionario?';

  @override
  String get retry => 'Reintentar';

  @override
  String get reviewComplete => '¡Repaso completo!';

  @override
  String get reviewCorrect => 'correctas';

  @override
  String get reviewFinish => 'Finalizar repaso';

  @override
  String get reviewGoodProgress => 'Buen avance';

  @override
  String get reviewKeepGoing => '¡Sigue así!';

  @override
  String get reviewKeepPracticing => 'Sigue practicando';

  @override
  String get reviewNoErrors => 'No hay errores que repasar';

  @override
  String get reviewSageGood =>
      'Cada repaso fortalece tu escudo. ¿Listo para más?';

  @override
  String get reviewSageKeep =>
      'Repasar es parte del aprendizaje. Puedes volver a intentarlo cuando quieras.';

  @override
  String get reviewSagePerfect =>
      'Tus áreas débiles están mejorando. Noto tu esfuerzo.';

  @override
  String get reviewTitle => 'Repaso';

  @override
  String get reward100Xp => '100 XP';

  @override
  String get reward200Exp => '200 EXP';

  @override
  String rewardAdCooldown(Object seconds) {
    return 'Disponible en $seconds segundos';
  }

  @override
  String rewardAdEarned(Object count) {
    return '¡Ganaste $count donaciones!';
  }

  @override
  String rewardAdEarnedGems(Object gems) {
    return '+$gems gemas';
  }

  @override
  String rewardAdEarnedXp(Object xp) {
    return '¡+$xp XP ganados!';
  }

  @override
  String get rewardAdNotAvailable =>
      'El anuncio no está disponible ahora. Intenta más tarde.';

  @override
  String get rewardAdSubtitle =>
      'Mira un anuncio y recibe donaciones al instante';

  @override
  String get rewardAdTitle => 'Gana donaciones extra';

  @override
  String get rewardAdWatch => 'Ver';

  @override
  String get rewardCopperFrame => 'Marco de Cobre';

  @override
  String get rewardEpicChest => 'Cofre Épico';

  @override
  String get rewardGoldenChest => 'Cofre dorado';

  @override
  String get rewardIceFlame => 'Llama de Hielo + Guardián';

  @override
  String get rewardTitaniumShield => 'Escudo de Titanio';

  @override
  String get routeSelection1 => 'Fundamentos primero';

  @override
  String get routeSelection2 => 'Ruta intermedia';

  @override
  String get routeSelection3 => 'Ruta avanzada';

  @override
  String sageAchievementUnlocked(Object name) {
    return '$name¡Logro desbloqueado!';
  }

  @override
  String sageAdvancing(Object levelHint, Object name) {
    return '${name}Sigues avanzando.$levelHint';
  }

  @override
  String get sageChatDescription =>
      'Escribe cualquier duda sobre ciberseguridad o elige una sugerencia rápida.';

  @override
  String get sageChatHint => 'Pregunta a Sage...';

  @override
  String get sageChatTitle => 'Pregunta a Sage';

  @override
  String sageCongratulations(Object name) {
    return '$name¡Felicidades!';
  }

  @override
  String get sageCriticalError => 'Error crítico';

  @override
  String get sageEasterEgg => '¿Viste eso?';

  @override
  String sageEmptyState(Object name) {
    return '${name}No hay nada aquí todavía';
  }

  @override
  String sageGreatJob(Object name, Object extra) {
    return '$name¡Excelente trabajo!$extra';
  }

  @override
  String sageHighStreakDays(Object streak) {
    return ' $streak días seguidos.';
  }

  @override
  String get sageImportant => 'Esto es muy importante';

  @override
  String sageImpressiveStreak(Object name, Object days) {
    return '$name¡Racha impresionante!$days';
  }

  @override
  String sageLevelHint(Object level) {
    return ' El nivel $level ya está cerca.';
  }

  @override
  String get sageLoading => 'Dame un segundo...';

  @override
  String get sageMascot => 'Mascota Sage';

  @override
  String get sageMonocleActive => 'Monóculo Sabio activo';

  @override
  String get sageMonocleButton => 'Usar Monóculo Sabio (elimina 2 incorrectas)';

  @override
  String get sageMotivational1 => '¡Eres increíble!';

  @override
  String get sageMotivational2 => '¡Sigue adelante, eres increíble!';

  @override
  String get sageMotivational3 => '¡Cada día más cerca de tu objetivo!';

  @override
  String get sageMotivational4 => '¡Yo creo en ti!';

  @override
  String get sageMotivational5 => 'No te rindas, ¡tú puedes!';

  @override
  String get sageMotivational6 => '¡Vamos a esta aventura juntos!';

  @override
  String get sageMotivational7 => '¡El esfuerzo rinde frutos!';

  @override
  String get sageMotivational8 => '¡Nunca dejes de aprender!';

  @override
  String get sagePerfect => '¡Perfecto!';

  @override
  String get sagePreparing => 'Preparando todo para ti';

  @override
  String get sageReadCarefully => 'Lee con atención';

  @override
  String get sageSomethingWrong => 'Algo salió mal';

  @override
  String sageStreakAmazing(Object streak) {
    return '¡Tu racha de $streak días es increíble!';
  }

  @override
  String sageStreakAtRisk(Object streak) {
    return ' ¡No pierdas $streak días de esfuerzo!';
  }

  @override
  String sageStreakAtRiskMessage(Object urgency, Object name) {
    return '$name¡No pierdas tu racha!$urgency';
  }

  @override
  String get sageStreakLost => ' Tienes el conocimiento para empezar de nuevo.';

  @override
  String sageStreakLostMessage(Object name, Object encouragement) {
    return '${name}La racha se ha perdido.$encouragement';
  }

  @override
  String sageTellMeMore(Object name) {
    return '${name}Cuéntame más de ti';
  }

  @override
  String get sageTryAgain => '¿Intentamos de nuevo?';

  @override
  String sageWelcomeBack(Object name) {
    return '$name¡Bienvenido de vuelta!';
  }

  @override
  String sageWhatDoYouThink(Object name) {
    return '$name¿Qué crees que es correcto?';
  }

  @override
  String get sagenPassClaim => 'Reclamar';

  @override
  String get sagenPassSupportSubtitle =>
      'Obtén beneficios exclusivos y ayuda a mejorar la app';

  @override
  String get sagenPassSupportTitle => 'Apoya SAGEN';

  @override
  String get sagenPassTitle => 'Pase SAGEN';

  @override
  String get savedQuizProgress =>
      'Tienes un progreso guardado. ¿Te gustaría continuar?';

  @override
  String get scheduledDarkMode => 'Modo oscuro programado';

  @override
  String get scheduledDarkModeSubtitle => 'Activo/desactivo según horario';

  @override
  String get searchPlaceholder => 'Buscar...';

  @override
  String get selectFile => 'Seleccionar archivo';

  @override
  String get selectedAnswer => 'Seleccionada';

  @override
  String get sendMessage => 'Enviar';

  @override
  String get sessionAccuracyText1 => '¡Muy buena puntería!';

  @override
  String get sessionAccuracyText2 => 'Precisión quirúrgica.';

  @override
  String get sessionAccuracyText3 => 'Nivel experto alcanzado.';

  @override
  String get sessionAccuracyText4 => '¡Tirador certero de conocimiento!';

  @override
  String get sessionAccuracyText5 => 'Precisión casi perfecta.';

  @override
  String get sessionAccuracyText6 => 'Sin margen de error.';

  @override
  String get sessionAccuracyText7 => 'Impecable.';

  @override
  String get sessionBackToMap => 'Volver al mapa';

  @override
  String get sessionClaimReward => 'RECLAMAR RECOMPENSA';

  @override
  String get sessionCorrect => '¡Correcto!';

  @override
  String sessionCorrectAnswer(Object answer) {
    return 'Respuesta correcta: $answer';
  }

  @override
  String get sessionExp => 'EXP';

  @override
  String get sessionIncorrect => 'Incorrecto';

  @override
  String get sessionLivesExhausted => 'Vidas agotadas';

  @override
  String get sessionLivesExhaustedDesc =>
      'Has perdido todas tus vidas. Vuelve a intentarlo.';

  @override
  String get sessionLoading => 'Cargando...';

  @override
  String get sessionPrecision => 'PRECISIÓN';

  @override
  String get sessionQuestionsToAnswer => 'preguntas por responder';

  @override
  String get sessionReadyToLearn => '¿Listo para aprender?';

  @override
  String get sessionRetry => 'Reintentar';

  @override
  String sessionScore(Object correct, Object total) {
    return '$correct/$total correctas';
  }

  @override
  String get sessionSelectAnswer => 'Selecciona una respuesta';

  @override
  String get sessionSpeedText1 => '¡Qué velocidad!';

  @override
  String get sessionSpeedText2 => 'Superaste el tiempo.';

  @override
  String get sessionSpeedText3 => 'A la velocidad de la luz.';

  @override
  String get sessionSpeedText4 => 'Reflejos de acero.';

  @override
  String get sessionSpeedText5 => 'Nadie puede alcanzarte hoy.';

  @override
  String get sessionSpeedText6 => '¡Tiempo récord!';

  @override
  String get sessionSpeedText7 => 'Velocidad supersónica.';

  @override
  String get sessionStandardText1 => '¡Lección completada!';

  @override
  String get sessionStandardText2 => 'Un paso más hacia tu meta.';

  @override
  String get sessionStandardText3 => 'El progreso es el camino.';

  @override
  String get sessionStandardText4 => 'Buen trabajo constante.';

  @override
  String get sessionStandardText5 => 'Sigue adelante, suma más días.';

  @override
  String get sessionStandardText6 => 'La constancia sobre todo.';

  @override
  String get sessionStandardText7 => 'La disciplina da resultados.';

  @override
  String get sessionStartQuiz => 'INICIAR CUESTIONARIO';

  @override
  String get sessionSummaryAccuracy => 'PRECISIÓN';

  @override
  String get sessionSummaryAccuracy1 => '¡Tu precisión es extraordinaria!';

  @override
  String get sessionSummaryAccuracy2 => '¡Excelente puntería!';

  @override
  String get sessionSummaryAccuracy3 => '¡Buen progreso!';

  @override
  String get sessionSummaryAccuracy4 => '¡Estás mejorando!';

  @override
  String get sessionSummaryAccuracy5 => '¡Gran esfuerzo!';

  @override
  String get sessionSummaryAccuracy6 => '¡Sigue aprendiendo!';

  @override
  String get sessionSummaryAccuracy7 => '¡Cada pregunta cuenta!';

  @override
  String get sessionSummaryExp => 'EXP';

  @override
  String get sessionSummaryReceiveReward => 'RECLAMAR RECOMPENSA';

  @override
  String get sessionSummaryReceiveRewardLabel => 'Recolectar recompensa';

  @override
  String get sessionSummarySpeed1 => '¡Velocidad relámpago!';

  @override
  String get sessionSummarySpeed2 => '¡Pensamiento rápido!';

  @override
  String get sessionSummarySpeed3 => '¡Aprendiz rápido!';

  @override
  String get sessionSummarySpeed4 => '¡Buen ritmo!';

  @override
  String get sessionSummarySpeed5 => '¡En el camino correcto!';

  @override
  String get sessionSummarySpeed6 => '¡Construyendo impulso!';

  @override
  String get sessionSummarySpeed7 => '¡Progreso constante!';

  @override
  String get sessionSummaryStandard1 => '¡Lección completada!';

  @override
  String get sessionSummaryStandard2 => '¡Bien hecho!';

  @override
  String get sessionSummaryStandard3 => '¡Buen trabajo!';

  @override
  String get sessionSummaryStandard4 => '¡Buen trabajo!';

  @override
  String get sessionSummaryStandard5 => '¡Lo lograste!';

  @override
  String get sessionSummaryStandard6 => '¡Otro paso adelante!';

  @override
  String get sessionSummaryStandard7 => '¡Sigue adelante!';

  @override
  String get sessionSummaryTime => 'TIEMPO';

  @override
  String get sessionTime => 'TIEMPO';

  @override
  String get settingsAmoledDark => 'AMOLED Oscuro';

  @override
  String get settingsAmoledDarkSubtitle =>
      'Fondo #000000 puro para ahorrar batería';

  @override
  String get settingsAnalytics => 'Análisis anónimo';

  @override
  String get settingsAnalyticsDesc =>
      'Ayuda a mejorar Sagen con datos de uso anónimos';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountConfirm =>
      '¿Estás seguro? Esta acción no se puede deshacer.';

  @override
  String get settingsExportData => 'Exportar datos';

  @override
  String get settingsFontSize => 'Tamaño de fuente';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutConfirm =>
      '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPrivacy => 'Privacidad';

  @override
  String get settingsReduceAnimations => 'Reducir animaciones';

  @override
  String get settingsSound => 'Sonido';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsVibration => 'Vibración';

  @override
  String get shareProfile => 'Compartir tarjeta de perfil';

  @override
  String get shareRanking => 'Compartir ranking';

  @override
  String get sharing => 'Compartiendo...';

  @override
  String get shieldTierBasic => 'Escudo Básico';

  @override
  String get shieldTierCrystal => 'Escudo de Cristal';

  @override
  String get shieldTierGlow => 'Escudo Radiante';

  @override
  String get shieldTierInactive => 'Sin Escudo';

  @override
  String get shieldTierLegendary => 'Escudo Legendario';

  @override
  String get shieldTierParticles => 'Escudo de Partículas';

  @override
  String get shopBgCyber => 'Fondo Cyberpunk';

  @override
  String get shopBgCyberDesc => 'Fondo de perfil futurista';

  @override
  String get shopBgMatrix => 'Fondo Matrix';

  @override
  String get shopBgMatrixDesc => 'Fondo de matriz verde';

  @override
  String get shopFrameDiamond => 'Marco de Diamante';

  @override
  String get shopFrameDiamondDesc => 'Marco de diamante exclusivo';

  @override
  String get shopFrameNeon => 'Marco Neón';

  @override
  String get shopFrameNeonDesc => 'Marco de perfil neón';

  @override
  String get shopItemAcquired => 'Obtenido';

  @override
  String get shopItemOwned => 'Obtenido';

  @override
  String get shopOwned => 'Obtenido';

  @override
  String get shopSageGolden => 'Sage Dorado';

  @override
  String get shopSageGoldenDesc => 'Skin dorada exclusiva';

  @override
  String get shopSageNeon => 'Sage Neón';

  @override
  String get shopSageNeonDesc => 'Skin neón cyan para Sage';

  @override
  String get shopSageShadow => 'Sage Sombra';

  @override
  String get shopSageShadowDesc => 'Piel oscura para Sage';

  @override
  String get shopTitleGuardian => 'Título de Guardián Digital';

  @override
  String get shopTitleGuardianDesc => 'Título de guardián';

  @override
  String get shopTitleHacker => 'Título de Hacker Ético';

  @override
  String get shopTitleHackerDesc => 'Título especial en el perfil';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get skipText => 'Saltar';

  @override
  String get skipToContent => 'Saltar al contenido principal';

  @override
  String get sounds => 'Sonidos';

  @override
  String get soundsSubtitle => 'Efectos de sonido de la app';

  @override
  String get spanish => 'Español';

  @override
  String get speedSort2fa => 'Autenticación en dos pasos';

  @override
  String get speedSortAntivirus => 'Antivirus';

  @override
  String get speedSortDataEncryption => 'Cifrado de datos';

  @override
  String get speedSortFakeEmail => 'Correo falso';

  @override
  String get speedSortFirewall => 'Cortafuegos';

  @override
  String get speedSortFraudulentCall => 'Llamada fraudulenta';

  @override
  String get speedSortProtectionCategory => 'Protección';

  @override
  String get speedSortScamCategory => 'Estafa';

  @override
  String get speedSortSecurityCategory => 'Seguridad';

  @override
  String get speedSortSmsLink => 'Enlace SMS';

  @override
  String get speedSortStrongPassword => 'Contraseña segura';

  @override
  String get speedSortVpn => 'VPN';

  @override
  String get splashTitle => 'SAGEN';

  @override
  String get stage1Subtitle => 'Fundamentos de seguridad digital';

  @override
  String get stage1Title => 'Fundamentos';

  @override
  String get stage2Subtitle => 'Identificar intentos de trampa';

  @override
  String get stage2Title => 'Phishing';

  @override
  String get stage3Subtitle => 'Crea claves seguras y protégete';

  @override
  String get stage3Title => 'Contraseñas';

  @override
  String get stage4Subtitle => 'Protege tu privacidad en plataformas';

  @override
  String get stage4Title => 'Redes Sociales';

  @override
  String get stage5Subtitle => 'Desinformación y sitios confiables';

  @override
  String get stage5Title => 'Navegación segura';

  @override
  String get stage6Subtitle => 'Controla tus datos personales';

  @override
  String get stage6Title => 'Privacidad Digital';

  @override
  String get stage7Subtitle => 'Protección completa para expertos';

  @override
  String get stage7Title => 'Ciberseguridad Avanzada';

  @override
  String get stage8Subtitle => 'Conviértete en un guardián digital';

  @override
  String get stage8Title => 'Experto Digital';

  @override
  String stageProgress(Object percent) {
    return 'Progreso de etapa: $percent por ciento';
  }

  @override
  String get startText => 'Comenzar';

  @override
  String get statsExcellent => '¡Excelente!';

  @override
  String get statsIncredible => '¡Increíble!';

  @override
  String get statsKeepTrying => 'Sigue intentándolo.';

  @override
  String get statsNoData => 'No hay datos de lección';

  @override
  String get statsNoErrors => '¡Sin errores!';

  @override
  String get statsReceiveXp => 'RECIBIR XP';

  @override
  String get statsSpeed => 'Velocidad';

  @override
  String get statsStartStage1 => 'Empezarás desde la Etapa 1, Lección 1';

  @override
  String get statsStartStage2 => 'Empezarás desde la Etapa 2, Lección 1';

  @override
  String get statsWellDone => '¡Bien hecho!';

  @override
  String get statusCompleted => 'completada';

  @override
  String get storeAdEarnXp => 'Gana XP mirando';

  @override
  String get storeAdRewardMessage => '+1 Donación por ver el anuncio';

  @override
  String get storeAdWatchVideo => 'Ve un video de 30 segundos';

  @override
  String storeBuyItem(Object cost, Object item) {
    return 'Comprar $item por $cost donaciones';
  }

  @override
  String get storeCategoryConsumables => 'Consumibles';

  @override
  String get storeCategoryCosmetics => 'Cosméticos';

  @override
  String get storeCategoryThemes => 'Temas';

  @override
  String get storeChestAvailable => '¡Cofre Diario Disponible!';

  @override
  String get storeChestComeBack => 'Vuelve mañana';

  @override
  String storeChestExpiresIn(Object gems) {
    return '$gems donados — expira a medianoche';
  }

  @override
  String get storeChestRenews => 'Tu cofre se renueva cada día';

  @override
  String get storeClaimError =>
      'No se pudo reclamar la recompensa. Por favor, inténtalo de nuevo.';

  @override
  String storeConfirmMessage(Object cost, Object item) {
    return '¿Deseas comprar $item por $cost donaciones?';
  }

  @override
  String get storeConfirmTitle => 'Confirmar compra';

  @override
  String get storeDonate => 'Donar';

  @override
  String storeDonateSubtitle(Object price) {
    return 'Desde $price';
  }

  @override
  String get storeDonationsLabel => 'donaciones';

  @override
  String get storeGemTipAchievement => 'Logros: gemas según dificultad';

  @override
  String get storeGemTipChest => 'Abre cofres: gemas según el cofre';

  @override
  String get storeGemTipFirstLesson => 'Primera lección del día: +10 gemas';

  @override
  String get storeGemTipLesson =>
      'Completa lecciones: 5 gemas por respuesta correcta';

  @override
  String get storeGemTipMission => 'Misiones diarias: +12 gemas';

  @override
  String get storeGemTipPerfect => 'Lección perfecta: +20 gemas extra';

  @override
  String get storeGemTipStreak => 'Rachas: hasta +150 gemas';

  @override
  String get storeHowToEarnGems => '¿Cómo conseguir gemas?';

  @override
  String get storeNoItems => 'No hay artículos disponibles en este momento.';

  @override
  String get storeOpen => 'Abrir';

  @override
  String get storePersonalization => 'Personalización';

  @override
  String get storeProtectStreak => 'Protege tu racha';

  @override
  String get storeDailyChestClaim => 'Reclamar';

  @override
  String storeDailyChestReward(Object xp) {
    return '¡+$xp XP!';
  }

  @override
  String get storeDailyChestSubtitle => 'Reclama tu recompensa diaria gratuita';

  @override
  String get storeDailyChestTitle => 'Cofre diario';

  @override
  String get storePurchaseFailed =>
      'Error al validar la compra. Inténtalo de nuevo.';

  @override
  String get storePurchaseSuccess => '¡Compra exitosa!';

  @override
  String get storeAlreadyOwned => 'Ya tienes este artículo.';

  @override
  String get storeShieldLimitReached => 'Límite de protectores alcanzado';

  @override
  String get storeSupport => 'Apóyanos';

  @override
  String get storeSupportTiers => 'Niveles de apoyo';

  @override
  String get storeThankYou => '¡Gracias por tu apoyo!';

  @override
  String get storeTitle => 'Tienda';

  @override
  String get storeWatch => 'Ver';

  @override
  String storeWhatsappPackages(Object price) {
    return 'Paquetes desde $price — Pago por WhatsApp';
  }

  @override
  String get streakAchievements => 'Logros y medallas por constancia';

  @override
  String get streakBadge => 'RACHA';

  @override
  String get streakChest100Message => '100 días. Leyenda.';

  @override
  String get streakChest100Title => '¡Racha de 100 días!';

  @override
  String get streakChest14Message => 'Dos semanas de constancia. ¡Sigue así!';

  @override
  String get streakChest14Title => '¡Racha de 14 días!';

  @override
  String get streakChest30Message => 'Un mes. Eres un Guardián Digital.';

  @override
  String get streakChest30Title => '¡Racha de 30 días!';

  @override
  String get streakChest7Message =>
      'Una semana protegiendo tu identidad digital.';

  @override
  String get streakChest7Title => '¡Racha de 7 días!';

  @override
  String get streakCommitButton => 'MANTENER MI COMPROMISO';

  @override
  String get streakCurrent => 'Racha actual';

  @override
  String streakCurrentProgress(Object goal, Object current) {
    return 'Racha actual: $current / $goal días';
  }

  @override
  String get streakDayFri => 'Vie';

  @override
  String get streakDayLabel => 'días de racha';

  @override
  String get streakDayMon => 'Lu';

  @override
  String get streakDayOfStreak => 'días de racha';

  @override
  String get streakDaySat => 'Sá';

  @override
  String get streakDaySun => 'Dom';

  @override
  String get streakDayThu => 'Jue';

  @override
  String get streakDayTue => 'T';

  @override
  String get streakDayWed => 'X';

  @override
  String streakDays(Object count) {
    return '$count días';
  }

  @override
  String streakDaysCount(Object count) {
    return '$count días de racha';
  }

  @override
  String streakDaysCountPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# días de racha',
      one: '# día de racha',
    );
    return '$_temp0';
  }

  @override
  String get streakEmotional100 => '100 días de protección constante. Leyenda.';

  @override
  String get streakEmotional14 =>
      'Dos semanas de constancia. Tu escudo brilla.';

  @override
  String get streakEmotional3 =>
      '3 días seguidos. Estás construyendo un hábito sólido.';

  @override
  String get streakEmotional30 =>
      'Un mes de aprendizaje. Tu dedicación te hace un Guardián Digital.';

  @override
  String get streakEmotional50 => '50 días de protección digital constante.';

  @override
  String get streakEmotional7 =>
      'Una semana protegiendo tu identidad digital. ¡Sigue así!';

  @override
  String get streakFireCard => 'Tarjeta de racha de fuego';

  @override
  String get streakFireCardA11y => 'Tarjeta de racha de fuego';

  @override
  String get streakFireCardLabel => 'Racha de Fuego';

  @override
  String get streakFreeze => 'Protector de racha';

  @override
  String get streakFreezeDescription => 'Mantén tu racha al fallar un día';

  @override
  String get streakFreezeUsed => 'Un escudo de hielo protegió tu racha.';

  @override
  String get streakFrozen => 'Racha congelada';

  @override
  String get streakGotIt => 'ENTENDIDO';

  @override
  String get streakKeepAlive => '¡Mantén tu racha activa!';

  @override
  String get streakKeepAliveDesc =>
      'Completa una lección cada día para mantener tu racha.\nCada día cuenta para fortalecer tu escudo digital.';

  @override
  String get streakKeepCommitment => 'MANTENER MI COMPROMISO';

  @override
  String get streakLongest => 'Mejor racha';

  @override
  String get streakMessage100Days => '100 días. Leyenda.';

  @override
  String get streakMessage14Days => 'Dos semanas. Tu escudo brilla.';

  @override
  String get streakMessage30Days => 'Un mes. Eres un Guardián Digital.';

  @override
  String get streakMessage3Days => '3 días. Buen comienzo.';

  @override
  String get streakMessage50Days => '50 días de protección constante.';

  @override
  String get streakMessage7Days => '¡Una semana! Sigue así.';

  @override
  String get streakMessageActive =>
      '¡Racha activa! La constancia es tu mejor arma hoy.';

  @override
  String get streakMessageAtRisk => '¡Tu racha está en riesgo!';

  @override
  String get streakMessageCloser => 'Un día más, un paso más hacia tu meta.';

  @override
  String get streakMessageEachDay =>
      'Cada día cuenta. Tu compromiso te hace más fuerte.';

  @override
  String get streakMessageKeepGoing =>
      '¡Sigue así! La disciplina de hoy es la victoria de mañana.';

  @override
  String get streakMessageKeepProtecting => '¡Sigue protegiéndote!';

  @override
  String get streakMessageNew =>
      '¡Una nueva racha! Practica todos los días y ayuda a que crezca.';

  @override
  String get streakMessageStartActivities =>
      'Completa actividades para iniciar tu racha.';

  @override
  String get streakMsg1 =>
      '¡Una nueva racha! Practica cada día y ayúdala a crecer.';

  @override
  String get streakMsg2 => '¡Racha activa! La constancia es tu mejor arma hoy.';

  @override
  String get streakMsg3 => 'Cada día cuenta. Tu compromiso te hace más fuerte.';

  @override
  String get streakMsg4 =>
      '¡Sigue así! La disciplina de hoy es la victoria de mañana.';

  @override
  String get streakMsg5 => 'Un día más, un paso más cerca de tu meta.';

  @override
  String get streakNoActiveStreak => 'Sin racha activa';

  @override
  String get streakReminder => 'Recordatorios de racha';

  @override
  String get streakReminderSubtitle =>
      'Recibe recordatorios para mantener tu racha';

  @override
  String get streakRewards => 'Recompensas exclusivas al alcanzar metas';

  @override
  String get streakShieldActive =>
      'Escudo activo — ¡tu racha está protegida hoy!';

  @override
  String get streakShieldOnboarding =>
      'Compra un escudo para proteger tu racha si te pierdes un día.';

  @override
  String get streakStrongerShield => 'Escudo más fuerte cada día';

  @override
  String get streakTitle => 'Mi Racha';

  @override
  String get streakTitleShort => 'Racha';

  @override
  String get summarizeButton => 'Resumen rápido';

  @override
  String get summaryCommitment => 'Compromiso';

  @override
  String get summaryDailyGoal => 'Meta diaria';

  @override
  String get summaryGoodWork => '¡Buen trabajo!';

  @override
  String get summaryInterest => 'Interés';

  @override
  String get summaryKeepPracticing => 'Sigue practicando';

  @override
  String get summaryKnowledge => 'Conocimiento';

  @override
  String get summaryLearning => 'Aprendizaje';

  @override
  String get summaryMotivations => 'Motivaciones';

  @override
  String get summaryOrigin => 'Origen';

  @override
  String get summaryPerfect => '¡Perfecto!';

  @override
  String get summaryReady =>
      'Todo listo para empezar tu viaje en seguridad digital.';

  @override
  String summaryStreakDays(Object days) {
    return '+$days día(s)';
  }

  @override
  String get summaryXpBonus => 'Bonus XP';

  @override
  String get summaryXpEarned => 'XP ganado';

  @override
  String get supporterBadge => 'Supporter';

  @override
  String get syncSnackbar => 'Progreso sincronizado';

  @override
  String get syncStatus => 'Estado de sincronización';

  @override
  String get syncing => 'Sincronizando...';

  @override
  String get termsConditions => 'Términos y condiciones';

  @override
  String get thankYouForSupport => '¡Gracias por tu apoyo!';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeDarkLabel => 'Oscuro';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeLightLabel => 'Claro';

  @override
  String get themeSystem => 'Según el sistema';

  @override
  String get themeSystemLabel => 'Sistema';

  @override
  String get themeTitle => 'Apariencia';

  @override
  String get tierBasic => 'Básico';

  @override
  String get tierCrystal => 'Cristal';

  @override
  String get tierGlow => 'Brillo';

  @override
  String get tierInactive => 'Inactivo';

  @override
  String get tierLegendary => 'Legendario';

  @override
  String get tierParticles => 'Partículas';

  @override
  String get totalProgress => 'Progreso total';

  @override
  String get tryAgain => 'Conéctate e inténtalo nuevamente.';

  @override
  String tutorLessonsProgress(Object completed, Object required) {
    return '$completed / $required lecciones';
  }

  @override
  String get tutorLocked => 'Tutor IA Bloqueado';

  @override
  String get tutorLockedDescription =>
      'Completa al menos 10 lecciones para desbloquear a Sage, tu tutor personal de ciberseguridad.';

  @override
  String tutorMotivationAlmost(Object count) {
    return 'Ya casi, solo te faltan $count lecciones. ¡Sigue así!';
  }

  @override
  String get tutorMotivationGeneral =>
      'Cada lección te acerca más a tu tutor personal de ciberseguridad.';

  @override
  String tutorMotivationGood(Object count) {
    return '¡Buen ritmo! Te faltan $count lecciones para acceder a Sage.';
  }

  @override
  String get tutorSampleAnswer1 =>
      'Nunca compartas tu contraseña. Usa un gestor de contraseñas y activa la autenticación de dos factores.';

  @override
  String get tutorSampleQuestion1 =>
      '¿Qué debo hacer si recibo un correo sospechoso?';

  @override
  String get tutorSampleQuestion2 => '¿Cómo puedo crear una contraseña segura?';

  @override
  String get tutorSampleTitle => 'Conversación de ejemplo';

  @override
  String get tutorTitle => 'Tutor IA';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialSkip => 'Omitir';

  @override
  String get tutorialStart => '¡Vamos!';

  @override
  String get tutorialStep1 => '¡Hola! Soy Sage, tu guía de ciberseguridad.';

  @override
  String get tutorialStep2 =>
      'Completa lecciones para ganar donaciones y subir de nivel.';

  @override
  String get tutorialStep3 =>
      'Mantén tu racha diaria para desbloquear cofres especiales.';

  @override
  String get tutorialStep4 =>
      'Tu misión: protege tu identidad digital. ¡Aprendamos juntos!';

  @override
  String get unknownLabel => 'Desconocido';

  @override
  String get updateChangelog => 'Actualizaciones y novedades';

  @override
  String get updateChangelogDesc =>
      'Nueva pantalla en la barra inferior que muestra el historial de cambios y novedades de la app.';

  @override
  String get updateChestSystem => 'Cofres de racha y lección';

  @override
  String get updateChestSystemDesc =>
      'Nuevo sistema de cofres: cofre diario por racha, cofre de lección cada 3/5/6/10 lecciones completadas.';

  @override
  String get updateDailyMissions => 'Misiones diarias';

  @override
  String get updateDailyMissionsDesc =>
      'Sistema de misiones diarias con recompensas en donaciones y experiencia.';

  @override
  String get updateEnergySystem => 'Sistema de Energía';

  @override
  String get updateEnergySystemDesc =>
      'Ahora cada lección consume energía. Responde bien para gastar solo 1, fallar cuesta 2. Los combos de aciertos regeneran energía. Al llegar a 0 no puedes continuar la lección.';

  @override
  String get updateFirstVersion => 'Primera versión';

  @override
  String get updateFirstVersionDesc =>
      'Lanzamiento inicial con lecciones interactivas, racha diaria, donaciones, tienda y perfil de usuario.';

  @override
  String get updateImprovedIcons => 'Iconos de objetos mejorados';

  @override
  String get updateImprovedIconsDesc =>
      'Todos los objetos especiales ahora tienen iconos personalizados y más llamativos en la tienda y el inventario.';

  @override
  String get updateInfiniteEnergy => 'Energía Infinita';

  @override
  String get updateInfiniteEnergyDesc =>
      'Nuevo objeto especial en la tienda que otorga energía ilimitada por tiempo limitado. Actívalo desde tu inventario.';

  @override
  String get updateLessonBoosters => 'Potenciadores de lección';

  @override
  String get updateLessonBoostersDesc =>
      'Nuevos objetos: Boost de XP (2x), Multiplicador de XP (2x en cofres), Boost de suerte (2x probabilidades). Se compran y activan desde la tienda.';

  @override
  String get updateMercadoPago => 'Mercado Pago integrado';

  @override
  String get updateMercadoPagoDesc =>
      'Pagos directos con Mercado Pago para paquetes de donaciones y bundles. También disponible el pago por WhatsApp.';

  @override
  String get updateNew => 'NUEVO';

  @override
  String get updateProgrammaticMascot => 'Mascota programática';

  @override
  String get updateProgrammaticMascotDesc =>
      'La mascota ahora se dibuja con CustomPainter. 29 emociones, sin assets, transiciones suaves entre emociones.';

  @override
  String get updateStreakProtectorImproved => 'Protector de racha mejorado';

  @override
  String get updateStreakProtectorImprovedDesc =>
      'Límite máximo de 2 protectores. Al alcanzarlo, se muestran ofertas de potenciadores en su lugar.';

  @override
  String get updateTestFix => 'Corrección de pruebas unitarias';

  @override
  String get updateTestFixDesc =>
      'Se corrigieron 7 pruebas fallidas. Ahora todas las pruebas pasan correctamente (419 tests). 0 issues de análisis.';

  @override
  String get updateTypeFeature => 'NUEVA FUNCIÓN';

  @override
  String get updateTypeFix => 'CORRECCIÓN';

  @override
  String get updateTypeImprovement => 'MEJORA';

  @override
  String get updateTypedRoutes => 'Rutas tipadas con GoRouter Builder';

  @override
  String get updateTypedRoutesDesc =>
      'Las rutas de splash y welcome ahora son tipadas, detectando errores en tiempo de compilación.';

  @override
  String get updates => 'Actualizaciones';

  @override
  String get updatesTitle => 'Noticias y actualizaciones';

  @override
  String get verifyEmailCheckButton => 'Ya verifiqué';

  @override
  String verifyEmailMessage(Object email) {
    return 'Enviamos un enlace de verificación a $email. Haz clic en el enlace para activar tu cuenta.';
  }

  @override
  String get verifyEmailNotVerified =>
      'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.';

  @override
  String get verifyEmailResendButton => 'Reenviar correo de verificación';

  @override
  String get verifyEmailResendError =>
      'No se pudo reenviar el correo. Por favor, intenta de nuevo.';

  @override
  String get verifyEmailSent =>
      'Correo de verificación enviado. Revisa tu bandeja de entrada.';

  @override
  String get verifyEmailSignOut => 'Cerrar sesión';

  @override
  String get verifyEmailSuccess => '¡Correo verificado! Bienvenido a SAGEN.';

  @override
  String get verifyEmailTitle => 'Verifica tu correo electrónico';

  @override
  String get viewAchievements => 'Ver logros';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get weeklyChestComplete => '¡Cofre semanal obtenido!';

  @override
  String get weeklyChestDesc =>
      'Completa 5 misiones diarias para un cofre épico';

  @override
  String get weeklyChestProgress => 'Progreso del cofre semanal';

  @override
  String weeklyChestProgressCount(Object done, Object total) {
    return '$done/$total';
  }

  @override
  String get welcomeLoginButton => 'YA TENGO UNA CUENTA';

  @override
  String get welcomeStartButton => 'EMPIEZA AHORA';

  @override
  String get welcomeSubtitle =>
      'Análisis inteligente y seguridad digital.\nGratis de por vida.';

  @override
  String get wizardAllAbove => 'Todo lo anterior';

  @override
  String get wizardAppStore => 'App Store';

  @override
  String get wizardArticles => 'Leer artículos';

  @override
  String get wizardBoostStudies => 'Impulsar mis estudios';

  @override
  String get wizardChatSage => 'Chatea con Sage';

  @override
  String get wizardCommit14 => '14 días';

  @override
  String get wizardCommit14Sub => '80 donaciones';

  @override
  String get wizardCommit30 => '30 días';

  @override
  String get wizardCommit30Sub => '200 donaciones';

  @override
  String get wizardCommit50 => '50 días';

  @override
  String get wizardCommit50Sub => '400 donaciones';

  @override
  String get wizardCommit7 => '7 días';

  @override
  String get wizardCommit7Sub => '30 donaciones';

  @override
  String get wizardCommitment => 'Elige tu compromiso';

  @override
  String get wizardCommitmentSage => 'Selecciona tus metas de constancia';

  @override
  String get wizardConfirmed => 'Compromiso confirmado';

  @override
  String get wizardConfirmedSage => '¡Has configurado tu ruta de aprendizaje!';

  @override
  String get wizardCuriosity => 'Por curiosidad';

  @override
  String get wizardDetectScams => 'Detectar estafas';

  @override
  String get wizardFacebook => 'Facebook';

  @override
  String get wizardFriends => 'Amigos';

  @override
  String get wizardGoal10 => '10 min';

  @override
  String get wizardGoal10Sub => 'Normal';

  @override
  String get wizardGoal15 => '15 min';

  @override
  String get wizardGoal15Sub => 'Serio';

  @override
  String get wizardGoal3 => '3 min';

  @override
  String get wizardGoal30 => '30 min';

  @override
  String get wizardGoal30Sub => 'Intenso';

  @override
  String get wizardGoal3Sub => 'Relajado';

  @override
  String get wizardGoogle => 'Google';

  @override
  String get wizardHaveFun => 'Divertirme';

  @override
  String get wizardHowDidYouFind => '¿Cómo te enteraste de SAGEN?';

  @override
  String get wizardHowDidYouFindSage => 'Dime, ¿cómo nos encontraste?';

  @override
  String get wizardHowFound => '¿Cómo conociste SAGEN?';

  @override
  String get wizardHowFoundSage => 'Cuéntame, ¿cómo nos encontraste?';

  @override
  String get wizardHowMuchKnow => '¿Cuánto sabes de seguridad digital?';

  @override
  String get wizardHowMuchKnowSage => '¿Qué tanto sabes del tema?';

  @override
  String get wizardHowMuchSage => '¿Cuánto sabes sobre el tema?';

  @override
  String get wizardHowMuchYouKnow => '¿Cuánto sabes sobre seguridad digital?';

  @override
  String get wizardHowPrefer => '¿Cómo prefieres aprender?';

  @override
  String get wizardHowPreferSage => 'Elige tus formas preferidas de aprender';

  @override
  String get wizardInstagram => 'Instagram';

  @override
  String get wizardLevel1 => 'Soy principiante';

  @override
  String get wizardLevel1Sub => 'Nunca he explorado este tema';

  @override
  String get wizardLevel2 => 'Conozco algunos conceptos';

  @override
  String get wizardLevel2Sub => 'Reconozco algunos términos';

  @override
  String get wizardLevel3 => 'Puedo defenderme';

  @override
  String get wizardLevel3Sub => 'Entiendo y practico los fundamentos';

  @override
  String get wizardLevel4 => 'Entiendo varios temas';

  @override
  String get wizardLevel4Sub => 'Domino múltiples conceptos';

  @override
  String get wizardLevel5 => 'Conozco bien el tema';

  @override
  String get wizardLevel5Sub => 'Puedo debatir temas avanzados';

  @override
  String get wizardLinks => 'Analizar enlaces';

  @override
  String get wizardNews => 'Noticias';

  @override
  String get wizardOther => 'Otro';

  @override
  String get wizardPrepareWork => 'Prepárame para el trabajo';

  @override
  String get wizardProtect => 'Protegerme';

  @override
  String get wizardProtectAccounts => 'Proteger mis cuentas';

  @override
  String get wizardProtectFamily => 'Proteger a mi familia';

  @override
  String get wizardProtectPrivacy => 'Proteger mi privacidad';

  @override
  String get wizardQuizzes => 'Practicar con cuestionarios';

  @override
  String get wizardSafeBrowsing => 'Navega con seguridad';

  @override
  String get wizardTV => 'TV';

  @override
  String get wizardTikTok => 'TikTok';

  @override
  String get wizardTimeDedicate => '¿Cuánto tiempo puedes dedicar al día?';

  @override
  String get wizardTimeSage => 'Elige tu ritmo de aprendizaje ideal';

  @override
  String get wizardVideos => 'Ver videos educativos';

  @override
  String get wizardWelcome => '¡Bienvenido a SAGEN!';

  @override
  String get wizardWelcomeSage =>
      '¡Hola! Soy Sage, tu guía de seguridad digital. ¿Empezamos?';

  @override
  String get wizardWelcomeTitle => '¡Bienvenido a SAGEN!';

  @override
  String get wizardWhatLearn => '¿Qué te gustaría aprender?';

  @override
  String get wizardWhatLearnSage => '¿Qué te gustaría aprender primero?';

  @override
  String get wizardWhyLearn => '¿Por qué quieres aprender?';

  @override
  String get wizardWhyLearnSage =>
      '¿Por qué quieres aprender sobre seguridad digital?';

  @override
  String get wizardYouTube => 'YouTube';

  @override
  String get xpBoostLabel => 'x2 Boost de XP';

  @override
  String get xpLevelUp => 'Level Up!';

  @override
  String xpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String xpRewardLabel(Object gems) {
    return '+$gems XP';
  }

  @override
  String get yourActivity => 'Tu actividad';

  @override
  String get yourLearning => 'Tu aprendizaje';

  @override
  String get xpLabel => 'XP';

  @override
  String get xpMultiplier => 'x2 XP';

  @override
  String get chatTypingIndicator => 'Sage está escribiendo...';

  @override
  String get demoModeOffline => 'MODO DEMO — Sin conexión';

  @override
  String get errorSync => 'Error de sincronización';

  @override
  String shareChestText(Object items, Object type) {
    return '¡Obtuve $items de un cofre $type en SAGEN!';
  }

  @override
  String get paymentMethodsLocal => 'WhatsApp / Yape / Plin';

  @override
  String get paymentMethodsMercadoPago => 'Mercado Pago';

  @override
  String get streakFlame => 'Llama de racha';

  @override
  String treasureChest(Object type) {
    return 'Cofre del tesoro $type';
  }

  @override
  String get errorRestart => 'Reiniciar';

  @override
  String get chatEmptyDesc =>
      'Pregunta sobre ciberseguridad o elige una sugerencia rápida.';

  @override
  String get continueButton => 'Continuar';

  @override
  String get shareButton => 'Compartir';

  @override
  String get tapToContinue => 'Toca para continuar';

  @override
  String get paymentSuccessful => 'Pago exitoso';

  @override
  String get errorLoadingQuestions => 'Error al cargar preguntas.';

  @override
  String get errorGenericShort => 'Error';

  @override
  String quizTimeRemaining(Object time) {
    return 'Tiempo restante: $time';
  }

  @override
  String get quizVerdictCorrect => 'Respuesta correcta';

  @override
  String get quizVerdictIncorrect => 'Respuesta incorrecta';

  @override
  String get exitQuizTitle => '¿Seguro que quieres salir de la lección?';

  @override
  String get exitQuizContent => '¿Seguro que quieres salir del cuestionario?';

  @override
  String currentStreakDays(Object count) {
    return 'Racha actual: $count días';
  }

  @override
  String get activityMap30Days => 'Mapa de actividad de los últimos 30 días';

  @override
  String courseProgressLabel(Object percent) {
    return 'Progreso total del curso: $percent%';
  }

  @override
  String stageProgressLabel(Object percent) {
    return 'Progreso de etapa: $percent%';
  }

  @override
  String collapseSession(Object title) {
    return 'Colapsar sesión: $title';
  }

  @override
  String expandSession(Object title) {
    return 'Expandir sesión: $title';
  }

  @override
  String xpGainedLabel(Object xp) {
    return '+$xp experiencia ganada';
  }

  @override
  String accuracyPercentLabel(Object percent) {
    return 'Precisión: $percent%';
  }

  @override
  String timeLabel(Object time) {
    return 'Tiempo: $time';
  }

  @override
  String livesRemainingLabel(Object count) {
    return 'Vidas restantes: $count de 3';
  }

  @override
  String get miniGameExitTitle => '¿Salir del juego?';

  @override
  String get miniGameExitContent =>
      'Perderás tu progreso actual. ¿Estás seguro?';

  @override
  String get paymentCancelTitle => 'Cancelar pago';

  @override
  String get paymentCancelContent =>
      '¿Seguro que quieres cancelar el pago? Se perderá el progreso.';

  @override
  String resultXpGained(Object xp) {
    return '$xp ganados';
  }

  @override
  String resultAccuracyLabel(Object percent) {
    return 'Precisión: $percent%';
  }

  @override
  String resultLivesLabel(Object count) {
    return 'Vidas: $count';
  }

  @override
  String get storeNewChestHint => 'Nuevo cofre disponible';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String gemBalanceLabel(Object count) {
    return 'Saldo de gemas: $count';
  }

  @override
  String wizardStepLabel(Object step) {
    return 'Paso $step';
  }

  @override
  String chestRewardShareText(Object items, Object type) {
    return '¡Obtuve $items de un cofre $type en SAGEN!';
  }

  @override
  String get gemRainAnimationLabel => 'Animación de gemas cayendo';
}
