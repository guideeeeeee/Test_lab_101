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
if docker ps | grep -q "pqc-target-nginx" && docker ps | grep -q "pqc-target-mysql"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Containers not running. Run ./setup.sh first."
    exit 1
fi

# Test 2: HTTPS connection
echo -n "Test 2: HTTPS connection (port 443)... "
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost | grep -q "200"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  Cannot connect to https://localhost"
    exit 1
fi

# Test 3: TLS 1.2 protocol
echo -n "Test 3: TLS 1.2 protocol... "
if openssl s_client -connect localhost:443 -tls1_2 </dev/null 2>&1 | grep -q "Protocol.*TLSv1.2"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "TLS 1.2 not available"
    exit 1
fi

# Test 4: RSA certificate
echo -n "Test 4: RSA-2048 certificate... "
if openssl s_client -connect localhost:443 </dev/null 2>&1 | grep -q "RSA Public-Key: (2048 bit)"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  Certificate might not be RSA-2048"
fi

# Test 5: ECDHE-RSA cipher
echo -n "Test 5: ECDHE-RSA cipher suite... "
if openssl s_client -connect localhost:443 -brief </dev/null 2>&1 | grep -q "ECDHE-RSA"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  ECDHE-RSA cipher not in use"
fi

# Test 6: MySQL connection
echo -n "Test 6: MySQL database... "
if docker exec pqc-target-mysql mysql -uwebapp -pwebpass2019 -e "SELECT 1" corporate_db &>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${RED}✗ FAIL${NC}"
    echo "  MySQL connection failed"
fi

# Test 7: HTTP redirect
echo -n "Test 7: HTTP to HTTPS redirect... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost | grep -q "301"; then
    echo -e "${GREEN}✓ PASS${NC}"
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
    echo "  HTTP redirect not working"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ All critical tests passed!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Quick info:"
openssl s_client -connect localhost:443 -brief </dev/null 2>&1 | grep -E "Protocol|Ciphersuite" || true
echo ""
echo "Ready for Lab 01: Manual Discovery"
echo ""
