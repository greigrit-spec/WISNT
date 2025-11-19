# ВНИМАНИЕ: Этот способ может работать нестабильно.
# Загрузка остается прежней
$BatUrl = "https://raw.githubusercontent.com/greigrit-spec/WISNT/main/WISNT.bat"
$TempPath = Join-Path $env:TEMP "w_$(Get-Date -Format 'yyyyMMdd_HHmmss').bat"
$UTF8NoBOM = New-Object System.Text.UTF8Encoding($False)

try {
    $webClient = New-Object System.Net.WebClient
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $Content = $webClient.DownloadString($BatUrl)
    [System.IO.File]::WriteAllText($TempPath, $Content, $UTF8NoBOM)
    Write-Host "WISNT.bat успешно загружен в $TempPath" -ForegroundColor Green
} catch {
    Write-Host "Ошибка загрузки WISNT.bat: $($_.Exception.Message)" -ForegroundColor Red
    return
}

# Запуск через PowerShell с указанием кодировки
# ВАЖНО: Это может вызвать проблемы с выполнением .bat команд
Start-Process -FilePath powershell.exe -ArgumentList "-NoExit", "-Command", "chcp 65001; cmd /k `"$TempPath`""
Write-Host "Процесс PowerShell с cmd.exe и WISNT.bat запущен." -ForegroundColor Yellow
Write-Host "Для очистки после использования удалите файл: $TempPath" -ForegroundColor Gray
