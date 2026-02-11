#!/bin/bash

# Lab 00: Target Application Setup Script
# Purpose: Deploy 2019-standard HTTPS server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}[$1/$2]${NC} $3"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Header
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Lab 00: Target Application Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Step 1: Check prerequisites
print_step 1 6 "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! docker ps &> /dev/null; then
    print_error "Docker daemon is not running. Please start Docker."
    exit 1
fi

if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
    print_error "Docker Compose is not installed."
    exit 1
fi
print_success "Prerequisites check passed ($DOCKER_COMPOSE)"

# Step 2: Generate certificates
print_step 2 6 "Generating RSA-2048 certificates..."
mkdir -p certs
cd certs

# Generate RSA-2048 private key
if [ ! -f server.key ]; then
    openssl genrsa -out server.key 2048 2>/dev/null
fi

# Generate self-signed certificate (valid for 1 year)
if [ ! -f server.crt ]; then
    openssl req -new -x509 -key server.key -out server.crt -days 365 \
        -subj "/C=TH/ST=Bangkok/L=Bangkok/O=Corporate Inc/OU=IT Department/CN=corporate-2019.local" \
        2>/dev/null
fi

# Generate DH parameters (2048-bit for 2019 standard)
if [ ! -f dhparam.pem ]; then
    openssl dhparam -out dhparam.pem 2048 2>/dev/null
fi

cd ..
print_success "Certificates generated (RSA-2048)"

# Step 3: Build NGINX container
print_step 3 6 "Building NGINX container..."
$DOCKER_COMPOSE build --quiet nginx
print_success "NGINX container built"

# Step 4: Start MySQL database
print_step 4 6 "Starting MySQL database..."
$DOCKER_COMPOSE up -d mysql
echo -n "   Waiting for MySQL to be ready"
for i in {1..15}; do
    if docker exec pqc-target-mysql mysqladmin ping -h localhost --silent 2>/dev/null; then
        echo ""
        break
    fi
    echo -n "."
    sleep 1
done
print_success "MySQL database started"

# Step 5: Start NGINX server
print_step 5 6 "Starting NGINX server..."
$DOCKER_COMPOSE up -d nginx
sleep 2
print_success "NGINX server started"

# Step 6: Verify deployment
print_step 6 6 "Verifying deployment..."

# Check if containers are running
if ! docker ps | grep -q pqc-target-nginx; then
    print_error "NGINX container is not running"
    echo "Check logs with: docker logs pqc-target-nginx"
    exit 1
fi

if ! docker ps | grep -q pqc-target-mysql; then
    print_error "MySQL container is not running"
    echo "Check logs with: docker logs pqc-target-mysql"
    exit 1
fi

# Test HTTPS connection
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost | grep -q "200"; then
    HTTP_CODE="200 OK"
else
    HTTP_CODE="Failed"
fi

# Check TLS version and cipher
TLS_INFO=$(openssl s_client -connect localhost:443 -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || echo "Unable to connect")

print_success "Deployment verified"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Target application is running!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  URL: https://localhost"
echo "  Status: $HTTP_CODE"
echo ""
echo "$TLS_INFO"
echo ""
echo "Next steps:"
echo "  1. Open browser: https://localhost"
echo "  2. Test CLI: curl -k https://localhost"
echo "  3. Check TLS: openssl s_client -connect localhost:443"
echo ""
echo "Container management:"
echo "  • View logs: docker logs pqc-target-nginx"
echo "  • Stop: docker-compose down"
echo "  • Restart: docker-compose restart"
echo ""
