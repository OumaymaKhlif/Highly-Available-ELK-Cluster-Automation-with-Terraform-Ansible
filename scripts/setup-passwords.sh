#!/bin/bash
# ============================================================================
# Configuration des mots de passe des utilisateurs Elasticsearch
# Usage: ./scripts/setup-passwords.sh
# ============================================================================
set -euo pipefail

ES_HOST="https://10.110.188.20:9200"
CA_CERT="/etc/elasticsearch/certs/ca.crt"
ELASTIC_PASSWORD="Ch@ngeMe!ELK2024"
KIBANA_PASSWORD="K1bana\$ecure2024"
LOGSTASH_PASSWORD="L0gstash\$ecure2024"
BEATS_PASSWORD="B3ats\$ecure2024"

echo "=== Configuration des mots de passe Elasticsearch ==="

echo "[1/4] Configuration du mot de passe kibana_system..."
curl -sk -u "elastic:${ELASTIC_PASSWORD}" \
  -X POST "${ES_HOST}/_security/user/kibana_system/_password" \
  -H "Content-Type: application/json" \
  --cacert "${CA_CERT}" \
  -d "{\"password\":\"${KIBANA_PASSWORD}\"}"
echo ""

echo "[2/4] Création du rôle logstash_writer_role..."
curl -sk -u "elastic:${ELASTIC_PASSWORD}" \
  -X PUT "${ES_HOST}/_security/role/logstash_writer_role" \
  -H "Content-Type: application/json" \
  --cacert "${CA_CERT}" \
  -d '{
    "cluster": ["manage_index_templates", "monitor", "manage_ilm"],
    "indices": [{"names": ["logstash-*","filebeat-*","metricbeat-*","auditbeat-*","heartbeat-*"],
    "privileges": ["write","create_index","manage","auto_configure"]}]
  }'
echo ""

echo "[3/4] Création de l'utilisateur logstash_writer..."
curl -sk -u "elastic:${ELASTIC_PASSWORD}" \
  -X POST "${ES_HOST}/_security/user/logstash_writer" \
  -H "Content-Type: application/json" \
  --cacert "${CA_CERT}" \
  -d "{\"password\":\"${LOGSTASH_PASSWORD}\",\"roles\":[\"logstash_writer_role\"],\"full_name\":\"Logstash Writer\"}"
echo ""

echo "[4/4] Création de l'utilisateur beats_writer..."
curl -sk -u "elastic:${ELASTIC_PASSWORD}" \
  -X POST "${ES_HOST}/_security/user/beats_writer" \
  -H "Content-Type: application/json" \
  --cacert "${CA_CERT}" \
  -d "{\"password\":\"${BEATS_PASSWORD}\",\"roles\":[\"beats_writer_role\",\"kibana_admin\"],\"full_name\":\"Beats Writer\"}"
echo ""

echo "=== Mots de passe configurés ==="
