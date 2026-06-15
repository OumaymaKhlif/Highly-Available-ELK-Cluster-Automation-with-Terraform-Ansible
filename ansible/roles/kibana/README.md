# Rôle Ansible : kibana

Ce rôle installe et configure Kibana 9.x sur les machines dédiées à la visualisation.

## Actions principales

1. **Installation de Kibana** : Télécharge et installe le paquet Kibana officiel via le gestionnaire de paquets APT.
2. **Gestion des Certificats** : Copie la CA et les certificats TLS de l'hôte dans `/etc/kibana/certs/`.
3. **Configuration du service (`kibana.yml`)** :
   - Configure l'écoute du serveur en HTTPS.
   - Configure les hôtes Elasticsearch cibles (coordinating nodes).
   - Configure le nom d'utilisateur système `kibana_system` et son mot de passe.
   - Active les audits de sécurité Kibana (filtrage et historique d'activités).
