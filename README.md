# gentelIA — Entorno Remoto de Desarrollo de IA (Gentle Shell & OpenCode)

Repositorio central de herramientas, scripts lanzadores, configuración de servicios e infraestructura para trabajar remotamente sobre la VPS (`YOUR_VPS_IP` / `10.8.0.1`) con **Gentle Shell v4.3.0** y **OpenCode Web**.

---

## 📚 Documentación Principal

- **[🌹 GUÍA COMPLETA DE GENTLE SHELL](docs/GUIA_COMPLETA_GENTLE_SHELL.md)**: Manual exhaustivo de uso, filosofía ODD, RDD, atajos de teclado (`Alt+G`, `Alt+A`, `Alt+K`), modos de permisos (YOLO) y subagentes.
- **[⚡ GUÍA DE ETERNAL TERMINAL (ET)](docs/GENTLE_SHELL_ET_README.md)**: Arquitectura de conexión remota de ultra-baja latencia sin lag de teclado ni cortes.
- **[💻 GUÍA PORTABLE WINDOWS SIN WSL](docs/windows/PORTABLE_README.md)**: Conexión inmediata desde Windows con doble clic usando `conectar_gentle.bat`.
- **[🐧 INSTALACIÓN CLIENTE UBUNTU](docs/INSTALACION_CLIENTE_UBUNTU.md)**: Instalador automatizado en un solo comando para Ubuntu 22.04 LTS.
- **[🌐 API DE FREELLMAPI](FREELLM_API_ACCESO.md)**: Credenciales de inferencia, modelos disponibles y ejemplos en Python/cURL.
- **[📜 CONVENCIONES Y SERVICIOS DEL VPS](docs/CONVENCIONES_VPS.md)**: Puertos abiertos, microservicios compartidos y estándares de ingeniería.

---

## 🚀 Uso Rápido según tu Máquina

### Desde Linux / macOS:
```bash
# Para Gentle Shell (con reconexión automática y latencia cero):
vps-gentle
# (o también: gentle-connect)

# Para OpenCode Web (modo attach):
vps-tunnel
```

### Desde Windows:
- Entra a `docs/windows/` y haz doble clic en **`conectar_gentle.bat`**.

---

## 🗂️ Estructura del Repositorio

```text
gentelIA/
├── README.md                              <- Este índice principal
├── FREELLM_API_ACCESO.md                  <- Documentación y API Key de FreeLLMAPI
├── scripts/
│   ├── vps-gentle                         <- Lanzador cliente de Gentle Shell (Linux/macOS)
│   ├── vps-gentle-menu.sh                 <- Gestor de sesiones de proyectos en la VPS
│   ├── vps-tunnel                         <- Lanzador cliente de OpenCode Web
│   ├── install-ubuntu-client.sh           <- Instalador automatizado para Ubuntu 22.04
│   └── opencode-quota-widget/             <- Inyector de cuotas para OpenCode
├── config/
│   ├── opencode.json                      <- Configuración activa de OpenCode
│   └── systemd/                           <- Servicios systemd de usuario (etserver, opencode)
└── docs/
    ├── GUIA_COMPLETA_GENTLE_SHELL.md      <- Guía completa de uso de Gentle Shell
    ├── GENTLE_SHELL_ET_README.md          <- Guía técnica de Eternal Terminal (ET)
    ├── INSTALACION_CLIENTE_UBUNTU.md      <- Instrucciones de instalación en Ubuntu
    ├── CONEXION_VPS_README.md             <- Guía general de conexión a la VPS
    ├── CONVENCIONES_VPS.md                <- Estándares y puertos del servidor
    ├── GUIA_DESARROLLO_EMPRESARIAL.md     <- Metodología SDD de trabajo asistido por IA
    └── windows/                           <- Entorno 100% portable para Windows sin WSL
        ├── conectar_gentle.bat            <- Lanzador Windows (doble clic)
        ├── et-client/et.exe               <- Binario nativo Windows x64 de Eternal Terminal
        ├── wg0.conf                       <- Configuración WireGuard Windows
        └── PORTABLE_README.md             <- Manual de uso en Windows
```
