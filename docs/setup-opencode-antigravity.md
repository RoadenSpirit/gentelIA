# Configurar OpenCode para usar Antigravity Proxy

## Contexto

OpenCode está corriendo actualmente con MCP servers (engram, n8n-mcp).
El proxy `antigravity-proxy` ya está clonado en `~/proyectos/antigravity-proxy/`.
El token OAuth de agy ya existe y está activo en `~/.gemini/antigravity-cli/antigravity-oauth-token`.
Python 3.13.5 y agy 1.1.2 están instalados.

## Objetivo

1. Configurar el proxy como servicio systemd para que corra en background
2. Agregar el provider `antigravity-proxy` a la config de OpenCode SIN modificar la sección MCP existente
3. Verificar que todo funciona

---

## Paso 1: Configurar el servicio systemd

El archivo del servicio ya existe en `~/proyectos/antigravity-proxy/antigravity-proxy.service`.

Ejecutar estos comandos:

```bash
mkdir -p ~/.config/systemd/user
cp ~/proyectos/antigravity-proxy/antigravity-proxy.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable antigravity-proxy
systemctl --user start antigravity-proxy
systemctl --user status antigravity-proxy
```

Verificar que el proxy responde:

```bash
curl -s http://127.0.0.1:8877/health
```

Esperado: `{"status": "ok", "service": "antigravity-proxy"}`

---

## Paso 2: Actualizar la config de OpenCode

**IMPORTANTE**: El archivo a modificar es `~/.config/opencode/opencode.json`.
Se debe AGREGAR la sección `provider` y `model` SIN TOCAR la sección `mcp`.

El contenido ACTUAL del archivo es:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "engram": {
      "command": [
        "/usr/local/bin/engram",
        "mcp",
        "--tools=agent"
      ],
      "enabled": true,
      "type": "local"
    },
    "n8n-mcp": {
      "command": [
        "npx",
        "-y",
        "n8n-mcp@latest"
      ],
      "env": {
        "N8N_API_URL": "https://carmayn8n.cloud",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MWVlMmYzOC1hM2ZjLTRiMDAtYjg4My02MGNjYTNkOTJjNTgiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiYTkwZWI3YmMtMzQwNC00YzQ5LWJkNzMtNDZmZmU5ZTFmMzk2IiwiaWF0IjoxNzg0MTM5NTAwfQ.g64Z2RKetsZ9BURvMFCe2gK-_oZGj3X3YbDaQyQViAY",
        "MCP_MODE": "stdio",
        "MCP_LOG_LEVEL": "info",
        "WEBHOOK_SECURITY_MODE": "moderate"
      },
      "enabled": true,
      "type": "local"
    }
  }
}
```

El contenido NUEVO debe ser (agregando `provider`, `model` y `small_model`):

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "antigravity-proxy": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Antigravity (Gemini/Claude)",
      "options": {
        "baseURL": "http://127.0.0.1:8877/v1",
        "apiKey": "antigravity"
      },
      "models": {
        "gemini-3.5-flash": {
          "name": "Gemini 3.5 Flash",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 1048576, "output": 65536 }
        },
        "gemini-3.1-pro-high": {
          "name": "Gemini 3.1 Pro High",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 1048576, "output": 65535 }
        },
        "gemini-3-flash": {
          "name": "Gemini 3 Flash",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 1048576, "output": 65536 }
        },
        "claude-sonnet-4.6": {
          "name": "Claude Sonnet 4.6",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 200000, "output": 64000 }
        },
        "claude-opus-4.6": {
          "name": "Claude Opus 4.6 Thinking",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 200000, "output": 64000 }
        },
        "gpt-oss-120b": {
          "name": "GPT-OSS 120B Medium",
          "modalities": { "input": ["text", "image"], "output": ["text"] },
          "limit": { "context": 128000, "output": 16384 }
        }
      }
    }
  },
  "model": "antigravity-proxy/gemini-3.5-flash",
  "small_model": "antigravity-proxy/gemini-3-flash",
  "mcp": {
    "engram": {
      "command": [
        "/usr/local/bin/engram",
        "mcp",
        "--tools=agent"
      ],
      "enabled": true,
      "type": "local"
    },
    "n8n-mcp": {
      "command": [
        "npx",
        "-y",
        "n8n-mcp@latest"
      ],
      "env": {
        "N8N_API_URL": "https://carmayn8n.cloud",
        "N8N_API_KEY": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1MWVlMmYzOC1hM2ZjLTRiMDAtYjg4My02MGNjYTNkOTJjNTgiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwianRpIjoiYTkwZWI3YmMtMzQwNC00YzQ5LWJkNzMtNDZmZmU5ZTFmMzk2IiwiaWF0IjoxNzg0MTM5NTAwfQ.g64Z2RKetsZ9BURvMFCe2gK-_oZGj3X3YbDaQyQViAY",
        "MCP_MODE": "stdio",
        "MCP_LOG_LEVEL": "info",
        "WEBHOOK_SECURITY_MODE": "moderate"
      },
      "enabled": true,
      "type": "local"
    }
  }
}
```

Usar `write` tool para reemplazar el archivo completo. NO usar `edit` porque es más seguro reescribir el archivo completo preservando todo.

---

## Paso 3: Verificar la configuración

```bash
# Verificar que el JSON es válido
python3 -c "import json; json.load(open('/home/your-user/.config/opencode/opencode.json')); print('JSON valido')"

# Verificar que el proxy sigue corriendo
curl -s http://127.0.0.1:8877/health

# Listar modelos disponibles en el proxy
curl -s http://127.0.0.1:8877/v1/models | python3 -m json.tool
```

---

## Paso 4: Informar al usuario

Una vez completados los pasos, informar:

1. El proxy está corriendo como servicio systemd
2. La config de OpenCode fue actualizada con el provider antigravity-proxy
3. Los MCP servers (engram, n8n-mcp) se mantienen intactos
4. Para usar: reiniciar OpenCode y ejecutar `/models` para seleccionar el modelo
5. Para cambiar entre Antigravity y OpenCode Zen: usar `/models` en el TUI

---

## Comandos de gestión útiles (para reference futura)

```bash
# Estado del proxy
systemctl --user status antigravity-proxy

# Reiniciar proxy
systemctl --user restart antigravity-proxy

# Ver logs
journalctl --user -u antigravity-proxy -f

# Re-autenticar si el token expira
agy && systemctl --user restart antigravity-proxy

# Modelos disponibles
curl -s http://127.0.0.1:8877/v1/models
```
