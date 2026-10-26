# setup_windows.ps1 - Instalación y configuración automática para Windows
# Configura WireGuard, SSH y accesos directos para la VPS (YOUR_VPS_IP)

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    CONFIGURADOR AUTOMÁTICO EN WINDOWS (VPS CONEXIÓN)     " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$VPS_IP = "YOUR_VPS_IP"
$VPS_PORT = "22"
$VPS_USER = "your-user"
$WG_SERVER_IP = "10.8.0.1"

# 1. Crear carpeta .ssh y archivo config
$SSH_DIR = Join-Path $env:USERPROFILE ".ssh"
if (!(Test-Path $SSH_DIR)) {
    New-Item -ItemType Directory -Path $SSH_DIR | Out-Null
}
$SSH_CONFIG = Join-Path $SSH_DIR "config"

$SSH_BLOCK = @"

# VPS Directo (IP Publica)
Host vps
    HostName $VPS_IP
    Port $VPS_PORT
    User $VPS_USER
    ServerAliveInterval 15
    ServerAliveCountMax 4

# VPS WireGuard (IP Interna)
Host vps-wg
    HostName $WG_SERVER_IP
    Port $VPS_PORT
    User $VPS_USER
    ServerAliveInterval 15
    ServerAliveCountMax 4
"@

if (Test-Path $SSH_CONFIG) {
    $currentContent = Get-Content $SSH_CONFIG -Raw
    if ($currentContent -notlike "*Host vps*") {
        Add-Content -Path $SSH_CONFIG -Value $SSH_BLOCK
        Write-Host "[OK] Configuración SSH añadida a $SSH_CONFIG" -ForegroundColor Green
    } else {
        Write-Host "[OK] SSH config ya existía en $SSH_CONFIG" -ForegroundColor Yellow
    }
} else {
    Set-Content -Path $SSH_CONFIG -Value $SSH_BLOCK
    Write-Host "[OK] Archivo de configuración SSH creado en $SSH_CONFIG" -ForegroundColor Green
}

# 2. Configurar WireGuard si existe en Documents o ProgramData
$SCRIPT_DIR = $PSScriptRoot
$WG_CONF_SRC = Join-Path $SCRIPT_DIR "wg0.conf"

if (Test-Path $WG_CONF_SRC) {
    Write-Host ""
    Write-Host "[OK] Configuración de WireGuard (wg0.conf) lista en: $WG_CONF_SRC" -ForegroundColor Green
    Write-Host "     Abre WireGuard en Windows e importa el archivo wg0.conf" -ForegroundColor Yellow
}

# 3. Crear script de acceso directo en PowerShell para OpenCode y FX
$DESKTOP_DIR = [Environment]::GetFolderPath("Desktop")

# Script ejecutable OpenCode
$LAUNCHER_OPENCODE = Join-Path $SCRIPT_DIR "conectar_opencode.bat"
$OPENCODE_BAT_CONTENT = @"
@echo off
echo Conectando a OpenCode Web en VPS...
ssh -t -p $VPS_PORT ${VPS_USER}@${VPS_IP} "~/IA/vps-tunnel"
pause
"@
Set-Content -Path $LAUNCHER_OPENCODE -Value $OPENCODE_BAT_CONTENT

# Script ejecutable FX
$LAUNCHER_FX = Join-Path $SCRIPT_DIR "conectar_fx.bat"
$FX_BAT_CONTENT = @"
@echo off
echo Conectando a FX en VPS...
ssh -t -p $VPS_PORT ${VPS_USER}@${VPS_IP} "~/IA/vps-fx"
pause
"@
Set-Content -Path $LAUNCHER_FX -Value $FX_BAT_CONTENT

# Script ejecutable AGY
$LAUNCHER_AGY = Join-Path $SCRIPT_DIR "conectar_agy.bat"
$AGY_BAT_CONTENT = @"
@echo off
echo Conectando a Antigravity CLI (agy) en VPS...
ssh -t -p $VPS_PORT ${VPS_USER}@${VPS_IP} "~/IA/vps-agy"
pause
"@
Set-Content -Path $LAUNCHER_AGY -Value $AGY_BAT_CONTENT

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  CONFIGURACIÓN COMPLETADA CON ÉXITO EN WINDOWS" -ForegroundColor Green
Write-Host "  Archivos ejecutables generados:" -ForegroundColor Green
Write-Host "   - $LAUNCHER_OPENCODE" -ForegroundColor White
Write-Host "   - $LAUNCHER_FX" -ForegroundColor White
Write-Host "   - $LAUNCHER_AGY" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Cyan
