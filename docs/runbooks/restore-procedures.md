# Procédures de Restauration

## Restauration depuis un Snapshot

### Lister les snapshots disponibles
```bash
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_snapshot/elk_backup/_all?pretty
```

### Restaurer un snapshot complet
```bash
# Fermer les index à restaurer (si ils existent)
curl -sk -u elastic:PASSWORD -X POST \
  https://10.110.188.20:9200/INDEX_NAME/_close

# Restaurer
curl -sk -u elastic:PASSWORD -X POST \
  "https://10.110.188.20:9200/_snapshot/elk_backup/SNAPSHOT_NAME/_restore" \
  -H "Content-Type: application/json" \
  -d '{
    "indices": "*",
    "ignore_unavailable": true,
    "include_global_state": false
  }'
```

### Restaurer un index spécifique
```bash
curl -sk -u elastic:PASSWORD -X POST \
  "https://10.110.188.20:9200/_snapshot/elk_backup/SNAPSHOT_NAME/_restore" \
  -H "Content-Type: application/json" \
  -d '{
    "indices": "logstash-2024.01.15",
    "ignore_unavailable": true,
    "include_global_state": false
  }'
```

### Suivre la progression
```bash
curl -sk -u elastic:PASSWORD \
  https://10.110.188.20:9200/_snapshot/elk_backup/SNAPSHOT_NAME/_status?pretty
```

---

## Restauration d'un nœud ES complet

1. Recréer la VM via Terraform si nécessaire
2. Relancer le playbook Ansible pour le nœud :
```bash
ansible-playbook playbooks/01-elasticsearch.yml --limit es-data-01
ansible-playbook playbooks/02-security.yml --limit es-data-01
```
3. Le nœud rejoint le cluster et les shards se réallouent

---

## Restauration complète du cluster (disaster recovery)

1. Provisionner les VMs :
```bash
cd terraform && terraform apply
```

2. Déployer le cluster :
```bash
cd ansible && ansible-playbook playbooks/site.yml
```

3. Enregistrer le dépôt de snapshots :
```bash
ansible-playbook playbooks/08-snapshot-ilm.yml
```

4. Restaurer depuis le dernier snapshot :
```bash
curl -sk -u elastic:PASSWORD -X POST \
  "https://10.110.188.20:9200/_snapshot/elk_backup/LATEST_SNAPSHOT/_restore?wait_for_completion=true" \
  -H "Content-Type: application/json" \
  -d '{"indices": "*", "include_global_state": false}'
```
