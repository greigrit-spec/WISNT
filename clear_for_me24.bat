@ECHO OFF
CHCP 65001
COLOR A
CLS

REM ----------------------------------------------------------------------------------------
REM Проверка наличия прав администратора
FOR /F "tokens=1,2*" %%V IN ('bcdedit') DO SET adminTest=%%V
    IF (%adminTest%)==(�⪠����) GOTO errNoAdmin
    IF (%adminTest%)==(Access) GOTO errNoAdmin
REM ----------------------------------------------------------------------------------------

ECHO.
ECHO Добро пожаловать!
ECHO Этот скрипт очистит различные системные и пользовательские данные.
ECHO Если у вас есть важные данные или настройки, пожалуйста, создайте их резервные копии перед продолжением.
ECHO.
ECHO.

ECHO 1 - Минимальная очистка
ECHO 2 - Средняя очистка (включает дополнительные действия)
ECHO 3 - Максимальная очистка (включает все возможные действия, включая журналы событий Windows)
ECHO Нажмите ENTER для выхода.
ECHO.
SET /p doset="Выберите опцию: " 
ECHO.

REM Выход, если пользователь не выбрал 1, 2 или 3
IF %doset% NEQ 1 (
    IF %doset% NEQ 2 (
        IF %doset% NEQ 3 EXIT
    )
)

REM Выполнение очистки журналов событий Windows, если выбрана опция 3
IF %doset% EQU 3 (
    ECHO.
    ECHO Очистка журналов событий Windows...
    FOR /F "tokens=*" %%G in ('wevtutil.exe el') DO (call :do_clear "%%G")
    ECHO.
    ECHO Выполнено.
    ECHO.
)

REM Очистка ShellBag
ECHO.
ECHO Очистка ShellBag...
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU" /f
REG DELETE "HKEY_CURRENT_USER\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags" /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\BagMRU" /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\Shell\Bags" /f
ECHO.

REM Очистка Explorer RunMRU
ECHO.
ECHO Очистка Explorer RunMRU...
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU" /va /f
ECHO.

REM Очистка ComDlg32 OpenSaveMRU
ECHO.
ECHO Очистка OpenSave и LastVisited...
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\FirstFolder" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRULegacy" /va /f
REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU" /f
REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU"
ECHO.

REM Дополнительные очистки для опций 2 и 3
IF %doset% NEQ 1 (
    REM Очистка UserAssist
    ECHO.
    ECHO Очистка UserAssist...
    REG DELETE "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist" /f
    REG ADD "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
    ECHO.
)

REM Очистка AppCompatCache
ECHO.
ECHO Очистка AppCompatCache...
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache" /va /f
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Session Manager\AppCompatCache" /va /f
ECHO.

REM Очистка DiagnosedApplications
ECHO.
ECHO Очистка DiagnosedApplications...
REG DELETE "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications" /f
REG ADD "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RADAR\HeapLeakDetection\DiagnosedApplications"
ECHO.

REM Получение SID пользователя
FOR /F "tokens=2" %%i IN ('whoami /user /fo table /nh') DO SET usersid=%%i

REM Очистка истории поиска
ECHO.
ECHO Очистка истории поиска...
REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps" /f
REG ADD "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps"
ECHO.

REM Очистка BAM (Background Activity Moderator)
ECHO.
ECHO Очистка Background Activity Moderator...
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\bam\UserSettings\%usersid%" /va /f
REG DELETE "HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\bam\UserSettings\%usersid%" /va /f
ECHO.

REM Очистка AppCompatFlags
ECHO.
ECHO Очистка AppCompatFlags...
REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store" /va /f
ECHO.

IF %doset% NEQ 1 (
    REM Очистка записи о несовместимости приложений
    ECHO.
    ECHO Очистка слоев совместимости приложений...
    REG DELETE  "HKEY_USERS\%usersid%\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /va /f
    ECHO.
)

REM Очистка монтированных устройств
ECHO.
ECHO Очистка монтированных устройств...
REG DELETE "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2" /f
REG ADD "HKEY_USERS\%usersid%\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2"
ECHO.

REM Завершение скрипта
ECHO.
ECHO Очистка завершена. Нажмите любую клавишу для выхода...
PAUSE > NUL
EXIT

REM Метка для очистки журналов событий
:do_clear
ECHO Очистка журнала событий %1
wevtutil.exe cl %1
GOTO :EOF

REM Ошибка, если нет прав администратора
:errNoAdmin
ECHO.
ECHO Ошибка: для выполнения этого скрипта необходимы права администратора.
ECHO Пожалуйста, запустите этот скрипт от имени администратора.
PAUSE > NUL
EXIT
