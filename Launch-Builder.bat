@echo off
echo ===============================================
echo PowerShell Executor Builder - GUI Launcher
echo ===============================================
echo.
echo Starting GUI application...
echo.
powershell.exe -ExecutionPolicy Bypass -File "%~dp0PSEBuilder.ps1"
echo.
echo GUI closed.
pause