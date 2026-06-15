# Rôle Ansible : logstash

Ce rôle installe et configure Logstash 9.x sur les nœuds d'ingestion.

## Actions principales

1. **Installation de Logstash** : Installe le paquet officiel de Logstash.
2. **Gestion des Certificats** : Copie la CA et les certificats TLS requis pour sécuriser l'input Beats et la communication vers Elasticsearch.
3. **Configuration globale (`logstash.yml`)** :
   - Configure les paramètres système de Logstash (chemins, monitoring).
4. **Configuration du Heap JVM** : Configure la mémoire maximale allouée au processus Logstash.
5. **Déploiement des pipelines** :
   - Pipelines globaux configurés via `pipelines.yml`.
   - Pipeline d'ingestion principale (`pipeline.conf`) : Entrée Beats (5044/TCP), filtrage syslog/audit et sortie sécurisée vers les serveurs ES Coordinating.
   - Pipeline d'audit dédiée (`filebeat-audit-pipeline.conf`) : Parse et traite les logs de Filebeat.
