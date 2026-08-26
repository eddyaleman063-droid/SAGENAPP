# SAGEN

**Tu guia digital** — Aprende ciberseguridad de forma inteligente.

---

## Requisitos

- Flutter SDK >=3.11.5, Dart >=3.11.5
- Android Studio / VS Code
- API keys (ver `.env.example`)

## Setup rapido

```bash
# 1. Clonar el repo
git clone <url>
cd SAGENAPP

# 2. Instalar dependencias
flutter pub get

# 3. Configurar API keys
cp .env.example .env
# Editar .env con tu API key (GEMINI_API_KEY)

# 4. Correr la app
.\run.ps1
```

## Setup automatico en maquina nueva (Windows)

`setup.ps1` detecta e instala todo el toolchain (Flutter 3.41.9, JDK 17,
Android SDK con platform-tools, platforms;android-36, build-tools y NDK 28.2),
corre `flutter pub get` y compila el APK debug:

```powershell
# Todo de una vez (incluye build del APK)
.\setup.ps1

# Solo toolchain + dependencias (sin build)
.\setup.ps1 -SkipBuild

# Sin instalar el Android SDK (solo analyze/test)
.\setup.ps1 -SkipAndroidSdk
```

---

## Scripts de desarrollo

### `run.ps1`

El script principal para desarrollo. Lee automaticamente las variables del `.env` y las pasa como `--dart-define` a Flutter.

| Comando | Descripcion |
|---------|-------------|
| `.\run.ps1 run` | Ejecuta en modo debug |
| `.\run.ps1 release` | Ejecuta en modo release |
| `.\run.ps1 apk` | Build APK debug |
| `.\run.ps1 apk --release` | Build APK release |
| `.\run.ps1 bundle` | Build App Bundle (AAB) |
| `.\run.ps1 analyze` | Analisis estatico |
| `.\run.ps1 clean` | Clean + pub get |
| `.\run.ps1 log` | Muestra el changelog |
| `.\run.ps1 version` | Muestra version actual |

### `build.ps1`

Para builds de release/CI.

```bash
.\build.ps1 apk                           # APK release
.\build.ps1 appbundle --Version 1.1.0     # AAB con version custom
.\build.ps1 apk --SkipTests               # APK saltando tests
```

---

## API Keys

| Variable | Servicio | Donde obtenerla |
|----------|----------|-----------------|
| `GEMINI_API_KEY` | Google Gemini (IA) | https://aistudio.google.com |

Las keys se cargan desde `.env` y se pasan como `--dart-define`. El archivo `.env` esta en `.gitignore`.

---

## Arquitectura

### Stack tecnico

- **Framework**: Flutter 3.x, Dart >=3.11.5
- **Estado**: Riverpod 2.x (`Notifier`/`NotifierProvider`)
- **Routing**: go_router con redirect centralizado
- **L10n**: ARB files en `lib/l10n/` (template: `app_es.arb`)
- **Backend**: Firebase (Auth, Firestore, Crashlytics, Functions)
- **IA**: Google Gemini API para chat con Sage

### Estructura del proyecto

```
lib/
  config/          — AppConfig, feature flags, API keys
  core/
    initialization/— ServiceInitializer (Firebase, prefs, services)
    interfaces/    — Abstract contracts (IDatabaseHelper)
    result.dart    — AppResult<T> / AppError<T> tipado
    theme/         — AppTheme, AppColors, AppTextStyle, AppRadius, AppSpacing
  l10n/            — Localización (app_es.arb, app_en.arb, app_fr.arb, app_pt.arb)
  models/          — Modelos de datos (ChatMessage, Stage, Lesson, etc.)
  providers/       — Riverpod providers (state management)
  repositories/    — Data access layer (SharedPreferences, Firestore)
  router/          — app_router.dart (go_router config)
  services/        — Business logic services (sage_ai, streak, payments, etc.)
  ui/
    screens/       — Full-screen widgets (auth, dashboard, onboarding, etc.)
    widgets/       — Reusable widgets (common/, sage_chat/, learning/, etc.)
  utils/           — Helpers (retry, map_utils, string_utils)

functions/         — Cloud Functions (Node.js)
test/              — Unit, widget, integration tests
```

### Patron de datos

```
UI (ConsumerWidget)
  ↓ ref.watch / ref.read
Providers (Notifier/NotifierProvider)
  ↓
Repositories (SharedPreferences, Firestore)
  ↓
Services (API calls, business logic)
```

Cada capa tiene una responsabilidad clara:
- **UI**: Renderiza estado, delega acciones a providers
- **Providers**: State management, orquesta services/repositories
- **Repositories**: Persistencia local (SharedPreferences) y remota (Firestore)
- **Services**: Logica de negocio, integraciones externas (Gemini, Firebase, MercadoPago)

### Routing

24 rutas planas (sin ShellRoute), redirect global centralizado en 3 fases:
1. **Cargando** → fuerza splash
2. **No autenticado** → rutas publicas o redirect a welcome
3. **Autenticado** → redirect a main o onboarding/flow segun progreso

Transiciones extraídas: `_slideFromRight`, `_slideFromBottom`, `_fadeIn`.

### Manejo de errores

**Global**:
- `AppLogger.error()` → Crashlytics automatico en release mode
- `FlutterError.onError` → Crashlytics en release
- `PlatformDispatcher.onError` → Zone errors
- `runZonedGuarded` → Safety net para async no capturado
- `ErrorBoundary` → Fallback UI en errores de build

**Por defecto**:
- Todos los `catch` deben capturar `(e, stack)` y reportar via `AppLogger().error()`
- `AppResult<T>` / `AppError<T>` para resultados tipados
- `retry()` utility con politica configurable
- Corrupt JSON en repositories → fallback a defaults + logging

### Performance

- `RepaintBoundary` en widgets complejos (message list, chest animations)
- `MessageList` como `ConsumerWidget` que watcha `streamingText` internamente
  (solo MessageList rebuilds por token, no el parent)
- AnimationControllers solo para primeros 3 mensajes (evita 97+ controllers)
- `CachedNetworkImage` para avatares
- `const` constructores donde sea posible
- `flutter_animate` para animaciones declarativas
- `reduceAnimationsProvider` para accesibilidad

### Testing

```bash
flutter test              # 1204+ tests, 0 failures
flutter analyze           # 0 errors
dart format . --output=none --set-exit-if-changed
```

Tests organizados por capa:
- `test/providers/` — Unit tests de providers
- `test/services/` — Unit tests de services
- `test/models/` — Unit tests de modelos
- `test/ui/widgets/` — Widget tests (login, input_bar, emotion, etc.)
- `test/ui/auth/` — Auth flow tests
- `test/ui/registration/` — Registration flow tests
- `test/repositories/` — Repository tests
- `test/routing/` — Router navigation tests
- `test/integration/` — Integration tests

### Convenciones

- 0 errores, 0 warnings en `flutter analyze`
- Widgets con `const` constructor cuando sea posible
- `dispose()` en todos los `StatefulWidget`
- Comentarios en espanol
- Sin emojis en codigo
- L10n: usar `flutter gen-l10n` despues de editar ARB files
- ICU: escapar apostrofes con `''` en ARB files
- Branch `master`, PRs via feature branches

---

Hecho con amor para estudiantes que se quieren proteger.
