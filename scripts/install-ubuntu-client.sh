#!/usr/bin/env bash
# =============================================================================
# install-ubuntu-client.sh — Instalador Automatizado de Gentle Shell & Conexión VPS
# Diseñado para Ubuntu 22.04 LTS (Jammy Jellyfish) y derivados.
# =============================================================================

set -euo pipefail

ROSE='\033[38;5;205m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${ROSE}"
cat << 'EOF'
 ⣠⣾⣷⣶⣦⣤⣤⣄⣠⣄⣀ ⢀⣀⣀
 ⢀⣴⣿⣿⠿⣋⣭⣭⣯⣭⣍⣭⣿⣟⠛⠛⠿⣿⣷⣄
 ⢀⣴⣾⡟⢻⣿⡟⠁⣼⣿⠏⣵⢻⣿⣻⣿⣿⢿⡻⣿⣿⣶⡌⢿⣿⣷⣦⣤⡄
 ⣤⣶⣾⣿⣿⠏ ⠈⢿⣄ ⢹⣏⠠⠟⣾⣿⣿⣿⣿⣿⠷⣏⣼⠟⢡⣿⡟⠋⢻⣿⣿⡄
 ⠈⣿⣿⣿⣿⡆ ⣽⢧⡘⠈⠳⣦⣍⠛⠛⢦⣉⣴⣛⣫⣭⣴⡟⠋ ⣾⣿⣿⡿
EOF
echo -e "${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo -e "${ROSE}   GENTLE SHELL — INSTALADOR Y PRECONFIGURADOR (UBUNTU 22)${NC}"
echo -e "${BLUE}==========================================================${NC}"
echo ""

# 1. Comprobar que corre en Linux
if [ "$(uname -s)" != "Linux" ]; then
    echo -e "${RED}[ERROR] Este instalador está optimizado para sistemas Linux (Ubuntu 22.04).${NC}"
    exit 1
fi

echo -e "${YELLOW}[1/5] Comprobando e instalando dependencias del sistema...${NC}"
sudo apt update -y
sudo apt install -y curl git software-properties-common wireguard-tools

# 2. Instalar Eternal Terminal (ET) desde PPA oficial
echo -e "${YELLOW}[2/5] Configurando Eternal Terminal (ET) para baja latencia...${NC}"
if ! command -v et >/dev/null 2>&1; then
    echo -e "${BLUE}Añadiendo PPA oficial de Eternal Terminal (ppa:jgmath2000/et)...${NC}"
    sudo add-apt-repository -y ppa:jgmath2000/et || true
    sudo apt update -y
    sudo apt install -y et || {
        echo -e "${YELLOW}Aviso: No se pudo instalar ET desde PPA. Usaremos conexión SSH ultra-optimizada.${NC}"
    }
else
    echo -e "${GREEN}[OK] Eternal Terminal ya está instalado.${NC}"
fi

# 3. Comprobar o instalar Node.js 22 LTS si el usuario quiere Pi local
echo -e "${YELLOW}[3/5] Verificando runtime de Node.js v22 (LTS)...${NC}"
NODE_READY=false
if command -v node >/dev/null 2>&1; then
    NODE_VER=$(node -v | tr -d 'v')
    NODE_MAJOR=$(echo "$NODE_VER" | cut -d. -f1)
    if [ "$NODE_MAJOR" -ge 22 ]; then
        echo -e "${GREEN}[OK] Node.js $NODE_VER compatible detectado.${NC}"
        NODE_READY=true
    fi
fi

if [ "$NODE_READY" = false ]; then
    echo -e "${BLUE}Instalando Node.js v22 LTS oficial...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt install -y nodejs
    echo -e "${GREEN}[OK] Node.js $(node -v) instalado exitosamente.${NC}"
fi

# 4. Preconfigurar el proveedor FreeLLMAPI en el entorno local de Pi
echo -e "${YELLOW}[4/5] Preconfigurando modelos y API de FreeLLMAPI...${NC}"
mkdir -p "$HOME/.gentle-shell/agent" "$HOME/.pi/agent"

CATALOG_JSON='{
  "$schema": "https://pi.dev/schemas/models.schema.json",
  "providers": {
    "freellmapi": {
      "name": "FreeLLMAPI Unified Gateway",
      "baseUrl": "https://omni.carmayn8n.cloud/v1",
      "api": "openai-completions",
      "apiKey": "sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4",
      "authHeader": true,
      "models": [
        {
          "id": "auto",
          "name": "Auto Router (Bandit)",
          "contextWindow": 1048576,
          "maxTokens": 65536,
          "input": ["text", "image"]
        },
        {
          "id": "gemini-3.8-flash-high",
          "name": "Gemini 3.8 Flash High",
          "contextWindow": 1048576,
          "maxTokens": 65536,
          "input": ["text", "image"]
        },
        {
          "id": "gemini-4-argon",
          "name": "Gemini 4 Argon",
          "contextWindow": 1048576,
          "maxTokens": 65536,
          "input": ["text", "image"]
        },
        {
          "id": "claude-sonnet-5-5-high",
          "name": "Claude Sonnet 5.5 High",
          "contextWindow": 200000,
          "maxTokens": 64000,
          "input": ["text", "image"]
        }
      ]
    }
  }
}'

SETTINGS_JSON='{
  "defaultProvider": "freellmapi",
  "defaultModel": "auto",
  "defaultThinkingLevel": "off",
  "tuiMode": "fullscreen",
  "theme": "Gentleman-Cute"
}'

echo "$CATALOG_JSON" > "$HOME/.gentle-shell/agent/models.json"
echo "$CATALOG_JSON" > "$HOME/.pi/agent/models.json"
echo "$SETTINGS_JSON" > "$HOME/.gentle-shell/agent/settings.json"
echo "$SETTINGS_JSON" > "$HOME/.pi/agent/settings.json"
echo -e "${GREEN}[OK] Proveedor FreeLLMAPI y modelos configurados.${NC}"

# 5. Instalar el comando global de conexión 'gentle-connect' y 'vps-gentle'
echo -e "${YELLOW}[5/5] Instalando lanzador global en el sistema...${NC}"

LAUNCHER_SCRIPT='#!/usr/bin/env bash
REMOTE_USER="your-user"
REMOTE_HOST_WG="10.8.0.1"
REMOTE_HOST_PUB="YOUR_VPS_IP"
SSH_PORT="22"
ET_PORT="2022"
REMOTE_CMD="/home/your-user/scripts/vps-gentle-menu.sh"
REMOTE_TERMINAL_PATH="/home/your-user/.local/bin/etterminal"

clear
echo "=========================================================="
echo "    CONECTANDO A GENTLE SHELL EN VPS (Eternal Terminal)    "
echo "=========================================================="
echo ""

# Detectar si WireGuard está activo
if ping -c 1 -W 2 "$REMOTE_HOST_WG" &>/dev/null; then
    TARGET_HOST="$REMOTE_HOST_WG"
    echo "Ruta: WireGuard ($TARGET_HOST) [Activo]"
else
    TARGET_HOST="$REMOTE_HOST_PUB"
    echo "Ruta: IP pública ($TARGET_HOST) [WireGuard no detectado]"
fi

echo ""

# Usar ET si está disponible, o fallback a SSH con TCP_NODELAY
if command -v et >/dev/null 2>&1; then
    echo "Iniciando Eternal Terminal hacia $TARGET_HOST..."
    exec et -u "$REMOTE_USER" --port "$ET_PORT" --ssh-option "Port=$SSH_PORT" --terminal-path "$REMOTE_TERMINAL_PATH" "$TARGET_HOST" -c "$REMOTE_CMD"
else
    echo "Conectando mediante SSH de ultra-baja latencia..."
    exec ssh -t -p "$SSH_PORT" \
        -o TCPKeepAlive=yes \
        -o ServerAliveInterval=15 \
        -o ServerAliveCountMax=4 \
        -o IPQoS=throughput \
        "${REMOTE_USER}@${TARGET_HOST}" "$REMOTE_CMD"
fi
'

mkdir -p "$HOME/.local/bin"
echo "$LAUNCHER_SCRIPT" > "$HOME/.local/bin/vps-gentle"
echo "$LAUNCHER_SCRIPT" > "$HOME/.local/bin/gentle-connect"
chmod +x "$HOME/.local/bin/vps-gentle" "$HOME/.local/bin/gentle-connect"

# Crear también enlace en /usr/local/bin para disponibilidad global de todos los usuarios
if sudo cp "$HOME/.local/bin/gentle-connect" /usr/local/bin/gentle-connect 2>/dev/null; then
    sudo chmod +x /usr/local/bin/gentle-connect
    sudo cp "$HOME/.local/bin/vps-gentle" /usr/local/bin/vps-gentle 2>/dev/null || true
fi

echo ""
echo -e "${GREEN}==========================================================${NC}"
echo -e "${GREEN}  ¡INSTALACIÓN Y PRECONFIGURACIÓN COMPLETADA CON ÉXITO!   ${NC}"
echo -e "${GREEN}==========================================================${NC}"
echo ""
echo -e "Para conectarte a tu VPS en cualquier momento, simplemente escribe:"
echo -e "   ${ROSE}gentle-connect${NC}   o   ${ROSE}vps-gentle${NC}"
echo ""
echo -e "Detalles de conexión preconfigurados:"
echo -e " - Host WireGuard: ${BLUE}10.8.0.1${NC} (prioritario)"
echo -e " - Host Público:   ${BLUE}YOUR_VPS_IP${NC} (fallback automático)"
echo -e " - Puerto SSH:     ${BLUE}22${NC}"
echo -e " - Puerto ET:      ${BLUE}2022${NC}"
echo -e " - Provider LLM:   ${BLUE}FreeLLMAPI (omni.carmayn8n.cloud)${NC}"
echo ""
