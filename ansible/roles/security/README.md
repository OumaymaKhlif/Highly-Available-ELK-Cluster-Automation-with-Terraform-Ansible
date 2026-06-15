# Rôle Ansible : security

Ce rôle configure la sécurité TLS du cluster. Il génère et distribue les certificats requis pour sécuriser les communications internes et externes du cluster ELK.

## Actions principales

1. **Création du instances.yml** (sur `es-master-01` uniquement) : Génère la liste de toutes les adresses IP et noms de domaine de toutes les VMs.
2. **Génération de la CA et des Certificats** (sur `es-master-01` uniquement) :
   - Utilise `elasticsearch-certutil ca` pour générer une Autorité de Certification locale.
   - Utilise `elasticsearch-certutil cert` pour signer les certificats de chaque machine (Elasticsearch, Kibana, Logstash).
3. **Rapatriement local** : Télécharge tous les certificats générés sur la machine de contrôle Ansible locale (dans `/tmp/elk-certs`).
4. **Distribution et permissions** : Copie la CA, le certificat du nœud et sa clé privée correspondante sur chaque VM cible avec des permissions Unix strictes (ex. `0600` pour la clé privée).
