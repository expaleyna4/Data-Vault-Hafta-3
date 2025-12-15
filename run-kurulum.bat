@echo off
REM Launcher to run kurulum-hafta3.sh in WSL (double-clickable)
setlocal enabledelayedexpansion
set SCRIPTDIR=%~dp0
if "%SCRIPTDIR:~-1%"=="\" set SCRIPTDIR=%SCRIPTDIR:~0,-1%
for /f "usebackq delims=" %%p in (`wsl wslpath -a "%SCRIPTDIR%"`) do set WSLPATH=%%p
wsl bash -lc "cd '%WSLPATH%' && bash ./kurulum-hafta3.sh -y --verbose --log /tmp/kurulum-debug.log"
pause
