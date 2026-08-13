class AppConfig {
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');

  static const String appName = 'SAGEN';
  static const String appVersion = String.fromEnvironment('APP_VERSION', defaultValue: '5.1.1');
  static const String appBuildNumber = String.fromEnvironment('APP_BUILD', defaultValue: '7');
  static const String appTagline = 'Your digital guide';
  static const String appTaglineAlt = 'Learn cybersecurity the smart way';
  static const String appSlogan = 'Your cybersecurity guide.';

  static const String geminiModel = 'gemini-2.5-flash';
  static const int geminiMaxOutputTokens = 8192;
  static const double geminiTemperature = 0.85;
  static const int geminiTopK = 40;
  static const double geminiTopP = 0.95;
  static const Duration geminiTimeout = Duration(seconds: 30);
  static const Duration geminiStreamTimeout = Duration(seconds: 45);
  static const int geminiMaxRetries = 3;
  static const Duration geminiRetryDelay = Duration(seconds: 2);

  static const Duration defaultTimeout = Duration(seconds: 15);

  static const int maxContextMessages = 20;
  static const int maxCachedConversations = 20;

  /// Mercado Pago payment link — must be set before release.
  static const String mercadopagoLink = String.fromEnvironment(
    'MERCADOPAGO_LINK',
    defaultValue: '',
  );

  /// Base URL for Mercado Pago API (Vercel).
  static const String mercadopagoFunctionsUrl = String.fromEnvironment(
    'MP_FUNCTIONS_URL',
    defaultValue: '',
  );

  /// Donation package prices (USD) — used by PaywallBottomSheet.
  static const double donationBasic = 3.00;
  static const double donationPopular = 5.00;
  static const double donationPremium = 10.00;
  static const int supporterLevelBasic = 1;
  static const int supporterLevelPopular = 2;
  static const int supporterLevelPremium = 3;

  /// WhatsApp support number — must be set before release.
  static const String whatsappNumber = String.fromEnvironment(
    'WHATSAPP_NUMBER',
    defaultValue: '',
  );
}
