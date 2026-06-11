# Problema: API local de inventario de modelos

> **Este archivo es tool-agnostic a propósito.** El mismo `.md` se le pega a
> `/speckit.specify` (Camino A · Claude Code + Spec Kit) o al crear el Feature
> Spec (Camino B · Kiro). No menciona ninguna herramienta.

## Contexto
Necesitás un servicio local mínimo para registrar artefactos de modelos en un
inventario. Todo corre en tu máquina, sin nube, sin auth.

## Objetivo
Levantar una base de datos local y un servidor Flask con endpoints GET y POST, y
probarlos con `curl`.

## Stack obligatorio
Python 3.11+, Flask, módulo `sqlite3` de la stdlib (sin ORM). Un solo archivo
`app.py`. Base `inventory.db` creada automáticamente.

## Modelo de datos
Tabla `models`:

| Columna      | Tipo    | Restricciones                       |
|--------------|---------|-------------------------------------|
| `id`         | INTEGER | PRIMARY KEY AUTOINCREMENT            |
| `name`       | TEXT    | NOT NULL                            |
| `framework`  | TEXT    | NOT NULL                            |
| `accuracy`   | REAL    |                                     |
| `created_at` | TEXT    | timestamp ISO (lo setea el server)  |

## Endpoints
- `GET /models` — lista JSON de todos los modelos.
- `GET /models/<id>` — un modelo por id; **404** si no existe.
- `POST /models` — body `{"name","framework","accuracy"}`, setea `created_at` en
  el server, responde **201** con `{"id"}`.
- `GET /health` — responde `{"status":"ok"}`.

## Seed
Si la tabla está vacía al iniciar, insertar:
- `{"name":"resnet50","framework":"pytorch","accuracy":0.76}`
- `{"name":"xgb-churn","framework":"sklearn","accuracy":0.88}`

## Criterios de aceptación
- `/health` → `ok`.
- `GET /models` → ≥ 2 seeds.
- `POST` válido crea y un segundo `GET` lo incluye.
- `GET /models/<id>` inexistente → **404**.
- `POST` sin campos requeridos → **400**.
- Server en `http://127.0.0.1:5000`.

## Tu tarea (antes de automatizar)
Estimá cuánto tardarías **a mano** (DB + server + 4 endpoints + seed + pruebas
curl). Anotá el número en minutos. Lo vas a comparar con el tiempo real vía SDD.

## Pruebas con curl (definición de hecho)
```bash
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/models
curl -X POST http://127.0.0.1:5000/models -H "Content-Type: application/json" \
  -d '{"name":"bert-base","framework":"pytorch","accuracy":0.91}'
curl http://127.0.0.1:5000/models/1
```
