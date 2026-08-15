// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutSage => 'À propos de Sage';

  @override
  String get aboutSection => 'À propos';

  @override
  String get achievementConqueror => 'Conquérant';

  @override
  String get achievementConquerorDesc => 'Terminez votre première étape';

  @override
  String get achievementConstant => 'Constant';

  @override
  String get achievementConstantDesc => '3 jours de série';

  @override
  String get achievementCurious => 'Curieux';

  @override
  String get achievementCuriousDesc => 'Parlez à Sage 10 fois';

  @override
  String get achievementCyberGuardian => 'Cyber Gardien';

  @override
  String get achievementCyberGuardianDesc => 'Terminez 50 leçons';

  @override
  String get achievementDigitalMaster => 'Maître Numérique';

  @override
  String get achievementDigitalMasterDesc => 'Terminez toutes les étapes';

  @override
  String get achievementDigitalStudent => 'Étudiant Numérique';

  @override
  String get achievementDigitalStudentDesc => 'Terminez 10 leçons';

  @override
  String get achievementDigitalWeek => 'Semaine Numérique';

  @override
  String get achievementDigitalWeekDesc => '7 jours de série';

  @override
  String get achievementFirstShield => 'Premier Bouclier';

  @override
  String get achievementFirstShieldDesc => 'Terminez votre première leçon';

  @override
  String get achievementGuardian => 'Gardien';

  @override
  String get achievementGuardianDesc => 'Terminez 25 leçons';

  @override
  String get achievementLearner => 'Apprenant';

  @override
  String get achievementLearnerDesc => 'Terminez 5 leçons';

  @override
  String get achievementLegendaryStreak => 'Série Légendaire';

  @override
  String get achievementLegendaryStreakDesc => '30 jours de série';

  @override
  String get achievementLocked => '???';

  @override
  String get achievementPerfect => 'Parfait';

  @override
  String get achievementPerfectDesc => 'Terminez une leçon sans erreurs';

  @override
  String get acquired => 'Acquis';

  @override
  String get adminCreditDonationA11y => 'Créditer des dons';

  @override
  String get adminCreditDonationButton => 'Créditer des dons';

  @override
  String adminCreditDonationSuccess(Object gems, Object userId) {
    return '$gems dons crédités à $userId';
  }

  @override
  String get adminCreditDonationTitle => 'Admin — Créditer des dons';

  @override
  String get adminCreditError =>
      'Erreur de crédit. Vérifiez que votre utilisateur est dans la collection \"admins\" de Firestore.';

  @override
  String adminCreditSuccessNotification(Object gems, Object userId) {
    return '$gems dons crédités à $userId';
  }

  @override
  String get adminDonations => 'Dons';

  @override
  String get adminFieldAmount => 'Montant';

  @override
  String get adminFieldDonationAmount => 'Montant du don';

  @override
  String get adminFieldUserId => 'User ID';

  @override
  String get adminInvalidInput => 'Entrez un User ID valide et un montant';

  @override
  String get adminMercadoPago => 'Mercado Pago';

  @override
  String get adminPaymentMethod => 'Mode de paiement';

  @override
  String get adminTitle => 'Admin — Créditer des dons';

  @override
  String get adminUserId => 'ID Utilisateur';

  @override
  String get adminVerifyingPermissions => 'Vérification des permissions admin…';

  @override
  String get adminWhatsapp => 'WhatsApp / Yape / Plin';

  @override
  String get analyzeFile => 'Analyser le fichier';

  @override
  String get analyzeLink => 'Analyser le lien';

  @override
  String get analyzing => 'Analyse en cours...';

  @override
  String get appName => 'SAGEN';

  @override
  String get appSlogan => 'Votre bouclier numérique';

  @override
  String get authAge => 'Âge';

  @override
  String get authBack => 'Retour';

  @override
  String get authCanceled => 'Connexion annulée';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authCreateAccountError => 'Erreur de création de compte';

  @override
  String get authCredentialExpired =>
      'Session expirée. Connectez-vous à nouveau.';

  @override
  String get authDefault => 'Erreur d\'authentification';

  @override
  String get authDeleteAccountFailed =>
      'Impossible de supprimer le compte. Réessayez.';

  @override
  String get authEmailError => 'Entrez votre e-mail';

  @override
  String get authEmailInUse => 'Un compte existe déjà avec cet e-mail';

  @override
  String get authEmailInvalid => 'E-mail invalide';

  @override
  String get authEmailLabel => 'E-mail';

  @override
  String get authEmailVerificationSent =>
      'Vérifiez votre e-mail pour confirmer votre compte';

  @override
  String get authEnterEmailError => 'Entrez votre e-mail';

  @override
  String get authFacebookButton => 'Continuer avec Facebook';

  @override
  String get authFacebookError => 'Erreur de connexion avec Facebook';

  @override
  String get authFirebaseUnavailable => 'Firebase n\'est pas disponible';

  @override
  String get authForgotPasswordButton => 'RÉINITIALISER LE MOT DE PASSE';

  @override
  String get authForgotPasswordDesc =>
      'Nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get authForgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authGoogleButton => 'Continuer avec Google';

  @override
  String get authGoogleError => 'Erreur de connexion avec Google';

  @override
  String get authHaveAccount => 'Vous avez déjà un compte? ';

  @override
  String get authInvalidCredential => 'E-mail ou mot de passe incorrect';

  @override
  String get authInvalidEmail => 'Format d\'e-mail invalide';

  @override
  String get authLoginButton => 'SE CONNECTER';

  @override
  String get authLoginError => 'Erreur de connexion';

  @override
  String get authLoginLink => 'Se connecter';

  @override
  String get authLoginTitle => 'Entrez vos informations';

  @override
  String get authNameError => 'Entrez votre nom';

  @override
  String get authNetworkError => 'Pas de connexion internet';

  @override
  String get authNoAccount => 'Vous n\'avez pas de compte? ';

  @override
  String get authNotAuthenticated => 'Aucun utilisateur authentifié';

  @override
  String get authNotFound => 'Aucun compte trouvé avec cet e-mail';

  @override
  String get authNotFoundCancel => 'Annuler';

  @override
  String get authNotFoundCreate => 'Créer un compte';

  @override
  String authNotFoundMessage(Object email) {
    return 'Aucun compte n\'est enregistré avec $email. Voulez-vous créer un nouveau compte et commencer à apprendre ?';
  }

  @override
  String get authNotFoundTitle => 'Compte non trouvé';

  @override
  String get authNotVerified =>
      'Vous n\'avez pas encore vérifié votre e-mail. Vérifiez votre boîte de réception.';

  @override
  String get authNullToken => 'Impossible d\'obtenir le jeton Facebook';

  @override
  String get authNullUser => 'Impossible d\'obtenir l\'utilisateur';

  @override
  String get authOrRegisterWith => 'ou inscrivez-vous avec';

  @override
  String get authPasswordError => 'Entrez votre mot de passe';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordMinError =>
      'Le mot de passe doit comporter 8+ caractères avec majuscule, minuscule et un chiffre';

  @override
  String get authPasswordMinHint => 'Mot de passe (8+ car., A-Z, a-z, 0-9)';

  @override
  String get authPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get authPrivacy => 'Vos informations sont protégées.';

  @override
  String get authRateLimited =>
      'Trop de tentatives. Veuillez patienter quelques secondes.';

  @override
  String get authReauthError =>
      'Impossible de vérifier les identifiants. Réessayez.';

  @override
  String get authReauthRequiredForDelete =>
      'Veuillez entrer votre mot de passe pour supprimer votre compte.';

  @override
  String get authRecoveryEmailSentDesc =>
      'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.';

  @override
  String get authRecoveryEmailSentMessage => 'E-mail de récupération envoyé';

  @override
  String get authRecoveryEmailSentTitle => 'E-mail envoyé';

  @override
  String get authRecoveryError =>
      'Impossible d\'envoyer l\'e-mail de récupération';

  @override
  String get authRegisterFacebookError => 'Erreur d\'inscription avec Facebook';

  @override
  String get authRegisterGoogleError => 'Erreur d\'inscription avec Google';

  @override
  String get authRegisterTitle => 'Créez votre compte';

  @override
  String get authResendEmailError =>
      'Impossible de renvoyer l\'e-mail de vérification';

  @override
  String get authSendEmailError => 'Erreur d\'envoi d\'e-mail';

  @override
  String get authSendLink => 'Envoyer le lien';

  @override
  String get authSubtitle =>
      'Apprenez, protégez-vous et naviguez plus sûrement sur internet.';

  @override
  String get authTitle => 'Votre protection numérique commence ici';

  @override
  String get authTokenExpired => 'Session expirée. Connectez-vous à nouveau.';

  @override
  String get authTooManyRequests => 'Trop de tentatives. Veuillez patienter.';

  @override
  String get authUnknown => 'Une erreur inattendue s\'est produite';

  @override
  String get authVerifyError => 'Impossible de vérifier. Réessayez.';

  @override
  String get authWeakPassword =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get authWrongPassword => 'Mot de passe incorrect';

  @override
  String get back => 'Retour';

  @override
  String get backButton => 'Retour';

  @override
  String get biometricPrompt => 'Déverrouillez SAGEN pour continuer';

  @override
  String get biometricReason => 'Déverrouillez SAGEN pour continuer';

  @override
  String get cancel => 'Annuler';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get careerCertifications => 'Certifications';

  @override
  String get careerDescription =>
      'Obtenez des certifications et développez des compétences qui vous rendent précieux dans l\'économie numérique.';

  @override
  String get careerOpp1 => 'Consultant en Sécurité Numérique';

  @override
  String get careerOpp1Desc => 'Aidez les entreprises à protéger leurs données';

  @override
  String get careerOpp2 => 'Formateur en Sensibilisation';

  @override
  String get careerOpp2Desc =>
      'Apprenez aux autres à rester en sécurité en ligne';

  @override
  String get careerOpp3 => 'Auditeur de Sécurité Freelance';

  @override
  String get careerOpp3Desc => 'Proposez des audits de sécurité à des clients';

  @override
  String get careerOpportunities => 'Opportunités Économiques';

  @override
  String get careerSkill1 => 'Sécurité des Mots de Passe';

  @override
  String get careerSkill2 => 'Détection du Phishing';

  @override
  String get careerSkill3 => 'Protection de la Vie Privée';

  @override
  String get careerSkill4 => 'Sécurité des Réseaux';

  @override
  String get careerSkill5 => 'Réponse aux Incidents';

  @override
  String get careerSkills => 'Compétences que vous développez';

  @override
  String get careerSubtitle => 'Votre parcours professionnel en cybersécurité';

  @override
  String get careerTitle => 'Carrière et Certifications';

  @override
  String get challengeComplete => 'Complétez la phrase';

  @override
  String get challengeCreatePassword => 'Créer un mot de passe';

  @override
  String get challengeDetectRisk => 'Détecter le risque';

  @override
  String get challengeMiniCase => 'Cas réel';

  @override
  String get challengeMultiple => 'Choix multiple';

  @override
  String get challengeSafe => 'Sûr';

  @override
  String get challengeSuspicious => 'Suspect';

  @override
  String get challengeTrueFalse => 'Vrai / Faux';

  @override
  String get challengeWhatWouldYouDo => 'Que feriez-vous ici?';

  @override
  String challenge_analyze_link_desc(Object count) {
    return 'Analysez $count lien(s)';
  }

  @override
  String get challenge_analyze_link_title => 'Analyser des Liens';

  @override
  String challenge_answer_questions_desc(Object count) {
    return 'Répondez à $count question(s)';
  }

  @override
  String get challenge_answer_questions_title => 'Répondre aux Questions';

  @override
  String challenge_check_in_desc(Object count) {
    return 'Enregistrez-vous $count fois';
  }

  @override
  String get challenge_check_in_title => 'Pointage Quotidien';

  @override
  String challenge_complete_lesson_desc(Object count) {
    return 'Terminez $count leçon(s)';
  }

  @override
  String get challenge_complete_lesson_title => 'Terminer des Leçons';

  @override
  String challenge_complete_session_desc(Object count) {
    return 'Terminez $count session(s)';
  }

  @override
  String get challenge_complete_session_title => 'Sessions d\'Apprentissage';

  @override
  String get challenge_complete_stage_desc => 'Terminez 1 étape';

  @override
  String get challenge_complete_stage_title => 'Terminer une Étape';

  @override
  String challenge_correct_streak_desc(Object count) {
    return 'Obtenez $count bonnes réponses à la suite';
  }

  @override
  String get challenge_correct_streak_title => 'Série Correcte';

  @override
  String challenge_detect_phishing_desc(Object count) {
    return 'Détectez $count tentative(s) de phishing';
  }

  @override
  String get challenge_detect_phishing_title => 'Détecter le Phishing';

  @override
  String challenge_earn_xp_desc(Object xp) {
    return 'Gagnez $xp XP';
  }

  @override
  String get challenge_earn_xp_title => 'Gagner de l\'XP';

  @override
  String challenge_learn_minutes_desc(Object count) {
    return 'Apprenez pendant $count minutes';
  }

  @override
  String get challenge_learn_minutes_title => 'Temps d\'Apprentissage';

  @override
  String challenge_learn_topic_desc(Object count) {
    return 'Apprenez $count sujet(s)';
  }

  @override
  String get challenge_learn_topic_title => 'Apprendre un Sujet';

  @override
  String get challenge_perfect_lesson_desc => 'Terminez une leçon sans erreurs';

  @override
  String get challenge_perfect_lesson_title => 'Leçon Parfaite';

  @override
  String challenge_privacy_check_desc(Object count) {
    return 'Vérifiez les paramètres de confidentialité $count fois';
  }

  @override
  String get challenge_privacy_check_title => 'Vérification de la Vie Privée';

  @override
  String challenge_quiz_night_desc(Object count) {
    return 'Terminez $count mini quiz';
  }

  @override
  String get challenge_quiz_night_title => 'Mini Quiz';

  @override
  String challenge_review_tips_desc(Object count) {
    return 'Révisez $count conseil(s) de sécurité';
  }

  @override
  String get challenge_review_tips_title => 'Revoir les Conseils';

  @override
  String challenge_security_audit_desc(Object count) {
    return 'Terminez $count audit(s) de sécurité';
  }

  @override
  String get challenge_security_audit_title => 'Audit de Sécurité';

  @override
  String challenge_share_knowledge_desc(Object count) {
    return 'Partagez $count conseil(s)';
  }

  @override
  String get challenge_share_knowledge_title => 'Partager le Savoir';

  @override
  String challenge_social_awareness_desc(Object count) {
    return 'Terminez $count défi(s) de conscience sociale';
  }

  @override
  String get challenge_social_awareness_title => 'Conscience Sociale';

  @override
  String challenge_streak_milestone_desc(Object count) {
    return 'Maintenez une série de $count jours';
  }

  @override
  String get challenge_streak_milestone_title => 'Jalon de Série';

  @override
  String challenge_talk_sage_desc(Object count) {
    return 'Discutez avec Sage $count fois';
  }

  @override
  String get challenge_talk_sage_title => 'Discuter avec Sage';

  @override
  String challenge_test_password_desc(Object count) {
    return 'Testez $count mot(s) de passe';
  }

  @override
  String get challenge_test_password_title => 'Tester les Mots de Passe';

  @override
  String get challenge_use_dark_mode_desc => 'Utiliser le mode sombre';

  @override
  String get challenge_use_dark_mode_title => 'Mode Sombre';

  @override
  String get changelogV4 => 'Fondation';

  @override
  String get changelogV4_1 => '8 étapes d\'apprentissage avec 1 099 leçons';

  @override
  String get changelogV4_2 => 'Série et défis quotidiens';

  @override
  String get changelogV4_3 => 'Système de succès';

  @override
  String get changelogV5 => 'IA et Personnalisation';

  @override
  String get changelogV5Old => 'Système de Coffres et Gacha';

  @override
  String get changelogV5Old_1 =>
      'Système d\'évolution des coffres (Bronze → Légendaire)';

  @override
  String get changelogV5Old_2 => 'Boutons 3D interactifs';

  @override
  String get changelogV5Old_3 => 'Refonte UI avec Glassmorphism';

  @override
  String get changelogV5_1 => 'Chat SAGE avec IA pour une aide personnalisée';

  @override
  String get changelogV5_2 => 'Émotions dynamiques du masque';

  @override
  String get changelogV5_3 => '17 157 questions de cybersécurité';

  @override
  String get changelogV5_4 => 'Société VIP pour les séries de 30+ jours';

  @override
  String get chatAskSage => 'Demandez à Sage';

  @override
  String get chatAskSageDesc =>
      'Posez toute question sur la cybersécurité ou choisissez une suggestion rapide.';

  @override
  String get chatBlocked => 'Chat bloqué';

  @override
  String get chatCancel => 'Annuler';

  @override
  String get chatClear => 'Effacer';

  @override
  String get chatClearAction => 'Effacer';

  @override
  String get chatClearMessage =>
      'Êtes-vous sûr de vouloir effacer cette conversation ? Cette action est irréversible.';

  @override
  String get chatClearTitle => 'Effacer la conversation';

  @override
  String get chatEmptyTitle => 'Démarrez une conversation';

  @override
  String get chatFallback => 'Je n\'ai pas pu répondre maintenant. Réessayez.';

  @override
  String get chatFallbackSubtitle =>
      'Posez une question sur la cybersécurité ou choisissez une suggestion rapide.';

  @override
  String get chatFallbackTitle => 'Demande à Sage';

  @override
  String get chatGuideDesc => 'Votre guide en cybersécurité';

  @override
  String get chatGuideSubtitle => 'Votre guide en cybersécurité';

  @override
  String get chatHint => 'Demandez à Sage...';

  @override
  String get chatInputHint => 'Demande à Sage...';

  @override
  String get chatNewConversation => 'Nouvelle conversation';

  @override
  String get chatSageTutor => 'Sage Tutor';

  @override
  String get chatSageTutorLabel => 'Tuteur Sage';

  @override
  String get checkInDesc => 'Pointage quotidien pour garder votre série active';

  @override
  String get checkInTitle => 'Pointage';

  @override
  String get chestCollect => 'Collecter';

  @override
  String chestEvolvedTo(Object type) {
    return 'Évolué en $type';
  }

  @override
  String get chestNoChange => 'Aucun changement';

  @override
  String chestOpenedTitle(Object type) {
    return 'Coffre $type!';
  }

  @override
  String get chestPityProgress => 'Légendaire dans';

  @override
  String get chestReminder => 'Rappels de coffre';

  @override
  String get chestReminderSubtitle =>
      'Recevez des rappels pour ouvrir votre coffre quotidien';

  @override
  String get chestRewardBronze => 'Bronze !';

  @override
  String get chestRewardDefault => 'Récompense';

  @override
  String get chestRewardDialog => 'Dialogue de récompense du coffre';

  @override
  String get chestRewardGold => 'Or !';

  @override
  String get chestRewardLegendary => 'Légendaire !';

  @override
  String get chestRewardSilver => 'Argent !';

  @override
  String get chestTapToOpen => 'Touchez pour ouvrir';

  @override
  String get chestTapToUpgrade => 'Touchez pour améliorer';

  @override
  String chestTitle(Object type) {
    return 'Coffre $type';
  }

  @override
  String chestTreasure(Object type) {
    return 'Coffre au trésor $type';
  }

  @override
  String chestTreasureLabel(Object type) {
    return 'Trésor $type';
  }

  @override
  String get chestTypeBronze => 'Bronze';

  @override
  String get chestTypeGold => 'Or';

  @override
  String get chestTypeLegendary => 'Légendaire';

  @override
  String get chestTypeSilver => 'Argent';

  @override
  String get chestXpBoost => 'x2 EXP';

  @override
  String get closeButton => 'Fermer';

  @override
  String get cloudDataDeleted => 'Données cloud supprimées';

  @override
  String get cloudSync => 'Cloud et synchronisation';

  @override
  String get commit1Month => '1 mois';

  @override
  String get commit1Week => '1 semaine';

  @override
  String get commit2Weeks => '2 semaines';

  @override
  String get commitButton => 'M\'ENGAGER ENVERS MON OBJECTIF';

  @override
  String get commitChooseGoal => 'Choisissez votre objectif';

  @override
  String get commitChooseGoalDesc =>
      'Sélectionnez combien de jours vous suivrez votre plan d\'apprentissage.';

  @override
  String commitDays(Object days) {
    return '$days jours';
  }

  @override
  String commitGoalLabel(Object days) {
    return 'Votre objectif: $days jours';
  }

  @override
  String get commitSelected => 'SÉLECTIONNÉ';

  @override
  String commitYourGoal(Object days) {
    return 'Votre objectif: $days jours';
  }

  @override
  String get completePrevious => 'Terminez l\'étape précédente';

  @override
  String get connectionErrorRetry => 'Erreur de connexion. Réessayez.';

  @override
  String continueLesson(Object title) {
    return 'Continuer la leçon: $title';
  }

  @override
  String get continueText => 'Continuer';

  @override
  String get correct => 'Correct';

  @override
  String get correctAnswer => 'Bonne réponse';

  @override
  String correctAnswers(Object correct, Object total) {
    return '$correct sur $total correctes';
  }

  @override
  String get currencySymbol => '€';

  @override
  String cyberQuizProgress(Object current, Object total) {
    return 'Question $current sur $total';
  }

  @override
  String get dailyGoalIntense => 'Intense';

  @override
  String dailyGoalMinutesPerDay(Object minutes) {
    return '$minutes min/jour';
  }

  @override
  String get dailyGoalNormal => 'Normal';

  @override
  String get dailyGoalQuestion =>
      'Quel est votre objectif d\'apprentissage quotidien ?';

  @override
  String get dailyGoalRelaxed => 'Décontracté';

  @override
  String get dailyGoalSerious => 'Sérieux';

  @override
  String get dailyMissions => 'Missions quotidiennes';

  @override
  String get dailyMissionsAllCompleted =>
      'Tous les défis terminés aujourd\'hui !';

  @override
  String get dailyMissionsDesc =>
      'Complétez vos missions pour gagner des récompenses';

  @override
  String get darkModeEnd => 'Fin du mode sombre';

  @override
  String darkModeScheduleInfo(Object end, Object start) {
    return 'Le mode sombre sera actif de $start:00 à $end:00';
  }

  @override
  String get darkModeStart => 'Début du mode sombre';

  @override
  String get dayAbbrFri => 'Ven';

  @override
  String get dayAbbrMon => 'Lun';

  @override
  String get dayAbbrSat => 'Sam';

  @override
  String get dayAbbrSun => 'Dim';

  @override
  String get dayAbbrThu => 'Jeu';

  @override
  String get dayAbbrTue => 'Mar';

  @override
  String get dayAbbrWed => 'Mer';

  @override
  String get dayShortFri => 'V';

  @override
  String get dayShortMon => 'L';

  @override
  String weekDayCompleted(Object day) {
    return '$day, terminé';
  }

  @override
  String weekDayToday(Object day) {
    return 'Aujourd\'hui, $day';
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
  String get daysLabel => 'jours';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteAccountConfirm => 'Supprimer mon compte';

  @override
  String get deleteAccountDesc =>
      'Cela supprimera définitivement toutes vos données. Cette action est irréversible.';

  @override
  String get deleteAccountReauthRequired =>
      'Authentification récente requise pour supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAction => 'Supprimer';

  @override
  String get deleteCloudData => 'Supprimer les données cloud';

  @override
  String get deleteCloudDesc =>
      'Êtes-vous sûr? Cette action supprimera définitivement votre progression sauvegardée dans le cloud. Les données locales ne seront pas affectées.';

  @override
  String get deleteCloudTitle => 'Supprimer les données cloud';

  @override
  String get deleteHistory => 'Supprimer l\'historique d\'analyse';

  @override
  String get deleteHistoryDesc =>
      'Toutes les analyses de liens sauvegardées seront supprimées. Cette action est irréversible.';

  @override
  String get deleteHistoryTitle => 'Supprimer l\'historique';

  @override
  String get demoModeLabel => 'MODE DÉMO';

  @override
  String get demoStudentName => 'Étudiant démo';

  @override
  String get developedWith => 'Développé avec Flutter';

  @override
  String get donateToSupport => 'Don pour soutenir';

  @override
  String get donationBasic => 'Supporter';

  @override
  String get donationBasicDesc => 'Aidez-nous à garder SAGEN gratuit';

  @override
  String get donationLabel => 'Don';

  @override
  String get donationPopular => 'Super Supporter';

  @override
  String get donationPopularDesc => 'Badge exclusif + remerciement spécial';

  @override
  String get donationPremium => 'Champion';

  @override
  String get donationPremiumDesc =>
      'Tous les avantages + votre nom dans les crédits';

  @override
  String get donationValueLabel => 'Montant';

  @override
  String dot(Object number) {
    return 'Point $number';
  }

  @override
  String get ecoCo2Saved => 'Émissions de CO₂ évitées';

  @override
  String get ecoComparison =>
      'SAGEN utilise 99% de ressources en moins que l\'éducation traditionnelle';

  @override
  String get ecoDescription =>
      'Chaque leçon que vous terminez économise de l\'eau, réduit les émissions de CO₂ et élimine l\'utilisation de papier.';

  @override
  String get ecoDigital => '📱 Numérique: juste votre téléphone';

  @override
  String get ecoDigitalLearning => 'Apprentissage 100% Numérique';

  @override
  String get ecoDigitalLearningDesc =>
      'Pas de papier, pas d\'impression, pas de transport nécessaire';

  @override
  String get ecoHowItWorks => 'Numérique vs Traditionnel';

  @override
  String get ecoLiters => 'litres';

  @override
  String get ecoPages => 'pages';

  @override
  String get ecoPaperSaved => 'Papier économisé';

  @override
  String get ecoSubtitle => 'Apprendre en prenant soin de la planète';

  @override
  String get ecoTitle => 'Impact Écologique';

  @override
  String get ecoTraditional => '📚 Traditionnel: papier, encre, transport';

  @override
  String get ecoTrees => 'arbres';

  @override
  String get ecoTreesEquivalent => 'Équivalent en arbres';

  @override
  String get ecoWaterSaved => 'Eau économisée';

  @override
  String get ecoYourImpact => 'Votre impact environnemental';

  @override
  String get emotionPhrase1 => 'Tu détectes les risques plus vite.';

  @override
  String get emotionPhrase2 => 'Ton habitude numérique s\'améliore.';

  @override
  String get emotionPhrase3 =>
      'Chaque jour tu comprends mieux comment te protéger.';

  @override
  String get emotionPhrase4 => 'Tu construis un instinct de sécurité.';

  @override
  String get emotionPhrase5 => 'Ton jugement numérique s\'affûte.';

  @override
  String get emotionPhrase6 =>
      'Tu apprends à voir ce que les autres ne voient pas.';

  @override
  String get emotionPhrase7 => 'Ton monde numérique est plus sûr grâce à toi.';

  @override
  String get emotionPhraseStart =>
      'Ton voyage numérique commence aujourd\'hui.';

  @override
  String get emotionalPhrase1 =>
      'Vous détectez les risques plus rapidement maintenant.';

  @override
  String get emotionalPhrase2 => 'Votre habitude digitale s\'améliore.';

  @override
  String get emotionalPhrase3 =>
      'Chaque jour vous comprenez mieux comment vous protéger.';

  @override
  String get emotionalPhrase4 => 'Vous construisez un instinct de sécurité.';

  @override
  String get emotionalPhrase5 => 'Votre jugement digital s\'affûte.';

  @override
  String get emotionalPhrase6 =>
      'Vous apprenez à voir ce que les autres ne voient pas.';

  @override
  String get emotionalPhrase7 =>
      'Votre monde digital est plus sûr grâce à vous.';

  @override
  String get emotionalPhraseStart =>
      'Votre voyage digital commence aujourd\'hui.';

  @override
  String get emptyChatSubtitle => 'Sage est prêt à vous aider';

  @override
  String get emptyProfile => 'Pas de données de profil';

  @override
  String get emptyStore => 'La boutique est vide';

  @override
  String get emptyUpdates => 'Aucune mise à jour disponible';

  @override
  String get english => 'Anglais';

  @override
  String get errorContentLoadFailed =>
      'Nous n\'avons pas pu charger le contenu. Vérifiez votre connexion et réessayez.';

  @override
  String get errorFeedback => 'Échec de la sauvegarde du feedback. Réessayez.';

  @override
  String get errorGeneric => 'Quelque chose s\'est mal passé. Réessayez.';

  @override
  String get errorIntegrityCheck =>
      'Un problème d\'intégrité a été détecté. Votre progression a été conservée, mais veuillez vérifier qu\'elle est correcte.';

  @override
  String get errorLoadContent =>
      'Impossible de charger le contenu. Vérifiez votre connexion et réessayez.';

  @override
  String get errorLoadProgress =>
      'Impossible de charger votre progression. Vérifiez votre connexion et réessayez.';

  @override
  String get errorLoadQuestions =>
      'Échec du chargement des questions. Réessayez.';

  @override
  String get errorNetwork =>
      'Pas de connexion internet. Vérifiez votre réseau.';

  @override
  String get errorPayment =>
      'Échec de l\'enregistrement du paiement. Réessayez.';

  @override
  String get errorProgressLoadFailed =>
      'Nous n\'avons pas pu charger vos progrès. Vérifiez votre connexion et réessayez.';

  @override
  String get errorProgressReloadFailed =>
      'Nous n\'avons pas pu recharger vos progrès. Réessayez.';

  @override
  String get errorReloadProgress =>
      'Impossible de recharger votre progression. Réessayez.';

  @override
  String get errorRestartApp => 'Redémarrer l\'application';

  @override
  String get errorRetry => 'Réessayer';

  @override
  String get errorShare => 'Échec du partage. Réessayez.';

  @override
  String get errorSomethingWrong => 'Quelque chose s\'est mal passé';

  @override
  String get errorStreak => 'Échec de la sauvegarde de la série.';

  @override
  String get errorUnexpected =>
      'Une erreur inattendue s\'est produite. Vous pouvez réessayer.';

  @override
  String get exitText => 'Quitter';

  @override
  String get experience => 'Expérience';

  @override
  String get exportData => 'Exporter mes données';

  @override
  String get exportDataCopied => 'Données copiées dans le presse-papier!';

  @override
  String get exportDataCopy => 'Copier dans le presse-papier';

  @override
  String get exportDataDesc =>
      'Téléchargez une copie de vos données personnelles';

  @override
  String get exportDataLoading => 'Collecte de vos données...';

  @override
  String get feedbackCatBug => 'Signaler un Bug';

  @override
  String get feedbackCatContent => 'Contenu';

  @override
  String get feedbackCatDesign => 'Design';

  @override
  String get feedbackCatFeature => 'Suggérer une Fonction';

  @override
  String get feedbackCatGeneral => 'Général';

  @override
  String get feedbackCategory => 'Catégorie';

  @override
  String get feedbackChangelog => 'Nouveautés';

  @override
  String get feedbackComments => 'Commentaires';

  @override
  String get feedbackConfusing => 'Confus';

  @override
  String get feedbackContinue => 'Continuer';

  @override
  String get feedbackExcellent => 'Vous êtes génial!';

  @override
  String get feedbackGood => 'Bien';

  @override
  String get feedbackHard => 'Difficile';

  @override
  String get feedbackHint => 'Dites-nous ce que vous pensez...';

  @override
  String get feedbackHowDidYouFeel => 'Comment vous êtes-vous senti?';

  @override
  String get feedbackPerfect => 'Parfait';

  @override
  String get feedbackPoor => 'Nous allons améliorer';

  @override
  String get feedbackRateExperience => 'Évaluez votre expérience';

  @override
  String get feedbackSubmit => 'Envoyer le Feedback';

  @override
  String get feedbackTapStars => 'Touchez une étoile pour évaluer';

  @override
  String get feedbackThanks => 'Merci!';

  @override
  String get feedbackThanksDesc =>
      'Votre feedback nous aide à améliorer SAGEN pour tous.';

  @override
  String get feedbackTitle => 'Feedback et Actualités';

  @override
  String get fileAnalyzer => 'Analyseur de fichiers';

  @override
  String get fileDangerous => 'Dangereux';

  @override
  String get fileHighRisk => 'Risque élevé';

  @override
  String get fileLowRisk => 'Faible risque';

  @override
  String get fileMediumRisk => 'Risque moyen';

  @override
  String get fileSafe => 'Sûr';

  @override
  String get finishText => 'Terminer';

  @override
  String firstLessonProgress(Object current, Object total) {
    return 'Leçon $current sur $total';
  }

  @override
  String get firstLessonSeeResults => 'VOIR LES RÉSULTATS';

  @override
  String get flexCardJoinAlliance => 'Rejoignez mon alliance sur SAGEN';

  @override
  String get fontSizeLarge => 'Grande';

  @override
  String get fontSizeNormal => 'Normale';

  @override
  String get fontSizeSmall => 'Petite';

  @override
  String get fontSizeTitle => 'Taille du texte';

  @override
  String get fontSizeXLarge => 'Très grande';

  @override
  String get forceSync => 'Forcer la synchronisation';

  @override
  String get free => 'Gratuit';

  @override
  String get french => 'Français';

  @override
  String get gachaChestTap => 'Coffre gacha. Appuyez pour améliorer.';

  @override
  String get gachaOrbFail => 'Aucun changement';

  @override
  String get gachaOrbSuccess => 'Amélioration réussie';

  @override
  String get gems => 'gemmes';

  @override
  String goToLesson(Object title) {
    return 'Aller aux leçons : $title';
  }

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get habitMsg1 =>
      'Excellent travail! Maintenant, renforçons votre discipline quotidienne.';

  @override
  String get habitMsg2 =>
      'Première étape terminée. Construisons l\'habitude qui vous mènera à l\'objectif.';

  @override
  String get habitMsg3 =>
      'Rendement excellent. Le secret maintenant est la constance.';

  @override
  String get habitMsg4 =>
      'Bien joué! Configurons maintenant votre rythme de progression quotidien.';

  @override
  String get habitMsg5 =>
      'Un début parfait. Assurons votre succès en créant une habitude inébranlable.';

  @override
  String get habitTransition1 =>
      'Construction de votre habitude quotidienne...';

  @override
  String get habitTransition2 => 'La constance est la clé';

  @override
  String get habitTransition3 => 'Vous progressez';

  @override
  String get habitTransition4 => 'Continuez !';

  @override
  String get habitTransition5 => 'Presque !';

  @override
  String get hapticFeedback => 'Retour haptique';

  @override
  String get hapticSubtitle => 'Réponse haptique lors des interactions';

  @override
  String get heatmapLess => 'Moins';

  @override
  String heatmapLessons(Object count) {
    return '$count leçons';
  }

  @override
  String get heatmapMore => 'Plus';

  @override
  String get heatmapTitle => 'Activité récente';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get historyDeleted => 'Historique supprimé';

  @override
  String get historyTitle => 'Historique';

  @override
  String get homeAllComplete => 'Tout est complet!';

  @override
  String get homeAllCompleteDesc => 'Vous avez maîtrisé toutes les leçons.';

  @override
  String get homeContinue => 'Continuer';

  @override
  String get homeDefaultName => 'Gardien';

  @override
  String get homeLearningPath => 'Parcours d\'apprentissage';

  @override
  String get homeTitle => 'Votre bouclier numérique est actif';

  @override
  String get homeViewAchievements => 'Voir les succès';

  @override
  String get howItWorks => 'Comment fonctionne SAGEN';

  @override
  String get impactAch => 'Succès';

  @override
  String get impactActiveUsers => 'Utilisateurs actifs';

  @override
  String get impactCommunity => 'Impact Communautaire';

  @override
  String get impactCountriesReached => 'Pays atteints';

  @override
  String get impactDonations => 'Total Doné';

  @override
  String get impactHoursLearned => 'Heures apprises';

  @override
  String get impactKnowledgeLevel => 'Connaissances en cybersécurité';

  @override
  String get impactLearningJourney => 'Votre Parcours d\'Apprentissage';

  @override
  String get impactLessons => 'Leçons faites';

  @override
  String get impactLevelActiveLearner => 'Apprenant Actif';

  @override
  String get impactLevelAwareUser => 'Utilisateur Averti';

  @override
  String get impactLevelBeginner => 'Débutant';

  @override
  String get impactLevelCybersecurityExpert => 'Expert en Cybersécurité';

  @override
  String get impactLevelDigitalGuardian => 'Gardien Numérique';

  @override
  String impactProgressToNext(Object count) {
    return '$count leçons pour le niveau suivant';
  }

  @override
  String get impactProtectedUsers => 'Utilisateurs protégés';

  @override
  String get impactQuestionsAnswered => 'Questions répondues';

  @override
  String get impactStreak => 'Série actuelle';

  @override
  String get impactTestimonial => 'Ce que disent les utilisateurs';

  @override
  String get impactTestimonial1 =>
      'SAGEN m\'a aidé à protéger ma famille du phishing. Les leçons interactives sont incroyables!';

  @override
  String get impactTestimonial2 =>
      'Je suis passé de zéro connaissance en cybersécurité à aider mes collègues à rester en sécurité en ligne.';

  @override
  String get impactTestimonial3 =>
      'La gamification rend l\'apprentissage amusant. J\'ai terminé 30 leçons en seulement 2 semaines!';

  @override
  String get impactTitle => 'Mon Impact';

  @override
  String get impactTotalLessons => 'Leçons terminées';

  @override
  String get impactXp => 'XP gagnés';

  @override
  String get impactYourLevel => 'VOTRE NIVEAU';

  @override
  String get impactYourStats => 'Vos Statistiques';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get incorrectAnswer => 'Mauvaise réponse';

  @override
  String get infoSection => 'Informations';

  @override
  String get initialAction => 'Commencez ici';

  @override
  String get inventoryFocusElixir => 'Élixir de Concentration';

  @override
  String get inventoryFocusElixirActivated =>
      'Elixir de Concentration activé — x2 pendant 15 min';

  @override
  String get inventoryFocusElixirDesc => 'Double EXP x2 pendant 15 min';

  @override
  String get inventoryMonocleAvailable =>
      'Monocle du Sage disponible pour le prochain défi';

  @override
  String get inventoryPhoenixFeather => 'Plume de Phénix';

  @override
  String get inventoryPhoenixFeatherDesc =>
      'Ravive votre série si perdue il y a moins de 24h';

  @override
  String get inventoryPhoenixFeatherRestored =>
      'Plume de Phénix: série restaurée';

  @override
  String get inventorySagesMonocle => 'Monocle du Sage';

  @override
  String get inventorySagesMonocleDesc =>
      'Supprime 2 mauvaises réponses dans un défi';

  @override
  String get inventoryShieldProtected => 'Bouclier de Titane: série protégée';

  @override
  String get inventoryTitaniumShield => 'Bouclier en Titane';

  @override
  String get inventoryTitaniumShieldDesc =>
      'Protège votre série automatiquement si vous manquez un jour';

  @override
  String get inventoryTitle => 'Inventaire';

  @override
  String get inventoryUse => 'Utiliser';

  @override
  String get languageTitle => 'Langue';

  @override
  String get lastSync => 'Dernière synchronisation';

  @override
  String get learnSubtitle => 'Leçons interactives de cybersécurité';

  @override
  String get learnTitle => 'Apprendre';

  @override
  String get learningPath => 'Votre parcours d\'apprentissage';

  @override
  String get legalAnd => ' et ';

  @override
  String get legalPrivacy => 'J\'accepte la politique de confidentialité';

  @override
  String get legalRegisterAgree => 'En vous inscrivant, vous acceptez nos ';

  @override
  String get legalTerms => 'Conditions';

  @override
  String get lessonComplete => 'Leçon terminée';

  @override
  String get lessonNoQuestions => 'Aucune question disponible pour cette leçon';

  @override
  String get lessonNoQuestionsHint =>
      'Sage est curieux aussi! Revenez bientôt.';

  @override
  String get lessonPreparing => 'Préparation de vos questions...';

  @override
  String lessonProgress(Object percent) {
    return 'Progrès: $percent%';
  }

  @override
  String get lessonResultsPreparing => 'Préparation des résultats...';

  @override
  String lessonsCompleted(Object count) {
    return '$count leçons terminées';
  }

  @override
  String lessonsCompletedPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# leçons terminées',
      one: '# leçon terminée',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(Object count) {
    return '$count leçons';
  }

  @override
  String lessonsLevel(Object level) {
    return 'Niveau $level';
  }

  @override
  String get lessonsNoAvailable => 'Aucune leçon disponible. Revenez bientôt.';

  @override
  String get lessonsYourPath => 'Votre parcours d\'apprentissage';

  @override
  String get levelAssessment0 => 'Débutant absolu';

  @override
  String get levelAssessment1 => 'Débutant';

  @override
  String get levelAssessment2 => 'Intermédiaire';

  @override
  String get levelAssessment3 => 'Avancé';

  @override
  String get levelAssessment4 => 'Expert';

  @override
  String get levelAssessmentQuestion =>
      'Quel est votre niveau actuel en cybersécurité ?';

  @override
  String levelProgress(Object percent) {
    return 'Progrès du niveau: $percent pour cent';
  }

  @override
  String get loading => 'Chargement';

  @override
  String get madeWithLove => 'Fait avec ♥ pour les étudiants';

  @override
  String get miniGameBackupDef => 'Copie de sécurité';

  @override
  String get miniGameComplete => 'Terminé!';

  @override
  String get miniGameCorrect => 'Correct';

  @override
  String get miniGameEncryptionDef => 'Protection des données avec clé';

  @override
  String get miniGameEncryptionTerm => 'Chiffrement';

  @override
  String get miniGameFirewallDef => 'Barrière de sécurité réseau';

  @override
  String get miniGameHiddenCard => 'Carte cachée';

  @override
  String get miniGameMalwareDef => 'Logiciel malveillant';

  @override
  String get miniGameMatches => 'Correspondances';

  @override
  String get miniGameMemory => 'Memory Match';

  @override
  String get miniGameMemoryDesc => 'Trouvez les paires de cartes';

  @override
  String get miniGameMistakes => 'Erreurs';

  @override
  String get miniGameMoves => 'Coups';

  @override
  String get miniGameOver => 'Bien essayé!';

  @override
  String get miniGamePattern => 'Pattern Trace';

  @override
  String get miniGamePatternDesc => 'Mémorisez et reproduisez les motifs';

  @override
  String get miniGamePhishingDef => 'Faux e-mail qui vole les données';

  @override
  String get miniGamePlayAgain => 'Rejouer';

  @override
  String get miniGameRound => 'Manche';

  @override
  String get miniGameScore => 'Score';

  @override
  String get miniGameSortInstruction =>
      'Appuyez pour classer chaque élément dans la bonne catégorie';

  @override
  String get miniGameSpeed => 'Speed Sort';

  @override
  String get miniGameSpeedDesc => 'Classez les éléments rapidement';

  @override
  String get miniGameSubtitle => 'Entraînez vos compétences en cybersécurité';

  @override
  String get miniGameTitle => 'Mini Jeux';

  @override
  String get miniGameVpnDef => 'Réseau privé virtuel';

  @override
  String get miniGameWatch => 'Regardez';

  @override
  String get miniGameWord => 'Word Match';

  @override
  String get miniGameWordDesc => 'Associez termes et définitions';

  @override
  String get miniGameWrong => 'Faux';

  @override
  String get miniGameYourTurn => 'Votre tour';

  @override
  String minutes(Object min) {
    return '$min min';
  }

  @override
  String minutesPerDay(Object count) {
    return '$count minutes par jour';
  }

  @override
  String get missionActiveLearnerDesc => 'Complétez 1 leçon de sécurité.';

  @override
  String get missionActiveLearnerTitle => 'Apprenant actif';

  @override
  String get missionActiveStreakDesc =>
      'Maintenez votre série d\'apprentissage aujourd\'hui.';

  @override
  String get missionActiveStreakTitle => 'Série active';

  @override
  String get missionChatWithSageDesc =>
      'Parlez à Sage de la sécurité numérique.';

  @override
  String get missionChatWithSageTitle => 'Discutez avec Sage';

  @override
  String get missionConsistentProtectorDesc =>
      'Complétez 3 leçons aujourd\'hui.';

  @override
  String get missionConsistentProtectorTitle => 'Protecteur constant';

  @override
  String get missionDigitalDetectiveDesc => 'Analysez un lien suspect.';

  @override
  String get missionDigitalDetectiveTitle => 'Détective digital';

  @override
  String get missionExpressChallengeDesc =>
      'Complétez un défi rapide de 30 secondes.';

  @override
  String get missionExpressChallengeTitle => 'Défi express';

  @override
  String get missionPerfectLessonDesc => 'Complétez une leçon sans erreur.';

  @override
  String get missionPerfectLessonTitle => 'Leçon parfaite';

  @override
  String get missionPhishingHunterDesc =>
      'Détectez correctement une tentative de phishing.';

  @override
  String get missionPhishingHunterTitle => 'Chasseur de phishing';

  @override
  String missionProgress(Object percent) {
    return 'Progrès de la mission: $percent pour cent';
  }

  @override
  String get missionThreeQueriesDesc =>
      'Discutez avec Sage 3 fois sur des sujets différents.';

  @override
  String get missionThreeQueriesTitle => '3 requêtes';

  @override
  String get monthApr => 'Avr';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthAug => 'Aoû';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthDec => 'Déc';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get monthFeb => 'Fév';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get motivationCareer => 'Carrière professionnelle';

  @override
  String get motivationConnect => 'Me connecter avec des gens';

  @override
  String get motivationDialogMultiple => 'Plusieurs motivations sélectionnées';

  @override
  String get motivationDialogNone => 'Aucune motivation sélectionnée';

  @override
  String get motivationFun => 'M\'amuser';

  @override
  String get motivationMind => 'Exercer mon esprit';

  @override
  String get motivationOther => 'Autre';

  @override
  String get motivationStudies => 'Études';

  @override
  String get motivationTravel => 'Voyager';

  @override
  String get myAccount => 'Mon compte';

  @override
  String get navChest => 'Coffre';

  @override
  String get navHome => 'Accueil';

  @override
  String get navProfile => 'Profil';

  @override
  String get navRanking => 'Classement';

  @override
  String get navSage => 'Sage';

  @override
  String get never => 'Jamais';

  @override
  String get newBadge => 'NOUVEAU';

  @override
  String get newsUpdates => 'Nouveautés et mises à jour';

  @override
  String get nextText => 'Suivant';

  @override
  String get noConnection => 'Pas de connexion internet.';

  @override
  String get noLessonsAvailable => 'Pas de leçons disponibles';

  @override
  String get notFoundBackHome => 'Retour à l\'accueil';

  @override
  String get notFoundDescription =>
      'La page que vous recherchez n\'existe pas.';

  @override
  String get notFoundTitle => 'Page introuvable';

  @override
  String get notificationReminder =>
      'Cinq minutes aujourd\'hui peuvent vous aider demain.';

  @override
  String get notificationStreakAlive => 'Votre série est toujours active!';

  @override
  String get notificationStreakLoss =>
      'Il n\'est jamais trop tard pour recommencer.';

  @override
  String get notificationTip => 'Votre bouclier numérique vous attend.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineAction => 'Connectez-vous et réessayez.';

  @override
  String get offlineMessage => 'Pas de connexion internet.';

  @override
  String get offlineNoConnection => 'Pas de connexion internet';

  @override
  String get offlineSavedForLater =>
      'Enregistré hors ligne. Nous synchroniserons bientôt.';

  @override
  String get offlineSyncComplete => 'Synchronisation terminée !';

  @override
  String get onbDiagnosisMsg =>
      'Super! Nous ajusterons votre plan d\'entraînement pour protéger vos connaissances dès le premier jour.';

  @override
  String get onbGoalCommit => 'MAINTENIR MON ENGAGEMENT';

  @override
  String get onbGoalIntense => 'Intense';

  @override
  String onbGoalMinPerDay(Object minutes) {
    return '$minutes min/jour';
  }

  @override
  String get onbGoalNormal => 'Normal';

  @override
  String get onbGoalRelaxed => 'Détendu';

  @override
  String get onbGoalSerious => 'Sérieux';

  @override
  String get onbGoalTitle =>
      'Quel est votre objectif d\'apprentissage quotidien?';

  @override
  String get onbLevel0 =>
      'Zéro absolu (Je ne sais pas ce qu\'est le phishing...)';

  @override
  String get onbLevel1 => 'Je connais les bases...';

  @override
  String get onbLevel2 => 'Niveau intermédiaire...';

  @override
  String get onbLevel3 => 'Niveau avancé...';

  @override
  String get onbLevel4 => 'Expert en cybersécurité...';

  @override
  String get onbLevelContinue => 'CONTINUER';

  @override
  String get onbLevelQuestion =>
      'Quel est votre niveau actuel en cybersécurité?';

  @override
  String get onbLevelTitle => 'Quel est votre niveau actuel en cybersécurité?';

  @override
  String get onbMotivationCareer => 'Carrière professionnelle';

  @override
  String get onbMotivationCareerMsg => 'D\'excellentes raisons d\'apprendre!';

  @override
  String get onbMotivationConnect => 'Me connecter avec des gens';

  @override
  String get onbMotivationConnectMsg => 'Préparons-nous à vous connecter!';

  @override
  String get onbMotivationFun => 'M\'amuser';

  @override
  String get onbMotivationFunMsg => 'J\'adore! M\'amuser est ma spécialité.';

  @override
  String get onbMotivationMind => 'Exercer mon esprit';

  @override
  String get onbMotivationMindMsg => 'C\'est une décision sage.';

  @override
  String get onbMotivationOther => 'Autre';

  @override
  String get onbMotivationOtherMsg => 'Compris! Dites-m\'en plus en chemin.';

  @override
  String get onbMotivationStudies => 'Études';

  @override
  String get onbMotivationStudiesMsg =>
      'Un monde d\'opportunités s\'ouvrira à vous!';

  @override
  String get onbMotivationTitle =>
      'Pourquoi souhaitez-vous maîtriser le monde numérique?';

  @override
  String get onbMotivationTravel => 'Voyager';

  @override
  String get onbMotivationTravelMsg =>
      'Rien de mieux que de voyager avec vos appareils 100% protégés!';

  @override
  String get onbNotifActivate => 'ACTIVER LES NOTIFICATIONS';

  @override
  String get onbNotifDesc =>
      'Activez les notifications pour ne pas perdre votre série, vos rappels quotidiens et vos défis importants.';

  @override
  String get onbNotifSkip => 'Pas maintenant';

  @override
  String get onbNotifTitle => 'On vous notifie?';

  @override
  String get onbProjHackerMind => 'Forgez un esprit de hacker';

  @override
  String get onbProjHackerMindDesc =>
      'Rappels stratégiques, défis quotidiens et tactiques de défense numérique.';

  @override
  String get onbProjLockAccounts => 'Verrouillez vos comptes';

  @override
  String get onbProjLockAccountsDesc =>
      'Protégez vos réseaux sociaux et comptes de jeux contre les piratages et les vols.';

  @override
  String get onbProjNavImmunity => 'Naviguer avec immunité';

  @override
  String get onbProjNavImmunityDesc =>
      'Détectez les arnaques, les liens malveillants et le phishing avant de cliquer.';

  @override
  String get onbProjectionTitle => 'Voici ce que vous maîtriserez en 3 mois!';

  @override
  String onbQuizIntro(Object count) {
    return 'Répondez à $count questions rapides avant votre premier entraînement numérique !';
  }

  @override
  String get onbRecommended => 'RECOMMANDÉ';

  @override
  String get onbReferralFriends => 'Recommandation d\'amis';

  @override
  String get onbReferralGoogle => 'Recherche Google';

  @override
  String get onbReferralOther => 'Autre';

  @override
  String get onbReferralPlayStore => 'Play Store';

  @override
  String get onbReferralQuestion => 'Comment avez-vous découvert SAGEN?';

  @override
  String get onbReferralSocial => 'Instagram / Facebook';

  @override
  String get onbReferralTiktok => 'TikTok';

  @override
  String get onbReferralTitle => 'Comment avez-vous découvert SAGEN?';

  @override
  String get onbReferralYoutube => 'YouTube';

  @override
  String get onbRouteAvailable => 'Parcours d\'entraînement disponibles :';

  @override
  String get onbRouteQuestion =>
      'Quel domaine de l\'environnement numérique aimeriez-vous maîtriser en premier ?';

  @override
  String get onbRoutineMessage =>
      'Choisissez votre routine d\'entraînement et de protection !';

  @override
  String get onbRoutineTitle =>
      'Choisissez votre routine d\'entraînement et de protection!';

  @override
  String get onbStartingExperienced => 'Vous avez déjà un niveau hacker?';

  @override
  String get onbStartingExperiencedSub =>
      'Passez le test de niveau et sautez les bases!';

  @override
  String get onbStartingPerfecto =>
      'Parfait! Voyons par où commencer votre entraînement.';

  @override
  String get onbStartingSubtitle =>
      'Commencez de zéro et forgez votre bouclier!';

  @override
  String get onbStartingTitle => 'C\'est votre première fois en cyberdéfense?';

  @override
  String get onbWelcomeMessage =>
      'Bonjour! Je suis Sagen. Je suis là pour vous entraîner, protéger votre environnement numérique et vous rendre expert.';

  @override
  String get onbWelcomeMsg =>
      'Bonjour! Je suis Sagen. Je suis là pour vous entraîner, protéger votre environnement numérique et faire de vous un expert.';

  @override
  String get onboardingCommitButton => 'MAINTENIR MON ENGAGEMENT';

  @override
  String get onboardingComplete =>
      'Parfait! Vous savez maintenant détecter le phishing basique.';

  @override
  String get onboardingDesc =>
      'Votre assistant personnel de sécurité numérique.\nApprenez, analysez et protégez-vous gratuitement.';

  @override
  String get onboardingError =>
      'C\'est ainsi qu\'ils agissent. Ils vérifient toujours avant de faire confiance.';

  @override
  String get onboardingHaveAccount => 'J\'ai déjà un compte';

  @override
  String get onboardingSage50Days =>
      '50 jours de dévouement. Une légende en devenir!';

  @override
  String get onboardingSageExcellent => 'D\'excellentes raisons, visez haut!';

  @override
  String get onboardingSageMonth =>
      'Un mois de discipline. Les habitudes se forgent.';

  @override
  String get onboardingSageStart => 'Un excellent début! Chaque jour compte.';

  @override
  String get onboardingSageTwoWeeks =>
      'Deux semaines de constance. Vous êtes imparable!';

  @override
  String get onboardingWelcome => 'Apprenez à vous protéger';

  @override
  String get onboardingWelcomeDesc =>
      'SAGEN vous apprend à naviguer, détecter les risques et protéger vos informations en ligne.';

  @override
  String get ourMission => 'Notre mission';

  @override
  String get owned => 'Possédé';

  @override
  String get passClaimFailed =>
      'Impossible de réclamer la récompense. Réessayez.';

  @override
  String get passClaimedLabel => 'Réclamée';

  @override
  String passDaysLeft(Object count) {
    return 'Encore $count jours';
  }

  @override
  String get passEarnSp => 'Gagnez du SP en terminant des leçons';

  @override
  String get passHowToEarnDailyLimit => 'Limite quotidienne de SP';

  @override
  String get passHowToEarnLesson => 'Terminez une leçon : +10 SP';

  @override
  String get passHowToEarnMission =>
      'Terminez des missions quotidiennes : +5 SP';

  @override
  String get passHowToEarnPerfect => 'Leçon parfaite : +15 SP';

  @override
  String get passHowToEarnReview => 'Révisez une leçon';

  @override
  String get passHowToEarnTitle => 'Comment gagner du SP';

  @override
  String passLevel(Object level) {
    return 'Niveau $level';
  }

  @override
  String get passLevelsTitle => 'Niveaux';

  @override
  String get passLocked => 'Verrouillé';

  @override
  String get passMaxLevel => 'Niveau maximum !';

  @override
  String passProgress(Object current, Object required) {
    return 'SP : $current / $required';
  }

  @override
  String get passReached => 'Atteint';

  @override
  String get passRewardClaimed => 'Récompense réclamée !';

  @override
  String passRewards(Object current, Object max) {
    return 'Récompenses ($current/$max)';
  }

  @override
  String get paymentCredited => 'Crédité!';

  @override
  String get paymentGoHome => 'Aller à l\'accueil';

  @override
  String get paymentMercadoPagoError =>
      'Erreur de connexion à MercadoPago. Réessayez.';

  @override
  String get paymentNotCompleted => 'Paiement non complété';

  @override
  String get paymentPending => 'Paiement en attente';

  @override
  String get paymentPendingDescription =>
      'Votre paiement est en cours de traitement. Les dons seront crédités une fois le paiement confirmé par le fournisseur.';

  @override
  String get paymentReturnToSagen => 'Retour à SAGEN';

  @override
  String get paymentTryAgain => 'Réessayer';

  @override
  String get paywallBasic => 'Basique';

  @override
  String get paywallDescription =>
      'Choisissez votre paquet et nous vous contacterons via WhatsApp pour coordonner le paiement.';

  @override
  String get paywallMercadoPago => 'Mercado Pago';

  @override
  String paywallPackageAmount(Object gems) {
    return '$gems dons';
  }

  @override
  String paywallPackageLabel(Object label) {
    return 'Paquet $label';
  }

  @override
  String paywallPackageSupporter(Object level) {
    return 'Niveau Supporter $level';
  }

  @override
  String get paywallPaymentMethods =>
      'Payez avec Yape, Plin, MercadoPago ou virement';

  @override
  String get paywallPopular => 'Populaire';

  @override
  String get paywallPremium => 'Premium';

  @override
  String get paywallSupportUs => 'Soutenir SAGEN';

  @override
  String paywallWhatsAppError(Object link) {
    return 'Erreur d\'ouverture de WhatsApp. Payer via: $link';
  }

  @override
  String paywallWhatsAppFallback(Object message) {
    return 'Ouvrez WhatsApp et envoyez: $message';
  }

  @override
  String paywallWhatsAppMessage(
    Object currencySymbol,
    Object supporterLevel,
    Object price,
    Object userId,
  ) {
    return 'Bonjour, je veux donner $currencySymbol$price à SAGEN (Supporter $supporterLevel). Mon ID utilisateur est : $userId';
  }

  @override
  String get portuguese => 'Portugais';

  @override
  String get preferencesTitle => 'Préférences';

  @override
  String get preparingResults => 'Préparation des résultats...';

  @override
  String get privacyLegal => 'Vie privée et légal';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité de SAGEN';

  @override
  String get privacyPolicyLastUpdate => 'Dernière mise à jour : Juillet 2026';

  @override
  String get privacyPolicySection1Title =>
      '1. Informations que nous collectons';

  @override
  String get privacyPolicySection1Body =>
      'Nous collectons les informations que vous fournissez directement, comme votre nom, email et âge, ainsi que les données dutilisation de lapp comme les leçons terminées, les séries et les scores.';

  @override
  String get privacyPolicySection2Title => '2. Utilisation des informations';

  @override
  String get privacyPolicySection2Body =>
      'Nous utilisons vos informations pour personnaliser votre expérience d\'apprentissage, améliorer nos services et vous envoyer des notifications pertinentes sur vos progrès.';

  @override
  String get privacyPolicySection3Title => '3. Stockage des données';

  @override
  String get privacyPolicySection3Body =>
      'Vos données sont stockées de manière sécurisée sur des serveurs protégés. Nous utilisons le chiffrement pour protéger vos informations personnelles.';

  @override
  String get privacyPolicySection4Title => '4. Vos droits';

  @override
  String get privacyPolicySection4Body =>
      'Vous avez le droit d\'accéder, de rectifier ou de supprimer vos données personnelles. Vous pouvez nous contacter pour exercer ces droits.';

  @override
  String get privacyPolicySection5Title => '5. Tiers';

  @override
  String get privacyPolicySection5Body =>
      'Nous ne vendons pas vos informations à des tiers. Nous pouvons partager des données anonymisées pour améliorer nos services éducatifs.';

  @override
  String get privacyPolicySection6Title => '6. Confidentialité des enfants';

  @override
  String get privacyPolicySection6Body =>
      'Notre app est destinée aux adultes. Nous ne collectons pas intentionnellement les informations des enfants de moins de 13 ans.';

  @override
  String get privacyPolicySection7Title => '7. Sécurité';

  @override
  String get privacyPolicySection7Body =>
      'Nous mettons en œuvre des mesures de sécurité techniques et organisationnelles pour protéger vos informations contre l\'accès non autorisé.';

  @override
  String get privacyPolicySection8Title =>
      '8. Modifications de cette politique';

  @override
  String get privacyPolicySection8Body =>
      'Nous nous réservons le droit de mettre à jour cette politique. Nous vous notifierons des changements importants via l\'app.';

  @override
  String get privacyPolicySection9Title => '9. Contact';

  @override
  String get privacyPolicySection9Body =>
      'Si vous avez des questions sur cette politique, contactez-nous à support@sagenapp.com';

  @override
  String get productBestOffer => 'Meilleure offre';

  @override
  String get productBoost => 'Impulsion';

  @override
  String get productBoostPack => 'Pack Impulsion';

  @override
  String get productBoostPackDesc => '200 dons + 1 Boost XP';

  @override
  String get productDonationBasic => 'Supporter';

  @override
  String get productDonationDesc => 'Aidez-nous à garder SAGEN gratuit';

  @override
  String get productDonationPremium => 'Champion';

  @override
  String get productDonationStandard => 'Super Supporter';

  @override
  String get productDonations => 'Dons';

  @override
  String get productDonationsDesc => 'Dons pour booster votre apprentissage';

  @override
  String get productFortune => 'Fortune';

  @override
  String get productFortunePack => 'Pack Fortune';

  @override
  String get productFortunePackDesc => '300 dons + 1 Multiplicateur d\'XP';

  @override
  String get productLuck => 'Chance';

  @override
  String get productLuckBoostDesc =>
      '1 Boost de Chance (2x dans les coffres légendaires)';

  @override
  String get productLuckPack => 'Pack Chance';

  @override
  String get productLuckPackDesc => '250 dons + 1 Boost de Chance';

  @override
  String get productOffer => 'Offre';

  @override
  String get productPopular => 'Populaire';

  @override
  String get productProtector => 'Protecteur';

  @override
  String get productProtectorPack => 'Pack Protecteur';

  @override
  String get productProtectorPackDesc => '100 dons + 1 protecteur de série';

  @override
  String get productStreakProtectorDesc => '1 Protecteur de série';

  @override
  String get productSupporter => 'Supporter';

  @override
  String get productUltra => 'Ultra';

  @override
  String get productXpBoostDesc => '1 Boost XP (2x votre prochaine leçon)';

  @override
  String get productXpMultiplierDesc =>
      '1 Multiplicateur d\'XP (2x dans les coffres)';

  @override
  String get profileAchievements => 'Succès';

  @override
  String get profileDay => 'jour';

  @override
  String get profileDays => 'jours';

  @override
  String get profileDefaultFirstName => 'Guerrier';

  @override
  String get profileDefaultLastName => 'Anonyme';

  @override
  String get profileDefaultName => 'Gardien';

  @override
  String get profileDonations => 'Dons';

  @override
  String get profileError => 'Erreur de chargement du profil';

  @override
  String get profileLevel => 'Niveau';

  @override
  String profileLevelValue(Object level) {
    return 'Niveau $level';
  }

  @override
  String get profileStreak => 'Série';

  @override
  String get profileTitle => 'Mon Profil';

  @override
  String get profileTotalXp => 'XP Total';

  @override
  String get profileXpLabel => 'XP';

  @override
  String get progressRestored => 'Progression restaurée depuis le cloud';

  @override
  String get projectionBenefit1Subtitle =>
      'Sécurisez vos réseaux sociaux et e-mails';

  @override
  String get projectionBenefit1Title => 'Protégez vos comptes';

  @override
  String get projectionBenefit2Subtitle =>
      'Identifiez le phishing et les liens malveillants';

  @override
  String get projectionBenefit2Title => 'Détectez les arnaques';

  @override
  String get projectionBenefit3Subtitle => 'Surfez internet en confiance';

  @override
  String get projectionBenefit3Title => 'Naviguez en sécurité';

  @override
  String get promoPostLessonSubtitle =>
      'Avec SAGEN Pass, obtenez des avantages exclusifs';

  @override
  String get promoPostLessonTitle => 'Continuez ! Débloquez plus';

  @override
  String get protectionBasic => 'Basique';

  @override
  String get protectionBasicDesc => 'Vous commencez à vous protéger';

  @override
  String get protectionCyberShield => 'Cyber Bouclier';

  @override
  String get protectionCyberShieldDesc => 'Vous êtes un bouclier actif';

  @override
  String get protectionElite => 'Protection Élite';

  @override
  String get protectionEliteDesc => 'Niveau de protection maximum';

  @override
  String get protectionGuardian => 'Gardien';

  @override
  String get protectionGuardianDesc => 'Vous défendez votre identité numérique';

  @override
  String get protectionProtected => 'Protégé';

  @override
  String get protectionProtectedDesc => 'Vos premiers habitudes numériques';

  @override
  String get protectionSecureMind => 'Secure Mind';

  @override
  String get protectionSecureMindDesc => 'La sécurité fait partie de vous';

  @override
  String questionProgress(Object current, Object total) {
    return 'Question $current sur $total';
  }

  @override
  String questions(Object count) {
    return '$count questions';
  }

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get quickChallengeDetectPhishing => 'Détectez le phishing';

  @override
  String get quickChallengeDetectRisk => 'Détectez le risque';

  @override
  String get quickChallengeSafePassword => 'Mot de passe sûr';

  @override
  String get quickChallengeTrueFalse => 'Vrai ou Faux';

  @override
  String get quickChallengeWhatWouldYouDo => 'Que feriez-vous ?';

  @override
  String get quizAbandonContent => 'Vous perdrez votre progression actuelle.';

  @override
  String get quizAbandonExit => 'QUITTER';

  @override
  String get quizAbandonMessage => 'Vous perdrez votre progression actuelle.';

  @override
  String get quizAbandonStay => 'CONTINUER';

  @override
  String get quizAbandonTitle => 'Abandonner ?';

  @override
  String get quizBack => 'Retour';

  @override
  String get quizCheck => 'VÉRIFIER';

  @override
  String get quizCheckAnswer => 'VÉRIFIER';

  @override
  String get quizContinue => 'CONTINUER';

  @override
  String get quizContinueButton => 'CONTINUER';

  @override
  String get quizDefaultTitle => 'Quiz';

  @override
  String get quizExit => 'QUITTER';

  @override
  String get quizIntroAnswer => 'Répondez';

  @override
  String get quizIntroBeforeTraining => 'Avant votre entraînement';

  @override
  String get quizIntroFastQuestions => 'Questions rapides';

  @override
  String quizProgress(Object percent) {
    return 'Progrès du quiz: $percent pour cent';
  }

  @override
  String get quizProgressExpired =>
      'La progression du quiz a expiré (plus de 24 heures).';

  @override
  String get quizResumeButton => 'Reprendre';

  @override
  String get quizStartOver => 'Recommencer';

  @override
  String get quizTitleDefault => 'Quiz';

  @override
  String get rankActiveLearner => 'Apprenant Actif';

  @override
  String get rankCybersecurityLegend => 'Légende de la Cybersécurité';

  @override
  String get rankEliteDefender => 'Défenseur d\'Élite';

  @override
  String get rankExperiencedWarrior => 'Guerrier Expérimenté';

  @override
  String get rankNovice => 'Novice';

  @override
  String get rankingEmptyMessage =>
      'Terminez des leçons pour entrer dans le classement';

  @override
  String get rankingError => 'Erreur de chargement du classement';

  @override
  String rankingPosition(Object rank) {
    return 'Rang #$rank';
  }

  @override
  String get rankingShareButton => 'Partager la Flex Card';

  @override
  String get rankingShareSubtitle => 'Dépasse mon rang sur SAGEN';

  @override
  String get rankingSharing => 'Partage en cours...';

  @override
  String get rankingSubtitle => 'Classement global · Top 50';

  @override
  String get rankingTitle => 'Le Colisée';

  @override
  String rankingXpToTop50(Object xp) {
    return 'Il vous manque $xp XP pour entrer dans le Top 50';
  }

  @override
  String rankingYourPosition(Object xp, Object rank) {
    return 'Votre position: #$rank · $xp XP';
  }

  @override
  String get rarityGold => 'Or';

  @override
  String get rarityPlatinum => 'Platine';

  @override
  String get raritySilver => 'Argent';

  @override
  String get reauthConfirm => 'Confirmer';

  @override
  String get reauthDesc =>
      'Pour des raisons de sécurité, veuillez saisir à nouveau votre mot de passe';

  @override
  String get reauthOAuthInfo =>
      'Vous vous êtes connecté avec Google ou Facebook. Confirmez la suppression du compte.';

  @override
  String get reauthTitle => 'Confirmez votre mot de passe';

  @override
  String get reauthWrongPassword => 'Mot de passe incorrect. Réessayez.';

  @override
  String get recommended => 'RECOMMANDÉ';

  @override
  String get reduceAnimations => 'Réduire les animations';

  @override
  String get reduceAnimationsSubtitle => 'Réduit l\'intensité des animations';

  @override
  String get referralSource1 => 'Recommandation d\'amis';

  @override
  String get referralSource2 => 'Réseaux sociaux';

  @override
  String get referralSource3 => 'Recherche Google';

  @override
  String get referralSource4 => 'App Store';

  @override
  String get referralSource5 => 'YouTube';

  @override
  String get referralSource6 => 'TikTok';

  @override
  String get referralSource7 => 'Autre';

  @override
  String get regAgeQuestion => 'Quel âge avez-vous?';

  @override
  String get regAgeValidation => 'Veuillez entrer votre âge réel';

  @override
  String get regChooseMethod =>
      'Choisissez une méthode pour créer votre compte.';

  @override
  String get regCloudSave => 'Progression sauvegardée dans le cloud';

  @override
  String get regCreateProfile => 'CRÉER LE PROFIL';

  @override
  String get regEmailDesc => 'Nous vous enverrons un code de vérification.';

  @override
  String get regEmailHint => 'exemple@email.com';

  @override
  String get regEmailOption => 'E-mail';

  @override
  String get regEmailTitle => 'Votre e-mail';

  @override
  String get regHowContinue => 'Comment souhaitez-vous continuer?';

  @override
  String get regLater => 'Plus tard';

  @override
  String get regMethodTitle => 'Choisissez la méthode d\'inscription';

  @override
  String get regNameHint => 'Prénom';

  @override
  String get regNameQuestion => 'Comment vous appelez-vous?';

  @override
  String get regPasswordDesc =>
      'Minimum 6 caractères pour protéger votre compte.';

  @override
  String get regPasswordTitle => 'Créez un mot de passe';

  @override
  String get regProfileAlmostReady => 'Presque prêt!';

  @override
  String get regProfileCreated => 'PROFIL CRÉÉ';

  @override
  String get regProfileDesc =>
      'Créez un profil pour sauvegarder votre progression et ne pas perdre votre série.';

  @override
  String get regReadyForLesson => 'Préparez-vous pour votre première leçon';

  @override
  String get regRewards => 'Récompenses et succès personnels';

  @override
  String get regStreakSync => 'Série synchronisée entre appareils';

  @override
  String get regSurnameHint => 'Nom';

  @override
  String get regWelcomeSagen => 'Bienvenue sur SAGEN!';

  @override
  String get registerAgeEmpty => 'Veuillez entrer votre âge';

  @override
  String get registerAgeHint => 'Votre âge (minimum 13 ans)';

  @override
  String get registerAgeInvalid => 'Âge invalide';

  @override
  String get registerAgeMin => 'Vous devez avoir au moins 13 ans';

  @override
  String get registerWithApple => 'S\'inscrire avec Apple';

  @override
  String get registerWithFacebook => 'S\'inscrire avec Facebook';

  @override
  String get registerWithGoogle => 'S\'inscrire avec Google';

  @override
  String get restartApp => 'Redémarrer l\'application';

  @override
  String get restoreAction => 'Restaurer';

  @override
  String get restoreCloud => 'Restaurer depuis le cloud';

  @override
  String get restoreDesc =>
      'Voulez-vous restaurer votre progression depuis le cloud? Cela remplacera les données locales par les données sauvegardées de votre compte.';

  @override
  String get restoreTitle => 'Restaurer la progression';

  @override
  String get resultAccuracy => 'Précision';

  @override
  String get resultCompleteTitle => 'Leçon terminée!';

  @override
  String get resultLives => 'Vies';

  @override
  String get resultNotPerfectDesc =>
      'Continuez à pratiquer pour obtenir une session parfaite.';

  @override
  String get resultPerfectBadge => 'SESSION PARFAITE';

  @override
  String get resultPerfectDesc =>
      'Vous n\'avez commis aucune erreur. Vous êtes un gardien numérique.';

  @override
  String get resultPerfectTitle => 'Résultat impeccable!';

  @override
  String get resumeQuiz => 'Reprendre le quiz ?';

  @override
  String get retry => 'Réessayer';

  @override
  String get reviewComplete => 'Révision terminée!';

  @override
  String get reviewCorrect => 'correctes';

  @override
  String get reviewFinish => 'Terminer la révision';

  @override
  String get reviewGoodProgress => 'Bon progrès';

  @override
  String get reviewKeepGoing => 'Continuez comme ça!';

  @override
  String get reviewKeepPracticing => 'Continuez à pratiquer';

  @override
  String get reviewNoErrors => 'Aucune erreur à réviser';

  @override
  String get reviewSageGood =>
      'Chaque révision renforce votre bouclier. Prêt pour plus?';

  @override
  String get reviewSageKeep =>
      'Réviser fait partie de l\'apprentissage. Vous pouvez réessayer quand vous voulez.';

  @override
  String get reviewSagePerfect =>
      'Vos points faibles s\'améliorent. Je vois votre effort.';

  @override
  String get reviewTitle => 'Révision';

  @override
  String get reward100Xp => '100 XP';

  @override
  String get reward200Exp => '200 EXP';

  @override
  String rewardAdCooldown(Object seconds) {
    return 'Disponible dans $seconds secondes';
  }

  @override
  String rewardAdEarned(Object count) {
    return 'Vous avez gagné $count dons!';
  }

  @override
  String rewardAdEarnedGems(Object gems) {
    return '+$gems gemmes';
  }

  @override
  String rewardAdEarnedXp(Object xp) {
    return '+$xp XP gagnés !';
  }

  @override
  String get rewardAdNotAvailable =>
      'L\'annonce n\'est pas disponible maintenant. Réessayez plus tard.';

  @override
  String get rewardAdSubtitle =>
      'Regardez une annonce et recevez des dons instantanément';

  @override
  String get rewardAdTitle => 'Gagnez des dons supplémentaires';

  @override
  String get rewardAdWatch => 'Regarder';

  @override
  String get rewardCopperFrame => 'Cadre Cuivre';

  @override
  String get rewardEpicChest => 'Coffre Épique';

  @override
  String get rewardGoldenChest => 'Coffre Doré';

  @override
  String get rewardIceFlame => 'Flamme Glaciale + Gardien';

  @override
  String get rewardTitaniumShield => 'Bouclier Titane';

  @override
  String get routeSelection1 => 'Les fondamentaux d\'abord';

  @override
  String get routeSelection2 => 'Parcours intermédiaire';

  @override
  String get routeSelection3 => 'Parcours avancé';

  @override
  String sageAchievementUnlocked(Object name) {
    return '${name}Succès débloqué !';
  }

  @override
  String sageAdvancing(Object levelHint, Object name) {
    return '${name}Vous continuez à progresser.$levelHint';
  }

  @override
  String get sageChatDescription =>
      'Posez une question sur la cybersécurité ou choisissez une suggestion rapide.';

  @override
  String get sageChatHint => 'Demandez à Sage...';

  @override
  String get sageChatTitle => 'Demandez à Sage';

  @override
  String sageCongratulations(Object name) {
    return '${name}Félicitations !';
  }

  @override
  String get sageCriticalError => 'Erreur critique';

  @override
  String get sageEasterEgg => 'Vous avez vu ça ?';

  @override
  String sageEmptyState(Object name) {
    return '${name}Rien ici pour l\'instant';
  }

  @override
  String sageGreatJob(Object name, Object extra) {
    return '${name}Excellent travail !$extra';
  }

  @override
  String sageHighStreakDays(Object streak) {
    return ' $streak jours consécutifs.';
  }

  @override
  String get sageImportant => 'C\'est très important';

  @override
  String sageImpressiveStreak(Object name, Object days) {
    return '${name}Série impressionnante !$days';
  }

  @override
  String sageLevelHint(Object level) {
    return ' Le niveau $level est proche.';
  }

  @override
  String get sageLoading => 'Donnez-moi une seconde...';

  @override
  String get sageMascot => 'Mascotte Sage';

  @override
  String get sageMonocleActive => 'Monocle Sage actif';

  @override
  String get sageMonocleButton =>
      'Utiliser le Monocle Sage (supprimer 2 fausses)';

  @override
  String get sageMotivational1 => 'Vous êtes génial!';

  @override
  String get sageMotivational2 => 'Continuez, vous êtes incroyable!';

  @override
  String get sageMotivational3 => 'Chaque jour plus proche de votre objectif!';

  @override
  String get sageMotivational4 => 'Je crois en vous!';

  @override
  String get sageMotivational5 => 'N\'abandonnez pas, vous pouvez le faire!';

  @override
  String get sageMotivational6 => 'Allons-y ensemble dans cette aventure!';

  @override
  String get sageMotivational7 => 'L\'effort porte ses fruits!';

  @override
  String get sageMotivational8 => 'N\'arrêtez jamais d\'apprendre!';

  @override
  String get sagePerfect => 'Parfait !';

  @override
  String get sagePreparing => 'Préparation de tout pour vous';

  @override
  String get sageReadCarefully => 'Lisez attentivement';

  @override
  String get sageSomethingWrong => 'Quelque chose s\'est mal passé';

  @override
  String sageStreakAmazing(Object streak) {
    return 'Votre série de $streak jours est incroyable !';
  }

  @override
  String sageStreakAtRisk(Object streak) {
    return ' Ne perdez pas $streak jours d\'effort !';
  }

  @override
  String sageStreakAtRiskMessage(Object urgency, Object name) {
    return '${name}Ne perdez pas votre série !$urgency';
  }

  @override
  String get sageStreakLost => ' Vous avez les connaissances pour recommencer.';

  @override
  String sageStreakLostMessage(Object name, Object encouragement) {
    return '${name}La série a été perdue.$encouragement';
  }

  @override
  String sageTellMeMore(Object name) {
    return '${name}Parlez-moi de vous';
  }

  @override
  String get sageTryAgain => 'On réessaie ?';

  @override
  String sageWelcomeBack(Object name) {
    return '${name}Bon retour !';
  }

  @override
  String sageWhatDoYouThink(Object name) {
    return '${name}Que pensez-vous être correct ?';
  }

  @override
  String get sagenPassClaim => 'Réclamer';

  @override
  String get sagenPassSupportSubtitle =>
      'Obtenez des avantages exclusifs et aidez à améliorer l\'app';

  @override
  String get sagenPassSupportTitle => 'Soutenir SAGEN';

  @override
  String get sagenPassTitle => 'Pass SAGEN';

  @override
  String get savedQuizProgress =>
      'Vous avez une progression sauvegardée. Voulez-vous continuer ?';

  @override
  String get scheduledDarkMode => 'Mode sombre programmé';

  @override
  String get scheduledDarkModeSubtitle => 'Actif/désactif selon l\'horaire';

  @override
  String get searchPlaceholder => 'Rechercher...';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get selectedAnswer => 'Sélectionnée';

  @override
  String get sendMessage => 'Envoyer';

  @override
  String get sessionAccuracyText1 => 'Quelle bonne visée!';

  @override
  String get sessionAccuracyText2 => 'Précision chirurgicale.';

  @override
  String get sessionAccuracyText3 => 'Niveau expert atteint.';

  @override
  String get sessionAccuracyText4 => 'Tireur d\'élite du savoir.';

  @override
  String get sessionAccuracyText5 => 'Perfection quasi absolue.';

  @override
  String get sessionAccuracyText6 => 'Aucune marge d\'erreur.';

  @override
  String get sessionAccuracyText7 => 'Impeccable.';

  @override
  String get sessionBackToMap => 'Retour à la carte';

  @override
  String get sessionClaimReward => 'RECEVOIR LA RÉCOMPENSE';

  @override
  String get sessionCorrect => 'Correct!';

  @override
  String sessionCorrectAnswer(Object answer) {
    return 'Bonne réponse: $answer';
  }

  @override
  String get sessionExp => 'EXP';

  @override
  String get sessionIncorrect => 'Incorrect';

  @override
  String get sessionLivesExhausted => 'Vies épuisées';

  @override
  String get sessionLivesExhaustedDesc =>
      'Vous avez perdu toutes vos vies. Réessayez.';

  @override
  String get sessionLoading => 'Chargement...';

  @override
  String get sessionPrecision => 'PRÉCISION';

  @override
  String get sessionQuestionsToAnswer => 'questions à répondre';

  @override
  String get sessionReadyToLearn => 'Prêt à apprendre?';

  @override
  String get sessionRetry => 'Réessayer';

  @override
  String sessionScore(Object correct, Object total) {
    return '$correct/$total correctes';
  }

  @override
  String get sessionSelectAnswer => 'Sélectionnez une réponse';

  @override
  String get sessionSpeedText1 => 'Quelle rapidité!';

  @override
  String get sessionSpeedText2 => 'Vous avez battu le chronomètre.';

  @override
  String get sessionSpeedText3 => 'À la vitesse de la lumière.';

  @override
  String get sessionSpeedText4 => 'Réflexes d\'acier.';

  @override
  String get sessionSpeedText5 => 'Personne ne vous rattrape aujourd\'hui.';

  @override
  String get sessionSpeedText6 => 'Temps record!';

  @override
  String get sessionSpeedText7 => 'Vitesse supersonique.';

  @override
  String get sessionStandardText1 => 'Leçon terminée!';

  @override
  String get sessionStandardText2 => 'Un pas de plus vers votre objectif.';

  @override
  String get sessionStandardText3 => 'Le progrès est le chemin.';

  @override
  String get sessionStandardText4 => 'Bon travail constant.';

  @override
  String get sessionStandardText5 => 'Continuez, ajoutez des jours.';

  @override
  String get sessionStandardText6 => 'La constance avant tout.';

  @override
  String get sessionStandardText7 => 'La discipline donne des résultats.';

  @override
  String get sessionStartQuiz => 'COMMENCER LE QUIZ';

  @override
  String get sessionSummaryAccuracy => 'PRÉCISION';

  @override
  String get sessionSummaryAccuracy1 => 'Votre précision est extraordinaire!';

  @override
  String get sessionSummaryAccuracy2 => 'Excellente visée !';

  @override
  String get sessionSummaryAccuracy3 => 'Bon progrès !';

  @override
  String get sessionSummaryAccuracy4 => 'Tu progresses !';

  @override
  String get sessionSummaryAccuracy5 => 'Bon effort !';

  @override
  String get sessionSummaryAccuracy6 => 'Continue d\'apprendre !';

  @override
  String get sessionSummaryAccuracy7 => 'Chaque question compte !';

  @override
  String get sessionSummaryExp => 'EXP';

  @override
  String get sessionSummaryReceiveReward => 'RÉCUPÉRER LA RÉCOMPENSE';

  @override
  String get sessionSummaryReceiveRewardLabel => 'Récupérer la récompense';

  @override
  String get sessionSummarySpeed1 => 'Vitesse éclair !';

  @override
  String get sessionSummarySpeed2 => 'Réflexe rapide !';

  @override
  String get sessionSummarySpeed3 => 'Apprenant rapide !';

  @override
  String get sessionSummarySpeed4 => 'Bon rythme !';

  @override
  String get sessionSummarySpeed5 => 'Sur la bonne voie !';

  @override
  String get sessionSummarySpeed6 => 'Tu prends de la vitesse !';

  @override
  String get sessionSummarySpeed7 => 'Progrès constant !';

  @override
  String get sessionSummaryStandard1 => 'Leçon terminée !';

  @override
  String get sessionSummaryStandard2 => 'Bien joué !';

  @override
  String get sessionSummaryStandard3 => 'Bon travail !';

  @override
  String get sessionSummaryStandard4 => 'Pas mal !';

  @override
  String get sessionSummaryStandard5 => 'Tu as réussi !';

  @override
  String get sessionSummaryStandard6 => 'Un pas de plus !';

  @override
  String get sessionSummaryStandard7 => 'Continue !';

  @override
  String get sessionSummaryTime => 'TEMPS';

  @override
  String get sessionTime => 'TEMPS';

  @override
  String get settingsAmoledDark => 'AMOLED Dark';

  @override
  String get settingsAmoledDarkSubtitle =>
      'Fond pur #000000 pour économiser la batterie';

  @override
  String get settingsAnalytics => 'Analyses anonymes';

  @override
  String get settingsAnalyticsDesc =>
      'Aidez à améliorer Sagen avec des données d\'utilisation anonymes';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountConfirm =>
      'Êtes-vous sûr? Cette action est irréversible.';

  @override
  String get settingsExportData => 'Exporter les données';

  @override
  String get settingsFontSize => 'Taille de police';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutConfirm =>
      'Êtes-vous sûr de vouloir vous déconnecter?';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Confidentialité';

  @override
  String get settingsReduceAnimations => 'Réduire les animations';

  @override
  String get settingsSound => 'Son';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get shareProfile => 'Partager la carte de profil';

  @override
  String get shareRanking => 'Partager le classement';

  @override
  String get sharing => 'Partage en cours...';

  @override
  String get shieldTierBasic => 'Bouclier Basique';

  @override
  String get shieldTierCrystal => 'Bouclier de Cristal';

  @override
  String get shieldTierGlow => 'Bouclier Rayonnant';

  @override
  String get shieldTierInactive => 'Sans Bouclier';

  @override
  String get shieldTierLegendary => 'Bouclier Légendaire';

  @override
  String get shieldTierParticles => 'Bouclier de Particules';

  @override
  String get shopBgCyber => 'Fond Cyberpunk';

  @override
  String get shopBgCyberDesc => 'Fond de profil futuriste';

  @override
  String get shopBgMatrix => 'Fond Matrix';

  @override
  String get shopBgMatrixDesc => 'Fond vert matrix';

  @override
  String get shopFrameDiamond => 'Cadre Diamant';

  @override
  String get shopFrameDiamondDesc => 'Cadre exclusif diamant';

  @override
  String get shopFrameNeon => 'Cadre Néon';

  @override
  String get shopFrameNeonDesc => 'Cadre de profil néon';

  @override
  String get shopItemAcquired => 'Acquis';

  @override
  String get shopItemOwned => 'Possédé';

  @override
  String get shopOwned => 'Possédé';

  @override
  String get shopSageGolden => 'Sage Doré';

  @override
  String get shopSageGoldenDesc => 'Skin dorée exclusive';

  @override
  String get shopSageNeon => 'Sage Néon';

  @override
  String get shopSageNeonDesc => 'Skin cyan néon pour Sage';

  @override
  String get shopSageShadow => 'Sage Ombre';

  @override
  String get shopSageShadowDesc => 'Skin sombre pour Sage';

  @override
  String get shopTitleGuardian => 'Titre Gardien Numérique';

  @override
  String get shopTitleGuardianDesc => 'Titre de protecteur';

  @override
  String get shopTitleHacker => 'Titre Hacker Éthique';

  @override
  String get shopTitleHackerDesc => 'Titre spécial dans le profil';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get skipText => 'Passer';

  @override
  String get skipToContent => 'Aller au contenu principal';

  @override
  String get sounds => 'Sons';

  @override
  String get soundsSubtitle => 'Effets sonores de l\'application';

  @override
  String get spanish => 'Espagnol';

  @override
  String get speedSort2fa => 'Authentification à deux facteurs';

  @override
  String get speedSortAntivirus => 'Antivirus';

  @override
  String get speedSortDataEncryption => 'Chiffrement des données';

  @override
  String get speedSortFakeEmail => 'E-mail fictif';

  @override
  String get speedSortFirewall => 'Pare-feu';

  @override
  String get speedSortFraudulentCall => 'Appel frauduleux';

  @override
  String get speedSortProtectionCategory => 'Protection';

  @override
  String get speedSortScamCategory => 'Arnaque';

  @override
  String get speedSortSecurityCategory => 'Sécurité';

  @override
  String get speedSortSmsLink => 'Lien SMS';

  @override
  String get speedSortStrongPassword => 'Mot de passe fort';

  @override
  String get speedSortVpn => 'VPN';

  @override
  String get splashTitle => 'SAGEN';

  @override
  String get stage1Subtitle => 'Concepts de base de la sécurité numérique';

  @override
  String get stage1Title => 'Fondamentaux';

  @override
  String get stage2Subtitle => 'Identifiez les tentatives de tromperie';

  @override
  String get stage2Title => 'Phishing';

  @override
  String get stage3Subtitle => 'Créez des clés sécurisées et protégez-vous';

  @override
  String get stage3Title => 'Mots de Passe';

  @override
  String get stage4Subtitle => 'Protégez votre vie privée sur les plateformes';

  @override
  String get stage4Title => 'Réseaux Sociaux';

  @override
  String get stage5Subtitle => 'Désinformation et sites fiables';

  @override
  String get stage5Title => 'Navigation Sécurisée';

  @override
  String get stage6Subtitle => 'Contrôlez vos données personnelles';

  @override
  String get stage6Title => 'Vie Privée Numérique';

  @override
  String get stage7Subtitle => 'Protection totale pour experts';

  @override
  String get stage7Title => 'Cybersécurité Avancée';

  @override
  String get stage8Subtitle => 'Devenez un gardien numérique';

  @override
  String get stage8Title => 'Expert Numérique';

  @override
  String stageProgress(Object percent) {
    return 'Progrès de l\'étape: $percent pour cent';
  }

  @override
  String get startText => 'Commencer';

  @override
  String get statsExcellent => 'Excellent!';

  @override
  String get statsIncredible => 'Incroyable!';

  @override
  String get statsKeepTrying => 'Continuez d\'essayer.';

  @override
  String get statsNoData => 'Aucune donnée de leçon';

  @override
  String get statsNoErrors => 'Sans erreurs!';

  @override
  String get statsReceiveXp => 'RECEVOIR L\'XP';

  @override
  String get statsSpeed => 'Vitesse';

  @override
  String get statsStartStage1 => 'Vous commencerez à l\'étape 1, Leçon 1';

  @override
  String get statsStartStage2 => 'Vous commencerez à l\'étape 2, Leçon 1';

  @override
  String get statsWellDone => 'Bien joué!';

  @override
  String get statusCompleted => 'terminée';

  @override
  String get storeAdEarnXp => 'Gagnez des XP en regardant';

  @override
  String get storeAdRewardMessage => '+1 Don pour avoir regardé l\'annonce';

  @override
  String get storeAdWatchVideo => 'Regardez une vidéo de 30 secondes';

  @override
  String storeBuyItem(Object cost, Object item) {
    return 'Acheter $item pour $cost dons';
  }

  @override
  String get storeCategoryConsumables => 'Consommables';

  @override
  String get storeCategoryCosmetics => 'Cosmétiques';

  @override
  String get storeCategoryThemes => 'Thèmes';

  @override
  String get storeChestAvailable => 'Coffre Quotidien Disponible!';

  @override
  String get storeChestComeBack => 'Revenez demain';

  @override
  String storeChestExpiresIn(Object gems) {
    return '$gems dons — expire à minuit';
  }

  @override
  String get storeChestRenews => 'Votre coffre se renouvelle chaque jour';

  @override
  String get storeClaimError =>
      'Échec de la réclamation de la récompense. Réessayez.';

  @override
  String storeConfirmMessage(Object cost, Object item) {
    return 'Voulez-vous acheter $item pour $cost dons?';
  }

  @override
  String get storeConfirmTitle => 'Confirmer l\'achat';

  @override
  String get storeDonate => 'Faire un don';

  @override
  String storeDonateSubtitle(Object price) {
    return 'À partir de $price';
  }

  @override
  String get storeDonationsLabel => 'dons';

  @override
  String get storeGemTipAchievement => 'Succès : gemmes selon la difficulté';

  @override
  String get storeGemTipChest =>
      'Ouvrez les coffres : gemmes selon le type de coffre';

  @override
  String get storeGemTipFirstLesson => 'Première leçon du jour : +10 gemmes';

  @override
  String get storeGemTipLesson =>
      'Complétez des leçons : 5 gemmes par bonne réponse';

  @override
  String get storeGemTipMission => 'Missions quotidiennes : +12 gemmes';

  @override
  String get storeGemTipPerfect =>
      'Leçon parfaite : +20 gemmes supplémentaires';

  @override
  String get storeGemTipStreak => 'Séries : jusqu\'à +150 gemmes';

  @override
  String get storeHowToEarnGems => 'Comment gagner des gemmes ?';

  @override
  String get storeNoItems => 'Aucun article disponible pour le moment.';

  @override
  String get storeOpen => 'Ouvrir';

  @override
  String get storePersonalization => 'Personnalisation';

  @override
  String get storeProtectStreak => 'Protégez votre série';

  @override
  String get storeDailyChestClaim => 'Réclamer';

  @override
  String storeDailyChestReward(Object xp) {
    return '+$xp XP !';
  }

  @override
  String get storeDailyChestSubtitle =>
      'Réclamez votre récompense quotidienne gratuite';

  @override
  String get storeDailyChestTitle => 'Coffre quotidien';

  @override
  String get storePurchaseFailed =>
      'Échec de la validation de l\'achat. Veuillez réessayer.';

  @override
  String get storePurchaseSuccess => 'Achat réussi!';

  @override
  String get storeAlreadyOwned => 'Vous possédez déjà cet article.';

  @override
  String get storeShieldLimitReached => 'Limite de boucliers atteinte';

  @override
  String get storeSupport => 'Soutenez-nous';

  @override
  String get storeSupportTiers => 'Niveaux de soutien';

  @override
  String get storeThankYou => 'Merci pour votre soutien!';

  @override
  String get storeTitle => 'Boutique';

  @override
  String get storeWatch => 'Regarder';

  @override
  String storeWhatsappPackages(Object price) {
    return 'Packages à partir de $price — Paiement par WhatsApp';
  }

  @override
  String get streakAchievements => 'Succès et médailles pour votre constance';

  @override
  String get streakBadge => 'SÉRIE';

  @override
  String get streakChest100Message => '100 jours. Légende.';

  @override
  String get streakChest100Title => 'Série de 100 jours !';

  @override
  String get streakChest14Message => 'Deux semaines de constance. Continuez !';

  @override
  String get streakChest14Title => 'Série de 14 jours !';

  @override
  String get streakChest30Message => 'Un mois. Vous êtes un Gardien Numérique.';

  @override
  String get streakChest30Title => 'Série de 30 jours !';

  @override
  String get streakChest7Message =>
      'Une semaine à protéger votre identité numérique.';

  @override
  String get streakChest7Title => 'Série de 7 jours !';

  @override
  String get streakCommitButton => 'MAINTENIR MON ENGAGEMENT';

  @override
  String get streakCurrent => 'Série actuelle';

  @override
  String streakCurrentProgress(Object goal, Object current) {
    return 'Série actuelle: $current / $goal jours';
  }

  @override
  String get streakDayFri => 'Ve';

  @override
  String get streakDayLabel => 'jour de série';

  @override
  String get streakDayMon => 'Lu';

  @override
  String get streakDayOfStreak => 'jour de série';

  @override
  String get streakDaySat => 'Sa';

  @override
  String get streakDaySun => 'Di';

  @override
  String get streakDayThu => 'Je';

  @override
  String get streakDayTue => 'Ma';

  @override
  String get streakDayWed => 'Me';

  @override
  String streakDays(Object count) {
    return '$count jours';
  }

  @override
  String streakDaysCount(Object count) {
    return '$count jours de série';
  }

  @override
  String streakDaysCountPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# jours de série',
      one: '# jour de série',
    );
    return '$_temp0';
  }

  @override
  String get streakEmotional100 =>
      '100 jours de protection constante. Légende.';

  @override
  String get streakEmotional14 =>
      'Deux semaines de constance. Votre bouclier brille.';

  @override
  String get streakEmotional3 =>
      '3 jours consécutifs. Vous construisez un solide habitude.';

  @override
  String get streakEmotional30 =>
      'Un mois d\'apprentissage. Votre dévouement vous fait un Gardien Digital.';

  @override
  String get streakEmotional50 => '50 jours de protection numérique constante.';

  @override
  String get streakEmotional7 =>
      'Une semaine à protéger votre identité numérique. Continuez !';

  @override
  String get streakFireCard => 'Carte de série en feu';

  @override
  String get streakFireCardA11y => 'Carte de série de feu';

  @override
  String get streakFireCardLabel => 'Série de Feu';

  @override
  String get streakFreeze => 'Bouclier de série';

  @override
  String get streakFreezeDescription =>
      'Gardez votre série si vous manquez un jour';

  @override
  String get streakFreezeUsed => 'Un gel a protégé votre série.';

  @override
  String get streakFrozen => 'Série gelée';

  @override
  String get streakGotIt => 'COMPRIS';

  @override
  String get streakKeepAlive => 'Gardez votre série active!';

  @override
  String get streakKeepAliveDesc =>
      'Terminez une leçon chaque jour pour maintenir votre série.\nChaque jour compte pour renforcer votre bouclier numérique.';

  @override
  String get streakKeepCommitment => 'GARDER MON ENGAGEMENT';

  @override
  String get streakLongest => 'Meilleure série';

  @override
  String get streakMessage100Days => '100 jours. Légende.';

  @override
  String get streakMessage14Days => 'Deux semaines. Votre bouclier brille.';

  @override
  String get streakMessage30Days => 'Un mois. Vous êtes un Gardien Digital.';

  @override
  String get streakMessage3Days => '3 jours. Bon début.';

  @override
  String get streakMessage50Days => '50 jours de protection constante.';

  @override
  String get streakMessage7Days => 'Une semaine ! Continuez.';

  @override
  String get streakMessageActive =>
      'Série active ! La constance est votre meilleure arme aujourd\'hui.';

  @override
  String get streakMessageAtRisk => 'Votre série est en danger !';

  @override
  String get streakMessageCloser =>
      'Un jour de plus, un pas de plus vers votre objectif.';

  @override
  String get streakMessageEachDay =>
      'Chaque jour compte. Votre engagement vous rend plus fort.';

  @override
  String get streakMessageKeepGoing =>
      'Continuez comme ça ! La discipline d\'aujourd\'hui est la victoire de demain.';

  @override
  String get streakMessageKeepProtecting => 'Continuez à vous protéger !';

  @override
  String get streakMessageNew =>
      'Une nouvelle série ! Entraînez-vous chaque jour et aidez-la à grandir.';

  @override
  String get streakMessageStartActivities =>
      'Complétez des activités pour commencer votre série.';

  @override
  String get streakMsg1 =>
      'Une nouvelle série! Pratiquez chaque jour et aidez-la à grandir.';

  @override
  String get streakMsg2 =>
      'Série active! La constance est votre meilleure arme aujourd\'hui.';

  @override
  String get streakMsg3 =>
      'Chaque jour compte. Votre engagement vous rend plus fort.';

  @override
  String get streakMsg4 =>
      'Continuez! La discipline d\'aujourd\'hui est votre victoire de demain.';

  @override
  String get streakMsg5 =>
      'Un jour de plus, un pas de plus vers votre objectif.';

  @override
  String get streakNoActiveStreak => 'Aucune série active';

  @override
  String get streakReminder => 'Rappels de série';

  @override
  String get streakReminderSubtitle =>
      'Recevez des rappels pour maintenir votre série';

  @override
  String get streakRewards =>
      'Récompenses exclusives en atteignant vos objectifs';

  @override
  String get streakShieldActive =>
      'Bouclier actif — votre série est protégée aujourd\'hui!';

  @override
  String get streakShieldOnboarding =>
      'Achetez un bouclier pour protéger votre série si vous manquez un jour.';

  @override
  String get streakStrongerShield => 'Un bouclier plus fort chaque jour';

  @override
  String get streakTitle => 'Ma Série';

  @override
  String get streakTitleShort => 'Série';

  @override
  String get summarizeButton => 'Résumé rapide';

  @override
  String get summaryCommitment => 'Engagement';

  @override
  String get summaryDailyGoal => 'Objectif quotidien';

  @override
  String get summaryGoodWork => 'Bon travail!';

  @override
  String get summaryInterest => 'Intérêt';

  @override
  String get summaryKeepPracticing => 'Continuez à pratiquer';

  @override
  String get summaryKnowledge => 'Connaissances';

  @override
  String get summaryLearning => 'Apprentissage';

  @override
  String get summaryMotivations => 'Motivations';

  @override
  String get summaryOrigin => 'Origine';

  @override
  String get summaryPerfect => 'Parfait!';

  @override
  String get summaryReady =>
      'Tout est prêt pour commencer votre voyage en sécurité numérique.';

  @override
  String summaryStreakDays(Object days) {
    return '+$days jour(s)';
  }

  @override
  String get summaryXpBonus => 'Bonus XP';

  @override
  String get summaryXpEarned => 'XP gagné';

  @override
  String get supporterBadge => 'Supporter';

  @override
  String get syncSnackbar => 'Progression synchronisée';

  @override
  String get syncStatus => 'État de la synchronisation';

  @override
  String get syncing => 'Synchronisation en cours...';

  @override
  String get termsConditions => 'Conditions d\'utilisation';

  @override
  String get thankYouForSupport => 'Merci pour votre soutien!';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeDarkLabel => 'Sombre';

  @override
  String get themeLabel => 'Thème';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeLightLabel => 'Clair';

  @override
  String get themeSystem => 'Selon le système';

  @override
  String get themeSystemLabel => 'Système';

  @override
  String get themeTitle => 'Apparence';

  @override
  String get tierBasic => 'Basique';

  @override
  String get tierCrystal => 'Cristal';

  @override
  String get tierGlow => 'Lueur';

  @override
  String get tierInactive => 'Inactif';

  @override
  String get tierLegendary => 'Légendaire';

  @override
  String get tierParticles => 'Particules';

  @override
  String get totalProgress => 'Progression totale';

  @override
  String get tryAgain => 'Connectez-vous et réessayez.';

  @override
  String tutorLessonsProgress(Object completed, Object required) {
    return '$completed / $required leçons';
  }

  @override
  String get tutorLocked => 'Tuteur IA Verrouillé';

  @override
  String get tutorLockedDescription =>
      'Terminez au moins 10 leçons pour débloquer Sage, votre tuteur personnel en cybersécurité.';

  @override
  String tutorMotivationAlmost(Object count) {
    return 'Presque, il ne vous manque que $count leçons. Continuez!';
  }

  @override
  String get tutorMotivationGeneral =>
      'Chaque leçon vous rapproche de votre tuteur personnel en cybersécurité.';

  @override
  String tutorMotivationGood(Object count) {
    return 'Bon rythme! Il vous manque $count leçons pour accéder à Sage.';
  }

  @override
  String get tutorSampleAnswer1 =>
      'Ne partagez jamais votre mot de passe. Utilisez un gestionnaire de mots de passe et activez l\'authentification à deux facteurs.';

  @override
  String get tutorSampleQuestion1 =>
      'Que dois-je faire si je reçois un e-mail suspect ?';

  @override
  String get tutorSampleQuestion2 =>
      'Comment puis-je créer un mot de passe fort ?';

  @override
  String get tutorSampleTitle => 'Exemple de conversation';

  @override
  String get tutorTitle => 'Tuteur IA';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get tutorialStart => 'C\'est parti!';

  @override
  String get tutorialStep1 =>
      'Bonjour! Je suis Sage, votre guide en cybersécurité.';

  @override
  String get tutorialStep2 =>
      'Terminez des leçons pour gagner des dons et monter de niveau.';

  @override
  String get tutorialStep3 =>
      'Maintenez votre série quotidienne pour débloquer des coffres spéciaux.';

  @override
  String get tutorialStep4 =>
      'Votre mission: protéger votre identité numérique. Apprenons ensemble!';

  @override
  String get unknownLabel => 'Inconnu';

  @override
  String get updateChangelog => 'Mises à jour et nouveautés';

  @override
  String get updateChangelogDesc =>
      'Nouvel écran dans la barre inférieure affichant l\'historique des modifications et les actualités.';

  @override
  String get updateChestSystem => 'Coffres de série et leçon';

  @override
  String get updateChestSystemDesc =>
      'Nouveau système de coffres : coffre quotidien pour la série, coffre de leçon toutes les 3/5/6/10 leçons terminées.';

  @override
  String get updateDailyMissions => 'Missions quotidiennes';

  @override
  String get updateDailyMissionsDesc =>
      'Système de missions quotidiennes avec récompenses en dons et expérience.';

  @override
  String get updateEnergySystem => 'Système d\'Énergie';

  @override
  String get updateEnergySystemDesc =>
      'Maintenant chaque leçon consomme de l\'énergie. Répondez correctement pour dépenser 1, échouer coûte 2. Les combos régénèrent l\'énergie. À 0 vous ne pouvez pas continuer.';

  @override
  String get updateFirstVersion => 'Première version';

  @override
  String get updateFirstVersionDesc =>
      'Lancement initial avec leçons interactives, série quotidienne, dons, boutique et profil utilisateur.';

  @override
  String get updateImprovedIcons => 'Icônes d\'objets améliorées';

  @override
  String get updateImprovedIconsDesc =>
      'Tous les objets spéciaux ont désormais des icônes personnalisées et plus accrocheuses dans la boutique et l\'inventaire.';

  @override
  String get updateInfiniteEnergy => 'Énergie Infinie';

  @override
  String get updateInfiniteEnergyDesc =>
      'Nouvel objet spécial dans la boutique qui donne une énergie illimitée pendant un temps limité. Activez-le depuis votre inventaire.';

  @override
  String get updateLessonBoosters => 'Boosters de leçon';

  @override
  String get updateLessonBoostersDesc =>
      'Nouveaux objets : Boost XP (2x), Multiplicateur d\'XP (2x dans les coffres), Boost de Chance (2x probabilités). Achetez et activez depuis la boutique.';

  @override
  String get updateMercadoPago => 'Mercado Pago intégré';

  @override
  String get updateMercadoPagoDesc =>
      'Paiements directs avec Mercado Pago pour les packs de dons et bundles. Paiement WhatsApp aussi disponible.';

  @override
  String get updateNew => 'NOUVEAU';

  @override
  String get updateProgrammaticMascot => 'Mascotte programmatique';

  @override
  String get updateProgrammaticMascotDesc =>
      'La mascotte est désormais dessinée avec CustomPainter. 29 émotions, sans assets, transitions fluides.';

  @override
  String get updateStreakProtectorImproved => 'Protecteur de série amélioré';

  @override
  String get updateStreakProtectorImprovedDesc =>
      'Limite maximale de 2 protecteurs. Atteint, les offres de boosters s\'affichent à la place.';

  @override
  String get updateTestFix => 'Correction des tests unitaires';

  @override
  String get updateTestFixDesc =>
      '7 tests échoués corrigés. Tous les tests passent désormais (419 tests). 0 problèmes d\'analyse.';

  @override
  String get updateTypeFeature => 'NOUVELLE FONCTION';

  @override
  String get updateTypeFix => 'CORRECTION';

  @override
  String get updateTypeImprovement => 'AMÉLIORATION';

  @override
  String get updateTypedRoutes => 'Routes typées avec GoRouter Builder';

  @override
  String get updateTypedRoutesDesc =>
      'Les routes splash et welcome sont désormais typées, détectant les erreurs à la compilation.';

  @override
  String get updates => 'Actualités';

  @override
  String get updatesTitle => 'Actualités et mises à jour';

  @override
  String get verifyEmailCheckButton => 'J\'ai déjà vérifié';

  @override
  String verifyEmailMessage(Object email) {
    return 'Nous avons envoyé un lien de vérification à $email. Cliquez sur le lien pour activer votre compte.';
  }

  @override
  String get verifyEmailNotVerified =>
      'Votre e-mail n\'a pas encore été vérifié. Vérifiez votre boîte de réception.';

  @override
  String get verifyEmailResendButton => 'Renvoyer l\'e-mail de vérification';

  @override
  String get verifyEmailResendError =>
      'Impossible de renvoyer l\'e-mail. Réessayez.';

  @override
  String get verifyEmailSent =>
      'E-mail de vérification envoyé. Vérifiez votre boîte de réception.';

  @override
  String get verifyEmailSignOut => 'Se déconnecter';

  @override
  String get verifyEmailSuccess => 'E-mail vérifié ! Bienvenue sur SAGEN.';

  @override
  String get verifyEmailTitle => 'Vérifiez votre e-mail';

  @override
  String get viewAchievements => 'Voir les accomplissements';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get weeklyChestComplete => 'Coffre hebdomadaire gagné!';

  @override
  String get weeklyChestDesc =>
      'Terminez 5 missions quotidiennes pour un coffre épique';

  @override
  String get weeklyChestProgress => 'Progression Coffre Hebdomadaire';

  @override
  String weeklyChestProgressCount(Object done, Object total) {
    return '$done/$total';
  }

  @override
  String get welcomeLoginButton => 'J\'AI DÉJÀ UN COMPTE';

  @override
  String get welcomeStartButton => 'COMMENCER MAINTENANT';

  @override
  String get welcomeSubtitle =>
      'Analyse intelligente et sécurité numérique.\nGratuit à vie.';

  @override
  String get wizardAllAbove => 'Tout ce qui précède';

  @override
  String get wizardAppStore => 'App Store';

  @override
  String get wizardArticles => 'Lire des articles';

  @override
  String get wizardBoostStudies => 'Booster mes études';

  @override
  String get wizardChatSage => 'Discuter avec Sage';

  @override
  String get wizardCommit14 => '14 jours';

  @override
  String get wizardCommit14Sub => '80 dons';

  @override
  String get wizardCommit30 => '30 jours';

  @override
  String get wizardCommit30Sub => '200 dons';

  @override
  String get wizardCommit50 => '50 jours';

  @override
  String get wizardCommit50Sub => '400 dons';

  @override
  String get wizardCommit7 => '7 jours';

  @override
  String get wizardCommit7Sub => '30 dons';

  @override
  String get wizardCommitment => 'Choisissez votre engagement';

  @override
  String get wizardCommitmentSage => 'Sélectionnez vos objectifs de constance';

  @override
  String get wizardConfirmed => 'Engagement confirmé';

  @override
  String get wizardConfirmedSage =>
      'Vous avez configuré votre parcours d\'apprentissage!';

  @override
  String get wizardCuriosity => 'Par curiosité';

  @override
  String get wizardDetectScams => 'Détecter les arnaques';

  @override
  String get wizardFacebook => 'Facebook';

  @override
  String get wizardFriends => 'Amis';

  @override
  String get wizardGoal10 => '10 min';

  @override
  String get wizardGoal10Sub => 'Normal';

  @override
  String get wizardGoal15 => '15 min';

  @override
  String get wizardGoal15Sub => 'Sérieux';

  @override
  String get wizardGoal3 => '3 min';

  @override
  String get wizardGoal30 => '30 min';

  @override
  String get wizardGoal30Sub => 'Intense';

  @override
  String get wizardGoal3Sub => 'Détendu';

  @override
  String get wizardGoogle => 'Google';

  @override
  String get wizardHaveFun => 'Pour m\'amuser';

  @override
  String get wizardHowDidYouFind => 'Comment avez-vous connu SAGEN?';

  @override
  String get wizardHowDidYouFindSage =>
      'Dites-moi, comment nous avez-vous trouvés?';

  @override
  String get wizardHowFound => 'Comment as-tu trouvé SAGEN ?';

  @override
  String get wizardHowFoundSage => 'Dis-moi, comment nous as-tu trouvés ?';

  @override
  String get wizardHowMuchKnow => 'Que sais-tu sur la sécurité numérique ?';

  @override
  String get wizardHowMuchKnowSage => 'Que sais-tu du sujet ?';

  @override
  String get wizardHowMuchSage => 'Que savez-vous du sujet?';

  @override
  String get wizardHowMuchYouKnow => 'Que savez-vous de la sécurité numérique?';

  @override
  String get wizardHowPrefer => 'Comment préférez-vous apprendre?';

  @override
  String get wizardHowPreferSage =>
      'Choisissez vos façons préférées d\'apprendre';

  @override
  String get wizardInstagram => 'Instagram';

  @override
  String get wizardLevel1 => 'Je débute';

  @override
  String get wizardLevel1Sub => 'Je n\'ai jamais exploré ce sujet';

  @override
  String get wizardLevel2 => 'Je connais quelques concepts';

  @override
  String get wizardLevel2Sub => 'Je reconnais quelques termes';

  @override
  String get wizardLevel3 => 'Je peux me défendre';

  @override
  String get wizardLevel3Sub => 'Je comprends et pratique les bases';

  @override
  String get wizardLevel4 => 'Je comprends plusieurs sujets';

  @override
  String get wizardLevel4Sub => 'Je maîtrise plusieurs concepts';

  @override
  String get wizardLevel5 => 'Je connais bien le sujet';

  @override
  String get wizardLevel5Sub => 'Je peux débattre de sujets avancés';

  @override
  String get wizardLinks => 'Analyser des liens';

  @override
  String get wizardNews => 'Actualités';

  @override
  String get wizardOther => 'Autres';

  @override
  String get wizardPrepareWork => 'Me préparer pour le travail';

  @override
  String get wizardProtect => 'Me protéger';

  @override
  String get wizardProtectAccounts => 'Protéger mes comptes';

  @override
  String get wizardProtectFamily => 'Protéger ma famille';

  @override
  String get wizardProtectPrivacy => 'Protéger ma vie privée';

  @override
  String get wizardQuizzes => 'Pratiquer avec des quiz';

  @override
  String get wizardSafeBrowsing => 'Naviguer en sécurité';

  @override
  String get wizardTV => 'TV';

  @override
  String get wizardTikTok => 'TikTok';

  @override
  String get wizardTimeDedicate =>
      'Combien de temps pouvez-vous consacrer par jour?';

  @override
  String get wizardTimeSage => 'Choisissez votre rythme d\'apprentissage idéal';

  @override
  String get wizardVideos => 'Regarder des vidéos éducatives';

  @override
  String get wizardWelcome => 'Bienvenue sur SAGEN!';

  @override
  String get wizardWelcomeSage =>
      'Bonjour! Je suis Sage, votre guide en sécurité numérique. Commençons?';

  @override
  String get wizardWelcomeTitle => 'Bienvenue sur SAGEN!';

  @override
  String get wizardWhatLearn => 'Qu\'aimeriez-vous apprendre?';

  @override
  String get wizardWhatLearnSage => 'Qu\'aimeriez-vous apprendre en premier?';

  @override
  String get wizardWhyLearn => 'Pourquoi voulez-vous apprendre?';

  @override
  String get wizardWhyLearnSage =>
      'Pourquoi voulez-vous apprendre la sécurité numérique?';

  @override
  String get wizardYouTube => 'YouTube';

  @override
  String get xpBoostLabel => 'x2 Boost XP';

  @override
  String get xpLevelUp => 'Niveau supérieur !';

  @override
  String xpReward(Object xp) {
    return '+$xp XP';
  }

  @override
  String xpRewardLabel(Object gems) {
    return '+$gems XP';
  }

  @override
  String get yourActivity => 'Votre activité';

  @override
  String get yourLearning => 'Votre apprentissage';

  @override
  String get xpLabel => 'XP';

  @override
  String get xpMultiplier => 'x2 XP';

  @override
  String get chatTypingIndicator => 'Sage écrit...';

  @override
  String get demoModeOffline => 'MODE DÉMO — Hors ligne';

  @override
  String get errorSync => 'Erreur de synchronisation';

  @override
  String shareChestText(Object items, Object type) {
    return 'J\'ai obtenu $items d\'un coffre $type sur SAGEN !';
  }

  @override
  String get paymentMethodsLocal => 'WhatsApp / Yape / Plin';

  @override
  String get paymentMethodsMercadoPago => 'Mercado Pago';

  @override
  String get streakFlame => 'Flamme de série';

  @override
  String treasureChest(Object type) {
    return 'Coffre au trésor $type';
  }

  @override
  String get errorRestart => 'Redémarrer';

  @override
  String get chatEmptyDesc =>
      'Posez une question sur la cybersécurité ou choisissez une suggestion.';

  @override
  String get continueButton => 'Continuer';

  @override
  String get shareButton => 'Partager';

  @override
  String get tapToContinue => 'Appuyez pour continuer';

  @override
  String get paymentSuccessful => 'Paiement réussi';

  @override
  String get errorLoadingQuestions =>
      'Erreur lors du chargement des questions.';

  @override
  String get errorGenericShort => 'Erreur';

  @override
  String quizTimeRemaining(Object time) {
    return 'Temps restant : $time';
  }

  @override
  String get quizVerdictCorrect => 'Bonne réponse';

  @override
  String get quizVerdictIncorrect => 'Mauvaise réponse';

  @override
  String get exitQuizTitle => 'Êtes-vous sûr de vouloir quitter la leçon ?';

  @override
  String get exitQuizContent => 'Êtes-vous sûr de vouloir quitter le quiz ?';

  @override
  String currentStreakDays(Object count) {
    return 'Série actuelle : $count jours';
  }

  @override
  String get activityMap30Days => 'Carte d\'activité des 30 derniers jours';

  @override
  String courseProgressLabel(Object percent) {
    return 'Progression totale du cours : $percent%';
  }

  @override
  String stageProgressLabel(Object percent) {
    return 'Progression de l\'étape : $percent%';
  }

  @override
  String collapseSession(Object title) {
    return 'Réduire la session : $title';
  }

  @override
  String expandSession(Object title) {
    return 'Développer la session : $title';
  }

  @override
  String xpGainedLabel(Object xp) {
    return '+$xp XP gagnés';
  }

  @override
  String accuracyPercentLabel(Object percent) {
    return 'Précision : $percent%';
  }

  @override
  String timeLabel(Object time) {
    return 'Temps : $time';
  }

  @override
  String livesRemainingLabel(Object count) {
    return 'Vies restantes : $count sur 3';
  }

  @override
  String get miniGameExitTitle => 'Quitter le jeu ?';

  @override
  String get miniGameExitContent =>
      'Vous perdrez votre progression. Êtes-vous sûr ?';

  @override
  String get paymentCancelTitle => 'Annuler le paiement';

  @override
  String get paymentCancelContent =>
      'Êtes-vous sûr de vouloir annuler ? La progression sera perdue.';

  @override
  String resultXpGained(Object xp) {
    return '$xp gagnés';
  }

  @override
  String resultAccuracyLabel(Object percent) {
    return 'Précision : $percent%';
  }

  @override
  String resultLivesLabel(Object count) {
    return 'Vies : $count';
  }
}
