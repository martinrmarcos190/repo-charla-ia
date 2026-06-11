# Taller: Spec-Driven Development + Skills

Repo de **materiales para participantes**. Acá está todo lo que vas a necesitar
para el taller: el pre-work, las **specs** que vas a pegar y los ejemplos de
configuración. **No hay código pre-hecho a propósito:** la API, el servidor MCP y
la Skill los generás vos **vía SDD** durante la clase.

> **Dual-track.** El taller corre en dos caminos y el 90% es idéntico:
> - 🟧 **[A]** Claude Code + Spec Kit
> - 🟪 **[B]** Kiro (AWS)
>
> Solo cambia *cómo creás las specs y dónde registrás las cosas*. Los `.md` de
> specs son **los mismos** en ambos.

---

## 📂 Qué hay en este repo

| Archivo | Para qué | Cuándo |
|---|---|---|
| `material-previo.md` | Guía de preparación completa (instalación + refresher Flask) | **Antes** del taller |
| `recursos/problema.md` | Spec del problema → genera la **API** | Bloque 3 |
| `recursos/spec-mcp.md` | Spec del **MCP** → genera `server.py` | Bloque 4 |
| `recursos/spec-skill.md` | Spec de la **Skill** → genera `SKILL.md` | Bloque 4 |
| `recursos/seed.sh` | Carga ~10 modelos de ejemplo vía `POST /models` (para poblar el inventario) | Bloque 3/4 |
| `recursos/examples/constitution.example.md` | 🟧 [A] ejemplo de constitución | Bloque 3 |
| `recursos/examples/steering.example.md` | 🟪 [B] ejemplo de steering file | Bloque 3 |
| `recursos/examples/mcp.json.example` | 🟪 [B] registro del MCP en Kiro | Bloque 4 |

> Las specs son **tool-agnostic**: el mismo `.md` se pega en `/speckit.specify`
> (A) o al crear el Feature Spec (B).

---

## 0. Antes del taller (pre-work)

Leé `material-previo.md` completo. Resumen de comandos:

### Base común (los dos caminos)

```bash
uv --version          # si falla: curl -LsSf https://astral.sh/uv/install.sh | sh
python3 --version     # necesitás ≥ 3.11  (si no: uv python install 3.12)
git --version
```

### 🟧 [A] Claude Code + Spec Kit

```bash
# 1) Claude Code (instalador nativo, sin Node)
curl -fsSL https://claude.ai/install.sh | bash          # macOS / Linux
#   irm https://claude.ai/install.ps1 | iex             # Windows PowerShell
claude --version
claude doctor

# 2) Spec Kit
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
specify check
specify version
```

La primera vez que corras `claude` te autentica por OAuth en el navegador.

### 🟪 [B] Kiro

```text
1) Descargá Kiro de kiro.dev/downloads (fork de VS Code; no necesitás cuenta AWS).
2) Logueate (Google / GitHub / Builder ID / AWS SSO).
3) No instalás Spec Kit ni Claude Code: el flujo SDD viene incluido.
   De la base común solo necesitás uv, Python y Git.
```

### Refresher opcional (Flask + SQLite)

Para llegar con la sintaxis fresca, mirá el snippet ilustrativo en
`material-previo.md` (sección 5). **No es la solución completa** (le faltan
`init_db()`, el seed y `GET /models/<id>`): esa la generás vos vía SDD en el
Bloque 3 a partir de `recursos/problema.md`.

> ⚠️ **macOS:** cuando corras la API, ojo que AirPlay Receiver ocupa el puerto
> 5000 y responde 403 a todo. Si `curl` devuelve vacío o 403, desactivalo en
> **Ajustes del Sistema → General → AirDrop y Handoff → Receptor de AirPlay**, o
> usá otro puerto.

---

## 1. Setup del proyecto (Bloque 2)

### 🟧 [A]
```bash
mkdir taller-sdd && cd taller-sdd
git init
claude                       # primera vez: autenticar en el navegador
# dentro de Claude Code:
/init
specify init . --integration claude
# tipeá "/" y confirmá que aparecen los /speckit.*
```

### 🟪 [B]
```text
File → New Folder "taller-sdd" → Open Folder.
(Opcional) terminal integrada: git init
El panel "Specs" ya está listo (no se instala nada).
```

---

## 2. Construir la API vía SDD (Bloque 3)

> Antes de empezar: **estimá** cuánto tardarías a mano (DB + Flask + 4 endpoints +
> seed + curl). Anotá el número y comparalo con el tiempo real.

### 🟧 [A] — pegá el contenido de `recursos/problema.md` en `/speckit.specify`
```text
/speckit.constitution   (reglas: solo stdlib + Flask, sqlite3, sin auth, tests con curl)
/speckit.specify        (pegá recursos/problema.md)
/speckit.clarify
/speckit.plan           (Flask + sqlite3 stdlib)
/speckit.tasks
/speckit.analyze
/speckit.implement
```

### 🟪 [B]
```text
(Opcional) Steering file en .kiro/steering/ con las mismas reglas (ver examples/steering.example.md).
Panel Specs → "+" → Feature → pegá recursos/problema.md →
   Requirements-First (o Quick Plan si vas ajustado) →
   revisar requirements.md → design.md → tasks.md → "Run all Tasks".
```

### Probar (los dos caminos) — con la API corriendo
```bash
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/models
curl -X POST http://127.0.0.1:5000/models -H "Content-Type: application/json" \
  -d '{"name":"bert-base","framework":"pytorch","accuracy":0.91}'
curl http://127.0.0.1:5000/models/1
```

**Poblar el inventario** (opcional, pero hace mejor la demo del Bloque 4) — con la
API corriendo, cargá ~10 modelos de ejemplo vía el endpoint:

```bash
./recursos/seed.sh                          # http://127.0.0.1:5000
./recursos/seed.sh http://127.0.0.1:5001    # si la levantaste en otro puerto
```

---

## 3. MCP + Skill (Bloque 4)

**La API del Bloque 3 debe estar corriendo.**

### 3.1 Scaffold del proyecto MCP (los dos caminos)
```bash
uv init mcp-items && cd mcp-items
uv venv && source .venv/bin/activate
uv add "mcp[cli]" httpx
```

### 3.2 Generá el `server.py` vía SDD (pegá `recursos/spec-mcp.md`)
- 🟧 **[A]** `/speckit.specify` (pegá `spec-mcp.md`) → `plan` → `tasks` → `implement`
- 🟪 **[B]** Feature Spec con `spec-mcp.md` (Quick Plan si vas ajustado)

### 3.3 Registrá el MCP
```bash
# 🟧 [A]
claude mcp add items-api -- uv --directory "$(pwd)" run server.py
claude mcp list          # debe aparecer items-api
# dentro de Claude Code: /mcp
```
```json
// 🟪 [B] — .kiro/settings/mcp.json (ver recursos/examples/mcp.json.example)
{
  "mcpServers": {
    "items-api": {
      "command": "uv",
      "args": ["--directory", "/ruta/absoluta/a/mcp-items", "run", "server.py"],
      "disabled": false
    }
  }
}
```

### 3.4 Generá la Skill vía SDD (pegá `recursos/spec-skill.md`)
- 🟧 **[A]** `/speckit.specify` (pegá `spec-skill.md`) → `plan` → `tasks` → `implement`
  → queda en `.claude/skills/items-ops/SKILL.md`. Si la carpeta es nueva:
  `/reload-skills` o reiniciá Claude Code.
- 🟪 **[B]** Feature Spec con `spec-skill.md` → `.kiro/skills/items-ops/SKILL.md`
  (respetá la subcarpeta con el nombre).

### 3.5 Probar
Pedile al agente: **"listá los modelos y agregá uno"**. Debe usar la Skill + las
tools del MCP. Verificá con los `curl` de arriba.

---

## 🔧 Troubleshooting rápido

- **`uv` / `uvx` "command not found":** reabrí la terminal o agregá `~/.local/bin` al PATH.
- **Python < 3.11:** `uv python install 3.12`.
- **Puerto 5000 en macOS (¡frecuente!):** es AirPlay Receiver (403 con body vacío). Desactivalo o cambiá de puerto. Diagnóstico: `lsof -nP -iTCP:5000 -sTCP:LISTEN`.
- **Flask viejo (`'Flask' object has no attribute 'get'`):** `uv run --python 3.12 --with flask app.py`.
- **MCP con 0 tools / no conecta:** corré el server a mano para ver errores en stderr; **nunca `print()` a stdout** (corrompe el JSON-RPC); usá **ruta absoluta** en `--directory`; abrí sesión nueva (descubre las tools al inicio).
- **No aparecen los `/speckit.*` (A):** `ls .claude/commands/`, reiniciá Claude Code; usá `--integration claude`.
- **No veo el panel Specs (B):** abrí una **carpeta** (no un archivo suelto) con File → Open Folder.
