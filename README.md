# Gentle IA — Framework de Infraestructura y Desarrollo Remoto Asistido por IA

**Gentle IA** es una suite de herramientas, lanzadores y configuraciones para conectar clientes locales (Linux, Windows, macOS) con un entorno de desarrollo remoto de ultra-baja latencia en un servidor VPS dedicado, maximizando la productividad en ingeniería de software asistida por IA.

Integra en un único flujo de trabajo:
- **TUI & Web AI Agents:** Túneles seguros para OpenCode y agentes autónomos remotos.
- **Gentle Shell:** Sesiones persistentes de desarrollo asistido con **Tmux** y **Eternal Terminal (ET)** para reconexión instantánea a 0ms sin pérdida de contexto ante cortes de red.
- **Failover Dinámico de Conexión:** Conmutación automática e inteligente entre red interna WireGuard y fallback SSH.
- **Integración con Gateways LLM:** Consumo centralizado de modelos de lenguaje mediante endpoints y proxies locales.

---

## 🏗️ Arquitectura del Sistema

```text
  [ Cliente Local (Windows / Linux / macOS) ]
                      │
           ┌──────────┴──────────┐
           ▼                     ▼
     [ WireGuard ]         [ SSH / ET ]
    (Ruta Primaria)       (Ruta Fallback)
           │                     │
           └──────────┬──────────┘
                      ▼
             [ Servidor VPS ]
      ┌───────────────────────────────┐
      │ • Eternal Terminal Server     │
      │ • Tmux Workspace Sessions     │
      │ • OpenCode AI Server (:4096)  │
      │ • FreeLLMAPI Gateway (:3005)  │
      └───────────────────────────────┘
```

## 📁 Estructura del Repositorio

```
gentelIA/
├── README.md                          <- Documentación maestra
├── scripts/
│   ├── vps-tunnel                     <- Lanzador interactivo cliente (OpenCode / Gentle Shell)
│   ├── vps-gentle-menu.sh             <- Gestor interactivo de sesiones Tmux en el VPS
│   ├── install-ubuntu-client.sh       <- Script de aprovisionamiento para clientes Ubuntu
│   └── opencode-quota-widget/         <- Widget de métricas y cuotas en tiempo real
├── config/
│   ├── opencode.json                  <- Plantilla de configuración de proveedores y modelos
│   └── systemd/                       <- Unidades de servicio systemd para demonios remotos
│       ├── opencode-server.service
│       ├── etserver.service
│       └── opencode-quota-widget.service
└── docs/
    ├── GUIA_COMPLETA_GENTLE_SHELL.md  <- Guía de terminal persistente con Eternal Terminal
    ├── GUIA_DESARROLLO_EMPRESARIAL.md <- Metodología SDD (Spec-Driven Development)
    ├── CONVENCIONES_VPS.md            <- Estándares y matriz de infraestructura
    └── windows/                       <- Scripts de aprovisionamiento para clientes Windows
```

## 🚀 Puesta en Marcha Rápida

### 1. Requisitos Previos
- Servidor VPS con Linux (Ubuntu/Debian recomendado).
- Cliente local con SSH o WireGuard.

### 2. Configuración de Variables
Edita las plantillas con tus datos antes de ejecutar los lanzadores:
- `YOUR_VPS_IP`: Dirección IP pública de tu servidor.
- `YOUR_SSH_PORT`: Puerto SSH (por defecto `22` o puerto personalizado).
- `YOUR_USER`: Usuario en el servidor remoto.
- `YOUR_OPENCODE_PASSWORD`: Contraseña asignada para la autenticación web de OpenCode.

### 3. Conexión desde el Cliente
En Linux/macOS:
```bash
./scripts/vps-tunnel
```
En Windows (PowerShell / CMD):
```cmd
cd docs/windows
conectar_gentle.bat
```

---

## 🛡️ Licencia y Propósito
Este repositorio se publica como referencia técnica y plantilla de arquitectura para desarrolladores que buscan implementar estaciones de trabajo de desarrollo con IA en servidores remotos sin latencia y con tolerancia a desconexiones.

Para restaurar en la VPS desde esta copia:

```bash
cp gentelIA/scripts/vps-tunnel              ~/IA/vps-tunnel
cp gentelIA/config/opencode.json            ~/.config/opencode/opencode.json
cp gentelIA/config/systemd/*.service        ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user restart opencode-server opencode-quota-widget
```

> **Nota:** `config/opencode.json` contiene claves de proveedores. Trátalo como
> secreto y no lo subas a repositorios públicos.