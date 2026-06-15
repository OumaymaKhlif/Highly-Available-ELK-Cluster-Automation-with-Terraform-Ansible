# Troubleshooting — ELK HA Cluster

## Elasticsearch

### Cluster RED
```bash
# Vérifier les shards non assignés
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cat/shards?v&s=state

# Voir les raisons d'allocation échouée
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_cluster/allocation/explain?pretty

# Forcer la réallocation si nécessaire
curl -sk -u elastic:PASSWORD -X POST https://10.110.188.20:9200/_cluster/reroute?retry_failed=true
```

### Nœud ne rejoint pas le cluster
1. Vérifier les logs : `journalctl -u elasticsearch -f`
2. Vérifier les certificats TLS : dates d'expiration, CA commune
3. Vérifier `cluster.name` identique sur tous les nœuds
4. Vérifier `discovery.seed_hosts` pointe vers les 3 masters
5. Vérifier la connectivité réseau : `nc -zv 10.110.188.10 9300`

### Heap / OOM
```bash
# Vérifier l'utilisation JVM
curl -sk -u elastic:PASSWORD https://10.110.188.20:9200/_nodes/stats/jvm?pretty
```
- Heap doit être à 50% de la RAM physique
- Ne jamais dépasser 30 GB

### Bootstrap check échoué
- `vm.max_map_count` : `sysctl vm.max_map_count` doit être 262144
- `memlock unlimited` : vérifier `/etc/security/limits.d/99-elasticsearch.conf`
- Swap désactivé : `swapon -s` doit être vide

## Kibana

### Kibana ne démarre pas
```bash
journalctl -u kibana -f
```
- Vérifier la connexion ES : `curl -sk https://10.110.188.20:9200` depuis le nœud Kibana
- Vérifier le mot de passe `kibana_system`
- Vérifier les certificats dans `/etc/kibana/certs/`

### Erreur "Kibana server is not ready yet"
- ES n'est pas encore prêt ou les credentials sont incorrects
- Attendre 2-3 minutes après le démarrage d'ES

## Logstash

### Pipeline ne démarre pas
```bash
journalctl -u logstash -f
# Tester la config
/usr/share/logstash/bin/logstash --config.test_and_exit -f /etc/logstash/conf.d/
```

### Dead Letter Queue pleine
```bash
ls -la /var/lib/logstash/dead_letter_queue/
```

## HAProxy / Keepalived

### VIP ne répond pas
```bash
# Vérifier qui détient la VIP
ip addr show | grep 10.110.188.100

# Vérifier Keepalived
systemctl status keepalived
journalctl -u keepalived -f

# Vérifier HAProxy
systemctl status haproxy
curl http://10.110.188.50:8404/stats
```

### Backend DOWN dans HAProxy
- Vérifier le service backend : `nc -zv IP PORT`
- Vérifier les health checks dans haproxy.cfg

## Beats

### Beats ne s'envoie pas
```bash
# Vérifier la connectivité vers la destination
# Metricbeat/Auditbeat/Heartbeat → ES coordinating
nc -zv 10.110.188.20 9200

# Filebeat → Logstash
nc -zv 10.110.188.30 5044

# Vérifier les logs
journalctl -u metricbeat -f
journalctl -u auditbeat -f
journalctl -u filebeat -f
journalctl -u heartbeat-elastic -f
```

## Certificats

### Certificat expiré
```bash
# Vérifier la date d'expiration
openssl x509 -in /etc/elasticsearch/certs/es-master-01.crt -noout -dates

# Régénérer les certificats
ansible-playbook playbooks/02-security.yml
```
