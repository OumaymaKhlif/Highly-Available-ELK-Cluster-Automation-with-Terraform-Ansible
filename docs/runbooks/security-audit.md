# Audit de Sécurité — Procédures

## Sources de données

| Besoin | Index ES | Champs clés |
|--------|----------|-------------|
| Connexions Kibana (IP, browser) | `filebeat-kibana-*` | `source.ip`, `user.name`, `user_agent.name` |
| Actions Kibana (dashboard, query) | `filebeat-kibana-*` | `event.action`, `kibana.saved_object.type` |
| Modifications fichiers config | `auditbeat-*` | `file.path`, `file.action`, `user.name` |
| Commandes exécutées | `auditbeat-*` | `process.executable`, `process.args`, `user.name` |
| Connexions SSH | `filebeat-system-*` | `source.ip`, `user.name`, `event.outcome` |
| Requêtes ES par user | `filebeat-elasticsearch-*` | `user.name`, `url.path` |
| Services DOWN | `heartbeat-*` | `monitor.name`, `monitor.status` |
| Trafic HAProxy | `filebeat-haproxy-*` | `source.ip`, `haproxy.backend_name` |

---

## Rechercher un utilisateur spécifique

### Dans Kibana → Discover

Index : `filebeat-system-*`
```
user.name: "ubuntu" AND event.action: "ssh_login"
```

Index : `auditbeat-*`
```
user.name: "root" AND event.module: "auditd"
```

### Via API
```bash
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/filebeat-system-*/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {"match": {"user.name": "ubuntu"}},
    "sort": [{"@timestamp": "desc"}],
    "size": 20
  }'
```

---

## Tracer une adresse IP

```bash
# Connexions SSH depuis une IP
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/filebeat-system-*/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {"match": {"source.ip": "10.110.188.50"}},
    "sort": [{"@timestamp": "desc"}],
    "size": 20
  }'
```

---

## Voir les modifications de fichiers critiques

```bash
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/auditbeat-*/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          {"match": {"event.module": "file_integrity"}},
          {"range": {"@timestamp": {"gte": "now-24h"}}}
        ]
      }
    },
    "sort": [{"@timestamp": "desc"}],
    "size": 50
  }'
```

---

## Analyser les navigateurs accédant à Kibana

Index : `filebeat-kibana-*`

Dans Kibana Discover, filtrer :
- `user_agent.name` — Navigateur (Chrome, Firefox…)
- `user_agent.os.name` — OS client
- `source.ip` — IP source

---

## Vérifier les tentatives d'accès refusées

```bash
# Erreurs 401/403 dans ES
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/filebeat-elasticsearch-*/_search \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "should": [
          {"match": {"http.response.status_code": 401}},
          {"match": {"http.response.status_code": 403}}
        ],
        "minimum_should_match": 1
      }
    },
    "sort": [{"@timestamp": "desc"}],
    "size": 20
  }'
```

---

## Dashboards Kibana recommandés

1. **Observability → Uptime** — Heartbeat, statut de tous les services
2. **Security → Alerts** — Alertes SSH bruteforce, FIM, service down
3. **Discover** — Recherche libre dans tous les index
4. **Dashboard Auditbeat** — Vue d'ensemble des événements d'audit
5. **Dashboard Filebeat System** — Logs SSH et authentification
