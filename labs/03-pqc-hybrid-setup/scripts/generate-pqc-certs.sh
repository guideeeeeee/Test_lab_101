#!/bin/bash
################################################################################
# PQC Hybrid Certificate Generation Script
# Generates ML-DSA (Dilithium) hybrid certificates for NGINX
################################################################################

set -e

# Configuration
CERT_DIR="/etc/nginx/certs"
DAYS_VALID=365
COUNTRY="TH"
STATE="Bangkok"
LOCALITY="Bangkok"
ORGANIZATION="PQC Lab"
OU="Training"
CN_CA="PQC Hybrid CA"
CN_SERVER="pqc-lab.local"

# Color output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}PQC Hybrid Certificate Generator${NC}"
echo -e "${GREEN}================================${NC}"

# Ensure cert directory exists
mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Verify OpenSSL and oqsprovider are available
echo -e "\n${YELLOW}[1/6] Verifying OpenSSL and oqsprovider...${NC}"
if ! /opt/openssl/bin/openssl version; then
    echo -e "${RED}Error: OpenSSL not found${NC}"
    exit 1
fi

if ! /opt/openssl/bin/openssl list -providers | grep -q "oqsprovider"; then
    echo -e "${RED}Error: oqsprovider not loaded${NC}"
    echo "Available providers:"
    /opt/openssl/bin/openssl list -providers
    exit 1
fi

echo -e "${GREEN}✓ OpenSSL $(/opt/openssl/bin/openssl version | awk '{print $2}')${NC}"
echo -e "${GREEN}✓ oqsprovider loaded${NC}"

# List available PQC algorithms
echo -e "\n${YELLOW}[2/6] Available PQC Signature Algorithms:${NC}"
/opt/openssl/bin/openssl list -signature-algorithms -provider oqsprovider | grep -E "(mldsa|dilithium|p256_|p384_)" | head -10

# Generate CA with hybrid signature (p384_mldsa65)
echo -e "\n${YELLOW}[3/6] Generating Hybrid CA Certificate (P-384 + ML-DSA-65)...${NC}"
/opt/openssl/bin/openssl req -x509 -new \
    -newkey p384_mldsa65 \
    -keyout ca-hybrid.key \
    -out ca-hybrid.crt \
    -nodes \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${OU}/CN=${CN_CA}" \
    -days ${DAYS_VALID} \
    -sha384

echo -e "${GREEN}✓ CA Certificate created: ca-hybrid.crt${NC}"
echo -e "${GREEN}✓ CA Key created: ca-hybrid.key${NC}"

# Generate server private key (hybrid)
echo -e "\n${YELLOW}[4/6] Generating Hybrid Server Key (P-384 + ML-DSA-65)...${NC}"
/opt/openssl/bin/openssl genpkey \
    -algorithm p384_mldsa65 \
    -out server-hybrid.key

echo -e "${GREEN}✓ Server Key created: server-hybrid.key${NC}"

# Generate Certificate Signing Request (CSR)
echo -e "\n${YELLOW}[5/6] Generating Certificate Signing Request...${NC}"
/opt/openssl/bin/openssl req -new \
    -key server-hybrid.key \
    -out server-hybrid.csr \
    -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANIZATION}/OU=${OU}/CN=${CN_SERVER}" \
    -addext "subjectAltName=DNS:${CN_SERVER},DNS:localhost,IP:127.0.0.1"

echo -e "${GREEN}✓ CSR created: server-hybrid.csr${NC}"

# Sign server certificate with CA
echo -e "\n${YELLOW}[6/6] Signing Server Certificate with Hybrid CA...${NC}"
/opt/openssl/bin/openssl x509 -req \
    -in server-hybrid.csr \
    -CA ca-hybrid.crt \
    -CAkey ca-hybrid.key \
    -CAcreateserial \
    -out server-hybrid.crt \
    -days ${DAYS_VALID} \
    -sha384 \
    -copy_extensions copyall

echo -e "${GREEN}✓ Server Certificate created: server-hybrid.crt${NC}"

# Create combined certificate chain
cat server-hybrid.crt ca-hybrid.crt > fullchain-hybrid.crt
echo -e "${GREEN}✓ Full chain created: fullchain-hybrid.crt${NC}"

# Set proper permissions
chmod 644 *.crt
chmod 600 *.key
chmod 644 *.csr

# Display certificate information
echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}Certificate Generation Complete!${NC}"
echo -e "${GREEN}================================${NC}"

echo -e "\n${YELLOW}CA Certificate Info:${NC}"
/opt/openssl/bin/openssl x509 -in ca-hybrid.crt -noout -subject -dates -ext subjectAltName

echo -e "\n${YELLOW}Server Certificate Info:${NC}"
/opt/openssl/bin/openssl x509 -in server-hybrid.crt -noout -subject -dates -ext subjectAltName

echo -e "\n${YELLOW}Certificate Files Generated:${NC}"
ls -lh "$CERT_DIR"/ | grep -E "\.(crt|key)$"

echo -e "\n${GREEN}✓ All certificates generated successfully!${NC}"
echo -e "${YELLOW}Note: Update nginx-hybrid.conf to use these certificates${NC}"
echo -e "  - ssl_certificate: fullchain-hybrid.crt"
echo -e "  - ssl_certificate_key: server-hybrid.key"
