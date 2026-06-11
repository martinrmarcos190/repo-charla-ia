#!/usr/bin/env bash
# seed.sh — carga datos de ejemplo en el inventario VÍA LA API (POST /models).
#
# No toca la base de datos directamente: usa el endpoint, así funciona igual sin
# importar cómo esté implementada la API (Camino A o B) y no spoilea la solución.
#
# Uso:
#   ./seed.sh                          # usa http://127.0.0.1:5000
#   ./seed.sh http://127.0.0.1:5001    # otro host/puerto
#   API_BASE=http://127.0.0.1:5001 ./seed.sh
#
# Requiere la API del Bloque 3 corriendo.

set -euo pipefail

API_BASE="${1:-${API_BASE:-http://127.0.0.1:5000}}"

# name|framework|accuracy
MODELS=(
  "bert-base-uncased|pytorch|0.91"
  "distilbert-sst2|pytorch|0.89"
  "xgboost-fraud|sklearn|0.94"
  "lightgbm-ltv|sklearn|0.87"
  "whisper-small|pytorch|0.82"
  "yolov8n|pytorch|0.78"
  "llama3-8b-lora|pytorch|0.85"
  "efficientnet-b0|tensorflow|0.80"
  "randomforest-churn|sklearn|0.83"
  "t5-small-summary|pytorch|0.79"
)

echo "→ API: $API_BASE"

if ! curl -fsS "$API_BASE/health" >/dev/null 2>&1; then
  echo "✗ No puedo conectar a $API_BASE/health"
  echo "  ¿Está corriendo la API del Bloque 3?"
  echo "  En macOS, el puerto 5000 suele estar tomado por AirPlay (responde 403):"
  echo "  desactivá el Receptor de AirPlay o levantá la API en otro puerto."
  exit 1
fi

echo "✓ API viva. Cargando ${#MODELS[@]} modelos…"
echo

ok=0
for entry in "${MODELS[@]}"; do
  IFS='|' read -r name framework accuracy <<< "$entry"
  if resp=$(curl -fsS -X POST "$API_BASE/models" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"$name\",\"framework\":\"$framework\",\"accuracy\":$accuracy}"); then
    echo "  ✓ $name ($framework, acc=$accuracy) → $resp"
    ok=$((ok + 1))
  else
    echo "  ✗ $name — falló el POST"
  fi
done

echo
echo "Listo: $ok/${#MODELS[@]} cargados."
echo "Verificá:  curl $API_BASE/models"
