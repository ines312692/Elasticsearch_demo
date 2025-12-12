#!/bin/bash

# ╔════════════════════════════════════════════════════════════════════╗
# ║         GÉNÉRATEUR DE LOGS EN TEMPS RÉEL                          ║
# ║         Pour démonstration live pendant la présentation            ║
# ╚════════════════════════════════════════════════════════════════════╝

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SERVICES=("api-gateway" "auth-service" "payment-service" "order-service" "database-service" "notification-service" "product-service" "security-service")
LEVELS=("INFO" "INFO" "INFO" "INFO" "INFO" "WARNING" "WARNING" "ERROR")
USERS=("USR001" "USR002" "USR003" "USR004" "USR005")



generate_log() {
    local SERVICE=${SERVICES[$RANDOM % ${#SERVICES[@]}]}
    local LEVEL=${LEVELS[$RANDOM % ${#LEVELS[@]}]}
    local USER=${USERS[$RANDOM % ${#USERS[@]}]}
    local TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S")
    local RESPONSE_TIME=$((50 + RANDOM % 2000))
    
    # Messages variés selon le niveau
    case $LEVEL in
        "INFO")
            MESSAGES=(
                "Requête GET /api/products traitée avec succès"
                "Utilisateur $USER connecté"
                "Commande créée avec succès"
                "Email envoyé à l'utilisateur"
                "Cache mis à jour"
                "Session initialisée pour $USER"
            )
            ;;
        "WARNING")
            MESSAGES=(
                "Temps de réponse élevé détecté: ${RESPONSE_TIME}ms"
                "Pool de connexions à 75%"
                "Tentative de connexion suspecte"
                "Rate limiting activé"
                "Mémoire cache à 85%"
            )
            ;;
        "ERROR")
            MESSAGES=(
                "Échec de connexion à la base de données"
                "Token expiré pour $USER"
                "Timeout lors du paiement"
                "NullPointerException dans le controller"
                "Service externe non disponible"
            )
            ;;
    esac
    
    local MESSAGE=${MESSAGES[$RANDOM % ${#MESSAGES[@]}]}
    
    # Créer le JSON
    local JSON="{\"timestamp\":\"$TIMESTAMP\",\"level\":\"$LEVEL\",\"service\":\"$SERVICE\",\"message\":\"$MESSAGE\",\"response_time_ms\":$RESPONSE_TIME,\"user_id\":\"$USER\"}"
    
    # Envoyer à Elasticsearch
    curl -s -X POST "localhost:9200/app-logs-$(date +%Y.%m.%d)/_doc" \
        -H "Content-Type: application/json" \
        -d "$JSON" > /dev/null
    
    # Afficher avec couleur selon niveau
    case $LEVEL in
        "INFO")
            echo -e "${GREEN}[INFO]${NC} $SERVICE: $MESSAGE"
            ;;
        "WARNING")
            echo -e "${YELLOW}[WARN]${NC} $SERVICE: $MESSAGE"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $SERVICE: $MESSAGE"
            ;;
    esac
}

# Boucle infinie
while true; do
    generate_log
    sleep $((1 + RANDOM % 3))  # Attendre 1-3 secondes
done
