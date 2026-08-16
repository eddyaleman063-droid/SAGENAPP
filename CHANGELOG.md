# Changelog

All notable changes to SAGEN will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.1.1] - 2026-08-05

### Fixed
- Build de Android: `workmanager` actualizado de 0.5.2 a 0.10.7 (la API antigua usaba el Flutter embedding v1, incompatible con Flutter 3.41+). `BackgroundSyncService` funciona con el embedding moderno.
- `MainActivity.kt`: `FirebaseOptions.fromResource()` ahora devuelve `FirebaseOptions?`; se maneja el caso nulo antes de `FirebaseApp.initializeApp`.
- `android/gradle.properties`: eliminada la ruta hardcodeada de `org.gradle.java.home` que rompía el build sin Android Studio.

### Changed
- Removidos archivos temporales de debug/tests de la raíz del repo.

## [Unreleased]

### Fixed
- Barra de estado: el brillo de los íconos (estado + navegación) ahora sigue el tema activo (`AnnotatedRegion`), en vez de quedar fijo en blanco — en tema claro quedaban invisibles y con edge-to-edge forzado (API 35/36) se hacía más notorio.
- `ios/Podfile` faltante: el proyecto iOS no podía compilar con plugins nativos (ni CocoaPods ni SPM). Se añade el Podfile canónico de Flutter 3.41.9; `pod install` lo integra al pbxproj.
- CI `release.yml`: los artefactos (APK/AAB) no se adjuntaban al release (glob no recursivo) y el path del deploy a Firebase App Distribution apuntaba a `release/*.aab` que no existe; ahora apunta a la ruta real del AAB.
- CI `pr_check.yml`: el check de formato y los tests corrían con `continue-on-error` (no gateaban); se quita. El diff para TODO/FIXME ahora se compara contra `origin/master`.
- Manifest PWA (`web/manifest.json`): `background_color`/`theme_color` alineados al color de marca (`#1565C0`) en vez del azul por defecto de Flutter.
- Webhooks de MercadoPago (Cloud Functions y Vercel): fallos transitorios (fetch a MP o error interno) devuelven 5xx para que MP reintente en vez de 200; el catch-all ya no traga errores.
- `registerPendingPayment` y `adminCreditDonation`: validación de monto (rango 0..100000) y sanitización de `operationId`/`userId`/`idempotencyKey` (regex `[A-Za-z0-9_-]`) contra path-injection en ids de documentos.
- Guards contra `data` nulo en callables.
- Webhook de Vercel (`api/index.js`): una firma malformada (no-hex) devuelve 401 en vez de 500, alineado con Cloud Functions (la validación previa a `timingSafeEqual` evita que un probe barato fuerce un retry).
- `firestore.rules`: error de sintaxis que BLOQUEABA el deploy (`request.resource.data.keys.size() <= 10` — `keys()` es un método en el lenguaje de reglas; sin paréntesis es un parse error y `firebase deploy --only firestore:rules` fallaba). Corregido a `keys().size()`.
- `api/index.js` (`payment_logs`): la clave `amount` estaba duplicada en el objeto de escritura y el segundo valor (`transaction_amount`) pisaba al monto acreditado. Alineado con Cloud Functions: ahora guarda `amount` (acreditado) y `paymentAmount` (bruto).
- Catch blocks silenciosos en `FlexCardWidget.capture`, `StoreScreen._isOwned` y `HabitTransitionScreen` ahora loguean errores via `AppLogger` en vez de tragarlos silenciosamente.
- `ProfileScreen` y `StoreScreen`: ahora muestran UI de error explícita (`errorMessage`) cuando falla la carga de datos, en vez de dejar la pantalla en estado vacío sin feedback.
- `GemProvider.spendShopGems`: catch block ahora loguea errores de compra fallida en vez de fallar silenciosamente.
- `LoginScreen`: catch blocks de email, Google y Facebook login ahora loguean errores via `AppLogger`.
- `ForgotPasswordScreen`: catch block ahora loguea errores de envío de email de recuperación.
- `SpeedSortScreen`: `_initGame` ahora valida que existan al menos 2 categorías antes de acceder a `entries[1]`, evitando `RangeError`.

### Changed
- `targetSdk` de Android a API 36 (Android 16): requisito de Google Play (API 35 desde ago-2025, API 36 desde ago-2026). `compileSdk` ya era 36.
- Migrado de `flutter_markdown` (discontinuado) a `flutter_markdown_plus` (fork mantenido, mismo API).
- Fallback de error de release (`ErrorWidget.builder`): ahora es localizado (es/en) usando la preferencia de idioma persistida en vez de cadenas en inglés fijas; incluye etiqueta de accesibilidad en el botón.
- `registerPendingPayment` en Vercel: ID determinístico `${userId}_${operationId}` como en Cloud Functions, para que un retry de red no cree pagos pendientes duplicados (responde `duplicate: true`).
- `web/index.html`: `<meta name="theme-color">` al color de marca (`#1565C0`) para que aplique antes de cargar el manifest.
- Selector de idioma: `AppLanguage` ahora soporta 4 idiomas (es/en/fr/pt) con código persistido; sin preferencia guardada la app sigue el idioma del sistema cuando está soportado (antes solo es/en y el resto caía en español).
- Migrados campos deprecated de `ThemeData`: `cardColor` → `CardThemeData`, `dividerColor` → `DividerThemeData` (4 temas: light, dark, highContrastLight, highContrastDark).
- `MediaQuery.of(context).size` → `MediaQuery.sizeOf(context)` + accessores targeteados (`viewInsetsOf`, `paddingOf`) en 3 archivos para reducir rebuilds innecesarios.
- Accesibilidad: progress indicators decorativos con `ExcludeSemantics` (5 en pass cards, gatekeeper, wizard, onboarding bar); el wizard_top_bar ahora anuncia paso y porcentaje.
- Accesibilidad: iconos decorativos (flechas, diamantes, insignias) envueltos en `ExcludeSemantics` para evitar anuncios redundantes de TalkBack/VoiceOver.
- Accesibilidad: tab Store ahora incluye `hint: 'Nuevo cofre disponible'` cuando el badge de cofre está visible; `selected` declarado explícitamente en todos los tabs.
- `wizard_top_bar.dart` convertido de `ConsumerWidget` a `StatelessWidget` (el `ref` no se usaba).
- `store_screen.dart` optimizado: `ref.watch` ahora usa `.select` para solo reconstruir cuando cambia `isLoading` o `errorMessage`.
- Widgets duplicados DRY: `_TipRow` privado de `store_screen` y `sagen_pass_screen` extraído a widget compartido `TipRow` (`lib/ui/widgets/common/tip_row.dart`).
- `achievement_card.dart`: dos switches extensos refactorizados a maps lookup (`_titles`, `_descriptions`).
- 5 archivos huérfanos eliminados (1,085 líneas): `cyber_quiz_screen.dart`, `weekly_calendar_widget.dart`, `error_retry_widget.dart`, `glass_card.dart`, `onboarding_progress_bar.dart` + tests asociados.
- `_BenefitRow`/`_BenefitRow2` duplicados en `streak_intro_screen` y `profile_hook_screen` extraídos a widget compartido `BenefitRow` (`lib/ui/widgets/common/benefit_row.dart`).
- `WizardSingleChoiceTile`/`WizardMultiChoiceTile` refactorizados: lógica de build compartida en `_WizardOptionTileBase` con flag `showCheckbox`.
- Accesibilidad: `ExcludeSemantics` en 13 `CircularProgressIndicator` decorativos (5 en botones de auth/share/buy, 4 en mini-games, 1 en payment pending, 3 en store).
- Strings hardcodeados en español localizados: `'Nuevo cofre disponible'`, `'Foto de perfil'`, `'Saldo de gemas'`, `'Paso N'` (4 claves l10n nuevas en es/en/fr/pt).

### Added
- Tests del webhook LIVE de Vercel (`api/index.js`): 15 tests nuevos (verificación de firma HMAC, retry 5xx ante fallo de MP, crédito idempotente de pagos aprobados, validación de `adminCreditDonation` con coerción de monto string→número y gate de auth 401/403). Jest sube a 232/232.
- +8 tests más del API de Vercel (flip de `pending_payments` por webhook, dedupe y validación de `registerPendingPayment`, ownership en `checkPendingPaymentStatus`). Jest sube a 239/239.
- `functions/__mocks__/firebase-admin.js`: soporte de `collection().where().get()` para que los tests del webhook verifiquen el flip real de `pending_payments` (antes caía en el catch silencioso).
- Test de reglas: `firestore_rules.test.js` ahora afirma `keys().size()` y habría detectado el bug de sintaxis.
- Selector de idioma en `SettingsSheet` (junto al de tema): grid 2×2 con Español/English/Français/Português, haptic, analytics y persistencia.
- +9 tests del provider de idioma (fr/pt: locale, persistencia y restauración desde prefs). Flutter pasa a 1156 tests.

## [5.1.2] - 2026-08-15

### Added
- `DailyChestCard` en la tienda: cofre diario reclamable (F-02 server-authoritative con `claimDailyChest` en Cloud Functions y `applyServerXp` local).
- `tools/repo_guard.ps1` y protocolo `AGENTS.md`: lock de sesión y snapshots para evitar corrupción por sesiones en paralelo.
- CI en rama `master` + job de tests Jest para Cloud Functions.
- Lints estrictos en `analysis_options.yaml` (const, final fields, llaves en control-flow).
- `dart_test.yaml`: los benchmarks de performance quedan taggeados `performance` y se saltean por defecto; el `nightly` los ejecuta con `--tags performance --run-skipped`.
- Cobertura honesta en CI: `lcov --remove` excluye código generado (`app_localizations*.dart`, `*.g.dart`, `*.freezed.dart`) antes de medir.
- Dependency audit CI workflow
- PR template for GitHub
- Release notes template
- +60 tests: cobertura de `SageEmotionService`, widgets comunes (TapScale, SkipToContent, KeyboardAwareLayout, StatCardWidget), learning (QuizFeedbackCard, QuizOptionButton), home (HeroMissionCard), auth (AuthSocialButtons), sage_chat (QuickChips, MessageBubble), ranking (CurrentUserRankBar), animaciones (ParticleBurst), onboarding (LegalTextBlock, WizardSummaryRow).
- Accesibilidad: live regions de accesibilidad para el temporizador y el veredicto del quiz, semántica de accesibilidad en el calendario semanal (día completado/hoy), tests de widgets de a11y (quiz + calendario).
- Reforzadas las Firestore Security Rules: `validProfileUpdate()` valida tipo y rango de cada campo modificado, y `pending_payments` exige `amount is int == 0`.

### Changed
- Git for Windows instalado; remote sin PAT embebido (usa Git Credential Manager).
- `dart format` aplicado a todo `lib/` y `test/` (374 archivos).
- Umbrales de wall-clock de `cache_integration_test` ampliados para que no falle bajo `--coverage`.
- Improved ConnectivityService with proper StreamSubscription lifecycle
- Added cacheWidth/cacheHeight to all Image.asset calls
- Extracted shared StatChip/RewardBadge widgets from mini-games
- Added surfaceTinted/borderSubtle to AppColorsX extension
- Dependencias: bumps seguros same-major (`confetti` 0.8.0, `rive` 0.14.11 con migración del widget de llama a la nueva API `RiveWidgetBuilder`, `audioplayers` 6.7.1, `lottie` 3.3.3, `sqflite_common_ffi` 2.4.0+3). `json_annotation`/`json_serializable` quedan fijados porque las versiones nuevas exigen `build ^4`, incompatible con `freezed` 2.x.

### Fixed
- Bug en `CurrentUserRankBar`: `rankingYourPosition` recibía `(rank, xp)` pero la firma generada es `(xp, rank)`; se mostraba "Tu posición: #5.0k · 3 XP" en lugar de "#3 · 5.0k XP".
- ConnectivityService StreamSubscription memory leak
- Missing theme extensions for mini-game screens
- 40 archivos muertos eliminados (sin referencias en `lib/`, `test/` ni `integration_test/`) y 3 carpetas vacías (`lib/extensions`, `lib/models/states`, `lib/ui/widgets/illustrations`).
- Security hardening en Cloud Functions y API: `idempotencyKey`/`lessonId` sanitizados contra inyección de paths (regex `[A-Za-z0-9_-]`), `reason` de `addXp` whitelisteado contra field-path injection, `correctCount`/`totalQuestions` requieren enteros estrictos (anti-farm), `Number.isFinite` en montos, y `getProductDetails` nulo devuelve 400 en vez de 500.
- L10n: placeholders sin declarar en metadata (`storeDailyChestReward`, `shareChestText`, `treasureChest`) en las 4 locales, y apóstrofos ICU escapados en francés (`shareChestText`).
- Fix defensivo en `_unlockFirstStage` (lista de stages vacía).
- Lint `prefer_const_constructors` aplicado en los nuevos tests.

## [5.1.0] - 2025-01-XX

### Added
- 200 learning sessions across 8 stages
- 1,099 interactive lessons
- Sage AI chatbot with Gemini integration
- Mini-games (Word Match, Speed Sort, Pattern Trace, Memory Flip)
- Chest gacha reward system
- Daily streak system with animations
- Experience/leveling system
- MercadoPago payment integration
- Admin credit management screen
- Certificate pinning
- Root/jailbreak detection
- Performance monitoring
- Feature flags via Firebase Remote Config
- A/B testing infrastructure
- CI/CD pipeline with GitHub Actions
- Firestore backup scripts
- Rollback strategy scripts
- Disaster recovery procedures

### Security
- XSS sanitization on all user inputs
- Age clamping for content filtering
- Field allowlist for Firestore writes
- Firebase Security Rules enforcement

## [5.0.0] - 2024-12-XX

### Added
- Initial release of SAGEN v5
- Complete cybersecurity curriculum
- Firebase Authentication
- Firestore database
- Localization (Spanish/English)
- Dark/light mode
- Offline support
