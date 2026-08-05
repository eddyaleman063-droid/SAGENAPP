#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Firestore backup script for SAGEN app.

.DESCRIPTION
    Exports Firestore data to Google Cloud Storage for backup purposes.
    Requires Firebase CLI and gcloud CLI authenticated.

.PARAMETER ProjectId
    Firebase project ID. Defaults to 'sagen-bdd3f'.

.PARAMETER OutputBucket
    GCS bucket for backups. Defaults to 'sagen-backups'.

.PARAMETER DryRun
    If specified, shows what would be done without making changes.
#>

param(
    [string]$ProjectId = "sagen-bdd3f",
    [string]$OutputBucket = "sagen-backups",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$exportPath = "gs://$OutputBucket/$date"

Write-Host "=== SAGEN Firestore Backup ===" -ForegroundColor Cyan
Write-Host "Project: $ProjectId"
Write-Host "Bucket:  $OutputBucket"
Write-Host "Path:    $exportPath"
Write-Host ""

# Check prerequisites
$gcloud = Get-Command gcloud -ErrorAction SilentlyContinue
if (-not $gcloud) {
    Write-Host "ERROR: gcloud CLI not found. Install from https://cloud.google.com/sdk/docs/install" -ForegroundColor Red
    exit 1
}

$firebase = Get-Command firebase -ErrorAction SilentlyContinue
if (-not $firebase) {
    Write-Host "ERROR: Firebase CLI not found. Install via: npm install -g firebase-tools" -ForegroundColor Red
    exit 1
}

if ($DryRun) {
    Write-Host "[DRY RUN] Would export Firestore to $exportPath" -ForegroundColor Gray
    Write-Host "[DRY RUN] Collections to export:" -ForegroundColor Gray
    Write-Host "  - users" -ForegroundColor Gray
    Write-Host "  - questions" -ForegroundColor Gray
    Write-Host "  - achievements" -ForegroundColor Gray
    Write-Host "  - payments" -ForegroundColor Gray
    exit 0
}

# Create bucket if it doesn't exist
Write-Host "Ensuring backup bucket exists..."
& gsutil mb -p $ProjectId -l us-central1 "gs://$OutputBucket" 2>&1 | Out-Null

# Export Firestore
Write-Host "Exporting Firestore data..."
& gcloud firestore export $exportPath --project=$ProjectId --collection-group=users 2>&1
& gcloud firestore export $exportPath --project=$ProjectId --collection-group=questions 2>&1
& gcloud firestore export $exportPath --project=$ProjectId --collection-group=payments 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Firestore export failed" -ForegroundColor Red
    exit 1
}

# Set lifecycle rule to auto-delete after 30 days
Write-Host "Setting 30-day retention policy..."
& gsutil lifecycle set '{"rule":[{"action":{"type":"Delete"],"age":30}]}' "gs://$OutputBucket" 2>&1 | Out-Null

Write-Host ""
Write-Host "=== Backup Complete ===" -ForegroundColor Green
Write-Host "Exported to: $exportPath" -ForegroundColor Green
Write-Host "Retention: 30 days" -ForegroundColor Yellow
