# ============================================================================
# ELK HA Cluster - Création de toutes les VMs via module réutilisable
# Utilise for_each sur la map vm_definitions pour créer les 14 VMs
# ============================================================================

module "elk_vms" {
  source   = "./modules/proxmox-vm"
  for_each = var.vm_definitions

  vm_name             = each.key
  proxmox_node        = var.proxmox_node
  template_id         = var.template_id
  cores               = each.value.cores
  memory              = each.value.memory
  disk_size           = each.value.disk_size
  storage_pool        = var.storage_pool
  ip_address          = each.value.ip_address
  network_cidr        = var.network_cidr
  network_gateway     = var.network_gateway
  network_bridge      = var.network_bridge
  ssh_public_key_path = var.ssh_public_key_path
  ssh_user            = var.ssh_user
  dns_servers         = var.dns_servers
  tags                = each.value.tags
}
