import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('es'),
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @achievementConqueror.
  ///
  /// In es, this message translates to:
  /// **'Conquistador'**
  String get achievementConqueror;

  /// No description provided for @achievementConquerorDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa tu primera etapa'**
  String get achievementConquerorDesc;

  /// No description provided for @achievementConstant.
  ///
  /// In es, this message translates to:
  /// **'Constante'**
  String get achievementConstant;

  /// No description provided for @achievementConstantDesc.
  ///
  /// In es, this message translates to:
  /// **'Racha de 3 días'**
  String get achievementConstantDesc;

  /// No description provided for @achievementCurious.
  ///
  /// In es, this message translates to:
  /// **'Curioso'**
  String get achievementCurious;

  /// No description provided for @achievementCuriousDesc.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage 10 veces'**
  String get achievementCuriousDesc;

  /// No description provided for @achievementCyberGuardian.
  ///
  /// In es, this message translates to:
  /// **'Guardián Cibernético'**
  String get achievementCyberGuardian;

  /// No description provided for @achievementCyberGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 50 lecciones'**
  String get achievementCyberGuardianDesc;

  /// No description provided for @achievementDigitalMaster.
  ///
  /// In es, this message translates to:
  /// **'Maestro Digital'**
  String get achievementDigitalMaster;

  /// No description provided for @achievementDigitalMasterDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa todas las etapas'**
  String get achievementDigitalMasterDesc;

  /// No description provided for @achievementDigitalStudent.
  ///
  /// In es, this message translates to:
  /// **'Estudiante Digital'**
  String get achievementDigitalStudent;

  /// No description provided for @achievementDigitalStudentDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 10 lecciones'**
  String get achievementDigitalStudentDesc;

  /// No description provided for @achievementDigitalWeek.
  ///
  /// In es, this message translates to:
  /// **'Semana Digital'**
  String get achievementDigitalWeek;

  /// No description provided for @achievementDigitalWeekDesc.
  ///
  /// In es, this message translates to:
  /// **'Racha de 7 días'**
  String get achievementDigitalWeekDesc;

  /// No description provided for @achievementFirstShield.
  ///
  /// In es, this message translates to:
  /// **'Primer Escudo'**
  String get achievementFirstShield;

  /// No description provided for @achievementFirstShieldDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa tu primera lección'**
  String get achievementFirstShieldDesc;

  /// No description provided for @achievementGuardian.
  ///
  /// In es, this message translates to:
  /// **'Guardián'**
  String get achievementGuardian;

  /// No description provided for @achievementGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 25 lecciones'**
  String get achievementGuardianDesc;

  /// No description provided for @achievementLearner.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz'**
  String get achievementLearner;

  /// No description provided for @achievementLearnerDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 5 lecciones'**
  String get achievementLearnerDesc;

  /// No description provided for @achievementLegendaryStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha Legendaria'**
  String get achievementLegendaryStreak;

  /// No description provided for @achievementLegendaryStreakDesc.
  ///
  /// In es, this message translates to:
  /// **'Racha de 30 días'**
  String get achievementLegendaryStreakDesc;

  /// No description provided for @achievementLocked.
  ///
  /// In es, this message translates to:
  /// **'???'**
  String get achievementLocked;

  /// No description provided for @achievementPerfect.
  ///
  /// In es, this message translates to:
  /// **'Perfecto'**
  String get achievementPerfect;

  /// No description provided for @achievementPerfectDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección sin errores'**
  String get achievementPerfectDesc;

  /// No description provided for @acquired.
  ///
  /// In es, this message translates to:
  /// **'Obtenido'**
  String get acquired;

  /// No description provided for @analyzeLink.
  ///
  /// In es, this message translates to:
  /// **'Analizar enlace'**
  String get analyzeLink;

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'SAGEN'**
  String get appName;

  /// No description provided for @authBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get authBack;

  /// No description provided for @authCanceled.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión cancelado'**
  String get authCanceled;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authDefault.
  ///
  /// In es, this message translates to:
  /// **'Error de autenticación'**
  String get authDefault;

  /// No description provided for @authDeleteAccountFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo eliminar la cuenta. Intenta de nuevo.'**
  String get authDeleteAccountFailed;

  /// No description provided for @authEmailError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo'**
  String get authEmailError;

  /// No description provided for @authEmailInUse.
  ///
  /// In es, this message translates to:
  /// **'Ya existe una cuenta con este correo'**
  String get authEmailInUse;

  /// No description provided for @authEmailInvalid.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico inválido'**
  String get authEmailInvalid;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailLabel;

  /// No description provided for @authEnterEmailError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu correo electrónico'**
  String get authEnterEmailError;

  /// No description provided for @authFacebookButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Facebook'**
  String get authFacebookButton;

  /// No description provided for @authFacebookError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Facebook'**
  String get authFacebookError;

  /// No description provided for @authFirebaseUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Firebase no está disponible'**
  String get authFirebaseUnavailable;

  /// No description provided for @authForgotPasswordButton.
  ///
  /// In es, this message translates to:
  /// **'RESTABLECER CONTRASEÑA'**
  String get authForgotPasswordButton;

  /// No description provided for @authForgotPasswordDesc.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un enlace a tu correo para restablecer tu contraseña.'**
  String get authForgotPasswordDesc;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get authForgotPasswordTitle;

  /// No description provided for @authGoogleButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authGoogleButton;

  /// No description provided for @authGoogleError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google'**
  String get authGoogleError;

  /// No description provided for @authInvalidCredential.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos'**
  String get authInvalidCredential;

  /// No description provided for @authInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'El formato del correo no es válido'**
  String get authInvalidEmail;

  /// No description provided for @authLoginButton.
  ///
  /// In es, this message translates to:
  /// **'INGRESAR'**
  String get authLoginButton;

  /// No description provided for @authLoginError.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get authLoginError;

  /// No description provided for @authLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus datos'**
  String get authLoginTitle;

  /// No description provided for @authNetworkError.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get authNetworkError;

  /// No description provided for @authNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get authNoAccount;

  /// No description provided for @authNotAuthenticated.
  ///
  /// In es, this message translates to:
  /// **'No hay usuario autenticado'**
  String get authNotAuthenticated;

  /// No description provided for @authNotFound.
  ///
  /// In es, this message translates to:
  /// **'No hay cuenta registrada con este correo'**
  String get authNotFound;

  /// No description provided for @authNotVerified.
  ///
  /// In es, this message translates to:
  /// **'Aún no has verificado tu correo. Revisa tu bandeja de entrada.'**
  String get authNotVerified;

  /// No description provided for @authNullToken.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener el token de Facebook'**
  String get authNullToken;

  /// No description provided for @authNullUser.
  ///
  /// In es, this message translates to:
  /// **'No se pudo obtener el usuario'**
  String get authNullUser;

  /// No description provided for @authPasswordError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña'**
  String get authPasswordError;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordMinError.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener 8+ caracteres con mayúscula, minúscula y un número'**
  String get authPasswordMinError;

  /// No description provided for @authRateLimited.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera unos segundos.'**
  String get authRateLimited;

  /// No description provided for @authReauthError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar las credenciales. Intenta de nuevo.'**
  String get authReauthError;

  /// No description provided for @authReauthRequiredForDelete.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu contraseña para eliminar tu cuenta.'**
  String get authReauthRequiredForDelete;

  /// No description provided for @authRecoveryEmailSentDesc.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.'**
  String get authRecoveryEmailSentDesc;

  /// No description provided for @authRecoveryEmailSentMessage.
  ///
  /// In es, this message translates to:
  /// **'Correo de recuperación enviado'**
  String get authRecoveryEmailSentMessage;

  /// No description provided for @authRecoveryEmailSentTitle.
  ///
  /// In es, this message translates to:
  /// **'Correo enviado'**
  String get authRecoveryEmailSentTitle;

  /// No description provided for @authRecoveryError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo enviar el correo de recuperación'**
  String get authRecoveryError;

  /// No description provided for @authResendEmailError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reenviar el correo de verificación'**
  String get authResendEmailError;

  /// No description provided for @authSendEmailError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar correo'**
  String get authSendEmailError;

  /// No description provided for @authSendLink.
  ///
  /// In es, this message translates to:
  /// **'Enviar enlace'**
  String get authSendLink;

  /// No description provided for @authTooManyRequests.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos. Espera un momento.'**
  String get authTooManyRequests;

  /// No description provided for @authUnknown.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado'**
  String get authUnknown;

  /// No description provided for @authVerifyError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo verificar. Intenta de nuevo.'**
  String get authVerifyError;

  /// No description provided for @authWeakPassword.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres'**
  String get authWeakPassword;

  /// No description provided for @authWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta'**
  String get authWrongPassword;

  /// No description provided for @back.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get back;

  /// No description provided for @backButton.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get backButton;

  /// No description provided for @biometricReason.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea SAGEN para continuar'**
  String get biometricReason;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @challengeComplete.
  ///
  /// In es, this message translates to:
  /// **'Completa la frase'**
  String get challengeComplete;

  /// No description provided for @challengeCreatePassword.
  ///
  /// In es, this message translates to:
  /// **'Crear contraseña'**
  String get challengeCreatePassword;

  /// No description provided for @challengeDetectRisk.
  ///
  /// In es, this message translates to:
  /// **'Detectar riesgo'**
  String get challengeDetectRisk;

  /// No description provided for @challengeMiniCase.
  ///
  /// In es, this message translates to:
  /// **'Caso real'**
  String get challengeMiniCase;

  /// No description provided for @challengeMultiple.
  ///
  /// In es, this message translates to:
  /// **'Opción múltiple'**
  String get challengeMultiple;

  /// No description provided for @challengeTrueFalse.
  ///
  /// In es, this message translates to:
  /// **'Verdadero / Falso'**
  String get challengeTrueFalse;

  /// No description provided for @challengeWhatWouldYouDo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué harías aquí?'**
  String get challengeWhatWouldYouDo;

  /// No description provided for @challenge_streak_milestone_desc.
  ///
  /// In es, this message translates to:
  /// **'Mantén una racha de {count} días'**
  String challenge_streak_milestone_desc(Object count);

  /// No description provided for @challenge_streak_milestone_title.
  ///
  /// In es, this message translates to:
  /// **'Hito de Racha'**
  String get challenge_streak_milestone_title;

  /// No description provided for @gemMilestoneTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Coleccionista de Gemas!'**
  String get gemMilestoneTitle;

  /// No description provided for @gemMilestoneDesc.
  ///
  /// In es, this message translates to:
  /// **'¡Has obtenido {count} gemas en total! ¡Sigue coleccionando!'**
  String gemMilestoneDesc(Object count);

  /// No description provided for @chatBlocked.
  ///
  /// In es, this message translates to:
  /// **'Chat bloqueado'**
  String get chatBlocked;

  /// No description provided for @chatCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get chatCancel;

  /// No description provided for @chatClearAction.
  ///
  /// In es, this message translates to:
  /// **'Borrar'**
  String get chatClearAction;

  /// No description provided for @chatClearMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres borrar esta conversación? Esta acción no se puede deshacer.'**
  String get chatClearMessage;

  /// No description provided for @chatClearTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar conversación'**
  String get chatClearTitle;

  /// No description provided for @chatEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Inicia una conversación'**
  String get chatEmptyTitle;

  /// No description provided for @chatFallbackSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Escribe cualquier duda sobre ciberseguridad o elige una sugerencia rápida.'**
  String get chatFallbackSubtitle;

  /// No description provided for @chatFallbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Pregunta a Sage'**
  String get chatFallbackTitle;

  /// No description provided for @chatGuideSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu guía de ciberseguridad'**
  String get chatGuideSubtitle;

  /// No description provided for @chatHint.
  ///
  /// In es, this message translates to:
  /// **'Pregúntale a Sage...'**
  String get chatHint;

  /// No description provided for @chatInputHint.
  ///
  /// In es, this message translates to:
  /// **'Pregunta a Sage...'**
  String get chatInputHint;

  /// No description provided for @chatSageTutorLabel.
  ///
  /// In es, this message translates to:
  /// **'Tutor Sage'**
  String get chatSageTutorLabel;

  /// No description provided for @chestCollect.
  ///
  /// In es, this message translates to:
  /// **'Recoger'**
  String get chestCollect;

  /// No description provided for @chestOpenedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Cofre {type}!'**
  String chestOpenedTitle(Object type);

  /// No description provided for @chestRewardDialog.
  ///
  /// In es, this message translates to:
  /// **'Diálogo de recompensa del cofre'**
  String get chestRewardDialog;

  /// No description provided for @chestTapToOpen.
  ///
  /// In es, this message translates to:
  /// **'Toca para abrir'**
  String get chestTapToOpen;

  /// No description provided for @chestTitle.
  ///
  /// In es, this message translates to:
  /// **'Cofre {type}'**
  String chestTitle(Object type);

  /// No description provided for @chestTreasureLabel.
  ///
  /// In es, this message translates to:
  /// **'Tesoro {type}'**
  String chestTreasureLabel(Object type);

  /// No description provided for @chestTypeBronze.
  ///
  /// In es, this message translates to:
  /// **'Bronce'**
  String get chestTypeBronze;

  /// No description provided for @chestTypeGold.
  ///
  /// In es, this message translates to:
  /// **'Oro'**
  String get chestTypeGold;

  /// No description provided for @chestTypeLegendary.
  ///
  /// In es, this message translates to:
  /// **'Legendario'**
  String get chestTypeLegendary;

  /// No description provided for @chestTypeSilver.
  ///
  /// In es, this message translates to:
  /// **'Plata'**
  String get chestTypeSilver;

  /// No description provided for @closeButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeButton;

  /// No description provided for @continueLesson.
  ///
  /// In es, this message translates to:
  /// **'Continuar lección: {title}'**
  String continueLesson(Object title);

  /// No description provided for @continueText.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueText;

  /// No description provided for @correct.
  ///
  /// In es, this message translates to:
  /// **'Correcto'**
  String get correct;

  /// No description provided for @correctAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta'**
  String get correctAnswer;

  /// No description provided for @correctAnswers.
  ///
  /// In es, this message translates to:
  /// **'{correct} de {total} correctas'**
  String correctAnswers(Object correct, Object total);

  /// No description provided for @currencySymbol.
  ///
  /// In es, this message translates to:
  /// **'\$'**
  String get currencySymbol;

  /// No description provided for @dayAbbrFri.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get dayAbbrFri;

  /// No description provided for @dayAbbrMon.
  ///
  /// In es, this message translates to:
  /// **'Lun'**
  String get dayAbbrMon;

  /// No description provided for @dayAbbrSat.
  ///
  /// In es, this message translates to:
  /// **'Sáb'**
  String get dayAbbrSat;

  /// No description provided for @dayAbbrSun.
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get dayAbbrSun;

  /// No description provided for @dayAbbrThu.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get dayAbbrThu;

  /// No description provided for @dayAbbrTue.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get dayAbbrTue;

  /// No description provided for @dayAbbrWed.
  ///
  /// In es, this message translates to:
  /// **'Mié'**
  String get dayAbbrWed;

  /// No description provided for @streakStatusCompleted.
  ///
  /// In es, this message translates to:
  /// **'completado'**
  String get streakStatusCompleted;

  /// No description provided for @streakStatusToday.
  ///
  /// In es, this message translates to:
  /// **'hoy'**
  String get streakStatusToday;

  /// No description provided for @streakStatusPending.
  ///
  /// In es, this message translates to:
  /// **'pendiente'**
  String get streakStatusPending;

  /// No description provided for @daysLabel.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get daysLabel;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @deleteCloudData.
  ///
  /// In es, this message translates to:
  /// **'Eliminar datos cloud'**
  String get deleteCloudData;

  /// No description provided for @demoModeLabel.
  ///
  /// In es, this message translates to:
  /// **'DEMO MODE'**
  String get demoModeLabel;

  /// No description provided for @demoStudentName.
  ///
  /// In es, this message translates to:
  /// **'Demo Student'**
  String get demoStudentName;

  /// No description provided for @dot.
  ///
  /// In es, this message translates to:
  /// **'Punto {number}'**
  String dot(Object number);

  /// No description provided for @emotionPhrase1.
  ///
  /// In es, this message translates to:
  /// **'Ya detectas riesgos más rápido.'**
  String get emotionPhrase1;

  /// No description provided for @emotionPhrase2.
  ///
  /// In es, this message translates to:
  /// **'Tu hábito digital está mejorando.'**
  String get emotionPhrase2;

  /// No description provided for @emotionPhrase3.
  ///
  /// In es, this message translates to:
  /// **'Cada día entiendes mejor cómo protegerte.'**
  String get emotionPhrase3;

  /// No description provided for @emotionPhrase4.
  ///
  /// In es, this message translates to:
  /// **'Estás construyendo un instinto de seguridad.'**
  String get emotionPhrase4;

  /// No description provided for @emotionPhrase5.
  ///
  /// In es, this message translates to:
  /// **'Tu criterio digital se está afilando.'**
  String get emotionPhrase5;

  /// No description provided for @emotionPhrase6.
  ///
  /// In es, this message translates to:
  /// **'Estás aprendiendo a ver lo que otros no ven.'**
  String get emotionPhrase6;

  /// No description provided for @emotionPhrase7.
  ///
  /// In es, this message translates to:
  /// **'Tu mundo digital está más seguro gracias a ti.'**
  String get emotionPhrase7;

  /// No description provided for @emotionPhraseStart.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje digital comienza hoy.'**
  String get emotionPhraseStart;

  /// No description provided for @emptyChatSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sage está listo para ayudarte'**
  String get emptyChatSubtitle;

  /// No description provided for @emptyProfile.
  ///
  /// In es, this message translates to:
  /// **'Sin datos de perfil'**
  String get emptyProfile;

  /// No description provided for @emptyStore.
  ///
  /// In es, this message translates to:
  /// **'La tienda está vacía'**
  String get emptyStore;

  /// No description provided for @errorContentLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.'**
  String get errorContentLoadFailed;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Por favor, intenta de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorLoadQuestions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar preguntas. Intenta de nuevo.'**
  String get errorLoadQuestions;

  /// No description provided for @errorRestartApp.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar app'**
  String get errorRestartApp;

  /// No description provided for @errorRetry.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get errorRetry;

  /// No description provided for @errorSomethingWrong.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get errorSomethingWrong;

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Puedes intentar de nuevo.'**
  String get errorUnexpected;

  /// No description provided for @exitText.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get exitText;

  /// No description provided for @firstLessonProgress.
  ///
  /// In es, this message translates to:
  /// **'Lección {current} de {total}'**
  String firstLessonProgress(Object current, Object total);

  /// No description provided for @firstLessonSeeResults.
  ///
  /// In es, this message translates to:
  /// **'VER RESULTADOS'**
  String get firstLessonSeeResults;

  /// No description provided for @flexCardJoinAlliance.
  ///
  /// In es, this message translates to:
  /// **'Únete a mi alianza en SAGEN'**
  String get flexCardJoinAlliance;

  /// No description provided for @fontSizeLarge.
  ///
  /// In es, this message translates to:
  /// **'Grande'**
  String get fontSizeLarge;

  /// No description provided for @fontSizeNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get fontSizeNormal;

  /// No description provided for @fontSizeSmall.
  ///
  /// In es, this message translates to:
  /// **'Pequeño'**
  String get fontSizeSmall;

  /// No description provided for @fontSizeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tamaño del texto'**
  String get fontSizeTitle;

  /// No description provided for @fontSizeXLarge.
  ///
  /// In es, this message translates to:
  /// **'Extra grande'**
  String get fontSizeXLarge;

  /// No description provided for @free.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get free;

  /// No description provided for @gems.
  ///
  /// In es, this message translates to:
  /// **'gemas'**
  String get gems;

  /// No description provided for @goToLesson.
  ///
  /// In es, this message translates to:
  /// **'Ir a lecciones: {title}'**
  String goToLesson(Object title);

  /// No description provided for @greetingAfternoon.
  ///
  /// In es, this message translates to:
  /// **'Buenas tardes'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In es, this message translates to:
  /// **'Buenas noches'**
  String get greetingEvening;

  /// No description provided for @greetingMorning.
  ///
  /// In es, this message translates to:
  /// **'Buenos días'**
  String get greetingMorning;

  /// No description provided for @hapticFeedback.
  ///
  /// In es, this message translates to:
  /// **'Vibración háptica'**
  String get hapticFeedback;

  /// No description provided for @hapticSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Respuesta háptica en interacciones'**
  String get hapticSubtitle;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @homeAllComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Todo completo!'**
  String get homeAllComplete;

  /// No description provided for @homeAllCompleteDesc.
  ///
  /// In es, this message translates to:
  /// **'Has dominado todas las lecciones.'**
  String get homeAllCompleteDesc;

  /// No description provided for @homeContinue.
  ///
  /// In es, this message translates to:
  /// **'Seguir'**
  String get homeContinue;

  /// No description provided for @homeDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Guardián'**
  String get homeDefaultName;

  /// No description provided for @levelUpCelebrationLabel.
  ///
  /// In es, this message translates to:
  /// **'¡Subiste de nivel! Nuevo nivel: {level}'**
  String levelUpCelebrationLabel(int level);

  /// No description provided for @homeLearningPath.
  ///
  /// In es, this message translates to:
  /// **'Ruta de aprendizaje'**
  String get homeLearningPath;

  /// No description provided for @homeViewAchievements.
  ///
  /// In es, this message translates to:
  /// **'Ver logros'**
  String get homeViewAchievements;

  /// No description provided for @incorrect.
  ///
  /// In es, this message translates to:
  /// **'Incorrecto'**
  String get incorrect;

  /// No description provided for @incorrectAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta incorrecta'**
  String get incorrectAnswer;

  /// No description provided for @languageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageSpanish;

  /// No description provided for @languageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In es, this message translates to:
  /// **'Francés'**
  String get languageFrench;

  /// No description provided for @languagePortuguese.
  ///
  /// In es, this message translates to:
  /// **'Portugués'**
  String get languagePortuguese;

  /// No description provided for @lastSync.
  ///
  /// In es, this message translates to:
  /// **'Última sincronización'**
  String get lastSync;

  /// No description provided for @legalAnd.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get legalAnd;

  /// No description provided for @legalRegisterAgree.
  ///
  /// In es, this message translates to:
  /// **'Al registrarte aceptas nuestros '**
  String get legalRegisterAgree;

  /// No description provided for @legalTerms.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get legalTerms;

  /// No description provided for @lessonComplete.
  ///
  /// In es, this message translates to:
  /// **'Lección completada'**
  String get lessonComplete;

  /// No description provided for @lessonPreparing.
  ///
  /// In es, this message translates to:
  /// **'Preparando tus preguntas...'**
  String get lessonPreparing;

  /// No description provided for @lessonProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso: {percent}%'**
  String lessonProgress(Object percent);

  /// No description provided for @lessonResultsPreparing.
  ///
  /// In es, this message translates to:
  /// **'Preparando resultados...'**
  String get lessonResultsPreparing;

  /// No description provided for @lessonsCompleted.
  ///
  /// In es, this message translates to:
  /// **'{count} lecciones completadas'**
  String lessonsCompleted(Object count);

  /// No description provided for @reviewCardLabel.
  ///
  /// In es, this message translates to:
  /// **'Repaso: {count} preguntas pendientes'**
  String reviewCardLabel(Object count);

  /// No description provided for @reviewCompleted.
  ///
  /// In es, this message translates to:
  /// **'¡Repaso completado!'**
  String get reviewCompleted;

  /// No description provided for @reviewDuePrompt.
  ///
  /// In es, this message translates to:
  /// **'Tienes {count} preguntas listas para repasar'**
  String reviewDuePrompt(Object count);

  /// No description provided for @reviewGemsLabel.
  ///
  /// In es, this message translates to:
  /// **'Gemas de repaso'**
  String get reviewGemsLabel;

  /// No description provided for @reviewNoneDue.
  ///
  /// In es, this message translates to:
  /// **'No tienes repasos pendientes ahora. ¡Bien hecho!'**
  String get reviewNoneDue;

  /// No description provided for @reviewScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Repaso inteligente'**
  String get reviewScreenTitle;

  /// No description provided for @reviewXpLabel.
  ///
  /// In es, this message translates to:
  /// **'XP de repaso'**
  String get reviewXpLabel;

  /// No description provided for @lessonsLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String lessonsLevel(Object level);

  /// No description provided for @lessonsYourPath.
  ///
  /// In es, this message translates to:
  /// **'Tu ruta de aprendizaje'**
  String get lessonsYourPath;

  /// No description provided for @levelProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso de nivel: {percent} por ciento'**
  String levelProgress(Object percent);

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando'**
  String get loading;

  /// No description provided for @miniGameBackupDef.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get miniGameBackupDef;

  /// No description provided for @miniGameBackupTerm.
  ///
  /// In es, this message translates to:
  /// **'Backup'**
  String get miniGameBackupTerm;

  /// No description provided for @miniGameComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Completado!'**
  String get miniGameComplete;

  /// No description provided for @miniGameCorrect.
  ///
  /// In es, this message translates to:
  /// **'Correcto'**
  String get miniGameCorrect;

  /// No description provided for @miniGameEncryptionDef.
  ///
  /// In es, this message translates to:
  /// **'Protección de datos con clave'**
  String get miniGameEncryptionDef;

  /// No description provided for @miniGameEncryptionTerm.
  ///
  /// In es, this message translates to:
  /// **'Cifrado'**
  String get miniGameEncryptionTerm;

  /// No description provided for @miniGameFirewallDef.
  ///
  /// In es, this message translates to:
  /// **'Barrera de seguridad de red'**
  String get miniGameFirewallDef;

  /// No description provided for @miniGameFirewallTerm.
  ///
  /// In es, this message translates to:
  /// **'Firewall'**
  String get miniGameFirewallTerm;

  /// No description provided for @miniGameHiddenCard.
  ///
  /// In es, this message translates to:
  /// **'Carta oculta'**
  String get miniGameHiddenCard;

  /// No description provided for @miniGameMalwareDef.
  ///
  /// In es, this message translates to:
  /// **'Software malicioso'**
  String get miniGameMalwareDef;

  /// No description provided for @miniGameMalwareTerm.
  ///
  /// In es, this message translates to:
  /// **'Malware'**
  String get miniGameMalwareTerm;

  /// No description provided for @miniGameMatches.
  ///
  /// In es, this message translates to:
  /// **'Aciertos'**
  String get miniGameMatches;

  /// No description provided for @miniGameMemory.
  ///
  /// In es, this message translates to:
  /// **'Juego de memoria'**
  String get miniGameMemory;

  /// No description provided for @miniGameMemoryDesc.
  ///
  /// In es, this message translates to:
  /// **'Encuentra las parejas coincidentes'**
  String get miniGameMemoryDesc;

  /// No description provided for @miniGameMistakes.
  ///
  /// In es, this message translates to:
  /// **'Errores'**
  String get miniGameMistakes;

  /// No description provided for @miniGameMoves.
  ///
  /// In es, this message translates to:
  /// **'Movimientos'**
  String get miniGameMoves;

  /// No description provided for @miniGameOver.
  ///
  /// In es, this message translates to:
  /// **'¡Buen intento!'**
  String get miniGameOver;

  /// No description provided for @miniGamePattern.
  ///
  /// In es, this message translates to:
  /// **'Trazo de patrón'**
  String get miniGamePattern;

  /// No description provided for @miniGamePatternDesc.
  ///
  /// In es, this message translates to:
  /// **'Memoriza y reproduce patrones'**
  String get miniGamePatternDesc;

  /// No description provided for @miniGamePhishingDef.
  ///
  /// In es, this message translates to:
  /// **'Correo falso que roba datos'**
  String get miniGamePhishingDef;

  /// No description provided for @miniGamePhishingTerm.
  ///
  /// In es, this message translates to:
  /// **'Phishing'**
  String get miniGamePhishingTerm;

  /// No description provided for @miniGamePlayAgain.
  ///
  /// In es, this message translates to:
  /// **'Jugar de nuevo'**
  String get miniGamePlayAgain;

  /// No description provided for @miniGameRound.
  ///
  /// In es, this message translates to:
  /// **'Ronda'**
  String get miniGameRound;

  /// No description provided for @miniGameScore.
  ///
  /// In es, this message translates to:
  /// **'Puntuación'**
  String get miniGameScore;

  /// No description provided for @miniGameSortInstruction.
  ///
  /// In es, this message translates to:
  /// **'Toca para ordenar cada elemento en la categoría correcta'**
  String get miniGameSortInstruction;

  /// No description provided for @miniGameSpeed.
  ///
  /// In es, this message translates to:
  /// **'Clasificación Veloz'**
  String get miniGameSpeed;

  /// No description provided for @miniGameSpeedDesc.
  ///
  /// In es, this message translates to:
  /// **'Ordena los elementos rápidamente'**
  String get miniGameSpeedDesc;

  /// No description provided for @miniGameSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Entrena tus habilidades de ciberseguridad'**
  String get miniGameSubtitle;

  /// No description provided for @miniGameTitle.
  ///
  /// In es, this message translates to:
  /// **'Minijuegos'**
  String get miniGameTitle;

  /// No description provided for @miniGameVpnDef.
  ///
  /// In es, this message translates to:
  /// **'Red privada virtual'**
  String get miniGameVpnDef;

  /// No description provided for @miniGameVpnTerm.
  ///
  /// In es, this message translates to:
  /// **'VPN'**
  String get miniGameVpnTerm;

  /// No description provided for @miniGameWatch.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get miniGameWatch;

  /// No description provided for @miniGameWord.
  ///
  /// In es, this message translates to:
  /// **'Palabras Iguales'**
  String get miniGameWord;

  /// No description provided for @miniGameWordDesc.
  ///
  /// In es, this message translates to:
  /// **'Relaciona términos y definiciones'**
  String get miniGameWordDesc;

  /// No description provided for @miniGameWrong.
  ///
  /// In es, this message translates to:
  /// **'Incorrecto'**
  String get miniGameWrong;

  /// No description provided for @miniGameYourTurn.
  ///
  /// In es, this message translates to:
  /// **'Tu turno'**
  String get miniGameYourTurn;

  /// No description provided for @minutes.
  ///
  /// In es, this message translates to:
  /// **'{min} min'**
  String minutes(Object min);

  /// No description provided for @missionActiveLearnerDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 1 lección de seguridad.'**
  String get missionActiveLearnerDesc;

  /// No description provided for @missionActiveLearnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz Activo'**
  String get missionActiveLearnerTitle;

  /// No description provided for @missionActiveStreakDesc.
  ///
  /// In es, this message translates to:
  /// **'Mantén tu racha de aprendizaje hoy.'**
  String get missionActiveStreakDesc;

  /// No description provided for @missionActiveStreakTitle.
  ///
  /// In es, this message translates to:
  /// **'Racha Activa'**
  String get missionActiveStreakTitle;

  /// No description provided for @missionChatWithSageDesc.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage sobre seguridad digital.'**
  String get missionChatWithSageDesc;

  /// No description provided for @missionChatWithSageTitle.
  ///
  /// In es, this message translates to:
  /// **'Chatea con Sage'**
  String get missionChatWithSageTitle;

  /// No description provided for @missionDigitalDetectiveDesc.
  ///
  /// In es, this message translates to:
  /// **'Analiza un enlace sospechoso.'**
  String get missionDigitalDetectiveDesc;

  /// No description provided for @missionDigitalDetectiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Detective Digital'**
  String get missionDigitalDetectiveTitle;

  /// No description provided for @missionExpressChallengeDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa un desafío rápido de 30 segundos.'**
  String get missionExpressChallengeDesc;

  /// No description provided for @missionExpressChallengeTitle.
  ///
  /// In es, this message translates to:
  /// **'Desafío Express'**
  String get missionExpressChallengeTitle;

  /// No description provided for @missionPerfectLessonDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección sin errores.'**
  String get missionPerfectLessonDesc;

  /// No description provided for @missionPerfectLessonTitle.
  ///
  /// In es, this message translates to:
  /// **'Lección Perfecta'**
  String get missionPerfectLessonTitle;

  /// No description provided for @missionPhishingHunterDesc.
  ///
  /// In es, this message translates to:
  /// **'Detecta correctamente un intento de phishing.'**
  String get missionPhishingHunterDesc;

  /// No description provided for @missionPhishingHunterTitle.
  ///
  /// In es, this message translates to:
  /// **'Cazador de Phishing'**
  String get missionPhishingHunterTitle;

  /// No description provided for @motivationCareer.
  ///
  /// In es, this message translates to:
  /// **'Carrera profesional'**
  String get motivationCareer;

  /// No description provided for @motivationConnect.
  ///
  /// In es, this message translates to:
  /// **'Conectar con personas'**
  String get motivationConnect;

  /// No description provided for @motivationDialogMultiple.
  ///
  /// In es, this message translates to:
  /// **'Múltiples motivaciones seleccionadas'**
  String get motivationDialogMultiple;

  /// No description provided for @motivationDialogNone.
  ///
  /// In es, this message translates to:
  /// **'Sin motivación seleccionada'**
  String get motivationDialogNone;

  /// No description provided for @motivationFun.
  ///
  /// In es, this message translates to:
  /// **'Divertirme'**
  String get motivationFun;

  /// No description provided for @motivationMind.
  ///
  /// In es, this message translates to:
  /// **'Entrenar mi mente'**
  String get motivationMind;

  /// No description provided for @motivationOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get motivationOther;

  /// No description provided for @motivationStudies.
  ///
  /// In es, this message translates to:
  /// **'Estudios'**
  String get motivationStudies;

  /// No description provided for @motivationTravel.
  ///
  /// In es, this message translates to:
  /// **'Viajar'**
  String get motivationTravel;

  /// No description provided for @navChest.
  ///
  /// In es, this message translates to:
  /// **'Cofre'**
  String get navChest;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @navRanking.
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get navRanking;

  /// No description provided for @navSage.
  ///
  /// In es, this message translates to:
  /// **'Sage'**
  String get navSage;

  /// No description provided for @nextText.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get nextText;

  /// No description provided for @noLessonsAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay lecciones disponibles'**
  String get noLessonsAvailable;

  /// No description provided for @notFoundBackHome.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get notFoundBackHome;

  /// No description provided for @notFoundDescription.
  ///
  /// In es, this message translates to:
  /// **'La página que buscas no existe.'**
  String get notFoundDescription;

  /// No description provided for @notFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Página no encontrada'**
  String get notFoundTitle;

  /// No description provided for @offlineSavedForLater.
  ///
  /// In es, this message translates to:
  /// **'Guardado sin conexión. Sincronizaremos pronto.'**
  String get offlineSavedForLater;

  /// No description provided for @onbMotivationCareerMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Grandes razones para aprender!'**
  String get onbMotivationCareerMsg;

  /// No description provided for @onbMotivationConnectMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos a conectarte!'**
  String get onbMotivationConnectMsg;

  /// No description provided for @onbMotivationFunMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Me encanta! Divertirme es mi especialidad.'**
  String get onbMotivationFunMsg;

  /// No description provided for @onbMotivationMindMsg.
  ///
  /// In es, this message translates to:
  /// **'Es una decisión sabia.'**
  String get onbMotivationMindMsg;

  /// No description provided for @onbMotivationOtherMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Entendido! Cuéntame más por el camino.'**
  String get onbMotivationOtherMsg;

  /// No description provided for @onbMotivationStudiesMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Un mundo de oportunidades se abrirá para ti!'**
  String get onbMotivationStudiesMsg;

  /// No description provided for @onbMotivationTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué quieres dominar el mundo digital?'**
  String get onbMotivationTitle;

  /// No description provided for @onbMotivationTravelMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Nada supera viajar con tus dispositivos 100% protegidos!'**
  String get onbMotivationTravelMsg;

  /// No description provided for @onbProjectionTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Esto es lo que dominarás en 3 meses!'**
  String get onbProjectionTitle;

  /// No description provided for @onbRouteAvailable.
  ///
  /// In es, this message translates to:
  /// **'Rutas de entrenamiento disponibles:'**
  String get onbRouteAvailable;

  /// No description provided for @onbRouteQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Qué área del entorno digital te gustaría dominar primero?'**
  String get onbRouteQuestion;

  /// No description provided for @onbStartingExperienced.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes experiencia como hacker?'**
  String get onbStartingExperienced;

  /// No description provided for @onbStartingExperiencedSub.
  ///
  /// In es, this message translates to:
  /// **'¡Toma el test de nivel y salta lo básico!'**
  String get onbStartingExperiencedSub;

  /// No description provided for @onbStartingPerfecto.
  ///
  /// In es, this message translates to:
  /// **'¡Perfecto! Veamos dónde empezar tu entrenamiento.'**
  String get onbStartingPerfecto;

  /// No description provided for @onbStartingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Empieza desde cero y forja tu escudo'**
  String get onbStartingSubtitle;

  /// No description provided for @onbStartingTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Es tu primera vez en ciberdefensa?'**
  String get onbStartingTitle;

  /// No description provided for @onbWelcomeMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy Sagen. Estoy aquí para entrenarte, proteger tu entorno digital y hacerte un experto.'**
  String get onbWelcomeMsg;

  /// No description provided for @onboardingCommitButton.
  ///
  /// In es, this message translates to:
  /// **'MANTENER MI COMPROMISO'**
  String get onboardingCommitButton;

  /// No description provided for @onboardingDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu asistente personal de seguridad digital.\nAprende, analiza y protégete gratis.'**
  String get onboardingDesc;

  /// No description provided for @onboardingHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'Ya tengo una cuenta'**
  String get onboardingHaveAccount;

  /// No description provided for @onboardingSage50Days.
  ///
  /// In es, this message translates to:
  /// **'50 días de dedicación. ¡Leyenda en formación!'**
  String get onboardingSage50Days;

  /// No description provided for @onboardingSageExcellent.
  ///
  /// In es, this message translates to:
  /// **'Excelentes motivos, ¡apunta alto!'**
  String get onboardingSageExcellent;

  /// No description provided for @onboardingSageMonth.
  ///
  /// In es, this message translates to:
  /// **'Un mes de disciplina. Los hábitos se forjan.'**
  String get onboardingSageMonth;

  /// No description provided for @onboardingSageStart.
  ///
  /// In es, this message translates to:
  /// **'¡Un gran comienzo! Cada día cuenta.'**
  String get onboardingSageStart;

  /// No description provided for @onboardingSageTwoWeeks.
  ///
  /// In es, this message translates to:
  /// **'Dos semanas de constancia. ¡Eres imparable!'**
  String get onboardingSageTwoWeeks;

  /// No description provided for @owned.
  ///
  /// In es, this message translates to:
  /// **'Obtenido'**
  String get owned;

  /// No description provided for @passClaimFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reclamar la recompensa. Inténtalo de nuevo.'**
  String get passClaimFailed;

  /// No description provided for @passClaimedLabel.
  ///
  /// In es, this message translates to:
  /// **'Reclamado'**
  String get passClaimedLabel;

  /// No description provided for @passDaysLeft.
  ///
  /// In es, this message translates to:
  /// **'Quedan {count} días'**
  String passDaysLeft(Object count);

  /// No description provided for @passEarnSp.
  ///
  /// In es, this message translates to:
  /// **'Gana SP completando lecciones'**
  String get passEarnSp;

  /// No description provided for @passHowToEarnDailyLimit.
  ///
  /// In es, this message translates to:
  /// **'Límite diario de SP'**
  String get passHowToEarnDailyLimit;

  /// No description provided for @passHowToEarnLesson.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección: +10 SP'**
  String get passHowToEarnLesson;

  /// No description provided for @passHowToEarnMission.
  ///
  /// In es, this message translates to:
  /// **'Completa misiones diarias: +5 SP'**
  String get passHowToEarnMission;

  /// No description provided for @passHowToEarnPerfect.
  ///
  /// In es, this message translates to:
  /// **'Lección perfecta: +15 SP'**
  String get passHowToEarnPerfect;

  /// No description provided for @passHowToEarnReview.
  ///
  /// In es, this message translates to:
  /// **'Repasa una lección'**
  String get passHowToEarnReview;

  /// No description provided for @passHowToEarnTitle.
  ///
  /// In es, this message translates to:
  /// **'Cómo ganar SP'**
  String get passHowToEarnTitle;

  /// No description provided for @passLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String passLevel(Object level);

  /// No description provided for @passLevelsTitle.
  ///
  /// In es, this message translates to:
  /// **'Niveles'**
  String get passLevelsTitle;

  /// No description provided for @passLocked.
  ///
  /// In es, this message translates to:
  /// **'Bloqueado'**
  String get passLocked;

  /// No description provided for @passMaxLevel.
  ///
  /// In es, this message translates to:
  /// **'¡Nivel máximo!'**
  String get passMaxLevel;

  /// No description provided for @passProgress.
  ///
  /// In es, this message translates to:
  /// **'SP: {current} / {required}'**
  String passProgress(Object current, Object required);

  /// No description provided for @passReached.
  ///
  /// In es, this message translates to:
  /// **'Alcanzado'**
  String get passReached;

  /// No description provided for @passRewardClaimed.
  ///
  /// In es, this message translates to:
  /// **'¡Recompensa reclamada!'**
  String get passRewardClaimed;

  /// No description provided for @passRewards.
  ///
  /// In es, this message translates to:
  /// **'Recompensas ({current}/{max})'**
  String passRewards(Object current, Object max);

  /// No description provided for @paymentGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get paymentGoHome;

  /// No description provided for @paymentMercadoPagoError.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión con MercadoPago. Por favor, intenta de nuevo.'**
  String get paymentMercadoPagoError;

  /// No description provided for @paymentNotCompleted.
  ///
  /// In es, this message translates to:
  /// **'Pago no completado'**
  String get paymentNotCompleted;

  /// No description provided for @paymentPending.
  ///
  /// In es, this message translates to:
  /// **'Pago pendiente'**
  String get paymentPending;

  /// No description provided for @paymentPendingDescription.
  ///
  /// In es, this message translates to:
  /// **'Tu pago está siendo procesado. Las donaciones se acreditarán una vez que el proveedor confirme el pago.'**
  String get paymentPendingDescription;

  /// No description provided for @paymentTryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get paymentTryAgain;

  /// No description provided for @paymentErrorNotSignedIn.
  ///
  /// In es, this message translates to:
  /// **'Debes iniciar sesión para donar.'**
  String get paymentErrorNotSignedIn;

  /// No description provided for @paymentErrorSessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada. Inicia sesión de nuevo.'**
  String get paymentErrorSessionExpired;

  /// No description provided for @paymentErrorInvalidProduct.
  ///
  /// In es, this message translates to:
  /// **'Producto inválido.'**
  String get paymentErrorInvalidProduct;

  /// No description provided for @paymentErrorStartFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo iniciar el pago. Intenta de nuevo.'**
  String get paymentErrorStartFailed;

  /// No description provided for @paymentErrorRegisterFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo registrar el pago. Intenta de nuevo.'**
  String get paymentErrorRegisterFailed;

  /// No description provided for @paymentErrorExpired.
  ///
  /// In es, this message translates to:
  /// **'El pago expiró. Intenta de nuevo.'**
  String get paymentErrorExpired;

  /// No description provided for @paymentErrorCancelled.
  ///
  /// In es, this message translates to:
  /// **'El pago fue cancelado o no se completó.'**
  String get paymentErrorCancelled;

  /// No description provided for @paywallBasic.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get paywallBasic;

  /// No description provided for @paywallDescription.
  ///
  /// In es, this message translates to:
  /// **'Elige tu paquete y te contactamos por WhatsApp para coordinar el pago.'**
  String get paywallDescription;

  /// No description provided for @paywallMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago'**
  String get paywallMercadoPago;

  /// No description provided for @paywallPackageLabel.
  ///
  /// In es, this message translates to:
  /// **'Paquete {label}'**
  String paywallPackageLabel(Object label);

  /// No description provided for @paywallPackageSupporter.
  ///
  /// In es, this message translates to:
  /// **'Nivel de Supporter {level}'**
  String paywallPackageSupporter(Object level);

  /// No description provided for @paywallPaymentMethods.
  ///
  /// In es, this message translates to:
  /// **'Paga con Yape, Plin, MercadoPago o transferencia'**
  String get paywallPaymentMethods;

  /// No description provided for @paywallPopular.
  ///
  /// In es, this message translates to:
  /// **'Popular'**
  String get paywallPopular;

  /// No description provided for @paywallPremium.
  ///
  /// In es, this message translates to:
  /// **'Premium'**
  String get paywallPremium;

  /// No description provided for @paywallSupportUs.
  ///
  /// In es, this message translates to:
  /// **'Apoya a SAGEN'**
  String get paywallSupportUs;

  /// No description provided for @paywallWhatsAppError.
  ///
  /// In es, this message translates to:
  /// **'Error al abrir WhatsApp. Paga vía: {link}'**
  String paywallWhatsAppError(Object link);

  /// No description provided for @paywallWhatsAppFallback.
  ///
  /// In es, this message translates to:
  /// **'Abre WhatsApp y envía: {message}'**
  String paywallWhatsAppFallback(Object message);

  /// No description provided for @paywallWhatsAppMessage.
  ///
  /// In es, this message translates to:
  /// **'Hola, quiero donar {currencySymbol}{price} a SAGEN (Supporter {supporterLevel}). Mi ID de usuario es: {userId}'**
  String paywallWhatsAppMessage(
    Object currencySymbol,
    Object supporterLevel,
    Object price,
    Object userId,
  );

  /// No description provided for @privacyPolicy.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In es, this message translates to:
  /// **'Política de Privacidad de SAGEN'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyLastUpdate.
  ///
  /// In es, this message translates to:
  /// **'Última actualización: Julio 2026'**
  String get privacyPolicyLastUpdate;

  /// No description provided for @privacyPolicySection1Title.
  ///
  /// In es, this message translates to:
  /// **'1. Información que Recopilamos'**
  String get privacyPolicySection1Title;

  /// No description provided for @privacyPolicySection1Body.
  ///
  /// In es, this message translates to:
  /// **'Recopilamos información que nos proporcionas directamente, como tu nombre, correo electrónico y edad, así como datos de uso de la app como lecciones completadas, rachas y puntuaciones.'**
  String get privacyPolicySection1Body;

  /// No description provided for @privacyPolicySection2Title.
  ///
  /// In es, this message translates to:
  /// **'2. Uso de la Información'**
  String get privacyPolicySection2Title;

  /// No description provided for @privacyPolicySection2Body.
  ///
  /// In es, this message translates to:
  /// **'Utilizamos tu información para personalizar tu experiencia de aprendizaje, mejorar nuestros servicios y enviarte notificaciones relevantes sobre tu progreso.'**
  String get privacyPolicySection2Body;

  /// No description provided for @privacyPolicySection3Title.
  ///
  /// In es, this message translates to:
  /// **'3. Almacenamiento de Datos'**
  String get privacyPolicySection3Title;

  /// No description provided for @privacyPolicySection3Body.
  ///
  /// In es, this message translates to:
  /// **'Tus datos se almacenan de forma segura en servidores protegidos. Utilizamos encriptación para proteger tu información personal.'**
  String get privacyPolicySection3Body;

  /// No description provided for @privacyPolicySection4Title.
  ///
  /// In es, this message translates to:
  /// **'4. Tus Derechos'**
  String get privacyPolicySection4Title;

  /// No description provided for @privacyPolicySection4Body.
  ///
  /// In es, this message translates to:
  /// **'Tienes derecho a acceder, rectificar o eliminar tus datos personales. Puede contactarnos para ejercer estos derechos.'**
  String get privacyPolicySection4Body;

  /// No description provided for @privacyPolicySection5Title.
  ///
  /// In es, this message translates to:
  /// **'5. Terceros'**
  String get privacyPolicySection5Title;

  /// No description provided for @privacyPolicySection5Body.
  ///
  /// In es, this message translates to:
  /// **'No vendemos tu información a terceros. Podemos compartir datos anonimizados para mejorar nuestros servicios educativos.'**
  String get privacyPolicySection5Body;

  /// No description provided for @privacyPolicySection6Title.
  ///
  /// In es, this message translates to:
  /// **'6. Privacidad de Menores'**
  String get privacyPolicySection6Title;

  /// No description provided for @privacyPolicySection6Body.
  ///
  /// In es, this message translates to:
  /// **'Nuestra app está dirigida a adultos. No recopilamos intencionalmente información de menores de 13 años.'**
  String get privacyPolicySection6Body;

  /// No description provided for @privacyPolicySection7Title.
  ///
  /// In es, this message translates to:
  /// **'7. Seguridad'**
  String get privacyPolicySection7Title;

  /// No description provided for @privacyPolicySection7Body.
  ///
  /// In es, this message translates to:
  /// **'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información contra acceso no autorizado.'**
  String get privacyPolicySection7Body;

  /// No description provided for @privacyPolicySection8Title.
  ///
  /// In es, this message translates to:
  /// **'8. Cambios en esta Política'**
  String get privacyPolicySection8Title;

  /// No description provided for @privacyPolicySection8Body.
  ///
  /// In es, this message translates to:
  /// **'Nos reservamos el derecho de actualizar esta política. Te notificaremos de cambios significativos a través de la app.'**
  String get privacyPolicySection8Body;

  /// No description provided for @privacyPolicySection9Title.
  ///
  /// In es, this message translates to:
  /// **'9. Contacto'**
  String get privacyPolicySection9Title;

  /// No description provided for @privacyPolicySection9Body.
  ///
  /// In es, this message translates to:
  /// **'Si tienes preguntas sobre esta política, contáctanos en soporte@sagenapp.com'**
  String get privacyPolicySection9Body;

  /// No description provided for @productBestOffer.
  ///
  /// In es, this message translates to:
  /// **'Mejor oferta'**
  String get productBestOffer;

  /// No description provided for @productBoost.
  ///
  /// In es, this message translates to:
  /// **'Impulso'**
  String get productBoost;

  /// No description provided for @productBoostPack.
  ///
  /// In es, this message translates to:
  /// **'Pack Impulso'**
  String get productBoostPack;

  /// No description provided for @productBoostPackDesc.
  ///
  /// In es, this message translates to:
  /// **'200 donaciones + 1 Boost de XP'**
  String get productBoostPackDesc;

  /// No description provided for @productDonationBasic.
  ///
  /// In es, this message translates to:
  /// **'Supporter'**
  String get productDonationBasic;

  /// No description provided for @productDonationDesc.
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos a mantener SAGEN gratis'**
  String get productDonationDesc;

  /// No description provided for @productDonationPremium.
  ///
  /// In es, this message translates to:
  /// **'Campeón'**
  String get productDonationPremium;

  /// No description provided for @productDonationStandard.
  ///
  /// In es, this message translates to:
  /// **'Super Supporter'**
  String get productDonationStandard;

  /// No description provided for @productLuck.
  ///
  /// In es, this message translates to:
  /// **'Suerte'**
  String get productLuck;

  /// No description provided for @productLuckBoostDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Boost de Suerte (2x en cofres legendarios)'**
  String get productLuckBoostDesc;

  /// No description provided for @productLuckPack.
  ///
  /// In es, this message translates to:
  /// **'Pack Suerte'**
  String get productLuckPack;

  /// No description provided for @productLuckPackDesc.
  ///
  /// In es, this message translates to:
  /// **'250 donaciones + 1 Boost de Suerte'**
  String get productLuckPackDesc;

  /// No description provided for @productPopular.
  ///
  /// In es, this message translates to:
  /// **'Popular'**
  String get productPopular;

  /// No description provided for @productProtector.
  ///
  /// In es, this message translates to:
  /// **'Protector'**
  String get productProtector;

  /// No description provided for @productProtectorPack.
  ///
  /// In es, this message translates to:
  /// **'Pack Protegido'**
  String get productProtectorPack;

  /// No description provided for @productProtectorPackDesc.
  ///
  /// In es, this message translates to:
  /// **'100 donaciones + 1 protector de racha'**
  String get productProtectorPackDesc;

  /// No description provided for @productStreakProtectorDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Protector de racha'**
  String get productStreakProtectorDesc;

  /// No description provided for @productSupporter.
  ///
  /// In es, this message translates to:
  /// **'Supporter'**
  String get productSupporter;

  /// No description provided for @productXpBoostDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Boost de XP (2x en tu próxima lección)'**
  String get productXpBoostDesc;

  /// No description provided for @profileAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get profileAchievements;

  /// No description provided for @profileDay.
  ///
  /// In es, this message translates to:
  /// **'día'**
  String get profileDay;

  /// No description provided for @profileDays.
  ///
  /// In es, this message translates to:
  /// **'días'**
  String get profileDays;

  /// No description provided for @profileDefaultFirstName.
  ///
  /// In es, this message translates to:
  /// **'Guerrero'**
  String get profileDefaultFirstName;

  /// No description provided for @profileDefaultLastName.
  ///
  /// In es, this message translates to:
  /// **'Anónimo'**
  String get profileDefaultLastName;

  /// No description provided for @profileDefaultName.
  ///
  /// In es, this message translates to:
  /// **'Guardián'**
  String get profileDefaultName;

  /// No description provided for @profileDonations.
  ///
  /// In es, this message translates to:
  /// **'Donaciones'**
  String get profileDonations;

  /// No description provided for @profileError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar perfil'**
  String get profileError;

  /// No description provided for @profileLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel'**
  String get profileLevel;

  /// No description provided for @profileLevelValue.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String profileLevelValue(Object level);

  /// No description provided for @profileStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get profileStreak;

  /// No description provided for @profileGemsEarned.
  ///
  /// In es, this message translates to:
  /// **'Ganadas'**
  String get profileGemsEarned;

  /// No description provided for @profileGemsSpent.
  ///
  /// In es, this message translates to:
  /// **'Gastadas'**
  String get profileGemsSpent;

  /// No description provided for @profileTotalXp.
  ///
  /// In es, this message translates to:
  /// **'XP Total'**
  String get profileTotalXp;

  /// No description provided for @profileXpLabel.
  ///
  /// In es, this message translates to:
  /// **'XP'**
  String get profileXpLabel;

  /// No description provided for @xpValue.
  ///
  /// In es, this message translates to:
  /// **'{count} XP'**
  String xpValue(int count);

  /// No description provided for @projectionBenefit1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Asegura tus redes sociales y correos'**
  String get projectionBenefit1Subtitle;

  /// No description provided for @projectionBenefit1Title.
  ///
  /// In es, this message translates to:
  /// **'Protege tus cuentas'**
  String get projectionBenefit1Title;

  /// No description provided for @projectionBenefit2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Identifica phishing y enlaces maliciosos'**
  String get projectionBenefit2Subtitle;

  /// No description provided for @projectionBenefit2Title.
  ///
  /// In es, this message translates to:
  /// **'Detecta estafas'**
  String get projectionBenefit2Title;

  /// No description provided for @projectionBenefit3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Navega internet con confianza'**
  String get projectionBenefit3Subtitle;

  /// No description provided for @projectionBenefit3Title.
  ///
  /// In es, this message translates to:
  /// **'Navega con seguridad'**
  String get projectionBenefit3Title;

  /// No description provided for @protectionBasic.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get protectionBasic;

  /// No description provided for @protectionBasicDesc.
  ///
  /// In es, this message translates to:
  /// **'Empiezas a protegerte'**
  String get protectionBasicDesc;

  /// No description provided for @protectionCyberShield.
  ///
  /// In es, this message translates to:
  /// **'Cyber Shield'**
  String get protectionCyberShield;

  /// No description provided for @protectionCyberShieldDesc.
  ///
  /// In es, this message translates to:
  /// **'Eres un escudo activo'**
  String get protectionCyberShieldDesc;

  /// No description provided for @protectionElite.
  ///
  /// In es, this message translates to:
  /// **'Elite Protection'**
  String get protectionElite;

  /// No description provided for @protectionEliteDesc.
  ///
  /// In es, this message translates to:
  /// **'Máximo nivel de protección'**
  String get protectionEliteDesc;

  /// No description provided for @protectionGuardian.
  ///
  /// In es, this message translates to:
  /// **'Guardián'**
  String get protectionGuardian;

  /// No description provided for @protectionGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Defiendes tu identidad digital'**
  String get protectionGuardianDesc;

  /// No description provided for @protectionProtected.
  ///
  /// In es, this message translates to:
  /// **'Protegido'**
  String get protectionProtected;

  /// No description provided for @protectionProtectedDesc.
  ///
  /// In es, this message translates to:
  /// **'Tus primeros hábitos digitales'**
  String get protectionProtectedDesc;

  /// No description provided for @protectionSecureMind.
  ///
  /// In es, this message translates to:
  /// **'Secure Mind'**
  String get protectionSecureMind;

  /// No description provided for @protectionSecureMindDesc.
  ///
  /// In es, this message translates to:
  /// **'La seguridad es parte de ti'**
  String get protectionSecureMindDesc;

  /// No description provided for @questions.
  ///
  /// In es, this message translates to:
  /// **'{count} preguntas'**
  String questions(Object count);

  /// No description provided for @quickChallengeDetectPhishing.
  ///
  /// In es, this message translates to:
  /// **'Detecta phishing'**
  String get quickChallengeDetectPhishing;

  /// No description provided for @quickChallengeDetectRisk.
  ///
  /// In es, this message translates to:
  /// **'Detecta el riesgo'**
  String get quickChallengeDetectRisk;

  /// No description provided for @quickChallengeSafePassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña segura'**
  String get quickChallengeSafePassword;

  /// No description provided for @quickChallengeTrueFalse.
  ///
  /// In es, this message translates to:
  /// **'Verdadero o Falso'**
  String get quickChallengeTrueFalse;

  /// No description provided for @quickChallengeWhatWouldYouDo.
  ///
  /// In es, this message translates to:
  /// **'¿Qué harías?'**
  String get quickChallengeWhatWouldYouDo;

  /// No description provided for @quizProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso del cuestionario: {percent} por ciento'**
  String quizProgress(Object percent);

  /// No description provided for @rankActiveLearner.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz Activo'**
  String get rankActiveLearner;

  /// No description provided for @rankCybersecurityLegend.
  ///
  /// In es, this message translates to:
  /// **'Leyenda de Ciberseguridad'**
  String get rankCybersecurityLegend;

  /// No description provided for @rankEliteDefender.
  ///
  /// In es, this message translates to:
  /// **'Defensor Élite'**
  String get rankEliteDefender;

  /// No description provided for @rankExperiencedWarrior.
  ///
  /// In es, this message translates to:
  /// **'Guerrero Experimentado'**
  String get rankExperiencedWarrior;

  /// No description provided for @rankNovice.
  ///
  /// In es, this message translates to:
  /// **'Novato'**
  String get rankNovice;

  /// No description provided for @rankingEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Completa lecciones para entrar al ranking'**
  String get rankingEmptyMessage;

  /// No description provided for @rankingError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar clasificación'**
  String get rankingError;

  /// No description provided for @rankingPosition.
  ///
  /// In es, this message translates to:
  /// **'Posición #{rank}'**
  String rankingPosition(Object rank);

  /// No description provided for @rankingShareButton.
  ///
  /// In es, this message translates to:
  /// **'Compartir Flex Card'**
  String get rankingShareButton;

  /// No description provided for @rankingShareSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Supera mi rango en SAGEN'**
  String get rankingShareSubtitle;

  /// No description provided for @rankingSharing.
  ///
  /// In es, this message translates to:
  /// **'Compartiendo...'**
  String get rankingSharing;

  /// No description provided for @rankingSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Clasificación global · Top 50'**
  String get rankingSubtitle;

  /// No description provided for @rankingTitle.
  ///
  /// In es, this message translates to:
  /// **'El Coliseo'**
  String get rankingTitle;

  /// No description provided for @rankingPodiumLabel.
  ///
  /// In es, this message translates to:
  /// **'Podio del ranking'**
  String get rankingPodiumLabel;

  /// No description provided for @rankingFirstPlace.
  ///
  /// In es, this message translates to:
  /// **'{name} en primer lugar con {xp} XP'**
  String rankingFirstPlace(Object name, Object xp);

  /// No description provided for @rankingSecondPlace.
  ///
  /// In es, this message translates to:
  /// **'{name} en segundo lugar con {xp} XP'**
  String rankingSecondPlace(Object name, Object xp);

  /// No description provided for @rankingThirdPlace.
  ///
  /// In es, this message translates to:
  /// **'{name} en tercer lugar con {xp} XP'**
  String rankingThirdPlace(Object name, Object xp);

  /// No description provided for @rankingXpToTop50.
  ///
  /// In es, this message translates to:
  /// **'Te faltan {xp} XP para entrar al Top 50'**
  String rankingXpToTop50(Object xp);

  /// No description provided for @rankingYourPosition.
  ///
  /// In es, this message translates to:
  /// **'Tu posición: #{rank} · {xp} XP'**
  String rankingYourPosition(Object xp, Object rank);

  /// No description provided for @rarityGold.
  ///
  /// In es, this message translates to:
  /// **'Oro'**
  String get rarityGold;

  /// No description provided for @rarityPlatinum.
  ///
  /// In es, this message translates to:
  /// **'Platino'**
  String get rarityPlatinum;

  /// No description provided for @raritySilver.
  ///
  /// In es, this message translates to:
  /// **'Plata'**
  String get raritySilver;

  /// No description provided for @recommended.
  ///
  /// In es, this message translates to:
  /// **'RECOMENDADO'**
  String get recommended;

  /// No description provided for @reduceAnimations.
  ///
  /// In es, this message translates to:
  /// **'Reducir animaciones'**
  String get reduceAnimations;

  /// No description provided for @reduceAnimationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reduce la intensidad de animaciones'**
  String get reduceAnimationsSubtitle;

  /// No description provided for @regAgeQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuántos años tienes?'**
  String get regAgeQuestion;

  /// No description provided for @regAgeValidation.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa tu verdadera edad'**
  String get regAgeValidation;

  /// No description provided for @regChooseMethod.
  ///
  /// In es, this message translates to:
  /// **'Elige un método para crear tu cuenta.'**
  String get regChooseMethod;

  /// No description provided for @regCloudSave.
  ///
  /// In es, this message translates to:
  /// **'Progreso guardado en la nube'**
  String get regCloudSave;

  /// No description provided for @regCreateProfile.
  ///
  /// In es, this message translates to:
  /// **'CREAR PERFIL'**
  String get regCreateProfile;

  /// No description provided for @regEmailDesc.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código de verificación.'**
  String get regEmailDesc;

  /// No description provided for @regEmailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get regEmailHint;

  /// No description provided for @regEmailOption.
  ///
  /// In es, this message translates to:
  /// **'Correo Electrónico'**
  String get regEmailOption;

  /// No description provided for @regEmailTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu correo electrónico'**
  String get regEmailTitle;

  /// No description provided for @regHowContinue.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo quieres continuar?'**
  String get regHowContinue;

  /// No description provided for @regLater.
  ///
  /// In es, this message translates to:
  /// **'Más adelante'**
  String get regLater;

  /// No description provided for @regNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get regNameHint;

  /// No description provided for @regNameQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te llamas?'**
  String get regNameQuestion;

  /// No description provided for @regPasswordDesc.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres con mayúscula, minúscula y un número.'**
  String get regPasswordDesc;

  /// No description provided for @regPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea una contraseña'**
  String get regPasswordTitle;

  /// No description provided for @regProfileAlmostReady.
  ///
  /// In es, this message translates to:
  /// **'¡Casi listo!'**
  String get regProfileAlmostReady;

  /// No description provided for @regProfileCreated.
  ///
  /// In es, this message translates to:
  /// **'PERFIL CREADO'**
  String get regProfileCreated;

  /// No description provided for @regProfileDesc.
  ///
  /// In es, this message translates to:
  /// **'Crea un perfil para guardar tu progreso y no perder tu racha.'**
  String get regProfileDesc;

  /// No description provided for @regReadyForLesson.
  ///
  /// In es, this message translates to:
  /// **'Prepárate para tu primera lección'**
  String get regReadyForLesson;

  /// No description provided for @regRewards.
  ///
  /// In es, this message translates to:
  /// **'Recompensas y logros personales'**
  String get regRewards;

  /// No description provided for @regStreakSync.
  ///
  /// In es, this message translates to:
  /// **'Racha sincronizada entre dispositivos'**
  String get regStreakSync;

  /// No description provided for @regSurnameHint.
  ///
  /// In es, this message translates to:
  /// **'Apellido'**
  String get regSurnameHint;

  /// No description provided for @regWelcomeSagen.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a SAGEN!'**
  String get regWelcomeSagen;

  /// No description provided for @resultAccuracy.
  ///
  /// In es, this message translates to:
  /// **'Precisión'**
  String get resultAccuracy;

  /// No description provided for @resultCompleteTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Lección completada!'**
  String get resultCompleteTitle;

  /// No description provided for @resultLives.
  ///
  /// In es, this message translates to:
  /// **'Vidas'**
  String get resultLives;

  /// No description provided for @resultNotPerfectDesc.
  ///
  /// In es, this message translates to:
  /// **'Sigue practicando para lograr una sesión perfecta.'**
  String get resultNotPerfectDesc;

  /// No description provided for @resultPerfectBadge.
  ///
  /// In es, this message translates to:
  /// **'SESIÓN PERFECTA'**
  String get resultPerfectBadge;

  /// No description provided for @resultPerfectDesc.
  ///
  /// In es, this message translates to:
  /// **'No cometiste ningún error. Eres un guardián digital.'**
  String get resultPerfectDesc;

  /// No description provided for @resultPerfectTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Resultado impecable!'**
  String get resultPerfectTitle;

  /// No description provided for @resumeQuiz.
  ///
  /// In es, this message translates to:
  /// **'¿Reanudar cuestionario?'**
  String get resumeQuiz;

  /// No description provided for @resumeLessonBody.
  ///
  /// In es, this message translates to:
  /// **'Tienes una lección a medias de hace menos de 30 minutos. ¿Quieres retomarla donde la dejaste o empezar de nuevo?'**
  String get resumeLessonBody;

  /// No description provided for @resumeContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get resumeContinue;

  /// No description provided for @retryStart.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get retryStart;

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @reward100Xp.
  ///
  /// In es, this message translates to:
  /// **'100 XP'**
  String get reward100Xp;

  /// No description provided for @reward200Exp.
  ///
  /// In es, this message translates to:
  /// **'200 EXP'**
  String get reward200Exp;

  /// No description provided for @rewardAdEarnedGems.
  ///
  /// In es, this message translates to:
  /// **'+{gems} gemas'**
  String rewardAdEarnedGems(Object gems);

  /// No description provided for @rewardCopperFrame.
  ///
  /// In es, this message translates to:
  /// **'Marco de Cobre'**
  String get rewardCopperFrame;

  /// No description provided for @rewardEpicChest.
  ///
  /// In es, this message translates to:
  /// **'Cofre Épico'**
  String get rewardEpicChest;

  /// No description provided for @rewardGoldenChest.
  ///
  /// In es, this message translates to:
  /// **'Cofre dorado'**
  String get rewardGoldenChest;

  /// No description provided for @rewardIceFlame.
  ///
  /// In es, this message translates to:
  /// **'Llama de Hielo + Guardián'**
  String get rewardIceFlame;

  /// No description provided for @rewardTitaniumShield.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Titanio'**
  String get rewardTitaniumShield;

  /// No description provided for @routeSelection1.
  ///
  /// In es, this message translates to:
  /// **'Fundamentos primero'**
  String get routeSelection1;

  /// No description provided for @routeSelection2.
  ///
  /// In es, this message translates to:
  /// **'Ruta intermedia'**
  String get routeSelection2;

  /// No description provided for @routeSelection3.
  ///
  /// In es, this message translates to:
  /// **'Ruta avanzada'**
  String get routeSelection3;

  /// No description provided for @sageMonocleActive.
  ///
  /// In es, this message translates to:
  /// **'Monóculo Sabio activo'**
  String get sageMonocleActive;

  /// No description provided for @sageMonocleButton.
  ///
  /// In es, this message translates to:
  /// **'Usar Monóculo Sabio (elimina 2 incorrectas)'**
  String get sageMonocleButton;

  /// No description provided for @sagenPassSupportSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Obtén beneficios exclusivos y ayuda a mejorar la app'**
  String get sagenPassSupportSubtitle;

  /// No description provided for @sagenPassSupportTitle.
  ///
  /// In es, this message translates to:
  /// **'Apoya SAGEN'**
  String get sagenPassSupportTitle;

  /// No description provided for @sagenPassTitle.
  ///
  /// In es, this message translates to:
  /// **'Pase SAGEN'**
  String get sagenPassTitle;

  /// No description provided for @selectedAnswer.
  ///
  /// In es, this message translates to:
  /// **'Seleccionada'**
  String get selectedAnswer;

  /// No description provided for @sendMessage.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendMessage;

  /// No description provided for @sessionBackToMap.
  ///
  /// In es, this message translates to:
  /// **'Volver al mapa'**
  String get sessionBackToMap;

  /// No description provided for @sessionCorrect.
  ///
  /// In es, this message translates to:
  /// **'¡Correcto!'**
  String get sessionCorrect;

  /// No description provided for @sessionCorrectAnswer.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta: {answer}'**
  String sessionCorrectAnswer(Object answer);

  /// No description provided for @sessionIncorrect.
  ///
  /// In es, this message translates to:
  /// **'Incorrecto'**
  String get sessionIncorrect;

  /// No description provided for @sessionLivesExhausted.
  ///
  /// In es, this message translates to:
  /// **'Vidas agotadas'**
  String get sessionLivesExhausted;

  /// No description provided for @sessionLivesExhaustedDesc.
  ///
  /// In es, this message translates to:
  /// **'Has perdido todas tus vidas. Vuelve a intentarlo.'**
  String get sessionLivesExhaustedDesc;

  /// No description provided for @sessionLoading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get sessionLoading;

  /// No description provided for @sessionRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get sessionRetry;

  /// No description provided for @sessionScore.
  ///
  /// In es, this message translates to:
  /// **'{correct}/{total} correctas'**
  String sessionScore(Object correct, Object total);

  /// No description provided for @sessionSelectAnswer.
  ///
  /// In es, this message translates to:
  /// **'Selecciona una respuesta'**
  String get sessionSelectAnswer;

  /// No description provided for @settingsLanguage.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get settingsLanguage;

  /// No description provided for @settingsLogout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que quieres cerrar sesión?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsNotifications.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de racha y cofre diario'**
  String get settingsNotificationsSubtitle;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @shareProfile.
  ///
  /// In es, this message translates to:
  /// **'Compartir tarjeta de perfil'**
  String get shareProfile;

  /// No description provided for @shareRanking.
  ///
  /// In es, this message translates to:
  /// **'Compartir ranking'**
  String get shareRanking;

  /// No description provided for @sharing.
  ///
  /// In es, this message translates to:
  /// **'Compartiendo...'**
  String get sharing;

  /// No description provided for @showPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get showPassword;

  /// No description provided for @skipText.
  ///
  /// In es, this message translates to:
  /// **'Saltar'**
  String get skipText;

  /// No description provided for @skipToContent.
  ///
  /// In es, this message translates to:
  /// **'Saltar al contenido principal'**
  String get skipToContent;

  /// No description provided for @sounds.
  ///
  /// In es, this message translates to:
  /// **'Sonidos'**
  String get sounds;

  /// No description provided for @soundsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Efectos de sonido de la app'**
  String get soundsSubtitle;

  /// No description provided for @speedSort2fa.
  ///
  /// In es, this message translates to:
  /// **'Autenticación en dos pasos'**
  String get speedSort2fa;

  /// No description provided for @speedSortAntivirus.
  ///
  /// In es, this message translates to:
  /// **'Antivirus'**
  String get speedSortAntivirus;

  /// No description provided for @speedSortDataEncryption.
  ///
  /// In es, this message translates to:
  /// **'Cifrado de datos'**
  String get speedSortDataEncryption;

  /// No description provided for @speedSortFakeEmail.
  ///
  /// In es, this message translates to:
  /// **'Correo falso'**
  String get speedSortFakeEmail;

  /// No description provided for @speedSortFirewall.
  ///
  /// In es, this message translates to:
  /// **'Cortafuegos'**
  String get speedSortFirewall;

  /// No description provided for @speedSortFraudulentCall.
  ///
  /// In es, this message translates to:
  /// **'Llamada fraudulenta'**
  String get speedSortFraudulentCall;

  /// No description provided for @speedSortProtectionCategory.
  ///
  /// In es, this message translates to:
  /// **'Protección'**
  String get speedSortProtectionCategory;

  /// No description provided for @speedSortScamCategory.
  ///
  /// In es, this message translates to:
  /// **'Estafa'**
  String get speedSortScamCategory;

  /// No description provided for @speedSortSecurityCategory.
  ///
  /// In es, this message translates to:
  /// **'Seguridad'**
  String get speedSortSecurityCategory;

  /// No description provided for @speedSortSmsLink.
  ///
  /// In es, this message translates to:
  /// **'Enlace SMS'**
  String get speedSortSmsLink;

  /// No description provided for @speedSortStrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña segura'**
  String get speedSortStrongPassword;

  /// No description provided for @speedSortVpn.
  ///
  /// In es, this message translates to:
  /// **'VPN'**
  String get speedSortVpn;

  /// No description provided for @splashTitle.
  ///
  /// In es, this message translates to:
  /// **'SAGEN'**
  String get splashTitle;

  /// No description provided for @stageProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso de etapa: {percent} por ciento'**
  String stageProgress(Object percent);

  /// No description provided for @startText.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get startText;

  /// No description provided for @statsExcellent.
  ///
  /// In es, this message translates to:
  /// **'¡Excelente!'**
  String get statsExcellent;

  /// No description provided for @statsIncredible.
  ///
  /// In es, this message translates to:
  /// **'¡Increíble!'**
  String get statsIncredible;

  /// No description provided for @statsKeepTrying.
  ///
  /// In es, this message translates to:
  /// **'Sigue intentándolo.'**
  String get statsKeepTrying;

  /// No description provided for @statsNoData.
  ///
  /// In es, this message translates to:
  /// **'No hay datos de lección'**
  String get statsNoData;

  /// No description provided for @statsNoErrors.
  ///
  /// In es, this message translates to:
  /// **'¡Sin errores!'**
  String get statsNoErrors;

  /// No description provided for @statsReceiveXp.
  ///
  /// In es, this message translates to:
  /// **'RECIBIR XP'**
  String get statsReceiveXp;

  /// No description provided for @statsSpeed.
  ///
  /// In es, this message translates to:
  /// **'Velocidad'**
  String get statsSpeed;

  /// No description provided for @statsStartStage1.
  ///
  /// In es, this message translates to:
  /// **'Empezarás desde la Etapa 1, Lección 1'**
  String get statsStartStage1;

  /// No description provided for @statsStartStage2.
  ///
  /// In es, this message translates to:
  /// **'Empezarás desde la Etapa 2, Lección 1'**
  String get statsStartStage2;

  /// No description provided for @statsWellDone.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho!'**
  String get statsWellDone;

  /// No description provided for @statusCompleted.
  ///
  /// In es, this message translates to:
  /// **'completada'**
  String get statusCompleted;

  /// No description provided for @storeBuyItem.
  ///
  /// In es, this message translates to:
  /// **'Comprar {item} por {cost} donaciones'**
  String storeBuyItem(Object cost, Object item);

  /// No description provided for @storeCategoryConsumables.
  ///
  /// In es, this message translates to:
  /// **'Consumibles'**
  String get storeCategoryConsumables;

  /// No description provided for @storeCategoryCosmetics.
  ///
  /// In es, this message translates to:
  /// **'Cosméticos'**
  String get storeCategoryCosmetics;

  /// No description provided for @storeCategoryThemes.
  ///
  /// In es, this message translates to:
  /// **'Temas'**
  String get storeCategoryThemes;

  /// No description provided for @storeConfirmMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Deseas comprar {item} por {cost} donaciones?'**
  String storeConfirmMessage(Object cost, Object item);

  /// No description provided for @storeConfirmTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar compra'**
  String get storeConfirmTitle;

  /// No description provided for @storeGemTipAchievement.
  ///
  /// In es, this message translates to:
  /// **'Logros: gemas según dificultad'**
  String get storeGemTipAchievement;

  /// No description provided for @storeGemTipChest.
  ///
  /// In es, this message translates to:
  /// **'Abre cofres: gemas según el cofre'**
  String get storeGemTipChest;

  /// No description provided for @storeGemTipFirstLesson.
  ///
  /// In es, this message translates to:
  /// **'Primera lección del día: +10 gemas'**
  String get storeGemTipFirstLesson;

  /// No description provided for @storeGemTipLesson.
  ///
  /// In es, this message translates to:
  /// **'Completa lecciones: 5 gemas por respuesta correcta'**
  String get storeGemTipLesson;

  /// No description provided for @storeGemTipMission.
  ///
  /// In es, this message translates to:
  /// **'Misiones diarias: +12 gemas'**
  String get storeGemTipMission;

  /// No description provided for @storeGemTipPerfect.
  ///
  /// In es, this message translates to:
  /// **'Lección perfecta: +20 gemas extra'**
  String get storeGemTipPerfect;

  /// No description provided for @storeGemTipStreak.
  ///
  /// In es, this message translates to:
  /// **'Rachas: hasta +150 gemas'**
  String get storeGemTipStreak;

  /// No description provided for @storeHowToEarnGems.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo conseguir gemas?'**
  String get storeHowToEarnGems;

  /// No description provided for @storePersonalization.
  ///
  /// In es, this message translates to:
  /// **'Personalización'**
  String get storePersonalization;

  /// No description provided for @storeProtectStreak.
  ///
  /// In es, this message translates to:
  /// **'Protege tu racha'**
  String get storeProtectStreak;

  /// No description provided for @storeDailyChestClaim.
  ///
  /// In es, this message translates to:
  /// **'Reclamar'**
  String get storeDailyChestClaim;

  /// No description provided for @storeDailyChestReward.
  ///
  /// In es, this message translates to:
  /// **'¡+{xp} XP!'**
  String storeDailyChestReward(Object xp);

  /// No description provided for @storeDailyChestSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Reclama tu recompensa diaria gratuita'**
  String get storeDailyChestSubtitle;

  /// No description provided for @storeDailyChestTitle.
  ///
  /// In es, this message translates to:
  /// **'Cofre diario'**
  String get storeDailyChestTitle;

  /// No description provided for @storePurchaseFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al validar la compra. Inténtalo de nuevo.'**
  String get storePurchaseFailed;

  /// No description provided for @storeNeedMoreGems.
  ///
  /// In es, this message translates to:
  /// **'Necesitas {needed} gemas más ({have}/{need})'**
  String storeNeedMoreGems(Object have, Object need, Object needed);

  /// No description provided for @storePurchaseSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Compra exitosa!'**
  String get storePurchaseSuccess;

  /// No description provided for @storeAlreadyOwned.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes este artículo.'**
  String get storeAlreadyOwned;

  /// No description provided for @storeShieldLimitReached.
  ///
  /// In es, this message translates to:
  /// **'Límite de protectores alcanzado'**
  String get storeShieldLimitReached;

  /// No description provided for @storeSupportTiers.
  ///
  /// In es, this message translates to:
  /// **'Niveles de apoyo'**
  String get storeSupportTiers;

  /// No description provided for @storeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get storeTitle;

  /// No description provided for @streakAchievements.
  ///
  /// In es, this message translates to:
  /// **'Logros y medallas por constancia'**
  String get streakAchievements;

  /// No description provided for @streakBadge.
  ///
  /// In es, this message translates to:
  /// **'RACHA'**
  String get streakBadge;

  /// No description provided for @streakDayLabel.
  ///
  /// In es, this message translates to:
  /// **'días de racha'**
  String get streakDayLabel;

  /// No description provided for @streakDays.
  ///
  /// In es, this message translates to:
  /// **'{count} días'**
  String streakDays(Object count);

  /// No description provided for @streakDaysCount.
  ///
  /// In es, this message translates to:
  /// **'{count} días de racha'**
  String streakDaysCount(Object count);

  /// No description provided for @streakFireCardLabel.
  ///
  /// In es, this message translates to:
  /// **'Racha de Fuego'**
  String get streakFireCardLabel;

  /// No description provided for @streakFreeze.
  ///
  /// In es, this message translates to:
  /// **'Protector de racha'**
  String get streakFreeze;

  /// No description provided for @streakFreezeDescription.
  ///
  /// In es, this message translates to:
  /// **'Mantén tu racha al fallar un día'**
  String get streakFreezeDescription;

  /// No description provided for @streakFrozen.
  ///
  /// In es, this message translates to:
  /// **'Racha congelada'**
  String get streakFrozen;

  /// No description provided for @streakGotIt.
  ///
  /// In es, this message translates to:
  /// **'ENTENDIDO'**
  String get streakGotIt;

  /// No description provided for @streakKeepAlive.
  ///
  /// In es, this message translates to:
  /// **'¡Mantén tu racha activa!'**
  String get streakKeepAlive;

  /// No description provided for @streakKeepAliveDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección cada día para mantener tu racha.\nCada día cuenta para fortalecer tu escudo digital.'**
  String get streakKeepAliveDesc;

  /// No description provided for @streakMsg1.
  ///
  /// In es, this message translates to:
  /// **'¡Una nueva racha! Practica cada día y ayúdala a crecer.'**
  String get streakMsg1;

  /// No description provided for @streakMsg2.
  ///
  /// In es, this message translates to:
  /// **'¡Racha activa! La constancia es tu mejor arma hoy.'**
  String get streakMsg2;

  /// No description provided for @streakMsg3.
  ///
  /// In es, this message translates to:
  /// **'Cada día cuenta. Tu compromiso te hace más fuerte.'**
  String get streakMsg3;

  /// No description provided for @streakMsg4.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así! La disciplina de hoy es la victoria de mañana.'**
  String get streakMsg4;

  /// No description provided for @streakMsg5.
  ///
  /// In es, this message translates to:
  /// **'Un día más, un paso más cerca de tu meta.'**
  String get streakMsg5;

  /// No description provided for @streakNoActiveStreak.
  ///
  /// In es, this message translates to:
  /// **'Sin racha activa'**
  String get streakNoActiveStreak;

  /// No description provided for @streakRewards.
  ///
  /// In es, this message translates to:
  /// **'Recompensas exclusivas al alcanzar metas'**
  String get streakRewards;

  /// No description provided for @streakShieldActive.
  ///
  /// In es, this message translates to:
  /// **'Escudo activo — ¡tu racha está protegida hoy!'**
  String get streakShieldActive;

  /// No description provided for @streakShieldOnboarding.
  ///
  /// In es, this message translates to:
  /// **'Compra un escudo para proteger tu racha si te pierdes un día.'**
  String get streakShieldOnboarding;

  /// No description provided for @streakStrongerShield.
  ///
  /// In es, this message translates to:
  /// **'Escudo más fuerte cada día'**
  String get streakStrongerShield;

  /// No description provided for @summaryCommitment.
  ///
  /// In es, this message translates to:
  /// **'Compromiso'**
  String get summaryCommitment;

  /// No description provided for @summaryDailyGoal.
  ///
  /// In es, this message translates to:
  /// **'Meta diaria'**
  String get summaryDailyGoal;

  /// No description provided for @summaryKnowledge.
  ///
  /// In es, this message translates to:
  /// **'Conocimiento'**
  String get summaryKnowledge;

  /// No description provided for @summaryLearning.
  ///
  /// In es, this message translates to:
  /// **'Aprendizaje'**
  String get summaryLearning;

  /// No description provided for @summaryPreferences.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get summaryPreferences;

  /// No description provided for @summaryMotivations.
  ///
  /// In es, this message translates to:
  /// **'Motivaciones'**
  String get summaryMotivations;

  /// No description provided for @summaryOrigin.
  ///
  /// In es, this message translates to:
  /// **'Origen'**
  String get summaryOrigin;

  /// No description provided for @summaryReady.
  ///
  /// In es, this message translates to:
  /// **'Todo listo para empezar tu viaje en seguridad digital.'**
  String get summaryReady;

  /// No description provided for @thankYouForSupport.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu apoyo!'**
  String get thankYouForSupport;

  /// No description provided for @themeDarkLabel.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDarkLabel;

  /// No description provided for @themeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeLightLabel.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLightLabel;

  /// No description provided for @themeSystemLabel.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystemLabel;

  /// No description provided for @tryAgain.
  ///
  /// In es, this message translates to:
  /// **'Conéctate e inténtalo nuevamente.'**
  String get tryAgain;

  /// No description provided for @tutorLessonsProgress.
  ///
  /// In es, this message translates to:
  /// **'{completed} / {required} lecciones'**
  String tutorLessonsProgress(Object completed, Object required);

  /// No description provided for @tutorLocked.
  ///
  /// In es, this message translates to:
  /// **'Tutor IA Bloqueado'**
  String get tutorLocked;

  /// No description provided for @tutorLockedDescription.
  ///
  /// In es, this message translates to:
  /// **'Completa al menos 10 lecciones para desbloquear a Sage, tu tutor personal de ciberseguridad.'**
  String get tutorLockedDescription;

  /// No description provided for @tutorMotivationAlmost.
  ///
  /// In es, this message translates to:
  /// **'Ya casi, solo te faltan {count} lecciones. ¡Sigue así!'**
  String tutorMotivationAlmost(Object count);

  /// No description provided for @tutorMotivationGeneral.
  ///
  /// In es, this message translates to:
  /// **'Cada lección te acerca más a tu tutor personal de ciberseguridad.'**
  String get tutorMotivationGeneral;

  /// No description provided for @tutorMotivationGood.
  ///
  /// In es, this message translates to:
  /// **'¡Buen ritmo! Te faltan {count} lecciones para acceder a Sage.'**
  String tutorMotivationGood(Object count);

  /// No description provided for @tutorSampleAnswer1.
  ///
  /// In es, this message translates to:
  /// **'Nunca compartas tu contraseña. Usa un gestor de contraseñas y activa la autenticación de dos factores.'**
  String get tutorSampleAnswer1;

  /// No description provided for @tutorSampleQuestion1.
  ///
  /// In es, this message translates to:
  /// **'¿Qué debo hacer si recibo un correo sospechoso?'**
  String get tutorSampleQuestion1;

  /// No description provided for @tutorSampleQuestion2.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo puedo crear una contraseña segura?'**
  String get tutorSampleQuestion2;

  /// No description provided for @tutorSampleTitle.
  ///
  /// In es, this message translates to:
  /// **'Conversación de ejemplo'**
  String get tutorSampleTitle;

  /// No description provided for @unknownLabel.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknownLabel;

  /// No description provided for @updateChangelog.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones y novedades'**
  String get updateChangelog;

  /// No description provided for @updateChangelogDesc.
  ///
  /// In es, this message translates to:
  /// **'Nueva pantalla en la barra inferior que muestra el historial de cambios y novedades de la app.'**
  String get updateChangelogDesc;

  /// No description provided for @updateChestSystem.
  ///
  /// In es, this message translates to:
  /// **'Cofres de racha y lección'**
  String get updateChestSystem;

  /// No description provided for @updateChestSystemDesc.
  ///
  /// In es, this message translates to:
  /// **'Nuevo sistema de cofres: cofre diario por racha, cofre de lección cada 3/5/6/10 lecciones completadas.'**
  String get updateChestSystemDesc;

  /// No description provided for @updateDailyMissions.
  ///
  /// In es, this message translates to:
  /// **'Misiones diarias'**
  String get updateDailyMissions;

  /// No description provided for @updateDailyMissionsDesc.
  ///
  /// In es, this message translates to:
  /// **'Sistema de misiones diarias con recompensas en donaciones y experiencia.'**
  String get updateDailyMissionsDesc;

  /// No description provided for @updateEnergySystem.
  ///
  /// In es, this message translates to:
  /// **'Sistema de Energía'**
  String get updateEnergySystem;

  /// No description provided for @updateEnergySystemDesc.
  ///
  /// In es, this message translates to:
  /// **'Ahora cada lección consume energía. Responde bien para gastar solo 1, fallar cuesta 2. Los combos de aciertos regeneran energía. Al llegar a 0 no puedes continuar la lección.'**
  String get updateEnergySystemDesc;

  /// No description provided for @updateFirstVersion.
  ///
  /// In es, this message translates to:
  /// **'Primera versión'**
  String get updateFirstVersion;

  /// No description provided for @updateFirstVersionDesc.
  ///
  /// In es, this message translates to:
  /// **'Lanzamiento inicial con lecciones interactivas, racha diaria, donaciones, tienda y perfil de usuario.'**
  String get updateFirstVersionDesc;

  /// No description provided for @updateImprovedIcons.
  ///
  /// In es, this message translates to:
  /// **'Iconos de objetos mejorados'**
  String get updateImprovedIcons;

  /// No description provided for @updateImprovedIconsDesc.
  ///
  /// In es, this message translates to:
  /// **'Todos los objetos especiales ahora tienen iconos personalizados y más llamativos en la tienda y el inventario.'**
  String get updateImprovedIconsDesc;

  /// No description provided for @updateInfiniteEnergy.
  ///
  /// In es, this message translates to:
  /// **'Energía Infinita'**
  String get updateInfiniteEnergy;

  /// No description provided for @updateInfiniteEnergyDesc.
  ///
  /// In es, this message translates to:
  /// **'Nuevo objeto especial en la tienda que otorga energía ilimitada por tiempo limitado. Actívalo desde tu inventario.'**
  String get updateInfiniteEnergyDesc;

  /// No description provided for @updateLessonBoosters.
  ///
  /// In es, this message translates to:
  /// **'Potenciadores de lección'**
  String get updateLessonBoosters;

  /// No description provided for @updateLessonBoostersDesc.
  ///
  /// In es, this message translates to:
  /// **'Nuevos objetos: Boost de XP (2x), Multiplicador de XP (2x en cofres), Boost de suerte (2x probabilidades). Se compran y activan desde la tienda.'**
  String get updateLessonBoostersDesc;

  /// No description provided for @updateMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago integrado'**
  String get updateMercadoPago;

  /// No description provided for @updateMercadoPagoDesc.
  ///
  /// In es, this message translates to:
  /// **'Pagos directos con Mercado Pago para paquetes de donaciones y bundles. También disponible el pago por WhatsApp.'**
  String get updateMercadoPagoDesc;

  /// No description provided for @updateProgrammaticMascot.
  ///
  /// In es, this message translates to:
  /// **'Mascota programática'**
  String get updateProgrammaticMascot;

  /// No description provided for @updateProgrammaticMascotDesc.
  ///
  /// In es, this message translates to:
  /// **'La mascota ahora se dibuja con CustomPainter. 29 emociones, sin assets, transiciones suaves entre emociones.'**
  String get updateProgrammaticMascotDesc;

  /// No description provided for @updateStreakProtectorImproved.
  ///
  /// In es, this message translates to:
  /// **'Protector de racha mejorado'**
  String get updateStreakProtectorImproved;

  /// No description provided for @updateStreakProtectorImprovedDesc.
  ///
  /// In es, this message translates to:
  /// **'Límite máximo de 2 protectores. Al alcanzarlo, se muestran ofertas de potenciadores en su lugar.'**
  String get updateStreakProtectorImprovedDesc;

  /// No description provided for @updateTestFix.
  ///
  /// In es, this message translates to:
  /// **'Corrección de pruebas unitarias'**
  String get updateTestFix;

  /// No description provided for @updateTestFixDesc.
  ///
  /// In es, this message translates to:
  /// **'Se corrigieron 7 pruebas fallidas. Ahora todas las pruebas pasan correctamente (419 tests). 0 issues de análisis.'**
  String get updateTestFixDesc;

  /// No description provided for @updateTypedRoutes.
  ///
  /// In es, this message translates to:
  /// **'Rutas tipadas con GoRouter Builder'**
  String get updateTypedRoutes;

  /// No description provided for @updateTypedRoutesDesc.
  ///
  /// In es, this message translates to:
  /// **'Las rutas de splash y welcome ahora son tipadas, detectando errores en tiempo de compilación.'**
  String get updateTypedRoutesDesc;

  /// No description provided for @verifyEmailCheckButton.
  ///
  /// In es, this message translates to:
  /// **'Ya verifiqué'**
  String get verifyEmailCheckButton;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In es, this message translates to:
  /// **'Enviamos un enlace de verificación a {email}. Haz clic en el enlace para activar tu cuenta.'**
  String verifyEmailMessage(Object email);

  /// No description provided for @verifyEmailNotVerified.
  ///
  /// In es, this message translates to:
  /// **'Tu correo aún no ha sido verificado. Revisa tu bandeja de entrada.'**
  String get verifyEmailNotVerified;

  /// No description provided for @verifyEmailResendButton.
  ///
  /// In es, this message translates to:
  /// **'Reenviar correo de verificación'**
  String get verifyEmailResendButton;

  /// No description provided for @verifyEmailResendError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reenviar el correo. Por favor, intenta de nuevo.'**
  String get verifyEmailResendError;

  /// No description provided for @verifyEmailSent.
  ///
  /// In es, this message translates to:
  /// **'Correo de verificación enviado. Revisa tu bandeja de entrada.'**
  String get verifyEmailSent;

  /// No description provided for @verifyEmailSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get verifyEmailSignOut;

  /// No description provided for @verifyEmailSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Correo verificado! Bienvenido a SAGEN.'**
  String get verifyEmailSuccess;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In es, this message translates to:
  /// **'Verifica tu correo electrónico'**
  String get verifyEmailTitle;

  /// No description provided for @viewAchievements.
  ///
  /// In es, this message translates to:
  /// **'Ver logros'**
  String get viewAchievements;

  /// No description provided for @welcomeLoginButton.
  ///
  /// In es, this message translates to:
  /// **'YA TENGO UNA CUENTA'**
  String get welcomeLoginButton;

  /// No description provided for @welcomeStartButton.
  ///
  /// In es, this message translates to:
  /// **'EMPIEZA AHORA'**
  String get welcomeStartButton;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Análisis inteligente y seguridad digital.\nGratis de por vida.'**
  String get welcomeSubtitle;

  /// No description provided for @wizardAllAbove.
  ///
  /// In es, this message translates to:
  /// **'Todo lo anterior'**
  String get wizardAllAbove;

  /// No description provided for @wizardAppStore.
  ///
  /// In es, this message translates to:
  /// **'App Store'**
  String get wizardAppStore;

  /// No description provided for @wizardArticles.
  ///
  /// In es, this message translates to:
  /// **'Leer artículos'**
  String get wizardArticles;

  /// No description provided for @wizardBoostStudies.
  ///
  /// In es, this message translates to:
  /// **'Impulsar mis estudios'**
  String get wizardBoostStudies;

  /// No description provided for @wizardChatSage.
  ///
  /// In es, this message translates to:
  /// **'Chatea con Sage'**
  String get wizardChatSage;

  /// No description provided for @wizardCommit14.
  ///
  /// In es, this message translates to:
  /// **'14 días'**
  String get wizardCommit14;

  /// No description provided for @wizardCommit14Sub.
  ///
  /// In es, this message translates to:
  /// **'80 donaciones'**
  String get wizardCommit14Sub;

  /// No description provided for @wizardCommit30.
  ///
  /// In es, this message translates to:
  /// **'30 días'**
  String get wizardCommit30;

  /// No description provided for @wizardCommit30Sub.
  ///
  /// In es, this message translates to:
  /// **'200 donaciones'**
  String get wizardCommit30Sub;

  /// No description provided for @wizardCommit50.
  ///
  /// In es, this message translates to:
  /// **'50 días'**
  String get wizardCommit50;

  /// No description provided for @wizardCommit50Sub.
  ///
  /// In es, this message translates to:
  /// **'400 donaciones'**
  String get wizardCommit50Sub;

  /// No description provided for @wizardCommit7.
  ///
  /// In es, this message translates to:
  /// **'7 días'**
  String get wizardCommit7;

  /// No description provided for @wizardCommit7Sub.
  ///
  /// In es, this message translates to:
  /// **'30 donaciones'**
  String get wizardCommit7Sub;

  /// No description provided for @wizardCommitment.
  ///
  /// In es, this message translates to:
  /// **'Elige tu compromiso'**
  String get wizardCommitment;

  /// No description provided for @wizardCommitmentSage.
  ///
  /// In es, this message translates to:
  /// **'Selecciona tus metas de constancia'**
  String get wizardCommitmentSage;

  /// No description provided for @wizardConfirmed.
  ///
  /// In es, this message translates to:
  /// **'Compromiso confirmado'**
  String get wizardConfirmed;

  /// No description provided for @wizardConfirmedSage.
  ///
  /// In es, this message translates to:
  /// **'¡Has configurado tu ruta de aprendizaje!'**
  String get wizardConfirmedSage;

  /// No description provided for @wizardCuriosity.
  ///
  /// In es, this message translates to:
  /// **'Por curiosidad'**
  String get wizardCuriosity;

  /// No description provided for @wizardDetectScams.
  ///
  /// In es, this message translates to:
  /// **'Detectar estafas'**
  String get wizardDetectScams;

  /// No description provided for @wizardFacebook.
  ///
  /// In es, this message translates to:
  /// **'Facebook'**
  String get wizardFacebook;

  /// No description provided for @wizardFriends.
  ///
  /// In es, this message translates to:
  /// **'Amigos'**
  String get wizardFriends;

  /// No description provided for @wizardGoal10.
  ///
  /// In es, this message translates to:
  /// **'10 min'**
  String get wizardGoal10;

  /// No description provided for @wizardGoal10Sub.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get wizardGoal10Sub;

  /// No description provided for @wizardGoal15.
  ///
  /// In es, this message translates to:
  /// **'15 min'**
  String get wizardGoal15;

  /// No description provided for @wizardGoal15Sub.
  ///
  /// In es, this message translates to:
  /// **'Serio'**
  String get wizardGoal15Sub;

  /// No description provided for @wizardGoal3.
  ///
  /// In es, this message translates to:
  /// **'3 min'**
  String get wizardGoal3;

  /// No description provided for @wizardGoal30.
  ///
  /// In es, this message translates to:
  /// **'30 min'**
  String get wizardGoal30;

  /// No description provided for @wizardGoal30Sub.
  ///
  /// In es, this message translates to:
  /// **'Intenso'**
  String get wizardGoal30Sub;

  /// No description provided for @wizardGoal3Sub.
  ///
  /// In es, this message translates to:
  /// **'Relajado'**
  String get wizardGoal3Sub;

  /// No description provided for @wizardGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get wizardGoogle;

  /// No description provided for @wizardHaveFun.
  ///
  /// In es, this message translates to:
  /// **'Divertirme'**
  String get wizardHaveFun;

  /// No description provided for @wizardHowFound.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo conociste SAGEN?'**
  String get wizardHowFound;

  /// No description provided for @wizardHowFoundSage.
  ///
  /// In es, this message translates to:
  /// **'Cuéntame, ¿cómo nos encontraste?'**
  String get wizardHowFoundSage;

  /// No description provided for @wizardHowMuchKnow.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto sabes de seguridad digital?'**
  String get wizardHowMuchKnow;

  /// No description provided for @wizardHowMuchKnowSage.
  ///
  /// In es, this message translates to:
  /// **'¿Qué tanto sabes del tema?'**
  String get wizardHowMuchKnowSage;

  /// No description provided for @wizardHowPrefer.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo prefieres aprender?'**
  String get wizardHowPrefer;

  /// No description provided for @wizardHowPreferSage.
  ///
  /// In es, this message translates to:
  /// **'Elige tus formas preferidas de aprender'**
  String get wizardHowPreferSage;

  /// No description provided for @wizardInstagram.
  ///
  /// In es, this message translates to:
  /// **'Instagram'**
  String get wizardInstagram;

  /// No description provided for @wizardLevel1.
  ///
  /// In es, this message translates to:
  /// **'Soy principiante'**
  String get wizardLevel1;

  /// No description provided for @wizardLevel1Sub.
  ///
  /// In es, this message translates to:
  /// **'Nunca he explorado este tema'**
  String get wizardLevel1Sub;

  /// No description provided for @wizardLevel2.
  ///
  /// In es, this message translates to:
  /// **'Conozco algunos conceptos'**
  String get wizardLevel2;

  /// No description provided for @wizardLevel2Sub.
  ///
  /// In es, this message translates to:
  /// **'Reconozco algunos términos'**
  String get wizardLevel2Sub;

  /// No description provided for @wizardLevel3.
  ///
  /// In es, this message translates to:
  /// **'Puedo defenderme'**
  String get wizardLevel3;

  /// No description provided for @wizardLevel3Sub.
  ///
  /// In es, this message translates to:
  /// **'Entiendo y practico los fundamentos'**
  String get wizardLevel3Sub;

  /// No description provided for @wizardLevel4.
  ///
  /// In es, this message translates to:
  /// **'Entiendo varios temas'**
  String get wizardLevel4;

  /// No description provided for @wizardLevel4Sub.
  ///
  /// In es, this message translates to:
  /// **'Domino múltiples conceptos'**
  String get wizardLevel4Sub;

  /// No description provided for @wizardLevel5.
  ///
  /// In es, this message translates to:
  /// **'Conozco bien el tema'**
  String get wizardLevel5;

  /// No description provided for @wizardLevel5Sub.
  ///
  /// In es, this message translates to:
  /// **'Puedo debatir temas avanzados'**
  String get wizardLevel5Sub;

  /// No description provided for @wizardLinks.
  ///
  /// In es, this message translates to:
  /// **'Analizar enlaces'**
  String get wizardLinks;

  /// No description provided for @wizardNews.
  ///
  /// In es, this message translates to:
  /// **'Noticias'**
  String get wizardNews;

  /// No description provided for @wizardOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get wizardOther;

  /// No description provided for @wizardPrepareWork.
  ///
  /// In es, this message translates to:
  /// **'Prepárame para el trabajo'**
  String get wizardPrepareWork;

  /// No description provided for @wizardProtect.
  ///
  /// In es, this message translates to:
  /// **'Protegerme'**
  String get wizardProtect;

  /// No description provided for @wizardProtectAccounts.
  ///
  /// In es, this message translates to:
  /// **'Proteger mis cuentas'**
  String get wizardProtectAccounts;

  /// No description provided for @wizardProtectFamily.
  ///
  /// In es, this message translates to:
  /// **'Proteger a mi familia'**
  String get wizardProtectFamily;

  /// No description provided for @wizardProtectPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Proteger mi privacidad'**
  String get wizardProtectPrivacy;

  /// No description provided for @wizardQuizzes.
  ///
  /// In es, this message translates to:
  /// **'Practicar con cuestionarios'**
  String get wizardQuizzes;

  /// No description provided for @wizardSafeBrowsing.
  ///
  /// In es, this message translates to:
  /// **'Navega con seguridad'**
  String get wizardSafeBrowsing;

  /// No description provided for @wizardTV.
  ///
  /// In es, this message translates to:
  /// **'TV'**
  String get wizardTV;

  /// No description provided for @wizardTikTok.
  ///
  /// In es, this message translates to:
  /// **'TikTok'**
  String get wizardTikTok;

  /// No description provided for @wizardTimeDedicate.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto tiempo puedes dedicar al día?'**
  String get wizardTimeDedicate;

  /// No description provided for @wizardTimeSage.
  ///
  /// In es, this message translates to:
  /// **'Elige tu ritmo de aprendizaje ideal'**
  String get wizardTimeSage;

  /// No description provided for @wizardVideos.
  ///
  /// In es, this message translates to:
  /// **'Ver videos educativos'**
  String get wizardVideos;

  /// No description provided for @wizardWelcomeSage.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy Sage, tu guía de seguridad digital. ¿Empezamos?'**
  String get wizardWelcomeSage;

  /// No description provided for @wizardWelcomeTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a SAGEN!'**
  String get wizardWelcomeTitle;

  /// No description provided for @wizardWhatLearn.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustaría aprender?'**
  String get wizardWhatLearn;

  /// No description provided for @wizardWhatLearnSage.
  ///
  /// In es, this message translates to:
  /// **'¿Qué te gustaría aprender primero?'**
  String get wizardWhatLearnSage;

  /// No description provided for @wizardWhyLearn.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué quieres aprender?'**
  String get wizardWhyLearn;

  /// No description provided for @wizardWhyLearnSage.
  ///
  /// In es, this message translates to:
  /// **'¿Por qué quieres aprender sobre seguridad digital?'**
  String get wizardWhyLearnSage;

  /// No description provided for @wizardYouTube.
  ///
  /// In es, this message translates to:
  /// **'YouTube'**
  String get wizardYouTube;

  /// No description provided for @xpLevelUp.
  ///
  /// In es, this message translates to:
  /// **'Level Up!'**
  String get xpLevelUp;

  /// No description provided for @xpReward.
  ///
  /// In es, this message translates to:
  /// **'+{xp} XP'**
  String xpReward(Object xp);

  /// No description provided for @chatTypingIndicator.
  ///
  /// In es, this message translates to:
  /// **'Sage está escribiendo...'**
  String get chatTypingIndicator;

  /// No description provided for @demoModeOffline.
  ///
  /// In es, this message translates to:
  /// **'MODO DEMO — Sin conexión'**
  String get demoModeOffline;

  /// No description provided for @streakFlame.
  ///
  /// In es, this message translates to:
  /// **'Llama de racha'**
  String get streakFlame;

  /// No description provided for @tapToContinue.
  ///
  /// In es, this message translates to:
  /// **'Toca para continuar'**
  String get tapToContinue;

  /// No description provided for @exitQuizTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres salir de la lección?'**
  String get exitQuizTitle;

  /// No description provided for @exitQuizContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres salir del cuestionario?'**
  String get exitQuizContent;

  /// No description provided for @currentStreakDays.
  ///
  /// In es, this message translates to:
  /// **'Racha actual: {count} días'**
  String currentStreakDays(Object count);

  /// No description provided for @activityMap30Days.
  ///
  /// In es, this message translates to:
  /// **'Mapa de actividad de los últimos 30 días'**
  String get activityMap30Days;

  /// No description provided for @courseProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'Progreso total del curso: {percent}%'**
  String courseProgressLabel(Object percent);

  /// No description provided for @stageProgressLabel.
  ///
  /// In es, this message translates to:
  /// **'Progreso de etapa: {percent}%'**
  String stageProgressLabel(Object percent);

  /// No description provided for @collapseSession.
  ///
  /// In es, this message translates to:
  /// **'Colapsar sesión: {title}'**
  String collapseSession(Object title);

  /// No description provided for @expandSession.
  ///
  /// In es, this message translates to:
  /// **'Expandir sesión: {title}'**
  String expandSession(Object title);

  /// No description provided for @livesRemainingLabel.
  ///
  /// In es, this message translates to:
  /// **'Vidas restantes: {count} de 3'**
  String livesRemainingLabel(Object count);

  /// No description provided for @miniGameExitTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir del juego?'**
  String get miniGameExitTitle;

  /// No description provided for @miniGameExitContent.
  ///
  /// In es, this message translates to:
  /// **'Perderás tu progreso actual. ¿Estás seguro?'**
  String get miniGameExitContent;

  /// No description provided for @paymentCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'Cancelar pago'**
  String get paymentCancelTitle;

  /// No description provided for @paymentCancelContent.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro que quieres cancelar el pago? Se perderá el progreso.'**
  String get paymentCancelContent;

  /// No description provided for @resultXpGained.
  ///
  /// In es, this message translates to:
  /// **'{xp} ganados'**
  String resultXpGained(Object xp);

  /// No description provided for @resultAccuracyLabel.
  ///
  /// In es, this message translates to:
  /// **'Precisión: {percent}%'**
  String resultAccuracyLabel(Object percent);

  /// No description provided for @resultLivesLabel.
  ///
  /// In es, this message translates to:
  /// **'Vidas: {count}'**
  String resultLivesLabel(Object count);

  /// No description provided for @storeNewChestHint.
  ///
  /// In es, this message translates to:
  /// **'Nuevo cofre disponible'**
  String get storeNewChestHint;

  /// No description provided for @profilePhoto.
  ///
  /// In es, this message translates to:
  /// **'Foto de perfil'**
  String get profilePhoto;

  /// No description provided for @gemBalanceLabel.
  ///
  /// In es, this message translates to:
  /// **'Saldo de gemas: {count}'**
  String gemBalanceLabel(Object count);

  /// No description provided for @wizardStepLabel.
  ///
  /// In es, this message translates to:
  /// **'Paso {step}'**
  String wizardStepLabel(Object step);

  /// No description provided for @chestRewardShareText.
  ///
  /// In es, this message translates to:
  /// **'¡Obtuve {items} de un cofre {type} en SAGEN!'**
  String chestRewardShareText(Object items, Object type);

  /// No description provided for @gemRainAnimationLabel.
  ///
  /// In es, this message translates to:
  /// **'Animación de gemas cayendo'**
  String get gemRainAnimationLabel;

  /// No description provided for @exitQuizLabel.
  ///
  /// In es, this message translates to:
  /// **'Salir del cuestionario'**
  String get exitQuizLabel;

  /// No description provided for @shopItemFocusElixirName.
  ///
  /// In es, this message translates to:
  /// **'Elixir de Foco'**
  String get shopItemFocusElixirName;

  /// No description provided for @shopItemFocusElixirDesc.
  ///
  /// In es, this message translates to:
  /// **'2x EXP por 15 minutos'**
  String get shopItemFocusElixirDesc;

  /// No description provided for @shopItemXpBoostName.
  ///
  /// In es, this message translates to:
  /// **'Impulso de XP'**
  String get shopItemXpBoostName;

  /// No description provided for @shopItemXpBoostDesc.
  ///
  /// In es, this message translates to:
  /// **'2x XP en tu próxima lección'**
  String get shopItemXpBoostDesc;

  /// No description provided for @shopItemLuckBoostName.
  ///
  /// In es, this message translates to:
  /// **'Impulso de Suerte'**
  String get shopItemLuckBoostName;

  /// No description provided for @shopItemLuckBoostDesc.
  ///
  /// In es, this message translates to:
  /// **'+15% rareza de cofres por 30 min'**
  String get shopItemLuckBoostDesc;

  /// No description provided for @shopItemSageMonocleName.
  ///
  /// In es, this message translates to:
  /// **'Monocle de Sage'**
  String get shopItemSageMonocleName;

  /// No description provided for @shopItemSageMonocleDesc.
  ///
  /// In es, this message translates to:
  /// **'Elimina 2 respuestas incorrectas'**
  String get shopItemSageMonocleDesc;

  /// No description provided for @shopItemTimeWarpName.
  ///
  /// In es, this message translates to:
  /// **'Warp del Tiempo'**
  String get shopItemTimeWarpName;

  /// No description provided for @shopItemTimeWarpDesc.
  ///
  /// In es, this message translates to:
  /// **'Salta el enfriamiento en la próxima revisión'**
  String get shopItemTimeWarpDesc;

  /// No description provided for @shopItemTitaniumShieldName.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Titanio'**
  String get shopItemTitaniumShieldName;

  /// No description provided for @shopItemTitaniumShieldDesc.
  ///
  /// In es, this message translates to:
  /// **'Protege tu racha si pierdes 1 día'**
  String get shopItemTitaniumShieldDesc;

  /// No description provided for @shopItemPhoenixFeatherName.
  ///
  /// In es, this message translates to:
  /// **'Pluma de Fénix'**
  String get shopItemPhoenixFeatherName;

  /// No description provided for @shopItemPhoenixFeatherDesc.
  ///
  /// In es, this message translates to:
  /// **'Revive tu racha si se pierde'**
  String get shopItemPhoenixFeatherDesc;

  /// No description provided for @shopItemNeonFrameName.
  ///
  /// In es, this message translates to:
  /// **'Marco Neón'**
  String get shopItemNeonFrameName;

  /// No description provided for @shopItemNeonFrameDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco animado con brillo neón'**
  String get shopItemNeonFrameDesc;

  /// No description provided for @shopItemGalaxyFrameName.
  ///
  /// In es, this message translates to:
  /// **'Marco Galaxia'**
  String get shopItemGalaxyFrameName;

  /// No description provided for @shopItemGalaxyFrameDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco estelar galáctico'**
  String get shopItemGalaxyFrameDesc;

  /// No description provided for @shopItemDragonFrameName.
  ///
  /// In es, this message translates to:
  /// **'Marco Dragón'**
  String get shopItemDragonFrameName;

  /// No description provided for @shopItemDragonFrameDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco de fuego de dragón animado'**
  String get shopItemDragonFrameDesc;

  /// No description provided for @shopItemCrystalFrameName.
  ///
  /// In es, this message translates to:
  /// **'Marco Cristal'**
  String get shopItemCrystalFrameName;

  /// No description provided for @shopItemCrystalFrameDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco de hielo cristalino'**
  String get shopItemCrystalFrameDesc;

  /// No description provided for @shopItemSkullFrameName.
  ///
  /// In es, this message translates to:
  /// **'Marco Calavera'**
  String get shopItemSkullFrameName;

  /// No description provided for @shopItemSkullFrameDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco de llama de calavera legendario'**
  String get shopItemSkullFrameDesc;

  /// No description provided for @shopItemTitleStormBreakerName.
  ///
  /// In es, this message translates to:
  /// **'Título: Rompetormentas'**
  String get shopItemTitleStormBreakerName;

  /// No description provided for @shopItemTitleStormBreakerDesc.
  ///
  /// In es, this message translates to:
  /// **'Título raro para tu perfil'**
  String get shopItemTitleStormBreakerDesc;

  /// No description provided for @shopItemTitleCyberSageName.
  ///
  /// In es, this message translates to:
  /// **'Título: Sabio Ciber'**
  String get shopItemTitleCyberSageName;

  /// No description provided for @shopItemTitleCyberSageDesc.
  ///
  /// In es, this message translates to:
  /// **'Título exclusivo para tu perfil'**
  String get shopItemTitleCyberSageDesc;

  /// No description provided for @shopItemTitleShadowHackerName.
  ///
  /// In es, this message translates to:
  /// **'Título: Hacker Sombrío'**
  String get shopItemTitleShadowHackerName;

  /// No description provided for @shopItemTitleShadowHackerDesc.
  ///
  /// In es, this message translates to:
  /// **'Título épico para tu perfil'**
  String get shopItemTitleShadowHackerDesc;

  /// No description provided for @shopItemTitleNightGuardianName.
  ///
  /// In es, this message translates to:
  /// **'Título: Guardián Nocturno'**
  String get shopItemTitleNightGuardianName;

  /// No description provided for @shopItemTitleNightGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Título exclusivo para tu perfil'**
  String get shopItemTitleNightGuardianDesc;

  /// No description provided for @shopItemTitleDigitalPhoenixName.
  ///
  /// In es, this message translates to:
  /// **'Título: Fénix Digital'**
  String get shopItemTitleDigitalPhoenixName;

  /// No description provided for @shopItemTitleDigitalPhoenixDesc.
  ///
  /// In es, this message translates to:
  /// **'Título legendario para tu perfil'**
  String get shopItemTitleDigitalPhoenixDesc;

  /// No description provided for @shopItemEffectDigitalRainName.
  ///
  /// In es, this message translates to:
  /// **'Efecto: Lluvia Digital'**
  String get shopItemEffectDigitalRainName;

  /// No description provided for @shopItemEffectDigitalRainDesc.
  ///
  /// In es, this message translates to:
  /// **'Efecto de lluvia Matrix animado'**
  String get shopItemEffectDigitalRainDesc;

  /// No description provided for @shopItemEffectFireTrailName.
  ///
  /// In es, this message translates to:
  /// **'Efecto: Estela de Fuego'**
  String get shopItemEffectFireTrailName;

  /// No description provided for @shopItemEffectFireTrailDesc.
  ///
  /// In es, this message translates to:
  /// **'Efecto de estela de fuego animado'**
  String get shopItemEffectFireTrailDesc;

  /// No description provided for @shopItemThemeBlueName.
  ///
  /// In es, this message translates to:
  /// **'Tema Azul Profundo'**
  String get shopItemThemeBlueName;

  /// No description provided for @shopItemThemeBlueDesc.
  ///
  /// In es, this message translates to:
  /// **'Apariencia azul premium'**
  String get shopItemThemeBlueDesc;

  /// No description provided for @shopItemThemePurpleName.
  ///
  /// In es, this message translates to:
  /// **'Tema Púrpura'**
  String get shopItemThemePurpleName;

  /// No description provided for @shopItemThemePurpleDesc.
  ///
  /// In es, this message translates to:
  /// **'Apariencia púrpura premium'**
  String get shopItemThemePurpleDesc;

  /// No description provided for @shopItemThemeDarkFireName.
  ///
  /// In es, this message translates to:
  /// **'Tema Fuego Oscuro'**
  String get shopItemThemeDarkFireName;

  /// No description provided for @shopItemThemeDarkFireDesc.
  ///
  /// In es, this message translates to:
  /// **'Tema de efectos de fuego oscuro'**
  String get shopItemThemeDarkFireDesc;

  /// No description provided for @shopItemThemeCyberNeonName.
  ///
  /// In es, this message translates to:
  /// **'Tema Neón Ciber'**
  String get shopItemThemeCyberNeonName;

  /// No description provided for @shopItemThemeCyberNeonDesc.
  ///
  /// In es, this message translates to:
  /// **'Tema neón futurista'**
  String get shopItemThemeCyberNeonDesc;

  /// No description provided for @mission3QueriesTitle.
  ///
  /// In es, this message translates to:
  /// **'3 Consultas'**
  String get mission3QueriesTitle;

  /// No description provided for @mission3QueriesDesc.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage 3 veces sobre diferentes temas.'**
  String get mission3QueriesDesc;

  /// No description provided for @missionConstantProtectorTitle.
  ///
  /// In es, this message translates to:
  /// **'Protector Constante'**
  String get missionConstantProtectorTitle;

  /// No description provided for @missionConstantProtectorDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 3 lecciones hoy.'**
  String get missionConstantProtectorDesc;

  /// Se muestra cuando el usuario alcanza el límite diario de mensajes de Sage.
  ///
  /// In es, this message translates to:
  /// **'Alcanzaste el límite diario de mensajes con Sage. Vuelve mañana.'**
  String get sageDailyLimitReached;

  /// Respuesta amable de Sage cuando hay problemas de conectividad.
  ///
  /// In es, this message translates to:
  /// **'Mi conexión mental está un poco débil ahora mismo, pero sigue practicando y pregúntame más tarde.'**
  String get sageConnectionWeak;

  /// No description provided for @gemHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de Gemas'**
  String get gemHistoryTitle;

  /// No description provided for @gemHistoryEmpty.
  ///
  /// In es, this message translates to:
  /// **'Sin transacciones aún'**
  String get gemHistoryEmpty;

  /// No description provided for @gemHistoryJustNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo'**
  String get gemHistoryJustNow;

  /// No description provided for @gemHistoryMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count}m'**
  String gemHistoryMinutesAgo(Object count);

  /// No description provided for @gemHistoryHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count}h'**
  String gemHistoryHoursAgo(Object count);

  /// No description provided for @gemHistoryYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get gemHistoryYesterday;

  /// No description provided for @gemHistoryDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {count}d'**
  String gemHistoryDaysAgo(Object count);

  /// No description provided for @gemReasonLesson.
  ///
  /// In es, this message translates to:
  /// **'Lección'**
  String get gemReasonLesson;

  /// No description provided for @gemReasonPerfectLesson.
  ///
  /// In es, this message translates to:
  /// **'Lección Perfecta'**
  String get gemReasonPerfectLesson;

  /// No description provided for @gemReasonFirstLesson.
  ///
  /// In es, this message translates to:
  /// **'Primera Lección del Día'**
  String get gemReasonFirstLesson;

  /// No description provided for @gemReasonDailyBonus.
  ///
  /// In es, this message translates to:
  /// **'Bono Diario'**
  String get gemReasonDailyBonus;

  /// No description provided for @gemReasonStreakMilestone.
  ///
  /// In es, this message translates to:
  /// **'Hito de Racha'**
  String get gemReasonStreakMilestone;

  /// No description provided for @gemReasonAchievement.
  ///
  /// In es, this message translates to:
  /// **'Logro'**
  String get gemReasonAchievement;

  /// No description provided for @gemReasonMission.
  ///
  /// In es, this message translates to:
  /// **'Misión'**
  String get gemReasonMission;

  /// No description provided for @gemReasonShop.
  ///
  /// In es, this message translates to:
  /// **'Compra en Tienda'**
  String get gemReasonShop;

  /// No description provided for @gemCapWarning.
  ///
  /// In es, this message translates to:
  /// **'¡El saldo de gemas se acerca al límite de 100,000!'**
  String get gemCapWarning;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @stop.
  ///
  /// In es, this message translates to:
  /// **'Detener'**
  String get stop;

  /// No description provided for @sageEmotionCalm.
  ///
  /// In es, this message translates to:
  /// **'Calmado'**
  String get sageEmotionCalm;

  /// No description provided for @sageEmotionHappy.
  ///
  /// In es, this message translates to:
  /// **'Feliz'**
  String get sageEmotionHappy;

  /// No description provided for @sageEmotionCurious.
  ///
  /// In es, this message translates to:
  /// **'Curioso'**
  String get sageEmotionCurious;

  /// No description provided for @sageEmotionThinking.
  ///
  /// In es, this message translates to:
  /// **'Pensando'**
  String get sageEmotionThinking;

  /// No description provided for @sageEmotionReading.
  ///
  /// In es, this message translates to:
  /// **'Leyendo'**
  String get sageEmotionReading;

  /// No description provided for @sageEmotionSerious.
  ///
  /// In es, this message translates to:
  /// **'Serio'**
  String get sageEmotionSerious;

  /// No description provided for @sageEmotionNeutral.
  ///
  /// In es, this message translates to:
  /// **'Neutro'**
  String get sageEmotionNeutral;

  /// No description provided for @sageEmotionExcited.
  ///
  /// In es, this message translates to:
  /// **'Emocionado'**
  String get sageEmotionExcited;

  /// No description provided for @sageEmotionConfused.
  ///
  /// In es, this message translates to:
  /// **'Confundido'**
  String get sageEmotionConfused;

  /// No description provided for @sageEmotionWorried.
  ///
  /// In es, this message translates to:
  /// **'Preocupado'**
  String get sageEmotionWorried;

  /// No description provided for @sageEmotionSadSoft.
  ///
  /// In es, this message translates to:
  /// **'Un poco triste'**
  String get sageEmotionSadSoft;

  /// No description provided for @sageEmotionSad.
  ///
  /// In es, this message translates to:
  /// **'Triste'**
  String get sageEmotionSad;

  /// No description provided for @sageEmotionCrying.
  ///
  /// In es, this message translates to:
  /// **'Llorando'**
  String get sageEmotionCrying;

  /// No description provided for @sageEmotionDepressed.
  ///
  /// In es, this message translates to:
  /// **'Deprimido'**
  String get sageEmotionDepressed;

  /// No description provided for @sageEmotionAngry.
  ///
  /// In es, this message translates to:
  /// **'Enojado'**
  String get sageEmotionAngry;

  /// No description provided for @sageEmotionFurious.
  ///
  /// In es, this message translates to:
  /// **'Furioso'**
  String get sageEmotionFurious;

  /// No description provided for @sageEmotionShocked.
  ///
  /// In es, this message translates to:
  /// **'Sorprendido'**
  String get sageEmotionShocked;

  /// No description provided for @sageEmotionSleepy.
  ///
  /// In es, this message translates to:
  /// **'Con sueño'**
  String get sageEmotionSleepy;

  /// No description provided for @sageEmotionWhistling.
  ///
  /// In es, this message translates to:
  /// **'Silbando'**
  String get sageEmotionWhistling;

  /// No description provided for @sageEmotionPointLeft.
  ///
  /// In es, this message translates to:
  /// **'Señalando a la izquierda'**
  String get sageEmotionPointLeft;

  /// No description provided for @sageEmotionPointRight.
  ///
  /// In es, this message translates to:
  /// **'Señalando a la derecha'**
  String get sageEmotionPointRight;

  /// No description provided for @sageEmotionWink.
  ///
  /// In es, this message translates to:
  /// **'Guiñando el ojo'**
  String get sageEmotionWink;

  /// No description provided for @sageEmotionShy.
  ///
  /// In es, this message translates to:
  /// **'Tímido'**
  String get sageEmotionShy;

  /// No description provided for @sageEmotionLaughing.
  ///
  /// In es, this message translates to:
  /// **'Riendo'**
  String get sageEmotionLaughing;

  /// No description provided for @sageEmotionSinging.
  ///
  /// In es, this message translates to:
  /// **'Cantando'**
  String get sageEmotionSinging;

  /// No description provided for @sageEmotionScared.
  ///
  /// In es, this message translates to:
  /// **'Asustado'**
  String get sageEmotionScared;

  /// No description provided for @sageEmotionEmbarrassed.
  ///
  /// In es, this message translates to:
  /// **'Apenado'**
  String get sageEmotionEmbarrassed;

  /// No description provided for @sageEmotionAnnoyed.
  ///
  /// In es, this message translates to:
  /// **'Molesto'**
  String get sageEmotionAnnoyed;

  /// No description provided for @sageEmotionUnmotivated.
  ///
  /// In es, this message translates to:
  /// **'Desmotivado'**
  String get sageEmotionUnmotivated;

  /// No description provided for @sageEmotionDistressed.
  ///
  /// In es, this message translates to:
  /// **'Angustiado'**
  String get sageEmotionDistressed;

  /// No description provided for @sageEmotionAggressive.
  ///
  /// In es, this message translates to:
  /// **'Agresivo'**
  String get sageEmotionAggressive;

  /// No description provided for @sageEmotionLol.
  ///
  /// In es, this message translates to:
  /// **'Jajaja'**
  String get sageEmotionLol;

  /// No description provided for @sageEmotionHappyWings.
  ///
  /// In es, this message translates to:
  /// **'Feliz con alas'**
  String get sageEmotionHappyWings;

  /// No description provided for @sageEmotionExcitedWave.
  ///
  /// In es, this message translates to:
  /// **'Emocionado saludando'**
  String get sageEmotionExcitedWave;

  /// No description provided for @sageEmotionSurprisedWings.
  ///
  /// In es, this message translates to:
  /// **'Sorprendido con alas'**
  String get sageEmotionSurprisedWings;

  /// No description provided for @sageEmotionCelebrating.
  ///
  /// In es, this message translates to:
  /// **'Celebrando'**
  String get sageEmotionCelebrating;

  /// No description provided for @sageEmotionProud.
  ///
  /// In es, this message translates to:
  /// **'Orgulloso'**
  String get sageEmotionProud;

  /// No description provided for @sageEmotionPanic.
  ///
  /// In es, this message translates to:
  /// **'En pánico'**
  String get sageEmotionPanic;

  /// No description provided for @chatSuggestionHelpLesson.
  ///
  /// In es, this message translates to:
  /// **'Ayúdame con una lección'**
  String get chatSuggestionHelpLesson;

  /// No description provided for @chatSuggestionExplainConcept.
  ///
  /// In es, this message translates to:
  /// **'Explícame un concepto'**
  String get chatSuggestionExplainConcept;

  /// No description provided for @chatSuggestionQuizMe.
  ///
  /// In es, this message translates to:
  /// **'Ponme a prueba con vocabulario'**
  String get chatSuggestionQuizMe;

  /// No description provided for @copiedToClipboard.
  ///
  /// In es, this message translates to:
  /// **'Copiado al portapapeles'**
  String get copiedToClipboard;

  /// No description provided for @messageFromYou.
  ///
  /// In es, this message translates to:
  /// **'Tú'**
  String get messageFromYou;

  /// No description provided for @messageFromSage.
  ///
  /// In es, this message translates to:
  /// **'Sage'**
  String get messageFromSage;

  /// No description provided for @gemRewardEarned.
  ///
  /// In es, this message translates to:
  /// **'+{count} gemas obtenidas'**
  String gemRewardEarned(Object count);

  /// No description provided for @defaultStudentName.
  ///
  /// In es, this message translates to:
  /// **'Estudiante'**
  String get defaultStudentName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
