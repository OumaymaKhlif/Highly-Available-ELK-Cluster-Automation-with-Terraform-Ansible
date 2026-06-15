#!/bin/bash
# ============================================================================
# Test de failover master Elasticsearch
# Arrête un master, vérifie la nouvelle élection, redémarre
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"
SSH_KEY="~/.ssh/elk_key"
MASTER_IP="10.110.188.10"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "=== Test de failover Master ==="

# Identifier le master actuel
CURRENT_MASTER=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cat/master?h=node" 2>/dev/null | tr -d '[:space:]')
echo "Master actuel: ${CURRENT_MASTER}"

# Arrêter es-master-01
echo -e "${YELLOW}[ACTION]${NC} Arrêt d'Elasticsearch sur es-master-01 (${MASTER_IP})..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${MASTER_IP} \
  "sudo systemctl stop elasticsearch" 2>/dev/null

echo "Attente de 30s pour la nouvelle élection..."
sleep 30

# Vérifier le nouveau master
NEW_MASTER=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cat/master?h=node" 2>/dev/null | tr -d '[:space:]')
HEALTH=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cluster/health" 2>/dev/null | jq -r '.status')

echo "Nouveau master: ${NEW_MASTER}"
echo "Santé cluster: ${HEALTH}"

if [[ "${NEW_MASTER}" != "${CURRENT_MASTER}" || "${CURRENT_MASTER}" != "es-master-01" ]] && [[ -n "${NEW_MASTER}" ]]; then
  echo -e "${GREEN}[PASS]${NC} Failover master réussi"
else
  echo -e "${RED}[FAIL]${NC} Pas de failover détecté"
fi

sleep 200

# Redémarrer es-master-01
echo -e "${YELLOW}[ACTION]${NC} Redémarrage d'Elasticsearch sur es-master-01..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${MASTER_IP} \
  "sudo systemctl start elasticsearch" 2>/dev/null

echo "Attente de 30s pour le rejoindre du cluster..."
sleep 30

NODES=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/_cluster/health" 2>/dev/null | jq -r '.number_of_nodes')
echo "Nombre de nœuds: ${NODES}"
echo -e "${GREEN}[DONE]${NC} Test failover master terminé"
