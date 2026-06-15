#!/bin/bash
# ============================================================================
# Script de déploiement complet du cluster ELK HA
# Usage: ./scripts/deploy.sh [phase]
# ============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
ANSIBLE_DIR="${PROJECT_DIR}/ansible"
TERRAFORM_DIR="${PROJECT_DIR}/terraform"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info()  { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Phase 1: Terraform ---
deploy_infra() {
  log_info "=== Phase 1: Provisioning VMs avec Terraform ==="
  cd "${TERRAFORM_DIR}"
  terraform init
  terraform validate
  terraform plan -out=tfplan
  log_warn "Vérifiez le plan ci-dessus. Appuyez sur Entrée pour appliquer ou Ctrl+C pour annuler."
  read -r
  terraform apply tfplan
  log_info "=== Infrastructure provisionnée ==="
  cd "${PROJECT_DIR}"
}

# --- Phase 2: Ansible ---
deploy_config() {
  log_info "=== Phase 2: Configuration avec Ansible ==="
  cd "${ANSIBLE_DIR}"

  log_info "Vérification de la syntaxe..."
  ansible-playbook playbooks/site.yml --syntax-check

  log_info "Lancement du déploiement complet..."
  ansible-playbook playbooks/site.yml -v

  log_info "=== Configuration terminée ==="
  cd "${PROJECT_DIR}"
}

# --- Déploiement individuel par phase ---
deploy_phase() {
  local phase=$1
  cd "${ANSIBLE_DIR}"
  log_info "Déploiement de la phase: ${phase}"
  ansible-playbook "playbooks/${phase}" -v
  cd "${PROJECT_DIR}"
}

# --- Main ---
case "${1:-all}" in
  infra)
    deploy_infra
    ;;
  config)
    deploy_config
    ;;
  all)
    deploy_infra
    log_info "Attente de 60s pour le démarrage des VMs..."
    sleep 60
    deploy_config
    ;;
  *)
    deploy_phase "$1"
    ;;
esac

log_info "=== Déploiement terminé ==="
