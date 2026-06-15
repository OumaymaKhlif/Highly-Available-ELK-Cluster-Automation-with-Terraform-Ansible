# Procédures de Failover

## Failover Master Elasticsearch

### Détection
- Heartbeat détecte le master DOWN
- `_cluster/health` montre le nombre de nœuds réduit

### Procédure automatique
Le cluster élit automatiquement un nouveau master parmi les 3 master-eligible nodes (quorum = 2).

### Vérification
```bash
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cat/master?v
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cluster/health?pretty
```

### Restauration du nœud
```bash
ssh -i ~/.ssh/elk_key ubuntu@10.110.188.10
sudo systemctl start elasticsearch
# Le nœud rejoint automatiquement le cluster
```

---

## Failover Data Node

### Impact
- Les shards primaires sur le nœud perdu deviennent des primaires à partir des replicas
- Le cluster passe en YELLOW jusqu'à la réallocation complète

### Vérification
```bash
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cat/shards?v&s=state
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cluster/health?pretty
```

### Restauration
```bash
ssh -i ~/.ssh/elk_key ubuntu@10.110.188.13
sudo systemctl start elasticsearch
# Les shards se réallouent automatiquement
```

---

## Failover Kibana

### Détection
HAProxy détecte le backend DOWN via les health checks (interval 5s, fall 3).

### Procédure automatique
HAProxy redirige automatiquement vers le Kibana restant.

### Vérification
```bash
# Accès via VIP doit toujours fonctionner
curl -sk https://10.110.188.60:5601
```

---

## Failover Load Balancer

### Détection
Keepalived détecte la panne via VRRP (advert_int 1s).

### Procédure automatique
La VIP (10.110.188.60) bascule automatiquement vers lb-02 (BACKUP priority 100).

### Vérification
```bash
# Sur lb-02
ip addr show | grep 10.110.188.60
```

---

## Failover Logstash

### Impact
Filebeat est configuré avec `loadbalance: true` et bascule automatiquement vers le Logstash restant.

### Vérification
```bash
nc -zv 10.110.188.31 5044  # Logstash-02 toujours actif
```
