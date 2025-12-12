#!/bin/bash



# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Fonction pause
pause() {
    echo ""
    echo -e "${CYAN}  ⏎ Appuyez sur ENTRÉE pour continuer...${NC}"
    read
}

# Fonction titre de section
section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}${BOLD}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

clear

# ═══════════════════════════════════════════════════════════════════════
# INTRODUCTION
# ═══════════════════════════════════════════════════════════════════════
echo ""
echo ""
echo -e "${YELLOW}   Scénario : Vous êtes DevOps dans une entreprise e-commerce.${NC}"
echo -e "${YELLOW}     Votre plateforme génère des milliers de logs par minute.${NC}"
echo -e "${YELLOW}     Comment surveiller et diagnostiquer les problèmes rapidement ?${NC}"
echo ""
echo -e "${CYAN}   Solution : ELK Stack !${NC}"
echo -e "${CYAN}     • Logstash   → Collecte et transforme les logs${NC}"
echo -e "${CYAN}     • Elasticsearch → Stocke et indexe pour recherche rapide${NC}"
echo -e "${CYAN}     • Kibana     → Visualise avec des dashboards${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 1 : ELASTICSEARCH
# ═══════════════════════════════════════════════════════════════════════
section "1⃣ ELASTICSEARCH - Le Moteur de Recherche"

echo -e "${WHITE}  Elasticsearch est le cœur du système.${NC}"
echo -e "${WHITE}  Il stocke les données et permet des recherches ultra-rapides.${NC}"
echo ""
sleep 1

echo -e "${CYAN}   Vérification du cluster :${NC}"
echo -e "${YELLOW}  Commande : curl http://localhost:9200${NC}"
echo ""
sleep 1

curl -s http://localhost:9200 | head -20

echo ""
echo -e "${GREEN}  ✓ Cluster 'elk-demo-cluster' opérationnel !${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 2 : LOGSTASH - SON RÔLE
# ═══════════════════════════════════════════════════════════════════════
section "2  LOGSTASH - La Collecte et Transformation"

echo -e "${WHITE}  Logstash a 3 missions :${NC}"
echo ""
echo -e "${CYAN}   INPUT   : Recevoir les logs depuis différentes sources${NC}"
echo -e "${CYAN}               (fichiers, TCP, HTTP, Kafka, bases de données...)${NC}"
echo ""
echo -e "${CYAN}   FILTER  : Transformer et enrichir les données${NC}"
echo -e "${CYAN}               (parser les dates, ajouter la géolocalisation,${NC}"
echo -e "${CYAN}                classifier par sévérité, extraire des champs...)${NC}"
echo ""
echo -e "${CYAN}   OUTPUT  : Envoyer vers Elasticsearch${NC}"
echo -e "${CYAN}               (indexation automatique par date)${NC}"
echo ""

echo -e "${YELLOW}   Notre pipeline Logstash :${NC}"
echo ""


pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 3 : VOIR LES DONNÉES
# ═══════════════════════════════════════════════════════════════════════
section "3️  DONNÉES INDEXÉES - Vérification"

echo -e "${CYAN}  Combien de logs ont été traités ?${NC}"
echo ""
sleep 1

# Compter les documents
TOTAL=$(curl -s "localhost:9200/app-logs-*/_count" | grep -o '"count":[0-9]*' | cut -d':' -f2)

echo -e "${GREEN}   Total de logs indexés : ${WHITE}${BOLD}$TOTAL documents${NC}"
echo ""

# Voir les index
echo -e "${CYAN}   Index créés par Logstash :${NC}"
echo ""
curl -s "localhost:9200/_cat/indices/app-logs-*?v&h=index,docs.count,store.size"

echo ""
echo -e "${GREEN}  ✓ Les logs sont organisés par date (app-logs-YYYY.MM.DD)${NC}"
echo -e "${GREEN}    C'est une best practice pour la gestion du cycle de vie !${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 4 : RECHERCHES ELASTICSEARCH
# ═══════════════════════════════════════════════════════════════════════
section "4️ RECHERCHE - Trouver les ERREURS"

echo -e "${RED}   Alerte ! Un client signale un problème de paiement.${NC}"
echo -e "${CYAN}     Je cherche toutes les erreurs...${NC}"
echo ""
sleep 1

echo -e "${YELLOW}  Requête Elasticsearch :${NC}"
echo '  {
    "query": {
      "terms": { "level": ["ERROR", "CRITICAL"] }
    },
    "sort": [{ "@timestamp": "desc" }]
  }'
echo ""
sleep 1

echo -e "${WHITE}  Résultats :${NC}"
echo ""

curl -s -X GET "localhost:9200/app-logs-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 5,
    "query": {
      "terms": {
        "level": ["ERROR", "CRITICAL"]
      }
    },
    "_source": ["@timestamp", "level", "service", "message"],
    "sort": [{"@timestamp": "desc"}]
  }' | grep -A 30 '"hits" : \[' | head -40

echo ""
echo -e "${GREEN}  ⚡ Erreurs trouvées en ${WHITE}< 10 millisecondes${GREEN} !${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 5 : RECHERCHE FULL-TEXT
# ═══════════════════════════════════════════════════════════════════════
section "5  RECHERCHE FULL-TEXT - \"timeout\""

echo -e "${CYAN}  Je suspecte un problème de base de données...${NC}"
echo -e "${CYAN}  Je cherche le mot \"timeout\" dans tous les messages.${NC}"
echo ""
sleep 1

curl -s -X GET "localhost:9200/app-logs-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "match": {
        "message": "timeout"
      }
    },
    "_source": ["@timestamp", "service", "message", "error_code"]
  }' | grep -A 20 '"hits" : \[' | head -25

echo ""
echo -e "${GREEN}  ✓ Problème identifié : MySQL ne répond pas !${NC}"
echo -e "${GREEN}    → Action : Vérifier le serveur de base de données.${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 6 : RECHERCHE PAR SERVICE
# ═══════════════════════════════════════════════════════════════════════
section "6️  RECHERCHE COMBINÉE - Erreurs du payment-service"

echo -e "${CYAN}  Focus sur le service de paiement...${NC}"
echo ""
sleep 1

echo -e "${YELLOW}  Requête (bool query) :${NC}"
echo '  {
    "query": {
      "bool": {
        "must": [
          { "match": { "service": "payment-service" } },
          { "terms": { "level": ["ERROR", "WARNING"] } }
        ]
      }
    }
  }'
echo ""

curl -s -X GET "localhost:9200/app-logs-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "must": [
          { "match": { "service": "payment-service" } },
          { "terms": { "level": ["ERROR", "WARNING"] } }
        ]
      }
    },
    "_source": ["@timestamp", "level", "message", "error_code", "user_id"]
  }' | grep -A 20 '"hits" : \[' | head -25

echo ""
echo -e "${GREEN}  ✓ Cause trouvée : Carte bancaire refusée (CARD_DECLINED)${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 7 : AGRÉGATIONS
# ═══════════════════════════════════════════════════════════════════════
section "7  AGRÉGATIONS - Statistiques par service"

echo -e "${CYAN}  Quel service génère le plus d'erreurs ?${NC}"
echo ""
sleep 1

echo -e "${YELLOW}  Requête d'agrégation :${NC}"
echo '  {
    "size": 0,
    "aggs": {
      "par_service": {
        "terms": { "field": "service" }
      }
    }
  }'
echo ""

curl -s -X GET "localhost:9200/app-logs-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "size": 0,
    "query": {
      "terms": { "level": ["ERROR", "CRITICAL"] }
    },
    "aggs": {
      "erreurs_par_service": {
        "terms": {
          "field": "service",
          "size": 10
        }
      }
    }
  }' | grep -A 30 '"aggregations"'

echo ""
echo -e "${GREEN}  ✓ Les services les plus problématiques sont identifiés !${NC}"
echo -e "${GREEN}    → Priorité : database-service et api-gateway${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 8 : ALERTES DE SÉCURITÉ
# ═══════════════════════════════════════════════════════════════════════
section "8️⃣  SÉCURITÉ - Détection d'activité suspecte"

echo -e "${RED}  🔒 Recherche d'activités suspectes...${NC}"
echo ""
sleep 1

curl -s -X GET "localhost:9200/app-logs-*/_search?pretty" \
  -H "Content-Type: application/json" \
  -d '{
    "query": {
      "bool": {
        "should": [
          { "match": { "message": "tentatives" } },
          { "match": { "message": "DDoS" } },
          { "match": { "message": "attaque" } },
          { "match": { "service": "security-service" } }
        ],
        "minimum_should_match": 1
      }
    },
    "_source": ["@timestamp", "level", "message", "ip_address"]
  }' | grep -A 25 '"hits" : \[' | head -30

echo ""
echo -e "${RED}    ALERTES SÉCURITÉ DÉTECTÉES :${NC}"
echo -e "${RED}     • 5 tentatives de connexion échouées${NC}"
echo -e "${RED}     • Attaque DDoS depuis 185.220.0.0/16${NC}"
echo ""
echo -e "${GREEN}  → Actions : Bloquer les IPs suspectes dans le firewall !${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# PARTIE 9 : KIBANA
# ═══════════════════════════════════════════════════════════════════════
section "9  KIBANA - Visualisation"

echo -e "${WHITE}  Kibana permet de :${NC}"
echo ""
echo -e "${CYAN}   Créer des dashboards interactifs${NC}"
echo -e "${CYAN}  Explorer les données avec Discover${NC}"
echo -e "${CYAN}  Créer des graphiques et visualisations${NC}"
echo -e "${CYAN}   Configurer des alertes automatiques${NC}"
echo ""
echo -e "${GREEN}   Ouvrez dans votre navigateur :${NC}"
echo ""
echo -e "${WHITE}${BOLD}     http://localhost:5601${NC}"
echo ""
echo -e "${YELLOW}  Pour configurer Kibana :${NC}"
echo -e "${YELLOW}     1. Menu ☰ → Stack Management → Data Views${NC}"
echo -e "${YELLOW}     2. Create data view → Pattern: app-logs-*${NC}"
echo -e "${YELLOW}     3. Timestamp field: @timestamp${NC}"
echo -e "${YELLOW}     4. Menu ☰ → Discover → Explorer les logs !${NC}"

pause

# ═══════════════════════════════════════════════════════════════════════
# CONCLUSION
# ═══════════════════════════════════════════════════════════════════════
clear
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                    ║${NC}"
echo -e "${GREEN}║               DÉMO ELK STACK TERMINÉE !                          ║${NC}"
echo -e "${GREEN}║                                                                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${WHITE}${BOLD}   RÉCAPITULATIF - Ce que nous avons vu :${NC}"
echo ""
echo -e "${CYAN}  ┌────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │                                                                │${NC}"
echo -e "${CYAN}  │   LOGSTASH                                                   │${NC}"
echo -e "${CYAN}  │     • Collecte les logs depuis fichiers/HTTP/TCP              │${NC}"
echo -e "${CYAN}  │     • Transforme : parse dates, ajoute tags, classifie        │${NC}"
echo -e "${CYAN}  │     • Envoie vers Elasticsearch                               │${NC}"
echo -e "${CYAN}  │                                                                │${NC}"
echo -e "${CYAN}  │   ELASTICSEARCH                                              │${NC}"
echo -e "${CYAN}  │     • Stocke et indexe les données                            │${NC}"
echo -e "${CYAN}  │     • Recherche full-text ultra-rapide (< 10ms)               │${NC}"
echo -e "${CYAN}  │     • Agrégations et statistiques en temps réel               │${NC}"
echo -e "${CYAN}  │                                                                │${NC}"
echo -e "${CYAN}  │   KIBANA                                                     │${NC}"
echo -e "${CYAN}  │     • Dashboards interactifs                                  │${NC}"
echo -e "${CYAN}  │     • Exploration des données                                 │${NC}"
echo -e "${CYAN}  │     • Alertes et monitoring                                   │${NC}"
echo -e "${CYAN}  │                                                                │${NC}"
echo -e "${CYAN}  └────────────────────────────────────────────────────────────────┘${NC}"
echo ""
echo -e "${YELLOW}   C'est ce que font Netflix, Uber, GitHub pour surveiller${NC}"
echo -e "${YELLOW}     leurs millions de serveurs en temps réel !${NC}"
echo ""
echo -e "${MAGENTA}   Merci pour votre attention !${NC}"
echo -e "${MAGENTA}     Des questions ?${NC}"
echo ""
