# 🌹 GUÍA COMPLETA DE GENTLE SHELL (GENTLE-AI & PI)

Bienvenido a la guía definitiva de **Gentle Shell**, el entorno de desarrollo y orquestación de agentes de IA creado por **Alan Buscaglia (Gentleman Programming)** sobre el motor de **Pi Coding Agent**.

Gentle Shell transforma tu terminal en un espacio de trabajo de ingeniería de élite: la TUI te ofrece visibilidad total sobre qué está haciendo el agente, qué archivos modifica, qué subagentes delega y cómo se gestionan tus modelos de IA, permitiéndote **liderar el desarrollo en lugar de perseguir las respuestas de un chatbot**.

---

## 📑 Tabla de Contenidos
1. [Filosofía: Más Allá del "Vibe Coding"](#1-filosofía-más-allá-del-vibe-coding)
2. [Arquitectura y Cómo Conectarte](#2-arquitectura-y-cómo-conectarte)
3. [La Interfaz TUI y sus Componentes](#3-la-interfaz-tui-y-sus-componentes)
4. [Atajos de Teclado Esenciales](#4-atajos-de-teclado-esenciales)
5. [ODD: Organic Driven Development](#5-odd-organic-driven-development)
6. [RDD: Revisión Nativa y Evidencia](#6-rdd-revisión-nativa-y-evidencia)
7. [Modos de Permisos (Normal, Auto, YOLO)](#7-modos-de-permisos-normal-auto-yolo)
8. [Orquestación de Subagentes con Contexto](#8-orquestación-de-subagentes-con-contexto)
9. [Modelos y Conexión con FreeLLMAPI](#9-modelos-y-conexión-con-freellmapi)
10. [Herramientas, Diagnósticos y Solución de Problemas](#10-herramientas-diagnósticos-y-solución-de-problemas)

---

## 1. Filosofía: Más Allá del "Vibe Coding"

La mayoría de agentes de IA convencionales operan como chatbots que escriben código sin control: olvidan decisiones entre sesiones, no entienden las convenciones de tu proyecto y te obligan a revisar manualmente cientos de líneas de diffs desestructurados.

**Gentle Shell impone disciplina de ingeniería:**
- **El desarrollador lidera:** Tú defines el alcance; el agente explora antes de tocar código, plantea preguntas concretas y reúne evidencia auditable.
- **Memoria persistente (Engram):** Las decisiones de arquitectura, bugs resueltos y convenciones no se pierden al cerrar la sesión.
- **Cero degradación de herramientas:** Utiliza herramientas nativas de alto rendimiento (`read`, `write`, `edit`, `bash`) ejecutadas directamente en tu servidor.

---

## 2. Arquitectura y Cómo Conectarte

Toda la lógica pesada de Gentle Shell, tus repositorios de código, la memoria Engram y las llamadas a la IA corren **100% en tu servidor VPS**. Desde tu máquina personal (PC, laptop) te conectas a través de **Eternal Terminal (ET)**, un protocolo de ultra-baja latencia que elimina el retraso de tipeo y reconecta de inmediato si tu red parpadea.

```
┌────────────────────────┐                    ┌────────────────────────┐
│     TU PC CLIENTE      │    ET (TCP 2022)   │       TU SERVIDOR      │
│  (Windows/Linux/Mac)   │ ◄────────────────► │  etserver + tmux (:PTY)│
│  - Tipeo fluido a 0ms  │    SSH (Port 22)│  - Gentle Shell v4.3.0 │
│  - Reconexión sin corte│                    │  - FreeLLMAPI (:3005)  │
└────────────────────────┘                    └────────────────────────┘
```

### Cómo entrar según tu sistema:

### A. Desde Linux (Ubuntu / Debian / Arch / Fedora) o macOS
Si ejecutaste el instalador o tienes el script:
```bash
# Simplemente escribe en tu consola:
gentle-connect
# (o también: ./vps-gentle)
```

### B. Desde Windows (Sin WSL, 100% Portable)
1. Entra en la carpeta `docs\windows` de este proyecto.
2. Haz doble clic en **`conectar_gentle.bat`**.
*(El script utiliza el cliente nativo `et.exe` preempaquetado y detecta automáticamente si estás dentro de WireGuard `10.8.0.1` o conectando por la IP pública `YOUR_VPS_IP`)*.

---

## 3. La Interfaz TUI y sus Componentes

Al entrar en un proyecto, verás la pantalla interactiva dividida en tres zonas principales:

```text
✿ Gentle Shell ⟡ ~/proyectos/gentelIA main ⟡ auto · high ⟡ ctx ▰▰▱▱▱▱ 35% ⟡ $0.00 sub
────────────────────────────────────────────────────────────────────────────────────────
 [Área de Conversación e Historial]                │ 🟢 Status (Rama, CWD, Sesión)
                                                   │ ✎ Changes (Archivos modificados)
                                                   │ ❀ Agents (Subagentes activos)
                                                   │ 📋 TODO (Checklist ODD)
────────────────────────────────────────────────────────────────────────────────────────
╭─ ✿ waiting for input ────────────────────────────────────────────────────────────────╮
│ Escribe tu mensaje, o usa / para comandos...                                         │
╰──────────────────────────────────────────────────────────────────────────────────────╯
```

1. **Header Superior:**
   - **Identidad:** Muestra el nombre de Gentle Shell, la ruta del proyecto (`cwd`), la rama Git y el modelo activo (`auto`, `gemini-3.8-flash-high`, etc.).
   - **Indicador de Contexto:** Una barra gráfica que mide el porcentaje de la ventana de contexto en uso. Se pone ámbar al 80% y roja al 95%.
2. **Rail Lateral Derecho:**
   - **Status:** Estado del proyecto, integraciones y extensiones cargadas.
   - **Changes:** Resumen en vivo de cuántos archivos tienen cambios Git no confirmados (`+lineas -lineas`).
   - **Agents:** Lista de subagentes activos con su consumo de tokens, costo y tiempo transcurrido.
   - **TODO:** Plan de trabajo interactivo estructurado por el flujo ODD.
3. **El Editor y el Prompt:**
   - **La Rosa (Petal):** Indica el estado del agente:
     - `waiting for input`: El agente está listo esperando tu instrucción.
     - `working` (girando): El agente está razonando o ejecutando herramientas.
     - `queued` (ámbar): Hay mensajes o tareas encoladas esperando al turno actual.

---

## 4. Atajos de Teclado Esenciales

Memoriza estos atajos; son los que hacen que trabajar en consola sea instantáneo:

| Atajo | Nombre | Acción |
| :---: | :--- | :--- |
| **`Alt + G`** | **Gentle Changes** | Abre el visor a pantalla completa de todos los cambios de Git (diffs, líneas agregadas/borradas) sin tener que hacer `git status`. |
| **`Alt + A`** | **Gentle Agents** | Abre el panel de subagentes para ver qué está explorando o escribiendo cada trabajador en segundo plano. |
| **`Alt + K`** | **Command Palette** | Abre la paleta de comandos interactiva (busca comandos como en VS Code u OpenCode). |
| **`Ctrl + B` luego `d`** | **Tmux Detach** | Desconecta tu terminal de la VPS dejando a Gentle Shell corriendo en el servidor. |
| **`Shift + Home/End`** | **Selección de texto** | Selecciona texto de la línea de comandos de forma nativa sin usar el ratón. |
| **`Ctrl + V`** | **Pegar imágenes** | Pega capturas de pantalla desde el portapapeles directamente como chips de imagen (`[Image#1]`) para modelos de visión. |

---

## 5. ODD: Organic Driven Development

**ODD** es el motor metodológico que Gentle Shell ejecuta por defecto en cada turno de trabajo. En lugar de comenzar a editar código desordenadamente, el agente sigue un ciclo orgánico de 7 pasos:

1. **Authorize (Autorizar):** El agente permanece en modo de solo lectura para preguntas, explicaciones o análisis. No toca archivos a menos que solicites explícitamente un cambio.
2. **Explore (Explorar):** Lee el código relevante, los tests existentes y los requisitos antes de emitir un juicio.
3. **Resolve Uncertainty (Resolver Incertidumbre):** Si el requerimiento es ambiguo o hay dos caminos arquitectónicos viables, te hace **una sola pregunta concreta** antes de continuar.
4. **Classify (Clasificar):**
   - **Tareas Pequeñas:** Si el cambio es pequeño, bien entendido y autocontenido, el agente lo implementa **inline** (directamente en la conversación, sin crear subagentes ni archivos pesados).
   - **Tareas Grandes:** Si el cambio involucra múltiples módulos o no se puede reanudar solo con `git diff`, activa el seguimiento formal.
5. **Track (Registrar):** Crea un documento de feature bajo `odd/tasks/<nombre-feature>.md` espejado automáticamente en la memoria de Engram.
6. **Implement (Implementar):** Ejecuta tarea por tarea aplicando TDD (Test-Driven Development) si aplica, en bloques de trabajo revisables (~400 líneas).
7. **Close (Cerrar):** Ejecuta la suite de pruebas funcionales, presenta la evidencia real y marca el cierre del objetivo.

---

## 6. RDD: Revisión Nativa y Evidencia

**RDD (Receipt-Driven Development)** es el mecanismo de verificación de Gentle Shell. Cuando un agente dice *"ya lo arreglé y las pruebas pasan"*, RDD congela el cambio y genera un recibo de evidencia verificable a través de cuatro lentes de calidad:

- 🛡️ **Risk (Riesgo):** ¿Qué componentes críticos o dependencias de seguridad se vieron afectadas?
- 🔄 **Resilience (Resiliencia):** ¿Cómo maneja los fallos en cascada, timeouts o errores de red?
- 📖 **Readability (Legibilidad):** ¿El código sigue los estándares idiomáticos del proyecto?
- ⚖️ **Reliability (Confiabilidad):** ¿Existen pruebas unitarias o de integración que certifiquen el comportamiento?

### Comandos de control de RDD:
- `/gentle:review-mode status` $\rightarrow$ Consulta si la revisión nativa está activa.
- `/gentle:review-mode disable` $\rightarrow$ Desactiva la revisión para este repositorio.
- `/gentle:review-mode enable` $\rightarrow$ Reactiva la revisión nativa.

---

## 7. Modos de Permisos (Normal, Auto, YOLO)

Puedes controlar qué tan seguido te pide confirmación el agente antes de ejecutar comandos o editar archivos:

```text
[Normal] ──(Más seguro)──► [Auto] ──(Equilibrado)──► [YOLO] ──(Máxima velocidad)
Pregunta todo              Inferencia inteligente     Permiso amplio (bloquea destructivo)
```

1. **Modo Normal (`/gentle:mode normal`):**  
   Comportamiento clásico; te pide confirmación para comandos de terminal potencialmente sensibles o escrituras fuera de contexto.
2. **Modo Auto (`/gentle:mode auto`):**  
   El agente evalúa internamente el contexto de la tarea: si una acción es segura y estándar para el objetivo que pediste, la ejecuta directamente; si detecta anomalías, se detiene y pregunta.
3. **Modo YOLO (`/gentle:yolo enable`):**  
   **Recomendado para sesiones de desarrollo largas y autónomas.**  
   Concede permiso permanente para lecturas, escrituras, compilaciones, creación de commits y ramas sin interrupciones constantes.  
   ⚠️ **Seguridad Garantizada:** Incluso con YOLO activo, las operaciones verdaderamente destructivas (`rm -rf`, borrado de ramas principales, sobrescritura de secretos `.env`) **SIEMPRE exigirán tu confirmación manual**.

Para apagar el modo YOLO: `/gentle:yolo disable`.

---

## 8. Orquestación de Subagentes con Contexto

Cuando una tarea es compleja, Gentle Shell delega trabajo a subagentes especializados sin perder el hilo de la conversación principal:

- **`gentle-ai-explore` (Explorador):** Un subagente de solo lectura que analiza el repositorio, busca archivos y devuelve un mapa resumido con referencias `archivo:línea`.
- **`gentle-ai-worker` (Trabajador):** Un subagente enfocado en implementar un módulo específico dentro de su propia superficie de edición.
- **Subagentes en Paralelo:** Si hay dos tareas independientes (ej: actualizar el frontend y crear una migración de base de datos), el orquestador puede lanzarlos simultáneamente.

### Cómo interactuar con los subagentes:
- Pulsa **`Alt + A`** en cualquier momento para ver la lista de tareas en ejecución, el modelo que usa cada una, los tokens consumidos y su estado.
- Las tareas en segundo plano te notifican al completarse creando una tarjeta en el historial sin interrumpir lo que estés escribiendo.

---

## 9. Modelos y Conexión con FreeLLMAPI

Gentle Shell en tu VPS está preconfigurado para enrutar todas sus llamadas hacia tu gateway unificado de **FreeLLMAPI** (`http://127.0.0.1:3005/v1`) con tu clave de agente segura.

### Catálogo de Modelos Listos para Usar:
- **`auto` (Por defecto):** Enrutador inteligente Bandit. Evalúa la latencia y tasa de éxito reciente y te asigna el mejor modelo disponible en ese instante.
- **`gemini-3.8-flash-high`:** Gemini 3.8 Flash con razonamiento profundo extendido (1 millón de tokens de contexto, soporte de visión).
- **`gemini-3.8-flash-medium` / `low`:** Variantes más rápidas para tareas ligeras.
- **`gemini-4-argon`:** Modelo de alto razonamiento de Google.
- **`claude-sonnet-5-5-high`:** Claude Sonnet 5.5 con razonamiento avanzado.
- **`claude-opus-5-5-high`:** Claude Opus 5.5 para tareas complejas de arquitectura.
- **`qwen3.8-27b`:** Qwen 3.8 con soporte de herramientas y visión vía Groq.
- **`devstral-2`:** Optimizado para generación y refactorización de código.

### Cómo cambiar de modelo dentro de la sesión:
Escribe en el chat:
```text
/model
```
Se abrirá un menú interactivo donde podrás buscar y seleccionar cualquier modelo del catálogo con las flechas del teclado.

---

## 10. Herramientas, Diagnósticos y Solución de Problemas

Gentle Shell incluye un conjunto completo de comandos de diagnóstico integrados:

### Comandos de Diagnóstico Rápido:
- **`/gentle:doctor`** $\rightarrow$ Revisa la salud del entorno: estado de Engram, herramientas, dependencias y extensiones activas.
- **`/gentle:status`** $\rightarrow$ Muestra el estado del proyecto, worktrees de Git registrados y consumo de cuota de la sesión.
- **`/gentle:stats`** $\rightarrow$ Despliega tu historial de uso: mapa de calor de actividad, tokens consumidos y costo estimado.
- **`/gentle:jobs`** $\rightarrow$ Lista los comandos en segundo plano que están corriendo (`bash_background` o `monitor`).
- **`/gentle:customize`** $\rightarrow$ Permite personalizar el estilo de las tarjetas (`float` o `neon`), los colores de la rosa y activar notificaciones de audio.

---

### ❓ Preguntas Frecuentes y Solución de Problemas

#### 1. ¿Cómo me desconecto sin detener lo que está haciendo el agente?
Pulsa la combinación de teclas de Tmux:
```text
Ctrl + B  luego suelta y pulsa  d
```
Volverás a la consola de tu PC. En el servidor, Gentle Shell seguirá compilando o esperando tu regreso. Para volver a entrar, simplemente ejecuta `gentle-connect` en tu PC y selecciona la opción de reconectar.

#### 2. Mi terminal se ve desalineada o con caracteres extraños tras redimensionar la ventana:
Si redimensionas la ventana de tu emulador de terminal bruscamente, escribe:
```text
/reload
```
Esto fuerza a `@earendil-works/pi-tui` a recalcular las dimensiones exactas de filas y columnas.

#### 3. ¿Dónde se guardan los archivos de sesión?
Las conversaciones y transcripciones se guardan en formato JSONL en:
`~/.gentle-shell/agent/sessions/`
Son archivos independientes que puedes exportar o revisar en cualquier momento.

---

*¡Felicidades! Ya tienes todo el conocimiento necesario para liderar y acelerar tu desarrollo con Gentle Shell al máximo nivel de productividad.*
