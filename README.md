# 🔍 ELK Stack Demo - Elasticsearch + Logstash + Kibana

> **Présenté par : Ines Tmimi**  
> **Matière : Bases de données avancées**  
> **ENSIT - 3ème année Génie Informatique GLID**  
> **Année Académique 2025-2026**

---

##  Description

Ce projet démontre l'utilisation complète du **ELK Stack** pour le monitoring et l'analyse de logs d'une application e-commerce en temps réel.

### Composants

| Composant | Rôle | Port |
|-----------|------|------|
| **Elasticsearch** | Moteur de recherche et stockage | 9200 |
| **Logstash** | Collecte et transformation des logs | 5044, 9600 |
| **Kibana** | Visualisation et dashboards | 5601 |

---

##  Démarrage rapide

### Prérequis

- Docker Desktop installé et lancé
- Au moins **6 Go de RAM** disponibles
- Ports 9200, 5601, 5044 libres

### Installation

```bash
# 1. Cloner ou télécharger le projet
cd elk-stack-demo

# 2. Rendre les scripts exécutables
chmod +x *.sh

# 3. Lancer le setup (télécharge les images et démarre tout)
./setup.sh

# 4. Attendre 2-3 minutes que tout soit prêt
```

### Vérification

```bash
# Elasticsearch
curl http://localhost:9200

# Kibana
# Ouvrir dans le navigateur : http://localhost:5601
```

---

##  Lancer la démo

```bash
# Démo interactive pour la présentation
./demo.sh
```

La démo montre :
1. Vérification d'Elasticsearch
2.  Rôle de Logstash (INPUT → FILTER → OUTPUT)
3.  Recherche d'erreurs
4.  Recherche full-text ("timeout")
5.  Recherche combinée (service + niveau)
6.  Agrégations (statistiques par service)
7.  Détection d'activité suspecte
8.  Introduction à Kibana

---

##  Logs de démonstration

Le fichier `logs/application.log` contient **30 logs réalistes** simulant :

-  **INFO** : Connexions, commandes, paiements réussis
-  **WARNING** : Temps de réponse élevés, tentatives suspectes
-  **ERROR** : Timeout, carte refusée, exceptions
-  **CRITICAL** : OutOfMemory, disque plein, attaque DDoS

---

##  Générer des logs en temps réel

Pour impressionner pendant la présentation :

```bash
# Dans un terminal séparé
./generate-logs.sh
```

Ce script génère des logs aléatoires toutes les 1-3 secondes.  
Vous pouvez voir les nouveaux logs apparaître dans Kibana en temps réel !

---

##  Configuration Kibana

### Créer un Data View

1. Ouvrir http://localhost:5601
2. Menu ☰ → **Stack Management**
3. **Data Views** → **Create data view**
4. Paramètres :
   - Name: `Application Logs`
   - Index pattern: `app-logs-*`
   - Timestamp field: `@timestamp`
5. Cliquer **Save data view to Kibana**

### Explorer les données

1. Menu ☰ → **Discover**
2. Sélectionner le Data View créé
3. Utiliser les filtres :
   - `level: ERROR` pour voir les erreurs
   - `service: payment-service` pour un service spécifique

---

##  Structure du projet

```
elk-stack-demo/
├── docker-compose.yml      # Configuration des 3 services
├── setup.sh                # Script d'installation
├── demo.sh                 # Script de démonstration
├── generate-logs.sh        # Générateur de logs temps réel
├── cleanup.sh              # Nettoyage des containers
├── README.md               # Ce fichier
│
├── logstash/
│   ├── config/
│   │   └── logstash.yml    # Configuration Logstash
│   └── pipeline/
│       └── logstash.conf   # Pipeline de traitement
│
└── logs/
    └── application.log     # Logs de démonstration
```

---

##  Exemples de requêtes Elasticsearch

### Toutes les erreurs
```json
GET /app-logs-*/_search
{
  "query": {
    "terms": { "level": ["ERROR", "CRITICAL"] }
  }
}
```

### Recherche full-text
```json
GET /app-logs-*/_search
{
  "query": {
    "match": { "message": "timeout" }
  }
}
```

### Agrégation par service
```json
GET /app-logs-*/_search
{
  "size": 0,
  "aggs": {
    "par_service": {
      "terms": { "field": "service" }
    }
  }
}
```

---

##  Nettoyage

```bash
# Arrêter et supprimer tous les containers et volumes
./cleanup.sh
```

---

##  Ressources

- [Documentation Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html)
- [Documentation Logstash](https://www.elastic.co/guide/en/logstash/current/index.html)
- [Documentation Kibana](https://www.elastic.co/guide/en/kibana/current/index.html)
- [GitHub Elasticsearch](https://github.com/elastic/elasticsearch)

---

##  Licence

Ce projet est créé à des fins éducatives pour le cours de Bases de données avancées à l'ENSIT.

---

**Merci pour votre attention ! **
