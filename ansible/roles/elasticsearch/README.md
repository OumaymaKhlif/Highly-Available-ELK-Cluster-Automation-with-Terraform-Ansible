# Rôle Ansible : elasticsearch

Ce rôle installe, configure et prépare le service Elasticsearch 9.x sur les nœuds configurés.

## Actions principales

1. **Installation d'Elasticsearch** : Installe la version spécifiée par `elastic_version` depuis le dépôt APT officiel.
2. **Création des répertoires** :
   - Répertoire pour les certificats TLS (`/etc/elasticsearch/certs`).
   - Répertoire pour le dépôt de snapshots (`/mnt/es-snapshots`).
3. **Configuration du nœud (`elasticsearch.yml`)** :
   - Déploie une configuration dynamique adaptée selon le groupe Ansible du nœud (Master-eligible, Data, ou Coordinating).
   - Configure la découverte réseau unicast (`discovery.seed_hosts` et `cluster.initial_master_nodes`).
   - Active les paramètres de sécurité (chiffrement TLS transport/http, audit d'accès).
4. **Configuration JVM** : Déploie les options de Heap JVM définies selon le sizing du nœud.
5. **Overrides systemd** : Configure l'override systemd pour déverrouiller la mémoire (`LimitMEMLOCK=infinity`) et augmenter les descripteurs de fichiers ouverts.
