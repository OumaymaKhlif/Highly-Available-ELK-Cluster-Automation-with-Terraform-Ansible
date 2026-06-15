#!/bin/bash
# ============================================================================
# Génération manuelle des certificats TLS (hors Ansible)
# Usage: ./scripts/generate-certs.sh
# ============================================================================
set -euo pipefail

CERTS_DIR="/tmp/elk-certs"
INSTANCES_FILE="/tmp/instances.yml"
ES_BIN="/usr/share/elasticsearch/bin"

echo "=== Génération des certificats TLS pour le cluster ELK ==="

# Créer le répertoire de sortie
mkdir -p "${CERTS_DIR}"

# Générer la CA
echo "[1/3] Génération de la CA..."
${ES_BIN}/elasticsearch-certutil ca --pem --out /tmp/elastic-ca.zip --pass ""
unzip -o /tmp/elastic-ca.zip -d /tmp/

# Créer le fichier instances.yml
cat > "${INSTANCES_FILE}" << 'EOF'
instances:
  - name: "es-master-01"
    ip: ["10.110.188.10"]
    dns: ["es-master-01", "localhost"]
  - name: "es-master-02"
    ip: ["10.110.188.11"]
    dns: ["es-master-02", "localhost"]
  - name: "es-master-03"
    ip: ["10.110.188.12"]
    dns: ["es-master-03", "localhost"]
  - name: "es-data-01"
    ip: ["10.110.188.13"]
    dns: ["es-data-01", "localhost"]
  - name: "es-data-02"
    ip: ["10.110.188.14"]
    dns: ["es-data-02", "localhost"]
  - name: "es-data-03"
    ip: ["10.110.188.15"]
    dns: ["es-data-03", "localhost"]
  - name: "es-coord-01"
    ip: ["10.110.188.20"]
    dns: ["es-coord-01", "localhost"]
  - name: "es-coord-02"
    ip: ["10.110.188.21"]
    dns: ["es-coord-02", "localhost"]
  - name: "kibana-01"
    ip: ["10.110.188.40"]
    dns: ["kibana-01", "localhost"]
  - name: "kibana-02"
    ip: ["10.110.188.41"]
    dns: ["kibana-02", "localhost"]
  - name: "logstash-01"
    ip: ["10.110.188.30"]
    dns: ["logstash-01", "localhost"]
  - name: "logstash-02"
    ip: ["10.110.188.31"]
    dns: ["logstash-02", "localhost"]
EOF

# Générer les certificats
echo "[2/3] Génération des certificats pour tous les nœuds..."
${ES_BIN}/elasticsearch-certutil cert \
  --ca-cert /tmp/ca/ca.crt --ca-key /tmp/ca/ca.key \
  --pem --in "${INSTANCES_FILE}" --out /tmp/elastic-certs.zip --pass ""
unzip -o /tmp/elastic-certs.zip -d /tmp/

# Copier dans le répertoire de sortie
echo "[3/3] Organisation des certificats..."
cp /tmp/ca/ca.crt "${CERTS_DIR}/ca.crt"
for node in es-master-01 es-master-02 es-master-03 es-data-01 es-data-02 es-data-03 \
            es-coord-01 es-coord-02 kibana-01 kibana-02 logstash-01 logstash-02; do
  cp "/tmp/${node}/${node}.crt" "${CERTS_DIR}/${node}.crt"
  cp "/tmp/${node}/${node}.key" "${CERTS_DIR}/${node}.key"
done

echo "=== Certificats générés dans ${CERTS_DIR} ==="
ls -la "${CERTS_DIR}/"
