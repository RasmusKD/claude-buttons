@echo off
rem Stops the running Claude Buttons panel cleanly - no Task Manager needed.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0claude-buttons.ps1" -Quit
pause
