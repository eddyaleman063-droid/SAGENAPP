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

### Changed
- Git for Windows instalado; remote sin PAT embebido (usa Git Credential Manager).
- `dart format` aplicado a todo `lib/` y `test/` (374 archivos).
- Umbrales de wall-clock de `cache_integration_test` ampliados para que no falle bajo `--coverage`.
- Improved ConnectivityService with proper StreamSubscription lifecycle
- Added cacheWidth/cacheHeight to all Image.asset calls
- Extracted shared StatChip/RewardBadge widgets from mini-games
- Added surfaceTinted/borderSubtle to AppColorsX extension

### Fixed
- Bug en `CurrentUserRankBar`: `rankingYourPosition` recibía `(rank, xp)` pero la firma generada es `(xp, rank)`; se mostraba "Tu posición: #5.0k · 3 XP" en lugar de "#3 · 5.0k XP".
- ConnectivityService StreamSubscription memory leak
- Missing theme extensions for mini-game screens## [5.1.0] - 2025-01-XX

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
