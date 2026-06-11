"""Refresher Flask + SQLite (stdlib) — API local de inventario de modelos.

Correr (sin instalar nada, con uv — pinneá el Python para no agarrar uno viejo):
    uv run --python 3.12 --with flask app.py

OJO macOS: AirPlay Receiver ocupa el puerto 5000 (devuelve 403). Desactivalo en
Ajustes del Sistema → General → AirDrop y Handoff, o cambiá el puerto.

Probar:
    curl http://127.0.0.1:5000/health
    curl http://127.0.0.1:5000/models
    curl -X POST http://127.0.0.1:5000/models -H "Content-Type: application/json" \
      -d '{"name":"bert-base","framework":"pytorch","accuracy":0.91}'
    curl http://127.0.0.1:5000/models/1

Nota: este archivo es la *referencia* del facilitador. En el Bloque 3 los
participantes lo generan vía SDD a partir de recursos/problema.md.
"""
import sqlite3
from datetime import datetime, timezone

from flask import Flask, g, jsonify, request

app = Flask(__name__)
DB = "inventory.db"

SEED = [
    {"name": "resnet50", "framework": "pytorch", "accuracy": 0.76},
    {"name": "xgb-churn", "framework": "sklearn", "accuracy": 0.88},
]


def get_db():
    if "db" not in g:
        g.db = sqlite3.connect(DB)
        g.db.row_factory = sqlite3.Row
    return g.db


@app.teardown_appcontext
def close_db(exc):
    db = g.pop("db", None)
    if db is not None:
        db.close()


def init_db():
    conn = sqlite3.connect(DB)
    conn.execute(
        """
        CREATE TABLE IF NOT EXISTS models (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            framework TEXT NOT NULL,
            accuracy REAL,
            created_at TEXT
        )
        """
    )
    cur = conn.execute("SELECT COUNT(*) FROM models")
    if cur.fetchone()[0] == 0:
        now = datetime.now(timezone.utc).isoformat()
        conn.executemany(
            "INSERT INTO models (name, framework, accuracy, created_at) "
            "VALUES (:name, :framework, :accuracy, :created_at)",
            [{**m, "created_at": now} for m in SEED],
        )
    conn.commit()
    conn.close()


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


@app.get("/models")
def list_models():
    rows = get_db().execute("SELECT * FROM models ORDER BY id").fetchall()
    return jsonify([dict(r) for r in rows])


@app.get("/models/<int:model_id>")
def get_model(model_id):
    row = get_db().execute(
        "SELECT * FROM models WHERE id = ?", (model_id,)
    ).fetchone()
    if row is None:
        return jsonify({"error": "not found"}), 404
    return jsonify(dict(row))


@app.post("/models")
def add_model():
    data = request.get_json(silent=True) or {}
    if not data.get("name") or not data.get("framework"):
        return jsonify({"error": "name y framework son obligatorios"}), 400
    created_at = datetime.now(timezone.utc).isoformat()
    db = get_db()
    cur = db.execute(
        "INSERT INTO models (name, framework, accuracy, created_at) "
        "VALUES (?, ?, ?, ?)",
        (data["name"], data["framework"], data.get("accuracy"), created_at),
    )
    db.commit()
    return jsonify({"id": cur.lastrowid}), 201


if __name__ == "__main__":
    init_db()
    app.run(host="127.0.0.1", port=5000, debug=True)
