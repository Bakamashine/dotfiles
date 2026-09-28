@echo off
setlocal enabledelayedexpansion

where pwsh.exe >nul 2>nul
if %errorlevel% equ 0 (
    pwsh.exe
    goto :eof
)

set "PWSH_PATH=%ProgramFiles%\PowerShell\7\pwsh.exe"
if exist "%PWSH_PATH%" (
    "%PWSH_PATH%"
    goto :eof
)

powershell.exe

endlocal