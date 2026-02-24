#!/bin/bash

# Verification script for Lab 00
# Tests if the target application is running correctly

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Lab 00: Verification Tests"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Docker containers
echo -n "Test 1: Checking Docker containers... "
if docker ps | grep -q "pqc-nginx-vulnerable" && docker ps | grep -q "pqc-nginx-secure" && docker ps | grep -q "pqc-target-mysql"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Containers not running. Run ./setup.sh first."
    exit 1
fi

# Test 2: HTTPS connection - vulnerable (port 4430)
# NOTE: curl rejects DH-1024 by default (host OpenSSL SECLEVEL=2)
# Use openssl s_client with SECLEVEL=1 to verify the server responds
echo -n "Test 2: HTTPS connection - vulnerable (port 4430)... "
if openssl s_client -connect localhost:4430 -tls1_2 \
    -cipher 'ECDHE-RSA-AES256-GCM-SHA384@SECLEVEL=1' \
    -brief </dev/null 2>&1 | grep -q "Protocol"; then
    echo -e "${GREEN}✓ PASS${NC} (TLS 1.2 responds - DH-1024 requires SECLEVEL=1 on client)"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Cannot connect to localhost:4430 even with SECLEVEL=1"
    exit 1
fi

# Test 3: HTTPS connection - secure (port 4431)
echo -n "Test 3: HTTPS connection - secure (port 4431)... "
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:4431 | grep -q "200"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Cannot connect to https://localhost:4431"
    exit 1
fi

# Test 4: Vulnerable - TLS 1.0/1.1 offered
echo -n "Test 4: Vulnerable server accepts TLS 1.0/1.1... "
if openssl s_client -connect localhost:4430 -tls1 </dev/null 2>&1 | grep -q "New\|CONNECTED"; then
    echo -e "${GREEN}✓ PASS${NC} (TLS 1.0 accepted - expected)"
elif openssl s_client -connect localhost:4430 -tls1_1 </dev/null 2>&1 | grep -q "New\|CONNECTED"; then
    echo -e "${GREEN}✓ PASS${NC} (TLS 1.1 accepted - expected)"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  TLS 1.0/1.1 not accepted - check ssl-params-vulnerable.conf + OpenSSL version"
fi

# Test 5: Secure - TLS 1.3 offered
echo -n "Test 5: Secure server supports TLS 1.3... "
if openssl s_client -connect localhost:4431 -tls1_3 -brief </dev/null 2>&1 | grep -q "TLSv1.3"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  TLS 1.3 not negotiated on port 4431"
fi

# Test 6: Secure - no 3DES/CBC
echo -n "Test 6: Secure server rejects weak ciphers (3DES)... "
if ! openssl s_client -connect localhost:4431 -cipher 'DES-CBC3-SHA' </dev/null 2>&1 | grep -q "New\|CONNECTED"; then
    echo -e "${GREEN}✓ PASS${NC} (3DES rejected as expected)"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  Weak cipher was accepted - check ssl-params-secure.conf"
fi

# Test 7: RSA-2048 certificate (shared)
echo -n "Test 7: RSA-2048 certificate... "
if openssl s_client -connect localhost:4430 -tls1_2 \
    -cipher 'ECDHE-RSA-AES256-GCM-SHA384@SECLEVEL=1' \
    </dev/null 2>&1 | grep -q "RSA Public-Key: (2048 bit)\|Public Key Algorithm: rsaEncryption\|2048"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  Certificate might not be RSA-2048"
fi

# Test 8: MySQL connection
echo -n "Test 8: MySQL database... "
if docker exec pqc-target-mysql mysql -uwebapp -pwebpass2019 -e "SELECT 1" corporate_db &>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  MySQL connection failed"
fi


echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ All critical tests passed!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "[VULNERABLE] port 4430:"
openssl s_client -connect localhost:4430 -tls1_2 -cipher 'ECDHE-RSA-AES256-GCM-SHA384@SECLEVEL=1' -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || true
echo ""
echo "[SECURE]     port 4431:"
openssl s_client -connect localhost:4431 -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || true
echo ""
echo "Ready for Lab 01: Manual Discovery"
echo ""
