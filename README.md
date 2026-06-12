# Taller: Spec-Driven Development + Skills para DevOps

Repo de **materiales para participantes**. El caso del taller: tu equipo de
DevOps registra **issues de infraestructura** en una API local; sobre eso
construís un MCP, una skill que opera los issues **y analiza logs**, una skill
que genera el **reporte HTML**, y al final empaquetás todo en un **plugin**.
**No hay código pre-hecho a propósito:** todo lo generás vos **vía SDD**.

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
| `recursos/problema.md` | Spec del problema → genera la **API de issues** | Bloque 3 |
| `recursos/spec-mcp.md` | Spec del **MCP** `issues-api` → genera `server.py` | Bloque 4 |
| `recursos/spec-skill.md` | Spec de la skill **`issues-ops`** → genera `SKILL.md` | Bloque 4 |
| `recursos/seed.sh` | Carga ~8 issues de ejemplo vía `POST`/`PUT` (poblar la base) | Bloque 4 |
| `recursos/spec-logs.md` | Spec de evolución: la skill **aprende a leer logs** | Bloque 5 |
| `recursos/logs/` | 3 archivos (~3900 líneas): gateway + services + infra, con incidentes que solo se resuelven **correlacionando entre archivos** | Bloque 5 |
| `recursos/spec-report.md` | Spec de la skill **`issues-report`** (reporte HTML) | Bloque 6 |
| `recursos/spec-plugin.md` | Spec del empaquetado **`devops-issues`** (plugin/Power) | Bloque 6 |
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
`init_db()`, el seed, `GET /issues/<id>` y el `PUT`): esa la generás vos vía SDD
en el Bloque 3 a partir de `recursos/problema.md`.

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

## 2. Construir la API de issues vía SDD (Bloque 3)

> Antes de empezar: **estimá** cuánto tardarías a mano (DB + Flask + 5 endpoints
> + validación de enums + seed + curl). Anotá el número y comparalo con el
> tiempo real.

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
curl http://127.0.0.1:5000/issues
curl -X POST http://127.0.0.1:5000/issues -H "Content-Type: application/json" \
  -d '{"title":"Cert TLS por vencer","service":"cert-monitor","severity":"medium"}'
curl -X PUT http://127.0.0.1:5000/issues/1 -H "Content-Type: application/json" \
  -d '{"status":"investigating"}'
curl http://127.0.0.1:5000/issues/1
```

---

## 3. MCP + Skill (Bloque 4)

**La API del Bloque 3 debe estar corriendo.**

**Poblá la base** (el Bloque 5 lo necesita — suma ~8 issues, 2 resueltos):

```bash
./recursos/seed.sh                          # http://127.0.0.1:5000
./recursos/seed.sh http://127.0.0.1:5001    # si la levantaste en otro puerto
```

### 3.1 Scaffold del proyecto MCP (los dos caminos)
```bash
uv init mcp-issues && cd mcp-issues
uv venv && source .venv/bin/activate
uv add "mcp[cli]" httpx
```

### 3.2 Generá el `server.py` vía SDD (pegá `recursos/spec-mcp.md`)
- 🟧 **[A]** `/speckit.specify` (pegá `spec-mcp.md`) → `plan` → `tasks` → `implement`
- 🟪 **[B]** Feature Spec con `spec-mcp.md` (Quick Plan si vas ajustado)

### 3.3 Registrá el MCP
```bash
# 🟧 [A]
claude mcp add issues-api -- uv --directory "$(pwd)" run server.py
claude mcp list          # debe aparecer issues-api
# dentro de Claude Code: /mcp   (debe mostrar 4 tools)
```
```json
// 🟪 [B] — .kiro/settings/mcp.json (ver recursos/examples/mcp.json.example)
{
  "mcpServers": {
    "issues-api": {
      "command": "uv",
      "args": ["--directory", "/ruta/absoluta/a/mcp-issues", "run", "server.py"],
      "disabled": false
    }
  }
}
```

### 3.4 Generá la skill `issues-ops` vía SDD (pegá `recursos/spec-skill.md`)
- 🟧 **[A]** `/speckit.specify` → `plan` → `tasks` → `implement`
  → queda en `.claude/skills/issues-ops/SKILL.md`. Si la carpeta es nueva:
  `/reload-skills` o reiniciá Claude Code.
- 🟪 **[B]** Feature Spec con `spec-skill.md` → `.kiro/skills/issues-ops/SKILL.md`
  (respetá la subcarpeta con el nombre).

### 3.5 Probar
Pedile al agente: **"listá los issues abiertos y marcá el de los pods en
CrashLoop como investigating"**. Debe usar la skill + las tools del MCP
(incluido `update_issue`). Bonus: pedile resolver un issue **sin** darle la
solución — la skill te la tiene que exigir.

---

## 4. La skill aprende a leer logs (Bloque 5)

En `recursos/logs/` hay 3 archivos: `gateway.log`, `services.log` e `infra.log`
(~3900 líneas). Hay varios incidentes enterrados. **Probá primero con grep si
querés** — `grep ERROR` te va a dar decenas de errores que se auto-resuelven y
unos cuantos 504/502… pero **ninguna causa raíz**: las causas son líneas INFO
inocentes en OTRO archivo, minutos u horas antes del síntoma. Esto no se
resuelve con regex; se resuelve **correlacionando entre archivos**. Para eso
está el LLM — y de paso ves el superpoder de SDD: no escribís una skill nueva,
**cambiás la spec y se regenera**.

1. Evolucioná la skill vía SDD (pegá `recursos/spec-logs.md`):
   - 🟧 **[A]** `/speckit.specify` → `implement` (actualiza el mismo `SKILL.md`)
   - 🟪 **[B]** Feature Spec (Quick Plan recomendado)
2. Corré el análisis: **"analizá los logs de `recursos/logs/`"** (pasale la
   ruta absoluta de la carpeta si no la encuentra).
3. Qué tiene que pasar: la skill construye **cadenas causales que cruzan
   archivos** (un evento inocente en una capa → el síntoma en otra), detecta
   una **periodicidad**, una **tendencia** que tarda horas en explotar y una
   **ráfaga con ventana exacta**; **actualiza** los issues existentes que esos
   hallazgos explican (sin duplicar), **crea** los genuinamente nuevos y
   **descarta** los errores ruidosos con justificación.
4. Verificá con `curl http://127.0.0.1:5000/issues` o pidiendo la lista.

---

## 5. Reporte HTML + plugin (Bloque 6)

### 5.1 La segunda skill: `issues-report` (pegá `recursos/spec-report.md`)
Genera un **reporte HTML autocontenido** alimentado solo por
`issues-api:list_issues`. Probá: **"armá el reporte de issues"** → abrí
`issues-report.html` en el navegador.

### 5.2 Empaquetá todo: `devops-issues` (pegá `recursos/spec-plugin.md`)
Las 2 skills + el MCP en una unidad instalable:

- 🟧 **[A]** plugin de Claude Code:
  ```text
  devops-issues/
  ├── .claude-plugin/plugin.json   ← name, description, version
  ├── skills/
  │   ├── issues-ops/SKILL.md
  │   └── issues-report/SKILL.md
  └── .mcp.json                    ← registra issues-api
  ```
  Instalá (marketplace local + `/plugin`) y **reiniciá la sesión**.
- 🟪 **[B]** Power de Kiro (MCP + steering; las skills adentro si tu versión lo
  soporta, si no quedan en `.kiro/skills/`).

### 5.3 Prueba integrada final
En sesión nueva, sin registrar nada a mano:
**"analizá los logs de `recursos/logs/` y después regenerá el reporte"** — una
skill actualiza la tabla, la otra la consume, el MCP conecta todo. 🎉

---

## 🔧 Troubleshooting rápido

- **`uv` / `uvx` "command not found":** reabrí la terminal o agregá `~/.local/bin` al PATH.
- **Python < 3.11:** `uv python install 3.12`.
- **Puerto 5000 en macOS (¡frecuente!):** es AirPlay Receiver (403 con body vacío). Desactivalo o cambiá de puerto. Diagnóstico: `lsof -nP -iTCP:5000 -sTCP:LISTEN`.
- **Flask viejo (`'Flask' object has no attribute 'get'`):** `uv run --python 3.12 --with flask app.py`.
- **MCP con 0 tools / no conecta:** corré el server a mano para ver errores en stderr; **nunca `print()` a stdout** (corrompe el JSON-RPC); usá **ruta absoluta** en `--directory`; abrí sesión nueva (descubre las tools al inicio).
- **No aparecen los `/speckit.*` (A):** `ls .claude/commands/`, reiniciá Claude Code; usá `--integration claude`.
- **No veo el panel Specs (B):** abrí una **carpeta** (no un archivo suelto) con File → Open Folder.
- **La skill no encuentra los logs:** pasale la **ruta absoluta** de la carpeta `logs/` o copiala dentro de tu proyecto.
- **El análisis se queda solo con los ERRORs:** la spec pide buscar periodicidad, tendencias y ventanas aunque no haya ERROR; si el `SKILL.md` regenerado perdió eso, repetí `implement`. Pista: ¿qué pasa cada hora en punto?
- **El análisis duplica issues:** la spec exige comparar con `list_issues` antes de crear; revisá que el `SKILL.md` regenerado conserve esa regla.
- **El plugin no aparece (A):** estructura exacta `.claude-plugin/plugin.json` + `skills/<nombre>/SKILL.md`; sesión nueva tras instalar; `/plugin` para ver el estado.
