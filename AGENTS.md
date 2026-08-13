# AGENTS.md

Protocolo obligatorio para CUALQUIER agente/sesión que edite este repositorio.

## Regla de oro: una sola sesión editando a la vez

Este repo es compartido. Varias sesiones de herramientas de IA (bajo distintos
usuarios de Windows) han corrompido archivos al editar en paralelo el mismo
directorio. Para que no vuelva a ocurrir:

1. ANTES de editar, adquiere el lock de sesión:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 lock`
   - Si falla, otra sesión está activa. NO edites hasta que se libere o el lock
     quede stale (2 h). Resuelve con la otra sesión primero.
2. DESPUÉS de terminar, libera el lock:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 unlock`
3. Verifica la integridad antes y después de cada tanda de cambios:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 check`
4. Antes de cerrar un trabajo importante, crea un punto de restauración:
   `powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 snapshot`

## Reglas de edición segura

- Nunca escribas listados con números de línea dentro de archivos `.dart`.
- Usa escrituras atómicas (la herramienta de edición por reemplazo exacto;
  nunca vuelques salidas de consola sobre archivos fuente).
- Si `check` reporta corrupción, restaura el snapshot más reciente
  (`list` para verlos, descomprime sobre la raíz del repo).
- No commitees credenciales ni llaves (`.env`, `firebase_options` con secretos).

## Convenciones del proyecto

- Flutter 3.x, Dart >= 3.11.5.
- Estado: Riverpod (`Notifier`/`NotifierProvider`).
- Validación: `flutter analyze` y `flutter test` deben quedar en verde.
- L10n: las cadenas viven en `lib/l10n/app_*.arb` (template: `app_es.arb`).
  Tras editarlas, regenerar con `flutter gen-l10n`.
- Backend: Cloud Functions en `functions/` (Node.js).
