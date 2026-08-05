$files = @('lib\l10n\app_en.arb','lib\l10n\app_es.arb','lib\l10n\app_fr.arb','lib\l10n\app_pt.arb')
foreach ($f in $files) {
    $json = Get-Content $f -Raw | ConvertFrom-Json
    $keys = ($json.PSObject.Properties | Where-Object { $_.Name -notlike '@@*' -and $_.Name -notlike '@*' }).Name
    $groups = $keys | Group-Object | Where-Object { $_.Count -gt 1 }
    if ($groups) {
        Write-Host "DUPLICATE in $f"
        $groups | ForEach-Object { Write-Host "  $($_.Name) x$($_.Count)" }
    } else {
        Write-Host "$f : no duplicates"
    }
}
