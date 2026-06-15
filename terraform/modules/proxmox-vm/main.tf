# ============================================================================
# Module réutilisable - VM Proxmox avec cloud-init
# ============================================================================

terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
  }
}

resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.proxmox_node
  tags      = var.tags

  # Clonage depuis le template Ubuntu 22.04
  clone {
    vm_id = var.template_id
    full  = true
  }

  # Agent QEMU pour récupérer les infos réseau
  agent {
    enabled = true
  }

  # CPU
  cpu {
    cores = var.cores
    type  = "host"
  }

  # Mémoire
  memory {
    dedicated = var.memory
  }

  # Disque principal
  disk {
    datastore_id = var.storage_pool
    size         = var.disk_size
    interface    = "scsi0"
  }

  # Interface réseau
  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  # Configuration cloud-init
  initialization {
    ip_config {
      ipv4 {
        address = "${var.ip_address}/${var.network_cidr}"
        gateway = var.network_gateway
      }
    }

    user_account {
      keys     = [trimspace(file(var.ssh_public_key_path))]
      username = var.ssh_user
    }

    dns {
      servers = var.dns_servers
    }
  }

  # Attendre que la VM soit démarrée et le réseau prêt
  lifecycle {
    ignore_changes = [
      initialization[0].user_account,
    ]
  }
}
