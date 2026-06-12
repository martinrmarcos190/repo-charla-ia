# Spec del empaquetado `devops-issues` (Bloque 6)

> El QUÉ es idéntico en ambos caminos: un paquete instalable con las dos skills
> y el MCP. El CÓMO difiere: 🟧 [A] **plugin** de Claude Code · 🟪 [B] **Power**
> de Kiro. Verificá la mecánica exacta con la versión de la herramienta el día
> del taller.

---

Quiero empaquetar todo lo que construimos en una unidad instalable llamada
**`devops-issues`**, para que cualquier persona del equipo la instale y tenga el
toolkit completo sin configurar nada a mano.

## Qué contiene

1. La skill **`issues-ops`** (operar issues + análisis de logs).
2. La skill **`issues-report`** (reporte HTML).
3. El MCP **`issues-api`** (la conectividad que ambas skills usan).

## 🟧 [A] Como plugin de Claude Code

Estructura esperada:

```
devops-issues/
├── .claude-plugin/
│   └── plugin.json          ← name, description, version
├── skills/
│   ├── issues-ops/SKILL.md
│   └── issues-report/SKILL.md
└── .mcp.json                ← registra issues-api (uv --directory ... run server.py)
```

- `plugin.json` mínimo: `{"name": "devops-issues", "description": "...", "version": "0.1.0"}`
  (solo `name` es obligatorio; kebab-case).
- El `.mcp.json` del plugin registra el MCP: al habilitar el plugin, el server
  **arranca automáticamente**, sin `claude mcp add` manual.
- **Probar en el taller (directo, sin marketplace):**
  `claude --plugin-dir ./devops-issues` — carga el plugin al lanzar; tras
  cambios, `/reload-plugins`.
- **Distribuir de verdad (marketplace local):** carpeta con
  `.claude-plugin/marketplace.json` (`{"name": "taller", "owner": {"name": "..."},
  "plugins": [{"name": "devops-issues", "source": "./devops-issues"}]}`) →
  `/plugin marketplace add ./carpeta` → `/plugin install devops-issues@taller`
  → `/reload-plugins` (no hace falta reiniciar la sesión).

## 🟪 [B] Como Power de Kiro

- Empaquetar el MCP (`mcp.json`) + el steering del proyecto como **Power**
  `devops-issues`, manteniendo las dos skills en `.kiro/skills/`.
- Si la versión de Kiro del día soporta skills dentro del Power, moverlas
  adentro; si no, el Power lleva la conectividad y las skills viajan al lado.
  El concepto es el mismo: **una unidad que se comparte e instala completa**.

## Criterios de aceptación

- Tras `/reload-plugins` (o lanzando con `--plugin-dir`), sin registrar nada a mano:
  - las dos skills aparecen disponibles, y
  - el MCP `issues-api` está conectado con sus 4 tools.
- Prueba integrada: pedirle al agente *"analizá los logs de `recursos/logs/` y
  después regenerá el reporte"* — una skill actualiza la tabla, la otra la
  consume, el MCP conecta todo.
