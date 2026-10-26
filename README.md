# gentelIA — Copia de seguridad del entorno OpenCode (VPS)

Copia del **script actual del lanzador de OpenCode** y de **toda la documentación
e infraestructura asociada** que corre en esta VPS (`your-user`).

> Snapshot tomado el 2026-10-24. Solo lectura/copia: no sustituye los archivos
> originales en producción.

## Contenido

```
gentelIA/
├── README.md                      <- este índice
├── scripts/
│   ├── vps-tunnel                 <- LANZADOR principal de OpenCode Web (menú + túnel SSH)
│   └── opencode-quota-widget/
│       ├── injector.mjs           <- inyector del widget de cuota (Node)
│       └── _quota_widget.js       <- UI/JS del widget de cuota
├── config/
│   ├── opencode.json              <- configuración activa de OpenCode (providers/modelos)
│   └── systemd/
│       ├── opencode-server.service        <- backend opencode web (puerto 4096)
│       └── opencode-quota-widget.service  <- servicio del widget de cuota
└── docs/
    ├── CONEXION_VPS_README.md            <- guía completa de conexión a la VPS
    ├── CONVENCIONES_VPS.md               <- estándares, puertos y servicios del VPS
    ├── GUIA_DESARROLLO_EMPRESARIAL.md    <- método de trabajo asistido por IA
    ├── setup-opencode-antigravity.md     <- configuración histórica OpenCode + Antigravity
    └── windows/
        ├── setup_windows.ps1             <- instalación del túnel en Windows (PowerShell)
        └── setup_windows.bat             <- lanzador de setup_windows.ps1
```

## Arquitectura (resumen)

- **TUI de OpenCode** corre en el PC del usuario (`opencode attach`) a través de un
  túnel SSH.
- **Backend OpenCode Web** (`opencode web`) corre en la VPS como servicio systemd
  de usuario: `opencode-server.service`, escuchando en `127.0.0.1:4096`.
- **Todas** las llamadas a IA/MCP/archivos se ejecutan en el servidor.
- El script `vps-tunnel` ofrece menú de: reconectar sesiones activas, iniciar en un
  proyecto, crear proyecto nuevo y salir. Usa WireGuard (`10.8.0.1`) como primera
  opción y cae a la IP pública (`YOUR_VPS_IP`) como respaldo.

## Datos de conexión

| Dato | Valor |
|---|---|
| SSH | `your-user@YOUR_VPS_IP` (puerto `22`) |
| SSH por WireGuard | `your-user@10.8.0.1` (puerto `22`) |
| OpenCode Web | `127.0.0.1:4096` (tunelado) |
| Usuario OpenCode | `asere` |
| Password OpenCode | `YOUR_OPENCODE_PASSWORD` |

## Uso rápido

```bash
# En el PC (ya instalado en PATH)
vps-tunnel

# Directo en la VPS
opencode web --port 4096 --hostname 127.0.0.1
```

## Restauración

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
