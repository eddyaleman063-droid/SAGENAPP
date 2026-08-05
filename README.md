# SAGEN

**Tu guía digital** — Aprende ciberseguridad de forma inteligente.

---

## Requisitos

- Flutter SDK ≥3.11
- Android Studio / VS Code
- API keys (ver `.env.example`)

## Setup rápido

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

---

## Uso del script `run.ps1`

El script principal para desarrollo. Lee automáticamente las variables del `.env` y las pasa como `--dart-define` a Flutter.

| Comando | Descripción |
|---------|-------------|
| `.\run.ps1 run` | Ejecuta en modo debug |
| `.\run.ps1 release` | Ejecuta en modo release |
| `.\run.ps1 apk` | Build APK debug |
| `.\run.ps1 apk --release` | Build APK release |
| `.\run.ps1 bundle` | Build App Bundle (AAB) |
| `.\run.ps1 analyze` | Análisis estático |
| `.\run.ps1 clean` | Clean + pub get |
| `.\run.ps1 log` | Muestra el changelog |
| `.\run.ps1 version` | Muestra versión actual |

Se pueden pasar argumentos extra directamente a Flutter:

```bash
.\run.ps1 run -d emulator-5554
.\run.ps1 apk --release --target-platform android-arm64
```

## Uso del script `build.ps1`

Para builds de release/CI.

```bash
# APK release
.\build.ps1 apk

# App Bundle con versión personalizada
.\build.ps1 appbundle --Version 1.1.0 --BuildNumber 2

# APK release saltando análisis
.\build.ps1 apk --SkipTests
```

## API Keys

| Variable | Servicio | Dónde obtenerla |
|----------|----------|-----------------|
| `GEMINI_API_KEY` | Google Gemini (IA) | https://aistudio.google.com |

Las keys se cargan desde `.env` y se pasan como `--dart-define`. El archivo `.env` está en `.gitignore`.

## Estructura del proyecto

```
lib/
  config/          — Configuración global (API keys, temas)
  constants/       — Constantes del dominio
  models/          — Modelos de datos
  providers/       — State management (Provider)
  screens/         — Pantallas
  services/        — Servicios externos (Gemini API, sincronización)
  utils/           — Utilidades
  widgets/         — Widgets reutilizables
```

## Versionado

- `pubspec.yaml` — versión semántica oficial (`1.0.0+1`)
- `lib/config/app_config.dart` — versión para la app (puede sobrescribirse con `--dart-define=APP_VERSION=x.x.x`)
- `lib/models/update_log.dart` — changelog interno que se muestra en la pantalla de Actualizaciones

## Convenciones

- 0 errores, 0 warnings en `flutter analyze`
- Widgets con `const` constructor cuando sea posible
- `dispose()` en todos los `StatefulWidget`
- Comentarios en español
- Sin emojis en código (excepto en textos de UI en español)

---

Hecho con ❤️ para estudiantes que se quieren proteger.
