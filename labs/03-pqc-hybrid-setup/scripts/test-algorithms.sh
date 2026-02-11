#!/bin/bash
# Test Algorithm Availability in OpenSSL with OQS Provider
# ตรวจสอบว่า PQC algorithms พร้อมใช้งานหรือไม่

set -e

echo "=================================="
echo "PQC Algorithm Availability Test"
echo "=================================="
echo ""

# Path to OpenSSL with OQS
OPENSSL_BIN="/usr/local/bin/openssl"

# Check if exists
if [ ! -f "$OPENSSL_BIN" ]; then
    echo "ERROR: OpenSSL not found at $OPENSSL_BIN"
    echo "Using system OpenSSL instead..."
    OPENSSL_BIN="openssl"
fi

echo "Using: $($OPENSSL_BIN version)"
echo ""

# Test 1: List providers
echo "[1/5] Checking providers..."
$OPENSSL_BIN list -providers || echo "Failed to list providers"
echo ""

# Test 2: List KEM algorithms
echo "[2/5] Available KEM (Key Encapsulation) algorithms:"
$OPENSSL_BIN list -kem-algorithms | grep -i "kyber\|kem" || echo "No PQC KEM algorithms found"
echo ""

# Test 3: List signature algorithms
echo "[3/5] Available Signature algorithms:"
$OPENSSL_BIN list -signature-algorithms | grep -i "dilithium\|mldsa\|falcon" || echo "No PQC signature algorithms found"
echo ""

# Test 4: List supported groups
echo "[4/5] Supported TLS groups:"
$OPENSSL_BIN ecparam -list_curves 2>/dev/null | tail -20 || echo "Failed to list curves"
echo ""

# Test 5: Test specific algorithms
echo "[5/5] Testing specific PQC algorithms:"
echo ""

test_algorithm() {
    local ALGO=$1
    local TYPE=$2
    
    echo -n "  Testing $ALGO ($TYPE)... "
    
    if $OPENSSL_BIN genpkey -algorithm $ALGO -out /tmp/test_${ALGO}.key 2>/dev/null; then
        echo "✓ Available"
        rm -f /tmp/test_${ALGO}.key
    else
        echo "✗ Not available"
    fi
}

# ML-KEM (Kyber)
test_algorithm "kyber512" "ML-KEM-512"
test_algorithm "kyber768" "ML-KEM-768"
test_algorithm "kyber1024" "ML-KEM-1024"

echo ""

# ML-DSA (Dilithium)
test_algorithm "dilithium2" "ML-DSA-44"
test_algorithm "dilithium3" "ML-DSA-65"
test_algorithm "dilithium5" "ML-DSA-87"

echo ""

# Hybrid algorithms (if available)
test_algorithm "p256_kyber512" "Hybrid ECDSA+ML-KEM-512"
test_algorithm "p256_kyber768" "Hybrid ECDSA+ML-KEM-768"

echo ""

# Summary
echo "=================================="
echo "If you see '✗ Not available' above,"
echo "you need to install OpenSSL with"
echo "liboqs and oqs-provider support."
echo ""
echo "See: labs/03-pqc-hybrid-setup/guides/install-oqs.md"
echo "=================================="
