# Rôle Ansible : auditbeat

Ce rôle déploie Auditbeat sur toutes les VMs pour l'audit de sécurité système et la conformité.

## Actions principales

1. **Installation d'Auditbeat** : Installe Auditbeat officiel.
2. **Gestion des Certificats** : Copie la CA requise pour chiffrer la connexion TLS vers Elasticsearch.
3. **Configuration d'Auditbeat** :
   - Module `auditd` : Configure les règles d'audit du noyau Linux (appels système `execve`, sockets réseau, modifications utilisateur/groupes, configurations système sensibles).
   - Module `file_integrity` (FIM) : Surveille l'intégrité (modifications, suppressions, écritures) de fichiers critiques (ex. `/etc/passwd`, `/etc/shadow`, `/etc/sudoers`, configurations ELK).
   - Module `system` : Audite les activités de login, de processus et d'état des utilisateurs.
4. **Exportation des données** : Indexation directe dans Elasticsearch via le compte `beats_writer`.
