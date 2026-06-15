# ============================================================================
# Variables du module proxmox-vm
# ============================================================================

variable "vm_name" {
  description = "Nom de la VM"
  type        = string
}

variable "proxmox_node" {
  description = "Nœud Proxmox cible"
  type        = string
}

variable "template_id" {
  description = "ID du template à cloner"
  type        = number
}

variable "cores" {
  description = "Nombre de vCPU"
  type        = number
}

variable "memory" {
  description = "RAM en MB"
  type        = number
}

variable "disk_size" {
  description = "Taille du disque en GB"
  type        = number
}

variable "storage_pool" {
  description = "Pool de stockage Proxmox"
  type        = string
}

variable "ip_address" {
  description = "Adresse IP statique"
  type        = string
}

variable "network_cidr" {
  description = "CIDR du réseau"
  type        = number
}

variable "network_gateway" {
  description = "Passerelle réseau"
  type        = string
}

variable "network_bridge" {
  description = "Bridge réseau Proxmox"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
}

variable "ssh_user" {
  description = "Utilisateur SSH"
  type        = string
  default     = "ubuntu"
}

variable "dns_servers" {
  description = "Serveurs DNS"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "tags" {
  description = "Tags pour la VM"
  type        = list(string)
  default     = []
}
