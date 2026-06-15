#!/bin/bash
# ============================================================================
# Test des logs Kibana via Filebeat (IP, browser, user)
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo "=== Test des logs Kibana via Filebeat ==="

# Vérifier l'index filebeat-kibana
INDEX_EXISTS=$(curl -sk -o /dev/null -w "%{http_code}" -u "${ES_USER}:${ES_PASS}" \
  --cacert "${CA}" "${ES_HOST}/filebeat-*" 2>/dev/null)

if [[ "${INDEX_EXISTS}" == "200" ]]; then
  echo -e "${GREEN}[PASS]${NC} Index filebeat-* existe"
else
  echo -e "${RED}[FAIL]${NC} Index filebeat-* non trouvé"
  exit 1
fi

# Compter les événements Kibana
KIBANA_COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/filebeat-*/_count" \
  -H "Content-Type: application/json" \
  -d '{"query":{"match":{"event.module":"kibana"}}}' 2>/dev/null | jq -r '.count')

echo "Événements Filebeat module kibana: ${KIBANA_COUNT}"

# Compter les événements system (SSH)
SYSTEM_COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/filebeat-*/_count" \
  -H "Content-Type: application/json" \
  -d '{"query":{"match":{"event.module":"system"}}}' 2>/dev/null | jq -r '.count')

echo "Événements Filebeat module system: ${SYSTEM_COUNT}"

# Rechercher des événements SSH login
echo ""
echo "--- Derniers événements SSH login ---"
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/filebeat-*/_search?size=5" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {"match": {"event.action": "ssh_login"}},
    "sort": [{"@timestamp": "desc"}],
    "_source": ["@timestamp", "source.ip", "user.name", "event.outcome"]
  }' 2>/dev/null | jq -r '.hits.hits[]._source | "\(.["@timestamp"]) | \(.["source.ip"] // "N/A") | \(.["user.name"] // "N/A") | \(.["event.outcome"] // "N/A")"'

echo ""
echo -e "${GREEN}[DONE]${NC} Test Filebeat Kibana logs terminé"
