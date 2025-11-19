# Определяем URL для скачивания .bat файла
$BatUrl = "https://raw.githubusercontent.com/greigrit-spec/WISNT/main/WISNT.bat"

# Создаём уникальный путь во временной папке
$TempPath = Join-Path $env:TEMP "w_$(Get-Date -Format 'yyyyMMdd_HHmmss').bat" # Добавим время для уникальности
$UTF8NoBOM = New-Object System.Text.UTF8Encoding($False)

try {
    # Используем WebClient для загрузки
    $webClient = New-Object System.Net.WebClient
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    $Content = $webClient.DownloadString($BatUrl)
    Write-Host "WISNT.bat успешно загружен." -ForegroundColor Green

    # --- Обработка содержимого ---
    # Разбиваем на строки
    $lines = $Content -split "`r?`n"

    # Определяем строки, которые нужно удалить (ANSI escape sequences и установка цветов)
    # Это строки, которые содержат %ESC%[ или прямой код ANSI (вроде [91m, [92m и т.д.)
    # И строки, устанавливающие переменные цвета (cRed, cGreen, cYellow и т.д.)
    $filteredLines = foreach ($line in $lines) {
        # Проверяем, содержит ли строка установку переменной цвета или ANSI код
        if ($line -match '%ESC%\[' -or
            $line -match 'set "c[A-Z][a-z]*=%ESC%.*"' -or # set "cRed=...", set "cGreen=..." и т.д.
            $line -match 'set "cReset=%ESC%.*"' -or
            $line -match 'set "cGray=%ESC%.*"' -or
            $line -match 'for /F.*prompt #\$H#\$E#' # Строка, создающая %ESC%
        ) {
            # Пропускаем (не добавляем) эту строку
            continue
        }
        # Добавляем строку в фильтрованный список
        $line
    }

    # Собираем обратно в строку
    $CleanContent = $filteredLines -join "`r`n"

    # Записываем ОЧИЩЕННОЕ содержимое в файл
    [System.IO.File]::WriteAllText($TempPath, $CleanContent, $UTF8NoBOM)
    Write-Host "WISNT.bat очищен от ANSI/UTF-8 и сохранён в $TempPath" -ForegroundColor Green

} catch {
    Write-Host "Ошибка обработки WISNT.bat: $($_.Exception.Message)" -ForegroundColor Red
    return # Прерываем выполнение скрипта в случае ошибки
}

# Подготовим команду для cmd.exe: сначала установить кодировку (на всякий случай), затем запустить ОЧИЩЕННЫЙ .bat файл
# /k означает выполнить команды и оставить окно открытым
# chcp 65001 устанавливает кодировку UTF-8 для этой сессии cmd (может не понадобиться, но не помешает)
# & - оператор последовательного выполнения команд в cmd
# Используем двойные кавычки для всего аргумента
$cmdArgs = "/k chcp 65001 & `"$TempPath`""

# Запускаем cmd.exe с подготовленной командой БЕЗ -Wait
Start-Process -FilePath cmd.exe -ArgumentList $cmdArgs
Write-Host "Процесс cmd.exe с ОЧИЩЕННЫМ WISNT.bat запущен." -ForegroundColor Yellow
Write-Host "Для очистки после использования удалите файл: $TempPath" -ForegroundColor Gray
