#!/bin/bash

# Verification Script for PQC Lab Environment
# Checks if all prerequisites are properly installed

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASS=0
FAIL=0
WARN=0

print_test() {
    echo -n "  $1... "
}

print_pass() {
    echo -e "${GREEN}✓ PASS${NC}"
    ((PASS++))
}

print_fail() {
    echo -e "${RED}✗ FAIL${NC}"
    if [ -n "$1" ]; then
        echo "    → $1"
    fi
    ((FAIL++))
}

print_warn() {
    echo -e "${YELLOW}⚠ WARNING${NC}"
    if [ -n "$1" ]; then
        echo "    → $1"
    fi
    ((WARN++))
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  PQC Lab Environment Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test 1: Docker daemon
print_test "Docker daemon running"
if docker ps &>/dev/null; then
    print_pass
else
    print_fail "Docker daemon not running or no permissions"
fi

# Test 2: Docker Compose
print_test "Docker Compose available"
if command -v docker-compose &>/dev/null || docker compose version &>/dev/null; then
    print_pass
else
    print_fail "docker-compose not found"
fi

# Test 3: Python 3
print_test "Python 3.8+ installed"
if command -v python3 &>/dev/null; then
    VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    if (( $(echo "$VERSION >= 3.8" | bc -l) )); then
        print_pass
    else
        print_warn "Python $VERSION (recommend 3.8+)"
    fi
else
    print_fail "Python 3 not found"
fi

# Test 4: pip3
print_test "pip3 available"
if command -v pip3 &>/dev/null; then
    print_pass
else
    print_fail "pip3 not found"
fi

# Test 5: Python packages
print_test "Python packages (matplotlib, pandas)"
if python3 -c "import matplotlib, pandas, numpy" &>/dev/null; then
    print_pass
else
    print_warn "Some Python packages missing (non-critical)"
fi

# Test 6: OpenSSL
print_test "OpenSSL installed"
if command -v openssl &>/dev/null; then
    VERSION=$(openssl version | awk '{print $2}')
    if [[ "$VERSION" < "1.1.1" ]]; then
        print_warn "OpenSSL $VERSION is old"
    else
        print_pass
    fi
else
    print_fail "OpenSSL not found"
fi

# Test 7: curl
print_test "curl available"
if command -v curl &>/dev/null; then
    print_pass
else
    print_fail "curl not found"
fi

# Test 8: Network connectivity
print_test "Internet connectivity"
if curl -s --max-time 5 https://google.com &>/dev/null; then
    print_pass
else
    print_warn "No internet access (may affect initial setup)"
fi

# Test 9: Port 443 availability
print_test "Port 443 available"
if lsof -i :443 &>/dev/null || netstat -tuln 2>/dev/null | grep -q ":443 "; then
    print_warn "Port 443 in use (can use alternative port)"
else
    print_pass
fi

# Test 10: Disk space
print_test "Sufficient disk space (10GB+)"
if command -v df &>/dev/null; then
    AVAILABLE=$(df -BG . 2>/dev/null | tail -1 | awk '{print $4}' | tr -d 'G' || echo "999")
    if [ "$AVAILABLE" -ge 10 ] 2>/dev/null || [ "$AVAILABLE" = "999" ]; then
        print_pass
    else
        print_warn "Only ${AVAILABLE}GB available (recommend 20GB+)"
    fi
else
    print_warn "Cannot check disk space"
fi

# Test 11: Docker images
print_test "Required Docker images"
if docker images | grep -q "nginx.*1.18" && docker images | grep -q "mysql.*5.7"; then
    print_pass
else
    print_warn "Docker images not yet pulled (will download on first use)"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  Results: ${GREEN}$PASS passed${NC}, ${RED}$FAIL failed${NC}, ${YELLOW}$WARN warnings${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}✅ All critical checks passed!${NC}"
    echo ""
    echo "Ready to start:"
    echo "  cd labs/00-target-app"
    echo "  ./setup.sh"
    echo ""
    exit 0
else
    echo -e "${RED}❌ Some critical checks failed${NC}"
    echo ""
    echo "Please fix the issues above and run:"
    echo "  ./scripts/setup-all.sh"
    echo ""
    exit 1
fi
