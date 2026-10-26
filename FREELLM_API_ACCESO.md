# ARQUITECTURA DE CONEXIÓN REMOTA — OPENCODE TUI ATTACH & FREELLMAPI

Este documento recopila de manera integral y exhaustiva la arquitectura técnica con la cual interactúas con tu VPS (`YOUR_VPS_IP`), el mecanismo exacto de túneles y adjuntado (`attach`) de la interfaz TUI local contra el backend remoto, y la exposición de la API de FreeLLM para consumo externo.

---

## 1. El Flujo de Trabajo Real: Attach Local de TUI sobre Backend Remoto

La interacción con OpenCode **NO es una sesión SSH típica con terminal remota** ni una simple página web. La arquitectura funciona con una **separación estricta entre presentación (TUI) y cómputo (Backend)**:

```
┌────────────────────────────────────────────────────────┐
│                   TU COMPUTADORA LOCAL                 │
│                                                        │
│  1. WireGuard VPN (wg0: 10.8.0.2 -> 10.8.0.1)          │
│  2. Túnel SSH / AutoSSH permanente en background:      │
│     localhost:4096 <===================> VPS:4096      │
│  3. Binario opencode local ejecutando TUI:             │
│     opencode attach http://localhost:4096              │
└───────────────────────────┬────────────────────────────┘
                            │  Túnel SSH / WireGuard
                            ▼
┌────────────────────────────────────────────────────────┐
│                      VPS REMOTA                        │
│                                                        │
│  1. Backend 'opencode web' (systemd :4096):            │
│     - Ejecución real del agente, plugins y terminal    │
│     - Directorio: /home/your-user/proyectos/<nombre>  │
│     - Control de sesiones por Alias (IA/aliases.sh)    │
│  2. FreeLLMAPI Unified Router (systemd :3005):         │
│     - Enrutamiento inteligente (auto, gemini, claude)  │
│  3. Antigravity Direct Proxy (systemd :8877):          │
│     - Conversión OAuth a Google Cloud Code             │
└────────────────────────────────────────────────────────┘
```

### ¿Por qué se diseñó de esta manera?
1. **Renderizado 100% nativo y fluido:**  
   La TUI (Text User Interface) se dibuja directamente en tu emulador de terminal local (Windows Terminal, Alacritty, iTerm2, etc.) usando los recursos gráficos de tu PC. No hay lag de cursor ni distorsión visual por latencia de red.
2. **Cómputo, herramientas y contexto en el servidor:**  
   Todo el código, repositorios, bash persistente en `tmux`, plugins (`sdd-governance`, `quota-monitor`), bases de datos SQLite y llamadas a la IA corren en la VPS. Tu PC local puede apagarse o desconectarse sin perder el estado de la sesión.
3. **El Lanzador Dinámico (`vps-tunnel`):**
   - **Detección inteligente de red:** Prueba primero la IP interna de WireGuard (`10.8.0.1`). Si no está activa la interfaz local `wg0`, intenta levantarla automáticamente (`wg-quick up wg0`) y, si no es posible, conmuta de forma transparente hacia la IP pública (`YOUR_VPS_IP:22`).
   - **Gestión por Alias (Llave de Sesión):** Tu PC almacena un alias persistente en `~/.config/opencode/alias.json`. La VPS a través de `~/IA/aliases.sh` aísla tus proyectos y conversaciones de otros posibles clientes.
   - **Submenú de Proyectos:** Lee dinámicamente los directorios en `/home/your-user/proyectos/`, muestra los últimos 3 chats de cada proyecto con su timestamp formateado y permite reanudar una sesión previa o inicializar un proyecto nuevo en la VPS.
   - **El comando final que ejecuta:**
     ```bash
     opencode attach \
       --username asere \
       --password 'YOUR_OPENCODE_PASSWORD' \
       --dir '/home/your-user/proyectos/<proyecto>' \
       --session <SESSION_ID> \
       http://localhost:4096
     ```

---

## 2. Acceso a FreeLLMAPI desde Agentes Externos (Internet)

FreeLLMAPI ha sido formalmente configurado y protegido para que cualquier agente externo pueda consumir los modelos de inferencia mediante HTTP/HTTPS exactamente como lo hace OpenCode, pero utilizando **API Keys dedicadas** de agente sin acceso al panel administrativo.

### Parámetros de Conexión Pública
| Parámetro | Valor |
|---|---|
| **Base URL Pública** | `https://omni.carmayn8n.cloud/v1` |
| **Base URL Local (dentro de VPS)** | `http://127.0.0.1:3005/v1` |
| **Cabecera de Autenticación** | `Authorization: Bearer <API_KEY>` (o `x-api-key: <API_KEY>`) |
| **Formato de Protocolo** | OpenAI-compatible (`/v1/chat/completions`, `/v1/models`, `/v1/responses`) |

### API Keys Disponibles
1. **API Key de Agente (Client Profile):**
   ```text
   sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4
   ```
   - **Perfil:** `agente-externo`
   - **Permisos:** Solo inferencia (`/v1/*`). No tiene acceso a `/api/*` (dashboard/keys).
   - **Seguridad:** Almacenada con hash SHA-256 y cifrado AES-256-GCM.
2. **Unified API Key Maestra (Uso interno de OpenCode):**
   ```text
   freellmapi-be8f2acb085c2a306996abf3014b9e6b5460c6e0dbfc551d
   ```

---

## 3. Catálogo de Modelos Disponibles

Puedes solicitar cualquiera de estos modelos en el payload `model`:

- **`auto`**: Enrutador heurístico Bandit. Selecciona dinámicamente el modelo con mejor tasa de éxito y menor latencia en tiempo real.
- **`gemini-3.8-flash-high`**: Gemini 3.8 Flash con razonamiento profundo (1M tokens contexto).
- **`gemini-3.8-flash-medium`**: Gemini 3.8 Flash balanceado.
- **`gemini-3.8-flash-low`**: Gemini 3.8 Flash ultrarrápido sin razonamiento extendido.
- **`gemini-4-argon`**: Gemini 4 Argon de alta capacidad de razonamiento.
- **`claude-sonnet-5-5-high`**: Claude Sonnet 5.5 High Reasoning.
- **`claude-opus-5-5-high`**: Claude Opus 5.5 High Reasoning.
- **`qwen3.8-27b`**: Qwen 3.8 27B vía Groq (soporte de visión y tools).
- **`gpt-oss-120b`**: GPT-OSS 120B vía Groq.
- **`devstral-2`**: Devstral Medium x2603 vía OrcaRouter (optimizado para código).

---

## 4. Ejemplos de Integración para Clientes y Agentes

### Opción A: Python (OpenAI SDK oficial)
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://omni.carmayn8n.cloud/v1",
    api_key="sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4"
)

response = client.chat.completions.create(
    model="auto",  # o "gemini-3.8-flash-high"
    messages=[
        {"role": "system", "content": "Eres un asistente de ingeniería útil y conciso."},
        {"role": "user", "content": "Explícame cómo funciona un túnel SSH inverso en una frase."}
    ]
)

print(response.choices[0].message.content)
```

### Opción B: TypeScript / Node.js (`@ai-sdk/openai-compatible`)
```typescript
import { createOpenAICompatible } from "@ai-sdk/openai-compatible";
import { generateText } from "ai";

const freellm = createOpenAICompatible({
  name: "freellmapi-remote",
  baseURL: "https://omni.carmayn8n.cloud/v1",
  apiKey: "sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4",
});

const { text } = await generateText({
  model: freellm("auto"),
  prompt: "Hola desde TypeScript remoto",
});

console.log(text);
```

### Opción C: cURL Directo
```bash
curl -X POST https://omni.carmayn8n.cloud/v1/chat/completions \
  -H "Authorization: Bearer sk-cp-4babb98ab0d6075aa59bca27df44613c1ed0aa4f5dc5dcc4" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "auto",
    "messages": [
      {"role": "user", "content": "Prueba de conexión exitosa"}
    ]
  }'
```

---

## 5. Gestión de API Keys en la VPS (Herramienta CLI)

En la VPS cuentas con el comando ejecutable `freellm-client` para crear, listar y revocar claves de acceso por agente de forma instantánea:

```bash
# Listar todas las llaves y agentes creados
freellm-client list

# Crear una nueva llave para otro agente o proyecto
freellm-client create "nombre-del-agente"

# Crear una llave con un System Prompt estricto forzado por servidor
freellm-client create "agente-soporte" "Instrucción fija de comportamiento"

# Revocar acceso inmediatamente a un agente (por ID)
freellm-client revoke 1

# Reactivar acceso previamente revocado
freellm-client enable 1
```

---

## 6. Estado Operativo del Servidor
- **Red y Proxy:** Configurado `TRUST_PROXY=1` en `/home/your-user/freellmapi/.env` para aislamiento individual del Rate Limit (`120 RPM`) por cada IP remota que pasa por Caddy.
- **Servicio Systemd:** `freellmapi.service` activo y vigilado en reinicio automático.
