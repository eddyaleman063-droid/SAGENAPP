<#
.SYNOPSIS
  SAGEN — One-command environment bootstrap + build
.DESCRIPTION
  Automates the full toolchain required to build SAGEN on a fresh Windows
  machine: Flutter SDK, JDK 17, Android SDK (platforms, build-tools, NDK).
  Then optionally builds the debug APK.

  What it does:
    1. Detects / installs Flutter 3.41.9 (matches this project's Dart 3.11.5)
    2. Detects / installs a JDK 17 (Temurin) if none is available
    3. Detects / installs the Android command-line tools + SDK packages
    4. Configures `flutter config --android-sdk`
    5. Runs `flutter pub get`
    6. Optionally runs `flutter build apk --debug` (default: yes)

.PARAMETER BuildApk
  Build the debug APK after setup. Default: $true.
.PARAMETER DevRoot
  Base directory for tools (Flutter, JDK, Android SDK). Default: C:\dev
.PARAMETER FlutterVersion
  Flutter version to install. Default: 3.41.9
.PARAMETER SkipAndroidSdk
  Skip Android SDK install (e.g. only want pub get / analyze).
.PARAMETER SkipBuild
  Alias for -BuildApk:$false.

.EXAMPLE
  .\setup.ps1
.EXAMPLE
  .\setup.ps1 -SkipBuild
.EXAMPLE
  .\setup.ps1 -DevRoot D:\tools -FlutterVersion 3.41.9
#>

param(
  [switch]$BuildApk = $true,
  [string]$DevRoot = 'C:\dev',
  [string]$FlutterVersion = '3.41.9',
  [switch]$SkipAndroidSdk,
  [switch]$SkipBuild
)

if ($SkipBuild) { $BuildApk = $false }

$ErrorActionPreference = 'Continue'
$esc = [char]27
$C_INFO = "${esc}[38;5;39m"; $C_OK = "${esc}[38;5;40m"; $C_WARN = "${esc}[38;5;220m"
$C_ERR = "${esc}[38;5;196m"; $C_BOLD = "${esc}[1m"; $C_RESET = "${esc}[0m"

function Step($msg) { Write-Host "${C_INFO}[*]${C_RESET} $msg" }
function Ok($msg)   { Write-Host "${C_OK}[+]${C_RESET} $msg" }
function Warn($msg) { Write-Host "${C_WARN}[!]${C_RESET} $msg" }
function Fail($msg) { Write-Host "${C_ERR}[x]${C_RESET} $msg" }

$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$ANDROID_HOME = Join-Path $DevRoot 'android-sdk'
$FLUTTER_HOME = Join-Path $DevRoot 'flutter'
$TEMP_DIR = Join-Path $env:TEMP 'sagen_setup'

Write-Host "${C_BOLD}SAGEN — Environment bootstrap${C_RESET}"

# ──────────────────────────── 1. Flutter SDK ────────────────────────────

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($flutterCmd) {
  $fv = & flutter --version 2>$null | Select-String 'Flutter ([0-9.]+)' | ForEach-Object { $_.Matches[0].Groups[1].Value }
  Ok "Flutter encontrado: $fv ($($flutterCmd.Source))"
} elseif (Test-Path (Join-Path $FLUTTER_HOME 'bin\flutter.bat')) {
  Ok "Flutter encontrado en $FLUTTER_HOME"
  $env:Path = "$FLUTTER_HOME\bin;$env:Path"
  $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
} else {
  Step "Flutter $FlutterVersion no encontrado. Descargando (~1.7 GB)..."
  New-Item -ItemType Directory -Force -Path $TEMP_DIR | Out-Null
  New-Item -ItemType Directory -Force -Path $DevRoot | Out-Null
  $zip = Join-Path $TEMP_DIR "flutter_$FlutterVersion.zip"
  $url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_$FlutterVersion-stable.zip"
  curl.exe -L -o $zip $url
  if ($LASTEXITCODE -ne 0) { Fail "Descarga de Flutter falló"; exit 1 }
  Step "Extrayendo Flutter..."
  tar -xf $zip -C $DevRoot
  $env:Path = "$FLUTTER_HOME\bin;$env:Path"
  Ok "Flutter instalado en $FLUTTER_HOME"
}

if (-not $flutterCmd) {
  $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
}
if (-not $flutterCmd) { Fail "No se pudo localizar 'flutter'"; exit 1 }

# ──────────────────────────── 2. JDK 17 ────────────────────────────

$javaCmd = Get-Command java -ErrorAction SilentlyContinue
$existingJdk = Get-ChildItem -Path $DevRoot -Filter 'jdk-17*' -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
if ($javaCmd) {
  $jv = & java -version 2>&1 | Select-Object -First 1
  Ok "Java encontrado: $jv"
} elseif ($existingJdk) {
  Ok "JDK encontrado en $($existingJdk.FullName)"
  $env:JAVA_HOME = $existingJdk.FullName
  $env:Path = "$($existingJdk.FullName)\bin;$env:Path"
} else {
  Step "JDK no encontrado. Descargando Temurin 17 (~180 MB)..."
  $jdkZip = Join-Path $TEMP_DIR 'jdk17.zip'
  curl.exe -L -o $jdkZip "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse"
  if ($LASTEXITCODE -ne 0) { Fail "Descarga de JDK falló"; exit 1 }
  tar -xf $jdkZip -C $DevRoot
  $existingJdk = Get-ChildItem -Path $DevRoot -Filter 'jdk-17*' -Directory | Select-Object -First 1
  if (-not $existingJdk) { Fail "No se pudo instalar el JDK"; exit 1 }
  $env:JAVA_HOME = $existingJdk.FullName
  $env:Path = "$($existingJdk.FullName)\bin;$env:Path"
  Ok "JDK instalado en $($existingJdk.FullName)"
}

if (-not $env:JAVA_HOME) {
  $env:JAVA_HOME = (Get-Command java -ErrorAction SilentlyContinue).Source | Split-Path | Split-Path
}

# ──────────────────────────── 3. Android SDK ────────────────────────────

if (-not $SkipAndroidSdk) {
  $sdkmanager = Join-Path $ANDROID_HOME 'cmdline-tools\latest\bin\sdkmanager.bat'
  if (-not (Test-Path $sdkmanager)) {
    Step "Android SDK tools no encontrados. Descargando commandlinetools (~150 MB)..."
    New-Item -ItemType Directory -Force -Path $ANDROID_HOME | Out-Null
    $cliZip = Join-Path $TEMP_DIR 'cmdtools.zip'
    curl.exe -L -o $cliZip "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    if ($LASTEXITCODE -ne 0) { Fail "Descarga de commandlinetools falló"; exit 1 }
    tar -xf $cliZip -C $ANDROID_HOME
    New-Item -ItemType Directory -Force -Path (Join-Path $ANDROID_HOME 'cmdline-tools\latest') | Out-Null
    Get-ChildItem (Join-Path $ANDROID_HOME 'cmdline-tools\cmdline-tools') -Force |
      ForEach-Object { Move-Item $_.FullName (Join-Path $ANDROID_HOME 'cmdline-tools\latest\') -Force }
    Remove-Item (Join-Path $ANDROID_HOME 'cmdline-tools\cmdline-tools') -Recurse -Force
    Ok "Commandline tools instalados"
  }

  Step "Aceptando licencias del SDK..."
  1..30 | ForEach-Object { 'y' } | & $sdkmanager --sdk_root=$ANDROID_HOME --licenses 2>$null | Out-Null

  Step "Instalando plataformas, build-tools y NDK (puede tardar)..."
  $packages = @(
    'platform-tools',
    'platforms;android-36',
    'build-tools;36.0.0',
    'build-tools;35.0.0',
    'ndk;28.2.13676358'
  )
  1..30 | ForEach-Object { 'y' } | & $sdkmanager --sdk_root=$ANDROID_HOME @packages 2>$null | Out-Null
  if ($LASTEXITCODE -ne 0) { Warn "sdkmanager reportó problemas instalando algunos paquetes" }
  Ok "Android SDK listo en $ANDROID_HOME"

  & flutter config --android-sdk $ANDROID_HOME 2>$null | Out-Null
}

# ──────────────────────────── 4. Dependencias ────────────────────────────

Step "Instalando dependencias de Flutter..."
Push-Location $PROJECT_ROOT
try {
  & flutter pub get
  if ($LASTEXITCODE -ne 0) { Fail "flutter pub get falló"; exit 1 }
  Ok "Dependencias instaladas"

  # ──────────────────────────── 5. Build APK ────────────────────────────

  if ($BuildApk) {
    Step "Compilando APK debug (primera vez puede tardar 20-40 min)..."
    & flutter build apk --debug
    if ($LASTEXITCODE -ne 0) { Fail "El build del APK falló"; exit 1 }
    $apk = Join-Path $PROJECT_ROOT 'build\app\outputs\flutter-apk\app-debug.apk'
    if (Test-Path $apk) {
      $size = [math]::Round((Get-Item $apk).Length / 1MB, 1)
      Ok "APK generado: $apk ($size MB)"
    }
  }
} finally {
  Pop-Location
}

Write-Host ""
Ok "Setup completado. SAGEN está listo para desarrollar."
Write-Host "  - run.ps1:   .\run.ps1 run"
Write-Host "  - analyze:   .\run.ps1 analyze"
Write-Host "  - tests:     flutter test"
