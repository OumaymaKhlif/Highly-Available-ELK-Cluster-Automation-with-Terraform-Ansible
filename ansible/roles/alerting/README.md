# Rôle Ansible : alerting

Ce rôle configure la surveillance active et proactive dans Kibana en utilisant l'API REST de l'alerteur Kibana.

## Actions principales

1. **Attente de disponibilité** : Patiente jusqu'à ce que l'interface web Kibana soit opérationnelle et réponde correctement.
2. **Connecteur d'Index** : Crée un connecteur d'action de type Index Elasticsearch pointant vers l'index `elk-alerts`.
3. **Règles d'alertes configurées** :
   - **SSH Bruteforce Detection** : Détecte plus de 10 tentatives d'authentification en échec en 1 minute.
   - **Service DOWN (Heartbeat)** : Déclenche une alerte si un service du cluster ELK est détecté hors ligne.
   - **CPU Usage High** : Déclenche une alerte si la charge vCPU dépasse 90%.
   - **File Integrity - Critical File Modified** : Alerte immédiatement si un fichier système sensible (`/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, ou configuration SSH) subit une modification non autorisée.
