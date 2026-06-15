# ============================================================================
# ELK HA Cluster - Valeurs Concrètes
# Adapter les valeurs Proxmox avant exécution
# ============================================================================

# --- Connexion Proxmox ---
proxmox_endpoint  = "https://10.110.188.77:8006"
proxmox_api_token = "terraform@pam!terraform-token=VOTRE_SECRET_ICI"
proxmox_node      = "pve" # Adapter au nom réel du nœud Proxmox

# --- Réseau ---
network_bridge  = "vmbr0"
network_cidr    = 22
network_gateway = "10.110.188.1"
dns_servers     = ["8.8.8.8", "8.8.4.4"]

# --- Template ---
template_id         = 9000
ssh_public_key_path = "~/.ssh/elk_key.pub"
ssh_user            = "ubuntu"

# --- Stockage ---
storage_pool = "local-lvm"

# ============================================================================
# Définition de toutes les VMs du cluster ELK
# ============================================================================
vm_definitions = {

  # --- Elasticsearch Masters (3 nœuds) ---
  "es-master-01" = {
    cores      = 2
    memory     = 4096
    disk_size  = 20
    ip_address = "10.110.188.10"
    tags       = ["elasticsearch", "master"]
  }
  "es-master-02" = {
    cores      = 2
    memory     = 4096
    disk_size  = 20
    ip_address = "10.110.188.11"
    tags       = ["elasticsearch", "master"]
  }
  "es-master-03" = {
    cores      = 2
    memory     = 4096
    disk_size  = 20
    ip_address = "10.110.188.12"
    tags       = ["elasticsearch", "master"]
  }

  # --- Elasticsearch Data Nodes (3 nœuds) ---
  "es-data-01" = {
    cores      = 2
    memory     = 6144
    disk_size  = 50
    ip_address = "10.110.188.13"
    tags       = ["elasticsearch", "data"]
  }
  "es-data-02" = {
    cores      = 2
    memory     = 6144
    disk_size  = 50
    ip_address = "10.110.188.14"
    tags       = ["elasticsearch", "data"]
  }
  "es-data-03" = {
    cores      = 2
    memory     = 6144
    disk_size  = 50
    ip_address = "10.110.188.15"
    tags       = ["elasticsearch", "data"]
  }

  # --- Elasticsearch Coordinating Nodes (2 nœuds) ---
  "es-coord-01" = {
    cores      = 2
    memory     = 2048
    disk_size  = 10
    ip_address = "10.110.188.20"
    tags       = ["elasticsearch", "coordinating"]
  }
  "es-coord-02" = {
    cores      = 2
    memory     = 2048
    disk_size  = 10
    ip_address = "10.110.188.21"
    tags       = ["elasticsearch", "coordinating"]
  }

  # --- Logstash (2 nœuds) ---
  "logstash-01" = {
    cores      = 2
    memory     = 3072
    disk_size  = 10
    ip_address = "10.110.188.30"
    tags       = ["logstash"]
  }
  "logstash-02" = {
    cores      = 2
    memory     = 3072
    disk_size  = 10
    ip_address = "10.110.188.31"
    tags       = ["logstash"]
  }

  # --- Kibana (2 nœuds) ---
  "kibana-01" = {
    cores      = 2
    memory     = 2048
    disk_size  = 10
    ip_address = "10.110.188.40"
    tags       = ["kibana"]
  }
  "kibana-02" = {
    cores      = 2
    memory     = 2048
    disk_size  = 10
    ip_address = "10.110.188.41"
    tags       = ["kibana"]
  }

  # --- Load Balancers HAProxy (2 nœuds) ---
  "lb-01" = {
    cores      = 1
    memory     = 1024
    disk_size  = 5
    ip_address = "10.110.188.50"
    tags       = ["haproxy", "loadbalancer"]
  }
  "lb-02" = {
    cores      = 1
    memory     = 1024
    disk_size  = 5
    ip_address = "10.110.188.51"
    tags       = ["haproxy", "loadbalancer"]
  }
}
