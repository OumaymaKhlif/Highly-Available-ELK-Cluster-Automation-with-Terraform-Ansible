# Rôle Ansible : heartbeat

Ce rôle installe Heartbeat uniquement sur les Load Balancers pour monitorer de l'extérieur l'Uptime et la disponibilité de tous les services du cluster.

## Actions principales

1. **Installation de Heartbeat** : Installe le service Heartbeat officiel via le gestionnaire APT.
2. **Gestion des Certificats** : Copie la CA pour autoriser le chiffrement TLS lors de l'envoi des événements à Elasticsearch.
3. **Configuration d'Uptime** :
   - Configure 13 moniteurs de type TCP, HTTP et HTTPS.
   - Surveille le statut d'écoute HTTPS des nœuds Kibana et Elasticsearch Coordinating.
   - Surveille le statut TCP des ports internes d'Elasticsearch (9300), de Logstash (5044) et des Load Balancers (VIP).
4. **Exportation** : Envoie les résultats d'Uptime directement à Elasticsearch pour alimentation de l'application Kibana Uptime.
