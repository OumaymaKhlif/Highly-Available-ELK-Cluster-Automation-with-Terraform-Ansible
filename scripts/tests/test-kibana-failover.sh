#!/bin/bash
# ============================================================================
# Test de failover Kibana via HAProxy
# ============================================================================
set -euo pipefail

SSH_KEY="~/.ssh/elk_key"
VIP="10.110.188.60"
KIBANA_IP="10.110.188.40"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "=== Test de failover Kibana ==="

# Vérifier que Kibana est accessible via la VIP
echo "Test d'accès via VIP (${VIP}:5601)..."
HTTP_CODE=$(curl -sk -o /dev/null -w "%{http_code}" "https://${VIP}:5601" 2>/dev/null || echo "000")
echo "Code HTTP VIP: ${HTTP_CODE}"

if [[ "${HTTP_CODE}" =~ ^(200|302)$ ]]; then
  echo -e "${GREEN}[PASS]${NC} Kibana accessible via VIP"
else
  echo -e "${RED}[FAIL]${NC} Kibana non accessible via VIP"
fi

# Arrêter Kibana sur kibana-01
echo -e "${YELLOW}[ACTION]${NC} Arrêt de Kibana sur kibana-01 (${KIBANA_IP})..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${KIBANA_IP} \
  "sudo systemctl stop kibana" 2>/dev/null

echo "Attente de 15s pour la bascule HAProxy..."
sleep 15

# Vérifier que Kibana est toujours accessible via la VIP
HTTP_CODE_AFTER=$(curl -sk -o /dev/null -w "%{http_code}" "https://${VIP}:5601" 2>/dev/null || echo "000")
echo "Code HTTP VIP après failover: ${HTTP_CODE_AFTER}"

if [[ "${HTTP_CODE_AFTER}" =~ ^(200|302)$ ]]; then
  echo -e "${GREEN}[PASS]${NC} Failover Kibana réussi — toujours accessible via VIP"
else
  echo -e "${RED}[FAIL]${NC} Kibana non accessible après failover"
fi

# Redémarrer Kibana
echo -e "${YELLOW}[ACTION]${NC} Redémarrage de Kibana sur kibana-01..."
ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ubuntu@${KIBANA_IP} \
  "sudo systemctl start kibana" 2>/dev/null

echo -e "${GREEN}[DONE]${NC} Test failover Kibana terminé"
