# Spec de la Skill `issues-report` (Bloque 6)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). El `SKILL.md` lo generás vos vía SDD.

---

Quiero una Skill llamada `issues-report` que genere un **reporte HTML completo**
del estado de los issues de infraestructura. Generá vía SDD la Skill completa.

Debe:

1. Explicar cuándo usarse (cuando pidan un reporte, dashboard o resumen del
   estado de los issues).
2. Obtener los datos **EXCLUSIVAMENTE** vía `issues-api:list_issues` (nombre
   calificado). Prohibido leer la base de datos o el código de la API: la skill
   solo conoce el MCP.
3. Generar un único archivo **`issues-report.html` autocontenido** (CSS inline,
   sin assets externos, sin internet) con:
   - Header con fecha/hora de generación y totales: cantidad de issues por
     `status` y por `severity`.
   - Una sección destacada arriba: **críticos y altos abiertos** (si los hay).
   - La tabla completa de issues: id, título, servicio, severity, status,
     solución propuesta. Severity con color (critical rojo, high naranja,
     medium amarillo, low gris).
   - Una sección final con los `resolved` y sus soluciones (es la base de
     conocimiento del equipo).
4. Decir al final dónde quedó el archivo y sugerir abrirlo en el navegador.

El `SKILL.md` debe tener frontmatter YAML con `name: issues-report` y un
`description` en tercera persona (≤1024 chars). Cuerpo <500 líneas.

## Criterios de aceptación

- Pedirle al agente "armá el reporte de issues" produce `issues-report.html`.
- El HTML abre en el navegador sin red y refleja exactamente lo que devuelve
  `issues-api:list_issues` en ese momento.
- Si no hay issues críticos/altos abiertos, la sección destacada lo dice
  ("sin críticos abiertos ✅") en vez de quedar vacía.

Ubicación del artefacto:
- **[A]** `.claude/skills/issues-report/SKILL.md`
- **[B]** `.kiro/skills/issues-report/SKILL.md` (respetá la subcarpeta con el nombre)
