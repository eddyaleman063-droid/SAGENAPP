$j = Get-Content 'C:\dev\SAGENAPP\assets\content\stages.json' -Raw | ConvertFrom-Json
$total = 0
foreach ($stage in $j) {
  Write-Host "Stage: $($stage.id) - $($stage.title)"
  $stageTotal = 0
  foreach ($ses in $stage.sessions) {
    foreach ($l in $ses.lessons) {
      $stageTotal += $l.questionCount
    }
  }
  Write-Host "  Total questions needed: $stageTotal"
  $total += $stageTotal
}
Write-Host "Grand total: $total"
