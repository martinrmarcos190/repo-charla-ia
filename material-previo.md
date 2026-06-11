# Material previo — Taller SDD + Skills (Clase 3) · dual-track

> Mandá este documento 3–4 días antes del taller. Pedí a cada participante que
> deje su entorno listo y pegue el output del checklist (el de su camino) en el
> canal del grupo.

---

## 1. Cómo usar este documento

El grupo viene **mixto**: algunos van a hacer el taller con **Claude Code +
Spec Kit (Camino A)** y otros con **Kiro (Camino B)**. No pasa nada: **SDD, MCP
y Skills son estándares abiertos**, así que el 90% es idéntico.

A lo largo del documento vas a ver etiquetas:

- 🟧 **[A]** — solo para Camino A (Claude Code + Spec Kit).
- 🟪 **[B]** — solo para Camino B (Kiro).
- 🟩 **[Ambos]** — común a los dos.

Elegí tu camino, seguí las etiquetas que te corresponden y la **[Ambos]**.

> No necesitás saber redes neuronales ni transformers para este taller. Si te
> interesa el fondo, mirá los videos de la sección 7 — son opcionales.

---

## 2. Qué es SDD y por qué

El **"vibe coding"** —tirarle prompts sueltos a un agente hasta que algo
funcione— no escala: los resultados son irreproducibles, nadie sabe qué se pidió
ni por qué, y no hay nada revisable como *intención*.

**Spec-Driven Development (SDD)** invierte eso: la **spec es la fuente de
verdad** y el **código es un artefacto de build**. Vos declarás el **QUÉ**
(requisitos, criterios de aceptación, restricciones) y la herramienta genera el
**CÓMO** (el código), pasando por fases con gates de aprobación.

La analogía que conviene tener en la cabeza: **SDD es a tu código lo que
Infrastructure-as-Code (IaC) es a tu infraestructura**. Con IaC no tocás
servidores a mano: declarás el estado deseado y la herramienta lo materializa,
de forma reproducible, versionable y revisable. SDD hace lo mismo con tu
aplicación: la spec versionada es la verdad; el código se regenera desde ahí.

El flujo, en abstracto:

```text
reglas/constitución → specify → clarify → plan → tasks → analyze → implement
```

`specify` captura el QUÉ; `clarify` cierra ambigüedades; `plan` define el CÓMO
técnico; `tasks` descompone; `analyze` es un gate de consistencia; `implement`
genera el código. Entre fases, **vos revisás**.

---

## 3. Las dos herramientas

| | 🟧 **[A]** Spec Kit + Claude Code | 🟪 **[B]** Kiro (AWS) |
|---|---|---|
| Qué es | Spec Kit **agrega** SDD a Claude Code | IDE con **SDD nativo** (fork de VS Code / Code OSS) |
| Cómo obtenés SDD | Lo instalás (`specify`) | Viene de fábrica |
| Flujo | `/speckit.*` | Feature Spec (Requirements-First / Design-First / Quick Plan) |
| Reglas | Constitución (`.specify/memory/`) | Steering files (`.kiro/steering/`) |

> **🟩 Recuadro: SDD, MCP y Skills son estándares abiertos.**
> En el taller **construimos todo desde cero vía specs** (nada de pegar código):
> el `.md` del problema, la spec del **MCP** y la de la **Skill** son **idénticas**
> en las dos herramientas. Solo cambia **cómo se crean las specs y dónde se
> registran**, no **qué son**. Eso es justamente lo que vamos a comprobar en vivo:
> el taller es portable.

---

## 4. Instalación y verificación

### 🟩 [Ambos] Base común

Necesitás esto sí o sí, vengas por el camino que vengas:

```bash
# uv (gestor de Python de Astral)
curl -LsSf https://astral.sh/uv/install.sh | sh        # macOS / Linux
# Windows PowerShell:
#   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# Reiniciá la terminal después de instalar uv. Luego verificá:
uv --version
python3 --version      # debe ser ≥ 3.11
git --version
docker --version
```

> Si `python3` es < 3.11: `uv python install 3.12`.
> Si `uv` da "command not found": reabrí la terminal o agregá `~/.local/bin` al PATH.

---

### 🟧 [A] Camino A — Claude Code + Spec Kit

**1) Instalá Claude Code** (instalador nativo recomendado por Anthropic, sin Node):

```bash
# macOS / Linux
curl -fsSL https://claude.ai/install.sh | bash
# Windows PowerShell
#   irm https://claude.ai/install.ps1 | iex
```

El binario nativo queda en `~/.local/bin/claude` y se autoactualiza.
Alternativa legada (npm, Node 18+, **nunca con sudo**): `npm install -g @anthropic-ai/claude-code`.

```bash
claude --version
claude doctor
```

La primera vez que corras `claude`, te autentica por OAuth en el navegador
(Pro / Max / Team / Enterprise).

**2) Instalá Spec Kit** (con uv):

```bash
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git
# (uso efímero, sin instalar:)
#   uvx --from git+https://github.com/github/spec-kit.git specify init <PROJECT>
specify check
specify version
```

> Pinneá la versión si querés reproducibilidad: agregá `@v0.8.18` al final de la URL del repo.

**Checklist "entorno listo" — 🟧 [A]:**
- [ ] `uv --version` responde
- [ ] `python3 --version` ≥ 3.11
- [ ] `git` y `docker` responden
- [ ] `claude --version` y `claude doctor` OK
- [ ] `specify check` OK

---

### 🟪 [B] Camino B — Kiro (sin Spec Kit)

```text
1) Descargá Kiro desde kiro.dev/downloads (macOS / Linux / Windows; es fork de VS Code).
2) Abrílo y logueate con Google, GitHub, Builder ID o AWS SSO (NO hace falta cuenta de AWS).
3) En Kiro NO instalás Spec Kit ni Claude Code: el flujo SDD viene incluido.
   De la base común solo necesitás uv (para el MCP del Bloque 4), Python, Git y Docker.
4) Verificación: abrí una carpeta vacía (File → Open Folder) y confirmá que aparece
   el panel "Specs" en la barra lateral y que podés abrir el chat.
```

**Checklist "entorno listo" — 🟪 [B]:**
- [ ] Kiro instalado y con sesión iniciada
- [ ] Abrí una carpeta y veo el panel **Specs**
- [ ] `uv --version`, `python3 --version` ≥ 3.11, `git` / `docker` responden (base común)

---

## 5. Refresher: Flask + SQLite

En el taller vas a generar este servicio **vía SDD**, pero conviene que lo
tengas fresco. Este `app.py` mínimo usa Flask y el `sqlite3` de la stdlib (sin
ORM):

```python
import sqlite3
from datetime import datetime, timezone
from flask import Flask, g, jsonify, request

app = Flask(__name__)
DB = "inventory.db"

def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB)
        g.db.row_factory = sqlite3.Row
    return g.db

@app.get("/health")
def health():
    return jsonify({"status": "ok"})

@app.get("/models")
def list_models():
    rows = get_db().execute("SELECT * FROM models ORDER BY id").fetchall()
    return jsonify([dict(r) for r in rows])

@app.post("/models")
def add_model():
    data = request.get_json(silent=True) or {}
    if not data.get("name") or not data.get("framework"):
        return jsonify({"error": "name y framework son obligatorios"}), 400
    created_at = datetime.now(timezone.utc).isoformat()
    db = get_db()
    cur = db.execute(
        "INSERT INTO models (name, framework, accuracy, created_at) VALUES (?, ?, ?, ?)",
        (data["name"], data["framework"], data.get("accuracy"), created_at),
    )
    db.commit()
    return jsonify({"id": cur.lastrowid}), 201

if __name__ == "__main__":
    # (en el taller, init_db() crea la tabla y el seed)
    app.run(host="127.0.0.1", port=5000, debug=True)
```

Correr sin instalar nada (uv trae Flask al vuelo; pinneá el Python para que no
agarre uno viejo del sistema):

```bash
uv run --python 3.12 --with flask app.py
```

> ⚠️ **macOS:** AirPlay Receiver ocupa el puerto 5000 y responde 403 a todo.
> Si `curl` te devuelve vacío o 403, desactivalo en **Ajustes del Sistema →
> General → AirDrop y Handoff → Receptor de AirPlay**, o usá otro puerto.

Probar:

```bash
curl http://127.0.0.1:5000/health
curl http://127.0.0.1:5000/models
curl -X POST http://127.0.0.1:5000/models -H "Content-Type: application/json" \
  -d '{"name":"bert-base","framework":"pytorch","accuracy":0.91}'
```

> El archivo completo (con `init_db()` y seed) está en `recursos/app.py`.

---

## 6. Cómo se mapea el curso en cada herramienta

| Pieza del taller | 🟧 [A] Claude Code + Spec Kit | 🟪 [B] Kiro |
|---|---|---|
| Flujo SDD | `/speckit.constitution → specify → clarify → plan → tasks → analyze → implement` | Feature Spec (Requirements-First / Design-First / Quick Plan) → `requirements.md → design.md → tasks.md` |
| Reglas / constitución | `.specify/memory/constitution.md` | Steering files en `.kiro/steering/` |
| Spec del problema | Idéntica — se la pegás a `/speckit.specify` | Idéntica — se la pegás al crear el Feature Spec |
| Spec del MCP (`spec-mcp.md`) | Idéntica → SDD genera `server.py` | Idéntica → SDD genera `server.py` |
| Registrar el MCP | `claude mcp add items-api -- uv run server.py` | Editar `.kiro/settings/mcp.json` |
| Spec de la Skill (`spec-skill.md`) | Idéntica → SDD genera `SKILL.md` en `.claude/skills/items-ops/` | Idéntica → SDD genera `SKILL.md` en `.kiro/skills/items-ops/` |
| Verificar MCP | `claude mcp list`, `/mcp` | Panel MCP de Kiro / `/mcp` en el chat |

---

## 7. Referencias

**Fundamentos (opcional, solo si querés el porqué):**
- 3Blue1Brown — *But what is a neural network?* y la serie de Deep Learning /
  atención (`youtube.com/@3blue1brown`). El video de atención es `eMlx5fFNoYc`.

**Docs oficiales:**
- 🟧 Spec Kit — `github.com/github/spec-kit`
- 🟧 Claude Code — `docs.claude.com` (instalación nativa, `claude mcp`, Skills)
- 🟪 Kiro — `kiro.dev/docs` (specs, steering, mcp, skills, powers)
- 🟩 MCP — `modelcontextprotocol.io` (SDK Python `mcp`)
- 🟩 uv — `docs.astral.sh/uv`

---

## ✅ Antes del taller

- [ ] Elegí tu camino (A o B).
- [ ] Completé el checklist de "entorno listo" de mi camino.
- [ ] Pegué el output del checklist en el canal del grupo.
- [ ] Leí el refresher de Flask + SQLite.
