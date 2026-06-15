# ============================================================================
# ELK HA Cluster - Terraform Provider Configuration
# Provider: bpg/proxmox for Proxmox VE
# ============================================================================

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = true # Proxmox utilise un certificat auto-signé par défaut

  ssh {
    agent = false
  }
}
