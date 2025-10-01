@echo off
title AnyDesk Reset / Backup Tool

:: Ensure running as Admin
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "APPDATA_AD=%APPDATA%\AnyDesk"
set "PROGDATA_AD=%ProgramData%\AnyDesk"
set "USERCONF=%APPDATA_AD%\user.conf"
set "BACKUPDIR=%APPDATA_AD%\Backups"
set "ANYDESK_EXE=%ProgramFiles(x86)%\AnyDesk\AnyDesk.exe"

:menu
cls
echo ==================================================
echo.
echo      _       _           _      _____           _ 
echo     / \   __^| ^| ___  ___^| ^| __ ^|_   _^|__   ___ ^| ^|
echo    / _ \ / _` ^|/ _ \/ __^| ^|/ /   ^| ^|/ _ \ / _ \^| ^|
echo   / ___ \ (_^| ^|  __/\__ \   ^<    ^| ^| (_) ^| (_) ^| ^|
echo  /_/   \_\__,_^|\___^|^|___/_^|\_\   ^|_^|\___/ \___/^|_^|
echo.
echo         AnyDesk Reset / Backup Tool
echo ==================================================
echo.
echo [1] Reset AnyDesk (keep user.conf)
echo [2] Clean Reset AnyDesk (backup first, remove user.conf)
echo [3] Backup user.conf
echo [4] Restore user.conf from backup
echo [5] Exit
echo.
set /p choice=Select option (1-5): 

if "%choice%"=="1" goto reset
if "%choice%"=="2" goto cleanreset
if "%choice%"=="3" goto backup
if "%choice%"=="4" goto restore
if "%choice%"=="5" exit
goto menu

:stop_anydesk
taskkill /f /im anydesk.exe >nul 2>&1
goto :eof

:start_anydesk
if exist "%ANYDESK_EXE%" (
    start "" "%ANYDESK_EXE%"
) else if exist "%ProgramFiles%\AnyDesk\AnyDesk.exe" (
    start "" "%ProgramFiles%\AnyDesk\AnyDesk.exe"
)
goto :eof

:backup
echo.
if exist "%AppData%\AnyDesk\user.conf" (
    if not exist "%AppData%\AnyDesk\Backups" mkdir "%AppData%\AnyDesk\Backups"
    
    rem Format datetime as YYYYMMDD-HHMMSS
    set "dt=%date:~-4%%date:~4,2%%date:~7,2%-%time:~0,2%%time:~3,2%%time:~6,2%"
    set "dt=%dt: =0%"  rem remove spaces (from hour if <10)
    
    copy "%AppData%\AnyDesk\user.conf" "%AppData%\AnyDesk\Backups\user.conf.%dt%.bak" >nul
    echo user.conf backed up as user.conf.%dt%.bak
) else (
    echo user.conf not found.
)
pause
goto menu


:restore
if not exist "%BACKUPDIR%" (
    echo No backups found.
    pause
    goto menu
)

echo.
echo Backups in: %BACKUPDIR%
dir /b /o-d "%BACKUPDIR%\user.conf.*.bak"
echo.
set /p restorefile=Enter exact backup filename to restore (or leave blank to cancel): 
if "%restorefile%"=="" goto menu

if exist "%BACKUPDIR%\%restorefile%" (
    copy /y "%BACKUPDIR%\%restorefile%" "%USERCONF%" >nul
    echo Restored %restorefile% to user.conf
    call :stop_anydesk
    call :start_anydesk
) else (
    echo File not found: %restorefile%
)
pause
goto menu

:reset
echo WARNING: This will generate a NEW AnyDesk ID.
echo Saved devices will need to enter the password again.
echo You need to set the Unattended Access password again.
set /p confirm=Proceed with Reset? (Y/n): 
if /i "%confirm%"=="Y" (
    call :stop_anydesk
    :: Delete service* and system* from ProgramData
    if exist "%PROGDATA_AD%" (
        del /f /q "%PROGDATA_AD%\service*" >nul 2>&1
        del /f /q "%PROGDATA_AD%\system*" >nul 2>&1
    )
    call :start_anydesk
) else (
    echo Reset cancelled.
)
pause
goto menu

:cleanreset
echo WARNING: This will generate a NEW AnyDesk ID.
echo Saved devices will need to enter the password again.
echo You need to set the Unattended Access password again.
set /p confirm=Proceed with Reset? (Y/n): 
if /i "%confirm%"=="Y" (
    call :backup
    call :stop_anydesk
    if exist "%PROGDATA_AD%" (
        del /f /q "%PROGDATA_AD%\service*" >nul 2>&1
        del /f /q "%PROGDATA_AD%\system*" >nul 2>&1
    )
    if exist "%USERCONF%" del /f /q "%USERCONF%"
    call :start_anydesk
) else (
    echo Clean Reset cancelled.
)
pause
goto menu
