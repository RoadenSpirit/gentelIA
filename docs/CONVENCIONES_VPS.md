# 🚀 Convenciones, Estándares e Infraestructura del VPS

Este documento establece las pautas oficiales, mapa de puertos, servicios compartidos y la arquitectura unificada para todos los proyectos hospedados en este VPS (`your-user`).

---

## 🛠️ 1. Mapa de Servicios y Puertos en el VPS

Todos los proyectos y microservicios deben respetar la asignación de puertos y dominios administrados por **Caddy**:

| Servicio / Aplicación | Puerto Local | Tipo | Dominio / URL Caddy | Descripción |
| :--- | :--- | :--- | :--- | :--- |
| **Baileys WhatsApp API** | `localhost:3000` | Docker (`baileys-sales-api`) | `ia.carmayn8n.cloud/api/wa/*` | API HTTP REST de WhatsApp basada en Baileys. |
| **n8n Community** | `localhost:5678` | Docker (`n8n-app` + `n8n-postgres`) | `carmayn8n.cloud` | Plataforma de automatización y flujos de trabajo. |
| **AsereAI API** | `localhost:8000` | systemd (`uvicorn` FastAPI) | `asere.carmayn8n.cloud`, `ia.carmayn8n.cloud/api` | Core Backend de inteligencia artificial y scraping. |
| **OmniRoute Proxy** | `localhost:20128` | process (`omniroute`) | `omni.carmayn8n.cloud` | Proxy unificador de proveedores y modelos LLM. |
| **Antigravity Direct Proxy** | `localhost:8080` | systemd (`antigravity-direct-proxy`) | `localhost-only` | Proxy OAuth para llamadas CLI y endpoints IA. |
| **OpenCode Web** | `localhost:4096` | systemd (`opencode-server`) | `opencode.carmayn8n.cloud` | Servidor Web y CLI interactivo para desarrollo. |
| **VPS Control Panel** | `localhost:4321` | systemd (`vps-control`) | `localhost:4321` | Panel de control Astro SSR para gestión del servidor. |
| **Asere Admin Web** | `localhost:3001` | Estático / Caddy | `asere.carmayn8n.cloud/admin` | Panel de administración de AsereAI. |
| **Asere Web App** | `localhost:3100` | Estático / Caddy | `ia.carmayn8n.cloud/app` | Aplicación cliente de AsereAI. |

---

## 🔗 2. Dependencias Compartidas y Métodos de Acceso

### A. API de WhatsApp (Baileys)
- **Endpoint interno:** `http://localhost:3000`
- **Autenticación:** Requiere header `x-api-key`.
- **Uso:** Empleado por `whatsappAPI`, webhooks de `n8n`, bot de Telegram y flujos de automatización.

### B. Scraping, Automatización y Certificación Visual (Playwright)
- **Contenedor Oficial para Ejecución:** Contenedor Docker `n8n-app` (`docker exec n8n-app ...`).
- **Binario Chromium Validado:** `/usr/bin/chromium` (dentro del contenedor `n8n-app`, versión 148+ con todas las librerías gráficas de Debian `bookworm` preinstaladas: `X11`, `GTK-3`, `cairo`, `dbus`).
- **Instalación de paquetes en el Host:** **PROHIBIDA**. El host VPS carece intencionalmente de paquetes gráficos y librerías de escritorio (`libnspr4`, `libX11`, etc.) para ahorrar memoria RAM (< 4GB). Todo script o test Playwright/Puppeteer debe invocarse exclusivamente delegando en el contenedor:
  ```bash
  docker exec n8n-app node -e '
  const { chromium } = require("playwright");
  (async () => {
    const browser = await chromium.launch({ executablePath: "/usr/bin/chromium", args: ["--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"] });
    const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
    await page.goto("URL", { waitUntil: "networkidle" });
    await page.screenshot({ path: "/tmp/cert.png" });
    await browser.close();
  })();
  '
  # Copiar captura al host:
  docker cp n8n-app:/tmp/cert.png /tmp/opencode/
  ```
- **Uso Compartido:** Validación visual SDD de frontends, extracción de datos, `ExtraerFacebook` y nodos de automatización n8n.

### C. n8n Automation Engine
- **Endpoint interno:** `http://localhost:5678`
- **Red Docker:** `n8n-carmay_default` (permite comunicación directa por nombre de contenedor entre `baileys-sales-api` y `n8n-app`).

---

## 🧠 3. Arquitectura Unificada de Skills y MCPs

### MCPs Globales (Single Source of Truth)
- **Ubicación:** `~/.config/opencode/opencode.json`
- **Regla:** Ningún proyecto debe crear archivos `mcp_config.json` locales. Todos los servidores MCP (`engram`, `n8n_mcp`, etc.) se registran centralizadamente en `opencode.json`.

### Skills Centralizadas (Repositorio Único)
- **Biblioteca canónica:** `/home/your-user/.config/opencode/skills/`
- **Acceso por Proyecto:** Cada proyecto en `/home/your-user/proyectos/` accede a los skills mediante un enlace simbólico automático:
  ```bash
  /home/your-user/proyectos/<MiProyecto>/.agents/skills -> /home/your-user/.config/opencode/skills
  ```
- **Ventaja:** Cero duplicación de disco, actualizaciones de skills en tiempo real para todos los proyectos.

---

## 🧹 4. Gestor de Recursos y Políticas del VPS

- **RAM Total:** 3.8 GiB (Límite crítico).
- **Prohibición:** No dejar servidores dev (`astro dev`, `vite`, `next dev`) ejecutándose en background en proyectos que no estén activamente en desarrollo.
- **TTL de Caché de 1 Hora:**
  - Timer activo: `systemctl --user list-timers` (`vps-cleanup.timer`).
  - Script: `/home/your-user/scripts/vps_cleanup_hourly.sh`.
  - Acción: Borra automáticamente archivos temporales `/tmp`, caché de npm (`_cacache`) e imágenes huérfanas de Docker con más de 60 minutos de vida.

---

## 📂 5. Reglas para Crear Nuevos Proyectos

1. **Ubicación:** Todo proyecto debe alojarse dentro de `/home/your-user/proyectos/<NombreDescriptivo>`.
2. **Nombre:** Prohibido nombres genéricos como `nuevo_proyecto`, `prueba`, `test1`. Debe reflejar el nombre del producto (ejemplo: `VitroArte`, `CarmayWeb`).
3. **Control de Versiones:** Debe inicializarse Git (`git init`) y configurarse remoto GitHub.
4. **Vínculo de Skills:** Ejecutar el enlace simbólico hacia las skills globales al crear la carpeta del proyecto:
   ```bash
   mkdir -p .agents && ln -s /home/your-user/.config/opencode/skills .agents/skills
   ```
