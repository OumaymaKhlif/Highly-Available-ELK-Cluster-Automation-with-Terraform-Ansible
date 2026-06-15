# ============================================================================
# Outputs - Adresses IP de toutes les VMs du cluster
# ============================================================================

output "all_vm_ips" {
  description = "Map de toutes les VMs avec leurs adresses IP"
  value = {
    for name, vm in module.elk_vms : name => vm.ip_address
  }
}

output "elasticsearch_master_ips" {
  description = "IPs des nœuds master Elasticsearch"
  value = [
    for name, vm in module.elk_vms : vm.ip_address
    if contains(try(var.vm_definitions[name].tags, []), "master")
  ]
}

output "elasticsearch_data_ips" {
  description = "IPs des nœuds data Elasticsearch"
  value = [
    for name, vm in module.elk_vms : vm.ip_address
    if contains(try(var.vm_definitions[name].tags, []), "data")
  ]
}

output "kibana_ips" {
  description = "IPs des nœuds Kibana"
  value = [
    for name, vm in module.elk_vms : vm.ip_address
    if contains(try(var.vm_definitions[name].tags, []), "kibana")
  ]
}

output "loadbalancer_ips" {
  description = "IPs des load balancers"
  value = [
    for name, vm in module.elk_vms : vm.ip_address
    if contains(try(var.vm_definitions[name].tags, []), "loadbalancer")
  ]
}

output "ssh_command_example" {
  description = "Exemple de commande SSH pour se connecter"
  value       = "ssh -i ~/.ssh/elk_key ubuntu@<IP>"
}
