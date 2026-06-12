#!/usr/bin/env bash
# seed.sh — carga issues de ejemplo en el registro VÍA LA API (POST + PUT /issues).
#
# No toca la base de datos directamente: usa los endpoints, así funciona igual
# sin importar cómo esté implementada la API (Camino A o B) y no spoilea la
# solución. Algunos issues correlacionan a propósito con los patrones de
# recursos/logs/app.log (para la demo de análisis de logs del Bloque 5).
#
# Uso:
#   ./seed.sh                          # usa http://127.0.0.1:5000
#   ./seed.sh http://127.0.0.1:5001    # otro host/puerto
#   API_BASE=http://127.0.0.1:5001 ./seed.sh
#
# Requiere la API del Bloque 3 corriendo.

set -euo pipefail

API_BASE="${1:-${API_BASE:-http://127.0.0.1:5000}}"

# title|service|severity|description|proposed_solution
# (los issues de payments-api y api-gateway ya los siembra la propia API al iniciar)
ISSUES=(
  "Backups nocturnos fallan esporádicamente|db-01|medium|El job nightly-backup termina con error algunas noches; causa sin identificar.|Revisar logs de pg_dump y monitoreo del job."
  "Latencia p99 alta tras deploy v2.3.1|auth-service|medium|Desde el último rollout la p99 de /login subió de 180ms a 900ms.|Comparar perfiles antes/después del deploy; posible regresión."
  "Builds lentos por cache misses|ci-runner|low|Los builds tardan 7min; el cache de dependencias casi nunca pega.|Revisar la key del cache y el orden de capas del Dockerfile."
  "Ratio de cache hit bajo en assets|cdn|low|El hit-ratio del CDN está en 62%, esperado >90%.|Revisar headers Cache-Control y normalización de query strings."
  "Pods de worker en CrashLoopBackOff|k8s|high|Tras el upgrade del cluster los workers de cola entraban en CrashLoop.|Pinnear la versión del runtime y subir requests de memoria."
  "Pérdida de eventos en picos de tráfico|logging-pipeline|medium|En picos, el pipeline de logs dropea eventos (buffer lleno).|Aumentar el buffer y activar backpressure en el shipper."
  "Evictions altas en horario pico|redis-cache|medium|Redis expulsa keys calientes a la tarde; maxmemory al límite.|Subir maxmemory o revisar TTLs de sesiones."
  "Resoluciones DNS internas lentas|dns-interno|low|Lookups intermitentes de 2-3s entre servicios internos.|Bajar el TTL negativo y revisar el forwarder."
)

echo "→ API: $API_BASE"

if ! curl -fsS "$API_BASE/health" >/dev/null 2>&1; then
  echo "✗ No puedo conectar a $API_BASE/health"
  echo "  ¿Está corriendo la API del Bloque 3?"
  echo "  En macOS, el puerto 5000 suele estar tomado por AirPlay (responde 403):"
  echo "  desactivá el Receptor de AirPlay o levantá la API en otro puerto."
  exit 1
fi

echo "✓ API viva. Cargando ${#ISSUES[@]} issues…"
echo

ok=0
ids=()
for entry in "${ISSUES[@]}"; do
  IFS='|' read -r title service severity description solution <<< "$entry"
  if resp=$(curl -fsS -X POST "$API_BASE/issues" \
      -H "Content-Type: application/json" \
      -d "{\"title\":\"$title\",\"service\":\"$service\",\"severity\":\"$severity\",\"description\":\"$description\",\"proposed_solution\":\"$solution\"}"); then
    id=$(echo "$resp" | python3 -c "import sys,json;print(json.load(sys.stdin)['id'])" 2>/dev/null || echo "?")
    ids+=("$id")
    echo "  ✓ #$id [$severity] $service — $title"
    ok=$((ok + 1))
  else
    ids+=("?")
    echo "  ✗ $title — falló el POST"
  fi
done

# Dos issues quedan resueltos (demuestra el PUT y puebla la base de conocimiento)
echo
echo "→ Marcando 2 issues como resueltos (PUT)…"
curl -fsS -X PUT "$API_BASE/issues/${ids[4]}" -H "Content-Type: application/json" \
  -d '{"status":"resolved","proposed_solution":"Runtime pinneado a containerd 1.7.x y memoria de los workers subida a 512Mi. Sin reinicios desde el fix."}' >/dev/null \
  && echo "  ✓ #${ids[4]} k8s CrashLoopBackOff → resolved"
curl -fsS -X PUT "$API_BASE/issues/${ids[7]}" -H "Content-Type: application/json" \
  -d '{"status":"resolved","proposed_solution":"TTL negativo bajado a 5s y forwarder apuntado al resolver secundario. Lookups <50ms."}' >/dev/null \
  && echo "  ✓ #${ids[7]} DNS lento → resolved"

echo
echo "Listo: $ok/${#ISSUES[@]} cargados (2 resueltos)."
echo "Verificá:  curl $API_BASE/issues"
