#!/bin/bash
# ============================================================================
# Test de santé du cluster Elasticsearch
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"

GREEN='\033[0;32m'; RED='\033[0;31m'; NC='\033[0m'

echo "=== Test de santé du cluster ==="

HEALTH=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" "${ES_HOST}/_cluster/health" 2>/dev/null)
STATUS=$(echo "${HEALTH}" | jq -r '.status')
NODES=$(echo "${HEALTH}" | jq -r '.number_of_nodes')
DATA_NODES=$(echo "${HEALTH}" | jq -r '.number_of_data_nodes')

echo "Status: ${STATUS}"
echo "Total nodes: ${NODES}"
echo "Data nodes: ${DATA_NODES}"

if [[ "${STATUS}" == "green" ]]; then
  echo -e "${GREEN}[PASS]${NC} Cluster est GREEN"
elif [[ "${STATUS}" == "yellow" ]]; then
  echo -e "${RED}[WARN]${NC} Cluster est YELLOW"
else
  echo -e "${RED}[FAIL]${NC} Cluster est RED"
  exit 1
fi

echo ""
echo "=== Liste des nœuds ==="
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" "${ES_HOST}/_cat/nodes?v"

echo ""
echo "=== Allocation des shards ==="
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" "${ES_HOST}/_cat/shards?v&s=state" | head -20
