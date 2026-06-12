# Problema: API local de registro de issues de infraestructura

> **Este archivo es tool-agnostic a propósito.** El mismo `.md` se le pega a
> `/speckit.specify` (Camino A · Claude Code + Spec Kit) o al crear el Feature
> Spec (Camino B · Kiro). No menciona ninguna herramienta.

## Contexto
Tu equipo de DevOps necesita un servicio local mínimo para registrar y seguir
**issues de infraestructura**: qué se rompió, en qué servicio, qué tan grave es
y qué solución se propone. Todo corre en tu máquina, sin nube, sin auth.

## Objetivo
Levantar una base de datos local y un servidor Flask con endpoints GET, POST y
PUT, y probarlos con `curl`.

## Stack obligatorio
Python 3.11+, Flask, módulo `sqlite3` de la stdlib (sin ORM). Un solo archivo
`app.py`. Base `issues.db` creada automáticamente.

## Modelo de datos
Tabla `issues`:

| Columna             | Tipo    | Restricciones                                          |
|---------------------|---------|--------------------------------------------------------|
| `id`                | INTEGER | PRIMARY KEY AUTOINCREMENT                              |
| `title`             | TEXT    | NOT NULL — resumen corto del problema                  |
| `service`           | TEXT    | NOT NULL — servicio afectado (`payments-api`, `db-01`…) |
| `severity`          | TEXT    | NOT NULL — uno de: `low` / `medium` / `high` / `critical` |
| `status`            | TEXT    | NOT NULL — uno de: `open` / `investigating` / `resolved` (default `open`) |
| `description`       | TEXT    | detalle del problema / evidencia                       |
| `proposed_solution` | TEXT    | posible solución                                       |
| `created_at`        | TEXT    | timestamp ISO (lo setea el server)                     |
| `updated_at`        | TEXT    | timestamp ISO (lo setea el server en cada PUT)         |

## Endpoints
- `GET /issues` — lista JSON de todos los issues.
- `GET /issues/<id>` — un issue por id; **404** si no existe.
- `POST /issues` — body `{"title","service","severity","description","proposed_solution"}`
  (los tres primeros obligatorios; `status` opcional, default `open`). El server
  setea `created_at` y valida los enums; responde **201** con `{"id"}`.
- `PUT /issues/<id>` — actualiza solo los campos provistos (`status`,
  `severity`, `description`, `proposed_solution`). El server setea `updated_at`
  y valida los enums. **404** si no existe, **400** si un enum es inválido.
- `GET /health` — responde `{"status":"ok"}`.

## Seed
Si la tabla está vacía al iniciar, insertar:
- `{"title":"Timeouts intermitentes contra la DB","service":"payments-api","severity":"high","description":"Conexiones a la base agotan el pool en hora pico.","proposed_solution":"Revisar tamaño del pool y queries lentas."}`
- `{"title":"502 intermitentes en /checkout","service":"api-gateway","severity":"high","description":"El gateway devuelve 502 esporádicos hacia checkout-service.","proposed_solution":"Chequear health del upstream y reintentos."}`

## Criterios de aceptación
- `/health` → `ok`.
- `GET /issues` → ≥ 2 seeds.
- `POST` válido crea (201) y un segundo `GET` lo incluye.
- `POST` sin campos requeridos → **400**.
- `POST` con `severity` fuera del enum → **400**.
- `PUT /issues/<id>` cambia `status` a `resolved` y un `GET` posterior lo refleja, con `updated_at` seteado.
- `PUT` con `status` inválido → **400**; `PUT` a un id inexistente → **404**.
- `GET /issues/<id>` inexistente → **404**.
- Server en `http://127.0.0.1:5000`.

## Tu tarea (antes de automatizar)
Estimá cuánto tardarías **a mano** (DB + server + 5 endpoints + validación de
enums + seed + pruebas curl). Anotá el número en minutos. Lo vas a comparar con
el tiempo real vía SDD.

## Pruebas con curl (definición de hecho)
```bash
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/issues
curl -X POST http://127.0.0.1:5000/issues -H "Content-Type: application/json" \
  -d '{"title":"Cert TLS por vencer","service":"cert-monitor","severity":"medium","description":"api.internal vence en 14 días","proposed_solution":"Renovar con certbot"}'
curl -X PUT http://127.0.0.1:5000/issues/1 -H "Content-Type: application/json" \
  -d '{"status":"resolved","proposed_solution":"Pool ampliado a 50 conexiones y query del checkout indexada."}'
curl http://127.0.0.1:5000/issues/1
```
