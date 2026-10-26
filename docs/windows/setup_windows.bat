@echo off
title Configurador VPS Windows
echo Ejecutando instalacion automatica en Windows...
powershell -ExecutionPolicy Bypass -File "%~dp0setup_windows.ps1"
pause
