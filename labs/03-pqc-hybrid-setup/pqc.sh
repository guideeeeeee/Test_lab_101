#!/bin/bash
################################################################################
# PQC Lab Management Script
# Easy commands for managing the PQC Hybrid TLS lab
################################################################################

COMPOSE_FILE="docker-compose-hybrid.yml"
SERVICE="nginx-pqc-hybrid"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${BLUE}PQC Lab Management Commands${NC}"
    echo ""
    echo "Usage: ./pqc.sh [command]"
    echo ""
    echo "Commands:"
    echo "  build       - Build Docker image"
    echo "  start       - Start containers"
    echo "  stop        - Stop containers"
    echo "  restart     - Restart containers"
    echo "  logs        - View logs (follow)"
    echo "  status      - Show container status"
    echo "  shell       - Open shell in container"
    echo "  test        - Test HTTPS connection"
    echo "  certs       - List certificates"
    echo "  gencerts    - Generate new certificates"
    echo "  clean       - Stop and remove containers"
    echo "  help        - Show this help"
    echo ""
}

case "$1" in
    build)
        echo -e "${YELLOW}Building Docker image...${NC}"
        docker compose -f "$COMPOSE_FILE" build
        ;;
    
    start)
        echo -e "${YELLOW}Starting containers...${NC}"
        docker compose -f "$COMPOSE_FILE" up -d
        echo -e "${GREEN}✓ Containers started${NC}"
        echo ""
        echo "Access: https://localhost:8443"
        ;;
    
    stop)
        echo -e "${YELLOW}Stopping containers...${NC}"
        docker compose -f "$COMPOSE_FILE" stop
        echo -e "${GREEN}✓ Containers stopped${NC}"
        ;;
    
    restart)
        echo -e "${YELLOW}Restarting containers...${NC}"
        docker compose -f "$COMPOSE_FILE" restart
        echo -e "${GREEN}✓ Containers restarted${NC}"
        ;;
    
    logs)
        echo -e "${YELLOW}Viewing logs (Ctrl+C to exit)...${NC}"
        docker compose -f "$COMPOSE_FILE" logs -f "$SERVICE"
        ;;
    
    status)
        echo -e "${YELLOW}Container status:${NC}"
        docker compose -f "$COMPOSE_FILE" ps
        ;;
    
    shell)
        echo -e "${YELLOW}Opening shell in container...${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE" bash
        ;;
    
    test)
        echo -e "${YELLOW}Testing HTTPS connection...${NC}"
        echo ""
        curl -k -v https://localhost:8443 2>&1 | grep -E "(TLS|SSL|Server|HTTP)"
        ;;
    
    certs)
        echo -e "${YELLOW}Certificates in container:${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE" ls -lh /etc/nginx/certs/
        echo ""
        echo -e "${YELLOW}Certificate details:${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE" \
            /opt/openssl/bin/openssl x509 -in /etc/nginx/certs/server-hybrid.crt \
            -noout -subject -issuer -dates 2>/dev/null || echo "Certificates not found"
        ;;
    
    gencerts)
        echo -e "${YELLOW}Generating new certificates...${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE" \
            /usr/local/bin/generate-pqc-certs.sh
        echo ""
        echo -e "${YELLOW}Reloading NGINX...${NC}"
        docker compose -f "$COMPOSE_FILE" exec "$SERVICE" nginx -s reload
        echo -e "${GREEN}✓ Done${NC}"
        ;;
    
    clean)
        echo -e "${YELLOW}Stopping and removing containers...${NC}"
        docker compose -f "$COMPOSE_FILE" down
        echo -e "${GREEN}✓ Cleanup complete${NC}"
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
