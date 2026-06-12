# Constitución del proyecto — taller SDD (Camino A · Spec Kit)

> Va en `.specify/memory/constitution.md`. Son las reglas que gobiernan todas
> las features del proyecto. En el Bloque 3 se cargan con
> `/speckit.constitution`.

## Stack
- Lenguaje: Python 3.11+.
- Web: **Flask** únicamente (sin frameworks adicionales).
- Persistencia: módulo **`sqlite3` de la stdlib**. Prohibido usar ORMs.
- Un solo archivo de aplicación: `app.py`. Base `issues.db` autocreada.

## Restricciones
- Sin autenticación, sin nube: todo corre local en `http://127.0.0.1:5000`.
- Sin dependencias extra más allá de Flask.
- Los timestamps (`created_at`, `updated_at`) los setea siempre el servidor (ISO).
- Los campos enumerados (`severity`, `status`) se validan en el server: 400 si el valor no pertenece al enum.

## Calidad y pruebas
- Toda feature se valida con **`curl`** según sus criterios de aceptación.
- Errores explícitos: 404 para recurso inexistente, 400 para body inválido.

## Convenciones
- Respuestas JSON.
- Códigos de estado correctos (200 / 201 / 400 / 404).
