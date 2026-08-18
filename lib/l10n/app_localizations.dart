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

  /// No description provided for @aboutSage.
  ///
  /// In es, this message translates to:
  /// **'Sobre Sage'**
  String get aboutSage;

  /// No description provided for @aboutSection.
  ///
  /// In es, this message translates to:
  /// **'Acerca de'**
  String get aboutSection;

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

  /// No description provided for @adminCreditDonationA11y.
  ///
  /// In es, this message translates to:
  /// **'Acreditar Donaciones'**
  String get adminCreditDonationA11y;

  /// No description provided for @adminCreditDonationButton.
  ///
  /// In es, this message translates to:
  /// **'Acreditar Donaciones'**
  String get adminCreditDonationButton;

  /// No description provided for @adminCreditDonationSuccess.
  ///
  /// In es, this message translates to:
  /// **'{gems} donaciones acreditadas a {userId}'**
  String adminCreditDonationSuccess(Object gems, Object userId);

  /// No description provided for @adminCreditDonationTitle.
  ///
  /// In es, this message translates to:
  /// **'Admin — Acreditar Donaciones'**
  String get adminCreditDonationTitle;

  /// No description provided for @adminCreditError.
  ///
  /// In es, this message translates to:
  /// **'Error al acreditar. Verifica que tu usuario esté en la colección \"admins\" de Firestore.'**
  String get adminCreditError;

  /// No description provided for @adminCreditSuccessNotification.
  ///
  /// In es, this message translates to:
  /// **'{gems} donaciones acreditadas a {userId}'**
  String adminCreditSuccessNotification(Object gems, Object userId);

  /// No description provided for @adminDonations.
  ///
  /// In es, this message translates to:
  /// **'Donaciones'**
  String get adminDonations;

  /// No description provided for @adminFieldAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get adminFieldAmount;

  /// No description provided for @adminFieldDonationAmount.
  ///
  /// In es, this message translates to:
  /// **'Monto de donación'**
  String get adminFieldDonationAmount;

  /// No description provided for @adminFieldUserId.
  ///
  /// In es, this message translates to:
  /// **'User ID'**
  String get adminFieldUserId;

  /// No description provided for @adminInvalidInput.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un User ID válido y monto'**
  String get adminInvalidInput;

  /// No description provided for @adminMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago'**
  String get adminMercadoPago;

  /// No description provided for @adminPaymentMethod.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get adminPaymentMethod;

  /// No description provided for @adminTitle.
  ///
  /// In es, this message translates to:
  /// **'Admin — Donaciones de Crédito'**
  String get adminTitle;

  /// No description provided for @adminUserId.
  ///
  /// In es, this message translates to:
  /// **'ID de usuario'**
  String get adminUserId;

  /// No description provided for @adminVerifyingPermissions.
  ///
  /// In es, this message translates to:
  /// **'Verificando permisos de administrador…'**
  String get adminVerifyingPermissions;

  /// No description provided for @adminWhatsapp.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp / Yape / Plin'**
  String get adminWhatsapp;

  /// No description provided for @analyzeFile.
  ///
  /// In es, this message translates to:
  /// **'Analizar archivo'**
  String get analyzeFile;

  /// No description provided for @analyzeLink.
  ///
  /// In es, this message translates to:
  /// **'Analizar enlace'**
  String get analyzeLink;

  /// No description provided for @analyzing.
  ///
  /// In es, this message translates to:
  /// **'Analizando...'**
  String get analyzing;

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'SAGEN'**
  String get appName;

  /// No description provided for @appSlogan.
  ///
  /// In es, this message translates to:
  /// **'Tu escudo digital'**
  String get appSlogan;

  /// No description provided for @authAge.
  ///
  /// In es, this message translates to:
  /// **'Edad'**
  String get authAge;

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

  /// No description provided for @authConfirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get authConfirmPassword;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authCreateAccountError.
  ///
  /// In es, this message translates to:
  /// **'Error al crear cuenta'**
  String get authCreateAccountError;

  /// No description provided for @authCredentialExpired.
  ///
  /// In es, this message translates to:
  /// **'La sesión ha expirado. Por favor, inicia sesión de nuevo.'**
  String get authCredentialExpired;

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

  /// No description provided for @authEmailVerificationSent.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu correo para verificar tu cuenta'**
  String get authEmailVerificationSent;

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

  /// No description provided for @authFullName.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get authFullName;

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

  /// No description provided for @authHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get authHaveAccount;

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

  /// No description provided for @authLoginLink.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authLoginLink;

  /// No description provided for @authLoginTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus datos'**
  String get authLoginTitle;

  /// No description provided for @authNameError.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre'**
  String get authNameError;

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

  /// No description provided for @authNotFoundCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get authNotFoundCancel;

  /// No description provided for @authNotFoundCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authNotFoundCreate;

  /// No description provided for @authNotFoundMessage.
  ///
  /// In es, this message translates to:
  /// **'No hay una cuenta registrada con {email}. ¿Desea crear una nueva cuenta y empezar a aprender?'**
  String authNotFoundMessage(Object email);

  /// No description provided for @authNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuenta no encontrada'**
  String get authNotFoundTitle;

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

  /// No description provided for @authOrRegisterWith.
  ///
  /// In es, this message translates to:
  /// **'o regístrate con'**
  String get authOrRegisterWith;

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

  /// No description provided for @authPasswordMinHint.
  ///
  /// In es, this message translates to:
  /// **'Contraseña (8+ chars, A-Z, a-z, 0-9)'**
  String get authPasswordMinHint;

  /// No description provided for @authPasswordsDoNotMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get authPasswordsDoNotMatch;

  /// No description provided for @authPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Tu información está protegida.'**
  String get authPrivacy;

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

  /// No description provided for @authRegisterFacebookError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse con Facebook'**
  String get authRegisterFacebookError;

  /// No description provided for @authRegisterGoogleError.
  ///
  /// In es, this message translates to:
  /// **'Error al registrarse con Google'**
  String get authRegisterGoogleError;

  /// No description provided for @authRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authRegisterTitle;

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

  /// No description provided for @authSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aprende, protégete y navega internet de forma más segura.'**
  String get authSubtitle;

  /// No description provided for @authTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu protección digital comienza aquí'**
  String get authTitle;

  /// No description provided for @authTokenExpired.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada. Por favor, inicia sesión de nuevo.'**
  String get authTokenExpired;

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

  /// No description provided for @biometricPrompt.
  ///
  /// In es, this message translates to:
  /// **'Desbloquea SAGEN para continuar'**
  String get biometricPrompt;

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

  /// No description provided for @careerCertifications.
  ///
  /// In es, this message translates to:
  /// **'Certificaciones'**
  String get careerCertifications;

  /// No description provided for @careerDescription.
  ///
  /// In es, this message translates to:
  /// **'Obtén certificaciones y desarrolla habilidades que te hacen valioso en la economía digital.'**
  String get careerDescription;

  /// No description provided for @careerOpp1.
  ///
  /// In es, this message translates to:
  /// **'Consultor de Seguridad Digital'**
  String get careerOpp1;

  /// No description provided for @careerOpp1Desc.
  ///
  /// In es, this message translates to:
  /// **'Ayuda a las empresas a proteger sus datos'**
  String get careerOpp1Desc;

  /// No description provided for @careerOpp2.
  ///
  /// In es, this message translates to:
  /// **'Capacitador de Concienciación'**
  String get careerOpp2;

  /// No description provided for @careerOpp2Desc.
  ///
  /// In es, this message translates to:
  /// **'Enseña a otros a estar seguros en línea'**
  String get careerOpp2Desc;

  /// No description provided for @careerOpp3.
  ///
  /// In es, this message translates to:
  /// **'Auditor de seguridad freelance'**
  String get careerOpp3;

  /// No description provided for @careerOpp3Desc.
  ///
  /// In es, this message translates to:
  /// **'Ofrece auditorías de seguridad a clientes'**
  String get careerOpp3Desc;

  /// No description provided for @careerOpportunities.
  ///
  /// In es, this message translates to:
  /// **'Oportunidades económicas'**
  String get careerOpportunities;

  /// No description provided for @careerSkill1.
  ///
  /// In es, this message translates to:
  /// **'Seguridad de contraseñas'**
  String get careerSkill1;

  /// No description provided for @careerSkill2.
  ///
  /// In es, this message translates to:
  /// **'Detección de Phishing'**
  String get careerSkill2;

  /// No description provided for @careerSkill3.
  ///
  /// In es, this message translates to:
  /// **'Protección de Privacidad'**
  String get careerSkill3;

  /// No description provided for @careerSkill4.
  ///
  /// In es, this message translates to:
  /// **'Seguridad de Red'**
  String get careerSkill4;

  /// No description provided for @careerSkill5.
  ///
  /// In es, this message translates to:
  /// **'Respuesta a Incidentes'**
  String get careerSkill5;

  /// No description provided for @careerSkills.
  ///
  /// In es, this message translates to:
  /// **'Habilidades que desarrollarás'**
  String get careerSkills;

  /// No description provided for @careerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu trayectoria profesional en ciberseguridad'**
  String get careerSubtitle;

  /// No description provided for @careerTitle.
  ///
  /// In es, this message translates to:
  /// **'Carrera y Certificaciones'**
  String get careerTitle;

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

  /// No description provided for @challengeSafe.
  ///
  /// In es, this message translates to:
  /// **'Seguro'**
  String get challengeSafe;

  /// No description provided for @challengeSuspicious.
  ///
  /// In es, this message translates to:
  /// **'Sospechoso'**
  String get challengeSuspicious;

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

  /// No description provided for @challenge_analyze_link_desc.
  ///
  /// In es, this message translates to:
  /// **'Analiza {count} enlace(s)'**
  String challenge_analyze_link_desc(Object count);

  /// No description provided for @challenge_analyze_link_title.
  ///
  /// In es, this message translates to:
  /// **'Analizar Enlaces'**
  String get challenge_analyze_link_title;

  /// No description provided for @challenge_answer_questions_desc.
  ///
  /// In es, this message translates to:
  /// **'Responde {count} pregunta(s)'**
  String challenge_answer_questions_desc(Object count);

  /// No description provided for @challenge_answer_questions_title.
  ///
  /// In es, this message translates to:
  /// **'Responder Preguntas'**
  String get challenge_answer_questions_title;

  /// No description provided for @challenge_check_in_desc.
  ///
  /// In es, this message translates to:
  /// **'Regístrate {count} vez(veces)'**
  String challenge_check_in_desc(Object count);

  /// No description provided for @challenge_check_in_title.
  ///
  /// In es, this message translates to:
  /// **'Registro Diario'**
  String get challenge_check_in_title;

  /// No description provided for @challenge_complete_lesson_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa {count} lección(es)'**
  String challenge_complete_lesson_desc(Object count);

  /// No description provided for @challenge_complete_lesson_title.
  ///
  /// In es, this message translates to:
  /// **'Completar Lecciones'**
  String get challenge_complete_lesson_title;

  /// No description provided for @challenge_complete_session_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa {count} sesión(es)'**
  String challenge_complete_session_desc(Object count);

  /// No description provided for @challenge_complete_session_title.
  ///
  /// In es, this message translates to:
  /// **'Sesiones de Aprendizaje'**
  String get challenge_complete_session_title;

  /// No description provided for @challenge_complete_stage_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa 1 etapa'**
  String get challenge_complete_stage_desc;

  /// No description provided for @challenge_complete_stage_title.
  ///
  /// In es, this message translates to:
  /// **'Completar Etapa'**
  String get challenge_complete_stage_title;

  /// No description provided for @challenge_correct_streak_desc.
  ///
  /// In es, this message translates to:
  /// **'Obtén {count} respuestas correctas seguidas'**
  String challenge_correct_streak_desc(Object count);

  /// No description provided for @challenge_correct_streak_title.
  ///
  /// In es, this message translates to:
  /// **'Racha Correcta'**
  String get challenge_correct_streak_title;

  /// No description provided for @challenge_detect_phishing_desc.
  ///
  /// In es, this message translates to:
  /// **'Detecta {count} intento(s) de phishing'**
  String challenge_detect_phishing_desc(Object count);

  /// No description provided for @challenge_detect_phishing_title.
  ///
  /// In es, this message translates to:
  /// **'Detectar Phishing'**
  String get challenge_detect_phishing_title;

  /// No description provided for @challenge_earn_xp_desc.
  ///
  /// In es, this message translates to:
  /// **'Gana {xp} XP'**
  String challenge_earn_xp_desc(Object xp);

  /// No description provided for @challenge_earn_xp_title.
  ///
  /// In es, this message translates to:
  /// **'Ganar XP'**
  String get challenge_earn_xp_title;

  /// No description provided for @challenge_learn_minutes_desc.
  ///
  /// In es, this message translates to:
  /// **'Aprende durante {count} minutos'**
  String challenge_learn_minutes_desc(Object count);

  /// No description provided for @challenge_learn_minutes_title.
  ///
  /// In es, this message translates to:
  /// **'Tiempo de Aprendizaje'**
  String get challenge_learn_minutes_title;

  /// No description provided for @challenge_learn_topic_desc.
  ///
  /// In es, this message translates to:
  /// **'Aprende {count} tema(s)'**
  String challenge_learn_topic_desc(Object count);

  /// No description provided for @challenge_learn_topic_title.
  ///
  /// In es, this message translates to:
  /// **'Aprender un Tema'**
  String get challenge_learn_topic_title;

  /// No description provided for @challenge_perfect_lesson_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección sin errores'**
  String get challenge_perfect_lesson_desc;

  /// No description provided for @challenge_perfect_lesson_title.
  ///
  /// In es, this message translates to:
  /// **'Lección Perfecta'**
  String get challenge_perfect_lesson_title;

  /// No description provided for @challenge_privacy_check_desc.
  ///
  /// In es, this message translates to:
  /// **'Revisa ajustes de privacidad {count} vez(veces)'**
  String challenge_privacy_check_desc(Object count);

  /// No description provided for @challenge_privacy_check_title.
  ///
  /// In es, this message translates to:
  /// **'Verificación de Privacidad'**
  String get challenge_privacy_check_title;

  /// No description provided for @challenge_quiz_night_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa {count} mini quiz'**
  String challenge_quiz_night_desc(Object count);

  /// No description provided for @challenge_quiz_night_title.
  ///
  /// In es, this message translates to:
  /// **'Mini Quiz'**
  String get challenge_quiz_night_title;

  /// No description provided for @challenge_review_tips_desc.
  ///
  /// In es, this message translates to:
  /// **'Revisa {count} consejo(s) de seguridad'**
  String challenge_review_tips_desc(Object count);

  /// No description provided for @challenge_review_tips_title.
  ///
  /// In es, this message translates to:
  /// **'Revisar Consejos'**
  String get challenge_review_tips_title;

  /// No description provided for @challenge_security_audit_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa {count} auditoría(s)'**
  String challenge_security_audit_desc(Object count);

  /// No description provided for @challenge_security_audit_title.
  ///
  /// In es, this message translates to:
  /// **'Auditoría de Seguridad'**
  String get challenge_security_audit_title;

  /// No description provided for @challenge_share_knowledge_desc.
  ///
  /// In es, this message translates to:
  /// **'Comparte {count} consejo(s)'**
  String challenge_share_knowledge_desc(Object count);

  /// No description provided for @challenge_share_knowledge_title.
  ///
  /// In es, this message translates to:
  /// **'Compartir Conocimiento'**
  String get challenge_share_knowledge_title;

  /// No description provided for @challenge_social_awareness_desc.
  ///
  /// In es, this message translates to:
  /// **'Completa {count} desafío(s) de conciencia social'**
  String challenge_social_awareness_desc(Object count);

  /// No description provided for @challenge_social_awareness_title.
  ///
  /// In es, this message translates to:
  /// **'Conciencia Social'**
  String get challenge_social_awareness_title;

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

  /// No description provided for @challenge_talk_sage_desc.
  ///
  /// In es, this message translates to:
  /// **'Charla con Sage {count} vez(veces)'**
  String challenge_talk_sage_desc(Object count);

  /// No description provided for @challenge_talk_sage_title.
  ///
  /// In es, this message translates to:
  /// **'Charla con Sage'**
  String get challenge_talk_sage_title;

  /// No description provided for @challenge_test_password_desc.
  ///
  /// In es, this message translates to:
  /// **'Prueba {count} contraseña(s)'**
  String challenge_test_password_desc(Object count);

  /// No description provided for @challenge_test_password_title.
  ///
  /// In es, this message translates to:
  /// **'Probar Contraseñas'**
  String get challenge_test_password_title;

  /// No description provided for @challenge_use_dark_mode_desc.
  ///
  /// In es, this message translates to:
  /// **'Usar modo oscuro'**
  String get challenge_use_dark_mode_desc;

  /// No description provided for @challenge_use_dark_mode_title.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get challenge_use_dark_mode_title;

  /// No description provided for @changelogV4.
  ///
  /// In es, this message translates to:
  /// **'Fundamentos'**
  String get changelogV4;

  /// No description provided for @changelogV4_1.
  ///
  /// In es, this message translates to:
  /// **'8 etapas de aprendizaje con 1,099 lecciones'**
  String get changelogV4_1;

  /// No description provided for @changelogV4_2.
  ///
  /// In es, this message translates to:
  /// **'Rachas diarias y desafíos'**
  String get changelogV4_2;

  /// No description provided for @changelogV4_3.
  ///
  /// In es, this message translates to:
  /// **'Sistema de logros'**
  String get changelogV4_3;

  /// No description provided for @changelogV5.
  ///
  /// In es, this message translates to:
  /// **'IA y Personalización'**
  String get changelogV5;

  /// No description provided for @changelogV5Old.
  ///
  /// In es, this message translates to:
  /// **'Sistema de Cofres y Gacha'**
  String get changelogV5Old;

  /// No description provided for @changelogV5Old_1.
  ///
  /// In es, this message translates to:
  /// **'Sistema de evolución de cofres (Bronce → Legendaria)'**
  String get changelogV5Old_1;

  /// No description provided for @changelogV5Old_2.
  ///
  /// In es, this message translates to:
  /// **'Botones 3D interactivos'**
  String get changelogV5Old_2;

  /// No description provided for @changelogV5Old_3.
  ///
  /// In es, this message translates to:
  /// **'Rediseño de interfaz con Glassmorphism'**
  String get changelogV5Old_3;

  /// No description provided for @changelogV5_1.
  ///
  /// In es, this message translates to:
  /// **'Chat de SAGE con IA para ayuda personalizada'**
  String get changelogV5_1;

  /// No description provided for @changelogV5_2.
  ///
  /// In es, this message translates to:
  /// **'Máscaras dinámicas de emociones'**
  String get changelogV5_2;

  /// No description provided for @changelogV5_3.
  ///
  /// In es, this message translates to:
  /// **'17,157 preguntas de ciberseguridad'**
  String get changelogV5_3;

  /// No description provided for @changelogV5_4.
  ///
  /// In es, this message translates to:
  /// **'Sociedad VIP para rachas de 30+ días'**
  String get changelogV5_4;

  /// No description provided for @chatAskSage.
  ///
  /// In es, this message translates to:
  /// **'Pregúntale a Sage'**
  String get chatAskSage;

  /// No description provided for @chatAskSageDesc.
  ///
  /// In es, this message translates to:
  /// **'Haz una pregunta de ciberseguridad o elige una sugerencia rápida.'**
  String get chatAskSageDesc;

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

  /// No description provided for @chatClear.
  ///
  /// In es, this message translates to:
  /// **'Limpiar'**
  String get chatClear;

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

  /// No description provided for @chatFallback.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo no pude responder. Intenta de nuevo.'**
  String get chatFallback;

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

  /// No description provided for @chatGuideDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu guía de ciberseguridad'**
  String get chatGuideDesc;

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

  /// No description provided for @chatNewConversation.
  ///
  /// In es, this message translates to:
  /// **'Nueva conversación'**
  String get chatNewConversation;

  /// No description provided for @chatSageTutor.
  ///
  /// In es, this message translates to:
  /// **'Tutor Sage'**
  String get chatSageTutor;

  /// No description provided for @chatSageTutorLabel.
  ///
  /// In es, this message translates to:
  /// **'Tutor Sage'**
  String get chatSageTutorLabel;

  /// No description provided for @checkInDesc.
  ///
  /// In es, this message translates to:
  /// **'Check-in diario para mantener tu racha activa'**
  String get checkInDesc;

  /// No description provided for @checkInTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro diario'**
  String get checkInTitle;

  /// No description provided for @chestCollect.
  ///
  /// In es, this message translates to:
  /// **'Recoger'**
  String get chestCollect;

  /// No description provided for @chestEvolvedTo.
  ///
  /// In es, this message translates to:
  /// **'Evolucionó a {type}'**
  String chestEvolvedTo(Object type);

  /// No description provided for @chestNoChange.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios'**
  String get chestNoChange;

  /// No description provided for @chestOpenedTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Cofre {type}!'**
  String chestOpenedTitle(Object type);

  /// No description provided for @chestPityProgress.
  ///
  /// In es, this message translates to:
  /// **'Legendario en'**
  String get chestPityProgress;

  /// No description provided for @chestReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de cofres'**
  String get chestReminder;

  /// No description provided for @chestReminderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recibe recordatorios para abrir tu cofre diario'**
  String get chestReminderSubtitle;

  /// No description provided for @chestRewardBronze.
  ///
  /// In es, this message translates to:
  /// **'¡Bronce!'**
  String get chestRewardBronze;

  /// No description provided for @chestRewardDefault.
  ///
  /// In es, this message translates to:
  /// **'Recompensa'**
  String get chestRewardDefault;

  /// No description provided for @chestRewardDialog.
  ///
  /// In es, this message translates to:
  /// **'Diálogo de recompensa del cofre'**
  String get chestRewardDialog;

  /// No description provided for @chestRewardGold.
  ///
  /// In es, this message translates to:
  /// **'¡Oro!'**
  String get chestRewardGold;

  /// No description provided for @chestRewardLegendary.
  ///
  /// In es, this message translates to:
  /// **'¡Legendario!'**
  String get chestRewardLegendary;

  /// No description provided for @chestRewardSilver.
  ///
  /// In es, this message translates to:
  /// **'¡Plata!'**
  String get chestRewardSilver;

  /// No description provided for @chestTapToOpen.
  ///
  /// In es, this message translates to:
  /// **'Toca para abrir'**
  String get chestTapToOpen;

  /// No description provided for @chestTapToUpgrade.
  ///
  /// In es, this message translates to:
  /// **'Toca para mejorar'**
  String get chestTapToUpgrade;

  /// No description provided for @chestTitle.
  ///
  /// In es, this message translates to:
  /// **'Cofre {type}'**
  String chestTitle(Object type);

  /// No description provided for @chestTreasure.
  ///
  /// In es, this message translates to:
  /// **'Cofre del tesoro {type}'**
  String chestTreasure(Object type);

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

  /// No description provided for @chestXpBoost.
  ///
  /// In es, this message translates to:
  /// **'x2 EXP'**
  String get chestXpBoost;

  /// No description provided for @closeButton.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get closeButton;

  /// No description provided for @cloudDataDeleted.
  ///
  /// In es, this message translates to:
  /// **'Datos cloud eliminados'**
  String get cloudDataDeleted;

  /// No description provided for @cloudSync.
  ///
  /// In es, this message translates to:
  /// **'Cloud y sincronización'**
  String get cloudSync;

  /// No description provided for @commit1Month.
  ///
  /// In es, this message translates to:
  /// **'1 mes'**
  String get commit1Month;

  /// No description provided for @commit1Week.
  ///
  /// In es, this message translates to:
  /// **'1 semana'**
  String get commit1Week;

  /// No description provided for @commit2Weeks.
  ///
  /// In es, this message translates to:
  /// **'2 semanas'**
  String get commit2Weeks;

  /// No description provided for @commitButton.
  ///
  /// In es, this message translates to:
  /// **'COMPROMETERME CON MI META'**
  String get commitButton;

  /// No description provided for @commitChooseGoal.
  ///
  /// In es, this message translates to:
  /// **'Elige tu meta'**
  String get commitChooseGoal;

  /// No description provided for @commitChooseGoalDesc.
  ///
  /// In es, this message translates to:
  /// **'Selecciona cuántos días seguirás tu plan de aprendizaje.'**
  String get commitChooseGoalDesc;

  /// No description provided for @commitDays.
  ///
  /// In es, this message translates to:
  /// **'{days} días'**
  String commitDays(Object days);

  /// No description provided for @commitGoalLabel.
  ///
  /// In es, this message translates to:
  /// **'Tu meta: {days} días'**
  String commitGoalLabel(Object days);

  /// No description provided for @commitSelected.
  ///
  /// In es, this message translates to:
  /// **'SELECCIONADO'**
  String get commitSelected;

  /// No description provided for @commitYourGoal.
  ///
  /// In es, this message translates to:
  /// **'Tu meta: {days} días'**
  String commitYourGoal(Object days);

  /// No description provided for @completePrevious.
  ///
  /// In es, this message translates to:
  /// **'Completa la etapa anterior'**
  String get completePrevious;

  /// No description provided for @connectionErrorRetry.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Intenta de nuevo.'**
  String get connectionErrorRetry;

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

  /// No description provided for @cyberQuizProgress.
  ///
  /// In es, this message translates to:
  /// **'Pregunta {current} de {total}'**
  String cyberQuizProgress(Object current, Object total);

  /// No description provided for @dailyGoalIntense.
  ///
  /// In es, this message translates to:
  /// **'Intenso'**
  String get dailyGoalIntense;

  /// No description provided for @dailyGoalMinutesPerDay.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min/día'**
  String dailyGoalMinutesPerDay(Object minutes);

  /// No description provided for @dailyGoalNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get dailyGoalNormal;

  /// No description provided for @dailyGoalQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu meta de aprendizaje diario?'**
  String get dailyGoalQuestion;

  /// No description provided for @dailyGoalRelaxed.
  ///
  /// In es, this message translates to:
  /// **'Relajado'**
  String get dailyGoalRelaxed;

  /// No description provided for @dailyGoalSerious.
  ///
  /// In es, this message translates to:
  /// **'Serio'**
  String get dailyGoalSerious;

  /// No description provided for @dailyMissions.
  ///
  /// In es, this message translates to:
  /// **'Misiones diarias'**
  String get dailyMissions;

  /// No description provided for @dailyMissionsAllCompleted.
  ///
  /// In es, this message translates to:
  /// **'Todos los desafíos completados hoy'**
  String get dailyMissionsAllCompleted;

  /// No description provided for @dailyMissionsDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa tus misiones para obtener recompensas'**
  String get dailyMissionsDesc;

  /// No description provided for @darkModeEnd.
  ///
  /// In es, this message translates to:
  /// **'Termina modo oscuro'**
  String get darkModeEnd;

  /// No description provided for @darkModeScheduleInfo.
  ///
  /// In es, this message translates to:
  /// **'El modo oscuro estará activo de {start}:00 a {end}:00'**
  String darkModeScheduleInfo(Object end, Object start);

  /// No description provided for @darkModeStart.
  ///
  /// In es, this message translates to:
  /// **'Inicia modo oscuro'**
  String get darkModeStart;

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

  /// No description provided for @dayShortFri.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get dayShortFri;

  /// No description provided for @dayShortMon.
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get dayShortMon;

  /// Accessible label for a completed day in the weekly calendar.
  ///
  /// In es, this message translates to:
  /// **'{day}, completado'**
  String weekDayCompleted(Object day);

  /// Accessible label for today in the weekly calendar.
  ///
  /// In es, this message translates to:
  /// **'Hoy, {day}'**
  String weekDayToday(Object day);

  /// No description provided for @dayShortSat.
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get dayShortSat;

  /// No description provided for @dayShortSun.
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get dayShortSun;

  /// No description provided for @dayShortThu.
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get dayShortThu;

  /// No description provided for @dayShortTue.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get dayShortTue;

  /// No description provided for @dayShortWed.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get dayShortWed;

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

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'Eliminar mi cuenta'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountDesc.
  ///
  /// In es, this message translates to:
  /// **'Esto eliminará permanentemente todos tus datos. Esta acción no se puede deshacer.'**
  String get deleteAccountDesc;

  /// No description provided for @deleteAccountReauthRequired.
  ///
  /// In es, this message translates to:
  /// **'Autenticación reciente requerida para eliminar la cuenta'**
  String get deleteAccountReauthRequired;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAction.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get deleteAction;

  /// No description provided for @deleteCloudData.
  ///
  /// In es, this message translates to:
  /// **'Eliminar datos cloud'**
  String get deleteCloudData;

  /// No description provided for @deleteCloudDesc.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Esta acción eliminará permanentemente tu progreso guardado en la nube. Los datos locales no se verán afectados.'**
  String get deleteCloudDesc;

  /// No description provided for @deleteCloudTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar datos cloud'**
  String get deleteCloudTitle;

  /// No description provided for @deleteHistory.
  ///
  /// In es, this message translates to:
  /// **'Borrar historial de análisis'**
  String get deleteHistory;

  /// No description provided for @deleteHistoryDesc.
  ///
  /// In es, this message translates to:
  /// **'Se eliminarán todos los análisis de enlaces guardados. Esta acción no se puede deshacer.'**
  String get deleteHistoryDesc;

  /// No description provided for @deleteHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Borrar historial'**
  String get deleteHistoryTitle;

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

  /// No description provided for @developedWith.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado con Flutter'**
  String get developedWith;

  /// No description provided for @donateToSupport.
  ///
  /// In es, this message translates to:
  /// **'Donar para apoyar'**
  String get donateToSupport;

  /// No description provided for @donationBasic.
  ///
  /// In es, this message translates to:
  /// **'Supporter'**
  String get donationBasic;

  /// No description provided for @donationBasicDesc.
  ///
  /// In es, this message translates to:
  /// **'Ayúdanos a mantener SAGEN gratis'**
  String get donationBasicDesc;

  /// No description provided for @donationLabel.
  ///
  /// In es, this message translates to:
  /// **'Donación'**
  String get donationLabel;

  /// No description provided for @donationPopular.
  ///
  /// In es, this message translates to:
  /// **'Super Supporter'**
  String get donationPopular;

  /// No description provided for @donationPopularDesc.
  ///
  /// In es, this message translates to:
  /// **'Badge exclusivo + agradecimiento especial'**
  String get donationPopularDesc;

  /// No description provided for @donationPremium.
  ///
  /// In es, this message translates to:
  /// **'Campeón'**
  String get donationPremium;

  /// No description provided for @donationPremiumDesc.
  ///
  /// In es, this message translates to:
  /// **'Todos los beneficios + tu nombre en créditos'**
  String get donationPremiumDesc;

  /// No description provided for @donationValueLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get donationValueLabel;

  /// No description provided for @dot.
  ///
  /// In es, this message translates to:
  /// **'Punto {number}'**
  String dot(Object number);

  /// No description provided for @ecoCo2Saved.
  ///
  /// In es, this message translates to:
  /// **'Emisiones de CO₂ evitadas'**
  String get ecoCo2Saved;

  /// No description provided for @ecoComparison.
  ///
  /// In es, this message translates to:
  /// **'SAGEN usa 99% menos recursos que la educación tradicional'**
  String get ecoComparison;

  /// No description provided for @ecoDescription.
  ///
  /// In es, this message translates to:
  /// **'Cada lección que completas ahorra agua, reduce las emisiones de CO₂ y elimina el uso de papel.'**
  String get ecoDescription;

  /// No description provided for @ecoDigital.
  ///
  /// In es, this message translates to:
  /// **'📱 Digital: solo tu teléfono'**
  String get ecoDigital;

  /// No description provided for @ecoDigitalLearning.
  ///
  /// In es, this message translates to:
  /// **'Aprendizaje 100% Digital'**
  String get ecoDigitalLearning;

  /// No description provided for @ecoDigitalLearningDesc.
  ///
  /// In es, this message translates to:
  /// **'Sin papel, sin impresión, sin transporte necesario'**
  String get ecoDigitalLearningDesc;

  /// No description provided for @ecoHowItWorks.
  ///
  /// In es, this message translates to:
  /// **'Digital vs Tradicional'**
  String get ecoHowItWorks;

  /// No description provided for @ecoLiters.
  ///
  /// In es, this message translates to:
  /// **'litros'**
  String get ecoLiters;

  /// No description provided for @ecoPages.
  ///
  /// In es, this message translates to:
  /// **'páginas'**
  String get ecoPages;

  /// No description provided for @ecoPaperSaved.
  ///
  /// In es, this message translates to:
  /// **'Papel ahorrado'**
  String get ecoPaperSaved;

  /// No description provided for @ecoSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aprende mientras cuidas el planeta'**
  String get ecoSubtitle;

  /// No description provided for @ecoTitle.
  ///
  /// In es, this message translates to:
  /// **'Impacto Ambiental'**
  String get ecoTitle;

  /// No description provided for @ecoTraditional.
  ///
  /// In es, this message translates to:
  /// **'📚 Tradicional: papel, tinta, transporte'**
  String get ecoTraditional;

  /// No description provided for @ecoTrees.
  ///
  /// In es, this message translates to:
  /// **'árboles'**
  String get ecoTrees;

  /// No description provided for @ecoTreesEquivalent.
  ///
  /// In es, this message translates to:
  /// **'Equivalente en árboles'**
  String get ecoTreesEquivalent;

  /// No description provided for @ecoWaterSaved.
  ///
  /// In es, this message translates to:
  /// **'Agua ahorrada'**
  String get ecoWaterSaved;

  /// No description provided for @ecoYourImpact.
  ///
  /// In es, this message translates to:
  /// **'Tu impacto ambiental'**
  String get ecoYourImpact;

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

  /// No description provided for @emotionalPhrase1.
  ///
  /// In es, this message translates to:
  /// **'Detectas riesgos más rápido ahora.'**
  String get emotionalPhrase1;

  /// No description provided for @emotionalPhrase2.
  ///
  /// In es, this message translates to:
  /// **'Tu hábito digital está mejorando.'**
  String get emotionalPhrase2;

  /// No description provided for @emotionalPhrase3.
  ///
  /// In es, this message translates to:
  /// **'Cada día entiendes mejor cómo protegerte.'**
  String get emotionalPhrase3;

  /// No description provided for @emotionalPhrase4.
  ///
  /// In es, this message translates to:
  /// **'Estás construyendo un instinto de seguridad.'**
  String get emotionalPhrase4;

  /// No description provided for @emotionalPhrase5.
  ///
  /// In es, this message translates to:
  /// **'Tu juicio digital se está afilando.'**
  String get emotionalPhrase5;

  /// No description provided for @emotionalPhrase6.
  ///
  /// In es, this message translates to:
  /// **'Estás aprendiendo a ver lo que otros no ven.'**
  String get emotionalPhrase6;

  /// No description provided for @emotionalPhrase7.
  ///
  /// In es, this message translates to:
  /// **'Tu mundo digital es más seguro por ti.'**
  String get emotionalPhrase7;

  /// No description provided for @emotionalPhraseStart.
  ///
  /// In es, this message translates to:
  /// **'Tu viaje digital comienza hoy.'**
  String get emotionalPhraseStart;

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

  /// No description provided for @emptyUpdates.
  ///
  /// In es, this message translates to:
  /// **'No hay actualizaciones disponibles'**
  String get emptyUpdates;

  /// No description provided for @english.
  ///
  /// In es, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @errorContentLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.'**
  String get errorContentLoadFailed;

  /// No description provided for @errorFeedback.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar comentario. Intenta de nuevo.'**
  String get errorFeedback;

  /// No description provided for @errorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Por favor, intenta de nuevo.'**
  String get errorGeneric;

  /// No description provided for @errorIntegrityCheck.
  ///
  /// In es, this message translates to:
  /// **'Se detectó un problema de integridad. Tu progreso se ha guardado, pero por favor verifica que sea correcto.'**
  String get errorIntegrityCheck;

  /// No description provided for @errorLoadContent.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el contenido. Verifica tu conexión e intenta de nuevo.'**
  String get errorLoadContent;

  /// No description provided for @errorLoadProgress.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu progreso. Revisa tu conexión e intenta de nuevo.'**
  String get errorLoadProgress;

  /// No description provided for @errorLoadQuestions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar preguntas. Intenta de nuevo.'**
  String get errorLoadQuestions;

  /// No description provided for @errorNetwork.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet. Revisa tu red.'**
  String get errorNetwork;

  /// No description provided for @errorPayment.
  ///
  /// In es, this message translates to:
  /// **'Error al registrar el pago. Por favor, intenta de nuevo.'**
  String get errorPayment;

  /// No description provided for @errorProgressLoadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar tu progreso. Verifica tu conexión e intenta de nuevo.'**
  String get errorProgressLoadFailed;

  /// No description provided for @errorProgressReloadFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos recargar tu progreso. Intenta de nuevo.'**
  String get errorProgressReloadFailed;

  /// No description provided for @errorReloadProgress.
  ///
  /// In es, this message translates to:
  /// **'No pudimos recargar tu progreso. Intenta de nuevo.'**
  String get errorReloadProgress;

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

  /// No description provided for @errorShare.
  ///
  /// In es, this message translates to:
  /// **'Error al compartir. Por favor, intenta de nuevo.'**
  String get errorShare;

  /// No description provided for @errorSomethingWrong.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get errorSomethingWrong;

  /// No description provided for @errorStreak.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar la racha.'**
  String get errorStreak;

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

  /// No description provided for @experience.
  ///
  /// In es, this message translates to:
  /// **'Experiencia'**
  String get experience;

  /// No description provided for @exportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar mis datos'**
  String get exportData;

  /// No description provided for @exportDataCopied.
  ///
  /// In es, this message translates to:
  /// **'¡Datos copiados al portapapeles!'**
  String get exportDataCopied;

  /// No description provided for @exportDataCopy.
  ///
  /// In es, this message translates to:
  /// **'Copiar al portapapeles'**
  String get exportDataCopy;

  /// No description provided for @exportDataDesc.
  ///
  /// In es, this message translates to:
  /// **'Descarga una copia de tus datos personales'**
  String get exportDataDesc;

  /// No description provided for @exportDataLoading.
  ///
  /// In es, this message translates to:
  /// **'Recopilando tus datos...'**
  String get exportDataLoading;

  /// No description provided for @feedbackCatBug.
  ///
  /// In es, this message translates to:
  /// **'Reportar un error'**
  String get feedbackCatBug;

  /// No description provided for @feedbackCatContent.
  ///
  /// In es, this message translates to:
  /// **'Contenido'**
  String get feedbackCatContent;

  /// No description provided for @feedbackCatDesign.
  ///
  /// In es, this message translates to:
  /// **'Diseño'**
  String get feedbackCatDesign;

  /// No description provided for @feedbackCatFeature.
  ///
  /// In es, this message translates to:
  /// **'Sugerir una función'**
  String get feedbackCatFeature;

  /// No description provided for @feedbackCatGeneral.
  ///
  /// In es, this message translates to:
  /// **'General'**
  String get feedbackCatGeneral;

  /// No description provided for @feedbackCategory.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get feedbackCategory;

  /// No description provided for @feedbackChangelog.
  ///
  /// In es, this message translates to:
  /// **'Novedades'**
  String get feedbackChangelog;

  /// No description provided for @feedbackComments.
  ///
  /// In es, this message translates to:
  /// **'Comentarios'**
  String get feedbackComments;

  /// No description provided for @feedbackConfusing.
  ///
  /// In es, this message translates to:
  /// **'Confundido'**
  String get feedbackConfusing;

  /// No description provided for @feedbackContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get feedbackContinue;

  /// No description provided for @feedbackExcellent.
  ///
  /// In es, this message translates to:
  /// **'¡Eres increíble!'**
  String get feedbackExcellent;

  /// No description provided for @feedbackGood.
  ///
  /// In es, this message translates to:
  /// **'Bueno'**
  String get feedbackGood;

  /// No description provided for @feedbackHard.
  ///
  /// In es, this message translates to:
  /// **'Difícil'**
  String get feedbackHard;

  /// No description provided for @feedbackHint.
  ///
  /// In es, this message translates to:
  /// **'Cuéntanos qué piensas...'**
  String get feedbackHint;

  /// No description provided for @feedbackHowDidYouFeel.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te sentiste?'**
  String get feedbackHowDidYouFeel;

  /// No description provided for @feedbackPerfect.
  ///
  /// In es, this message translates to:
  /// **'Perfecto'**
  String get feedbackPerfect;

  /// No description provided for @feedbackPoor.
  ///
  /// In es, this message translates to:
  /// **'Mejoraremos'**
  String get feedbackPoor;

  /// No description provided for @feedbackRateExperience.
  ///
  /// In es, this message translates to:
  /// **'Califica tu experiencia'**
  String get feedbackRateExperience;

  /// No description provided for @feedbackSubmit.
  ///
  /// In es, this message translates to:
  /// **'Enviar comentarios'**
  String get feedbackSubmit;

  /// No description provided for @feedbackTapStars.
  ///
  /// In es, this message translates to:
  /// **'Toca una estrella para calificar'**
  String get feedbackTapStars;

  /// No description provided for @feedbackThanks.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias!'**
  String get feedbackThanks;

  /// No description provided for @feedbackThanksDesc.
  ///
  /// In es, this message translates to:
  /// **'Tus comentarios nos ayudan a mejorar SAGEN para todos.'**
  String get feedbackThanksDesc;

  /// No description provided for @feedbackTitle.
  ///
  /// In es, this message translates to:
  /// **'Comentarios y Historial de Cambios'**
  String get feedbackTitle;

  /// No description provided for @fileAnalyzer.
  ///
  /// In es, this message translates to:
  /// **'Analizar archivo'**
  String get fileAnalyzer;

  /// No description provided for @fileDangerous.
  ///
  /// In es, this message translates to:
  /// **'Peligroso'**
  String get fileDangerous;

  /// No description provided for @fileHighRisk.
  ///
  /// In es, this message translates to:
  /// **'Alto riesgo'**
  String get fileHighRisk;

  /// No description provided for @fileLowRisk.
  ///
  /// In es, this message translates to:
  /// **'Bajo riesgo'**
  String get fileLowRisk;

  /// No description provided for @fileMediumRisk.
  ///
  /// In es, this message translates to:
  /// **'Riesgo medio'**
  String get fileMediumRisk;

  /// No description provided for @fileSafe.
  ///
  /// In es, this message translates to:
  /// **'Seguro'**
  String get fileSafe;

  /// No description provided for @finishText.
  ///
  /// In es, this message translates to:
  /// **'Finalizar'**
  String get finishText;

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

  /// No description provided for @forceSync.
  ///
  /// In es, this message translates to:
  /// **'Forzar sincronización'**
  String get forceSync;

  /// No description provided for @free.
  ///
  /// In es, this message translates to:
  /// **'Gratis'**
  String get free;

  /// No description provided for @french.
  ///
  /// In es, this message translates to:
  /// **'Francés'**
  String get french;

  /// No description provided for @gachaChestTap.
  ///
  /// In es, this message translates to:
  /// **'Cofre de gacha. Toca para mejorar.'**
  String get gachaChestTap;

  /// No description provided for @gachaOrbFail.
  ///
  /// In es, this message translates to:
  /// **'Sin cambios'**
  String get gachaOrbFail;

  /// No description provided for @gachaOrbSuccess.
  ///
  /// In es, this message translates to:
  /// **'Mejora exitosa'**
  String get gachaOrbSuccess;

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

  /// No description provided for @habitMsg1.
  ///
  /// In es, this message translates to:
  /// **'¡Gran trabajo! Ahora vamos a fortalecer tu disciplina diaria.'**
  String get habitMsg1;

  /// No description provided for @habitMsg2.
  ///
  /// In es, this message translates to:
  /// **'Primer paso listo. Vamos a construir el hábito que te llevará a tu meta.'**
  String get habitMsg2;

  /// No description provided for @habitMsg3.
  ///
  /// In es, this message translates to:
  /// **'Excelente rendimiento. El secreto ahora es la constancia.'**
  String get habitMsg3;

  /// No description provided for @habitMsg4.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho! Ahora configuremos el ritmo de tu progreso diario.'**
  String get habitMsg4;

  /// No description provided for @habitMsg5.
  ///
  /// In es, this message translates to:
  /// **'Un comienzo perfecto. Aseguremos tu éxito construyendo un hábito inquebrantable.'**
  String get habitMsg5;

  /// No description provided for @habitTransition1.
  ///
  /// In es, this message translates to:
  /// **'Construyendo tu hábito diario...'**
  String get habitTransition1;

  /// No description provided for @habitTransition2.
  ///
  /// In es, this message translates to:
  /// **'La constancia es la clave'**
  String get habitTransition2;

  /// No description provided for @habitTransition3.
  ///
  /// In es, this message translates to:
  /// **'Estás progresando'**
  String get habitTransition3;

  /// No description provided for @habitTransition4.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así!'**
  String get habitTransition4;

  /// No description provided for @habitTransition5.
  ///
  /// In es, this message translates to:
  /// **'¡Ya casi!'**
  String get habitTransition5;

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

  /// No description provided for @heatmapLess.
  ///
  /// In es, this message translates to:
  /// **'Menos'**
  String get heatmapLess;

  /// No description provided for @heatmapLessons.
  ///
  /// In es, this message translates to:
  /// **'{count} lecciones'**
  String heatmapLessons(Object count);

  /// No description provided for @heatmapMore.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get heatmapMore;

  /// No description provided for @heatmapTitle.
  ///
  /// In es, this message translates to:
  /// **'Actividad reciente'**
  String get heatmapTitle;

  /// No description provided for @hidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get hidePassword;

  /// No description provided for @historyDeleted.
  ///
  /// In es, this message translates to:
  /// **'Historial eliminado'**
  String get historyDeleted;

  /// No description provided for @historyTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTitle;

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

  /// No description provided for @homeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tu escudo digital está activo'**
  String get homeTitle;

  /// No description provided for @homeViewAchievements.
  ///
  /// In es, this message translates to:
  /// **'Ver logros'**
  String get homeViewAchievements;

  /// No description provided for @howItWorks.
  ///
  /// In es, this message translates to:
  /// **'Cómo funciona SAGEN'**
  String get howItWorks;

  /// No description provided for @impactAch.
  ///
  /// In es, this message translates to:
  /// **'Logros'**
  String get impactAch;

  /// No description provided for @impactActiveUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios activos'**
  String get impactActiveUsers;

  /// No description provided for @impactCommunity.
  ///
  /// In es, this message translates to:
  /// **'Impacto Comunitario'**
  String get impactCommunity;

  /// No description provided for @impactCountriesReached.
  ///
  /// In es, this message translates to:
  /// **'Países alcanzados'**
  String get impactCountriesReached;

  /// No description provided for @impactDonations.
  ///
  /// In es, this message translates to:
  /// **'Total Donado'**
  String get impactDonations;

  /// No description provided for @impactHoursLearned.
  ///
  /// In es, this message translates to:
  /// **'Horas aprendidas'**
  String get impactHoursLearned;

  /// No description provided for @impactKnowledgeLevel.
  ///
  /// In es, this message translates to:
  /// **'Conocimiento en ciberseguridad'**
  String get impactKnowledgeLevel;

  /// No description provided for @impactLearningJourney.
  ///
  /// In es, this message translates to:
  /// **'Tu Viaje de Aprendizaje'**
  String get impactLearningJourney;

  /// No description provided for @impactLessons.
  ///
  /// In es, this message translates to:
  /// **'Lecciones completadas'**
  String get impactLessons;

  /// No description provided for @impactLevelActiveLearner.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz activo'**
  String get impactLevelActiveLearner;

  /// No description provided for @impactLevelAwareUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario consciente'**
  String get impactLevelAwareUser;

  /// No description provided for @impactLevelBeginner.
  ///
  /// In es, this message translates to:
  /// **'Principiante'**
  String get impactLevelBeginner;

  /// No description provided for @impactLevelCybersecurityExpert.
  ///
  /// In es, this message translates to:
  /// **'Experto en Ciberseguridad'**
  String get impactLevelCybersecurityExpert;

  /// No description provided for @impactLevelDigitalGuardian.
  ///
  /// In es, this message translates to:
  /// **'Guardián Digital'**
  String get impactLevelDigitalGuardian;

  /// No description provided for @impactProgressToNext.
  ///
  /// In es, this message translates to:
  /// **'{count} lecciones para el siguiente nivel'**
  String impactProgressToNext(Object count);

  /// No description provided for @impactProtectedUsers.
  ///
  /// In es, this message translates to:
  /// **'Usuarios protegidos'**
  String get impactProtectedUsers;

  /// No description provided for @impactQuestionsAnswered.
  ///
  /// In es, this message translates to:
  /// **'Preguntas respondidas'**
  String get impactQuestionsAnswered;

  /// No description provided for @impactStreak.
  ///
  /// In es, this message translates to:
  /// **'Racha actual'**
  String get impactStreak;

  /// No description provided for @impactTestimonial.
  ///
  /// In es, this message translates to:
  /// **'Lo que dicen los usuarios'**
  String get impactTestimonial;

  /// No description provided for @impactTestimonial1.
  ///
  /// In es, this message translates to:
  /// **'SAGEN me ayudó a proteger a mi familia del phishing. ¡Las lecciones interactivas son increíbles!'**
  String get impactTestimonial1;

  /// No description provided for @impactTestimonial2.
  ///
  /// In es, this message translates to:
  /// **'Pasé de no saber nada de ciberseguridad a ayudar a mis colegas a mantenerse seguros en línea.'**
  String get impactTestimonial2;

  /// No description provided for @impactTestimonial3.
  ///
  /// In es, this message translates to:
  /// **'La gamificación hace que aprender sea divertido. ¡Completé 30 lecciones en solo 2 semanas!'**
  String get impactTestimonial3;

  /// No description provided for @impactTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Impacto'**
  String get impactTitle;

  /// No description provided for @impactTotalLessons.
  ///
  /// In es, this message translates to:
  /// **'Lecciones completadas'**
  String get impactTotalLessons;

  /// No description provided for @impactXp.
  ///
  /// In es, this message translates to:
  /// **'XP obtenidos'**
  String get impactXp;

  /// No description provided for @impactYourLevel.
  ///
  /// In es, this message translates to:
  /// **'TU NIVEL'**
  String get impactYourLevel;

  /// No description provided for @impactYourStats.
  ///
  /// In es, this message translates to:
  /// **'Tus estadísticas'**
  String get impactYourStats;

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

  /// No description provided for @infoSection.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoSection;

  /// No description provided for @initialAction.
  ///
  /// In es, this message translates to:
  /// **'Comienza aquí'**
  String get initialAction;

  /// No description provided for @inventoryFocusElixir.
  ///
  /// In es, this message translates to:
  /// **'Elixir de Foco'**
  String get inventoryFocusElixir;

  /// No description provided for @inventoryFocusElixirActivated.
  ///
  /// In es, this message translates to:
  /// **'Elixir de enfoque activado — x2 por 15 min'**
  String get inventoryFocusElixirActivated;

  /// No description provided for @inventoryFocusElixirDesc.
  ///
  /// In es, this message translates to:
  /// **'Multiplica EXP x2 durante 15 min'**
  String get inventoryFocusElixirDesc;

  /// No description provided for @inventoryMonocleAvailable.
  ///
  /// In es, this message translates to:
  /// **'Monocle de Sage disponible para el siguiente desafío'**
  String get inventoryMonocleAvailable;

  /// No description provided for @inventoryPhoenixFeather.
  ///
  /// In es, this message translates to:
  /// **'Pluma de Fénix'**
  String get inventoryPhoenixFeather;

  /// No description provided for @inventoryPhoenixFeatherDesc.
  ///
  /// In es, this message translates to:
  /// **'Revive tu racha si la perdiste hace menos de 24h'**
  String get inventoryPhoenixFeatherDesc;

  /// No description provided for @inventoryPhoenixFeatherRestored.
  ///
  /// In es, this message translates to:
  /// **'Pluma de Fénix: racha restaurada'**
  String get inventoryPhoenixFeatherRestored;

  /// No description provided for @inventorySagesMonocle.
  ///
  /// In es, this message translates to:
  /// **'Monóculo del Sabio'**
  String get inventorySagesMonocle;

  /// No description provided for @inventorySagesMonocleDesc.
  ///
  /// In es, this message translates to:
  /// **'Elimina 2 respuestas incorrectas en un reto'**
  String get inventorySagesMonocleDesc;

  /// No description provided for @inventoryShieldProtected.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Titanio: racha protegida'**
  String get inventoryShieldProtected;

  /// No description provided for @inventoryTitaniumShield.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Titanio'**
  String get inventoryTitaniumShield;

  /// No description provided for @inventoryTitaniumShieldDesc.
  ///
  /// In es, this message translates to:
  /// **'Protege tu racha automáticamente si faltas un día'**
  String get inventoryTitaniumShieldDesc;

  /// No description provided for @inventoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get inventoryTitle;

  /// No description provided for @inventoryUse.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get inventoryUse;

  /// No description provided for @languageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get languageTitle;

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

  /// No description provided for @learnSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lecciones interactivas de seguridad digital'**
  String get learnSubtitle;

  /// No description provided for @learnTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprender'**
  String get learnTitle;

  /// No description provided for @learningPath.
  ///
  /// In es, this message translates to:
  /// **'Tu camino de aprendizaje'**
  String get learningPath;

  /// No description provided for @legalAnd.
  ///
  /// In es, this message translates to:
  /// **' y '**
  String get legalAnd;

  /// No description provided for @legalPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Acepto la política de privacidad'**
  String get legalPrivacy;

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

  /// No description provided for @lessonNoQuestions.
  ///
  /// In es, this message translates to:
  /// **'No hay preguntas disponibles para esta lección'**
  String get lessonNoQuestions;

  /// No description provided for @lessonNoQuestionsHint.
  ///
  /// In es, this message translates to:
  /// **'¡Sage también tiene curiosidad! Vuelve pronto.'**
  String get lessonNoQuestionsHint;

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

  /// No description provided for @lessonsCompletedPlural.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{# lección completada} other{# lecciones completadas}}'**
  String lessonsCompletedPlural(num count);

  /// No description provided for @lessonsCount.
  ///
  /// In es, this message translates to:
  /// **'{count} lecciones'**
  String lessonsCount(Object count);

  /// No description provided for @lessonsLevel.
  ///
  /// In es, this message translates to:
  /// **'Nivel {level}'**
  String lessonsLevel(Object level);

  /// No description provided for @lessonsNoAvailable.
  ///
  /// In es, this message translates to:
  /// **'No hay lecciones disponibles. Vuelve pronto.'**
  String get lessonsNoAvailable;

  /// No description provided for @lessonsYourPath.
  ///
  /// In es, this message translates to:
  /// **'Tu ruta de aprendizaje'**
  String get lessonsYourPath;

  /// No description provided for @levelAssessment0.
  ///
  /// In es, this message translates to:
  /// **'Principiante absoluto'**
  String get levelAssessment0;

  /// No description provided for @levelAssessment1.
  ///
  /// In es, this message translates to:
  /// **'Principiante'**
  String get levelAssessment1;

  /// No description provided for @levelAssessment2.
  ///
  /// In es, this message translates to:
  /// **'Intermedio'**
  String get levelAssessment2;

  /// No description provided for @levelAssessment3.
  ///
  /// In es, this message translates to:
  /// **'Avanzado'**
  String get levelAssessment3;

  /// No description provided for @levelAssessment4.
  ///
  /// In es, this message translates to:
  /// **'Experto'**
  String get levelAssessment4;

  /// No description provided for @levelAssessmentQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu nivel actual en ciberseguridad?'**
  String get levelAssessmentQuestion;

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

  /// No description provided for @madeWithLove.
  ///
  /// In es, this message translates to:
  /// **'Hecho con ♥ para estudiantes'**
  String get madeWithLove;

  /// No description provided for @miniGameBackupDef.
  ///
  /// In es, this message translates to:
  /// **'Copia de seguridad'**
  String get miniGameBackupDef;

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

  /// No description provided for @minutesPerDay.
  ///
  /// In es, this message translates to:
  /// **'{count} minutos por día'**
  String minutesPerDay(Object count);

  /// No description provided for @missionActiveLearnerDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 1 lección de seguridad.'**
  String get missionActiveLearnerDesc;

  /// No description provided for @missionActiveLearnerTitle.
  ///
  /// In es, this message translates to:
  /// **'Aprendiz activo'**
  String get missionActiveLearnerTitle;

  /// No description provided for @missionActiveStreakDesc.
  ///
  /// In es, this message translates to:
  /// **'Mantén tu racha de aprendizaje hoy.'**
  String get missionActiveStreakDesc;

  /// No description provided for @missionActiveStreakTitle.
  ///
  /// In es, this message translates to:
  /// **'Racha activa'**
  String get missionActiveStreakTitle;

  /// No description provided for @missionChatWithSageDesc.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage sobre seguridad digital.'**
  String get missionChatWithSageDesc;

  /// No description provided for @missionChatWithSageTitle.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage'**
  String get missionChatWithSageTitle;

  /// No description provided for @missionConsistentProtectorDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 3 lecciones hoy.'**
  String get missionConsistentProtectorDesc;

  /// No description provided for @missionConsistentProtectorTitle.
  ///
  /// In es, this message translates to:
  /// **'Protector constante'**
  String get missionConsistentProtectorTitle;

  /// No description provided for @missionDigitalDetectiveDesc.
  ///
  /// In es, this message translates to:
  /// **'Analiza un enlace sospechoso.'**
  String get missionDigitalDetectiveDesc;

  /// No description provided for @missionDigitalDetectiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Detective digital'**
  String get missionDigitalDetectiveTitle;

  /// No description provided for @missionExpressChallengeDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa un desafío rápido de 30 segundos.'**
  String get missionExpressChallengeDesc;

  /// No description provided for @missionExpressChallengeTitle.
  ///
  /// In es, this message translates to:
  /// **'Desafío express'**
  String get missionExpressChallengeTitle;

  /// No description provided for @missionPerfectLessonDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa una lección sin errores.'**
  String get missionPerfectLessonDesc;

  /// No description provided for @missionPerfectLessonTitle.
  ///
  /// In es, this message translates to:
  /// **'Lección perfecta'**
  String get missionPerfectLessonTitle;

  /// No description provided for @missionPhishingHunterDesc.
  ///
  /// In es, this message translates to:
  /// **'Detecta correctamente un intento de phishing.'**
  String get missionPhishingHunterDesc;

  /// No description provided for @missionPhishingHunterTitle.
  ///
  /// In es, this message translates to:
  /// **'Cazador de phishing'**
  String get missionPhishingHunterTitle;

  /// No description provided for @missionProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso de misión: {percent} por ciento'**
  String missionProgress(Object percent);

  /// No description provided for @missionThreeQueriesDesc.
  ///
  /// In es, this message translates to:
  /// **'Habla con Sage 3 veces sobre diferentes temas.'**
  String get missionThreeQueriesDesc;

  /// No description provided for @missionThreeQueriesTitle.
  ///
  /// In es, this message translates to:
  /// **'3 consultas'**
  String get missionThreeQueriesTitle;

  /// No description provided for @monthApr.
  ///
  /// In es, this message translates to:
  /// **'Abr'**
  String get monthApr;

  /// No description provided for @monthApril.
  ///
  /// In es, this message translates to:
  /// **'Abril'**
  String get monthApril;

  /// No description provided for @monthAug.
  ///
  /// In es, this message translates to:
  /// **'Ago'**
  String get monthAug;

  /// No description provided for @monthAugust.
  ///
  /// In es, this message translates to:
  /// **'Agosto'**
  String get monthAugust;

  /// No description provided for @monthDec.
  ///
  /// In es, this message translates to:
  /// **'Dic'**
  String get monthDec;

  /// No description provided for @monthDecember.
  ///
  /// In es, this message translates to:
  /// **'Diciembre'**
  String get monthDecember;

  /// No description provided for @monthFeb.
  ///
  /// In es, this message translates to:
  /// **'Feb'**
  String get monthFeb;

  /// No description provided for @monthFebruary.
  ///
  /// In es, this message translates to:
  /// **'Febrero'**
  String get monthFebruary;

  /// No description provided for @monthJan.
  ///
  /// In es, this message translates to:
  /// **'Ene'**
  String get monthJan;

  /// No description provided for @monthJanuary.
  ///
  /// In es, this message translates to:
  /// **'Enero'**
  String get monthJanuary;

  /// No description provided for @monthJul.
  ///
  /// In es, this message translates to:
  /// **'Jul'**
  String get monthJul;

  /// No description provided for @monthJuly.
  ///
  /// In es, this message translates to:
  /// **'Julio'**
  String get monthJuly;

  /// No description provided for @monthJun.
  ///
  /// In es, this message translates to:
  /// **'Jun'**
  String get monthJun;

  /// No description provided for @monthJune.
  ///
  /// In es, this message translates to:
  /// **'Junio'**
  String get monthJune;

  /// No description provided for @monthMar.
  ///
  /// In es, this message translates to:
  /// **'Mar'**
  String get monthMar;

  /// No description provided for @monthMarch.
  ///
  /// In es, this message translates to:
  /// **'Marzo'**
  String get monthMarch;

  /// No description provided for @monthMay.
  ///
  /// In es, this message translates to:
  /// **'Mayo'**
  String get monthMay;

  /// No description provided for @monthNov.
  ///
  /// In es, this message translates to:
  /// **'Nov'**
  String get monthNov;

  /// No description provided for @monthNovember.
  ///
  /// In es, this message translates to:
  /// **'Noviembre'**
  String get monthNovember;

  /// No description provided for @monthOct.
  ///
  /// In es, this message translates to:
  /// **'Oct'**
  String get monthOct;

  /// No description provided for @monthOctober.
  ///
  /// In es, this message translates to:
  /// **'Octubre'**
  String get monthOctober;

  /// No description provided for @monthSep.
  ///
  /// In es, this message translates to:
  /// **'Sep'**
  String get monthSep;

  /// No description provided for @monthSeptember.
  ///
  /// In es, this message translates to:
  /// **'Septiembre'**
  String get monthSeptember;

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

  /// No description provided for @myAccount.
  ///
  /// In es, this message translates to:
  /// **'Mi cuenta'**
  String get myAccount;

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

  /// No description provided for @never.
  ///
  /// In es, this message translates to:
  /// **'Nunca'**
  String get never;

  /// No description provided for @newBadge.
  ///
  /// In es, this message translates to:
  /// **'NUEVO'**
  String get newBadge;

  /// No description provided for @newsUpdates.
  ///
  /// In es, this message translates to:
  /// **'Novedades y actualizaciones'**
  String get newsUpdates;

  /// No description provided for @nextText.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get nextText;

  /// No description provided for @noConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet.'**
  String get noConnection;

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

  /// No description provided for @notificationReminder.
  ///
  /// In es, this message translates to:
  /// **'Cinco minutos hoy pueden ayudarte mañana.'**
  String get notificationReminder;

  /// No description provided for @notificationStreakAlive.
  ///
  /// In es, this message translates to:
  /// **'Tu racha sigue viva'**
  String get notificationStreakAlive;

  /// No description provided for @notificationStreakLoss.
  ///
  /// In es, this message translates to:
  /// **'Nunca es tarde para empezar otra vez.'**
  String get notificationStreakLoss;

  /// No description provided for @notificationTip.
  ///
  /// In es, this message translates to:
  /// **'Tu escudo digital te espera.'**
  String get notificationTip;

  /// No description provided for @notificationsTitle.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get notificationsTitle;

  /// No description provided for @offlineAction.
  ///
  /// In es, this message translates to:
  /// **'Conéctate e inténtalo nuevamente.'**
  String get offlineAction;

  /// No description provided for @offlineMessage.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet.'**
  String get offlineMessage;

  /// No description provided for @offlineNoConnection.
  ///
  /// In es, this message translates to:
  /// **'Sin conexión a internet'**
  String get offlineNoConnection;

  /// No description provided for @offlineSavedForLater.
  ///
  /// In es, this message translates to:
  /// **'Guardado sin conexión. Sincronizaremos pronto.'**
  String get offlineSavedForLater;

  /// No description provided for @offlineSyncComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Sincronización completada!'**
  String get offlineSyncComplete;

  /// No description provided for @onbDiagnosisMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Genial! Ajustaremos tu plan de entrenamiento para proteger tu conocimiento desde el primer día.'**
  String get onbDiagnosisMsg;

  /// No description provided for @onbGoalCommit.
  ///
  /// In es, this message translates to:
  /// **'MANTENTE COMPROMETIDO'**
  String get onbGoalCommit;

  /// No description provided for @onbGoalIntense.
  ///
  /// In es, this message translates to:
  /// **'Intenso'**
  String get onbGoalIntense;

  /// No description provided for @onbGoalMinPerDay.
  ///
  /// In es, this message translates to:
  /// **'{minutes} min/día'**
  String onbGoalMinPerDay(Object minutes);

  /// No description provided for @onbGoalNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get onbGoalNormal;

  /// No description provided for @onbGoalRelaxed.
  ///
  /// In es, this message translates to:
  /// **'Relajado'**
  String get onbGoalRelaxed;

  /// No description provided for @onbGoalSerious.
  ///
  /// In es, this message translates to:
  /// **'Serio'**
  String get onbGoalSerious;

  /// No description provided for @onbGoalTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu meta de aprendizaje diario?'**
  String get onbGoalTitle;

  /// No description provided for @onbLevel0.
  ///
  /// In es, this message translates to:
  /// **'Cero absoluto (no sé qué es el phishing...)'**
  String get onbLevel0;

  /// No description provided for @onbLevel1.
  ///
  /// In es, this message translates to:
  /// **'Sé lo básico...'**
  String get onbLevel1;

  /// No description provided for @onbLevel2.
  ///
  /// In es, this message translates to:
  /// **'Nivel intermedio...'**
  String get onbLevel2;

  /// No description provided for @onbLevel3.
  ///
  /// In es, this message translates to:
  /// **'Nivel avanzado...'**
  String get onbLevel3;

  /// No description provided for @onbLevel4.
  ///
  /// In es, this message translates to:
  /// **'Experto en ciberseguridad...'**
  String get onbLevel4;

  /// No description provided for @onbLevelContinue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get onbLevelContinue;

  /// No description provided for @onbLevelQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu nivel actual en ciberseguridad?'**
  String get onbLevelQuestion;

  /// No description provided for @onbLevelTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cuál es tu nivel actual en ciberseguridad?'**
  String get onbLevelTitle;

  /// No description provided for @onbMotivationCareer.
  ///
  /// In es, this message translates to:
  /// **'Carrera profesional'**
  String get onbMotivationCareer;

  /// No description provided for @onbMotivationCareerMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Grandes razones para aprender!'**
  String get onbMotivationCareerMsg;

  /// No description provided for @onbMotivationConnect.
  ///
  /// In es, this message translates to:
  /// **'Conecta con personas'**
  String get onbMotivationConnect;

  /// No description provided for @onbMotivationConnectMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos a conectarte!'**
  String get onbMotivationConnectMsg;

  /// No description provided for @onbMotivationFun.
  ///
  /// In es, this message translates to:
  /// **'Diviértete'**
  String get onbMotivationFun;

  /// No description provided for @onbMotivationFunMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Me encanta! Divertirme es mi especialidad.'**
  String get onbMotivationFunMsg;

  /// No description provided for @onbMotivationMind.
  ///
  /// In es, this message translates to:
  /// **'Entrenar mi mente'**
  String get onbMotivationMind;

  /// No description provided for @onbMotivationMindMsg.
  ///
  /// In es, this message translates to:
  /// **'Es una decisión sabia.'**
  String get onbMotivationMindMsg;

  /// No description provided for @onbMotivationOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get onbMotivationOther;

  /// No description provided for @onbMotivationOtherMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Entendido! Cuéntame más por el camino.'**
  String get onbMotivationOtherMsg;

  /// No description provided for @onbMotivationStudies.
  ///
  /// In es, this message translates to:
  /// **'Estudios'**
  String get onbMotivationStudies;

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

  /// No description provided for @onbMotivationTravel.
  ///
  /// In es, this message translates to:
  /// **'Viajar'**
  String get onbMotivationTravel;

  /// No description provided for @onbMotivationTravelMsg.
  ///
  /// In es, this message translates to:
  /// **'¡Nada supera viajar con tus dispositivos 100% protegidos!'**
  String get onbMotivationTravelMsg;

  /// No description provided for @onbNotifActivate.
  ///
  /// In es, this message translates to:
  /// **'ACTIVAR NOTIFICACIONES'**
  String get onbNotifActivate;

  /// No description provided for @onbNotifDesc.
  ///
  /// In es, this message translates to:
  /// **'Activa las notificaciones para no perderte tu racha, los recordatorios diarios y los desafíos importantes.'**
  String get onbNotifDesc;

  /// No description provided for @onbNotifSkip.
  ///
  /// In es, this message translates to:
  /// **'Ahora no'**
  String get onbNotifSkip;

  /// No description provided for @onbNotifTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Recibir notificaciones?'**
  String get onbNotifTitle;

  /// No description provided for @onbProjHackerMind.
  ///
  /// In es, this message translates to:
  /// **'Forja una mentalidad de hacker'**
  String get onbProjHackerMind;

  /// No description provided for @onbProjHackerMindDesc.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios estratégicos, desafíos diarios y tácticas de defensa digital.'**
  String get onbProjHackerMindDesc;

  /// No description provided for @onbProjLockAccounts.
  ///
  /// In es, this message translates to:
  /// **'Asegura tus cuentas'**
  String get onbProjLockAccounts;

  /// No description provided for @onbProjLockAccountsDesc.
  ///
  /// In es, this message translates to:
  /// **'Protege tus cuentas de redes sociales y videojuegos contra hackeos y robos.'**
  String get onbProjLockAccountsDesc;

  /// No description provided for @onbProjNavImmunity.
  ///
  /// In es, this message translates to:
  /// **'Navega con inmunidad'**
  String get onbProjNavImmunity;

  /// No description provided for @onbProjNavImmunityDesc.
  ///
  /// In es, this message translates to:
  /// **'Detecta estafas, enlaces maliciosos y phishing antes de hacer clic.'**
  String get onbProjNavImmunityDesc;

  /// No description provided for @onbProjectionTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Esto es lo que dominarás en 3 meses!'**
  String get onbProjectionTitle;

  /// No description provided for @onbQuizIntro.
  ///
  /// In es, this message translates to:
  /// **'Responda {count} preguntas rápidas antes de su primer entrenamiento digital'**
  String onbQuizIntro(Object count);

  /// No description provided for @onbRecommended.
  ///
  /// In es, this message translates to:
  /// **'RECOMENDADO'**
  String get onbRecommended;

  /// No description provided for @onbReferralFriends.
  ///
  /// In es, this message translates to:
  /// **'Referir amigos'**
  String get onbReferralFriends;

  /// No description provided for @onbReferralGoogle.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda de Google'**
  String get onbReferralGoogle;

  /// No description provided for @onbReferralOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get onbReferralOther;

  /// No description provided for @onbReferralPlayStore.
  ///
  /// In es, this message translates to:
  /// **'Play Store'**
  String get onbReferralPlayStore;

  /// No description provided for @onbReferralQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo descubriste la existencia de SAGEN?'**
  String get onbReferralQuestion;

  /// No description provided for @onbReferralSocial.
  ///
  /// In es, this message translates to:
  /// **'Instagram / Facebook'**
  String get onbReferralSocial;

  /// No description provided for @onbReferralTiktok.
  ///
  /// In es, this message translates to:
  /// **'TikTok'**
  String get onbReferralTiktok;

  /// No description provided for @onbReferralTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo descubriste SAGEN?'**
  String get onbReferralTitle;

  /// No description provided for @onbReferralYoutube.
  ///
  /// In es, this message translates to:
  /// **'YouTube'**
  String get onbReferralYoutube;

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

  /// No description provided for @onbRoutineMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Elige tu rutina de entrenamiento y blindaje!'**
  String get onbRoutineMessage;

  /// No description provided for @onbRoutineTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Elige tu rutina de capacitación y protección!'**
  String get onbRoutineTitle;

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

  /// No description provided for @onbWelcomeMessage.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy Sagen. Estoy aquí para entrenarte, blindar tu entorno digital y convertirte en un experto.'**
  String get onbWelcomeMessage;

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

  /// No description provided for @onboardingComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Listo! Ya sabes detectar phishing básico.'**
  String get onboardingComplete;

  /// No description provided for @onboardingDesc.
  ///
  /// In es, this message translates to:
  /// **'Tu asistente personal de seguridad digital.\nAprende, analiza y protégete gratis.'**
  String get onboardingDesc;

  /// No description provided for @onboardingError.
  ///
  /// In es, this message translates to:
  /// **'Así actúan. Siempre verifican antes de confiar.'**
  String get onboardingError;

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

  /// No description provided for @onboardingWelcome.
  ///
  /// In es, this message translates to:
  /// **'Aprende a protegerte'**
  String get onboardingWelcome;

  /// No description provided for @onboardingWelcomeDesc.
  ///
  /// In es, this message translates to:
  /// **'SAGEN te enseña a navegar, detectar riesgos y proteger tu información en internet.'**
  String get onboardingWelcomeDesc;

  /// No description provided for @ourMission.
  ///
  /// In es, this message translates to:
  /// **'Nuestra misión'**
  String get ourMission;

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

  /// No description provided for @paymentCredited.
  ///
  /// In es, this message translates to:
  /// **'¡Acreditado!'**
  String get paymentCredited;

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

  /// No description provided for @paymentReturnToSagen.
  ///
  /// In es, this message translates to:
  /// **'Volver a SAGEN'**
  String get paymentReturnToSagen;

  /// No description provided for @paymentTryAgain.
  ///
  /// In es, this message translates to:
  /// **'Intentar de nuevo'**
  String get paymentTryAgain;

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

  /// No description provided for @paywallPackageAmount.
  ///
  /// In es, this message translates to:
  /// **'{gems} donaciones'**
  String paywallPackageAmount(Object gems);

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

  /// No description provided for @portuguese.
  ///
  /// In es, this message translates to:
  /// **'Portugués'**
  String get portuguese;

  /// No description provided for @preferencesTitle.
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get preferencesTitle;

  /// No description provided for @preparingResults.
  ///
  /// In es, this message translates to:
  /// **'Preparando resultados...'**
  String get preparingResults;

  /// No description provided for @privacyLegal.
  ///
  /// In es, this message translates to:
  /// **'Privacidad y legal'**
  String get privacyLegal;

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

  /// No description provided for @productDonations.
  ///
  /// In es, this message translates to:
  /// **'Donaciones'**
  String get productDonations;

  /// No description provided for @productDonationsDesc.
  ///
  /// In es, this message translates to:
  /// **'Donaciones para potenciar tu aprendizaje'**
  String get productDonationsDesc;

  /// No description provided for @productFortune.
  ///
  /// In es, this message translates to:
  /// **'Fortuna'**
  String get productFortune;

  /// No description provided for @productFortunePack.
  ///
  /// In es, this message translates to:
  /// **'Pack Fortuna'**
  String get productFortunePack;

  /// No description provided for @productFortunePackDesc.
  ///
  /// In es, this message translates to:
  /// **'300 donaciones + 1 Multiplicador de XP'**
  String get productFortunePackDesc;

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

  /// No description provided for @productOffer.
  ///
  /// In es, this message translates to:
  /// **'Oferta'**
  String get productOffer;

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

  /// No description provided for @productUltra.
  ///
  /// In es, this message translates to:
  /// **'Ultra'**
  String get productUltra;

  /// No description provided for @productXpBoostDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Boost de XP (2x en tu próxima lección)'**
  String get productXpBoostDesc;

  /// No description provided for @productXpMultiplierDesc.
  ///
  /// In es, this message translates to:
  /// **'1 Multiplicador de XP (2x en cofres)'**
  String get productXpMultiplierDesc;

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

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Perfil'**
  String get profileTitle;

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

  /// No description provided for @progressRestored.
  ///
  /// In es, this message translates to:
  /// **'Progreso restaurado desde la nube'**
  String get progressRestored;

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

  /// No description provided for @promoPostLessonSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con SAGEN Pass obtienes beneficios exclusivos'**
  String get promoPostLessonSubtitle;

  /// No description provided for @promoPostLessonTitle.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así! Desbloquea más'**
  String get promoPostLessonTitle;

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

  /// No description provided for @questionProgress.
  ///
  /// In es, this message translates to:
  /// **'Pregunta {current} de {total}'**
  String questionProgress(Object current, Object total);

  /// No description provided for @questions.
  ///
  /// In es, this message translates to:
  /// **'{count} preguntas'**
  String questions(Object count);

  /// No description provided for @quickActions.
  ///
  /// In es, this message translates to:
  /// **'Acciones rápidas'**
  String get quickActions;

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

  /// No description provided for @quizAbandonContent.
  ///
  /// In es, this message translates to:
  /// **'Perderás tu progreso actual.'**
  String get quizAbandonContent;

  /// No description provided for @quizAbandonExit.
  ///
  /// In es, this message translates to:
  /// **'SALIR'**
  String get quizAbandonExit;

  /// No description provided for @quizAbandonMessage.
  ///
  /// In es, this message translates to:
  /// **'Perderás tu progreso actual.'**
  String get quizAbandonMessage;

  /// No description provided for @quizAbandonStay.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get quizAbandonStay;

  /// No description provided for @quizAbandonTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Salir?'**
  String get quizAbandonTitle;

  /// No description provided for @quizBack.
  ///
  /// In es, this message translates to:
  /// **'Atrás'**
  String get quizBack;

  /// No description provided for @quizCheck.
  ///
  /// In es, this message translates to:
  /// **'VERIFICAR'**
  String get quizCheck;

  /// No description provided for @quizCheckAnswer.
  ///
  /// In es, this message translates to:
  /// **'VERIFICAR'**
  String get quizCheckAnswer;

  /// No description provided for @quizContinue.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get quizContinue;

  /// No description provided for @quizContinueButton.
  ///
  /// In es, this message translates to:
  /// **'CONTINUAR'**
  String get quizContinueButton;

  /// No description provided for @quizDefaultTitle.
  ///
  /// In es, this message translates to:
  /// **'Cuestionario'**
  String get quizDefaultTitle;

  /// No description provided for @quizExit.
  ///
  /// In es, this message translates to:
  /// **'SALIR'**
  String get quizExit;

  /// No description provided for @quizIntroAnswer.
  ///
  /// In es, this message translates to:
  /// **'Responde'**
  String get quizIntroAnswer;

  /// No description provided for @quizIntroBeforeTraining.
  ///
  /// In es, this message translates to:
  /// **'Antes de tu entrenamiento'**
  String get quizIntroBeforeTraining;

  /// No description provided for @quizIntroFastQuestions.
  ///
  /// In es, this message translates to:
  /// **'Preguntas rápidas'**
  String get quizIntroFastQuestions;

  /// No description provided for @quizProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso del cuestionario: {percent} por ciento'**
  String quizProgress(Object percent);

  /// No description provided for @quizProgressExpired.
  ///
  /// In es, this message translates to:
  /// **'El progreso del cuestionario ha expirado (más de 24 horas).'**
  String get quizProgressExpired;

  /// No description provided for @quizResumeButton.
  ///
  /// In es, this message translates to:
  /// **'Reanudar'**
  String get quizResumeButton;

  /// No description provided for @quizStartOver.
  ///
  /// In es, this message translates to:
  /// **'Empezar de nuevo'**
  String get quizStartOver;

  /// No description provided for @quizTitleDefault.
  ///
  /// In es, this message translates to:
  /// **'Cuestionario'**
  String get quizTitleDefault;

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

  /// No description provided for @reauthConfirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get reauthConfirm;

  /// No description provided for @reauthDesc.
  ///
  /// In es, this message translates to:
  /// **'Por razones de seguridad, por favor ingresa tu contraseña nuevamente'**
  String get reauthDesc;

  /// No description provided for @reauthOAuthInfo.
  ///
  /// In es, this message translates to:
  /// **'Iniciaste sesión con Google o Facebook. Confirma la eliminación de tu cuenta.'**
  String get reauthOAuthInfo;

  /// No description provided for @reauthTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirma tu contraseña'**
  String get reauthTitle;

  /// No description provided for @reauthWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Intenta de nuevo.'**
  String get reauthWrongPassword;

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

  /// No description provided for @referralSource1.
  ///
  /// In es, this message translates to:
  /// **'Recomendación de amigos'**
  String get referralSource1;

  /// No description provided for @referralSource2.
  ///
  /// In es, this message translates to:
  /// **'Redes sociales'**
  String get referralSource2;

  /// No description provided for @referralSource3.
  ///
  /// In es, this message translates to:
  /// **'Búsqueda de Google'**
  String get referralSource3;

  /// No description provided for @referralSource4.
  ///
  /// In es, this message translates to:
  /// **'App Store'**
  String get referralSource4;

  /// No description provided for @referralSource5.
  ///
  /// In es, this message translates to:
  /// **'YouTube'**
  String get referralSource5;

  /// No description provided for @referralSource6.
  ///
  /// In es, this message translates to:
  /// **'TikTok'**
  String get referralSource6;

  /// No description provided for @referralSource7.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get referralSource7;

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

  /// No description provided for @regMethodTitle.
  ///
  /// In es, this message translates to:
  /// **'Elige tu método de registro'**
  String get regMethodTitle;

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
  /// **'Mínimo 6 caracteres para proteger tu cuenta.'**
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
  /// **'Prepara para tu primera lección'**
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

  /// No description provided for @registerAgeEmpty.
  ///
  /// In es, this message translates to:
  /// **'Por favor ingresa tu edad'**
  String get registerAgeEmpty;

  /// No description provided for @registerAgeHint.
  ///
  /// In es, this message translates to:
  /// **'Tu edad (mínimo 13)'**
  String get registerAgeHint;

  /// No description provided for @registerAgeInvalid.
  ///
  /// In es, this message translates to:
  /// **'Edad no válida'**
  String get registerAgeInvalid;

  /// No description provided for @registerAgeMin.
  ///
  /// In es, this message translates to:
  /// **'Debes tener al menos 13 años'**
  String get registerAgeMin;

  /// No description provided for @registerWithApple.
  ///
  /// In es, this message translates to:
  /// **'Regístrate con Apple'**
  String get registerWithApple;

  /// No description provided for @registerWithFacebook.
  ///
  /// In es, this message translates to:
  /// **'Regístrate con Facebook'**
  String get registerWithFacebook;

  /// No description provided for @registerWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Regístrate con Google'**
  String get registerWithGoogle;

  /// No description provided for @restartApp.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar app'**
  String get restartApp;

  /// No description provided for @restoreAction.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get restoreAction;

  /// No description provided for @restoreCloud.
  ///
  /// In es, this message translates to:
  /// **'Restaurar desde la nube'**
  String get restoreCloud;

  /// No description provided for @restoreDesc.
  ///
  /// In es, this message translates to:
  /// **'¿Quieres restaurar tu progreso desde la nube? Esto reemplazará los datos locales con los datos guardados en tu cuenta.'**
  String get restoreDesc;

  /// No description provided for @restoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Restaurar progreso'**
  String get restoreTitle;

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

  /// No description provided for @retry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// No description provided for @reviewComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Repaso completo!'**
  String get reviewComplete;

  /// No description provided for @reviewCorrect.
  ///
  /// In es, this message translates to:
  /// **'correctas'**
  String get reviewCorrect;

  /// No description provided for @reviewFinish.
  ///
  /// In es, this message translates to:
  /// **'Finalizar repaso'**
  String get reviewFinish;

  /// No description provided for @reviewGoodProgress.
  ///
  /// In es, this message translates to:
  /// **'Buen avance'**
  String get reviewGoodProgress;

  /// No description provided for @reviewKeepGoing.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así!'**
  String get reviewKeepGoing;

  /// No description provided for @reviewKeepPracticing.
  ///
  /// In es, this message translates to:
  /// **'Sigue practicando'**
  String get reviewKeepPracticing;

  /// No description provided for @reviewNoErrors.
  ///
  /// In es, this message translates to:
  /// **'No hay errores que repasar'**
  String get reviewNoErrors;

  /// No description provided for @reviewSageGood.
  ///
  /// In es, this message translates to:
  /// **'Cada repaso fortalece tu escudo. ¿Listo para más?'**
  String get reviewSageGood;

  /// No description provided for @reviewSageKeep.
  ///
  /// In es, this message translates to:
  /// **'Repasar es parte del aprendizaje. Puedes volver a intentarlo cuando quieras.'**
  String get reviewSageKeep;

  /// No description provided for @reviewSagePerfect.
  ///
  /// In es, this message translates to:
  /// **'Tus áreas débiles están mejorando. Noto tu esfuerzo.'**
  String get reviewSagePerfect;

  /// No description provided for @reviewTitle.
  ///
  /// In es, this message translates to:
  /// **'Repaso'**
  String get reviewTitle;

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

  /// No description provided for @rewardAdCooldown.
  ///
  /// In es, this message translates to:
  /// **'Disponible en {seconds} segundos'**
  String rewardAdCooldown(Object seconds);

  /// No description provided for @rewardAdEarned.
  ///
  /// In es, this message translates to:
  /// **'¡Ganaste {count} donaciones!'**
  String rewardAdEarned(Object count);

  /// No description provided for @rewardAdEarnedGems.
  ///
  /// In es, this message translates to:
  /// **'+{gems} gemas'**
  String rewardAdEarnedGems(Object gems);

  /// No description provided for @rewardAdEarnedXp.
  ///
  /// In es, this message translates to:
  /// **'¡+{xp} XP ganados!'**
  String rewardAdEarnedXp(Object xp);

  /// No description provided for @rewardAdNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'El anuncio no está disponible ahora. Intenta más tarde.'**
  String get rewardAdNotAvailable;

  /// No description provided for @rewardAdSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Mira un anuncio y recibe donaciones al instante'**
  String get rewardAdSubtitle;

  /// No description provided for @rewardAdTitle.
  ///
  /// In es, this message translates to:
  /// **'Gana donaciones extra'**
  String get rewardAdTitle;

  /// No description provided for @rewardAdWatch.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get rewardAdWatch;

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

  /// No description provided for @sageAchievementUnlocked.
  ///
  /// In es, this message translates to:
  /// **'{name}¡Logro desbloqueado!'**
  String sageAchievementUnlocked(Object name);

  /// No description provided for @sageAdvancing.
  ///
  /// In es, this message translates to:
  /// **'{name}Sigues avanzando.{levelHint}'**
  String sageAdvancing(Object levelHint, Object name);

  /// No description provided for @sageChatDescription.
  ///
  /// In es, this message translates to:
  /// **'Escribe cualquier duda sobre ciberseguridad o elige una sugerencia rápida.'**
  String get sageChatDescription;

  /// No description provided for @sageChatHint.
  ///
  /// In es, this message translates to:
  /// **'Pregunta a Sage...'**
  String get sageChatHint;

  /// No description provided for @sageChatTitle.
  ///
  /// In es, this message translates to:
  /// **'Pregunta a Sage'**
  String get sageChatTitle;

  /// No description provided for @sageCongratulations.
  ///
  /// In es, this message translates to:
  /// **'{name}¡Felicidades!'**
  String sageCongratulations(Object name);

  /// No description provided for @sageCriticalError.
  ///
  /// In es, this message translates to:
  /// **'Error crítico'**
  String get sageCriticalError;

  /// No description provided for @sageEasterEgg.
  ///
  /// In es, this message translates to:
  /// **'¿Viste eso?'**
  String get sageEasterEgg;

  /// No description provided for @sageEmptyState.
  ///
  /// In es, this message translates to:
  /// **'{name}No hay nada aquí todavía'**
  String sageEmptyState(Object name);

  /// No description provided for @sageGreatJob.
  ///
  /// In es, this message translates to:
  /// **'{name}¡Excelente trabajo!{extra}'**
  String sageGreatJob(Object name, Object extra);

  /// No description provided for @sageHighStreakDays.
  ///
  /// In es, this message translates to:
  /// **' {streak} días seguidos.'**
  String sageHighStreakDays(Object streak);

  /// No description provided for @sageImportant.
  ///
  /// In es, this message translates to:
  /// **'Esto es muy importante'**
  String get sageImportant;

  /// No description provided for @sageImpressiveStreak.
  ///
  /// In es, this message translates to:
  /// **'{name}¡Racha impresionante!{days}'**
  String sageImpressiveStreak(Object name, Object days);

  /// No description provided for @sageLevelHint.
  ///
  /// In es, this message translates to:
  /// **' El nivel {level} ya está cerca.'**
  String sageLevelHint(Object level);

  /// No description provided for @sageLoading.
  ///
  /// In es, this message translates to:
  /// **'Dame un segundo...'**
  String get sageLoading;

  /// No description provided for @sageMascot.
  ///
  /// In es, this message translates to:
  /// **'Mascota Sage'**
  String get sageMascot;

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

  /// No description provided for @sageMotivational1.
  ///
  /// In es, this message translates to:
  /// **'¡Eres increíble!'**
  String get sageMotivational1;

  /// No description provided for @sageMotivational2.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue adelante, eres increíble!'**
  String get sageMotivational2;

  /// No description provided for @sageMotivational3.
  ///
  /// In es, this message translates to:
  /// **'¡Cada día más cerca de tu objetivo!'**
  String get sageMotivational3;

  /// No description provided for @sageMotivational4.
  ///
  /// In es, this message translates to:
  /// **'¡Yo creo en ti!'**
  String get sageMotivational4;

  /// No description provided for @sageMotivational5.
  ///
  /// In es, this message translates to:
  /// **'No te rindas, ¡tú puedes!'**
  String get sageMotivational5;

  /// No description provided for @sageMotivational6.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos a esta aventura juntos!'**
  String get sageMotivational6;

  /// No description provided for @sageMotivational7.
  ///
  /// In es, this message translates to:
  /// **'¡El esfuerzo rinde frutos!'**
  String get sageMotivational7;

  /// No description provided for @sageMotivational8.
  ///
  /// In es, this message translates to:
  /// **'¡Nunca dejes de aprender!'**
  String get sageMotivational8;

  /// No description provided for @sagePerfect.
  ///
  /// In es, this message translates to:
  /// **'¡Perfecto!'**
  String get sagePerfect;

  /// No description provided for @sagePreparing.
  ///
  /// In es, this message translates to:
  /// **'Preparando todo para ti'**
  String get sagePreparing;

  /// No description provided for @sageReadCarefully.
  ///
  /// In es, this message translates to:
  /// **'Lee con atención'**
  String get sageReadCarefully;

  /// No description provided for @sageSomethingWrong.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal'**
  String get sageSomethingWrong;

  /// No description provided for @sageStreakAmazing.
  ///
  /// In es, this message translates to:
  /// **'¡Tu racha de {streak} días es increíble!'**
  String sageStreakAmazing(Object streak);

  /// No description provided for @sageStreakAtRisk.
  ///
  /// In es, this message translates to:
  /// **' ¡No pierdas {streak} días de esfuerzo!'**
  String sageStreakAtRisk(Object streak);

  /// No description provided for @sageStreakAtRiskMessage.
  ///
  /// In es, this message translates to:
  /// **'{name}¡No pierdas tu racha!{urgency}'**
  String sageStreakAtRiskMessage(Object urgency, Object name);

  /// No description provided for @sageStreakLost.
  ///
  /// In es, this message translates to:
  /// **' Tienes el conocimiento para empezar de nuevo.'**
  String get sageStreakLost;

  /// No description provided for @sageStreakLostMessage.
  ///
  /// In es, this message translates to:
  /// **'{name}La racha se ha perdido.{encouragement}'**
  String sageStreakLostMessage(Object name, Object encouragement);

  /// No description provided for @sageTellMeMore.
  ///
  /// In es, this message translates to:
  /// **'{name}Cuéntame más de ti'**
  String sageTellMeMore(Object name);

  /// No description provided for @sageTryAgain.
  ///
  /// In es, this message translates to:
  /// **'¿Intentamos de nuevo?'**
  String get sageTryAgain;

  /// No description provided for @sageWelcomeBack.
  ///
  /// In es, this message translates to:
  /// **'{name}¡Bienvenido de vuelta!'**
  String sageWelcomeBack(Object name);

  /// No description provided for @sageWhatDoYouThink.
  ///
  /// In es, this message translates to:
  /// **'{name}¿Qué crees que es correcto?'**
  String sageWhatDoYouThink(Object name);

  /// No description provided for @sagenPassClaim.
  ///
  /// In es, this message translates to:
  /// **'Reclamar'**
  String get sagenPassClaim;

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

  /// No description provided for @savedQuizProgress.
  ///
  /// In es, this message translates to:
  /// **'Tienes un progreso guardado. ¿Te gustaría continuar?'**
  String get savedQuizProgress;

  /// No description provided for @scheduledDarkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro programado'**
  String get scheduledDarkMode;

  /// No description provided for @scheduledDarkModeSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Activo/desactivo según horario'**
  String get scheduledDarkModeSubtitle;

  /// No description provided for @searchPlaceholder.
  ///
  /// In es, this message translates to:
  /// **'Buscar...'**
  String get searchPlaceholder;

  /// No description provided for @selectFile.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar archivo'**
  String get selectFile;

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

  /// No description provided for @sessionAccuracyText1.
  ///
  /// In es, this message translates to:
  /// **'¡Muy buena puntería!'**
  String get sessionAccuracyText1;

  /// No description provided for @sessionAccuracyText2.
  ///
  /// In es, this message translates to:
  /// **'Precisión quirúrgica.'**
  String get sessionAccuracyText2;

  /// No description provided for @sessionAccuracyText3.
  ///
  /// In es, this message translates to:
  /// **'Nivel experto alcanzado.'**
  String get sessionAccuracyText3;

  /// No description provided for @sessionAccuracyText4.
  ///
  /// In es, this message translates to:
  /// **'¡Tirador certero de conocimiento!'**
  String get sessionAccuracyText4;

  /// No description provided for @sessionAccuracyText5.
  ///
  /// In es, this message translates to:
  /// **'Precisión casi perfecta.'**
  String get sessionAccuracyText5;

  /// No description provided for @sessionAccuracyText6.
  ///
  /// In es, this message translates to:
  /// **'Sin margen de error.'**
  String get sessionAccuracyText6;

  /// No description provided for @sessionAccuracyText7.
  ///
  /// In es, this message translates to:
  /// **'Impecable.'**
  String get sessionAccuracyText7;

  /// No description provided for @sessionBackToMap.
  ///
  /// In es, this message translates to:
  /// **'Volver al mapa'**
  String get sessionBackToMap;

  /// No description provided for @sessionClaimReward.
  ///
  /// In es, this message translates to:
  /// **'RECLAMAR RECOMPENSA'**
  String get sessionClaimReward;

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

  /// No description provided for @sessionExp.
  ///
  /// In es, this message translates to:
  /// **'EXP'**
  String get sessionExp;

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

  /// No description provided for @sessionPrecision.
  ///
  /// In es, this message translates to:
  /// **'PRECISIÓN'**
  String get sessionPrecision;

  /// No description provided for @sessionQuestionsToAnswer.
  ///
  /// In es, this message translates to:
  /// **'preguntas por responder'**
  String get sessionQuestionsToAnswer;

  /// No description provided for @sessionReadyToLearn.
  ///
  /// In es, this message translates to:
  /// **'¿Listo para aprender?'**
  String get sessionReadyToLearn;

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

  /// No description provided for @sessionSpeedText1.
  ///
  /// In es, this message translates to:
  /// **'¡Qué velocidad!'**
  String get sessionSpeedText1;

  /// No description provided for @sessionSpeedText2.
  ///
  /// In es, this message translates to:
  /// **'Superaste el tiempo.'**
  String get sessionSpeedText2;

  /// No description provided for @sessionSpeedText3.
  ///
  /// In es, this message translates to:
  /// **'A la velocidad de la luz.'**
  String get sessionSpeedText3;

  /// No description provided for @sessionSpeedText4.
  ///
  /// In es, this message translates to:
  /// **'Reflejos de acero.'**
  String get sessionSpeedText4;

  /// No description provided for @sessionSpeedText5.
  ///
  /// In es, this message translates to:
  /// **'Nadie puede alcanzarte hoy.'**
  String get sessionSpeedText5;

  /// No description provided for @sessionSpeedText6.
  ///
  /// In es, this message translates to:
  /// **'¡Tiempo récord!'**
  String get sessionSpeedText6;

  /// No description provided for @sessionSpeedText7.
  ///
  /// In es, this message translates to:
  /// **'Velocidad supersónica.'**
  String get sessionSpeedText7;

  /// No description provided for @sessionStandardText1.
  ///
  /// In es, this message translates to:
  /// **'¡Lección completada!'**
  String get sessionStandardText1;

  /// No description provided for @sessionStandardText2.
  ///
  /// In es, this message translates to:
  /// **'Un paso más hacia tu meta.'**
  String get sessionStandardText2;

  /// No description provided for @sessionStandardText3.
  ///
  /// In es, this message translates to:
  /// **'El progreso es el camino.'**
  String get sessionStandardText3;

  /// No description provided for @sessionStandardText4.
  ///
  /// In es, this message translates to:
  /// **'Buen trabajo constante.'**
  String get sessionStandardText4;

  /// No description provided for @sessionStandardText5.
  ///
  /// In es, this message translates to:
  /// **'Sigue adelante, suma más días.'**
  String get sessionStandardText5;

  /// No description provided for @sessionStandardText6.
  ///
  /// In es, this message translates to:
  /// **'La constancia sobre todo.'**
  String get sessionStandardText6;

  /// No description provided for @sessionStandardText7.
  ///
  /// In es, this message translates to:
  /// **'La disciplina da resultados.'**
  String get sessionStandardText7;

  /// No description provided for @sessionStartQuiz.
  ///
  /// In es, this message translates to:
  /// **'INICIAR CUESTIONARIO'**
  String get sessionStartQuiz;

  /// No description provided for @sessionSummaryAccuracy.
  ///
  /// In es, this message translates to:
  /// **'PRECISIÓN'**
  String get sessionSummaryAccuracy;

  /// No description provided for @sessionSummaryAccuracy1.
  ///
  /// In es, this message translates to:
  /// **'¡Tu precisión es extraordinaria!'**
  String get sessionSummaryAccuracy1;

  /// No description provided for @sessionSummaryAccuracy2.
  ///
  /// In es, this message translates to:
  /// **'¡Excelente puntería!'**
  String get sessionSummaryAccuracy2;

  /// No description provided for @sessionSummaryAccuracy3.
  ///
  /// In es, this message translates to:
  /// **'¡Buen progreso!'**
  String get sessionSummaryAccuracy3;

  /// No description provided for @sessionSummaryAccuracy4.
  ///
  /// In es, this message translates to:
  /// **'¡Estás mejorando!'**
  String get sessionSummaryAccuracy4;

  /// No description provided for @sessionSummaryAccuracy5.
  ///
  /// In es, this message translates to:
  /// **'¡Gran esfuerzo!'**
  String get sessionSummaryAccuracy5;

  /// No description provided for @sessionSummaryAccuracy6.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue aprendiendo!'**
  String get sessionSummaryAccuracy6;

  /// No description provided for @sessionSummaryAccuracy7.
  ///
  /// In es, this message translates to:
  /// **'¡Cada pregunta cuenta!'**
  String get sessionSummaryAccuracy7;

  /// No description provided for @sessionSummaryExp.
  ///
  /// In es, this message translates to:
  /// **'EXP'**
  String get sessionSummaryExp;

  /// No description provided for @sessionSummaryReceiveReward.
  ///
  /// In es, this message translates to:
  /// **'RECLAMAR RECOMPENSA'**
  String get sessionSummaryReceiveReward;

  /// No description provided for @sessionSummaryReceiveRewardLabel.
  ///
  /// In es, this message translates to:
  /// **'Recolectar recompensa'**
  String get sessionSummaryReceiveRewardLabel;

  /// No description provided for @sessionSummarySpeed1.
  ///
  /// In es, this message translates to:
  /// **'¡Velocidad relámpago!'**
  String get sessionSummarySpeed1;

  /// No description provided for @sessionSummarySpeed2.
  ///
  /// In es, this message translates to:
  /// **'¡Pensamiento rápido!'**
  String get sessionSummarySpeed2;

  /// No description provided for @sessionSummarySpeed3.
  ///
  /// In es, this message translates to:
  /// **'¡Aprendiz rápido!'**
  String get sessionSummarySpeed3;

  /// No description provided for @sessionSummarySpeed4.
  ///
  /// In es, this message translates to:
  /// **'¡Buen ritmo!'**
  String get sessionSummarySpeed4;

  /// No description provided for @sessionSummarySpeed5.
  ///
  /// In es, this message translates to:
  /// **'¡En el camino correcto!'**
  String get sessionSummarySpeed5;

  /// No description provided for @sessionSummarySpeed6.
  ///
  /// In es, this message translates to:
  /// **'¡Construyendo impulso!'**
  String get sessionSummarySpeed6;

  /// No description provided for @sessionSummarySpeed7.
  ///
  /// In es, this message translates to:
  /// **'¡Progreso constante!'**
  String get sessionSummarySpeed7;

  /// No description provided for @sessionSummaryStandard1.
  ///
  /// In es, this message translates to:
  /// **'¡Lección completada!'**
  String get sessionSummaryStandard1;

  /// No description provided for @sessionSummaryStandard2.
  ///
  /// In es, this message translates to:
  /// **'¡Bien hecho!'**
  String get sessionSummaryStandard2;

  /// No description provided for @sessionSummaryStandard3.
  ///
  /// In es, this message translates to:
  /// **'¡Buen trabajo!'**
  String get sessionSummaryStandard3;

  /// No description provided for @sessionSummaryStandard4.
  ///
  /// In es, this message translates to:
  /// **'¡Buen trabajo!'**
  String get sessionSummaryStandard4;

  /// No description provided for @sessionSummaryStandard5.
  ///
  /// In es, this message translates to:
  /// **'¡Lo lograste!'**
  String get sessionSummaryStandard5;

  /// No description provided for @sessionSummaryStandard6.
  ///
  /// In es, this message translates to:
  /// **'¡Otro paso adelante!'**
  String get sessionSummaryStandard6;

  /// No description provided for @sessionSummaryStandard7.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue adelante!'**
  String get sessionSummaryStandard7;

  /// No description provided for @sessionSummaryTime.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO'**
  String get sessionSummaryTime;

  /// No description provided for @sessionTime.
  ///
  /// In es, this message translates to:
  /// **'TIEMPO'**
  String get sessionTime;

  /// No description provided for @settingsAmoledDark.
  ///
  /// In es, this message translates to:
  /// **'AMOLED Oscuro'**
  String get settingsAmoledDark;

  /// No description provided for @settingsAmoledDarkSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Fondo #000000 puro para ahorrar batería'**
  String get settingsAmoledDarkSubtitle;

  /// No description provided for @settingsAnalytics.
  ///
  /// In es, this message translates to:
  /// **'Análisis anónimo'**
  String get settingsAnalytics;

  /// No description provided for @settingsAnalyticsDesc.
  ///
  /// In es, this message translates to:
  /// **'Ayuda a mejorar Sagen con datos de uso anónimos'**
  String get settingsAnalyticsDesc;

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDeleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro? Esta acción no se puede deshacer.'**
  String get settingsDeleteAccountConfirm;

  /// No description provided for @settingsExportData.
  ///
  /// In es, this message translates to:
  /// **'Exportar datos'**
  String get settingsExportData;

  /// No description provided for @settingsFontSize.
  ///
  /// In es, this message translates to:
  /// **'Tamaño de fuente'**
  String get settingsFontSize;

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

  /// No description provided for @settingsPrivacy.
  ///
  /// In es, this message translates to:
  /// **'Privacidad'**
  String get settingsPrivacy;

  /// No description provided for @settingsReduceAnimations.
  ///
  /// In es, this message translates to:
  /// **'Reducir animaciones'**
  String get settingsReduceAnimations;

  /// No description provided for @settingsSound.
  ///
  /// In es, this message translates to:
  /// **'Sonido'**
  String get settingsSound;

  /// No description provided for @settingsTheme.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get settingsTheme;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settingsTitle;

  /// No description provided for @settingsVibration.
  ///
  /// In es, this message translates to:
  /// **'Vibración'**
  String get settingsVibration;

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

  /// No description provided for @shieldTierBasic.
  ///
  /// In es, this message translates to:
  /// **'Escudo Básico'**
  String get shieldTierBasic;

  /// No description provided for @shieldTierCrystal.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Cristal'**
  String get shieldTierCrystal;

  /// No description provided for @shieldTierGlow.
  ///
  /// In es, this message translates to:
  /// **'Escudo Radiante'**
  String get shieldTierGlow;

  /// No description provided for @shieldTierInactive.
  ///
  /// In es, this message translates to:
  /// **'Sin Escudo'**
  String get shieldTierInactive;

  /// No description provided for @shieldTierLegendary.
  ///
  /// In es, this message translates to:
  /// **'Escudo Legendario'**
  String get shieldTierLegendary;

  /// No description provided for @shieldTierParticles.
  ///
  /// In es, this message translates to:
  /// **'Escudo de Partículas'**
  String get shieldTierParticles;

  /// No description provided for @shopBgCyber.
  ///
  /// In es, this message translates to:
  /// **'Fondo Cyberpunk'**
  String get shopBgCyber;

  /// No description provided for @shopBgCyberDesc.
  ///
  /// In es, this message translates to:
  /// **'Fondo de perfil futurista'**
  String get shopBgCyberDesc;

  /// No description provided for @shopBgMatrix.
  ///
  /// In es, this message translates to:
  /// **'Fondo Matrix'**
  String get shopBgMatrix;

  /// No description provided for @shopBgMatrixDesc.
  ///
  /// In es, this message translates to:
  /// **'Fondo de matriz verde'**
  String get shopBgMatrixDesc;

  /// No description provided for @shopFrameDiamond.
  ///
  /// In es, this message translates to:
  /// **'Marco de Diamante'**
  String get shopFrameDiamond;

  /// No description provided for @shopFrameDiamondDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco de diamante exclusivo'**
  String get shopFrameDiamondDesc;

  /// No description provided for @shopFrameNeon.
  ///
  /// In es, this message translates to:
  /// **'Marco Neón'**
  String get shopFrameNeon;

  /// No description provided for @shopFrameNeonDesc.
  ///
  /// In es, this message translates to:
  /// **'Marco de perfil neón'**
  String get shopFrameNeonDesc;

  /// No description provided for @shopItemAcquired.
  ///
  /// In es, this message translates to:
  /// **'Obtenido'**
  String get shopItemAcquired;

  /// No description provided for @shopItemOwned.
  ///
  /// In es, this message translates to:
  /// **'Obtenido'**
  String get shopItemOwned;

  /// No description provided for @shopOwned.
  ///
  /// In es, this message translates to:
  /// **'Obtenido'**
  String get shopOwned;

  /// No description provided for @shopSageGolden.
  ///
  /// In es, this message translates to:
  /// **'Sage Dorado'**
  String get shopSageGolden;

  /// No description provided for @shopSageGoldenDesc.
  ///
  /// In es, this message translates to:
  /// **'Skin dorada exclusiva'**
  String get shopSageGoldenDesc;

  /// No description provided for @shopSageNeon.
  ///
  /// In es, this message translates to:
  /// **'Sage Neón'**
  String get shopSageNeon;

  /// No description provided for @shopSageNeonDesc.
  ///
  /// In es, this message translates to:
  /// **'Skin neón cyan para Sage'**
  String get shopSageNeonDesc;

  /// No description provided for @shopSageShadow.
  ///
  /// In es, this message translates to:
  /// **'Sage Sombra'**
  String get shopSageShadow;

  /// No description provided for @shopSageShadowDesc.
  ///
  /// In es, this message translates to:
  /// **'Piel oscura para Sage'**
  String get shopSageShadowDesc;

  /// No description provided for @shopTitleGuardian.
  ///
  /// In es, this message translates to:
  /// **'Título de Guardián Digital'**
  String get shopTitleGuardian;

  /// No description provided for @shopTitleGuardianDesc.
  ///
  /// In es, this message translates to:
  /// **'Título de guardián'**
  String get shopTitleGuardianDesc;

  /// No description provided for @shopTitleHacker.
  ///
  /// In es, this message translates to:
  /// **'Título de Hacker Ético'**
  String get shopTitleHacker;

  /// No description provided for @shopTitleHackerDesc.
  ///
  /// In es, this message translates to:
  /// **'Título especial en el perfil'**
  String get shopTitleHackerDesc;

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

  /// No description provided for @spanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get spanish;

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

  /// No description provided for @stage1Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Fundamentos de seguridad digital'**
  String get stage1Subtitle;

  /// No description provided for @stage1Title.
  ///
  /// In es, this message translates to:
  /// **'Fundamentos'**
  String get stage1Title;

  /// No description provided for @stage2Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Identificar intentos de trampa'**
  String get stage2Subtitle;

  /// No description provided for @stage2Title.
  ///
  /// In es, this message translates to:
  /// **'Phishing'**
  String get stage2Title;

  /// No description provided for @stage3Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Crea claves seguras y protégete'**
  String get stage3Subtitle;

  /// No description provided for @stage3Title.
  ///
  /// In es, this message translates to:
  /// **'Contraseñas'**
  String get stage3Title;

  /// No description provided for @stage4Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Protege tu privacidad en plataformas'**
  String get stage4Subtitle;

  /// No description provided for @stage4Title.
  ///
  /// In es, this message translates to:
  /// **'Redes Sociales'**
  String get stage4Title;

  /// No description provided for @stage5Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Desinformación y sitios confiables'**
  String get stage5Subtitle;

  /// No description provided for @stage5Title.
  ///
  /// In es, this message translates to:
  /// **'Navegación segura'**
  String get stage5Title;

  /// No description provided for @stage6Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Controla tus datos personales'**
  String get stage6Subtitle;

  /// No description provided for @stage6Title.
  ///
  /// In es, this message translates to:
  /// **'Privacidad Digital'**
  String get stage6Title;

  /// No description provided for @stage7Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Protección completa para expertos'**
  String get stage7Subtitle;

  /// No description provided for @stage7Title.
  ///
  /// In es, this message translates to:
  /// **'Ciberseguridad Avanzada'**
  String get stage7Title;

  /// No description provided for @stage8Subtitle.
  ///
  /// In es, this message translates to:
  /// **'Conviértete en un guardián digital'**
  String get stage8Subtitle;

  /// No description provided for @stage8Title.
  ///
  /// In es, this message translates to:
  /// **'Experto Digital'**
  String get stage8Title;

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

  /// No description provided for @storeAdEarnXp.
  ///
  /// In es, this message translates to:
  /// **'Gana XP mirando'**
  String get storeAdEarnXp;

  /// No description provided for @storeAdRewardMessage.
  ///
  /// In es, this message translates to:
  /// **'+1 Donación por ver el anuncio'**
  String get storeAdRewardMessage;

  /// No description provided for @storeAdWatchVideo.
  ///
  /// In es, this message translates to:
  /// **'Ve un video de 30 segundos'**
  String get storeAdWatchVideo;

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

  /// No description provided for @storeChestAvailable.
  ///
  /// In es, this message translates to:
  /// **'¡Cofre Diario Disponible!'**
  String get storeChestAvailable;

  /// No description provided for @storeChestComeBack.
  ///
  /// In es, this message translates to:
  /// **'Vuelve mañana'**
  String get storeChestComeBack;

  /// No description provided for @storeChestExpiresIn.
  ///
  /// In es, this message translates to:
  /// **'{gems} donados — expira a medianoche'**
  String storeChestExpiresIn(Object gems);

  /// No description provided for @storeChestRenews.
  ///
  /// In es, this message translates to:
  /// **'Tu cofre se renueva cada día'**
  String get storeChestRenews;

  /// No description provided for @storeClaimError.
  ///
  /// In es, this message translates to:
  /// **'No se pudo reclamar la recompensa. Por favor, inténtalo de nuevo.'**
  String get storeClaimError;

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

  /// No description provided for @storeDonate.
  ///
  /// In es, this message translates to:
  /// **'Donar'**
  String get storeDonate;

  /// No description provided for @storeDonateSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Desde {price}'**
  String storeDonateSubtitle(Object price);

  /// No description provided for @storeDonationsLabel.
  ///
  /// In es, this message translates to:
  /// **'donaciones'**
  String get storeDonationsLabel;

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

  /// No description provided for @storeNoItems.
  ///
  /// In es, this message translates to:
  /// **'No hay artículos disponibles en este momento.'**
  String get storeNoItems;

  /// No description provided for @storeOpen.
  ///
  /// In es, this message translates to:
  /// **'Abrir'**
  String get storeOpen;

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

  /// No description provided for @storeSupport.
  ///
  /// In es, this message translates to:
  /// **'Apóyanos'**
  String get storeSupport;

  /// No description provided for @storeSupportTiers.
  ///
  /// In es, this message translates to:
  /// **'Niveles de apoyo'**
  String get storeSupportTiers;

  /// No description provided for @storeThankYou.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu apoyo!'**
  String get storeThankYou;

  /// No description provided for @storeTitle.
  ///
  /// In es, this message translates to:
  /// **'Tienda'**
  String get storeTitle;

  /// No description provided for @storeWatch.
  ///
  /// In es, this message translates to:
  /// **'Ver'**
  String get storeWatch;

  /// No description provided for @storeWhatsappPackages.
  ///
  /// In es, this message translates to:
  /// **'Paquetes desde {price} — Pago por WhatsApp'**
  String storeWhatsappPackages(Object price);

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

  /// No description provided for @streakChest100Message.
  ///
  /// In es, this message translates to:
  /// **'100 días. Leyenda.'**
  String get streakChest100Message;

  /// No description provided for @streakChest100Title.
  ///
  /// In es, this message translates to:
  /// **'¡Racha de 100 días!'**
  String get streakChest100Title;

  /// No description provided for @streakChest14Message.
  ///
  /// In es, this message translates to:
  /// **'Dos semanas de constancia. ¡Sigue así!'**
  String get streakChest14Message;

  /// No description provided for @streakChest14Title.
  ///
  /// In es, this message translates to:
  /// **'¡Racha de 14 días!'**
  String get streakChest14Title;

  /// No description provided for @streakChest30Message.
  ///
  /// In es, this message translates to:
  /// **'Un mes. Eres un Guardián Digital.'**
  String get streakChest30Message;

  /// No description provided for @streakChest30Title.
  ///
  /// In es, this message translates to:
  /// **'¡Racha de 30 días!'**
  String get streakChest30Title;

  /// No description provided for @streakChest7Message.
  ///
  /// In es, this message translates to:
  /// **'Una semana protegiendo tu identidad digital.'**
  String get streakChest7Message;

  /// No description provided for @streakChest7Title.
  ///
  /// In es, this message translates to:
  /// **'¡Racha de 7 días!'**
  String get streakChest7Title;

  /// No description provided for @streakCommitButton.
  ///
  /// In es, this message translates to:
  /// **'MANTENER MI COMPROMISO'**
  String get streakCommitButton;

  /// No description provided for @streakCurrent.
  ///
  /// In es, this message translates to:
  /// **'Racha actual'**
  String get streakCurrent;

  /// No description provided for @streakCurrentProgress.
  ///
  /// In es, this message translates to:
  /// **'Racha actual: {current} / {goal} días'**
  String streakCurrentProgress(Object goal, Object current);

  /// No description provided for @streakDayFri.
  ///
  /// In es, this message translates to:
  /// **'Vie'**
  String get streakDayFri;

  /// No description provided for @streakDayLabel.
  ///
  /// In es, this message translates to:
  /// **'días de racha'**
  String get streakDayLabel;

  /// No description provided for @streakDayMon.
  ///
  /// In es, this message translates to:
  /// **'Lu'**
  String get streakDayMon;

  /// No description provided for @streakDayOfStreak.
  ///
  /// In es, this message translates to:
  /// **'días de racha'**
  String get streakDayOfStreak;

  /// No description provided for @streakDaySat.
  ///
  /// In es, this message translates to:
  /// **'Sá'**
  String get streakDaySat;

  /// No description provided for @streakDaySun.
  ///
  /// In es, this message translates to:
  /// **'Dom'**
  String get streakDaySun;

  /// No description provided for @streakDayThu.
  ///
  /// In es, this message translates to:
  /// **'Jue'**
  String get streakDayThu;

  /// No description provided for @streakDayTue.
  ///
  /// In es, this message translates to:
  /// **'T'**
  String get streakDayTue;

  /// No description provided for @streakDayWed.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get streakDayWed;

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

  /// No description provided for @streakDaysCountPlural.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, one{# día de racha} other{# días de racha}}'**
  String streakDaysCountPlural(num count);

  /// No description provided for @streakEmotional100.
  ///
  /// In es, this message translates to:
  /// **'100 días de protección constante. Leyenda.'**
  String get streakEmotional100;

  /// No description provided for @streakEmotional14.
  ///
  /// In es, this message translates to:
  /// **'Dos semanas de constancia. Tu escudo brilla.'**
  String get streakEmotional14;

  /// No description provided for @streakEmotional3.
  ///
  /// In es, this message translates to:
  /// **'3 días seguidos. Estás construyendo un hábito sólido.'**
  String get streakEmotional3;

  /// No description provided for @streakEmotional30.
  ///
  /// In es, this message translates to:
  /// **'Un mes de aprendizaje. Tu dedicación te hace un Guardián Digital.'**
  String get streakEmotional30;

  /// No description provided for @streakEmotional50.
  ///
  /// In es, this message translates to:
  /// **'50 días de protección digital constante.'**
  String get streakEmotional50;

  /// No description provided for @streakEmotional7.
  ///
  /// In es, this message translates to:
  /// **'Una semana protegiendo tu identidad digital. ¡Sigue así!'**
  String get streakEmotional7;

  /// No description provided for @streakFireCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de racha de fuego'**
  String get streakFireCard;

  /// No description provided for @streakFireCardA11y.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta de racha de fuego'**
  String get streakFireCardA11y;

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

  /// No description provided for @streakFreezeUsed.
  ///
  /// In es, this message translates to:
  /// **'Un escudo de hielo protegió tu racha.'**
  String get streakFreezeUsed;

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

  /// No description provided for @streakKeepCommitment.
  ///
  /// In es, this message translates to:
  /// **'MANTENER MI COMPROMISO'**
  String get streakKeepCommitment;

  /// No description provided for @streakLongest.
  ///
  /// In es, this message translates to:
  /// **'Mejor racha'**
  String get streakLongest;

  /// No description provided for @streakMessage100Days.
  ///
  /// In es, this message translates to:
  /// **'100 días. Leyenda.'**
  String get streakMessage100Days;

  /// No description provided for @streakMessage14Days.
  ///
  /// In es, this message translates to:
  /// **'Dos semanas. Tu escudo brilla.'**
  String get streakMessage14Days;

  /// No description provided for @streakMessage30Days.
  ///
  /// In es, this message translates to:
  /// **'Un mes. Eres un Guardián Digital.'**
  String get streakMessage30Days;

  /// No description provided for @streakMessage3Days.
  ///
  /// In es, this message translates to:
  /// **'3 días. Buen comienzo.'**
  String get streakMessage3Days;

  /// No description provided for @streakMessage50Days.
  ///
  /// In es, this message translates to:
  /// **'50 días de protección constante.'**
  String get streakMessage50Days;

  /// No description provided for @streakMessage7Days.
  ///
  /// In es, this message translates to:
  /// **'¡Una semana! Sigue así.'**
  String get streakMessage7Days;

  /// No description provided for @streakMessageActive.
  ///
  /// In es, this message translates to:
  /// **'¡Racha activa! La constancia es tu mejor arma hoy.'**
  String get streakMessageActive;

  /// No description provided for @streakMessageAtRisk.
  ///
  /// In es, this message translates to:
  /// **'¡Tu racha está en riesgo!'**
  String get streakMessageAtRisk;

  /// No description provided for @streakMessageCloser.
  ///
  /// In es, this message translates to:
  /// **'Un día más, un paso más hacia tu meta.'**
  String get streakMessageCloser;

  /// No description provided for @streakMessageEachDay.
  ///
  /// In es, this message translates to:
  /// **'Cada día cuenta. Tu compromiso te hace más fuerte.'**
  String get streakMessageEachDay;

  /// No description provided for @streakMessageKeepGoing.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue así! La disciplina de hoy es la victoria de mañana.'**
  String get streakMessageKeepGoing;

  /// No description provided for @streakMessageKeepProtecting.
  ///
  /// In es, this message translates to:
  /// **'¡Sigue protegiéndote!'**
  String get streakMessageKeepProtecting;

  /// No description provided for @streakMessageNew.
  ///
  /// In es, this message translates to:
  /// **'¡Una nueva racha! Practica todos los días y ayuda a que crezca.'**
  String get streakMessageNew;

  /// No description provided for @streakMessageStartActivities.
  ///
  /// In es, this message translates to:
  /// **'Completa actividades para iniciar tu racha.'**
  String get streakMessageStartActivities;

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

  /// No description provided for @streakReminder.
  ///
  /// In es, this message translates to:
  /// **'Recordatorios de racha'**
  String get streakReminder;

  /// No description provided for @streakReminderSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Recibe recordatorios para mantener tu racha'**
  String get streakReminderSubtitle;

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

  /// No description provided for @streakTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Racha'**
  String get streakTitle;

  /// No description provided for @streakTitleShort.
  ///
  /// In es, this message translates to:
  /// **'Racha'**
  String get streakTitleShort;

  /// No description provided for @summarizeButton.
  ///
  /// In es, this message translates to:
  /// **'Resumen rápido'**
  String get summarizeButton;

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

  /// No description provided for @summaryGoodWork.
  ///
  /// In es, this message translates to:
  /// **'¡Buen trabajo!'**
  String get summaryGoodWork;

  /// No description provided for @summaryInterest.
  ///
  /// In es, this message translates to:
  /// **'Interés'**
  String get summaryInterest;

  /// No description provided for @summaryKeepPracticing.
  ///
  /// In es, this message translates to:
  /// **'Sigue practicando'**
  String get summaryKeepPracticing;

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

  /// No description provided for @summaryPerfect.
  ///
  /// In es, this message translates to:
  /// **'¡Perfecto!'**
  String get summaryPerfect;

  /// No description provided for @summaryReady.
  ///
  /// In es, this message translates to:
  /// **'Todo listo para empezar tu viaje en seguridad digital.'**
  String get summaryReady;

  /// No description provided for @summaryStreakDays.
  ///
  /// In es, this message translates to:
  /// **'+{days} día(s)'**
  String summaryStreakDays(Object days);

  /// No description provided for @summaryXpBonus.
  ///
  /// In es, this message translates to:
  /// **'Bonus XP'**
  String get summaryXpBonus;

  /// No description provided for @summaryXpEarned.
  ///
  /// In es, this message translates to:
  /// **'XP ganado'**
  String get summaryXpEarned;

  /// No description provided for @supporterBadge.
  ///
  /// In es, this message translates to:
  /// **'Supporter'**
  String get supporterBadge;

  /// No description provided for @syncSnackbar.
  ///
  /// In es, this message translates to:
  /// **'Progreso sincronizado'**
  String get syncSnackbar;

  /// No description provided for @syncStatus.
  ///
  /// In es, this message translates to:
  /// **'Estado de sincronización'**
  String get syncStatus;

  /// No description provided for @syncing.
  ///
  /// In es, this message translates to:
  /// **'Sincronizando...'**
  String get syncing;

  /// No description provided for @termsConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y condiciones'**
  String get termsConditions;

  /// No description provided for @thankYouForSupport.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu apoyo!'**
  String get thankYouForSupport;

  /// No description provided for @themeDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get themeDark;

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

  /// No description provided for @themeLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeLightLabel.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get themeLightLabel;

  /// No description provided for @themeSystem.
  ///
  /// In es, this message translates to:
  /// **'Según el sistema'**
  String get themeSystem;

  /// No description provided for @themeSystemLabel.
  ///
  /// In es, this message translates to:
  /// **'Sistema'**
  String get themeSystemLabel;

  /// No description provided for @themeTitle.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get themeTitle;

  /// No description provided for @tierBasic.
  ///
  /// In es, this message translates to:
  /// **'Básico'**
  String get tierBasic;

  /// No description provided for @tierCrystal.
  ///
  /// In es, this message translates to:
  /// **'Cristal'**
  String get tierCrystal;

  /// No description provided for @tierGlow.
  ///
  /// In es, this message translates to:
  /// **'Brillo'**
  String get tierGlow;

  /// No description provided for @tierInactive.
  ///
  /// In es, this message translates to:
  /// **'Inactivo'**
  String get tierInactive;

  /// No description provided for @tierLegendary.
  ///
  /// In es, this message translates to:
  /// **'Legendario'**
  String get tierLegendary;

  /// No description provided for @tierParticles.
  ///
  /// In es, this message translates to:
  /// **'Partículas'**
  String get tierParticles;

  /// No description provided for @totalProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso total'**
  String get totalProgress;

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

  /// No description provided for @tutorTitle.
  ///
  /// In es, this message translates to:
  /// **'Tutor IA'**
  String get tutorTitle;

  /// No description provided for @tutorialNext.
  ///
  /// In es, this message translates to:
  /// **'Siguiente'**
  String get tutorialNext;

  /// No description provided for @tutorialSkip.
  ///
  /// In es, this message translates to:
  /// **'Omitir'**
  String get tutorialSkip;

  /// No description provided for @tutorialStart.
  ///
  /// In es, this message translates to:
  /// **'¡Vamos!'**
  String get tutorialStart;

  /// No description provided for @tutorialStep1.
  ///
  /// In es, this message translates to:
  /// **'¡Hola! Soy Sage, tu guía de ciberseguridad.'**
  String get tutorialStep1;

  /// No description provided for @tutorialStep2.
  ///
  /// In es, this message translates to:
  /// **'Completa lecciones para ganar donaciones y subir de nivel.'**
  String get tutorialStep2;

  /// No description provided for @tutorialStep3.
  ///
  /// In es, this message translates to:
  /// **'Mantén tu racha diaria para desbloquear cofres especiales.'**
  String get tutorialStep3;

  /// No description provided for @tutorialStep4.
  ///
  /// In es, this message translates to:
  /// **'Tu misión: protege tu identidad digital. ¡Aprendamos juntos!'**
  String get tutorialStep4;

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

  /// No description provided for @updateNew.
  ///
  /// In es, this message translates to:
  /// **'NUEVO'**
  String get updateNew;

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

  /// No description provided for @updateTypeFeature.
  ///
  /// In es, this message translates to:
  /// **'NUEVA FUNCIÓN'**
  String get updateTypeFeature;

  /// No description provided for @updateTypeFix.
  ///
  /// In es, this message translates to:
  /// **'CORRECCIÓN'**
  String get updateTypeFix;

  /// No description provided for @updateTypeImprovement.
  ///
  /// In es, this message translates to:
  /// **'MEJORA'**
  String get updateTypeImprovement;

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

  /// No description provided for @updates.
  ///
  /// In es, this message translates to:
  /// **'Actualizaciones'**
  String get updates;

  /// No description provided for @updatesTitle.
  ///
  /// In es, this message translates to:
  /// **'Noticias y actualizaciones'**
  String get updatesTitle;

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

  /// No description provided for @viewAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todo'**
  String get viewAll;

  /// No description provided for @weeklyChestComplete.
  ///
  /// In es, this message translates to:
  /// **'¡Cofre semanal obtenido!'**
  String get weeklyChestComplete;

  /// No description provided for @weeklyChestDesc.
  ///
  /// In es, this message translates to:
  /// **'Completa 5 misiones diarias para un cofre épico'**
  String get weeklyChestDesc;

  /// No description provided for @weeklyChestProgress.
  ///
  /// In es, this message translates to:
  /// **'Progreso del cofre semanal'**
  String get weeklyChestProgress;

  /// No description provided for @weeklyChestProgressCount.
  ///
  /// In es, this message translates to:
  /// **'{done}/{total}'**
  String weeklyChestProgressCount(Object done, Object total);

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

  /// No description provided for @wizardHowDidYouFind.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te enteraste de SAGEN?'**
  String get wizardHowDidYouFind;

  /// No description provided for @wizardHowDidYouFindSage.
  ///
  /// In es, this message translates to:
  /// **'Dime, ¿cómo nos encontraste?'**
  String get wizardHowDidYouFindSage;

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

  /// No description provided for @wizardHowMuchSage.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto sabes sobre el tema?'**
  String get wizardHowMuchSage;

  /// No description provided for @wizardHowMuchYouKnow.
  ///
  /// In es, this message translates to:
  /// **'¿Cuánto sabes sobre seguridad digital?'**
  String get wizardHowMuchYouKnow;

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

  /// No description provided for @wizardWelcome.
  ///
  /// In es, this message translates to:
  /// **'¡Bienvenido a SAGEN!'**
  String get wizardWelcome;

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

  /// No description provided for @xpBoostLabel.
  ///
  /// In es, this message translates to:
  /// **'x2 Boost de XP'**
  String get xpBoostLabel;

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

  /// No description provided for @xpRewardLabel.
  ///
  /// In es, this message translates to:
  /// **'+{gems} XP'**
  String xpRewardLabel(Object gems);

  /// No description provided for @yourActivity.
  ///
  /// In es, this message translates to:
  /// **'Tu actividad'**
  String get yourActivity;

  /// No description provided for @yourLearning.
  ///
  /// In es, this message translates to:
  /// **'Tu aprendizaje'**
  String get yourLearning;

  /// No description provided for @xpLabel.
  ///
  /// In es, this message translates to:
  /// **'XP'**
  String get xpLabel;

  /// No description provided for @xpMultiplier.
  ///
  /// In es, this message translates to:
  /// **'x2 XP'**
  String get xpMultiplier;

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

  /// No description provided for @errorSync.
  ///
  /// In es, this message translates to:
  /// **'Error de sincronización'**
  String get errorSync;

  /// No description provided for @shareChestText.
  ///
  /// In es, this message translates to:
  /// **'¡Obtuve {items} de un cofre {type} en SAGEN!'**
  String shareChestText(Object items, Object type);

  /// No description provided for @paymentMethodsLocal.
  ///
  /// In es, this message translates to:
  /// **'WhatsApp / Yape / Plin'**
  String get paymentMethodsLocal;

  /// No description provided for @paymentMethodsMercadoPago.
  ///
  /// In es, this message translates to:
  /// **'Mercado Pago'**
  String get paymentMethodsMercadoPago;

  /// No description provided for @streakFlame.
  ///
  /// In es, this message translates to:
  /// **'Llama de racha'**
  String get streakFlame;

  /// No description provided for @treasureChest.
  ///
  /// In es, this message translates to:
  /// **'Cofre del tesoro {type}'**
  String treasureChest(Object type);

  /// No description provided for @errorRestart.
  ///
  /// In es, this message translates to:
  /// **'Reiniciar'**
  String get errorRestart;

  /// No description provided for @chatEmptyDesc.
  ///
  /// In es, this message translates to:
  /// **'Pregunta sobre ciberseguridad o elige una sugerencia rápida.'**
  String get chatEmptyDesc;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @shareButton.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get shareButton;

  /// No description provided for @tapToContinue.
  ///
  /// In es, this message translates to:
  /// **'Toca para continuar'**
  String get tapToContinue;

  /// No description provided for @paymentSuccessful.
  ///
  /// In es, this message translates to:
  /// **'Pago exitoso'**
  String get paymentSuccessful;

  /// No description provided for @errorLoadingQuestions.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar preguntas.'**
  String get errorLoadingQuestions;

  /// No description provided for @errorGenericShort.
  ///
  /// In es, this message translates to:
  /// **'Error'**
  String get errorGenericShort;

  /// Live region announcing the remaining quiz time to screen readers.
  ///
  /// In es, this message translates to:
  /// **'Tiempo restante: {time}'**
  String quizTimeRemaining(Object time);

  /// Live region announcing a correct answer to screen readers.
  ///
  /// In es, this message translates to:
  /// **'Respuesta correcta'**
  String get quizVerdictCorrect;

  /// Live region announcing an incorrect answer to screen readers.
  ///
  /// In es, this message translates to:
  /// **'Respuesta incorrecta'**
  String get quizVerdictIncorrect;

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

  /// No description provided for @xpGainedLabel.
  ///
  /// In es, this message translates to:
  /// **'+{xp} experiencia ganada'**
  String xpGainedLabel(Object xp);

  /// No description provided for @accuracyPercentLabel.
  ///
  /// In es, this message translates to:
  /// **'Precisión: {percent}%'**
  String accuracyPercentLabel(Object percent);

  /// No description provided for @timeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tiempo: {time}'**
  String timeLabel(Object time);

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
