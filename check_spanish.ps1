Get-ChildItem -Path 'lib' -Filter '*.dart' -Recurse | Where-Object {
    $_.FullName -notmatch 'app_es\.arb|app_localizations_es\.dart|local_fallback_service\.dart|motivational_quotes_service\.dart|privacy_policy_screen\.dart|sage_personality_profile\.dart|app_localizations\.dart'
} | ForEach-Object {
    $file = $_.FullName
    $lineNum = 0
    Get-Content $file | ForEach-Object {
        $lineNum++
        if ($_ -match '[áéíóúñ¿¡]') {
            if ($_ -notmatch '^\s*//' -and $_ -notmatch '^\s*/\*' -and $_ -notmatch 'log\.' -and $_ -notmatch 'logger\.' -and $_ -notmatch 'AppLogger') {
                Write-Host "${file}:${lineNum}: $_"
            }
        }
    }
}
