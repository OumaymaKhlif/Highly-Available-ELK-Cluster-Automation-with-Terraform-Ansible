# Rôle Ansible : common

Ce rôle prépare le système d'exploitation de base sur tous les nœuds du cluster pour garantir un fonctionnement optimal et conforme aux exigences d'Elasticsearch.

## Actions principales

1. **Désactivation permanente du Swap** : Désactive le swap pour éviter que les performances d'Elasticsearch ne s'effondrent à cause de la pagination mémoire.
2. **Configuration sysctl** :
   - Configure `vm.max_map_count=262144` pour permettre à Elasticsearch d'avoir assez de zones de mémoire virtuelle.
   - Ajuste `fs.file-max=2097152` pour supporter un grand nombre de fichiers ouverts.
3. **Limites Système (`limits.conf`)** :
   - Configure les limites de descripteurs de fichiers (`nofile`) et de processus (`nproc`) pour l'utilisateur `elasticsearch` et d'autres.
4. **Configuration du dépôt APT Elastic** :
   - Ajoute la clé GPG officielle d'Elastic.
   - Ajoute le dépôt officiel APT pour la version 9.x.
5. **Résolution DNS Interne (`/etc/hosts`)** :
   - Génère et déploie le fichier `/etc/hosts` sur chaque machine pour permettre une résolution de noms DNS stable entre tous les nœuds sans dépendre d'un serveur DNS externe.
