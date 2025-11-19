# Определяем URL для скачивания .bat файла
$BatUrl = "https://raw.githubusercontent.com/greigrit-spec/WISNT/main/WISNT.bat"

# Создаём уникальный путь во временной папке
$TempPath = Join-Path $env:TEMP "w_$(Get-Date -Format 'yyyyMMdd_HHmmss').bat" # Добавим время для уникальности
#$Content = irm -Uri $BatUrl # Закомментировано, используем более надёжный способ
$UTF8NoBOM = New-Object System.Text.UTF8Encoding($False)

try {
    # Используем WebClient для загрузки, чтобы получить более надёжный контроль
    # и избежать проблем с TLS или разметкой в некоторых случаях
    $webClient = New-Object System.Net.WebClient
    # Устанавливаем TLS 1.2, если возможно
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $Content = $webClient.DownloadString($BatUrl)
    [System.IO.File]::WriteAllText($TempPath, $Content, $UTF8NoBOM)
    Write-Host "WISNT.bat успешно загружен в $TempPath" -ForegroundColor Green
} catch {
    Write-Host "Ошибка загрузки WISNT.bat: $($_.Exception.Message)" -ForegroundColor Red
    return # Прерываем выполнение скрипта в случае ошибки
}

# Подготовим команду для cmd.exe: сначала установить кодировку, затем запустить .bat файл
# /k означает выполнить команды и оставить окно открытым
# chcp 65001 устанавливает кодировку UTF-8 для этой сессии cmd
# & - оператор последовательного выполнения команд в cmd
# Используем двойные кавычки для всего аргумента, чтобы он правильно интерпретировался как одна строка команд
$cmdArgs = "/k chcp 65001 & `"$TempPath`""

# Запускаем cmd.exe с подготовленной командой БЕЗ -Wait и БЕЗ & exit сразу после .bat
# Это позволяет .bat файлу работать независимо от PowerShell-сеанса iex
Start-Process -FilePath cmd.exe -ArgumentList $cmdArgs
Write-Host "Процесс cmd.exe с WISNT.bat запущен. PowerShell-сеанс может завершиться, .bat будет работать отдельно." -ForegroundColor Yellow
Write-Host "Для очистки после использования удалите файл: $TempPath" -ForegroundColor Gray
