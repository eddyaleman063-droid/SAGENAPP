$files = @('lib\l10n\app_en.arb','lib\l10n\app_es.arb','lib\l10n\app_fr.arb','lib\l10n\app_pt.arb')
foreach ($f in $files) {
    $json = Get-Content $f -Raw | ConvertFrom-Json
    $count = ($json.PSObject.Properties | Where-Object { $_.Name -notlike '@@*' -and $_.Name -notlike '@*' }).Count
    Write-Host "$f : $count keys"
}
