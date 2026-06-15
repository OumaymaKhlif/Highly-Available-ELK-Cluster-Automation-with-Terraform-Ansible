# Rôle Ansible : haproxy

Ce rôle installe et configure la couche de répartition de charge et de haute disponibilité à l'aide d'HAProxy et Keepalived.

## Actions principales

1. **Installation des services** : Installe `haproxy` et `keepalived` sur les Load Balancers du cluster.
2. **Configuration Keepalived** :
   - Configure la VIP (`10.110.188.100`) sur l'interface réseau active.
   - Configure les priorités (`MASTER` avec priorité 101 sur `lb-01`, `BACKUP` avec priorité 100 sur `lb-02`).
   - Configure un script de vérification (`chk_haproxy`) pour déclencher une bascule automatique de la VIP si le processus HAProxy s'arrête.
3. **Configuration HAProxy** :
   - Expose l'interface HTTPS pour Kibana sur le port 5601 (répartition de charge en mode round-robin vers `kibana-01` et `kibana-02`).
   - Expose l'interface HTTPS pour Elasticsearch sur le port 9200 (répartition de charge vers les nœuds `es-coord-01` et `es-coord-02`).
   - Active une page de statistiques accessible sur le port 8404.
