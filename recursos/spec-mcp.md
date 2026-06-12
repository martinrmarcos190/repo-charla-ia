# Spec del MCP `issues-api` (Bloque 4)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). MCP es un estándar abierto: la spec
> es idéntica en ambos caminos. El `server.py` lo generás vos vía SDD.

---

Quiero un servidor **MCP** llamado `issues-api` que exponga como tools la API
local de issues de infraestructura (el Flask del Bloque 3, corriendo en
`http://127.0.0.1:5000`). Generá vía SDD el server completo en un único archivo
`server.py`.

## Stack obligatorio

- SDK oficial de MCP para Python (`mcp[cli]`, usar `FastMCP`).
- `httpx` para los llamados HTTP a la API (cliente async).
- Transporte **stdio** (`mcp.run(transport="stdio")`).
- Python 3.11+.

## Tools a exponer

1. `list_issues()` — lista todos los issues. Hace `GET /issues`.
2. `get_issue(issue_id: int)` — devuelve un issue por id. Hace `GET /issues/<id>`;
   si la API responde **404**, devolver un mensaje claro de "no existe", no un error.
3. `add_issue(title: str, service: str, severity: str, description: str = "",
   proposed_solution: str = "")` — crea un issue. Hace `POST /issues` con el
   body JSON y devuelve la respuesta (incluye el `id`).
4. `update_issue(issue_id: int, status: str | None = None,
   severity: str | None = None, description: str | None = None,
   proposed_solution: str | None = None)` — actualiza un issue. Hace
   `PUT /issues/<id>` enviando **solo los campos provistos** (los `None` no se
   mandan). Si la API responde 404 o 400, devolver el mensaje de error legible.

Cada tool debe tener un **docstring** describiendo qué hace y los valores
válidos de los enums (`severity`: low/medium/high/critical · `status`:
open/investigating/resolved) — el MCP usa el docstring como descripción de la
tool para el agente. Tipá los parámetros.

## Reglas de robustez (críticas para stdio)

- **NUNCA escribir a stdout** (`print`, etc.): corrompe el protocolo JSON-RPC.
  Cualquier log va a **stderr** (`logging.basicConfig(stream=sys.stderr)`).
- La base de la API (`http://127.0.0.1:5000`) en una constante al tope del archivo.
- Timeout razonable en los llamados HTTP (p. ej. 30s) y `raise_for_status()`.

## Criterios de aceptación

- Corriendo el server a mano (`uv run server.py`) no imprime nada a stdout.
- Al registrarlo, el cliente descubre **4 tools**: `list_issues`, `get_issue`,
  `add_issue`, `update_issue`.
- Con el Flask del Bloque 3 corriendo: `list_issues` devuelve los seeds;
  `add_issue` crea y devuelve un `id`; `update_issue` cambia el `status` y
  `get_issue` lo refleja; `get_issue` con un id inexistente devuelve el mensaje
  de "no existe".

## Tu tarea (antes de automatizar)

Igual que con el Flask: **estimá** cuánto tardarías a mano en escribir el MCP
server (4 tools + campos opcionales + manejo de 404/400 + stdio + httpx async).
Anotá el número y compará con el tiempo real vía SDD.
