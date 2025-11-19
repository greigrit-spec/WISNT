$BatUrl = "https://raw.githubusercontent.com/greigrit-spec/WISNT/main/WISNT.bat"
$TempPath = Join-Path $env:TEMP "w.bat"
$Content = irm -Uri $BatUrl
$UTF8NoBOM = New-Object System.Text.UTF8Encoding($False)
[System.IO.File]::WriteAllText($TempPath, $Content, $UTF8NoBOM)
Start-Process -FilePath cmd -ArgumentList "/k chcp 65001 & $TempPath & exit" -Wait
