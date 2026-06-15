# Rôle Ansible : filebeat

Ce rôle installe Filebeat sur tous les serveurs du cluster pour collecter et acheminer les logs applicatifs et système.

## Actions principales

1. **Installation de Filebeat** : Installe le paquet officiel Filebeat.
2. **Gestion des Certificats** : Installe la CA locale pour l'authentification.
3. **Configuration de l'output** : Oriente l'envoi des logs vers la couche Logstash (ports 5044) avec équilibrage de charge (`loadbalance: true`).
4. **Modules Activés et Configurés** :
   - `system` (toutes les VMs) : Collecte syslog et logs d'authentification (`auth.log`).
   - `elasticsearch` (nœuds ES uniquement) : Collecte des logs de serveur, de GC et des journaux d'audit de sécurité d'Elasticsearch.
   - `kibana` (nœuds Kibana uniquement) : Collecte des journaux d'accès et d'audit de Kibana.
   - `logstash` (nœuds Logstash uniquement) : Collecte des logs système de Logstash.
   - `haproxy` (Load Balancers uniquement) : Collecte des logs d'accès HAProxy.
