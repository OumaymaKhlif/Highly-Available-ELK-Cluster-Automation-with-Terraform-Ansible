# ============================================================================
# Outputs du module proxmox-vm
# ============================================================================

output "vm_id" {
  description = "ID de la VM créée"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "vm_name" {
  description = "Nom de la VM"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "ip_address" {
  description = "Adresse IP de la VM"
  value       = var.ip_address
}
