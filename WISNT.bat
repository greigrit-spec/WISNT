@echo off
:: ==============================================
:: ИНИЦИАЛИЗАЦИЯ И СТИЛИЗАЦИЯ
:: ==============================================
chcp 65001 >nul
title Windows Ultimate Optimizer (Final Fix)
setlocal enabledelayedexpansion

:: Настройка цветов ANSI
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "ESC=%%b"

:: Палитра
set "cRed=%ESC%[91m"
set "cGreen=%ESC%[92m"
set "cYellow=%ESC%[93m"
set "cBlue=%ESC%[94m"
set "cMagenta=%ESC%[95m"
set "cCyan=%ESC%[96m"
set "cWhite=%ESC%[97m"
set "cReset=%ESC%[0m"
set "cGray=%ESC%[90m"

:: Размер окна (строго фиксируем)
mode con cols=120 lines=62

:: Логирование
set "logfile=%TEMP%\win_tweak_log.txt"
echo [%date% %time%] Script Started >> "%logfile%"

:: ==============================================
:: ПРОВЕРКА ПРАВ АДМИНИСТРАТОРА
:: ==============================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  %cRed%[ ERROR ] Требуются права администратора!%cReset%
    echo  %cYellow%Перезапуск с повышенными правами...%cReset%
    timeout /t 2 >nul
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: ==============================================
:: ГЛАВНОЕ МЕНЮ
:: ==============================================
:menu
:: Сброс размера и очистка "мусора"
mode con cols=120 lines=62 >nul 2>&1
cls
echo.
echo  %cCyan%╔════════════════════════════════════════════════════════════════════════════════════════════════╗%cReset%
echo  %cCyan%║%cWhite%                               УНИВЕРСАЛЬНЫЙ НАСТРОЙЩИК WINDOWS                                 %cCyan%║%cReset%
echo  %cCyan%╚════════════════════════════════════════════════════════════════════════════════════════════════╝%cReset%
echo.
echo   %cGray%:: НАСТРОЙКИ ИНТЕРФЕЙСА И СИСТЕМЫ ::%cReset%
echo   %cCyan%[1]%cReset%  Просмотр автозагрузки                 %cCyan%[4]%cReset%  Визуальные эффекты
echo   %cCyan%[2]%cReset%  Включить автозапуск Num Lock          %cCyan%[5]%cReset%  Управление UAC
echo   %cCyan%[3]%cReset%  Настройки папок (скрытые файлы)       %cCyan%[6]%cReset%  Настройки электропитания
echo.
echo   %cGray%:: ПАМЯТЬ И ОПТИМИЗАЦИЯ ::%cReset%
echo   %cCyan%[7]%cReset%  Авто-файл подкачки (25%% от ОЗУ)       %cCyan%[9]%cReset%  Очистка мусора (Temp, Cache, Logs)
echo   %cCyan%[8]%cReset%  Файл подкачки вручную                 %cCyan%[10]%cReset% Сброс сети и DNS
echo.
echo   %cGray%:: ДИАГНОСТИКА И УПРАВЛЕНИЕ ::%cReset%
echo   %cCyan%[11]%cReset% Проверка целостности (SFC)            %cCyan%[13]%cReset% Перезапуск видеодрайвера
echo   %cCyan%[12]%cReset% Управление пользователями             %cCyan%[14]%cReset% %cGreen%СВОДКА О СИСТЕМЕ (DASHBOARD)%cReset%
echo.
echo   %cGray%:: ПИТАНИЕ И ЗАГРУЗКА ::%cReset%
echo   %cCyan%[15]%cReset% Перезагрузка                        %cCyan%[17]%cReset% Безопасный режим
echo   %cCyan%[16]%cReset% В BIOS                              %cCyan%[18]%cReset% Обычный режим (сброс SafeMode)
echo.
echo   %cGray%:: ПРОЧЕЕ ::%cReset%
echo   %cCyan%[19]%cReset% Полезные ссылки                     %cCyan%[20]%cReset% Активация (MAS)
echo.
echo   %cRed%[0]  ВЫХОД%cReset%
echo.
echo  %cCyan%=================================================================================================%cReset%
set "selected_option="
set /p "selected_option= %cYellow%>>> Ваш выбор [0-20]: %cReset%"

if not defined selected_option goto menu
echo [LOG] Choice: !selected_option! >> "%logfile%"

if "!selected_option!"=="0" exit
if "!selected_option!"=="1" goto startup
if "!selected_option!"=="2" goto numlock
if "!selected_option!"=="3" goto folder_options
if "!selected_option!"=="4" goto visual_effects
if "!selected_option!"=="5" goto uac
if "!selected_option!"=="6" goto power_combined
if "!selected_option!"=="7" goto auto_pagefile
if "!selected_option!"=="8" goto pagefile
if "!selected_option!"=="9" goto optimize
if "!selected_option!"=="10" goto reset_network
if "!selected_option!"=="11" goto sfc_scan
if "!selected_option!"=="12" goto local_users_groups
if "!selected_option!"=="13" goto reset_gpu
if "!selected_option!"=="14" goto sys_info_safe
if "!selected_option!"=="15" goto restart_normal
if "!selected_option!"=="16" goto restart_bios
if "!selected_option!"=="17" goto restart_safe
if "!selected_option!"=="18" goto reset_safe
if "!selected_option!"=="19" goto open_links
if "!selected_option!"=="20" goto activate

echo.
echo  %cRed%[ ERROR ] Неверный ввод!%cReset%
timeout /t 1 >nul
goto menu

:: ==============================================
:: ФУНКЦИИ
:: ==============================================

:startup
echo.
echo  %cYellow%[ INFO ]%cReset% Открытие автозагрузки...
start "" "taskmgr.exe" /startup
start "" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
goto menu

:numlock
echo.
echo  %cYellow%[ BUSY ]%cReset% Настройка реестра...
reg add "HKEY_USERS\.DEFAULT\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul
reg add "HKEY_CURRENT_USER\Control Panel\Keyboard" /v InitialKeyboardIndicators /t REG_SZ /d 2 /f >nul
echo  %cGreen%[ OK ]%cReset% NumLock включен.
timeout /t 2 >nul
goto menu

:folder_options
start "" control.exe folders
goto menu

:visual_effects
start "" "SystemPropertiesPerformance.exe"
if %errorlevel% neq 0 start "" "SystemPropertiesAdvanced.exe"
goto menu

:uac
start "" "UserAccountControlSettings.exe"
goto menu

:power_combined
start "" "powercfg.cpl"
goto menu

:auto_pagefile
cls
echo.
echo  %cCyan%--- НАСТРОЙКА ФАЙЛА ПОДКАЧКИ ---%cReset%
echo.
echo  %cYellow%[ BUSY ]%cReset% Вычисление объема ОЗУ...
powershell -noprofile -command "[math]::Floor((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1MB)" > "%TEMP%\ram.tmp"
set /p total_mb=<"%TEMP%\ram.tmp"
del "%TEMP%\ram.tmp"

if "%total_mb%"=="" (
    echo  %cRed%[ ERROR ] Ошибка определения ОЗУ.%cReset%
    pause
    goto menu
)

set /a "swap_size=total_mb / 4"
if !swap_size! lss 512 set "swap_size=512"

echo  %cGreen%[ INFO ]%cReset% ОЗУ: %cWhite%!total_mb! МБ%cReset%
echo  %cGreen%[ INFO ]%cReset% Устанавливаем подкачку: %cWhite%!swap_size! МБ%cReset%

powershell -command "Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management' -Name 'PagingFiles' -Value ('c:\pagefile.sys %swap_size% %swap_size%') -Type MultiString -Force"
echo.
echo  %cGreen%[ OK ]%cReset% Настройки применены успешно.
echo  %cGray%Нажмите любую клавишу...%cReset%
pause >nul
goto menu

:pagefile
start "" "SystemPropertiesAdvanced.exe"
goto menu

:optimize
cls
echo.
echo  %cCyan%--- ОЧИСТКА СИСТЕМЫ (УСИЛЕННАЯ) ---%cReset%
echo.

:: 1. Очистка Недавних
echo  %cYellow%[ 1/4 ]%cReset% Очистка Недавних документов...
del /f /q "%USERPROFILE%\Recent\*.*" >nul 2>&1
if not errorlevel 1 (echo  %cGreen%[ OK ]%cReset%) else (echo  %cRed%[ FAIL ]%cReset%)

:: 2. Очистка временных файлов (USER TEMP)
echo  %cYellow%[ 2/4 ]%cReset% Очистка пользовательской папки Temp...
del /f /s /q "%TEMP%\*.*" >nul 2>&1
if not errorlevel 1 (echo  %cGreen%[ OK ]%cReset%) else (echo  %cRed%[ FAIL ]%cReset%)

:: 3. Очистка временных файлов (SYSTEM TEMP)
echo  %cYellow%[ 3/4 ]%cReset% Очистка системной папки Temp и кеша обновлений...
del /f /s /q "%WINDIR%\Temp\*.*" >nul 2>&1
del /f /s /q "%WINDIR%\SoftwareDistribution\Download\*.*" >nul 2>&1
if not errorlevel 1 (echo  %cGreen%[ OK ]%cReset%) else (echo  %cRed%[ FAIL ]%cReset%)

:: 4. Запуск встроенной очистки диска (Включает Корзину, Кеш)
echo  %cYellow%[ 4/4 ]%cReset% Запуск встроенной очистки диска (cleanmgr)...
:: Добавляем ключ реестра для автоматического включения всех опций очистки (включая Корзину)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0010 /t REG_DWORD /d 2 /f >nul
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0010 /t REG_DWORD /d 2 /f >nul
cleanmgr.exe /sagerun:10
if not errorlevel 1 (echo  %cGreen%[ OK ]%cReset%) else (echo  %cRed%[ FAIL ]%cReset%)

echo.
echo  %cGreen%[ DONE ]%cReset% Полная очистка завершена.
timeout /t 2 >nul
goto menu

:reset_network
echo.
echo  %cYellow%[ BUSY ]%cReset% Сброс сетевых настроек...
netsh winsock reset >nul 2>&1
ipconfig /flushdns >nul 2>&1
echo  %cGreen%[ OK ]%cReset% Сеть сброшена.
timeout /t 2 >nul
goto menu

:sfc_scan
cls
echo.
echo  %cCyan%--- ПРОВЕРКА ЦЕЛОСТНОСТИ (SFC) ---%cReset%
echo.
sfc /scannow
echo.
echo  %cGray%Нажмите любую клавишу...%cReset%
pause >nul
goto menu

:local_users_groups
start "" "lusrmgr.msc"
echo.
echo  %cYellow%[ INFO ]%cReset% Если окно не открылось - нажмите клавишу для альтернативы.
pause >nul
start "" "netplwiz"
goto menu

:reset_gpu
echo.
echo  %cYellow%[ BUSY ]%cReset% Перезапуск драйвера видеокарты...
powershell -command "Get-PnpDevice -Class Display | Disable-PnpDevice -Confirm:$false; Start-Sleep -Seconds 1; Get-PnpDevice -Class Display | Enable-PnpDevice -Confirm:$false"
echo  %cGreen%[ OK ]%cReset% Готово.
timeout /t 2 >nul
goto menu

:: ==============================================
:: [14] СВОДКА О ЖЕЛЕЗЕ (ИСПРАВЛЕНО ОТОБРАЖЕНИЕ)
:: ==============================================
:sys_info_safe
:: Сначала очищаем экран в CMD, чтобы PS начал писать с самого верха
cls
echo.
echo  %cYellow%[ BUSY ]%cReset% Загрузка данных (SSD, TPM, System)...
echo  %cGray%Пожалуйста, подождите...%cReset%
echo.

set "ps_file=%TEMP%\sys_info_gen.ps1"
if exist "%ps_file%" del "%ps_file%"

:: --- ГЕНЕРАЦИЯ СКРИПТА ---
setlocal DisableDelayedExpansion

echo $ProgressPreference = 'SilentlyContinue' >> "%ps_file%"
echo $ErrorActionPreference = 'SilentlyContinue' >> "%ps_file%"
:: Убрали Clear-Host изнутри, полагаемся на CLS батника, чтобы не мигало

:: 1. WINDOWS & UPTIME
echo Write-Host " [OPERATING SYSTEM]" -ForegroundColor Cyan >> "%ps_file%"
echo $os = Get-CimInstance Win32_OperatingSystem >> "%ps_file%"
echo $uptime = (Get-Date) - $os.LastBootUpTime >> "%ps_file%"
echo $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes >> "%ps_file%"
echo $secBoot = try { if (Confirm-SecureBootUEFI) {'Enabled'} else {'Disabled'} } catch {'Legacy/Unknown'} >> "%ps_file%"
echo $tpm = try { $t = Get-Tpm; if($t.TpmPresent){'v2.0'}else{'None'} } catch {'Unknown'} >> "%ps_file%"
echo [PSCustomObject]@{ 'Edition'=$os.Caption; 'Version'=$os.Version; 'InstallDate'=$os.InstallDate; 'Uptime'=$uptimeStr; 'TPM'=$tpm } ^| Format-Table -AutoSize >> "%ps_file%"

:: 2. MOTHERBOARD
echo Write-Host " [MOTHERBOARD & RAM]" -ForegroundColor Cyan >> "%ps_file%"
echo $cs = Get-CimInstance Win32_ComputerSystem >> "%ps_file%"
echo $bb = Get-CimInstance Win32_BaseBoard >> "%ps_file%"
echo $bios = Get-CimInstance Win32_BIOS >> "%ps_file%"
echo $ram = "{0:N2} GB" -f ($cs.TotalPhysicalMemory / 1GB) >> "%ps_file%"
echo [PSCustomObject]@{ 'Model'=$bb.Product; 'Vendor'=$bb.Manufacturer; 'BIOS'=$bios.SMBIOSBIOSVersion; 'Total RAM'=$ram } ^| Format-Table -AutoSize >> "%ps_file%"

:: 3. CPU
echo Write-Host " [CPU]" -ForegroundColor Cyan >> "%ps_file%"
echo Get-CimInstance Win32_Processor ^| Select-Object @{N='Model';E={$_.Name}}, @{N='Cores';E={$_.NumberOfCores}}, @{N='Threads';E={$_.NumberOfLogicalProcessors}}, @{N='MHz';E={$_.MaxClockSpeed}} ^| Format-Table -AutoSize >> "%ps_file%"

:: 4. GPU
echo Write-Host " [GPU & DISPLAY]" -ForegroundColor Cyan >> "%ps_file%"
echo $gpu = Get-CimInstance Win32_VideoController >> "%ps_file%"
echo $gpu ^| Select-Object @{N='Model';E={$_.Name}}, @{N='Driver';E={$_.DriverVersion}}, @{N='VRAM';E={if($_.AdapterRAM){"{0:N2} GB" -f ($_.AdapterRAM/1GB)}else{"(System)"}}}, @{N='Mode';E={if($_.CurrentHorizontalResolution){"$($_.CurrentHorizontalResolution)x$($_.CurrentVerticalResolution) @ $($_.CurrentRefreshRate)Hz"}else{"N/A"}}} ^| Format-Table -AutoSize >> "%ps_file%"

:: 5. STORAGE (PHYSICAL)
echo Write-Host " [STORAGE DEVICES]" -ForegroundColor Cyan >> "%ps_file%"
echo Get-PhysicalDisk ^| Select-Object @{N='Model';E={$_.FriendlyName}}, @{N='Type';E={$_.MediaType}}, @{N='Health';E={$_.HealthStatus}}, @{N='Size';E={"{0:N2} GB" -f ($_.Size/1GB)}} ^| Format-Table -AutoSize >> "%ps_file%"

:: 6. LOGICAL DISKS
echo Write-Host " [LOGICAL VOLUMES]" -ForegroundColor Cyan >> "%ps_file%"
echo Get-CimInstance Win32_LogicalDisk ^| Where-Object DriveType -eq 3 ^| Select-Object @{N='Drive';E={$_.DeviceID}}, @{N='Label';E={$_.VolumeName}}, @{N='Total';E={"{0:N2} GB" -f ($_.Size/1GB)}}, @{N='Free';E={"{0:N2} GB" -f ($_.FreeSpace/1GB)}} ^| Format-Table -AutoSize >> "%ps_file%"

:: 7. AUDIO
echo Write-Host " [AUDIO DEVICES]" -ForegroundColor Cyan >> "%ps_file%"
echo Get-CimInstance Win32_SoundDevice ^| Where-Object Status -eq 'OK' ^| Select-Object @{N='Name';E={$_.ProductName}}, @{N='Manufacturer';E={$_.Manufacturer}} ^| Format-Table -AutoSize >> "%ps_file%"

:: 8. NETWORK
echo Write-Host " [ACTIVE NETWORK]" -ForegroundColor Cyan >> "%ps_file%"
echo Get-CimInstance Win32_NetworkAdapterConfiguration ^| Where-Object {$_.IPEnabled -eq $true} ^| Select-Object @{N='Adapter';E={$_.Description.Split('(')[0].Trim()}}, @{N='IP';E={$_.IPAddress[0]}}, @{N='MAC';E={$_.MACAddress}} ^| Format-Table -AutoSize >> "%ps_file%"

endlocal
:: --- КОНЕЦ ГЕНЕРАЦИИ ---

:: Чистим экран ПЕРЕД выводом, чтобы первая строка была в самом верху
cls
powershell -NoProfile -ExecutionPolicy Bypass -File "%ps_file%"

:: Очистка временного файла
del "%ps_file%" >nul 2>&1

echo.
echo  %cCyan%===========================================================================%cReset%
echo  %cGray%Нажмите любую клавишу, чтобы вернуться в меню...%cReset%
pause >nul

:: Восстановление окна
mode con cols=120 lines=62 >nul 2>&1
goto menu

:: ==============================================
:: КОМАНДЫ ПИТАНИЯ И ССЫЛКИ
:: ==============================================
:restart_normal
echo.
echo  %cYellow%[ INFO ]%cReset% Перезагрузка...
shutdown /r /t 0
exit

:restart_bios
echo.
echo  %cYellow%[ INFO ]%cReset% Вход в BIOS...
shutdown /r /fw /t 0
exit

:restart_safe
echo.
echo  %cYellow%[ INFO ]%cReset% Настройка безопасного режима...
bcdedit /set {current} safeboot minimal
shutdown /r /t 0
exit

:reset_safe
echo.
echo  %cYellow%[ INFO ]%cReset% Отключение безопасного режима...
bcdedit /deletevalue {current} safeboot
echo  %cGreen%[ OK ]%cReset%
timeout /t 2 >nul
goto menu

:open_links
echo.
echo  %cYellow%[ INFO ]%cReset% Открытие ссылок в браузере...
start "" "https://github.com/hellzerg/optimizer/releases"
start "" "https://www.nirsoft.net/x64_download_package.html"
start "" "https://www.virustotal.com"
start "" "https://win10tweaker.ru/buy"
start "" "https://get.activated.win"
echo  %cGreen%[ OK ]%cReset%
timeout /t 2 >nul
goto menu

:activate
cls
echo.
echo  %cYellow%[ INFO ]%cReset% Запуск MAS (Microsoft Activation Scripts)...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://get.activated.win | iex"
echo.
echo  %cGreen%[ DONE ]%cReset% Активатор завершил работу.
echo  %cGray%Нажмите любую клавишу...%cReset%
pause >nul

goto menu

