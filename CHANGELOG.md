# Changelog

All notable changes to SAGEN will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Dependency audit CI workflow
- Architecture documentation (ARCHITECTURE.md)
- Contributing guide (CONTRIBUTING.md)
- Code style guide (STYLE_GUIDE.md)
- PR template for GitHub
- CODEOWNERS file
- Release notes template

### Changed
- Improved ConnectivityService with proper StreamSubscription lifecycle
- Added cacheWidth/cacheHeight to all Image.asset calls
- Extracted shared StatChip/RewardBadge widgets from mini-games
- Added surfaceTinted/borderSubtle to AppColorsX extension

### Fixed
- ConnectivityService StreamSubscription memory leak
- Missing theme extensions for mini-game screens

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
