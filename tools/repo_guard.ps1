# repo_guard.ps1
# Guards the SAGEN repo against concurrent-edit corruption and provides
# corruption detection plus rollback snapshots.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 check
#   powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 lock
#   powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 unlock
#   powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 snapshot
#   powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 status
#
# Exit codes: 0 = ok, 1 = problem found.

param([Parameter(Position = 0)][string]$Command = 'help')

$RepoRoot = Split-Path -Parent $PSScriptRoot
$LockFile = Join-Path $RepoRoot '.sagen-session.lock'
$BackupDir = Join-Path $RepoRoot 'backups'
$LockMaxAgeMinutes = 120

function Write-Ok($msg) { Write-Output "[OK]   $msg" }
function Write-Warn($msg) { Write-Output "[WARN] $msg" }
function Write-Err($msg) { Write-Output "[ERROR] $msg" }

function Get-CurrentUser {
  $started = [datetime]::MinValue
  if ($null -ne $lockObj -and $null -ne $lockObj.started -and $lockObj.started -is [string]) {
    [datetime]::TryParse($lockObj.started, [ref]$started) | Out-Null
  }
  if ($started -eq [datetime]::MinValue) { return 0 }
  return ((Get-Date) - $started).TotalMinutes
}

function Read-Lock {
  if (-not (Test-Path $LockFile)) { return $null }
  try {
    $raw = Get-Content -Raw -LiteralPath $LockFile
    return $raw | ConvertFrom-Json
  } catch {
    return $null
  }
}

function Write-Lock($lockObj) {
  $json = $lockObj | ConvertTo-Json -Compress
  [System.IO.File]::WriteAllText($LockFile, $json, [System.Text.Encoding]::UTF8)
}

function Test-CorruptionPattern {
  $bad = @()
  $patterns = @(
    '^: [0-9]+: ',
    '^[0-9]+: [0-9]+: ',
    '^[0-9]+: ',
    ':[0-9]+: '
  )
  $dirs = @((Join-Path $RepoRoot 'lib'), (Join-Path $RepoRoot 'test'))
  foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { continue }
    Get-ChildItem $dir -Recurse -Filter *.dart | ForEach-Object {
      $f = $_.FullName
      foreach ($p in $patterns) {
        $m = Select-String -Path $f -Pattern $p -ErrorAction SilentlyContinue
        if ($m) { $bad += ($f + ':' + $m.LineNumber); break }
      }
    }
  }
  return $bad
}

function Get-LockAgeMinutes($lockObj) {
  $started = [datetime]::MinValue
  if ($null -ne $lockObj -and $null -ne $lockObj.started -and $lockObj.started -is [string]) {
    [datetime]::TryParse($lockObj.started, [ref]$started) | Out-Null
  }
  if ($started -eq [datetime]::MinValue) { return 0 }
  return ((Get-Date) - $started).TotalMinutes
}

function Get-CurrentUser {
  return [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
}

function Get-LockStale($lockObj) {
  if ($null -eq $lockObj) { return $true }
  $age = Get-LockAgeMinutes $lockObj
  return $age -gt $LockMaxAgeMinutes
}

function Invoke-Check {
  Write-Output "Repo guard check on $RepoRoot"
  $bad = Test-CorruptionPattern
  if ($bad.Count -gt 0) {
    foreach ($b in ($bad | Select-Object -First 20)) { Write-Err "Corruption pattern in $b" }
    Write-Err "Found $($bad.Count) corrupted line(s). Restore from the latest snapshot:"
    Write-Err "  powershell -ExecutionPolicy Bypass -File tools/repo_guard.ps1 list"
    $script:guardExit = 1
    return
  }
  $lock = Read-Lock
  if ($null -ne $lock) {
    $age = Get-LockAgeMinutes $lock
    $stale = Get-LockStale $lock
    $state = if ($stale) { 'STALE' } else { 'ACTIVE' }
    Write-Warn "Session lock ${state}: pid=$($lock.pid) user=$($lock.user) host=$($lock.host) started=$($lock.started) age=$([math]::Round($age,1))min"
  } else {
    Write-Ok 'No session lock present'
  }
  Write-Ok 'No corruption patterns found'
}

function Invoke-Lock {
  $lock = Read-Lock
  if ($null -ne $lock -and -not (Get-LockStale $lock)) {
    $age = Get-LockAgeMinutes $lock
    Write-Err "Another session holds the lock (user=$($lock.user) started=$($lock.started), age=$([math]::Round($age,1))min)."
    Write-Err "Wait until it is released or goes stale ($LockMaxAgeMinutes min), then run 'lock' again."
    $script:guardExit = 1
    return
  }
  if ($null -ne $lock) {
    Write-Warn "Taking over stale lock from user=$($lock.user) started=$($lock.started)"
  }
  $now = Get-Date -Format 'yyyy-MM-ddTHH:mm:sszzz'
  $me = Get-CurrentUser
  $lockObj = [pscustomobject]@{
    pid = $PID
    user = $me
    host = $env:COMPUTERNAME
    started = $now
    tool = 'repo_guard.ps1'
  }
  Write-Lock $lockObj
  Write-Ok "Lock acquired: user=$($me) started=$($now)"
}

function Invoke-Unlock {
  $lock = Read-Lock
  if ($null -eq $lock) {
    Write-Ok 'No lock to release'
    return
  }
  $me = Get-CurrentUser
  if ($lock.user -ne $me) {
    Write-Warn "Lock is owned by another user ($($lock.user)); you are $me. Use -Force to override."
    if ($Force) { Remove-Item -LiteralPath $LockFile -Force; Write-Ok 'Lock removed (forced)'; return }
    $script:guardExit = 1
    return
  }
  Remove-Item -LiteralPath $LockFile -Force
  Write-Ok 'Lock released'
}

function Invoke-Snapshot {
  if (-not (Test-Path $BackupDir)) { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
  $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
  $dest = Join-Path $BackupDir "snapshot-$stamp.zip"
  $items = @(
    (Join-Path $RepoRoot 'lib'),
    (Join-Path $RepoRoot 'test'),
    (Join-Path $RepoRoot 'pubspec.yaml'),
    (Join-Path $RepoRoot 'pubspec.lock'),
    (Join-Path $RepoRoot 'analysis_options.yaml'),
    (Join-Path $RepoRoot 'AGENTS.md')
  ) | Where-Object { Test-Path $_ }
  if ($items.Count -eq 0) { Write-Err 'Nothing to snapshot'; $script:guardExit = 1; return }
  Compress-Archive -Path $items -DestinationPath $dest -CompressionLevel Optimal -Force
  Write-Ok "Snapshot created: $dest"
  $old = Get-ChildItem $BackupDir -Filter 'snapshot-*.zip' | Sort-Object Name -Descending | Select-Object -Skip 5
  foreach ($o in $old) { Remove-Item -LiteralPath $o.FullName -Force; Write-Warn "Pruned old snapshot: $($o.Name)" }
}

function Invoke-List {
  if (-not (Test-Path $BackupDir)) { Write-Ok 'No snapshots yet'; return }
  $snaps = Get-ChildItem $BackupDir -Filter 'snapshot-*.zip' | Sort-Object Name -Descending
  if ($snaps.Count -eq 0) { Write-Ok 'No snapshots yet'; return }
  $i = 1
  foreach ($s in $snaps) {
    Write-Output ("{0}. {1} ({2:N0} bytes)" -f $i, $s.Name, $s.Length)
    $i++
  }
  Write-Ok 'Restore: unzip the newest snapshot over the repo root.'
}

function Invoke-Status {
  $lock = Read-Lock
  if ($null -eq $lock) {
    Write-Ok 'No session lock'
  } else {
    $age = Get-LockAgeMinutes $lock
    $stale = Get-LockStale $lock
    $state = if ($stale) { 'STALE' } else { 'ACTIVE' }
    Write-Output "Lock: user=$($lock.user) host=$($lock.host) started=$($lock.started) age=$([math]::Round($age,1))min ${state}"
  }
  $bad = Test-CorruptionPattern
  Write-Output "Corruption patterns: $($bad.Count)"
}

$script:guardExit = 0

switch ($Command.ToLower()) {
  'check' { Invoke-Check }
  'lock' { Invoke-Lock }
  'unlock' { Invoke-Unlock }
  'snapshot' { Invoke-Snapshot }
  'list' { Invoke-List }
  'status' { Invoke-Status }
  'help' {
    Write-Output 'repo_guard.ps1 - prevent & detect concurrent-edit corruption'
    Write-Output 'Commands: check | lock | unlock | snapshot | list | status | help'
  }
  default {
    Write-Err "Unknown command: $Command"
    $script:guardExit = 2
  }
}
exit $script:guardExit
