#!/bin/bash
# ============================================================================
# Test de résilience complet — Lance tous les tests séquentiellement
# Usage: ./scripts/tests/test-resilience.sh
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PASS=0; FAIL=0

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

run_test() {
  local test_name=$1
  local test_script=$2
  echo ""
  echo -e "${YELLOW}======================================${NC}"
  echo -e "${YELLOW} ${test_name}${NC}"
  echo -e "${YELLOW}======================================${NC}"
  if bash "${SCRIPT_DIR}/${test_script}"; then
    echo -e "${GREEN}[PASS]${NC} ${test_name}"
    ((PASS++))
  else
    echo -e "${RED}[FAIL]${NC} ${test_name}"
    ((FAIL++))
  fi
  echo "Attente de 30s entre les tests..."
  sleep 30
}

echo "============================================"
echo " SUITE DE TESTS DE RÉSILIENCE — ELK HA"
echo " Date: $(date)"
echo "============================================"

run_test "Santé du cluster"          "test-cluster-health.sh"
run_test "Failover Master"           "test-master-failover.sh"
run_test "Panne Data Node"           "test-data-node-failure.sh"
run_test "Failover Kibana"           "test-kibana-failover.sh"
run_test "Failover Logstash"         "test-logstash-failover.sh"
run_test "Snapshot et Restauration"  "test-snapshot-restore.sh"
run_test "Événements Auditbeat"      "test-audit-events.sh"
run_test "Logs Filebeat Kibana"      "test-filebeat-kibana-logs.sh"
run_test "Uptime Heartbeat"          "test-heartbeat-uptime.sh"

echo ""
echo "============================================"
echo " RÉSULTATS"
echo "============================================"
echo -e " Réussis : ${GREEN}${PASS}${NC}"
echo -e " Échoués : ${RED}${FAIL}${NC}"
echo " Total   : $((PASS + FAIL))"
echo "============================================"

if [[ ${FAIL} -gt 0 ]]; then
  exit 1
fi
