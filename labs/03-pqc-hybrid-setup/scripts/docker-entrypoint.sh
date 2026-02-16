#!/bin/bash
################################################################################
# Docker Entrypoint for PQC Hybrid NGINX
# - Checks and generates certificates if needed
# - Starts NGINX
################################################################################

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  PQC Hybrid NGINX Container Starting  ${NC}"
echo -e "${BLUE}========================================${NC}"

# Certificate directory
CERT_DIR="/etc/nginx/certs"

# Environment variables with defaults
: ${AUTO_GENERATE_CERTS:=yes}
: ${CERT_COUNTRY:=TH}
: ${CERT_STATE:=Bangkok}
: ${CERT_LOCALITY:=Bangkok}
: ${CERT_ORG:=PQC Lab}
: ${CERT_CN:=pqc-lab.local}

# Function to check if certificates exist and are valid
check_certificates() {
    local cert_file="$CERT_DIR/server-hybrid.crt"
    local key_file="$CERT_DIR/server-hybrid.key"
    
    if [ -f "$cert_file" ] && [ -f "$key_file" ]; then
        # Check if certificate is still valid
        if /opt/openssl/bin/openssl x509 -in "$cert_file" -noout -checkend 86400 2>/dev/null; then
            echo -e "${GREEN}✓ Valid certificates found${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠ Certificates exist but expired or invalid${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Certificates not found${NC}"
        return 1
    fi
}

# Function to verify OpenSSL and oqsprovider
verify_openssl_setup() {
    echo -e "\n${YELLOW}Verifying OpenSSL and oqsprovider...${NC}"
    
    # Check OpenSSL version
    if ! /opt/openssl/bin/openssl version; then
        echo -e "${RED}✗ OpenSSL not found or not working${NC}"
        exit 1
    fi
    
    # Check if oqsprovider is loaded
    if ! /opt/openssl/bin/openssl list -providers 2>/dev/null | grep -q "oqsprovider"; then
        echo -e "${RED}✗ oqsprovider not loaded${NC}"
        echo -e "${YELLOW}Trying to diagnose the issue...${NC}"
        
        # Check if provider file exists
        if [ -f "/opt/openssl/lib64/ossl-modules/oqsprovider.so" ]; then
            echo -e "${GREEN}✓ oqsprovider.so found${NC}"
        else
            echo -e "${RED}✗ oqsprovider.so NOT found${NC}"
            ls -la /opt/openssl/lib64/ossl-modules/ || echo "Directory doesn't exist"
        fi
        
        # Check OpenSSL config
        if [ -f "$OPENSSL_CONF" ]; then
            echo -e "${GREEN}✓ OpenSSL config found: $OPENSSL_CONF${NC}"
            echo -e "${YELLOW}Config contents:${NC}"
            cat "$OPENSSL_CONF"
        else
            echo -e "${RED}✗ OpenSSL config NOT found: $OPENSSL_CONF${NC}"
        fi
        
        exit 1
    fi
    
    echo -e "${GREEN}✓ OpenSSL: $(/opt/openssl/bin/openssl version)${NC}"
    echo -e "${GREEN}✓ oqsprovider: loaded${NC}"
    
    # List available PQC algorithms
    echo -e "\n${YELLOW}Available PQC KEM algorithms:${NC}"
    /opt/openssl/bin/openssl list -kem-algorithms -provider oqsprovider 2>/dev/null | grep -E "mlkem|kyber" | head -5
    
    echo -e "\n${YELLOW}Available PQC Signature algorithms:${NC}"
    /opt/openssl/bin/openssl list -signature-algorithms -provider oqsprovider 2>/dev/null | grep -E "mldsa|dilithium|p384_" | head -5
}

# Function to generate certificates
generate_certificates() {
    echo -e "\n${YELLOW}Generating PQC Hybrid Certificates...${NC}"
    
    # Check if generation script exists
    if [ ! -f "/usr/local/bin/generate-pqc-certs.sh" ]; then
        echo -e "${RED}✗ Certificate generation script not found${NC}"
        exit 1
    fi
    
    # Run the certificate generation script
    bash /usr/local/bin/generate-pqc-certs.sh
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Certificates generated successfully${NC}"
    else
        echo -e "${RED}✗ Certificate generation failed${NC}"
        exit 1
    fi
}

# Function to test NGINX configuration
test_nginx_config() {
    echo -e "\n${YELLOW}Testing NGINX configuration...${NC}"
    
    if nginx -t 2>&1 | tee /tmp/nginx-test.log; then
        echo -e "${GREEN}✓ NGINX configuration is valid${NC}"
        return 0
    else
        echo -e "${RED}✗ NGINX configuration has errors:${NC}"
        cat /tmp/nginx-test.log
        return 1
    fi
}

# Main execution
echo -e "\n${BLUE}Step 1: Verify OpenSSL and OQS Provider${NC}"
verify_openssl_setup

echo -e "\n${BLUE}Step 2: Check Certificates${NC}"
if ! check_certificates; then
    if [ "$AUTO_GENERATE_CERTS" = "yes" ]; then
        echo -e "${YELLOW}Auto-generating certificates...${NC}"
        generate_certificates
    else
        echo -e "${RED}✗ Certificates required but AUTO_GENERATE_CERTS=no${NC}"
        echo -e "${YELLOW}Please mount certificates or set AUTO_GENERATE_CERTS=yes${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✓ Using existing certificates${NC}"
fi

echo -e "\n${BLUE}Step 3: Display Certificate Information${NC}"
if [ -f "$CERT_DIR/server-hybrid.crt" ]; then
    echo -e "${YELLOW}Server Certificate:${NC}"
    /opt/openssl/bin/openssl x509 -in "$CERT_DIR/server-hybrid.crt" -noout -subject -issuer -dates
    
    echo -e "\n${YELLOW}Certificate Algorithm:${NC}"
    /opt/openssl/bin/openssl x509 -in "$CERT_DIR/server-hybrid.crt" -noout -text | grep -E "Public Key Algorithm|Signature Algorithm" | head -4
fi

echo -e "\n${BLUE}Step 4: Test NGINX Configuration${NC}"
if ! test_nginx_config; then
    echo -e "${RED}✗ NGINX configuration test failed${NC}"
    echo -e "${YELLOW}Continuing anyway... (errors may prevent startup)${NC}"
fi

echo -e "\n${BLUE}Step 5: Starting NGINX${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  PQC Hybrid NGINX Ready!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "${YELLOW}Access: https://localhost:8443${NC}"
echo -e "${YELLOW}Logs: /var/log/nginx/${NC}"
echo ""

# Execute the main command (NGINX)
exec "$@"
