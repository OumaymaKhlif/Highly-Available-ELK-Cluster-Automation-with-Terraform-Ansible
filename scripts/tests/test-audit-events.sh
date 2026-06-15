#!/bin/bash
# ============================================================================
# Test des événements Auditbeat dans Elasticsearch
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo "=== Test des événements Auditbeat ==="

# Vérifier l'existence de l'index
INDEX_EXISTS=$(curl -sk -o /dev/null -w "%{http_code}" -u "${ES_USER}:${ES_PASS}" \
  --cacert "${CA}" "${ES_HOST}/auditbeat-*" 2>/dev/null)

if [[ "${INDEX_EXISTS}" == "200" ]]; then
  echo -e "${GREEN}[PASS]${NC} Index auditbeat-* existe"
else
  echo -e "${RED}[FAIL]${NC} Index auditbeat-* non trouvé"
  exit 1
fi

# Compter les événements
COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/auditbeat-*/_count" 2>/dev/null | jq -r '.count')
echo "Nombre total d'événements Auditbeat: ${COUNT}"

if [[ "${COUNT}" -gt 0 ]]; then
  echo -e "${GREEN}[PASS]${NC} Des événements Auditbeat sont présents"
else
  echo -e "${RED}[FAIL]${NC} Aucun événement Auditbeat"
  exit 1
fi

# Vérifier les modules
echo ""
echo "--- Événements par module ---"
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/auditbeat-*/_search?size=0" \
  -H "Content-Type: application/json" \
  -d '{
    "aggs": {
      "modules": {
        "terms": { "field": "event.module", "size": 10 }
      }
    }
  }' 2>/dev/null | jq -r '.aggregations.modules.buckets[] | "\(.key): \(.doc_count)"'

echo ""
echo -e "${GREEN}[DONE]${NC} Test Auditbeat terminé"
