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

# Generate DH parameters (1024-bit for vulnerable demo)
if [ ! -f dhparam-1024.pem ]; then
    openssl dhparam -out dhparam-1024.pem 1024 2>/dev/null
fi

cd ..
print_success "Certificates generated (RSA-2048 + DH-2048 + DH-1024)"

# Step 3: Build NGINX containers
print_step 3 6 "Building NGINX containers (vulnerable + secure)..."
$DOCKER_COMPOSE build --quiet pqc-nginx-vulnerable pqc-nginx-secure
print_success "NGINX containers built"

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

# Step 5: Start NGINX servers (vulnerable + secure)
print_step 5 6 "Starting NGINX servers (vulnerable: 4430 | secure: 4431)..."
$DOCKER_COMPOSE up -d pqc-nginx-vulnerable pqc-nginx-secure
sleep 2
print_success "NGINX servers started"

# Step 6: Verify deployment
print_step 6 6 "Verifying deployment..."

# Check if containers are running
if ! docker ps | grep -q pqc-nginx-vulnerable; then
    print_error "Vulnerable NGINX container is not running"
    echo "Check logs with: docker logs pqc-nginx-vulnerable"
    exit 1
fi

if ! docker ps | grep -q pqc-nginx-secure; then
    print_error "Secure NGINX container is not running"
    echo "Check logs with: docker logs pqc-nginx-secure"
    exit 1
fi

if ! docker ps | grep -q pqc-target-mysql; then
    print_error "MySQL container is not running"
    echo "Check logs with: docker logs pqc-target-mysql"
    exit 1
fi

# Test HTTPS connections
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:4430 | grep -q "200"; then
    HTTP_VULN="200 OK"
else
    HTTP_VULN="Failed"
fi

if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:4431 | grep -q "200"; then
    HTTP_SEC="200 OK"
else
    HTTP_SEC="Failed"
fi

# Check TLS version and cipher on vulnerable
TLS_VULN=$(openssl s_client -connect localhost:4430 -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || echo "Unable to connect")

# Check TLS version and cipher on secure
TLS_SEC=$(openssl s_client -connect localhost:4431 -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || echo "Unable to connect")

print_success "Deployment verified"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Target applications are running!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  [VULNERABLE] https://localhost:4430  →  Status: $HTTP_VULN"
echo "  $TLS_VULN"
echo ""
echo "  [SECURE]     https://localhost:4431  →  Status: $HTTP_SEC"
echo "  $TLS_SEC"
echo ""
echo "Next steps:"
echo "  1. Vulnerable: curl -k https://localhost:4430"
echo "  2. Secure:     curl -k https://localhost:4431"
echo "  3. Compare TLS: openssl s_client -connect localhost:4430 -brief"
echo "                  openssl s_client -connect localhost:4431 -brief"
echo ""
echo "Container management:"
echo "  • Vulnerable logs: docker logs pqc-nginx-vulnerable"
echo "  • Secure logs:     docker logs pqc-nginx-secure"
echo "  • Stop: docker-compose down"
echo "  • Restart: docker-compose restart"
echo ""
