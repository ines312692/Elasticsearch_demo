#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════╗
# ║                                                                    ║
# ║          SETUP ELK STACK - DÉMO COMPLÈTE                           ║
# ║                                                                    ║
# ║         Elasticsearch + Logstash + Kibana                          ║
# ║         Présenté par : Ines Tmimi                                  ║
# ║         Bases de données avancées - ENSIT 2025-2026                ║
# ║                                                                    ║
# ╚════════════════════════════════════════════════════════════════════╝

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m'


# ─────────────────────────────────────────────────────────────────
# ÉTAPE 1 : Vérification Docker
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 1/6 : Vérification de Docker${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

docker info > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}   Docker n'est pas lancé !${NC}"
    echo -e "${RED}     → Lance Docker Desktop et réessaie.${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker est opérationnel${NC}"

# Vérifier docker-compose
docker-compose version > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}   Docker Compose n'est pas installé !${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Docker Compose est installé${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────
# ÉTAPE 2 : Nettoyage des anciens containers
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 2/6 : Nettoyage des anciens containers${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

docker-compose down -v 2>/dev/null
echo -e "${GREEN}  ✓ Environnement nettoyé${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────
# ÉTAPE 3 : Lancement du stack ELK
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 3/6 : Lancement du stack ELK${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${CYAN}   Téléchargement des images Docker...${NC}"
echo -e "${CYAN}     (Cela peut prendre quelques minutes la première fois)${NC}"
echo ""

docker-compose up -d

echo ""
echo -e "${GREEN}  ✓ Containers lancés${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────
# ÉTAPE 4 : Attente d'Elasticsearch
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 4/6 : Attente d'Elasticsearch${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -ne "${CYAN}   Elasticsearch démarre"

MAX_ATTEMPTS=60
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    HEALTH=$(curl -s http://localhost:9200/_cluster/health 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$HEALTH" == "green" ] || [ "$HEALTH" == "yellow" ]; then
        echo ""
        echo -e "${GREEN}  ✓ Elasticsearch est prêt ! (Status: $HEALTH)${NC}"
        break
    fi
    
    echo -n "."
    sleep 2
    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo ""
    echo -e "${RED}   Elasticsearch ne répond pas.${NC}"
    echo -e "${RED}     Vérifie les logs : docker-compose logs elasticsearch${NC}"
    exit 1
fi
echo ""

# ─────────────────────────────────────────────────────────────────
# ÉTAPE 5 : Attente de Kibana
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 5/6 : Attente de Kibana${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -ne "${CYAN}   Kibana démarre"

ATTEMPT=0
while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    STATUS=$(curl -s http://localhost:5601/api/status 2>/dev/null | grep -o '"overall":{"level":"[^"]*"' | cut -d'"' -f6)
    
    if [ "$STATUS" == "available" ]; then
        echo ""
        echo -e "${GREEN}  ✓ Kibana est prêt !${NC}"
        break
    fi
    
    echo -n "."
    sleep 3
    ATTEMPT=$((ATTEMPT + 1))
done

if [ $ATTEMPT -eq $MAX_ATTEMPTS ]; then
    echo ""
    echo -e "${YELLOW}   Kibana prend du temps à démarrer.${NC}"
    echo -e "${YELLOW}    Attends encore 1-2 minutes puis ouvre http://localhost:5601${NC}"
fi
echo ""

# ─────────────────────────────────────────────────────────────────
# ÉTAPE 6 : Injection des données de démo
# ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}  ÉTAPE 6/6 : Injection des données de démonstration${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Attendre que Logstash soit prêt
echo -e "${CYAN}   Attente de Logstash...${NC}"
sleep 15

# Vérifier si les logs ont été traités
LOGS_COUNT=$(curl -s "localhost:9200/app-logs-*/_count" 2>/dev/null | grep -o '"count":[0-9]*' | cut -d':' -f2)

if [ -n "$LOGS_COUNT" ] && [ "$LOGS_COUNT" -gt 0 ]; then
    echo -e "${GREEN}  ✓ $LOGS_COUNT logs traités par Logstash !${NC}"
else
    echo -e "${CYAN}   Injection directe des logs dans Elasticsearch...${NC}"
    
    # Injection directe si Logstash n'a pas encore traité
    while IFS= read -r line; do
        curl -s -X POST "localhost:9200/app-logs-2024.01.15/_doc" \
            -H "Content-Type: application/json" \
            -d "$line" > /dev/null
    done < logs/application.log
    
    echo -e "${GREEN}  ✓ Logs injectés avec succès !${NC}"
fi

echo ""

# ─────────────────────────────────────────────────────────────────
# TERMINÉ !
# ─────────────────────────────────────────────────────────────────

service: "payment-service" AND level: "ERROR"

level: "ERROR"

curl -s "localhost:9200/app-logs-*/_count"