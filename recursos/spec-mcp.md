# Spec del MCP `items-api` (Bloque 4)

> **Tool-agnostic:** este texto se pega en `/speckit.specify` (Camino A) o al
> crear el Feature Spec en Kiro (Camino B). MCP es un estándar abierto: la spec
> es idéntica en ambos caminos. El `server.py` lo generás vos vía SDD.

---

Quiero un servidor **MCP** llamado `items-api` que exponga como tools la API
local de inventario de modelos (el Flask del Bloque 3, corriendo en
`http://127.0.0.1:5000`). Generá vía SDD el server completo en un único archivo
`server.py`.

## Stack obligatorio

- SDK oficial de MCP para Python (`mcp[cli]`, usar `FastMCP`).
- `httpx` para los llamados HTTP a la API (cliente async).
- Transporte **stdio** (`mcp.run(transport="stdio")`).
- Python 3.11+.

## Tools a exponer

1. `list_models()` — lista todos los modelos. Hace `GET /models`.
2. `get_model(model_id: int)` — devuelve un modelo por id. Hace `GET /models/<id>`;
   si la API responde **404**, devolver un mensaje claro de "no existe", no un error.
3. `add_model(name: str, framework: str, accuracy: float)` — crea un modelo.
   Hace `POST /models` con el body JSON y devuelve la respuesta (incluye el `id`).

Cada tool debe tener un **docstring** describiendo qué hace (el MCP lo usa como
descripción de la tool para el agente). Tipá los parámetros.

## Reglas de robustez (críticas para stdio)

- **NUNCA escribir a stdout** (`print`, etc.): corrompe el protocolo JSON-RPC.
  Cualquier log va a **stderr** (`logging.basicConfig(stream=sys.stderr)`).
- La base de la API (`http://127.0.0.1:5000`) en una constante al tope del archivo.
- Timeout razonable en los llamados HTTP (p. ej. 30s) y `raise_for_status()`.

## Criterios de aceptación

- Corriendo el server a mano (`uv run server.py`) no imprime nada a stdout.
- Al registrarlo, el cliente descubre **3 tools**: `list_models`, `get_model`, `add_model`.
- Con el Flask del Bloque 3 corriendo: `list_models` devuelve los seeds;
  `add_model` crea y devuelve un `id`; `get_model` con ese id lo recupera;
  `get_model` con un id inexistente devuelve el mensaje de "no existe".

## Tu tarea (antes de automatizar)

Igual que con el Flask: **estimá** cuánto tardarías a mano en escribir el MCP
server (3 tools + manejo de 404 + stdio + httpx async). Anotá el número y
compará con el tiempo real vía SDD.
