#!/bin/bash
# ============================================================================
# Test de failover Logstash
# ============================================================================
set -euo pipefail

SSH_KEY="~/.ssh/elk_key"
LOGSTASH_IP="10.110.188.30"
LOGSTASH_IP2="10.110.188.31"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "=== Test de failover Logstash ==="

# Vérifier que les deux Logstash sont actifs
echo "Vérification des ports Beats (5044)..."
for IP in ${LOGSTASH_IP} ${LOGSTASH_IP2}; do
  if nc -z -w3 "${IP}" 5044 2>/dev/null; then
    echo -e "${GREEN}[OK]${NC} Logstash ${IP}:5044 accessible"
  else
    echo -e "${RED}[KO]${NC} Logstash ${IP}:5044 non accessible"
  fi
done

# Arrêter logstash-01
echo -e "${YELLOW}[ACTION]${NC} Arrêt de Logstash sur logstash-01 (${LOGSTASH_IP})..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${LOGSTASH_IP} \
  "sudo systemctl stop logstash" 2>/dev/null

echo "Attente de 10s..."
sleep 10

# Vérifier que logstash-02 est toujours actif
if nc -z -w3 "${LOGSTASH_IP2}" 5044 2>/dev/null; then
  echo -e "${GREEN}[PASS]${NC} Logstash-02 toujours actif — ingestion continue"
else
  echo -e "${RED}[FAIL]${NC} Logstash-02 non accessible"
fi

# Redémarrer logstash-01
echo -e "${YELLOW}[ACTION]${NC} Redémarrage de Logstash sur logstash-01..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${LOGSTASH_IP} \
  "sudo systemctl start logstash" 2>/dev/null

echo -e "${GREEN}[DONE]${NC} Test failover Logstash terminé"
