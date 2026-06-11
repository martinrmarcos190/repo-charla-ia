---
inclusion: always
---

# Steering — taller SDD (Camino B · Kiro)

> Va en `.kiro/steering/` (p. ej. `tech.md`). El frontmatter `inclusion`
> controla cuándo Kiro inyecta este contexto: `always` / `auto` / `fileMatch`
> / `manual`. Es el equivalente más cercano a la constitución de Spec Kit.

## Stack obligatorio
- Python 3.11+.
- **Flask** como único framework web.
- Persistencia con el módulo **`sqlite3` de la stdlib** (sin ORM).
- Un solo archivo `app.py`; base `inventory.db` creada automáticamente.

## Restricciones
- Sin auth, sin nube. Server en `http://127.0.0.1:5000`.
- Sin dependencias extra fuera de Flask.
- `created_at` lo setea el servidor (timestamp ISO).

## Definición de hecho
- Cada endpoint se prueba con **`curl`**.
- 404 para inexistente, 400 para body inválido, 201 al crear.
