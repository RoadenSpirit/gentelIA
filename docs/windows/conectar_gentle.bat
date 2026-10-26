@echo off
setlocal enabledelayedexpansion
title Gentle Shell - Conexión Portable (Eternal Terminal)
cls
echo ==========================================================
echo    CONECTANDO A GENTLE SHELL EN VPS (Eternal Terminal)    
echo ==========================================================
echo.

set SCRIPT_DIR=%~dp0
set ET_BIN=%SCRIPT_DIR%et-client\et.exe
set REMOTE_USER=your-user
set REMOTE_HOST_WG=10.8.0.1
set REMOTE_HOST_PUB=YOUR_VPS_IP
set SSH_PORT=22
set ET_PORT=2022
set REMOTE_CMD=/home/your-user/scripts/vps-gentle-menu.sh
set REMOTE_TERMINAL_PATH=/home/your-user/.local/bin/etterminal

:: 1. Detección automática de clave privada portable (si la llevas en la misma carpeta)
set SSH_KEY_OPT=
if exist "%SCRIPT_DIR%id_ed25519" (
    set SSH_KEY_OPT=--ssh-option "IdentityFile=%SCRIPT_DIR%id_ed25519"
    set SSH_DIRECT_KEY=-i "%SCRIPT_DIR%id_ed25519"
    echo [OK] Clave SSH portable detectada: id_ed25519
) else if exist "%SCRIPT_DIR%id_rsa" (
    set SSH_KEY_OPT=--ssh-option "IdentityFile=%SCRIPT_DIR%id_rsa"
    set SSH_DIRECT_KEY=-i "%SCRIPT_DIR%id_rsa"
    echo [OK] Clave SSH portable detectada: id_rsa
)

:: 2. Comprobar si WireGuard está activo en este PC
ping -n 1 -w 1000 %REMOTE_HOST_WG% >nul 2>&1
if %errorlevel% equ 0 (
    set TARGET_HOST=%REMOTE_HOST_WG%
    echo [Ruta] WireGuard (%REMOTE_HOST_WG%) [Activo]
) else (
    set TARGET_HOST=%REMOTE_HOST_PUB%
    echo [Ruta] IP Publica (%REMOTE_HOST_PUB%) [WireGuard no activo]
)

echo.
:: 3. Conexión mediante et.exe nativo de Windows (sin WSL)
if exist "%ET_BIN%" (
    echo Iniciando Eternal Terminal portable hacia %TARGET_HOST%...
    if defined SSH_KEY_OPT (
        "%ET_BIN%" -u %REMOTE_USER% --port %ET_PORT% --ssh-option "Port=%SSH_PORT%" %SSH_KEY_OPT% --terminal-path "%REMOTE_TERMINAL_PATH%" %TARGET_HOST% -c "%REMOTE_CMD%"
    ) else (
        "%ET_BIN%" -u %REMOTE_USER% --port %ET_PORT% --ssh-option "Port=%SSH_PORT%" --terminal-path "%REMOTE_TERMINAL_PATH%" %TARGET_HOST% -c "%REMOTE_CMD%"
    )
) else (
    echo [Aviso] et.exe no encontrado, conectando via OpenSSH de Windows...
    if defined SSH_DIRECT_KEY (
        ssh -t -p %SSH_PORT% %SSH_DIRECT_KEY% %REMOTE_USER%@%TARGET_HOST% "%REMOTE_CMD%"
    ) else (
        ssh -t -p %SSH_PORT% %REMOTE_USER%@%TARGET_HOST% "%REMOTE_CMD%"
    )
)

if %errorlevel% neq 0 (
    echo.
    echo ==========================================================
    echo Conexion finalizada o interrumpida.
    echo ==========================================================
    pause
)
