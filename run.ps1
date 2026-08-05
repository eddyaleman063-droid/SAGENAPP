<#
.SYNOPSIS
  SAGEN — Build & Run Script
.DESCRIPTION
  Professional CLI for running, building, and maintaining SAGEN.
  Reads .env automatically and passes --dart-define to Flutter.
.PARAMETER Action
  run       -> flutter run (default)
  release   -> flutter run --release
  apk       -> flutter build apk (add --release for release APK)
  analyze   -> flutter analyze
  clean     -> flutter clean + pub get
  log       -> shows changelog from kUpdateLog
  version   -> shows version info
.PARAMETER ExtraArgs
  Additional arguments passed directly to Flutter (e.g. --release, -d device_id)
.EXAMPLE
  .\run.ps1
  .\run.ps1 apk --release
  .\run.ps1 run -d emulator-5554
  .\run.ps1 analyze
#>

param(
  [string]$Action = 'run',
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]]$ExtraArgs
)

# ──────────────────────────── Configuration ────────────────────────────

$PROJECT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$ENV_FILE     = Join-Path $PROJECT_ROOT '.env'
$PUBSPEC_FILE = Join-Path $PROJECT_ROOT 'pubspec.yaml'
$APP_CONFIG   = Join-Path $PROJECT_ROOT 'lib\config\app_config.dart'
$CHANGE_LOG   = Join-Path $PROJECT_ROOT 'lib\models\update_log.dart'

# ──────────────────────────── Color helpers ────────────────────────────

$ESC = [char]27
$C_RESET = "${ESC}[0m"
$C_BOLD  = "${ESC}[1m"
$C_DIM   = "${ESC}[2m"
$C_GREEN = "${ESC}[38;5;40m"
$C_CYAN  = "${ESC}[38;5;39m"
$C_YLW   = "${ESC}[38;5;220m"
$C_RED   = "${ESC}[38;5;196m"
$C_MGNT  = "${ESC}[38;5;135m"
$C_GRY   = "${ESC}[38;5;245m"
$C_BLU   = "${ESC}[38;5;33m"

function Write-Info($msg)  { Write-Host "${C_CYAN}◆${C_RESET} $msg" }
function Write-Ok($msg)    { Write-Host "${C_GREEN}✔${C_RESET} $msg" }
function Write-Warn($msg)  { Write-Host "${C_YLW}⚠${C_RESET} $msg" }
function Write-Error($msg) { Write-Host "${C_RED}✘${C_RESET} $msg" }
function Write-Step($msg)  { Write-Host "${C_BOLD}${C_BLU}┃${C_RESET} ${C_BOLD}$msg${C_RESET}" }
function Write-Line()      { Write-Host "${C_DIM}────────────────────────────────────────────${C_RESET}" }

# ──────────────────────────── Banner ────────────────────────────

function Show-Banner {
  Write-Host @"

${C_BOLD}${C_BLU}  ███████  █████   █████  ███████     ███████  █████  ██
  ██      ██   ██ ██   ██ ██          ██      ██   ██ ██
  █████   ███████ ███████ █████       █████   ███████ ██
  ██      ██   ██ ██   ██ ██          ██      ██   ██ ██
  ██      ██   ██ ██   ██ ███████     ██      ██   ██ ███████${C_RESET}
${C_DIM}  SAGEN — Build System${C_RESET}

"@
}

# ──────────────────────────── .env loader ────────────────────────────

function Read-EnvFile {
  if (-not (Test-Path $ENV_FILE)) {
    Write-Warn "No .env file found at $ENV_FILE"
    Write-Info  "Copy .env.example to .env and fill in your API keys"
    return @{}
  }

  $vars = @{}
  Get-Content $ENV_FILE | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith('#')) {
      $match = [regex]::Match($line, '^([A-Z_]+)=(.*)$')
      if ($match.Success) {
        $vars[$match.Groups[1].Value] = $match.Groups[2].Value
      }
    }
  }
  return $vars
}

# ──────────────────────────── Version helpers ────────────────────────────

function Read-PubspecVersion {
  if (-not (Test-Path $PUBSPEC_FILE)) { return @{version = '?'; build = '?' } }

  $content = Get-Content $PUBSPEC_FILE -Raw
  $match = [regex]::Match($content, '^version:\s*(\d+\.\d+\.\d+)\+(\d+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
  if ($match.Success) {
    return @{ version = $match.Groups[1].Value; build = $match.Groups[2].Value }
  }
  return @{ version = '?'; build = '?' }
}

function Show-VersionInfo {
  $v = Read-PubspecVersion
  Write-Line
  Write-Info "${C_BOLD}App:${C_RESET}    SAGEN"
  Write-Info "${C_BOLD}Version:${C_RESET} $($v.version)+$($v.build)"
  Write-Info "${C_BOLD}Flutter:${C_RESET} $(flutter --version 2>$null | Select-String 'Flutter' | ForEach-Object { $_.ToString().Split(' ')[1] })"
  Write-Line
}

# ──────────────────────────── Dart-Define builder ────────────────────────────

function Build-DartDefines {
  $envVars = Read-EnvFile
  $defines = @()
  $missing = @()

  # Required keys
  $required = @('GEMINI_API_KEY')

  foreach ($key in $required) {
    if ($envVars.ContainsKey($key) -and $envVars[$key]) {
      $defines += "--dart-define=$key=$($envVars[$key])"
    } else {
      $missing += $key
    }
  }

  # Extra keys from .env (not in required list)
  foreach ($kv in $envVars.GetEnumerator()) {
    if ($kv.Key -notin $required -and $kv.Value) {
      $defines += "--dart-define=$($kv.Key)=$($kv.Value)"
    }
  }

  return @{ defines = $defines; missing = $missing }
}

# ──────────────────────────── Command runners ────────────────────────────

function Invoke-Run    { Invoke-Flutter 'run' $args }
function Invoke-Release { Invoke-Flutter 'run' @('--release') + $args }
function Invoke-Apk     { Invoke-Flutter 'build' @('apk') + $args }
function Invoke-Analyze { Invoke-Flutter 'analyze' $args }
function Invoke-Clean   { Invoke-Flutter 'clean'; Invoke-Flutter 'pub' @('get') }

function Invoke-Flutter {
  param([string]$FlutterCmd, [string[]]$FlutterArgs)

  $def = Build-DartDefines
  $allArgs = @($FlutterCmd) + $def.defines + $FlutterArgs

  # Check for missing keys
  if ($def.missing.Count -gt 0) {
    Write-Warn "Missing API keys in .env: $($def.missing -join ', ')"
    Write-Info  "The app may not work correctly without them."
    Write-Line
  }

  Write-Step "flutter $($allArgs -join ' ')"
  Write-Line

  # Run flutter
  $exitCode = 0
  try {
    & flutter $allArgs 2>&1 | ForEach-Object { $_ }
    $exitCode = $LASTEXITCODE
  } catch {
    Write-Error "Flutter command failed: $_"
    $exitCode = 1
  }

  Write-Line
  if ($exitCode -eq 0) {
    Write-Ok "Command completed successfully"
  } else {
    Write-Error "Command failed with exit code $exitCode"
  }

  return $exitCode
}

# ──────────────────────────── Changelog display ────────────────────────────

function Show-Changelog {
  if (-not (Test-Path $CHANGE_LOG)) {
    Write-Host "${C_YLW}${C_RESET} update_log.dart not found"
    return
  }

  Write-Host "${C_BOLD}${C_BLU}|${C_RESET} ${C_BOLD}Changelog${C_RESET}"
  Write-Host "${C_DIM}-------------------------------------------${C_RESET}"

  $content = Get-Content $CHANGE_LOG -Raw
  $pattern = [regex] "version: '([^']+)'[\s\S]*?date: '([^']+)'[\s\S]*?title: '([^']+)'[\s\S]*?badge: UpdateBadge\.(\w+)[\s\S]*?changes: \[([^\]]+)\]"
  $matches = $pattern.Matches($content)

  if ($matches.Count -eq 0) {
    Write-Host "${C_CYAN}${C_RESET} No changelog entries found"
    return
  }

  $entries = @()
  for ($i = 0; $i -lt $matches.Count; $i++) {
    $m = $matches[$i]
    $changesText = $m.Groups[5].Value
    $changes = $changesText -split "',\s*'" | ForEach-Object { $_.Trim().TrimStart("'").TrimEnd("'").Trim() } | Where-Object { $_ }
    $entries += @{
      version = $m.Groups[1].Value
      date    = $m.Groups[2].Value
      title   = $m.Groups[3].Value
      badge   = $m.Groups[4].Value
      changes = $changes
    }
  }

  [array]::Reverse($entries)
  foreach ($e in $entries) {
    $badgeColor = switch ($e.badge) {
      'nuevo'    { $C_GREEN }
      'mejorado' { $C_CYAN }
      'optimizado' { $C_YLW }
      'ia'       { $C_MGNT }
      'seguridad' { $C_RED }
      default    { $C_GRY }
    }
    Write-Host "${C_BOLD}v$($e.version)${C_RESET}  ${C_DIM}$($e.date)${C_RESET}  ${badgeColor}$($e.badge.ToUpper())${C_RESET}"
    Write-Host "  ${C_DIM}$($e.title)${C_RESET}"
    foreach ($c in $e.changes) {
      Write-Host "  ${C_GREEN}*${C_RESET} $c"
    }
    Write-Host ""
  }
}

# ──────────────────────────── Main ────────────────────────────

Show-Banner

switch ($Action.ToLower()) {
  'run'     { Invoke-Run $ExtraArgs }
  'release' { Invoke-Flutter 'run' @('--release') + $ExtraArgs }
  'apk'     { Invoke-Flutter 'build' @('apk') + $ExtraArgs }
  'bundle'  { Invoke-Flutter 'build' @('appbundle') + $ExtraArgs }
  'ios'     { Invoke-Flutter 'build' @('ios') + $ExtraArgs }
  'analyze' { Invoke-Flutter 'analyze' $ExtraArgs }
  'clean'   { Invoke-Clean }
  'log'     { Show-Changelog }
  'version' { Show-VersionInfo }
  default {
    Write-Error "Unknown action: $Action"
    Write-Info  "Available: run, release, apk, bundle, ios, analyze, clean, log, version"
  }
}
