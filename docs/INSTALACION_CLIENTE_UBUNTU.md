# INSTALACIÓN AUTOMATIZADA EN CLIENTES UBUNTU 22.04

Este instalador deja cualquier máquina con **Ubuntu 22.04 LTS** (o derivados como Linux Mint, Pop!_OS, Debian) lista con todas las herramientas, Eternal Terminal (ET) y el comando global `gentle-connect` configurado contra tu VPS.

---

## ⚡ Instalación en 1 Línea de Comando

Abre la terminal en tu máquina con Ubuntu y ejecuta:

```bash
curl -fsSL https://raw.githubusercontent.com/RoadenSpirit/gentelIA/main/scripts/install-ubuntu-client.sh | bash
```

*(O si ya clonaste el repositorio en tu PC:)*
```bash
chmod +x scripts/install-ubuntu-client.sh
./scripts/install-ubuntu-client.sh
```

---

## 🛠️ ¿Qué hace este instalador automáticamente?

1. **Paquetes Base:** Instala `curl`, `git`, `software-properties-common` y `wireguard-tools`.
2. **Eternal Terminal (ET):** Añade el PPA oficial de Ubuntu (`ppa:jgmath2000/et`) e instala `et` para conexión de ultra-baja latencia y reconexión automática ante cortes.
3. **Node.js v22 LTS:** Comprueba si existe Node >= 22; si no existe, instala la versión oficial LTS desde NodeSource.
4. **Preconfiguración FreeLLMAPI:** Registra tu endpoint de inferencia (`https://omni.carmayn8n.cloud/v1`) con tu API Key segura en `~/.gentle-shell/agent/models.json` y `~/.pi/agent/models.json`.
5. **Comando Global de Conexión:** Instala en `/usr/local/bin/gentle-connect` y `~/.local/bin/gentle-connect` el lanzador conmutador (WireGuard `10.8.0.1:2022` $\leftrightarrow$ IP pública `YOUR_VPS_IP:2022`).

---

## 🚀 Cómo Conectarse Tras la Instalación

Simplemente escribe en cualquier terminal:

```bash
gentle-connect
```
*(o también `vps-gentle`)*.

El sistema te mostrará de inmediato el menú de proyectos de Gentle Shell en tu VPS.
