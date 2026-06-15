# Rôle Ansible : metricbeat

Ce rôle déploie Metricbeat sur tous les serveurs du cluster pour monitorer les performances système et applicatives.

## Actions principales

1. **Installation de Metricbeat** : Installe le service Metricbeat officiel via APT.
2. **Gestion des Certificats** : Copie la CA pour authentifier la connexion TLS vers Elasticsearch.
3. **Configuration Metricbeat** :
   - Envoi direct des métriques collectées vers les serveurs ES Coordinating.
   - Utilise l'utilisateur `beats_writer` pour l'indexation.
4. **Modules Activés** :
   - `system` : Récupération périodique des métriques CPU, mémoire, disque, réseau et processus système.
   - `elasticsearch` (sur les nœuds ES uniquement) : Collecte interne de l'état du cluster et des nœuds.
5. **Dashboards** : Importe les tableaux de bord système préconfigurés dans Kibana.
