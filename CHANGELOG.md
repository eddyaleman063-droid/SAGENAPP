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

### Changed
- `targetSdk` de Android a API 36 (Android 16): requisito de Google Play (API 35 desde ago-2025, API 36 desde ago-2026). `compileSdk` ya era 36.
- Migrado de `flutter_markdown` (discontinuado) a `flutter_markdown_plus` (fork mantenido, mismo API).

### Added
- Tests del webhook LIVE de Vercel (`api/index.js`): 15 tests nuevos (verificación de firma HMAC, retry 5xx ante fallo de MP, crédito idempotente de pagos aprobados, validación de `adminCreditDonation` con coerción de monto string→número y gate de auth 401/403). Jest sube a 232/232.
- `functions/jest.config.js`: `moduleDirectories` para resolver deps desde `functions/node_modules`; los tests de `api/` quedan incluidos en `npm test` (CI).

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
