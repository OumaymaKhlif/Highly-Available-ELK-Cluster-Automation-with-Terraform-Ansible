# ============================================================================
# Variables - Proxmox Connection
# ============================================================================

variable "proxmox_endpoint" {
  description = "URL de l'API Proxmox VE"
  type        = string
}

variable "proxmox_api_token" {
  description = "Token API Proxmox (format: user@realm!token-name=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Nom du nœud Proxmox cible"
  type        = string
}

# ============================================================================
# Variables - Template & Cloud-Init
# ============================================================================

variable "template_id" {
  description = "ID du template VM Ubuntu 22.04 cloud-init"
  type        = number
  default     = 9000
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH à injecter via cloud-init"
  type        = string
  default     = "~/.ssh/elk_key.pub"
}

variable "ssh_user" {
  description = "Utilisateur SSH créé par cloud-init"
  type        = string
  default     = "ubuntu"
}

# ============================================================================
# Variables - Réseau
# ============================================================================

variable "network_bridge" {
  description = "Bridge réseau Proxmox"
  type        = string
  default     = "vmbr0"
}

variable "network_cidr" {
  description = "CIDR du sous-réseau"
  type        = number
  default     = 22
}

variable "network_gateway" {
  description = "Passerelle réseau"
  type        = string
  default     = "10.110.188.1"
}

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

# ============================================================================
# Variables - Stockage
# ============================================================================

variable "storage_pool" {
  description = "Pool de stockage Proxmox pour les disques VM"
  type        = string
  default     = "local-lvm"
}

# ============================================================================
# Variables - Définition des VMs
# ============================================================================

variable "vm_definitions" {
  description = "Map de toutes les VMs à créer (nom => specs)"
  type = map(object({
    cores      = number
    memory     = number # en MB
    disk_size  = number # en GB
    ip_address = string
    tags       = list(string)
  }))
}
