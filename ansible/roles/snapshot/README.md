# Rôle Ansible : snapshot

Ce rôle met en œuvre la politique de sauvegarde des données du cluster Elasticsearch.

## Actions principales

1. **Configuration du Point de Partage** : S'assure que le répertoire `/mnt/es-snapshots` dispose des bons droits Unix pour l'utilisateur `elasticsearch`.
2. **Script d'enregistrement de dépôt** : Déploie et exécute un script d'API REST pour déclarer le répertoire en tant que dépôt de snapshot partagé (`elk_backup`) dans le cluster.
3. **Automatisation cron** :
   - Déploie le script `snapshot-cron.sh` exécutant les snapshots quotidiens.
   - Gère le nettoyage des anciens snapshots en appliquant une politique de rétention (conserve les 30 derniers snapshots).
   - Configure une tâche planifiée système cron pour lancer ce processus automatiquement tous les jours à 02h30.
