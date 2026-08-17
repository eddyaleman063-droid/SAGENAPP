// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutSage => 'About Sage';

  @override
  String get aboutSection => 'About';

  @override
  String get achievementConqueror => 'Conqueror';

  @override
  String get achievementConquerorDesc => 'Complete your first stage';

  @override
  String get achievementConstant => 'Constant';

  @override
  String get achievementConstantDesc => '3-day streak';

  @override
  String get achievementCurious => 'Curious';

  @override
  String get achievementCuriousDesc => 'Talk to Sage 10 times';

  @override
  String get achievementCyberGuardian => 'Cyber Guardian';

  @override
  String get achievementCyberGuardianDesc => 'Complete 50 lessons';

  @override
  String get achievementDigitalMaster => 'Digital Master';

  @override
  String get achievementDigitalMasterDesc => 'Complete all stages';

  @override
  String get achievementDigitalStudent => 'Digital Student';

  @override
  String get achievementDigitalStudentDesc => 'Complete 10 lessons';

  @override
  String get achievementDigitalWeek => 'Digital Week';

  @override
  String get achievementDigitalWeekDesc => '7-day streak';

  @override
  String get achievementFirstShield => 'First Shield';

  @override
  String get achievementFirstShieldDesc => 'Complete your first lesson';

  @override
  String get achievementGuardian => 'Guardian';

  @override
  String get achievementGuardianDesc => 'Complete 25 lessons';

  @override
  String get achievementLearner => 'Learner';

  @override
  String get achievementLearnerDesc => 'Complete 5 lessons';

  @override
  String get achievementLegendaryStreak => 'Legendary Streak';

  @override
  String get achievementLegendaryStreakDesc => '30-day streak';

  @override
  String get achievementLocked => '???';

  @override
  String get achievementPerfect => 'Perfect';

  @override
  String get achievementPerfectDesc => 'Complete a lesson without mistakes';

  @override
  String get acquired => 'Acquired';

  @override
  String get adminCreditDonationA11y => 'Credit Donations';

  @override
  String get adminCreditDonationButton => 'Credit Donations';

  @override
  String adminCreditDonationSuccess(Object gems, Object userId) {
    return '$gems donations credited to $userId';
  }

  @override
  String get adminCreditDonationTitle => 'Admin — Credit Donations';

  @override
  String get adminCreditError =>
      'Error crediting. Verify your user is in the Firestore \"admins\" collection.';

  @override
  String adminCreditSuccessNotification(Object gems, Object userId) {
    return '$gems donations credited to $userId';
  }

  @override
  String get adminDonations => 'Donations';

  @override
  String get adminFieldAmount => 'Amount';

  @override
  String get adminFieldDonationAmount => 'Donation amount';

  @override
  String get adminFieldUserId => 'User ID';

  @override
  String get adminInvalidInput => 'Enter a valid User ID and amount';

  @override
  String get adminMercadoPago => 'Mercado Pago';

  @override
  String get adminPaymentMethod => 'Payment method';

  @override
  String get adminTitle => 'Admin — Credit Donations';

  @override
  String get adminUserId => 'User ID';

  @override
  String get adminVerifyingPermissions => 'Verifying admin permissions…';

  @override
  String get adminWhatsapp => 'WhatsApp / Yape / Plin';

  @override
  String get analyzeFile => 'Analyze file';

  @override
  String get analyzeLink => 'Analyze link';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get appName => 'SAGEN';

  @override
  String get appSlogan => 'Your digital shield';

  @override
  String get authAge => 'Age';

  @override
  String get authBack => 'Back';

  @override
  String get authCanceled => 'Sign in canceled';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authCreateAccountError => 'Error creating account';

  @override
  String get authCredentialExpired => 'Session expired. Please log in again.';

  @override
  String get authDefault => 'Authentication error';

  @override
  String get authDeleteAccountFailed => 'Could not delete account. Try again.';

  @override
  String get authEmailError => 'Enter your email';

  @override
  String get authEmailInUse => 'An account already exists with this email';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailVerificationSent =>
      'Check your email to verify your account';

  @override
  String get authEnterEmailError => 'Enter your email';

  @override
  String get authFacebookButton => 'Continue with Facebook';

  @override
  String get authFacebookError => 'Error signing in with Facebook';

  @override
  String get authFirebaseUnavailable => 'Firebase is not available';

  @override
  String get authForgotPasswordButton => 'RESET PASSWORD';

  @override
  String get authForgotPasswordDesc =>
      'We\'ll send you a link to reset your password.';

  @override
  String get authForgotPasswordTitle => 'Reset password';

  @override
  String get authFullName => 'Full name';

  @override
  String get authGoogleButton => 'Continue with Google';

  @override
  String get authGoogleError => 'Error signing in with Google';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authInvalidCredential => 'Incorrect email or password';

  @override
  String get authInvalidEmail => 'Invalid email format';

  @override
  String get authLoginButton => 'LOG IN';

  @override
  String get authLoginError => 'Error logging in';

  @override
  String get authLoginLink => 'Log in';

  @override
  String get authLoginTitle => 'Enter your details';

  @override
  String get authNameError => 'Enter your name';

  @override
  String get authNetworkError => 'No internet connection';

  @override
  String get authNoAccount => 'Don\'t have an account? ';

  @override
  String get authNotAuthenticated => 'No authenticated user';

  @override
  String get authNotFound => 'No account found with this email';

  @override
  String get authNotFoundCancel => 'Cancel';

  @override
  String get authNotFoundCreate => 'Create account';

  @override
  String authNotFoundMessage(Object email) {
    return 'No account is registered with $email. Would you like to create a new account and start learning?';
  }

  @override
  String get authNotFoundTitle => 'Account not found';

  @override
  String get authNotVerified => 'Email not verified yet. Check your inbox.';

  @override
  String get authNullToken => 'Could not get Facebook token';

  @override
  String get authNullUser => 'Could not get user';

  @override
  String get authOrRegisterWith => 'or sign up with';

  @override
  String get authPasswordError => 'Enter your password';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordMinError =>
      'Password must be 8+ characters with uppercase, lowercase, and a number';

  @override
  String get authPasswordMinHint => 'Password (8+ chars, A-Z, a-z, 0-9)';

  @override
  String get authPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get authPrivacy => 'Your information is protected.';

  @override
  String get authRateLimited => 'Too many attempts. Please wait a few seconds.';

  @override
  String get authReauthError => 'Could not verify credentials. Try again.';

  @override
  String get authReauthRequiredForDelete =>
      'Please enter your password to delete your account.';

  @override
  String get authRecoveryEmailSentDesc =>
      'Check your inbox and follow the instructions to reset your password.';

  @override
  String get authRecoveryEmailSentMessage => 'Recovery email sent';

  @override
  String get authRecoveryEmailSentTitle => 'Email sent';

  @override
  String get authRecoveryError => 'Could not send recovery email';

  @override
  String get authRegisterFacebookError => 'Error signing up with Facebook';

  @override
  String get authRegisterGoogleError => 'Error signing up with Google';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authResendEmailError => 'Could not resend verification email';

  @override
  String get authSendEmailError => 'Error sending email';

  @override
  String get authSendLink => 'Send link';

  @override
  String get authSubtitle =>
      'Learn, protect yourself, and browse the internet more safely.';

  @override
  String get authTitle => 'Your digital protection starts here';

  @override
  String get authTokenExpired => 'Session expired. Please log in again.';

  @override
  String get authTooManyRequests => 'Too many attempts. Please wait.';

  @override
  String get authUnknown => 'An unexpected error occurred';

  @override
  String get authVerifyError => 'Could not verify. Try again.';

  @override
  String get authWeakPassword => 'Password must be at least 6 characters';

  @override
  String get authWrongPassword => 'Incorrect password';

  @override
  String get back => 'Back';

  @override
  String get backButton => 'Back';

  @override
  String get biometricPrompt => 'Unlock SAGEN to continue';

  @override
  String get biometricReason => 'Unlock SAGEN to continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get careerCertifications => 'Certifications';

  @override
  String get careerDescription =>
      'Earn certifications and develop skills that make you valuable in the digital economy.';

  @override
  String get careerOpp1 => 'Digital Security Consultant';

  @override
  String get careerOpp1Desc => 'Help businesses protect their data';

  @override
  String get careerOpp2 => 'Awareness Trainer';

  @override
  String get careerOpp2Desc => 'Teach others to stay safe online';

  @override
  String get careerOpp3 => 'Freelance Security Auditor';

  @override
  String get careerOpp3Desc => 'Offer security audits to clients';

  @override
  String get careerOpportunities => 'Economic Opportunities';

  @override
  String get careerSkill1 => 'Password Security';

  @override
  String get careerSkill2 => 'Phishing Detection';

  @override
  String get careerSkill3 => 'Privacy Protection';

  @override
  String get careerSkill4 => 'Network Security';

  @override
  String get careerSkill5 => 'Incident Response';

  @override
  String get careerSkills => 'Skills you\'ll develop';

  @override
  String get careerSubtitle => 'Your cybersecurity career path';

  @override
  String get careerTitle => 'Career and Certifications';

  @override
  String get challengeComplete => 'Complete the phrase';

  @override
  String get challengeCreatePassword => 'Create password';

  @override
  String get challengeDetectRisk => 'Detect risk';

  @override
  String get challengeMiniCase => 'Real case';

  @override
  String get challengeMultiple => 'Multiple choice';

  @override
  String get challengeSafe => 'Safe';

  @override
  String get challengeSuspicious => 'Suspicious';

  @override
  String get challengeTrueFalse => 'True / False';

  @override
  String get challengeWhatWouldYouDo => 'What would you do?';

  @override
  String challenge_analyze_link_desc(Object count) {
    return 'Analyze $count link(s)';
  }

  @override
  String get challenge_analyze_link_title => 'Analyze Links';

  @override
  String challenge_answer_questions_desc(Object count) {
    return 'Answer $count question(s)';
  }

  @override
  String get challenge_answer_questions_title => 'Answer Questions';

  @override
  String challenge_check_in_desc(Object count) {
    return 'Check in $count time(s)';
  }

  @override
  String get challenge_check_in_title => 'Daily Check-in';

  @override
  String challenge_complete_lesson_desc(Object count) {
    return 'Complete $count lesson(s)';
  }

  @override
  String get challenge_complete_lesson_title => 'Complete Lessons';

  @override
  String challenge_complete_session_desc(Object count) {
    return 'Complete $count learning session(s)';
  }

  @override
  String get challenge_complete_session_title => 'Learning Sessions';

  @override
  String get challenge_complete_stage_desc => 'Complete 1 stage';

  @override
  String get challenge_complete_stage_title => 'Complete Stage';

  @override
  String challenge_correct_streak_desc(Object count) {
    return 'Get $count correct answers in a row';
  }

  @override
  String get challenge_correct_streak_title => 'Correct Streak';

  @override
  String challenge_detect_phishing_desc(Object count) {
    return 'Detect $count phishing attempt(s)';
  }

  @override
  String get challenge_detect_phishing_title => 'Detect Phishing';

  @override
  String challenge_earn_xp_desc(Object xp) {
    return 'Earn $xp XP';
  }

  @override
  String get challenge_earn_xp_title => 'Earn XP';

  @override
  String challenge_learn_minutes_desc(Object count) {
    return 'Learn for $count minutes';
  }

  @override
  String get challenge_learn_minutes_title => 'Learning Time';

  @override
  String challenge_learn_topic_desc(Object count) {
    return 'Learn $count topic(s)';
  }

  @override
  String get challenge_learn_topic_title => 'Learn a Topic';

  @override
  String get challenge_perfect_lesson_desc =>
      'Complete a lesson with no errors';

  @override
  String get challenge_perfect_lesson_title => 'Perfect Lesson';

  @override
  String challenge_privacy_check_desc(Object count) {
    return 'Review privacy settings $count time(s)';
  }

  @override
  String get challenge_privacy_check_title => 'Privacy Check';

  @override
  String challenge_quiz_night_desc(Object count) {
    return 'Complete $count mini quiz(es)';
  }

  @override
  String get challenge_quiz_night_title => 'Mini Quiz';

  @override
  String challenge_review_tips_desc(Object count) {
    return 'Review $count security tip(s)';
  }

  @override
  String get challenge_review_tips_title => 'Review Security Tips';

  @override
  String challenge_security_audit_desc(Object count) {
    return 'Complete $count security audit(s)';
  }

  @override
  String get challenge_security_audit_title => 'Security Audit';

  @override
  String challenge_share_knowledge_desc(Object count) {
    return 'Share $count tip(s)';
  }

  @override
  String get challenge_share_knowledge_title => 'Share Knowledge';

  @override
  String challenge_social_awareness_desc(Object count) {
    return 'Complete $count social awareness challenge(s)';
  }

  @override
  String get challenge_social_awareness_title => 'Social Awareness';

  @override
  String challenge_streak_milestone_desc(Object count) {
    return 'Maintain a $count-day streak';
  }

  @override
  String get challenge_streak_milestone_title => 'Streak Milestone';

  @override
  String challenge_talk_sage_desc(Object count) {
    return 'Chat with Sage $count time(s)';
  }

  @override
  String get challenge_talk_sage_title => 'Chat with Sage';

  @override
  String challenge_test_password_desc(Object count) {
    return 'Test $count password(s)';
  }

  @override
  String get challenge_test_password_title => 'Test Passwords';

  @override
  String get challenge_use_dark_mode_desc => 'Use dark mode';

  @override
  String get challenge_use_dark_mode_title => 'Dark Mode';

  @override
  String get changelogV4 => 'Foundation';

  @override
  String get changelogV4_1 => '8 learning stages with 1,099 lessons';

  @override
  String get changelogV4_2 => 'Daily streaks and challenges';

  @override
  String get changelogV4_3 => 'Achievement system';

  @override
  String get changelogV5 => 'AI and Personalization';

  @override
  String get changelogV5Old => 'Chest and Gacha System';

  @override
  String get changelogV5Old_1 => 'Chest evolution system (Bronze → Legendary)';

  @override
  String get changelogV5Old_2 => 'Interactive 3D buttons';

  @override
  String get changelogV5Old_3 => 'UI redesign with Glassmorphism';

  @override
  String get changelogV5_1 => 'SAGE chat with AI for personalized help';

  @override
  String get changelogV5_2 => 'Dynamic mask emotions';

  @override
  String get changelogV5_3 => '17,157 cybersecurity questions';

  @override
  String get changelogV5_4 => 'VIP society for 30+ day streaks';

  @override
  String get chatAskSage => 'Ask Sage';

  @override
  String get chatAskSageDesc =>
      'Ask any cybersecurity question or choose a quick suggestion.';

  @override
  String get chatBlocked => 'Chat blocked';

  @override
  String get chatCancel => 'Cancel';

  @override
  String get chatClear => 'Clear';

  @override
  String get chatClearAction => 'Clear';

  @override
  String get chatClearMessage =>
      'Are you sure you want to clear this conversation? This action cannot be undone.';

  @override
  String get chatClearTitle => 'Clear conversation';

  @override
  String get chatEmptyTitle => 'Start a conversation';

  @override
  String get chatFallback => 'I couldn\'t respond right now. Please try again.';

  @override
  String get chatFallbackSubtitle =>
      'Ask anything about cybersecurity or choose a quick suggestion.';

  @override
  String get chatFallbackTitle => 'Ask Sage';

  @override
  String get chatGuideDesc => 'Your cybersecurity guide';

  @override
  String get chatGuideSubtitle => 'Your cybersecurity guide';

  @override
  String get chatHint => 'Ask Sage...';

  @override
  String get chatInputHint => 'Ask Sage...';

  @override
  String get chatNewConversation => 'New conversation';

  @override
  String get chatSageTutor => 'Sage Tutor';

  @override
  String get chatSageTutorLabel => 'Sage Tutor';

  @override
  String get checkInDesc => 'Daily check-in to keep your streak active';

  @override
  String get checkInTitle => 'Check-in';

  @override
  String get chestCollect => 'Collect';

  @override
  String chestEvolvedTo(Object type) {
    return 'Evolved to $type';
  }

  @override
  String get chestNoChange => 'No change';

  @override
  String chestOpenedTitle(Object type) {
    return '$type Chest!';
  }

  @override
  String get chestPityProgress => 'Legendary in';

  @override
  String get chestReminder => 'Chest reminders';

  @override
  String get chestReminderSubtitle => 'Get reminders to open your daily chest';

  @override
  String get chestRewardBronze => 'Bronze!';

  @override
  String get chestRewardDefault => 'Reward';

  @override
  String get chestRewardDialog => 'Chest reward dialog';

  @override
  String get chestRewardGold => 'Gold!';

  @override
  String get chestRewardLegendary => 'Legendary!';

  @override
  String get chestRewardSilver => 'Silver!';

  @override
  String get chestTapToOpen => 'Tap to open';

  @override
  String get chestTapToUpgrade => 'Tap to upgrade';

  @override
  String chestTitle(Object type) {
    return '$type Chest';
  }

  @override
  String chestTreasure(Object type) {
    return 'Treasure chest $type';
  }

  @override
  String chestTreasureLabel(Object type) {
    return '$type treasure';
  }

  @override
  String get chestTypeBronze => 'Bronze';

  @override
  String get chestTypeGold => 'Gold';

  @override
  String get chestTypeLegendary => 'Legendary';

  @override
  String get chestTypeSilver => 'Silver';

  @override
  String get chestXpBoost => 'x2 EXP';

  @override
  String get closeButton => 'Close';

  @override
  String get cloudDataDeleted => 'Cloud data deleted';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get commit1Month => '1 month';

  @override
  String get commit1Week => '1 week';

  @override
  String get commit2Weeks => '2 weeks';

  @override
  String get commitButton => 'COMMIT TO MY GOAL';

  @override
  String get commitChooseGoal => 'Choose your goal';

  @override
  String get commitChooseGoalDesc =>
      'Select how many days you will follow your learning plan.';

  @override
  String commitDays(Object days) {
    return '$days days';
  }

  @override
  String commitGoalLabel(Object days) {
    return 'Your goal: $days days';
  }

  @override
  String get commitSelected => 'SELECTED';

  @override
  String commitYourGoal(Object days) {
    return 'Your goal: $days days';
  }

  @override
  String get completePrevious => 'Complete previous stage';

  @override
  String get connectionErrorRetry => 'Connection error. Try again.';

  @override
  String continueLesson(Object title) {
    return 'Continue lesson: $title';
  }

  @override
  String get continueText => 'Continue';

  @override
  String get correct => 'Correct';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String correctAnswers(Object correct, Object total) {
    return '$correct of $total correct';
  }

  @override
  String get currencySymbol => '\$';

  @override
  String cyberQuizProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String get dailyGoalIntense => 'Intense';

  @override
  String dailyGoalMinutesPerDay(Object minutes) {
    return '$minutes min/day';
  }

  @override
  String get dailyGoalNormal => 'Normal';

  @override
  String get dailyGoalQuestion => 'What\'s your daily learning goal?';

  @override
  String get dailyGoalRelaxed => 'Relaxed';

  @override
  String get dailyGoalSerious => 'Serious';

  @override
  String get dailyMissions => 'Daily missions';

  @override
  String get dailyMissionsAllCompleted => 'All challenges completed today!';

  @override
  String get dailyMissionsDesc => 'Complete your missions to earn rewards';

  @override
  String get darkModeEnd => 'End dark mode';

  @override
  String darkModeScheduleInfo(Object end, Object start) {
    return 'Dark mode will be active from $start:00 to $end:00';
  }

  @override
  String get darkModeStart => 'Start dark mode';

  @override
  String get dayAbbrFri => 'Fri';

  @override
  String get dayAbbrMon => 'Mon';

  @override
  String get dayAbbrSat => 'Sat';

  @override
  String get dayAbbrSun => 'Sun';

  @override
  String get dayAbbrThu => 'Thu';

  @override
  String get dayAbbrTue => 'Tue';

  @override
  String get dayAbbrWed => 'Wed';

  @override
  String get dayShortFri => 'F';

  @override
  String get dayShortMon => 'M';

  @override
  String weekDayCompleted(Object day) {
    return '$day, completed';
  }

  @override
  String weekDayToday(Object day) {
    return 'Today, $day';
  }

  @override
  String get dayShortSat => 'S';

  @override
  String get dayShortSun => 'S';

  @override
  String get dayShortThu => 'T';

  @override
  String get dayShortTue => 'T';

  @override
  String get dayShortWed => 'W';

  @override
  String get streakStatusCompleted => 'completed';

  @override
  String get streakStatusToday => 'today';

  @override
  String get streakStatusPending => 'pending';

  @override
  String get daysLabel => 'days';

  @override
  String get delete => 'Delete';

  @override
  String get deleteAccountConfirm => 'Delete my account';

  @override
  String get deleteAccountDesc =>
      'This will permanently delete all your data. This action cannot be undone.';

  @override
  String get deleteAccountReauthRequired =>
      'Recent authentication required to delete account';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAction => 'Delete';

  @override
  String get deleteCloudData => 'Delete Cloud Data';

  @override
  String get deleteCloudDesc =>
      'Are you sure? This will permanently delete your saved cloud progress. Local data will not be affected.';

  @override
  String get deleteCloudTitle => 'Delete Cloud Data';

  @override
  String get deleteHistory => 'Delete Analysis History';

  @override
  String get deleteHistoryDesc =>
      'All saved link analyses will be deleted. This action cannot be undone.';

  @override
  String get deleteHistoryTitle => 'Delete History';

  @override
  String get demoModeLabel => 'DEMO MODE';

  @override
  String get demoStudentName => 'Demo Student';

  @override
  String get developedWith => 'Built with Flutter';

  @override
  String get donateToSupport => 'Donate to support';

  @override
  String get donationBasic => 'Supporter';

  @override
  String get donationBasicDesc => 'Help us keep SAGEN free';

  @override
  String get donationLabel => 'Donation';

  @override
  String get donationPopular => 'Super Supporter';

  @override
  String get donationPopularDesc => 'Exclusive badge + special thanks';

  @override
  String get donationPremium => 'Champion';

  @override
  String get donationPremiumDesc => 'All perks + your name in credits';

  @override
  String get donationValueLabel => 'Amount';

  @override
  String dot(Object number) {
    return 'Dot $number';
  }

  @override
  String get ecoCo2Saved => 'CO₂ emissions avoided';

  @override
  String get ecoComparison =>
      'SAGEN uses 99% fewer resources than traditional education';

  @override
  String get ecoDescription =>
      'Each lesson you complete saves water, reduces CO₂ emissions, and eliminates paper use.';

  @override
  String get ecoDigital => '📱 Digital: just your phone';

  @override
  String get ecoDigitalLearning => '100% Digital Learning';

  @override
  String get ecoDigitalLearningDesc =>
      'No paper, no printing, no transport needed';

  @override
  String get ecoHowItWorks => 'Digital vs Traditional';

  @override
  String get ecoLiters => 'liters';

  @override
  String get ecoPages => 'pages';

  @override
  String get ecoPaperSaved => 'Paper saved';

  @override
  String get ecoSubtitle => 'Learn while caring for the planet';

  @override
  String get ecoTitle => 'Environmental Impact';

  @override
  String get ecoTraditional => '📚 Traditional: paper, ink, transport';

  @override
  String get ecoTrees => 'trees';

  @override
  String get ecoTreesEquivalent => 'Equivalent in trees';

  @override
  String get ecoWaterSaved => 'Water saved';

  @override
  String get ecoYourImpact => 'Your environmental impact';

  @override
  String get emotionPhrase1 => 'You detect risks faster now.';

  @override
  String get emotionPhrase2 => 'Your digital habit is improving.';

  @override
  String get emotionPhrase3 =>
      'Each day you understand better how to protect yourself.';

  @override
  String get emotionPhrase4 => 'You are building a security instinct.';

  @override
  String get emotionPhrase5 => 'Your digital judgment is sharpening.';

  @override
  String get emotionPhrase6 => 'You are learning to see what others don\'t.';

  @override
  String get emotionPhrase7 => 'Your digital world is safer thanks to you.';

  @override
  String get emotionPhraseStart => 'Your digital journey begins today.';

  @override
  String get emotionalPhrase1 => 'You detect risks faster now.';

  @override
  String get emotionalPhrase2 => 'Your digital habit is improving.';

  @override
  String get emotionalPhrase3 =>
      'Each day you understand better how to protect yourself.';

  @override
  String get emotionalPhrase4 => 'You are building a security instinct.';

  @override
  String get emotionalPhrase5 => 'Your digital judgment is sharpening.';

  @override
  String get emotionalPhrase6 =>
      'You are learning to see what others don\'t see.';

  @override
  String get emotionalPhrase7 => 'Your digital world is safer because of you.';

  @override
  String get emotionalPhraseStart => 'Your digital journey begins today.';

  @override
  String get emptyChatSubtitle => 'Sage is ready to help you';

  @override
  String get emptyProfile => 'No profile data';

  @override
  String get emptyStore => 'Store is empty';

  @override
  String get emptyUpdates => 'No updates available';

  @override
  String get english => 'English';

  @override
  String get errorContentLoadFailed =>
      'We couldn\'t load the content. Check your connection and try again.';

  @override
  String get errorFeedback => 'Failed to save feedback. Try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorIntegrityCheck =>
      'An integrity issue was detected. Your progress has been saved, but please verify that it is correct.';

  @override
  String get errorLoadContent =>
      'Could not load content. Check your connection and try again.';

  @override
  String get errorLoadProgress =>
      'Could not load your progress. Check your connection and try again.';

  @override
  String get errorLoadQuestions => 'Failed to load questions. Try again.';

  @override
  String get errorNetwork => 'No internet connection. Check your network.';

  @override
  String get errorPayment => 'Payment recording failed. Please try again.';

  @override
  String get errorProgressLoadFailed =>
      'We couldn\'t load your progress. Check your connection and try again.';

  @override
  String get errorProgressReloadFailed =>
      'We couldn\'t reload your progress. Try again.';

  @override
  String get errorReloadProgress =>
      'Could not reload your progress. Try again.';

  @override
  String get errorRestartApp => 'Restart app';

  @override
  String get errorRetry => 'Try again';

  @override
  String get errorShare => 'Share failed. Please try again.';

  @override
  String get errorSomethingWrong => 'Something went wrong';

  @override
  String get errorStreak => 'Failed to save streak.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. You can try again.';

  @override
  String get exitText => 'Exit';

  @override
  String get experience => 'Experience';

  @override
  String get exportData => 'Export my data';

  @override
  String get exportDataCopied => 'Data copied to clipboard!';

  @override
  String get exportDataCopy => 'Copy to clipboard';

  @override
  String get exportDataDesc => 'Download a copy of your personal data';

  @override
  String get exportDataLoading => 'Collecting your data...';

  @override
  String get feedbackCatBug => 'Report a Bug';

  @override
  String get feedbackCatContent => 'Content';

  @override
  String get feedbackCatDesign => 'Design';

  @override
  String get feedbackCatFeature => 'Suggest a Feature';

  @override
  String get feedbackCatGeneral => 'General';

  @override
  String get feedbackCategory => 'Category';

  @override
  String get feedbackChangelog => 'What\'s New';

  @override
  String get feedbackComments => 'Comments';

  @override
  String get feedbackConfusing => 'Confused';

  @override
  String get feedbackContinue => 'Continue';

  @override
  String get feedbackExcellent => 'You\'re awesome!';

  @override
  String get feedbackGood => 'Good';

  @override
  String get feedbackHard => 'Hard';

  @override
  String get feedbackHint => 'Tell us what you think...';

  @override
  String get feedbackHowDidYouFeel => 'How did you feel?';

  @override
  String get feedbackPerfect => 'Perfect';

  @override
  String get feedbackPoor => 'We will improve';

  @override
  String get feedbackRateExperience => 'Rate your experience';

  @override
  String get feedbackSubmit => 'Submit Feedback';

  @override
  String get feedbackTapStars => 'Tap a star to rate';

  @override
  String get feedbackThanks => 'Thank you!';

  @override
  String get feedbackThanksDesc =>
      'Your feedback helps us improve SAGEN for everyone.';

  @override
  String get feedbackTitle => 'Feedback and Changelog';

  @override
  String get fileAnalyzer => 'File Analyzer';

  @override
  String get fileDangerous => 'Dangerous';

  @override
  String get fileHighRisk => 'High risk';

  @override
  String get fileLowRisk => 'Low risk';

  @override
  String get fileMediumRisk => 'Medium risk';

  @override
  String get fileSafe => 'Safe';

  @override
  String get finishText => 'Finish';

  @override
  String firstLessonProgress(Object current, Object total) {
    return 'Lesson $current of $total';
  }

  @override
  String get firstLessonSeeResults => 'SEE RESULTS';

  @override
  String get flexCardJoinAlliance => 'Join my alliance on SAGEN';

  @override
  String get fontSizeLarge => 'Large';

  @override
  String get fontSizeNormal => 'Normal';

  @override
  String get fontSizeSmall => 'Small';

  @override
  String get fontSizeTitle => 'Text size';

  @override
  String get fontSizeXLarge => 'Extra large';

  @override
  String get forceSync => 'Force Sync';

  @override
  String get free => 'Free';

  @override
  String get french => 'French';

  @override
  String get gachaChestTap => 'Gacha chest. Tap to upgrade.';

  @override
  String get gachaOrbFail => 'No change';

  @override
  String get gachaOrbSuccess => 'Upgrade successful';

  @override
  String get gems => 'gems';

  @override
  String goToLesson(Object title) {
    return 'Go to lesson: $title';
  }

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get habitMsg1 =>
      'Great work! Now let\'s strengthen your daily discipline.';

  @override
  String get habitMsg2 =>
      'First step done. Let\'s build the habit that will get you to your goal.';

  @override
  String get habitMsg3 =>
      'Excellent performance. The secret now is consistency.';

  @override
  String get habitMsg4 =>
      'Well done! Now let\'s set up your daily progress pace.';

  @override
  String get habitMsg5 =>
      'A perfect start. Let\'s secure your success by building an unbreakable habit.';

  @override
  String get habitTransition1 => 'Building your daily habit...';

  @override
  String get habitTransition2 => 'Consistency is key';

  @override
  String get habitTransition3 => 'You are making progress';

  @override
  String get habitTransition4 => 'Keep going!';

  @override
  String get habitTransition5 => 'Almost there!';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticSubtitle => 'Haptic response on interactions';

  @override
  String get heatmapLess => 'Less';

  @override
  String heatmapLessons(Object count) {
    return '$count lessons';
  }

  @override
  String get heatmapMore => 'More';

  @override
  String get heatmapTitle => 'Recent activity';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get historyDeleted => 'History deleted';

  @override
  String get historyTitle => 'History';

  @override
  String get homeAllComplete => 'All complete!';

  @override
  String get homeAllCompleteDesc => 'You have mastered all lessons.';

  @override
  String get homeContinue => 'Continue';

  @override
  String get homeDefaultName => 'Guardian';

  @override
  String levelUpCelebrationLabel(int level) {
    return 'Level up! New level: $level';
  }

  @override
  String get homeLearningPath => 'Learning path';

  @override
  String get homeTitle => 'Your digital shield is active';

  @override
  String get homeViewAchievements => 'View achievements';

  @override
  String get howItWorks => 'How SAGEN works';

  @override
  String get impactAch => 'Achievements';

  @override
  String get impactActiveUsers => 'Active users';

  @override
  String get impactCommunity => 'Community Impact';

  @override
  String get impactCountriesReached => 'Countries reached';

  @override
  String get impactDonations => 'Total Donated';

  @override
  String get impactHoursLearned => 'Hours learned';

  @override
  String get impactKnowledgeLevel => 'Cybersecurity knowledge';

  @override
  String get impactLearningJourney => 'Your Learning Journey';

  @override
  String get impactLessons => 'Lessons completed';

  @override
  String get impactLevelActiveLearner => 'Active Learner';

  @override
  String get impactLevelAwareUser => 'Aware User';

  @override
  String get impactLevelBeginner => 'Beginner';

  @override
  String get impactLevelCybersecurityExpert => 'Cybersecurity Expert';

  @override
  String get impactLevelDigitalGuardian => 'Digital Guardian';

  @override
  String impactProgressToNext(Object count) {
    return '$count lessons to next level';
  }

  @override
  String get impactProtectedUsers => 'Protected users';

  @override
  String get impactQuestionsAnswered => 'Questions answered';

  @override
  String get impactStreak => 'Current streak';

  @override
  String get impactTestimonial => 'What users are saying';

  @override
  String get impactTestimonial1 =>
      'SAGEN helped me protect my family from phishing. The interactive lessons are amazing!';

  @override
  String get impactTestimonial2 =>
      'I went from zero cybersecurity knowledge to helping my colleagues stay safe online.';

  @override
  String get impactTestimonial3 =>
      'Gamification makes learning fun. I completed 30 lessons in just 2 weeks!';

  @override
  String get impactTitle => 'My Impact';

  @override
  String get impactTotalLessons => 'Lessons completed';

  @override
  String get impactXp => 'XP earned';

  @override
  String get impactYourLevel => 'YOUR LEVEL';

  @override
  String get impactYourStats => 'Your Statistics';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get incorrectAnswer => 'Incorrect answer';

  @override
  String get infoSection => 'Information';

  @override
  String get initialAction => 'Start here';

  @override
  String get inventoryFocusElixir => 'Focus Elixir';

  @override
  String get inventoryFocusElixirActivated =>
      'Focus Elixir activated — x2 for 15 min';

  @override
  String get inventoryFocusElixirDesc => 'Multiplies EXP x2 for 15 min';

  @override
  String get inventoryMonocleAvailable =>
      'Sage Monocle available for the next challenge';

  @override
  String get inventoryPhoenixFeather => 'Phoenix Feather';

  @override
  String get inventoryPhoenixFeatherDesc =>
      'Revives your streak if lost less than 24h ago';

  @override
  String get inventoryPhoenixFeatherRestored =>
      'Phoenix Feather: streak restored';

  @override
  String get inventorySagesMonocle => 'Sage Monocle';

  @override
  String get inventorySagesMonocleDesc =>
      'Removes 2 wrong answers in a challenge';

  @override
  String get inventoryShieldProtected => 'Titanium Shield: streak protected';

  @override
  String get inventoryTitaniumShield => 'Titanium Shield';

  @override
  String get inventoryTitaniumShieldDesc =>
      'Protects your streak automatically if you miss a day';

  @override
  String get inventoryTitle => 'Inventory';

  @override
  String get inventoryUse => 'Use';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'French';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get lastSync => 'Last sync';

  @override
  String get learnSubtitle => 'Interactive cybersecurity lessons';

  @override
  String get learnTitle => 'Learn';

  @override
  String get learningPath => 'Your learning path';

  @override
  String get legalAnd => ' and ';

  @override
  String get legalPrivacy => 'I accept the privacy policy';

  @override
  String get legalRegisterAgree => 'By registering you accept our ';

  @override
  String get legalTerms => 'Terms';

  @override
  String get lessonComplete => 'Lesson complete';

  @override
  String get lessonNoQuestions => 'No questions available for this lesson';

  @override
  String get lessonNoQuestionsHint => 'Sage is curious too! Check back soon.';

  @override
  String get lessonPreparing => 'Preparing your questions...';

  @override
  String lessonProgress(Object percent) {
    return 'Progress: $percent%';
  }

  @override
  String get lessonResultsPreparing => 'Preparing results...';

  @override
  String lessonsCompleted(Object count) {
    return '$count lessons completed';
  }

  @override
  String lessonsCompletedPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# lessons completed',
      one: '# lesson completed',
    );
    return '$_temp0';
  }

  @override
  String lessonsCount(Object count) {
    return '$count lessons';
  }

  @override
  String lessonsLevel(Object level) {
    return 'Level $level';
  }

  @override
  String get lessonsNoAvailable => 'No lessons available. Check back soon.';

  @override
  String get lessonsYourPath => 'Your learning path';

  @override
  String get levelAssessment0 => 'Absolute beginner';

  @override
  String get levelAssessment1 => 'Beginner';

  @override
  String get levelAssessment2 => 'Intermediate';

  @override
  String get levelAssessment3 => 'Advanced';

  @override
  String get levelAssessment4 => 'Expert';

  @override
  String get levelAssessmentQuestion =>
      'What is your current level in cybersecurity?';

  @override
  String levelProgress(Object percent) {
    return 'Level progress: $percent percent';
  }

  @override
  String get loading => 'Loading';

  @override
  String get madeWithLove => 'Made with ♥ for students';

  @override
  String get miniGameBackupDef => 'Security copy';

  @override
  String get miniGameComplete => 'Complete!';

  @override
  String get miniGameCorrect => 'Correct';

  @override
  String get miniGameEncryptionDef => 'Data protection with key';

  @override
  String get miniGameEncryptionTerm => 'Encryption';

  @override
  String get miniGameFirewallDef => 'Network security barrier';

  @override
  String get miniGameHiddenCard => 'Hidden card';

  @override
  String get miniGameMalwareDef => 'Malicious software';

  @override
  String get miniGameMatches => 'Matches';

  @override
  String get miniGameMemory => 'Memory Match';

  @override
  String get miniGameMemoryDesc => 'Find the matching pairs';

  @override
  String get miniGameMistakes => 'Mistakes';

  @override
  String get miniGameMoves => 'Moves';

  @override
  String get miniGameOver => 'Nice try!';

  @override
  String get miniGamePattern => 'Pattern Trace';

  @override
  String get miniGamePatternDesc => 'Memorize and reproduce patterns';

  @override
  String get miniGamePhishingDef => 'Fake email that steals data';

  @override
  String get miniGamePlayAgain => 'Play Again';

  @override
  String get miniGameRound => 'Round';

  @override
  String get miniGameScore => 'Score';

  @override
  String get miniGameSortInstruction =>
      'Tap to sort each item into the correct category';

  @override
  String get miniGameSpeed => 'Speed Sort';

  @override
  String get miniGameSpeedDesc => 'Sort the elements quickly';

  @override
  String get miniGameSubtitle => 'Train your cybersecurity skills';

  @override
  String get miniGameTitle => 'Mini Games';

  @override
  String get miniGameVpnDef => 'Virtual private network';

  @override
  String get miniGameWatch => 'Watch';

  @override
  String get miniGameWord => 'Word Match';

  @override
  String get miniGameWordDesc => 'Match terms and definitions';

  @override
  String get miniGameWrong => 'Wrong';

  @override
  String get miniGameYourTurn => 'Your turn';

  @override
  String minutes(Object min) {
    return '$min min';
  }

  @override
  String minutesPerDay(Object count) {
    return '$count minutes per day';
  }

  @override
  String get missionActiveLearnerDesc => 'Complete 1 security lesson.';

  @override
  String get missionActiveLearnerTitle => 'Active learner';

  @override
  String get missionActiveStreakDesc => 'Maintain your learning streak today.';

  @override
  String get missionActiveStreakTitle => 'Active streak';

  @override
  String get missionChatWithSageDesc => 'Talk to Sage about digital security.';

  @override
  String get missionChatWithSageTitle => 'Chat with Sage';

  @override
  String get missionConsistentProtectorDesc => 'Complete 3 lessons today.';

  @override
  String get missionConsistentProtectorTitle => 'Consistent protector';

  @override
  String get missionDigitalDetectiveDesc => 'Analyze a suspicious link.';

  @override
  String get missionDigitalDetectiveTitle => 'Digital detective';

  @override
  String get missionExpressChallengeDesc =>
      'Complete a quick 30-second challenge.';

  @override
  String get missionExpressChallengeTitle => 'Express challenge';

  @override
  String get missionPerfectLessonDesc => 'Complete a lesson without mistakes.';

  @override
  String get missionPerfectLessonTitle => 'Perfect lesson';

  @override
  String get missionPhishingHunterDesc =>
      'Correctly detect a phishing attempt.';

  @override
  String get missionPhishingHunterTitle => 'Phishing hunter';

  @override
  String missionProgress(Object percent) {
    return 'Mission progress: $percent percent';
  }

  @override
  String get missionThreeQueriesDesc =>
      'Talk to Sage 3 times about different topics.';

  @override
  String get missionThreeQueriesTitle => '3 queries';

  @override
  String get monthApr => 'Apr';

  @override
  String get monthApril => 'April';

  @override
  String get monthAug => 'Aug';

  @override
  String get monthAugust => 'August';

  @override
  String get monthDec => 'Dec';

  @override
  String get monthDecember => 'December';

  @override
  String get monthFeb => 'Feb';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthJan => 'Jan';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthJul => 'Jul';

  @override
  String get monthJuly => 'July';

  @override
  String get monthJun => 'Jun';

  @override
  String get monthJune => 'June';

  @override
  String get monthMar => 'Mar';

  @override
  String get monthMarch => 'March';

  @override
  String get monthMay => 'May';

  @override
  String get monthNov => 'Nov';

  @override
  String get monthNovember => 'November';

  @override
  String get monthOct => 'Oct';

  @override
  String get monthOctober => 'October';

  @override
  String get monthSep => 'Sep';

  @override
  String get monthSeptember => 'September';

  @override
  String get motivationCareer => 'Professional career';

  @override
  String get motivationConnect => 'Connect with people';

  @override
  String get motivationDialogMultiple => 'Multiple motivations selected';

  @override
  String get motivationDialogNone => 'No motivation selected';

  @override
  String get motivationFun => 'Have fun';

  @override
  String get motivationMind => 'Train my mind';

  @override
  String get motivationOther => 'Other';

  @override
  String get motivationStudies => 'Studies';

  @override
  String get motivationTravel => 'Travel';

  @override
  String get myAccount => 'My Account';

  @override
  String get navChest => 'Chest';

  @override
  String get navHome => 'Home';

  @override
  String get navProfile => 'Profile';

  @override
  String get navRanking => 'Ranking';

  @override
  String get navSage => 'Sage';

  @override
  String get never => 'Never';

  @override
  String get newBadge => 'NEW';

  @override
  String get newsUpdates => 'News & Updates';

  @override
  String get nextText => 'Next';

  @override
  String get noConnection => 'No internet connection.';

  @override
  String get noLessonsAvailable => 'No lessons available';

  @override
  String get notFoundBackHome => 'Back to home';

  @override
  String get notFoundDescription =>
      'The page you\'re looking for doesn\'t exist.';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String get notificationReminder =>
      'Five minutes today can help you tomorrow.';

  @override
  String get notificationStreakAlive => 'Your streak is still alive!';

  @override
  String get notificationStreakLoss => 'It\'s never too late to start again.';

  @override
  String get notificationTip => 'Your digital shield is waiting for you.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get offlineAction => 'Connect and try again.';

  @override
  String get offlineMessage => 'No internet connection.';

  @override
  String get offlineNoConnection => 'No internet connection';

  @override
  String get offlineSavedForLater => 'Saved offline. We\'ll sync soon.';

  @override
  String get offlineSyncComplete => 'Sync complete!';

  @override
  String get onbDiagnosisMsg =>
      'Great! We\'ll adjust your training plan to protect your knowledge from day one.';

  @override
  String get onbGoalCommit => 'STAY COMMITTED';

  @override
  String get onbGoalIntense => 'Intense';

  @override
  String onbGoalMinPerDay(Object minutes) {
    return '$minutes min/day';
  }

  @override
  String get onbGoalNormal => 'Normal';

  @override
  String get onbGoalRelaxed => 'Relaxed';

  @override
  String get onbGoalSerious => 'Serious';

  @override
  String get onbGoalTitle => 'What is your daily learning goal?';

  @override
  String get onbLevel0 => 'Absolute zero (I don\'t know what phishing is...)';

  @override
  String get onbLevel1 => 'I know the basics...';

  @override
  String get onbLevel2 => 'Intermediate level...';

  @override
  String get onbLevel3 => 'Advanced level...';

  @override
  String get onbLevel4 => 'Cybersecurity expert...';

  @override
  String get onbLevelContinue => 'CONTINUE';

  @override
  String get onbLevelQuestion => 'What is your current level in cybersecurity?';

  @override
  String get onbLevelTitle => 'What is your current level in cybersecurity?';

  @override
  String get onbMotivationCareer => 'Professional career';

  @override
  String get onbMotivationCareerMsg => 'Great reasons to learn!';

  @override
  String get onbMotivationConnect => 'Connect with people';

  @override
  String get onbMotivationConnectMsg => 'Let\'s get you connected!';

  @override
  String get onbMotivationFun => 'Have fun';

  @override
  String get onbMotivationFunMsg => 'I love it! Having fun is my specialty.';

  @override
  String get onbMotivationMind => 'Train my mind';

  @override
  String get onbMotivationMindMsg => 'It\'s a wise decision.';

  @override
  String get onbMotivationOther => 'Other';

  @override
  String get onbMotivationOtherMsg => 'Got it! Tell me more along the way.';

  @override
  String get onbMotivationStudies => 'Studies';

  @override
  String get onbMotivationStudiesMsg =>
      'A world of opportunities will open up for you!';

  @override
  String get onbMotivationTitle =>
      'Why do you want to master the digital world?';

  @override
  String get onbMotivationTravel => 'Travel';

  @override
  String get onbMotivationTravelMsg =>
      'Nothing beats traveling with your devices 100% protected!';

  @override
  String get onbNotifActivate => 'ENABLE NOTIFICATIONS';

  @override
  String get onbNotifDesc =>
      'Enable notifications so you don\'t miss your streak, daily reminders, and important challenges.';

  @override
  String get onbNotifSkip => 'Not now';

  @override
  String get onbNotifTitle => 'Get notified?';

  @override
  String get onbProjHackerMind => 'Forge a hacker mindset';

  @override
  String get onbProjHackerMindDesc =>
      'Strategic reminders, daily challenges, and digital defense tactics.';

  @override
  String get onbProjLockAccounts => 'Lock down your accounts';

  @override
  String get onbProjLockAccountsDesc =>
      'Protect your social media and gaming accounts from hacks and theft.';

  @override
  String get onbProjNavImmunity => 'Browse with immunity';

  @override
  String get onbProjNavImmunityDesc =>
      'Detect scams, malicious links, and phishing before you click.';

  @override
  String get onbProjectionTitle => 'This is what you will master in 3 months!';

  @override
  String onbQuizIntro(Object count) {
    return 'Answer $count quick questions before your first digital training!';
  }

  @override
  String get onbRecommended => 'RECOMMENDED';

  @override
  String get onbReferralFriends => 'Friend referral';

  @override
  String get onbReferralGoogle => 'Google Search';

  @override
  String get onbReferralOther => 'Other';

  @override
  String get onbReferralPlayStore => 'Play Store';

  @override
  String get onbReferralQuestion => 'How did you discover SAGEN?';

  @override
  String get onbReferralSocial => 'Instagram / Facebook';

  @override
  String get onbReferralTiktok => 'TikTok';

  @override
  String get onbReferralTitle => 'How did you discover SAGEN?';

  @override
  String get onbReferralYoutube => 'YouTube';

  @override
  String get onbRouteAvailable => 'Available training routes:';

  @override
  String get onbRouteQuestion =>
      'What area of the digital environment would you like to master first?';

  @override
  String get onbRoutineMessage =>
      'Choose your training and protection routine!';

  @override
  String get onbRoutineTitle => 'Choose your training and protection routine!';

  @override
  String get onbStartingExperienced => 'Already have some hacker experience?';

  @override
  String get onbStartingExperiencedSub =>
      'Take the level test and skip the basics!';

  @override
  String get onbStartingPerfecto =>
      'Perfect! Let\'s see where to start your training.';

  @override
  String get onbStartingSubtitle => 'Start from scratch and forge your shield!';

  @override
  String get onbStartingTitle => 'Is this your first time in cyber defense?';

  @override
  String get onbWelcomeMessage =>
      'Hi! I\'m Sagen. I\'m here to train you, protect your digital environment and make you an expert.';

  @override
  String get onbWelcomeMsg =>
      'Hi! I\'m Sagen. I\'m here to train you, protect your digital environment, and make you an expert.';

  @override
  String get onboardingCommitButton => 'KEEP MY COMMITMENT';

  @override
  String get onboardingComplete => 'Great! You can now detect basic phishing.';

  @override
  String get onboardingDesc =>
      'Your personal digital security assistant.\nLearn, analyze and protect yourself for free.';

  @override
  String get onboardingError =>
      'That\'s how they operate. They always verify before trusting.';

  @override
  String get onboardingHaveAccount => 'I already have an account';

  @override
  String get onboardingSage50Days =>
      '50 days of dedication. Legend in the making!';

  @override
  String get onboardingSageExcellent => 'Excellent reasons, aim high!';

  @override
  String get onboardingSageMonth =>
      'One month of discipline. Habits are forged.';

  @override
  String get onboardingSageStart => 'A great start! Every day counts.';

  @override
  String get onboardingSageTwoWeeks =>
      'Two weeks of consistency. You are unstoppable!';

  @override
  String get onboardingWelcome => 'Learn to protect yourself';

  @override
  String get onboardingWelcomeDesc =>
      'SAGEN teaches you to browse, detect risks, and protect your information online.';

  @override
  String get ourMission => 'Our Mission';

  @override
  String get owned => 'Owned';

  @override
  String get passClaimFailed => 'Could not claim the reward. Please try again.';

  @override
  String get passClaimedLabel => 'Claimed';

  @override
  String passDaysLeft(Object count) {
    return '$count days left';
  }

  @override
  String get passEarnSp => 'Earn SP by completing lessons';

  @override
  String get passHowToEarnDailyLimit => 'Daily SP limit';

  @override
  String get passHowToEarnLesson => 'Complete a lesson: +10 SP';

  @override
  String get passHowToEarnMission => 'Complete daily missions: +5 SP';

  @override
  String get passHowToEarnPerfect => 'Perfect lesson: +15 SP';

  @override
  String get passHowToEarnReview => 'Review a lesson';

  @override
  String get passHowToEarnTitle => 'How to earn SP';

  @override
  String passLevel(Object level) {
    return 'Level $level';
  }

  @override
  String get passLevelsTitle => 'Levels';

  @override
  String get passLocked => 'Locked';

  @override
  String get passMaxLevel => 'Max level!';

  @override
  String passProgress(Object current, Object required) {
    return 'SP: $current / $required';
  }

  @override
  String get passReached => 'Reached';

  @override
  String get passRewardClaimed => 'Reward claimed!';

  @override
  String passRewards(Object current, Object max) {
    return 'Rewards ($current/$max)';
  }

  @override
  String get paymentCredited => 'Credited!';

  @override
  String get paymentGoHome => 'Go to home';

  @override
  String get paymentMercadoPagoError =>
      'MercadoPago connection error. Please try again.';

  @override
  String get paymentNotCompleted => 'Payment not completed';

  @override
  String get paymentPending => 'Payment pending';

  @override
  String get paymentPendingDescription =>
      'Your payment is being processed. Donations will be credited once the payment is confirmed by the provider.';

  @override
  String get paymentReturnToSagen => 'Return to SAGEN';

  @override
  String get paymentTryAgain => 'Try again';

  @override
  String get paywallBasic => 'Basic';

  @override
  String get paywallDescription =>
      'Choose your package and we\'ll contact you via WhatsApp to coordinate payment.';

  @override
  String get paywallMercadoPago => 'Mercado Pago';

  @override
  String paywallPackageAmount(Object gems) {
    return '$gems donations';
  }

  @override
  String paywallPackageLabel(Object label) {
    return 'Package $label';
  }

  @override
  String paywallPackageSupporter(Object level) {
    return 'Supporter Level $level';
  }

  @override
  String get paywallPaymentMethods =>
      'Pay with Yape, Plin, MercadoPago or transfer';

  @override
  String get paywallPopular => 'Popular';

  @override
  String get paywallPremium => 'Premium';

  @override
  String get paywallSupportUs => 'Support SAGEN';

  @override
  String paywallWhatsAppError(Object link) {
    return 'Error opening WhatsApp. Pay via: $link';
  }

  @override
  String paywallWhatsAppFallback(Object message) {
    return 'Open WhatsApp and send: $message';
  }

  @override
  String paywallWhatsAppMessage(
    Object currencySymbol,
    Object supporterLevel,
    Object price,
    Object userId,
  ) {
    return 'Hi, I want to donate $currencySymbol$price to SAGEN (Supporter $supporterLevel). My user ID is: $userId';
  }

  @override
  String get portuguese => 'Portuguese';

  @override
  String get preferencesTitle => 'Preferences';

  @override
  String get preparingResults => 'Preparing results...';

  @override
  String get privacyLegal => 'Privacy & Legal';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get privacyPolicyTitle => 'SAGEN Privacy Policy';

  @override
  String get privacyPolicyLastUpdate => 'Last updated: July 2026';

  @override
  String get privacyPolicySection1Title => '1. Information We Collect';

  @override
  String get privacyPolicySection1Body =>
      'We collect information you provide directly, such as your name, email, and age, as well as app usage data like completed lessons, streaks, and scores.';

  @override
  String get privacyPolicySection2Title => '2. How We Use Information';

  @override
  String get privacyPolicySection2Body =>
      'We use your information to personalize your learning experience, improve our services, and send you relevant notifications about your progress.';

  @override
  String get privacyPolicySection3Title => '3. Data Storage';

  @override
  String get privacyPolicySection3Body =>
      'Your data is securely stored on protected servers. We use encryption to protect your personal information.';

  @override
  String get privacyPolicySection4Title => '4. Your Rights';

  @override
  String get privacyPolicySection4Body =>
      'You have the right to access, rectify, or delete your personal data. You can contact us to exercise these rights.';

  @override
  String get privacyPolicySection5Title => '5. Third Parties';

  @override
  String get privacyPolicySection5Body =>
      'We do not sell your information to third parties. We may share anonymized data to improve our educational services.';

  @override
  String get privacyPolicySection6Title => '6. Children\'s Privacy';

  @override
  String get privacyPolicySection6Body =>
      'Our app is intended for adults. We do not intentionally collect information from children under 13.';

  @override
  String get privacyPolicySection7Title => '7. Security';

  @override
  String get privacyPolicySection7Body =>
      'We implement technical and organizational security measures to protect your information against unauthorized access.';

  @override
  String get privacyPolicySection8Title => '8. Changes to This Policy';

  @override
  String get privacyPolicySection8Body =>
      'We reserve the right to update this policy. We will notify you of significant changes through the app.';

  @override
  String get privacyPolicySection9Title => '9. Contact';

  @override
  String get privacyPolicySection9Body =>
      'If you have questions about this policy, contact us at support@sagenapp.com';

  @override
  String get productBestOffer => 'Best offer';

  @override
  String get productBoost => 'Boost';

  @override
  String get productBoostPack => 'Boost Pack';

  @override
  String get productBoostPackDesc => '200 donations + 1 XP Boost';

  @override
  String get productDonationBasic => 'Supporter';

  @override
  String get productDonationDesc => 'Help us keep SAGEN free';

  @override
  String get productDonationPremium => 'Champion';

  @override
  String get productDonationStandard => 'Super Supporter';

  @override
  String get productDonations => 'Donations';

  @override
  String get productDonationsDesc => 'Donations to boost your learning';

  @override
  String get productFortune => 'Fortune';

  @override
  String get productFortunePack => 'Fortune Pack';

  @override
  String get productFortunePackDesc => '300 donations + 1 Donation Multiplier';

  @override
  String get productLuck => 'Luck';

  @override
  String get productLuckBoostDesc => '1 Luck Boost (2x in legendary chests)';

  @override
  String get productLuckPack => 'Luck Pack';

  @override
  String get productLuckPackDesc => '250 donations + 1 Luck Boost';

  @override
  String get productOffer => 'Offer';

  @override
  String get productPopular => 'Popular';

  @override
  String get productProtector => 'Protector';

  @override
  String get productProtectorPack => 'Protector Pack';

  @override
  String get productProtectorPackDesc => '100 donations + 1 streak protector';

  @override
  String get productStreakProtectorDesc => '1 Streak Protector';

  @override
  String get productSupporter => 'Supporter';

  @override
  String get productUltra => 'Ultra';

  @override
  String get productXpBoostDesc => '1 XP Boost (2x on your next lesson)';

  @override
  String get productXpMultiplierDesc => '1 XP Multiplier (2x in chests)';

  @override
  String get profileAchievements => 'Achievements';

  @override
  String get profileDay => 'day';

  @override
  String get profileDays => 'days';

  @override
  String get profileDefaultFirstName => 'Warrior';

  @override
  String get profileDefaultLastName => 'Anonymous';

  @override
  String get profileDefaultName => 'Guardian';

  @override
  String get profileDonations => 'Donations';

  @override
  String get profileError => 'Error loading profile';

  @override
  String get profileLevel => 'Level';

  @override
  String profileLevelValue(Object level) {
    return 'Level $level';
  }

  @override
  String get profileStreak => 'Streak';

  @override
  String get profileTitle => 'My Profile';

  @override
  String get profileTotalXp => 'Total XP';

  @override
  String get profileXpLabel => 'XP';

  @override
  String xpValue(int count) {
    return '$count XP';
  }

  @override
  String get progressRestored => 'Progress restored from cloud';

  @override
  String get projectionBenefit1Subtitle =>
      'Secure your social media and emails';

  @override
  String get projectionBenefit1Title => 'Protect your accounts';

  @override
  String get projectionBenefit2Subtitle =>
      'Identify phishing and malicious links';

  @override
  String get projectionBenefit2Title => 'Detect scams';

  @override
  String get projectionBenefit3Subtitle => 'Surf the internet with confidence';

  @override
  String get projectionBenefit3Title => 'Browse safely';

  @override
  String get promoPostLessonSubtitle =>
      'With SAGEN Pass you get exclusive benefits';

  @override
  String get promoPostLessonTitle => 'Keep going! Unlock more';

  @override
  String get protectionBasic => 'Basic';

  @override
  String get protectionBasicDesc => 'You are starting to protect yourself';

  @override
  String get protectionCyberShield => 'Cyber Shield';

  @override
  String get protectionCyberShieldDesc => 'You are an active shield';

  @override
  String get protectionElite => 'Elite Protection';

  @override
  String get protectionEliteDesc => 'Maximum protection level';

  @override
  String get protectionGuardian => 'Guardian';

  @override
  String get protectionGuardianDesc => 'You defend your digital identity';

  @override
  String get protectionProtected => 'Protected';

  @override
  String get protectionProtectedDesc => 'Your first digital habits';

  @override
  String get protectionSecureMind => 'Secure Mind';

  @override
  String get protectionSecureMindDesc => 'Security is part of you';

  @override
  String questionProgress(Object current, Object total) {
    return 'Question $current of $total';
  }

  @override
  String questions(Object count) {
    return '$count questions';
  }

  @override
  String get quickActions => 'Quick actions';

  @override
  String get quickChallengeDetectPhishing => 'Detect phishing';

  @override
  String get quickChallengeDetectRisk => 'Detect the risk';

  @override
  String get quickChallengeSafePassword => 'Safe password';

  @override
  String get quickChallengeTrueFalse => 'True or False';

  @override
  String get quickChallengeWhatWouldYouDo => 'What would you do?';

  @override
  String get quizAbandonContent => 'You will lose your current progress.';

  @override
  String get quizAbandonExit => 'QUIT';

  @override
  String get quizAbandonMessage => 'You\'ll lose your current progress.';

  @override
  String get quizAbandonStay => 'CONTINUE';

  @override
  String get quizAbandonTitle => 'Quit?';

  @override
  String get quizBack => 'Back';

  @override
  String get quizCheck => 'CHECK';

  @override
  String get quizCheckAnswer => 'CHECK';

  @override
  String get quizContinue => 'CONTINUE';

  @override
  String get quizContinueButton => 'CONTINUE';

  @override
  String get quizDefaultTitle => 'Quiz';

  @override
  String get quizExit => 'QUIT';

  @override
  String get quizIntroAnswer => 'Answer';

  @override
  String get quizIntroBeforeTraining => 'Before your training';

  @override
  String get quizIntroFastQuestions => 'Fast questions';

  @override
  String quizProgress(Object percent) {
    return 'Quiz progress: $percent percent';
  }

  @override
  String get quizProgressExpired =>
      'Quiz progress has expired (more than 24 hours).';

  @override
  String get quizResumeButton => 'Resume';

  @override
  String get quizStartOver => 'Start over';

  @override
  String get quizTitleDefault => 'Quiz';

  @override
  String get rankActiveLearner => 'Active Learner';

  @override
  String get rankCybersecurityLegend => 'Cybersecurity Legend';

  @override
  String get rankEliteDefender => 'Elite Defender';

  @override
  String get rankExperiencedWarrior => 'Experienced Warrior';

  @override
  String get rankNovice => 'Novice';

  @override
  String get rankingEmptyMessage => 'Complete lessons to enter the ranking';

  @override
  String get rankingError => 'Error loading ranking';

  @override
  String rankingPosition(Object rank) {
    return 'Rank #$rank';
  }

  @override
  String get rankingShareButton => 'Share Flex Card';

  @override
  String get rankingShareSubtitle => 'Beat my rank on SAGEN';

  @override
  String get rankingSharing => 'Sharing...';

  @override
  String get rankingSubtitle => 'Global ranking · Top 50';

  @override
  String get rankingTitle => 'The Coliseum';

  @override
  String rankingXpToTop50(Object xp) {
    return 'You need $xp XP to enter the Top 50';
  }

  @override
  String rankingYourPosition(Object xp, Object rank) {
    return 'Your position: #$rank · $xp XP';
  }

  @override
  String get rarityGold => 'Gold';

  @override
  String get rarityPlatinum => 'Platinum';

  @override
  String get raritySilver => 'Silver';

  @override
  String get reauthConfirm => 'Confirm';

  @override
  String get reauthDesc =>
      'For security reasons, please enter your password again';

  @override
  String get reauthOAuthInfo =>
      'You signed in with Google or Facebook. Confirm account deletion.';

  @override
  String get reauthTitle => 'Confirm your password';

  @override
  String get reauthWrongPassword => 'Incorrect password. Try again.';

  @override
  String get recommended => 'RECOMMENDED';

  @override
  String get reduceAnimations => 'Reduce Animations';

  @override
  String get reduceAnimationsSubtitle => 'Reduces animation intensity';

  @override
  String get referralSource1 => 'Friend referral';

  @override
  String get referralSource2 => 'Social media';

  @override
  String get referralSource3 => 'Google search';

  @override
  String get referralSource4 => 'App Store';

  @override
  String get referralSource5 => 'YouTube';

  @override
  String get referralSource6 => 'TikTok';

  @override
  String get referralSource7 => 'Other';

  @override
  String get regAgeQuestion => 'How old are you?';

  @override
  String get regAgeValidation => 'Please enter your real age';

  @override
  String get regChooseMethod => 'Choose a method to create your account.';

  @override
  String get regCloudSave => 'Cloud-saved progress';

  @override
  String get regCreateProfile => 'CREATE PROFILE';

  @override
  String get regEmailDesc => 'We\'ll send you a verification code.';

  @override
  String get regEmailHint => 'example@email.com';

  @override
  String get regEmailOption => 'Email';

  @override
  String get regEmailTitle => 'Your email';

  @override
  String get regHowContinue => 'How would you like to continue?';

  @override
  String get regLater => 'Later';

  @override
  String get regMethodTitle => 'Choose your sign-up method';

  @override
  String get regNameHint => 'First name';

  @override
  String get regNameQuestion => 'What\'s your name?';

  @override
  String get regPasswordDesc => 'Minimum 6 characters to protect your account.';

  @override
  String get regPasswordTitle => 'Create a password';

  @override
  String get regProfileAlmostReady => 'Almost ready!';

  @override
  String get regProfileCreated => 'PROFILE CREATED';

  @override
  String get regProfileDesc =>
      'Create a profile to save your progress and keep your streak.';

  @override
  String get regReadyForLesson => 'Get ready for your first lesson';

  @override
  String get regRewards => 'Personal rewards and achievements';

  @override
  String get regStreakSync => 'Streak synced across devices';

  @override
  String get regSurnameHint => 'Last name';

  @override
  String get regWelcomeSagen => 'Welcome to SAGEN!';

  @override
  String get registerAgeEmpty => 'Please enter your age';

  @override
  String get registerAgeHint => 'Your age (minimum 13)';

  @override
  String get registerAgeInvalid => 'Invalid age';

  @override
  String get registerAgeMin => 'You must be at least 13 years old';

  @override
  String get registerWithApple => 'Sign up with Apple';

  @override
  String get registerWithFacebook => 'Sign up with Facebook';

  @override
  String get registerWithGoogle => 'Sign up with Google';

  @override
  String get restartApp => 'Restart app';

  @override
  String get restoreAction => 'Restore';

  @override
  String get restoreCloud => 'Restore from Cloud';

  @override
  String get restoreDesc =>
      'Do you want to restore your progress from the cloud? This will replace local data with your saved account data.';

  @override
  String get restoreTitle => 'Restore Progress';

  @override
  String get resultAccuracy => 'Accuracy';

  @override
  String get resultCompleteTitle => 'Lesson completed!';

  @override
  String get resultLives => 'Lives';

  @override
  String get resultNotPerfectDesc =>
      'Keep practicing to achieve a perfect session.';

  @override
  String get resultPerfectBadge => 'PERFECT SESSION';

  @override
  String get resultPerfectDesc =>
      'You made no mistakes. You are a digital guardian.';

  @override
  String get resultPerfectTitle => 'Flawless result!';

  @override
  String get resumeQuiz => 'Resume quiz?';

  @override
  String get retry => 'Retry';

  @override
  String get reviewComplete => 'Review complete!';

  @override
  String get reviewCorrect => 'correct';

  @override
  String get reviewFinish => 'Finish review';

  @override
  String get reviewGoodProgress => 'Good progress';

  @override
  String get reviewKeepGoing => 'Keep it up!';

  @override
  String get reviewKeepPracticing => 'Keep practicing';

  @override
  String get reviewNoErrors => 'No errors to review';

  @override
  String get reviewSageGood =>
      'Each review strengthens your shield. Ready for more?';

  @override
  String get reviewSageKeep =>
      'Reviewing is part of learning. You can try again anytime.';

  @override
  String get reviewSagePerfect =>
      'Your weak areas are improving. I can see your effort.';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reward100Xp => '100 XP';

  @override
  String get reward200Exp => '200 EXP';

  @override
  String rewardAdCooldown(Object seconds) {
    return 'Available in $seconds seconds';
  }

  @override
  String rewardAdEarned(Object count) {
    return 'You earned $count donations!';
  }

  @override
  String rewardAdEarnedGems(Object gems) {
    return '+$gems gems';
  }

  @override
  String rewardAdEarnedXp(Object xp) {
    return '+$xp XP earned!';
  }

  @override
  String get rewardAdNotAvailable =>
      'The ad is not available now. Try again later.';

  @override
  String get rewardAdSubtitle => 'Watch an ad and receive donations instantly';

  @override
  String get rewardAdTitle => 'Earn extra donations';

  @override
  String get rewardAdWatch => 'Watch';

  @override
  String get rewardCopperFrame => 'Copper Frame';

  @override
  String get rewardEpicChest => 'Epic Chest';

  @override
  String get rewardGoldenChest => 'Golden Chest';

  @override
  String get rewardIceFlame => 'Ice Flame + Guardian';

  @override
  String get rewardTitaniumShield => 'Titanium Shield';

  @override
  String get routeSelection1 => 'Fundamentals first';

  @override
  String get routeSelection2 => 'Intermediate path';

  @override
  String get routeSelection3 => 'Advanced route';

  @override
  String sageAchievementUnlocked(Object name) {
    return '${name}Achievement unlocked!';
  }

  @override
  String sageAdvancing(Object levelHint, Object name) {
    return '${name}You keep advancing.$levelHint';
  }

  @override
  String get sageChatDescription =>
      'Ask anything about cybersecurity or choose a quick suggestion.';

  @override
  String get sageChatHint => 'Ask Sage...';

  @override
  String get sageChatTitle => 'Ask Sage';

  @override
  String sageCongratulations(Object name) {
    return '${name}Congratulations!';
  }

  @override
  String get sageCriticalError => 'Critical error';

  @override
  String get sageEasterEgg => 'Did you see that?';

  @override
  String sageEmptyState(Object name) {
    return '${name}Nothing here yet';
  }

  @override
  String sageGreatJob(Object name, Object extra) {
    return '${name}Great job!$extra';
  }

  @override
  String sageHighStreakDays(Object streak) {
    return ' $streak days in a row.';
  }

  @override
  String get sageImportant => 'This is very important';

  @override
  String sageImpressiveStreak(Object name, Object days) {
    return '${name}Impressive streak!$days';
  }

  @override
  String sageLevelHint(Object level) {
    return ' Level $level is close.';
  }

  @override
  String get sageLoading => 'Give me a second...';

  @override
  String get sageMascot => 'Sage mascot';

  @override
  String get sageMonocleActive => 'Sage Monocle active';

  @override
  String get sageMonocleButton => 'Use Sage Monocle (remove 2 wrong)';

  @override
  String get sageMotivational1 => 'You\'re awesome!';

  @override
  String get sageMotivational2 => 'Keep going, you\'re incredible!';

  @override
  String get sageMotivational3 => 'Every day closer to your goal!';

  @override
  String get sageMotivational4 => 'I believe in you!';

  @override
  String get sageMotivational5 => 'Don\'t give up, you can do it!';

  @override
  String get sageMotivational6 => 'Let\'s go on this adventure together!';

  @override
  String get sageMotivational7 => 'Hard work pays off!';

  @override
  String get sageMotivational8 => 'Never stop learning!';

  @override
  String get sagePerfect => 'Perfect!';

  @override
  String get sagePreparing => 'Preparing everything for you';

  @override
  String get sageReadCarefully => 'Read carefully';

  @override
  String get sageSomethingWrong => 'Something went wrong';

  @override
  String sageStreakAmazing(Object streak) {
    return 'Your $streak day streak is incredible!';
  }

  @override
  String sageStreakAtRisk(Object streak) {
    return ' Don\'t lose $streak days of effort!';
  }

  @override
  String sageStreakAtRiskMessage(Object urgency, Object name) {
    return '${name}Don\'t lose your streak!$urgency';
  }

  @override
  String get sageStreakLost => ' You have the knowledge to start again.';

  @override
  String sageStreakLostMessage(Object name, Object encouragement) {
    return '${name}The streak has been lost.$encouragement';
  }

  @override
  String sageTellMeMore(Object name) {
    return '${name}Tell me more about you';
  }

  @override
  String get sageTryAgain => 'Shall we try again?';

  @override
  String sageWelcomeBack(Object name) {
    return '${name}Welcome back!';
  }

  @override
  String sageWhatDoYouThink(Object name) {
    return '${name}What do you think is correct?';
  }

  @override
  String get sagenPassClaim => 'Claim';

  @override
  String get sagenPassSupportSubtitle =>
      'Get exclusive benefits and help improve the app';

  @override
  String get sagenPassSupportTitle => 'Support SAGEN';

  @override
  String get sagenPassTitle => 'SAGEN Pass';

  @override
  String get savedQuizProgress =>
      'You have saved progress. Would you like to resume?';

  @override
  String get scheduledDarkMode => 'Scheduled Dark Mode';

  @override
  String get scheduledDarkModeSubtitle => 'Auto on/off based on schedule';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get selectFile => 'Select file';

  @override
  String get selectedAnswer => 'Selected';

  @override
  String get sendMessage => 'Send';

  @override
  String get sessionAccuracyText1 => 'Great aim!';

  @override
  String get sessionAccuracyText2 => 'Surgical precision.';

  @override
  String get sessionAccuracyText3 => 'Expert level reached.';

  @override
  String get sessionAccuracyText4 => 'Knowledge sharpshooter.';

  @override
  String get sessionAccuracyText5 => 'Near-perfect accuracy.';

  @override
  String get sessionAccuracyText6 => 'No room for error.';

  @override
  String get sessionAccuracyText7 => 'Impeccable.';

  @override
  String get sessionBackToMap => 'Back to map';

  @override
  String get sessionClaimReward => 'CLAIM REWARD';

  @override
  String get sessionCorrect => 'Correct!';

  @override
  String sessionCorrectAnswer(Object answer) {
    return 'Correct answer: $answer';
  }

  @override
  String get sessionExp => 'EXP';

  @override
  String get sessionIncorrect => 'Incorrect';

  @override
  String get sessionLivesExhausted => 'Lives exhausted';

  @override
  String get sessionLivesExhaustedDesc => 'You lost all your lives. Try again.';

  @override
  String get sessionLoading => 'Loading...';

  @override
  String get sessionPrecision => 'ACCURACY';

  @override
  String get sessionQuestionsToAnswer => 'questions to answer';

  @override
  String get sessionReadyToLearn => 'Ready to learn?';

  @override
  String get sessionRetry => 'Retry';

  @override
  String sessionScore(Object correct, Object total) {
    return '$correct/$total correct';
  }

  @override
  String get sessionSelectAnswer => 'Select an answer';

  @override
  String get sessionSpeedText1 => 'What speed!';

  @override
  String get sessionSpeedText2 => 'You beat the clock.';

  @override
  String get sessionSpeedText3 => 'At the speed of light.';

  @override
  String get sessionSpeedText4 => 'Steel reflexes.';

  @override
  String get sessionSpeedText5 => 'Nobody can catch you today.';

  @override
  String get sessionSpeedText6 => 'Record time!';

  @override
  String get sessionSpeedText7 => 'Supersonic speed.';

  @override
  String get sessionStandardText1 => 'Lesson completed!';

  @override
  String get sessionStandardText2 => 'One more step toward your goal.';

  @override
  String get sessionStandardText3 => 'Progress is the journey.';

  @override
  String get sessionStandardText4 => 'Consistent good work.';

  @override
  String get sessionStandardText5 => 'Keep going, add more days.';

  @override
  String get sessionStandardText6 => 'Consistency above all.';

  @override
  String get sessionStandardText7 => 'Discipline yields results.';

  @override
  String get sessionStartQuiz => 'START QUIZ';

  @override
  String get sessionSummaryAccuracy => 'ACCURACY';

  @override
  String get sessionSummaryAccuracy1 => 'Your accuracy is outstanding!';

  @override
  String get sessionSummaryAccuracy2 => 'Excellent aim!';

  @override
  String get sessionSummaryAccuracy3 => 'Good progress!';

  @override
  String get sessionSummaryAccuracy4 => 'You\'re improving!';

  @override
  String get sessionSummaryAccuracy5 => 'Great effort!';

  @override
  String get sessionSummaryAccuracy6 => 'Keep learning!';

  @override
  String get sessionSummaryAccuracy7 => 'Every question counts!';

  @override
  String get sessionSummaryExp => 'EXP';

  @override
  String get sessionSummaryReceiveReward => 'CLAIM REWARD';

  @override
  String get sessionSummaryReceiveRewardLabel => 'Collect reward';

  @override
  String get sessionSummarySpeed1 => 'Lightning speed!';

  @override
  String get sessionSummarySpeed2 => 'Quick thinking!';

  @override
  String get sessionSummarySpeed3 => 'Fast learner!';

  @override
  String get sessionSummarySpeed4 => 'Nice pace!';

  @override
  String get sessionSummarySpeed5 => 'On the right track!';

  @override
  String get sessionSummarySpeed6 => 'Building momentum!';

  @override
  String get sessionSummarySpeed7 => 'Steady progress!';

  @override
  String get sessionSummaryStandard1 => 'Lesson complete!';

  @override
  String get sessionSummaryStandard2 => 'Well done!';

  @override
  String get sessionSummaryStandard3 => 'Good work!';

  @override
  String get sessionSummaryStandard4 => 'Nice job!';

  @override
  String get sessionSummaryStandard5 => 'You did it!';

  @override
  String get sessionSummaryStandard6 => 'Another step forward!';

  @override
  String get sessionSummaryStandard7 => 'Keep going!';

  @override
  String get sessionSummaryTime => 'TIME';

  @override
  String get sessionTime => 'TIME';

  @override
  String get settingsAmoledDark => 'AMOLED Dark';

  @override
  String get settingsAmoledDarkSubtitle =>
      'Pure #000000 background to save battery';

  @override
  String get settingsAnalytics => 'Anonymous analytics';

  @override
  String get settingsAnalyticsDesc =>
      'Help improve Sagen with anonymous usage data';

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDeleteAccountConfirm =>
      'Are you sure? This action cannot be undone.';

  @override
  String get settingsExportData => 'Export data';

  @override
  String get settingsFontSize => 'Font size';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to log out?';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsReduceAnimations => 'Reduce animations';

  @override
  String get settingsSound => 'Sound';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsVibration => 'Vibration';

  @override
  String get shareProfile => 'Share profile card';

  @override
  String get shareRanking => 'Share ranking';

  @override
  String get sharing => 'Sharing...';

  @override
  String get shieldTierBasic => 'Basic Shield';

  @override
  String get shieldTierCrystal => 'Crystal Shield';

  @override
  String get shieldTierGlow => 'Radiant Shield';

  @override
  String get shieldTierInactive => 'No Shield';

  @override
  String get shieldTierLegendary => 'Legendary Shield';

  @override
  String get shieldTierParticles => 'Particles Shield';

  @override
  String get shopBgCyber => 'Cyberpunk Background';

  @override
  String get shopBgCyberDesc => 'Futuristic profile background';

  @override
  String get shopBgMatrix => 'Matrix Background';

  @override
  String get shopBgMatrixDesc => 'Green matrix background';

  @override
  String get shopFrameDiamond => 'Diamond Frame';

  @override
  String get shopFrameDiamondDesc => 'Exclusive diamond frame';

  @override
  String get shopFrameNeon => 'Neon Frame';

  @override
  String get shopFrameNeonDesc => 'Neon profile frame';

  @override
  String get shopItemAcquired => 'Acquired';

  @override
  String get shopItemOwned => 'Owned';

  @override
  String get shopOwned => 'Owned';

  @override
  String get shopSageGolden => 'Golden Sage';

  @override
  String get shopSageGoldenDesc => 'Exclusive golden skin';

  @override
  String get shopSageNeon => 'Neon Sage';

  @override
  String get shopSageNeonDesc => 'Neon cyan skin for Sage';

  @override
  String get shopSageShadow => 'Shadow Sage';

  @override
  String get shopSageShadowDesc => 'Dark skin for Sage';

  @override
  String get shopTitleGuardian => 'Digital Guardian Title';

  @override
  String get shopTitleGuardianDesc => 'Guardian title';

  @override
  String get shopTitleHacker => 'Ethical Hacker Title';

  @override
  String get shopTitleHackerDesc => 'Special title in profile';

  @override
  String get showPassword => 'Show password';

  @override
  String get skipText => 'Skip';

  @override
  String get skipToContent => 'Skip to main content';

  @override
  String get sounds => 'Sounds';

  @override
  String get soundsSubtitle => 'App sound effects';

  @override
  String get spanish => 'Spanish';

  @override
  String get speedSort2fa => 'Two-factor authentication';

  @override
  String get speedSortAntivirus => 'Antivirus';

  @override
  String get speedSortDataEncryption => 'Data encryption';

  @override
  String get speedSortFakeEmail => 'Fake email';

  @override
  String get speedSortFirewall => 'Firewall';

  @override
  String get speedSortFraudulentCall => 'Fraudulent call';

  @override
  String get speedSortProtectionCategory => 'Protection';

  @override
  String get speedSortScamCategory => 'Scam';

  @override
  String get speedSortSecurityCategory => 'Security';

  @override
  String get speedSortSmsLink => 'SMS link';

  @override
  String get speedSortStrongPassword => 'Strong password';

  @override
  String get speedSortVpn => 'VPN';

  @override
  String get splashTitle => 'SAGEN';

  @override
  String get stage1Subtitle => 'Digital security basics';

  @override
  String get stage1Title => 'Fundamentals';

  @override
  String get stage2Subtitle => 'Identify cheating attempts';

  @override
  String get stage2Title => 'Phishing';

  @override
  String get stage3Subtitle => 'Create secure keys and protect yourself';

  @override
  String get stage3Title => 'Passwords';

  @override
  String get stage4Subtitle => 'Protect your privacy on platforms';

  @override
  String get stage4Title => 'Social Media';

  @override
  String get stage5Subtitle => 'Misinformation and trusted sites';

  @override
  String get stage5Title => 'Secure Browsing';

  @override
  String get stage6Subtitle => 'Control your personal data';

  @override
  String get stage6Title => 'Digital Privacy';

  @override
  String get stage7Subtitle => 'Full protection for experts';

  @override
  String get stage7Title => 'Advanced Cybersecurity';

  @override
  String get stage8Subtitle => 'Become a digital guardian';

  @override
  String get stage8Title => 'Digital Expert';

  @override
  String stageProgress(Object percent) {
    return 'Stage progress: $percent percent';
  }

  @override
  String get startText => 'Start';

  @override
  String get statsExcellent => 'Excellent!';

  @override
  String get statsIncredible => 'Incredible!';

  @override
  String get statsKeepTrying => 'Keep trying.';

  @override
  String get statsNoData => 'No lesson data';

  @override
  String get statsNoErrors => 'No errors!';

  @override
  String get statsReceiveXp => 'RECEIVE XP';

  @override
  String get statsSpeed => 'Speed';

  @override
  String get statsStartStage1 => 'You\'ll start from Stage 1, Lesson 1';

  @override
  String get statsStartStage2 => 'You\'ll start from Stage 2, Lesson 1';

  @override
  String get statsWellDone => 'Well done!';

  @override
  String get statusCompleted => 'completed';

  @override
  String get storeAdEarnXp => 'Earn XP by watching';

  @override
  String get storeAdRewardMessage => '+1 Donation for watching the ad';

  @override
  String get storeAdWatchVideo => 'Watch a 30-second video';

  @override
  String storeBuyItem(Object cost, Object item) {
    return 'Buy $item for $cost donations';
  }

  @override
  String get storeCategoryConsumables => 'Consumables';

  @override
  String get storeCategoryCosmetics => 'Cosmetics';

  @override
  String get storeCategoryThemes => 'Themes';

  @override
  String get storeChestAvailable => 'Daily Chest Available!';

  @override
  String get storeChestComeBack => 'Come back tomorrow';

  @override
  String storeChestExpiresIn(Object gems) {
    return '$gems donated — expires at midnight';
  }

  @override
  String get storeChestRenews => 'Your chest renews every day';

  @override
  String get storeClaimError => 'Failed to claim the reward. Please try again.';

  @override
  String storeConfirmMessage(Object cost, Object item) {
    return 'Do you want to buy $item for $cost donations?';
  }

  @override
  String get storeConfirmTitle => 'Confirm purchase';

  @override
  String get storeDonate => 'Donate';

  @override
  String storeDonateSubtitle(Object price) {
    return 'From $price';
  }

  @override
  String get storeDonationsLabel => 'donations';

  @override
  String get storeGemTipAchievement => 'Achievements: gems based on difficulty';

  @override
  String get storeGemTipChest => 'Open chests: gems based on chest type';

  @override
  String get storeGemTipFirstLesson => 'First lesson of the day: +10 gems';

  @override
  String get storeGemTipLesson => 'Complete lessons: 5 gems per correct answer';

  @override
  String get storeGemTipMission => 'Daily missions: +12 gems';

  @override
  String get storeGemTipPerfect => 'Perfect lesson: +20 extra gems';

  @override
  String get storeGemTipStreak => 'Streaks: up to +150 gems';

  @override
  String get storeHowToEarnGems => 'How to earn gems?';

  @override
  String get storeNoItems => 'No items available at the moment.';

  @override
  String get storeOpen => 'Open';

  @override
  String get storePersonalization => 'Personalization';

  @override
  String get storeProtectStreak => 'Protect your streak';

  @override
  String get storeDailyChestClaim => 'Claim';

  @override
  String storeDailyChestReward(Object xp) {
    return '+$xp XP!';
  }

  @override
  String get storeDailyChestSubtitle => 'Claim your free daily reward';

  @override
  String get storeDailyChestTitle => 'Daily Chest';

  @override
  String get storePurchaseFailed =>
      'Purchase validation failed. Please try again.';

  @override
  String get storePurchaseSuccess => 'Purchase successful!';

  @override
  String get storeAlreadyOwned => 'You already own this item.';

  @override
  String get storeShieldLimitReached => 'Shield limit reached';

  @override
  String get storeSupport => 'Support Us';

  @override
  String get storeSupportTiers => 'Supporter tiers';

  @override
  String get storeThankYou => 'Thank you for your support!';

  @override
  String get storeTitle => 'Store';

  @override
  String get storeWatch => 'Watch';

  @override
  String storeWhatsappPackages(Object price) {
    return 'Packages from $price — Pay via WhatsApp';
  }

  @override
  String get streakAchievements => 'Achievements and medals for consistency';

  @override
  String get streakBadge => 'STREAK';

  @override
  String get streakChest100Message => '100 days. Legend.';

  @override
  String get streakChest100Title => '100-day streak!';

  @override
  String get streakChest14Message => 'Two weeks of consistency. Keep going!';

  @override
  String get streakChest14Title => '14-day streak!';

  @override
  String get streakChest30Message => 'One month. You\'re a Digital Guardian.';

  @override
  String get streakChest30Title => '30-day streak!';

  @override
  String get streakChest7Message =>
      'One week protecting your digital identity.';

  @override
  String get streakChest7Title => '7-day streak!';

  @override
  String get streakCommitButton => 'KEEP MY COMMITMENT';

  @override
  String get streakCurrent => 'Current streak';

  @override
  String streakCurrentProgress(Object goal, Object current) {
    return 'Current streak: $current / $goal days';
  }

  @override
  String get streakDayFri => 'Fri';

  @override
  String get streakDayLabel => 'day streak';

  @override
  String get streakDayMon => 'Mo';

  @override
  String get streakDayOfStreak => 'day streak';

  @override
  String get streakDaySat => 'Sa';

  @override
  String get streakDaySun => 'Sun';

  @override
  String get streakDayThu => 'Thu';

  @override
  String get streakDayTue => 'T';

  @override
  String get streakDayWed => 'W';

  @override
  String streakDays(Object count) {
    return '$count days';
  }

  @override
  String streakDaysCount(Object count) {
    return '$count day streak';
  }

  @override
  String streakDaysCountPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# day streak',
      one: '# day streak',
    );
    return '$_temp0';
  }

  @override
  String get streakEmotional100 => '100 days of constant protection. Legend.';

  @override
  String get streakEmotional14 =>
      'Two weeks of consistency. Your shield shines bright.';

  @override
  String get streakEmotional3 =>
      '3 days in a row. You are building a solid habit.';

  @override
  String get streakEmotional30 =>
      'One month of learning. Your dedication makes you a Digital Guardian.';

  @override
  String get streakEmotional50 => '50 days of constant digital protection.';

  @override
  String get streakEmotional7 =>
      'One week protecting your digital identity. Keep it up!';

  @override
  String get streakFireCard => 'Streak fire card';

  @override
  String get streakFireCardA11y => 'Fire streak card';

  @override
  String get streakFireCardLabel => 'Fire Streak';

  @override
  String get streakFreeze => 'Streak Shield';

  @override
  String get streakFreezeDescription => 'Keep your streak when you miss a day';

  @override
  String get streakFreezeUsed => 'A freeze protected your streak.';

  @override
  String get streakFrozen => 'Streak frozen';

  @override
  String get streakGotIt => 'GOT IT';

  @override
  String get streakKeepAlive => 'Keep your streak alive!';

  @override
  String get streakKeepAliveDesc =>
      'Complete a lesson each day to keep your streak.\nEvery day counts to strengthen your digital shield.';

  @override
  String get streakKeepCommitment => 'KEEP MY COMMITMENT';

  @override
  String get streakLongest => 'Best streak';

  @override
  String get streakMessage100Days => '100 days. Legend.';

  @override
  String get streakMessage14Days => 'Two weeks. Your shield shines.';

  @override
  String get streakMessage30Days => 'One month. You are a Digital Guardian.';

  @override
  String get streakMessage3Days => '3 days. Good start.';

  @override
  String get streakMessage50Days => '50 days of constant protection.';

  @override
  String get streakMessage7Days => 'One week! Keep going.';

  @override
  String get streakMessageActive =>
      'Active streak! Consistency is your best weapon today.';

  @override
  String get streakMessageAtRisk => 'Your streak is at risk!';

  @override
  String get streakMessageCloser =>
      'One more day, one more step toward your goal.';

  @override
  String get streakMessageEachDay =>
      'Every day counts. Your commitment makes you stronger.';

  @override
  String get streakMessageKeepGoing =>
      'Keep it up! Today\'s discipline is tomorrow\'s victory.';

  @override
  String get streakMessageKeepProtecting => 'Keep protecting yourself!';

  @override
  String get streakMessageNew =>
      'A new streak! Practice every day and help it grow.';

  @override
  String get streakMessageStartActivities =>
      'Complete activities to start your streak.';

  @override
  String get streakMsg1 => 'A new streak! Practice every day and help it grow.';

  @override
  String get streakMsg2 =>
      'Streak active! Consistency is your best weapon today.';

  @override
  String get streakMsg3 =>
      'Every day counts. Your commitment makes you stronger.';

  @override
  String get streakMsg4 =>
      'Keep going! Today\'s discipline is tomorrow\'s victory.';

  @override
  String get streakMsg5 => 'One more day, one step closer to your goal.';

  @override
  String get streakNoActiveStreak => 'No active streak';

  @override
  String get streakReminder => 'Streak reminders';

  @override
  String get streakReminderSubtitle => 'Get reminders to maintain your streak';

  @override
  String get streakRewards => 'Exclusive rewards when reaching goals';

  @override
  String get streakShieldActive =>
      'Shield active — your streak is protected today!';

  @override
  String get streakShieldOnboarding =>
      'Buy a shield to protect your streak if you miss a day.';

  @override
  String get streakStrongerShield => 'Stronger shield every day';

  @override
  String get streakTitle => 'My Streak';

  @override
  String get streakTitleShort => 'Streak';

  @override
  String get summarizeButton => 'Quick summary';

  @override
  String get summaryCommitment => 'Commitment';

  @override
  String get summaryDailyGoal => 'Daily goal';

  @override
  String get summaryGoodWork => 'Good work!';

  @override
  String get summaryInterest => 'Interest';

  @override
  String get summaryKeepPracticing => 'Keep practicing';

  @override
  String get summaryKnowledge => 'Knowledge';

  @override
  String get summaryLearning => 'Learning';

  @override
  String get summaryMotivations => 'Motivations';

  @override
  String get summaryOrigin => 'Origin';

  @override
  String get summaryPerfect => 'Perfect!';

  @override
  String get summaryReady => 'All set to start your digital security journey.';

  @override
  String summaryStreakDays(Object days) {
    return '+$days day(s)';
  }

  @override
  String get summaryXpBonus => 'XP Bonus';

  @override
  String get summaryXpEarned => 'XP earned';

  @override
  String get supporterBadge => 'Supporter';

  @override
  String get syncSnackbar => 'Progress synced';

  @override
  String get syncStatus => 'Sync Status';

  @override
  String get syncing => 'Syncing...';

  @override
  String get termsConditions => 'Terms & Conditions';

  @override
  String get thankYouForSupport => 'Thank you for your support!';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkLabel => 'Dark';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightLabel => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemLabel => 'System';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get tierBasic => 'Basic';

  @override
  String get tierCrystal => 'Crystal';

  @override
  String get tierGlow => 'Glow';

  @override
  String get tierInactive => 'Inactive';

  @override
  String get tierLegendary => 'Legendary';

  @override
  String get tierParticles => 'Particles';

  @override
  String get totalProgress => 'Total progress';

  @override
  String get tryAgain => 'Connect and try again.';

  @override
  String tutorLessonsProgress(Object completed, Object required) {
    return '$completed / $required lessons';
  }

  @override
  String get tutorLocked => 'AI Tutor Locked';

  @override
  String get tutorLockedDescription =>
      'Complete at least 10 lessons to unlock Sage, your personal cybersecurity tutor.';

  @override
  String tutorMotivationAlmost(Object count) {
    return 'Almost there, only $count lessons to go. Keep it up!';
  }

  @override
  String get tutorMotivationGeneral =>
      'Each lesson brings you closer to your personal cybersecurity tutor.';

  @override
  String tutorMotivationGood(Object count) {
    return 'Great pace! You need $count more lessons to access Sage.';
  }

  @override
  String get tutorSampleAnswer1 =>
      'Never share your password. Use a password manager and enable two-factor authentication.';

  @override
  String get tutorSampleQuestion1 =>
      'What should I do if I receive a suspicious email?';

  @override
  String get tutorSampleQuestion2 => 'How can I create a strong password?';

  @override
  String get tutorSampleTitle => 'Sample conversation';

  @override
  String get tutorTitle => 'AI Tutor';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialStart => 'Let\'s go!';

  @override
  String get tutorialStep1 => 'Hi! I\'m Sage, your cybersecurity guide.';

  @override
  String get tutorialStep2 =>
      'Complete lessons to earn donations and level up.';

  @override
  String get tutorialStep3 =>
      'Maintain your daily streak to unlock special chests.';

  @override
  String get tutorialStep4 =>
      'Your mission: protect your digital identity. Let\'s learn together!';

  @override
  String get unknownLabel => 'Unknown';

  @override
  String get updateChangelog => 'Updates and news';

  @override
  String get updateChangelogDesc =>
      'New screen in the bottom bar showing the changelog and app news.';

  @override
  String get updateChestSystem => 'Streak and lesson chests';

  @override
  String get updateChestSystemDesc =>
      'New chest system: daily chest for streak, lesson chest every 3/5/6/10 completed lessons.';

  @override
  String get updateDailyMissions => 'Daily missions';

  @override
  String get updateDailyMissionsDesc =>
      'Daily missions system with donation and experience rewards.';

  @override
  String get updateEnergySystem => 'Energy System';

  @override
  String get updateEnergySystemDesc =>
      'Now each lesson uses energy. Answer correctly to spend only 1, failing costs 2. Combo streaks regenerate energy. At 0 you cannot continue.';

  @override
  String get updateFirstVersion => 'First version';

  @override
  String get updateFirstVersionDesc =>
      'Initial launch with interactive lessons, daily streak, donations, store and user profile.';

  @override
  String get updateImprovedIcons => 'Improved item icons';

  @override
  String get updateImprovedIconsDesc =>
      'All special items now have custom, more eye-catching icons in the store and inventory.';

  @override
  String get updateInfiniteEnergy => 'Infinite Energy';

  @override
  String get updateInfiniteEnergyDesc =>
      'New special item in the store that grants unlimited energy for a limited time. Activate from your inventory.';

  @override
  String get updateLessonBoosters => 'Lesson boosters';

  @override
  String get updateLessonBoostersDesc =>
      'New items: XP Boost (2x), XP Multiplier (2x in chests), Luck Boost (2x chances). Buy and activate from the store.';

  @override
  String get updateMercadoPago => 'Mercado Pago integrated';

  @override
  String get updateMercadoPagoDesc =>
      'Direct payments with Mercado Pago for donation packages and bundles. WhatsApp payment also available.';

  @override
  String get updateNew => 'NEW';

  @override
  String get updateProgrammaticMascot => 'Programmatic mascot';

  @override
  String get updateProgrammaticMascotDesc =>
      'The mascot is now drawn with CustomPainter. 29 emotions, no assets, smooth transitions between emotions.';

  @override
  String get updateStreakProtectorImproved => 'Improved streak protector';

  @override
  String get updateStreakProtectorImprovedDesc =>
      'Maximum limit of 2 protectors. When reached, booster offers are shown instead.';

  @override
  String get updateTestFix => 'Unit test fix';

  @override
  String get updateTestFixDesc =>
      'Fixed 7 failing tests. All tests now pass (419 tests). 0 analysis issues.';

  @override
  String get updateTypeFeature => 'NEW FEATURE';

  @override
  String get updateTypeFix => 'FIX';

  @override
  String get updateTypeImprovement => 'IMPROVEMENT';

  @override
  String get updateTypedRoutes => 'Typed routes with GoRouter Builder';

  @override
  String get updateTypedRoutesDesc =>
      'Splash and welcome routes are now typed, detecting errors at compile time.';

  @override
  String get updates => 'Updates';

  @override
  String get updatesTitle => 'News and updates';

  @override
  String get verifyEmailCheckButton => 'I\'ve already verified';

  @override
  String verifyEmailMessage(Object email) {
    return 'We sent a verification link to $email. Click the link to activate your account.';
  }

  @override
  String get verifyEmailNotVerified =>
      'Your email has not been verified yet. Check your inbox.';

  @override
  String get verifyEmailResendButton => 'Resend verification email';

  @override
  String get verifyEmailResendError =>
      'Unable to resend email. Please try again.';

  @override
  String get verifyEmailSent => 'Verification email sent. Check your inbox.';

  @override
  String get verifyEmailSignOut => 'Sign out';

  @override
  String get verifyEmailSuccess => 'Email verified! Welcome to SAGEN.';

  @override
  String get verifyEmailTitle => 'Verify your email';

  @override
  String get viewAchievements => 'View achievements';

  @override
  String get viewAll => 'View all';

  @override
  String get weeklyChestComplete => 'Weekly chest earned!';

  @override
  String get weeklyChestDesc => 'Complete 5 daily missions for an epic chest';

  @override
  String get weeklyChestProgress => 'Weekly Chest Progress';

  @override
  String weeklyChestProgressCount(Object done, Object total) {
    return '$done/$total';
  }

  @override
  String get welcomeLoginButton => 'I ALREADY HAVE AN ACCOUNT';

  @override
  String get welcomeStartButton => 'START NOW';

  @override
  String get welcomeSubtitle =>
      'Intelligent analysis and digital security.\nFree forever.';

  @override
  String get wizardAllAbove => 'All of the above';

  @override
  String get wizardAppStore => 'App Store';

  @override
  String get wizardArticles => 'Read articles';

  @override
  String get wizardBoostStudies => 'Boost my studies';

  @override
  String get wizardChatSage => 'Chat with Sage';

  @override
  String get wizardCommit14 => '14 days';

  @override
  String get wizardCommit14Sub => '80 donations';

  @override
  String get wizardCommit30 => '30 days';

  @override
  String get wizardCommit30Sub => '200 donations';

  @override
  String get wizardCommit50 => '50 days';

  @override
  String get wizardCommit50Sub => '400 donations';

  @override
  String get wizardCommit7 => '7 days';

  @override
  String get wizardCommit7Sub => '30 donations';

  @override
  String get wizardCommitment => 'Choose your commitment';

  @override
  String get wizardCommitmentSage => 'Select your consistency goals';

  @override
  String get wizardConfirmed => 'Commitment confirmed';

  @override
  String get wizardConfirmedSage => 'You\'ve set up your learning path!';

  @override
  String get wizardCuriosity => 'Out of curiosity';

  @override
  String get wizardDetectScams => 'Detect scams';

  @override
  String get wizardFacebook => 'Facebook';

  @override
  String get wizardFriends => 'Friends';

  @override
  String get wizardGoal10 => '10 min';

  @override
  String get wizardGoal10Sub => 'Normal';

  @override
  String get wizardGoal15 => '15 min';

  @override
  String get wizardGoal15Sub => 'Serious';

  @override
  String get wizardGoal3 => '3 min';

  @override
  String get wizardGoal30 => '30 min';

  @override
  String get wizardGoal30Sub => 'Intense';

  @override
  String get wizardGoal3Sub => 'Relaxed';

  @override
  String get wizardGoogle => 'Google';

  @override
  String get wizardHaveFun => 'To have fun';

  @override
  String get wizardHowDidYouFind => 'How did you hear about SAGEN?';

  @override
  String get wizardHowDidYouFindSage => 'Tell me, how did you find us?';

  @override
  String get wizardHowFound => 'How did you find SAGEN?';

  @override
  String get wizardHowFoundSage => 'Tell me, how did you find us?';

  @override
  String get wizardHowMuchKnow =>
      'How much do you know about digital security?';

  @override
  String get wizardHowMuchKnowSage => 'How much do you know about the topic?';

  @override
  String get wizardHowMuchSage => 'How much do you know about the topic?';

  @override
  String get wizardHowMuchYouKnow =>
      'How much do you know about digital security?';

  @override
  String get wizardHowPrefer => 'How do you prefer to learn?';

  @override
  String get wizardHowPreferSage => 'Choose your preferred ways to learn';

  @override
  String get wizardInstagram => 'Instagram';

  @override
  String get wizardLevel1 => 'I\'m a beginner';

  @override
  String get wizardLevel1Sub => 'I\'ve never explored this subject';

  @override
  String get wizardLevel2 => 'I know a few concepts';

  @override
  String get wizardLevel2Sub => 'I recognize a few terms';

  @override
  String get wizardLevel3 => 'I can defend myself';

  @override
  String get wizardLevel3Sub => 'I understand and practice the basics';

  @override
  String get wizardLevel4 => 'I understand multiple topics';

  @override
  String get wizardLevel4Sub => 'I master multiple concepts';

  @override
  String get wizardLevel5 => 'I know the subject well';

  @override
  String get wizardLevel5Sub => 'I can debate advanced topics';

  @override
  String get wizardLinks => 'Analyze links';

  @override
  String get wizardNews => 'News';

  @override
  String get wizardOther => 'Other';

  @override
  String get wizardPrepareWork => 'Prepare me for work';

  @override
  String get wizardProtect => 'Protect me';

  @override
  String get wizardProtectAccounts => 'Protect my accounts';

  @override
  String get wizardProtectFamily => 'Protect my family';

  @override
  String get wizardProtectPrivacy => 'Protect my privacy';

  @override
  String get wizardQuizzes => 'Practice with quizzes';

  @override
  String get wizardSafeBrowsing => 'Browse safely';

  @override
  String get wizardTV => 'TV';

  @override
  String get wizardTikTok => 'TikTok';

  @override
  String get wizardTimeDedicate => 'How much time can you dedicate per day?';

  @override
  String get wizardTimeSage => 'Choose your ideal learning pace';

  @override
  String get wizardVideos => 'Watch educational videos';

  @override
  String get wizardWelcome => 'Welcome to SAGEN!';

  @override
  String get wizardWelcomeSage =>
      'Hi! I\'m Sage, your guide to digital security. Shall we begin?';

  @override
  String get wizardWelcomeTitle => 'Welcome to SAGEN!';

  @override
  String get wizardWhatLearn => 'What would you like to learn?';

  @override
  String get wizardWhatLearnSage => 'What would you like to learn first?';

  @override
  String get wizardWhyLearn => 'Why do you want to learn?';

  @override
  String get wizardWhyLearnSage => 'Why do you want to learn digital security?';

  @override
  String get wizardYouTube => 'YouTube';

  @override
  String get xpBoostLabel => 'x2 XP Boost';

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
  String get yourActivity => 'Your activity';

  @override
  String get yourLearning => 'Your learning';

  @override
  String get xpLabel => 'XP';

  @override
  String get xpMultiplier => 'x2 XP';

  @override
  String get chatTypingIndicator => 'Sage is typing...';

  @override
  String get demoModeOffline => 'DEMO MODE — Offline';

  @override
  String get errorSync => 'Sync error';

  @override
  String shareChestText(Object items, Object type) {
    return 'I got $items from a $type chest on SAGEN!';
  }

  @override
  String get paymentMethodsLocal => 'WhatsApp / Yape / Plin';

  @override
  String get paymentMethodsMercadoPago => 'Mercado Pago';

  @override
  String get streakFlame => 'Streak flame';

  @override
  String treasureChest(Object type) {
    return 'Treasure chest $type';
  }

  @override
  String get errorRestart => 'Restart';

  @override
  String get chatEmptyDesc =>
      'Ask anything about cybersecurity or choose a quick suggestion.';

  @override
  String get continueButton => 'Continue';

  @override
  String get shareButton => 'Share';

  @override
  String get tapToContinue => 'Tap to continue';

  @override
  String get paymentSuccessful => 'Payment successful';

  @override
  String get errorLoadingQuestions => 'Error loading questions.';

  @override
  String get errorGenericShort => 'Error';

  @override
  String quizTimeRemaining(Object time) {
    return 'Time remaining: $time';
  }

  @override
  String get quizVerdictCorrect => 'Correct answer';

  @override
  String get quizVerdictIncorrect => 'Incorrect answer';

  @override
  String get exitQuizTitle => 'Are you sure you want to exit the lesson?';

  @override
  String get exitQuizContent => 'Are you sure you want to exit the quiz?';

  @override
  String currentStreakDays(Object count) {
    return 'Current streak: $count days';
  }

  @override
  String get activityMap30Days => 'Activity map of the last 30 days';

  @override
  String courseProgressLabel(Object percent) {
    return 'Total course progress: $percent%';
  }

  @override
  String stageProgressLabel(Object percent) {
    return 'Stage progress: $percent%';
  }

  @override
  String collapseSession(Object title) {
    return 'Collapse session: $title';
  }

  @override
  String expandSession(Object title) {
    return 'Expand session: $title';
  }

  @override
  String xpGainedLabel(Object xp) {
    return '+$xp XP gained';
  }

  @override
  String accuracyPercentLabel(Object percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String timeLabel(Object time) {
    return 'Time: $time';
  }

  @override
  String livesRemainingLabel(Object count) {
    return 'Lives remaining: $count of 3';
  }

  @override
  String get miniGameExitTitle => 'Exit game?';

  @override
  String get miniGameExitContent =>
      'You\'ll lose your current progress. Are you sure?';

  @override
  String get paymentCancelTitle => 'Cancel payment';

  @override
  String get paymentCancelContent =>
      'Are you sure you want to cancel? Progress will be lost.';

  @override
  String resultXpGained(Object xp) {
    return '$xp earned';
  }

  @override
  String resultAccuracyLabel(Object percent) {
    return 'Accuracy: $percent%';
  }

  @override
  String resultLivesLabel(Object count) {
    return 'Lives: $count';
  }

  @override
  String get storeNewChestHint => 'New chest available';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String gemBalanceLabel(Object count) {
    return 'Gem balance: $count';
  }

  @override
  String wizardStepLabel(Object step) {
    return 'Step $step';
  }
}
