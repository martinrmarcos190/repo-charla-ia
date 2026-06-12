# Spec de la Skill `issues-ops` (Bloque 4)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). El `SKILL.md` lo generás vos vía SDD.

---

Quiero una Skill llamada `issues-ops` que opere el registro de issues de
infraestructura a través de las tools del MCP `issues-api`. Generá vía SDD la
Skill completa.

Debe:

1. Explicar cuándo usarse (listar, consultar, crear o actualizar issues).
2. Instruir a usar SIEMPRE los nombres calificados de las tools:
   - `issues-api:list_issues`
   - `issues-api:get_issue`
   - `issues-api:add_issue`
   - `issues-api:update_issue`
3. Validar los enums antes de crear o actualizar:
   - `severity` ∈ {low, medium, high, critical}
   - `status` ∈ {open, investigating, resolved}
   Si el usuario pide otro valor, pedí corrección antes de llamar a la tool.
4. **Regla de negocio:** para marcar un issue como `resolved`, exigir que
   `proposed_solution` no quede vacía (si falta, pedirla o redactarla con el
   usuario antes de actualizar).
5. Tras crear o actualizar, confirmar el resultado leyendo el issue con
   `issues-api:get_issue` y mostrarlo legible.

El `SKILL.md` debe tener frontmatter YAML con `name: issues-ops` y un
`description` en tercera persona (≤1024 chars) con qué hace y cuándo usarse.
Cuerpo <500 líneas.

Ubicación del artefacto:
- **[A]** `.claude/skills/issues-ops/SKILL.md`
- **[B]** `.kiro/skills/issues-ops/SKILL.md` (respetá la subcarpeta con el nombre)
