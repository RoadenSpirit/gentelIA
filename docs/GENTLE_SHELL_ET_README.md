# GENTLE SHELL CON ETERNAL TERMINAL (ET) — GUÍA DE CONEXIÓN Y OPERACIÓN

Esta guía detalla la arquitectura completa de conexión remota de ultra-baja latencia para **Gentle Shell v4.3.0** sobre **Pi v1.4.0**, utilizando **Eternal Terminal (ET v7.0.0)** y **Tmux** en tu VPS (`YOUR_VPS_IP` / `10.8.0.1`).

---

## 1. ¿Por qué Eternal Terminal (ET) y cómo resuelve la latencia?

En conexiones con alta latencia (300ms a 600ms), el SSH tradicional y Tmux resultan lentos porque cada pulsación de tecla espera el eco de red del servidor antes de pintarse.

**Eternal Terminal resuelve esto mediante:**
1. **Canal TCP dedicado con reconexión instantánea:** Tras autenticarse por SSH (puerto 22), la sesión pasa al demonio `etserver` (puerto 2022).
2. **Inmunidad a caídas de red:** Si tu conexión a internet parpadea, cambias de Wi-Fi a datos o cierras la laptop, la sesión **NO muere**. Al recuperar red, se reconecta en milisegundos en el punto exacto donde estabas.
3. **Fidelidad TUI 100%:** Soporta el 100% de TrueColor (24 bits), rueda de ratón para scrolling y los atajos de teclado nativos de Gentle Shell (`Alt+G`, `Alt+A`, `Alt+K`), sin las limitaciones de Mosh.

---

## 2. Control de Recursos y Memoria RAM en el VPS (Telemetría en Vivo)

Medición real registrada en el servidor con sesión activa en `n8nCarmay`:
- **`etserver` (Daemon del sistema):** **`2.1 MB` de RAM** (escuchando en `TCP 2022`).
- **`tmux` (Servidor de sesiones):** **`~4.5 MB` de RAM**.
- **`gentle-shell` + `pi` (Sesión activa en proyecto):** **`~346 MB` de RAM** (frente a los **`1,227 MB`** que consume solo Op3nCode Server en reposo).
- **Margen de RAM Libre en el VPS:** **`1.0 GB disponible`** (sin riesgo de colapso por memoria).
- **Espacio en Disco:** **`9.3 GB disponibles` (81% de uso)** en `/dev/sda1`.

---

## 3. Conexión desde tu PC Cliente

### A. Desde Windows (Doble Clic Nativo)
Hemos empaquetado el cliente oficial `et.exe` directamente dentro de esta carpeta:
1. Copia la carpeta `docs/windows/` a tu PC de Windows.
2. Asegúrate de tener WireGuard activo (IP `10.8.0.2` conectada a `10.8.0.1`).
3. Haz doble clic en **`conectar_gentle.bat`**.
   - El script detecta `et-client\et.exe` y se conecta directamente al VPS.
   - Si no detectara `et.exe`, hace fallback automático a SSH optimizado con `TCP_NODELAY`.

### B. Desde Linux (Ubuntu / Debian / Arch / Fedora) o macOS
En tu terminal local:
```bash
# 1. Si no lo has descargado aún:
scp -P 22 your-user@YOUR_VPS_IP:/home/your-user/proyectos/gentelIA/scripts/vps-gentle ./vps-gentle
chmod +x ./vps-gentle

# 2. Ejecutar:
./vps-gentle
```
El script detecta la ruta más rápida (WireGuard `10.8.0.1:2022` o IP pública `YOUR_VPS_IP:2022`), pasando los parámetros exactos:
`et -u your-user --port 2022 --ssh-option "Port=22" --terminal-path /home/your-user/.local/bin/etterminal $TARGET_HOST -c /home/your-user/scripts/vps-gentle-menu.sh`

---

## 4. El Menú de Sesiones en el Servidor (`vps-gentle-menu.sh`)

Al conectar, el servidor te recibe con un menú interactivo:
```text
==========================================================
       GENTLE SHELL — GESTOR DE SESIONES VPS (ET)         
==========================================================
  Node: v22.23.4 (Parche Seguridad) · Pi: 1.4.0 · Gentle: 4.3.0
  Provider: FreeLLMAPI (http://127.0.0.1:3005/v1)
==========================================================

--- 🟢 SESIONES ACTIVAS DE GENTLE SHELL ---
  [1] - Reconectar a: n8nCarmay (tmux: gentle-n8nCarmay)

--- 📁 PROYECTOS DISPONIBLES EN ~/proyectos ---
  [2] - Iniciar en: gentelIA
  [3] - Iniciar en: AsereAI
  [4] - Iniciar en: vps-control
  [5] - Iniciar en: webIA

--- ⚙️  OPCIONES GENERALES ---
  [6] - NUEVO PROYECTO (crea nueva carpeta y arranca)
  [0] - Salir de la terminal
==========================================================
```

### Reglas de Gestión de Proyectos:
1. **Unicidad:** Cada proyecto tiene como máximo **UNA sola instancia activa**. Si ya está corriendo, el menú te ofrece "Reconectar a..." para evitar duplicar memoria en el VPS.
2. **Persistencia:** Si sales de tu terminal con `Ctrl+B d` (detach) o se apaga tu equipo, la sesión de Gentle Shell sigue viva ejecutando código o subagentes en la VPS. Al reconectar, vuelves a ella de inmediato.

---

## 5. Configuración de Modelos y FreeLLMAPI

Gentle Shell está configurado de forma nativa para enrutar todas las consultas hacia FreeLLMAPI localmente en la VPS:
- **Base URL:** `http://127.0.0.1:3005/v1`
- **API Key:** `sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4` (Client Profile de inferencia seguro).
- **Archivos de configuración:**
  - `~/.gentle-shell/agent/models.json`
  - `~/.gentle-shell/agent/settings.json`
- **Modelo por defecto:** `auto` (enrutamiento dinámico Bandit según rendimiento).

---

## 6. Atajos de Teclado Esenciales en Gentle Shell

| Atajo | Acción en Gentle Shell |
|---|---|
| **`Alt + G`** | **Gentle Changes:** Visor interactivo a pantalla completa de diffs Git en todos los worktrees. |
| **`Alt + A`** | **Gentle Agents:** Panel en vivo de subagentes activos, tokens, costos y tiempo de ejecución. |
| **`Alt + K`** | **Command Palette:** Menú flotante de búsqueda rápida de comandos y herramientas. |
| **`/gentle:customize`** | Abre el panel visual para cambiar temas, colores de rosa, estilos de tarjetas (`neon`/`float`) y notificaciones de sonido. |
| **`/gentle:yolo enable`** | Activa el modo YOLO (permisos automáticos para tareas ya acotadas, manteniendo confirmación para acciones destructivas). |
| **`Ctrl + B d`** | Desconectar (detach) de la sesión de Tmux dejando Gentle Shell corriendo en la VPS. |
