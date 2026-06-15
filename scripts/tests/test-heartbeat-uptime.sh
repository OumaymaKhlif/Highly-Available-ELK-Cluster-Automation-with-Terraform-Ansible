#!/bin/bash
# ============================================================================
# Test de l'uptime Heartbeat
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo "=== Test Heartbeat Uptime ==="

INDEX_EXISTS=$(curl -sk -o /dev/null -w "%{http_code}" -u "${ES_USER}:${ES_PASS}" \
  --cacert "${CA}" "${ES_HOST}/heartbeat-*" 2>/dev/null)

if [[ "${INDEX_EXISTS}" == "200" ]]; then
  echo -e "${GREEN}[PASS]${NC} Index heartbeat-* existe"
else
  echo -e "${RED}[FAIL]${NC} Index heartbeat-* non trouvé"
  exit 1
fi

COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/heartbeat-*/_count" 2>/dev/null | jq -r '.count')
echo "Événements Heartbeat total: ${COUNT}"

echo ""
echo "--- Statut par service ---"
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/heartbeat-*/_search?size=0" \
  -H "Content-Type: application/json" \
  -d '{
    "aggs": {
      "monitors": {
        "terms": { "field": "monitor.name", "size": 20 },
        "aggs": {
          "latest": {
            "top_hits": {
              "size": 1,
              "sort": [{"@timestamp": "desc"}],
              "_source": ["monitor.status", "@timestamp"]
            }
          }
        }
      }
    }
  }' 2>/dev/null | jq -r '.aggregations.monitors.buckets[] | "\(.key): \(.latest.hits.hits[0]._source["monitor.status"])"'

DOWN_COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/heartbeat-*/_count" \
  -H "Content-Type: application/json" \
  -d '{"query":{"bool":{"must":[{"match":{"monitor.status":"down"}},{"range":{"@timestamp":{"gte":"now-5m"}}}]}}}' \
  2>/dev/null | jq -r '.count')

echo ""
if [[ "${DOWN_COUNT}" == "0" ]]; then
  echo -e "${GREEN}[PASS]${NC} Aucun service DOWN dans les 5 dernières minutes"
else
  echo -e "${RED}[WARN]${NC} ${DOWN_COUNT} événements DOWN dans les 5 dernières minutes"
fi

echo -e "${GREEN}[DONE]${NC} Test Heartbeat uptime terminé"
