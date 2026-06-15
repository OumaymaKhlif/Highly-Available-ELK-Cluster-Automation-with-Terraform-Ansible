# Architecture — ELK HA Cluster

## Vue d'ensemble

Cluster ELK haute disponibilité déployé sur Proxmox VE via Terraform + Ansible.

## Composants

### Elasticsearch (8 nœuds)

- **3 Master nodes** (10.110.188.10-12) — Quorum = 2, gestion du cluster
- **3 Data nodes** (10.110.188.13-15) — Stockage et indexation, 50 GB disque
- **2 Coordinating nodes** (10.110.188.20-21) — Routage des requêtes, point d'entrée

### Logstash (2 nœuds)

- 10.110.188.30-31
- Pipeline principale : Beats (5044) → Filter → ES (coordinating)
- Pipeline audit : enrichissement des logs Filebeat (geoip, useragent)
- Dead letter queue activée

### Kibana (2 nœuds)

- 10.110.188.40-41
- HTTPS avec TLS
- Connexion via coordinating nodes
- Audit log activé

### Load Balancers (2 nœuds)

- HAProxy : 10.110.188.50-51
- Keepalived VIP : 10.110.188.100
- Frontend Kibana (5601) + ES (9200)
- Health checks sur backends

## Flux réseau

```
Clients → VIP (10.110.188.100)
  → HAProxy → Kibana (5601)
  → HAProxy → ES Coordinating (9200)

Kibana → ES Coordinating (9200/HTTPS)
Logstash → ES Coordinating (9200/HTTPS)
Beats → Logstash (5044/TCP)
ES Coordinating ↔ ES Data ↔ ES Master (9300/TLS transport)
```

## Sécurité

- TLS transport (inter-nœuds) + HTTP (client)
- Certificats générés via `elasticsearch-certutil`
- RBAC : elastic, kibana_system, logstash_writer, beats_writer
- Audit log ES + Kibana activé
- Auditbeat kernel audit sur tous les nœuds

## Monitoring Stack

| Beat | Nœuds | Rôle |
|------|-------|------|
| Metricbeat | 14 | Métriques système + ES |
| Auditbeat | 14 | Audit kernel + FIM |
| Filebeat | 14 | Logs applicatifs |
| Heartbeat | 2 (LB) | Uptime monitoring |

## ILM Policy

| Phase | Durée | Action |
|-------|-------|--------|
| Hot | 7 jours | Rollover |
| Warm | 30 jours | Force merge (1 segment) |
| Cold | 90 jours | Freeze |
| Delete | 365 jours | Suppression |

## Snapshots

- Repository : filesystem `/mnt/es-snapshots`
- SLM : quotidien à 02h30
- Rétention : 30 jours, min 5 / max 30
