<#
.SYNOPSIS
  SAGEN - Release Build Script
.DESCRIPTION
  Production-grade build script for generating release APK/AAB.
  Reads .env, signs with keystore if available, and outputs to build/releases/.
.PARAMETER Type
  apk     -> Android APK (default)
  appbundle -> Android App Bundle (AAB)
.PARAMETER Version
  Override version name (e.g. 1.1.0). Defaults to pubspec.yaml.
.PARAMETER BuildNumber
  Override build number. Defaults to pubspec.yaml.
.PARAMETER SkipTests
  Skip flutter analyze before building.
.PARAMETER OutputDir
  Custom output directory (default: build/releases/).
.EXAMPLE
  .\build.ps1 appbundle -Version 5.0.0 -BuildNumber 6
  .\build.ps1 apk -SkipTests
#>

param(
  [ValidateSet('apk', 'appbundle')]
  [string]$Type = 'apk',
  [string]$Version = '',
  [string]$BuildNumber = '',
  [switch]$SkipTests,
  [string]$OutputDir = ''
)

$ESC = [char]27

# Colors
$C_RESET = "$ESC[0m"
$C_BOLD  = "$ESC[1m"
$C_GREEN = "$ESC[38;5;40m"
$C_CYAN  = "$ESC[38;5;39m"
$C_YLW   = "$ESC[38;5;220m"
$C_RED   = "$ESC[38;5;196m"
$C_BLU   = "$ESC[38;5;33m"
$C_DIM   = "$ESC[38;5;245m"

function Write-Info($m)  { Write-Host "${C_CYAN}<>${C_RESET} $m" }
function Write-Ok($m)    { Write-Host "${C_GREEN}OK${C_RESET} $m" }
function Write-Warn($m)  { Write-Host "${C_YLW}!!${C_RESET} $m" }
function Write-Error($m) { Write-Host "${C_RED}XX${C_RESET} $m" }
function Write-Step($m)  { Write-Host "${C_BOLD}${C_BLU}|>${C_RESET} ${C_BOLD}$m${C_RESET}" }
function Write-Line()    { Write-Host "${C_DIM}-------------------------------------------${C_RESET}" }

$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$ENV_FILE     = Join-Path $PROJECT_ROOT '.env'
$PUBSPEC_FILE = Join-Path $PROJECT_ROOT 'pubspec.yaml'

# ------------ Read version from pubspec ------------

if (-not (Test-Path $PUBSPEC_FILE)) {
  Write-Error "pubspec.yaml not found"
  exit 1
}

$pubspec = Get-Content $PUBSPEC_FILE -Raw
$vMatch = [regex]::Match($pubspec, '^version:\s*(\d+\.\d+\.\d+)\+(\d+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)

if ((-not $Version) -or $Version.StartsWith('--') -or $Version.StartsWith('-'))  { $Version = if ($vMatch.Success) { $vMatch.Groups[1].Value } else { '1.0.0' } }
if ((-not $BuildNumber) -or $BuildNumber.StartsWith('--') -or $BuildNumber.StartsWith('-')) { $BuildNumber = if ($vMatch.Success) { $vMatch.Groups[2].Value } else { '1' } }

# ------------ Banner ------------

Write-Host @"
${C_BOLD}${C_BLU}
  SAGEN - Release Builder (STAGING v5)
${C_RESET}${C_DIM}  Version $Version${C_RESET}

"@

Write-Info "${C_BOLD}Version:${C_RESET}     $Version+$BuildNumber"
Write-Info "${C_BOLD}Build Type:${C_RESET}  $Type"
Write-Line

# ------------ Step 1: Analyze ------------

if (-not $SkipTests) {
  Write-Step "1/4 - Static analysis"
  flutter analyze --no-fatal-infos 2>&1 | ForEach-Object { $_ }
  if ($LASTEXITCODE -ne 0) {
    Write-Error "Analysis failed. Fix issues before building. Use --SkipTests to bypass."
    exit 1
  }
  Write-Ok "Analysis passed"
  Write-Line
} else {
  Write-Warn "Skipping static analysis"
}

# ------------ Step 2: Read .env ------------

Write-Step "2/4 - Loading environment"

if (-not (Test-Path $ENV_FILE)) {
  Write-Warn "No .env file found. Build may lack API keys."
  $envVars = @{}
} else {
  $envVars = @{}
  Get-Content $ENV_FILE | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#')) {
      $match = [regex]::Match($line, '^([A-Z_]+)=(.*)$')
      if ($match.Success) { $envVars[$match.Groups[1].Value] = $match.Groups[2].Value }
    }
  }
  Write-Ok "Loaded $($envVars.Count) variables from .env"
}

# Build --dart-define args
$dartDefines = @()
$missing = @()
foreach ($key in @('GEMINI_API_KEY')) {
  if ($envVars.ContainsKey($key) -and $envVars[$key]) {
    $dartDefines += "--dart-define=$key=$($envVars[$key])"
  } else {
    $missing += $key
  }
}

# Pass version info so app_config.dart can read it if needed
$dartDefines += "--dart-define=APP_VERSION=$Version"
$dartDefines += "--dart-define=APP_BUILD=$BuildNumber"

if ($missing.Count -gt 0) {
  Write-Warn "Missing: $($missing -join ', ')"
}
Write-Line

# ------------ Step 3: Clean ------------

Write-Step "3/4 - Cleaning previous build"
if (Test-Path "build") { Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue }
flutter clean 2>&1 | Out-Null
flutter pub get 2>&1 | Out-Null
Write-Ok "Clean complete"
Write-Line

# ------------ Step 4: Build ------------

$buildArgs = @('build', $Type, '--release', '--obfuscate', '--split-debug-info=build/app/outputs/symbols')
if ($Type -eq 'apk') {
  $buildArgs += '--split-per-abi'
}
$buildArgs += $dartDefines

if (-not $OutputDir) {
  $OutputDir = Join-Path $PROJECT_ROOT "build\releases\$Type-v$Version+$BuildNumber"
}

Write-Step "4/4 - Building $Type (release)"
Write-Info "flutter $($buildArgs -join ' ')"
Write-Line

try {
  & flutter $buildArgs 2>&1 | ForEach-Object { $_ }
  if ($LASTEXITCODE -ne 0) { throw "Build failed" }
} catch {
  Write-Error "Build failed: $_"
  exit 1
}

# Copy artifact to output directory
if (-not (Test-Path $OutputDir)) { New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null }
if ($Type -eq 'apk') {
  # Universal APK (fat)
  $srcFat = Join-Path $PROJECT_ROOT "build\app\outputs\flutter-apk\app-release.apk"
  if (Test-Path $srcFat) {
    $dstFat = Join-Path $OutputDir "SAGEN-v$Version+$BuildNumber-Universal.apk"
    Copy-Item $srcFat $dstFat
  }
  # Splitted APKs (if built with --split-per-abi)
  $srcArm64 = Join-Path $PROJECT_ROOT "build\app\outputs\flutter-apk\app-arm64-v8a-release.apk"
  if (Test-Path $srcArm64) {
    $dstArm64 = Join-Path $OutputDir "SAGEN-v$Version+$BuildNumber-arm64.apk"
    Copy-Item $srcArm64 $dstArm64
  }
} elseif ($Type -eq 'appbundle') {
  $src = Join-Path $PROJECT_ROOT "build\app\outputs\bundle\release\app-release.aab"
  $dst = Join-Path $OutputDir "SAGEN-v$Version+$BuildNumber.aab"
  Copy-Item $src $dst
}

Write-Line
Write-Ok "${C_BOLD}Build complete!${C_RESET}"
Write-Info "Output: ${C_CYAN}$OutputDir${C_RESET}"
Write-Line
