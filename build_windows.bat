@echo off
echo ================================
echo Building Trainer for Windows
echo ================================
echo.
cd /d "%~dp0"
flutter build windows --dart-define-from-file=secrets.json
echo.
if %ERRORLEVEL% EQU 0 (
    echo ================================
    echo Build SUCCESS!
    echo ================================
    echo.
    echo Executable location:
    echo build\windows\x64\runner\Release\pulsefit_pro.exe
    echo.
) else (
    echo ================================
    echo Build FAILED!
    echo ================================
)
pause
