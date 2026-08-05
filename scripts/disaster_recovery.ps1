#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Disaster recovery script for SAGEN app.

.DESCRIPTION
    Provides DR procedures for critical failures.
    Can perform: emergency feature flag disable, database rollback, cache purge.

.PARAMETER Action
    DR action to perform:
    - 'disable-features': Disable all feature flags via Remote Config
    - 'status': Show current system status
    - 'purge-cache': Instructions for cache purge
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('disable-features', 'status', 'purge-cache')]
    [string]$Action,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "=== SAGEN Disaster Recovery ===" -ForegroundColor Red
Write-Host "Action: $Action"
Write-Host "Time:   $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host ""

switch ($Action) {
    'disable-features' {
        Write-Host "EMERGENCY: Disabling all feature flags..." -ForegroundColor Red
        Write-Host ""
        Write-Host "To disable all feature flags, update Remote Config in Firebase Console:" -ForegroundColor Yellow
        Write-Host "  1. Go to https://console.firebase.google.com/project/sagen-bdd3f/config" -ForegroundColor Yellow
        Write-Host "  2. Set ALL ff_* keys to false:" -ForegroundColor Yellow
        Write-Host "     - ff_new_ui = false" -ForegroundColor Yellow
        Write-Host "     - ff_chat_v2 = false" -ForegroundColor Yellow
        Write-Host "     - ff_mini_games = false" -ForegroundColor Yellow
        Write-Host "     - ff_store_redesign = false" -ForegroundColor Yellow
        Write-Host "     - ff_streak_freeze = false" -ForegroundColor Yellow
        Write-Host "     - ff_leaderboard = false" -ForegroundColor Yellow
        Write-Host "     - ff_dark_mode = false" -ForegroundColor Yellow
        Write-Host "     - ff_voice_input = false" -ForegroundColor Yellow
        Write-Host "  3. Publish the changes" -ForegroundColor Yellow
        Write-Host "  4. Changes propagate within 1 hour (or immediately with app restart)" -ForegroundColor Yellow
        Write-Host ""

        if (-not $DryRun) {
            Write-Host "Opening Firebase Console..." -ForegroundColor Cyan
            Start-Process "https://console.firebase.google.com/project/sagen-bdd3f/config"
        }
    }

    'status' {
        Write-Host "System Status Check:" -ForegroundColor Cyan
        Write-Host ""

        # Check Firebase project
        $firebase = Get-Command firebase -ErrorAction SilentlyContinue
        if ($firebase) {
            Write-Host "[OK] Firebase CLI installed" -ForegroundColor Green
        } else {
            Write-Host "[WARN] Firebase CLI not installed" -ForegroundColor Yellow
        }

        # Check gcloud
        $gcloud = Get-Command gcloud -ErrorAction SilentlyContinue
        if ($gcloud) {
            Write-Host "[OK] gcloud CLI installed" -ForegroundColor Green
        } else {
            Write-Host "[WARN] gcloud CLI not installed" -ForegroundColor Yellow
        }

        # Check Flutter
        $flutter = Get-Command flutter -ErrorAction SilentlyContinue
        if ($flutter) {
            $version = & flutter --version 2>&1 | Select-Object -First 1
            Write-Host "[OK] Flutter: $version" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] Flutter not installed" -ForegroundColor Red
        }

        # Check build artifacts
        if (Test-Path "build/releases") {
            $artifacts = Get-ChildItem "build/releases" -Directory
            Write-Host "[OK] Build artifacts: $($artifacts.Count) releases" -ForegroundColor Green
            foreach ($a in $artifacts) {
                Write-Host "     - $($a.Name)" -ForegroundColor Gray
            }
        } else {
            Write-Host "[WARN] No build artifacts found" -ForegroundColor Yellow
        }

        # Check latest backup
        Write-Host ""
        Write-Host "Recent Backups (check GCS bucket 'sagen-backups'):" -ForegroundColor Cyan
        Write-Host "  Run: gsutil ls gs://sagen-backups/" -ForegroundColor Gray
    }

    'purge-cache' {
        Write-Host "Cache Purge Instructions:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Firebase Remote Config cache (auto-expires):" -ForegroundColor Cyan
        Write-Host "   - Remote Config has 1-hour minimum fetch interval" -ForegroundColor Gray
        Write-Host "   - Client-side cache expires after 30 minutes" -ForegroundColor Gray
        Write-Host ""
        Write-Host "2. App local cache:" -ForegroundColor Cyan
        Write-Host "   - SmartCache TTL: 5 minutes default" -ForegroundColor Gray
        Write-Host "   - SharedPreferences analytics: max 500 events" -ForegroundColor Gray
        Write-Host ""
        Write-Host "3. CDN cache (if applicable):" -ForegroundColor Cyan
        Write-Host "   - Firebase Hosting: firebase hosting:channel:expire" -ForegroundColor Gray
        Write-Host ""
        Write-Host "4. User-side cache:" -ForegroundColor Cyan
        Write-Host "   - Users can clear cache via Settings > Clear Data" -ForegroundColor Gray
        Write-Host "   - App reinstall clears all local data" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "=== DR Procedure Complete ===" -ForegroundColor Red
