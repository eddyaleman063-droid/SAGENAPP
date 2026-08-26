# AGENTS.md

Protocolo obligatorio para CUALQUIER agente/sesion que edite este repositorio.

## Regla de oro: una sola sesion editando a la vez

Este repo es compartido. Varias sesiones de herramientas de IA (bajo distintos
usuarios de Windows) han corrompido archivos al editar en paralelo el mismo
directorio. Para que no vuelva a ocurrir:

1. ANTES de editar, adquiere el lock de sesion:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 lock`
   - Si falla, otra sesion esta activa. NO edites hasta que se libere o el lock
     quede stale (2 h). Resuelve con la otra sesion primero.
2. DESPUES de terminar, libera el lock:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 unlock`
3. Verifica la integridad antes y despues de cada tanda de cambios:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 check`
4. Antes de cerrar un trabajo importante, crea un punto de restauracion:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 snapshot`

## Reglas de edicion segura

- Nunca escribas listados con numeros de linea dentro de archivos `.dart`.
- Usa escrituras atomicas (la herramienta de edicion por reemplazo exacto;
  nunca vuelques salidas de consola sobre archivos fuente).
- Si `check` reporta corrupcion, restaura el snapshot mas reciente
  (`list` para verlos, descomprime sobre la raiz del repo).
- No commitees credenciales ni llaves (`.env`, `firebase_options` con secretos).

## Comandos obligatorios antes de commit

```bash
# Siempre en verde antes de commitear:
flutter analyze           # 0 errores, 0 warnings
flutter test              # 0 failures
dart format . --output=none --set-exit-if-changed  # 0 drift

# Regenerar l10n si se editaron ARB files:
flutter gen-l10n
```

## Convenciones del proyecto

- Flutter 3.x, Dart >= 3.11.5.
- Branch: `master`, remote: `https://github.com/eddyaleman063-droid/SAGENAPP.git`.
- Estado: Riverpod (`Notifier`/`NotifierProvider`). Usar `ref.watch` en UI, `ref.read` en logica.
- Routing: go_router con redirect centralizado (`lib/router/app_router.dart`).
- Validacion: `flutter analyze` y `flutter test` deben quedar en verde.
- L10n: las cadenas viven en `lib/l10n/app_*.arb` (template: `app_es.arb`).
  Tras editarlas, regenerar con `flutter gen-l10n`.
  - ICU: escapar apostrofes con `''` en ARB files.
- Backend: Cloud Functions en `functions/` (Node.js).
- Error handling: `AppLogger().error(msg, exception, stack)` para logging.
  En release mode, esto se reporta automaticamente a Crashlytics.
- Testing: test files en `test/` siguen la misma estructura que `lib/`.

## Referencia rapida de archivos clave

| Archivo | Descripcion |
|---------|-------------|
| `lib/main.dart` | Entry point, setup de providers globales |
| `lib/router/app_router.dart` | 24 rutas + redirect de auth |
| `lib/providers/providers.dart` | Barrel file de todos los providers |
| `lib/services/sage_ai_provider.dart` | Chat con Sage (streaming) |
| `lib/services/app_logger.dart` | Logging centralizado + Crashlytics |
| `lib/core/result.dart` | AppResult<T> / AppError<T> |
| `lib/core/theme/` | Tema visual (AppColors, AppTextStyle, etc.) |
| `tools/repo_guard.ps1` | Lock/snapshot/check del repo |

## Providers mas importantes

- `authProvider` — Estado de autenticacion (AuthState)
- `sageAiProvider` — Chat con Sage (streaming, mensajes)
- `learningProvider` — Estado del learning (stages, lessons)
- `streakProvider` — Streak diario
- `gamificationProvider` — Gamificacion (XP, logros)
- `registrationFunnelProvider` — Flujo de registro
- `experienceServiceProvider` — Servicios de experiencia (haptics, font scale)
- `themeProvider` / `languageProvider` — Tema e idioma
