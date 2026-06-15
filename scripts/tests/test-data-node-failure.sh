#!/bin/bash
# ============================================================================
# Test de panne d'un data node
# Arrête un data node, vérifie la réallocation des shards
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"
SSH_KEY="~/.ssh/elk_key"
DATA_IP="10.110.188.13"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "=== Test de panne Data Node ==="

# Compter les shards avant
SHARDS_BEFORE=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cluster/health" 2>/dev/null | jq -r '.active_shards')
echo "Shards actifs avant: ${SHARDS_BEFORE}"

# Arrêter es-data-01
echo -e "${YELLOW}[ACTION]${NC} Arrêt d'Elasticsearch sur es-data-01 (${DATA_IP})..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${DATA_IP} \
  "sudo systemctl stop elasticsearch" 2>/dev/null

echo "Attente de 60s pour la réallocation des shards..."
sleep 60

# Vérifier la santé
HEALTH=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cluster/health" 2>/dev/null)
STATUS=$(echo "${HEALTH}" | jq -r '.status')
RELOCATING=$(echo "${HEALTH}" | jq -r '.relocating_shards')
UNASSIGNED=$(echo "${HEALTH}" | jq -r '.unassigned_shards')

echo "Status: ${STATUS}"
echo "Shards en réallocation: ${RELOCATING}"
echo "Shards non assignés: ${UNASSIGNED}"

if [[ "${STATUS}" != "red" ]]; then
  echo -e "${GREEN}[PASS]${NC} Cluster n'est pas RED après perte d'un data node"
else
  echo -e "${RED}[FAIL]${NC} Cluster est RED"
fi

# Redémarrer es-data-01
echo -e "${YELLOW}[ACTION]${NC} Redémarrage d'Elasticsearch sur es-data-01..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${DATA_IP} \
  "sudo systemctl start elasticsearch" 2>/dev/null

echo "Attente de 60s pour la récupération..."
sleep 60

FINAL_STATUS=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cluster/health" 2>/dev/null | jq -r '.status')
echo "Status final: ${FINAL_STATUS}"
echo -e "${GREEN}[DONE]${NC} Test data node failure terminé"
