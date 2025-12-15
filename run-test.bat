@echo off
REM Launcher to run test-hafta3.sh in WSL (double-clickable)
setlocal enabledelayedexpansion
set SCRIPTDIR=%~dp0
rem Remove trailing backslash if present
if "%SCRIPTDIR:~-1%"=="\" set SCRIPTDIR=%SCRIPTDIR:~0,-1%
for /f "usebackq delims=" %%p in (`wsl wslpath -a "%SCRIPTDIR%"`) do set WSLPATH=%%p
wsl bash -lc "cd '%WSLPATH%' && bash ./test-hafta3.sh"
pause
