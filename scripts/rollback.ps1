#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Rollback script for SAGEN app deployments.

.DESCRIPTION
    Provides rollback capabilities for Android builds.
    Can revert to a previous version on Firebase App Distribution or Google Play.

.PARAMETER Target
    Rollback target: 'staging' (Firebase App Distribution) or 'production' (Google Play).

.PARAMETER Version
    The version to rollback to (e.g., '5.1.0+7').

.PARAMETER DryRun
    If specified, shows what would be done without making changes.
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('staging', 'production')]
    [string]$Target,

    [Parameter(Mandatory=$true)]
    [string]$Version,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$buildDir = "build/releases"

Write-Host "=== SAGEN Rollback Script ===" -ForegroundColor Cyan
Write-Host "Target:  $Target"
Write-Host "Version: $Version"
Write-Host "DryRun:  $DryRun"
Write-Host ""

# Find the artifact for the target version
$artifactDir = Join-Path $buildDir "appbundle-v$Version"
if (-not (Test-Path $artifactDir)) {
    Write-Host "ERROR: No artifact found for version $Version at $artifactDir" -ForegroundColor Red
    Write-Host "Available artifacts:" -ForegroundColor Yellow
    Get-ChildItem $buildDir -Directory -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "  - $($_.Name)" }
    exit 1
}

$aabFile = Get-ChildItem $artifactDir -Filter "*.aab" | Select-Object -First 1
if (-not $aabFile) {
    Write-Host "ERROR: No .aab file found in $artifactDir" -ForegroundColor Red
    exit 1
}

Write-Host "Found artifact: $($aabFile.Name)" -ForegroundColor Green

if ($Target -eq "staging") {
    Write-Host ""
    Write-Host "Rolling back STAGING (Firebase App Distribution)..." -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would upload $($aabFile.Name) to Firebase App Distribution" -ForegroundColor Gray
    } else {
        # Firebase App Distribution uses the Firebase CLI
        $appId = $env:FIREBASE_ANDROID_APP_ID
        if (-not $appId) {
            Write-Host "ERROR: FIREBASE_ANDROID_APP_ID environment variable not set" -ForegroundColor Red
            exit 1
        }

        Write-Host "Uploading to Firebase App Distribution..."
        & firebase appdistribution:distribute $aabFile.FullName --app $appId --groups internal-testers 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Firebase App Distribution upload failed" -ForegroundColor Red
            exit 1
        }
        Write-Host "Rollback to $Version completed for staging" -ForegroundColor Green
    }
} elseif ($Target -eq "production") {
    Write-Host ""
    Write-Host "Rolling back PRODUCTION (Google Play)..." -ForegroundColor Yellow
    Write-Host "NOTE: Google Play does not support direct rollback via CLI." -ForegroundColor Yellow
    Write-Host "Please use the Google Play Console to:" -ForegroundColor Yellow
    Write-Host "  1. Go to Release > Production" -ForegroundColor Yellow
    Write-Host "  2. Find the release with version $Version" -ForegroundColor Yellow
    Write-Host "  3. Click 'Promote to production' or 'Rollback'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Alternatively, build and upload the previous version:" -ForegroundColor Yellow

    if ($DryRun) {
        Write-Host "[DRY RUN] Would build and upload version $Version" -ForegroundColor Gray
    } else {
        Write-Host "Building version $Version..."
        & pwsh ./build.ps1 -Type appbundle -Version $Version -BuildNumber ($Version.Split('+')[1] ?? "1")
        if ($LASTEXITCODE -ne 0) {
            Write-Host "ERROR: Build failed" -ForegroundColor Red
            exit 1
        }
        Write-Host "Build complete. Please upload manually via Google Play Console." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "=== Rollback Complete ===" -ForegroundColor Cyan
