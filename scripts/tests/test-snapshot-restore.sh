#!/bin/bash
# ============================================================================
# Test de snapshot et restauration
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
ES_USER="elastic"
ES_PASS="Ch@ngeMe!ELK2024"
CA="/etc/elasticsearch/certs/ca.crt"
REPO="elk_backup"
TEST_INDEX="test-snapshot-restore"
SNAP_NAME="test-snap-$(date +%s)"

GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; NC='\033[0m'

echo "=== Test de snapshot et restauration ==="

# Créer un index de test
echo "[1/5] Création de l'index de test..."
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X PUT "${ES_HOST}/${TEST_INDEX}" \
  -H "Content-Type: application/json" \
  -d '{"settings":{"number_of_replicas":1,"number_of_shards":1}}'
echo ""

# Indexer des documents
echo "[2/5] Indexation de documents de test..."
for i in $(seq 1 10); do
  curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
    -X POST "${ES_HOST}/${TEST_INDEX}/_doc" \
    -H "Content-Type: application/json" \
    -d "{\"message\":\"test document ${i}\",\"timestamp\":\"$(date -u +%FT%TZ)\"}" > /dev/null
done
echo "10 documents indexés"

# Créer le snapshot
echo "[3/5] Création du snapshot: ${SNAP_NAME}..."
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X PUT "${ES_HOST}/_snapshot/${REPO}/${SNAP_NAME}?wait_for_completion=true" \
  -H "Content-Type: application/json" \
  -d "{\"indices\":\"${TEST_INDEX}\",\"ignore_unavailable\":true}"
echo ""

# Supprimer l'index
echo "[4/5] Suppression de l'index..."
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X DELETE "${ES_HOST}/${TEST_INDEX}"
echo ""
sleep 2

# Restaurer le snapshot
echo "[5/5] Restauration du snapshot..."
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  -X POST "${ES_HOST}/_snapshot/${REPO}/${SNAP_NAME}/_restore?wait_for_completion=true" \
  -H "Content-Type: application/json" \
  -d "{\"indices\":\"${TEST_INDEX}\"}"
echo ""
sleep 5

# Vérifier la restauration
COUNT=$(curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" \
  "${ES_HOST}/${TEST_INDEX}/_count" 2>/dev/null | jq -r '.count')
echo "Documents restaurés: ${COUNT}"

if [[ "${COUNT}" == "10" ]]; then
  echo -e "${GREEN}[PASS]${NC} Snapshot/Restore réussi — ${COUNT} documents récupérés"
else
  echo -e "${RED}[FAIL]${NC} Attendu 10 documents, trouvé ${COUNT}"
fi

# Nettoyage
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" -X DELETE "${ES_HOST}/${TEST_INDEX}" > /dev/null
curl -sk -u "${ES_USER}:${ES_PASS}" --cacert "${CA}" -X DELETE "${ES_HOST}/_snapshot/${REPO}/${SNAP_NAME}" > /dev/null
echo -e "${GREEN}[DONE]${NC} Test snapshot/restore terminé"
