# Guide d'installation — ELK HA Cluster

## Prérequis

### Infrastructure
- Proxmox VE avec accès API
- Template Ubuntu 22.04 cloud-init (VM ID 9000)
- Réseau 10.110.188.0/22, gateway 10.110.188.1
- Bridge réseau `vmbr0`

### Outils
- Terraform >= 1.5
- Ansible >= 2.14
- SSH key pair : `~/.ssh/elk_key` / `~/.ssh/elk_key.pub`

### Proxmox API Token
```
terraform@pam!terraform-token=VOTRE_SECRET
```

## Étape 1 : Provisionner l'infrastructure

```bash
cd terraform

# Configurer les variables
# Éditer terraform.tfvars avec votre token Proxmox API

terraform init
terraform validate
terraform plan
terraform apply
```

Vérifier que les 14 VMs sont créées dans Proxmox.

## Étape 2 : Vérifier la connectivité SSH

```bash
# Tester un nœud
ssh -i ~/.ssh/elk_key ubuntu@10.110.188.10
```

## Étape 3 : Déployer le cluster complet

```bash
cd ansible

# Vérifier la syntaxe
ansible-playbook playbooks/site.yml --syntax-check

# Déployer
ansible-playbook playbooks/site.yml -v
```

### Déploiement par phase

```bash
ansible-playbook playbooks/00-prerequisites.yml    # Préparation système
ansible-playbook playbooks/01-elasticsearch.yml     # Installation ES
ansible-playbook playbooks/02-security.yml          # Certificats TLS
ansible-playbook playbooks/03-start-elasticsearch.yml  # Démarrage + RBAC
ansible-playbook playbooks/04-kibana.yml            # Kibana
ansible-playbook playbooks/05-logstash.yml          # Logstash
ansible-playbook playbooks/06-haproxy.yml           # HAProxy + Keepalived
ansible-playbook playbooks/07-post-deploy.yml       # Beats + Snapshots
ansible-playbook playbooks/08-snapshot-ilm.yml      # ILM (standalone)
ansible-playbook playbooks/09-security-audit.yml    # Vérification audit
ansible-playbook playbooks/10-alerting.yml          # Alertes Kibana
```

## Étape 4 : Vérifications post-déploiement

```bash
# Santé du cluster
curl -sk -u elastic:Ch@ngeMe!ELK2024 https://10.110.188.20:9200/_cluster/health?pretty

# Liste des nœuds
curl -sk -u elastic:Ch@ngeMe!ELK2024 https://10.110.188.20:9200/_cat/nodes?v

# Accès Kibana
# Ouvrir https://10.110.188.100:5601

# Tests de résilience
./scripts/tests/test-resilience.sh
```

## Étape 5 : Sécuriser les mots de passe

En production, chiffrer les mots de passe avec Ansible Vault :

```bash
ansible-vault encrypt_string 'Ch@ngeMe!ELK2024' --name 'es_elastic_password'
```

Puis remplacer les valeurs en clair dans `inventory/group_vars/all.yml`.
