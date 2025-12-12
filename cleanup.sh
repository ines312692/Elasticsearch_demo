#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════╗
# ║         NETTOYAGE - Arrêter et supprimer les containers           ║
# ╚════════════════════════════════════════════════════════════════════╝

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo -e "${YELLOW}🧹 Arrêt et nettoyage du stack ELK...${NC}"
echo ""

docker-compose down -v

echo ""
echo -e "${GREEN}✓ Tous les containers ont été arrêtés et supprimés.${NC}"
echo -e "${GREEN}✓ Les volumes de données ont été nettoyés.${NC}"
echo ""
