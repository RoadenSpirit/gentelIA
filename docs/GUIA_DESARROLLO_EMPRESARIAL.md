# 🎓 Guía del Desarrollador: De Junior a Senior Asistido por IA (Anti-VibeCoding)

Esta guía establece el método de trabajo oficial para desarrollar software en este VPS. Su objetivo es garantizar productos de calidad empresarial mientras aprendes a fondo cada tecnología utilizada.

---

## 🚫 1. Qué es "Vibe Coding" y Por Qué es Peligroso
El **Vibe Coding** ocurre cuando le pides a una IA: *"Hazme un sistema de login y que envíe correos"*, y la IA vomita 400 líneas de código que tú no entiendes pero aceptas porque "parece que funciona".
- **Consecuencias:** Fallos de seguridad, fugas de memoria en el VPS (4GB RAM colapsados), dependencias innecesarias, código imposible de mantener cuando la IA comete un error, y lo peor: **no aprendes nada como desarrollador**.

---

## 🛡️ 2. El Ciclo de Ingeniería Inviolable (SDD Empresarial)

En este ecosistema, ninguna IA escribe código por adivinanza. El proceso consta de 6 etapas formales:

```
[Requisitos (PRD)] ➔ [Especificación (.spec.md)] ➔ [Visto Bueno Humano] ➔ [Skills] ➔ [Implementación + Bloque Instructivo] ➔ [Certificación de Pruebas]
```

### Paso 1: Requisitos Claros (`requisitos.md`)
- Antes de pedir código, define qué problema resuelves.
- Ejemplo (`VitroArte/requisitos.md`): Lámparas fijas comprables por carrito, vitrales bajo encargo con medidas, emisión de ticket `#VA-XXXX` enviado por WhatsApp.

### Paso 2: Especificación Técnica y Criterios de Aceptación
- La IA redacta el documento `.spec.md` respondiendo:
  1. ¿Qué archivos exactos se crearán o modificarán?
  2. ¿Qué contrato de datos (JSON/schema) se usará?
  3. ¿Cuáles son los **Criterios de Aceptación**? (Ej: *"Dado un carrito con 2 artículos en USD, debe calcular el total exacto y generar una URL válida de WhatsApp"*).
  4. ¿Qué impacto tendrá en la RAM/disco del VPS?

### Paso 3: Visto Bueno del Desarrollador (Gate)
- La IA se detiene. Como director del proyecto, lees el plan. Si algo no tiene sentido, pides cambios. **La IA tiene prohibido tocar código sin tu "Aprobado".**

### Paso 4: Carga de Skills Obligatorias
- La IA invoca `skill(...)` para la tecnología en uso (ej: `impeccable` para diseño UI, `using-n8n-skills` para flujos n8n, `vps-services-and-infrastructure` para puertos).

### Paso 5: Implementación con Bloque Pedagógico
- La IA escribe el código.
- **Regla Educativa:** Si se introduce una tecnología, librería o patrón nuevo, la IA incluye obligatoriamente el **Bloque Instructivo**:
  - ¿Qué es el concepto?
  - ¿Por qué se eligió en vez de otra opción?
  - ¿Cómo funciona bajo el capó?
  - ¿Qué errores comunes debes vigilar tú como desarrollador?

### Paso 6: Certificación Final de Pruebas
- La IA o el subagente de testing escribe y ejecuta pruebas (`npm test` con Vitest, o `pytest`) contra los **Criterios de Aceptación** definidos en el Paso 2.
- El código se considera entregado **solo cuando las pruebas están en verde y `tsc --noEmit` / linter pasan al 100%**.

---

## 👥 3. Cómo Delegar en tu Equipo de Subagentes (`agency-agents`)

Tienes a tu disposición **91 agentes especializados** instalados en `~/.config/opencode/agents/`.
No le pidas a un solo asistente genérico que haga todo. Utiliza la herramienta `Task` para delegar tareas específicas:

| Cuando necesites... | Delega en el Agente... |
| :--- | :--- |
| **Diseñar o pulir interfaces web y CSS** | `frontend-developer` o `ui-designer` |
| **Diseñar APIs, schemas y contratos** | `backend-architect` |
| **Optimizar consultas SQL o base de datos** | `database-optimizer` |
| **Auditar puertos, credenciales y seguridad** | `security-architect` o `application-security-engineer` |
| **Crear y ejecutar la suite final de pruebas** | `test-automation-engineer` o `api-tester` |
| **Auditar qué se rompió tras un cambio** | `reality-checker` o `code-reviewer` |
| **Explorar código desconocido de un repo** | `codebase-onboarding-engineer` |

---

## 💡 4. Tu Rol como Desarrollador Junior en Crecimiento
1. **Sé el Arquitecto que cuestiona:** Pregunta *"¿Por qué usaste esta librería y no la nativa de Node?"*.
2. **Exige el bloque instructivo:** Si ves código raro (ej. `Array.reduce`, `AbortSignal`, `cgroups`, `middleware`), pide una explicación paso a paso.
3. **No des el visto bueno a ciegas:** Si la especificación técnica tiene puntos que no entiendes, pide aclaración antes de autorizar la fase de desarrollo.
