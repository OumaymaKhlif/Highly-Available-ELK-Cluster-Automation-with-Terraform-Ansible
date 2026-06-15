# 🚀 Highly Available ELK Stack Automation (Terraform + Ansible)

## Overview
This project demonstrates the design and deployment of a **production-ready, highly available ELK 9.4.1 cluster** using Infrastructure as Code (IaC).  
It focuses on automation, scalability, security, and observability in a distributed environment.


## Architecture

The infrastructure is fully automated and includes **14 VMs** across 6 node types:

| Rôle | Count | IPs |
|------|-------|-----|
| ES Master | 3 | 10.110.188.10-12 |
| ES Data | 3 | 10.110.188.13-15 |
| ES Coordinating | 2 | 10.110.188.20-21 |
| Logstash | 2 | 10.110.188.30-31 |
| Kibana | 2 | 10.110.188.40-41 |
| HAProxy/Keepalived | 2 | 10.110.188.50-51 (VIP: .60) |

## Quick Start

### Prerequisites

- Proxmox VE with Ubuntu 22.04 cloud-init template (VM ID 9000)
- Terraform >= 1.5
- Ansible >= 2.14
- SSH key pair at `~/.ssh/elk_key`

### Deploy

```bash
# 1. Provision infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars  # Edit with your Proxmox token
terraform init && terraform apply

# 2. Configure cluster
cd ../ansible
ansible-playbook playbooks/site.yml

# Or use the deploy script
./scripts/deploy.sh all
```

### Access

- **Kibana**: https://10.110.188.60:5601 (via VIP)
- **Elasticsearch**: https://10.110.188.60:9200 (via VIP)
- **HAProxy Stats**: http://10.110.188.50:8404/stats

### Resilience Tests

```bash
./scripts/tests/test-resilience.sh
```

## Security

- TLS on transport and HTTP layers
- RBAC with dedicated users (kibana_system, logstash_writer, beats_writer)
- Audit logging on ES and Kibana
- Auditbeat on all nodes (kernel audit + file integrity)
- Filebeat collecting SSH, ES, Kibana, Logstash, HAProxy logs

## Monitoring

- **Metricbeat**: CPU, RAM, disk, network + ES metrics on all nodes
- **Auditbeat**: System audit, file integrity on all nodes
- **Filebeat**: Application and auth logs on all nodes
- **Heartbeat**: Uptime monitoring from LB nodes

## 🎯 Objective

To simulate a real-world **enterprise ELK deployment** and gain hands-on experience in:

- DevOps & DevSecOps practices
- Distributed systems
- Infrastructure automation
- Cloud-native architecture principles

---

## 👩‍💻 Authors

- **Saba Kallel**
- **Oumayma Khlif**

---

## 🚀 Status

✔ Completed  
✔ Production-ready architecture simulation  
✔ Fully automated deployment

---

## Documentation

- [Architecture](docs/architecture.md)
- [Installation Guide](docs/installation-guide.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Failover Procedures](docs/runbooks/failover-procedures.md)
- [Restore Procedures](docs/runbooks/restore-procedures.md)
- [Security Audit](docs/runbooks/security-audit.md)
