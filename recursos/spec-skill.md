# Spec de la Skill `items-ops` (Bloque 4)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). El `SKILL.md` lo generás vos vía SDD.

---

Quiero una Skill llamada `items-ops` que opere el inventario de modelos a
través de las tools del MCP `items-api`. Generá vía SDD la Skill completa.

Debe:

1. Explicar cuándo usarse (listar, consultar o agregar modelos).
2. Instruir a usar SIEMPRE los nombres calificados de las tools:
   - `items-api:list_models`
   - `items-api:get_model`
   - `items-api:add_model`
3. Validar `accuracy` entre 0 y 1 antes de un alta.
4. Tras un alta, confirmar el id leyendo el modelo.

El `SKILL.md` debe tener frontmatter YAML con `name: items-ops` y un
`description` en tercera persona (≤1024 chars) con qué hace y cuándo usarse.
Cuerpo <500 líneas.

Ubicación del artefacto:
- **[A]** `.claude/skills/items-ops/SKILL.md`
- **[B]** `.kiro/skills/items-ops/SKILL.md` (respetá la subcarpeta con el nombre)
