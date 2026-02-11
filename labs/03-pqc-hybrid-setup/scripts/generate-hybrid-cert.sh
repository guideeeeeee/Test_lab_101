#!/bin/bash
# Generate Hybrid Post-Quantum Certificates
# สคริปต์สร้างใบรับรองแบบ Hybrid (Classical + PQC)

set -e

echo "=================================="
echo "Hybrid Certificate Generator"
echo "=================================="
echo ""

# Configuration
CERT_DIR="$(pwd)/certs-hybrid"
VALIDITY_DAYS=365
COUNTRY="TH"
STATE="Bangkok"
LOCALITY="Bangkok"
ORG="PQC Lab Corporation"
OU="IT Security"
CN="localhost"

# OpenSSL with OQS support
# Change this path if you compiled OpenSSL+OQS elsewhere
OPENSSL_BIN="/usr/local/bin/openssl"

# Check if OpenSSL with OQS is available
if [ ! -f "$OPENSSL_BIN" ]; then
    echo "ERROR: OpenSSL with OQS provider not found at $OPENSSL_BIN"
    echo ""
    echo "Please either:"
    echo "  1. Use pre-compiled binaries from binaries/ directory"
    echo "  2. Compile OpenSSL + liboqs + oqs-provider manually"
    echo ""
    echo "See: labs/03-pqc-hybrid-setup/guides/install-oqs.md"
    exit 1
fi

# Verify OQS provider is available
if ! $OPENSSL_BIN list -providers 2>/dev/null | grep -q "oqsprovider"; then
    echo "ERROR: oqsprovider not found in OpenSSL"
    echo "Run: $OPENSSL_BIN list -providers"
    exit 1
fi

echo "✓ Using OpenSSL: $($OPENSSL_BIN version)"
echo ""

# Create cert directory
mkdir -p "$CERT_DIR"

# Function to generate certificate
generate_cert() {
    local ALGO=$1
    local ALGO_TYPE=$2  # "hybrid" or "pure"
    local DESCRIPTION=$3
    
    echo "----------------------------------------"
    echo "Generating: $DESCRIPTION"
    echo "Algorithm: $ALGO"
    echo "----------------------------------------"
    
    local KEY_FILE="$CERT_DIR/${ALGO}_key.pem"
    local CERT_FILE="$CERT_DIR/${ALGO}_cert.pem"
    local CSR_FILE="$CERT_DIR/${ALGO}_csr.pem"
    
    # Generate private key
    echo "1. Generating private key..."
    $OPENSSL_BIN genpkey -algorithm $ALGO -out "$KEY_FILE"
    
    if [ $? -eq 0 ]; then
        echo "   ✓ Private key: $KEY_FILE"
    else
        echo "   ✗ Failed to generate private key"
        return 1
    fi
    
    # Generate Certificate Signing Request (CSR)
    echo "2. Generating CSR..."
    $OPENSSL_BIN req -new -key "$KEY_FILE" -out "$CSR_FILE" \
        -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORG/OU=$OU/CN=$CN"
    
    if [ $? -eq 0 ]; then
        echo "   ✓ CSR: $CSR_FILE"
    else
        echo "   ✗ Failed to generate CSR"
        return 1
    fi
    
    # Self-sign certificate
    echo "3. Self-signing certificate..."
    $OPENSSL_BIN x509 -req -days $VALIDITY_DAYS \
        -in "$CSR_FILE" \
        -signkey "$KEY_FILE" \
        -out "$CERT_FILE"
    
    if [ $? -eq 0 ]; then
        echo "   ✓ Certificate: $CERT_FILE"
    else
        echo "   ✗ Failed to sign certificate"
        return 1
    fi
    
    # Display certificate info
    echo "4. Certificate details:"
    $OPENSSL_BIN x509 -in "$CERT_FILE" -noout -subject -issuer -dates
    echo "   Public Key Algorithm:"
    $OPENSSL_BIN x509 -in "$CERT_FILE" -noout -text | grep "Public Key Algorithm" | head -1
    
    echo "✓ Complete!"
    echo ""
}

# Main menu
echo "Select certificate type to generate:"
echo ""
echo "  [1] Hybrid ECDSA + ML-DSA-65 (RECOMMENDED)"
echo "  [2] Hybrid RSA-2048 + ML-DSA-65"
echo "  [3] Pure ML-DSA-65 (PQC only)"
echo "  [4] Pure ML-DSA-87 (Higher security)"
echo "  [5] Generate ALL certificates"
echo "  [0] Exit"
echo ""
read -p "Enter choice [1-5, 0]: " CHOICE

case $CHOICE in
    1)
        # Hybrid: ECDSA P-256 + ML-DSA-65
        generate_cert "p256_mldsa65" "hybrid" "Hybrid ECDSA P-256 + ML-DSA-65"
        ;;
    
    2)
        # Hybrid: RSA-2048 + ML-DSA-65
        generate_cert "rsa3072_mldsa65" "hybrid" "Hybrid RSA-3072 + ML-DSA-65"
        ;;
    
    3)
        # Pure PQC: ML-DSA-65
        generate_cert "mldsa65" "pure" "Pure ML-DSA-65 (FIPS 204)"
        ;;
    
    4)
        # Pure PQC: ML-DSA-87
        generate_cert "mldsa87" "pure" "Pure ML-DSA-87 (Higher Security)"
        ;;
    
    5)
        # Generate all
        echo "Generating all certificate types..."
        echo ""
        
        generate_cert "p256_mldsa65" "hybrid" "Hybrid ECDSA P-256 + ML-DSA-65"
        generate_cert "rsa3072_mldsa65" "hybrid" "Hybrid RSA-3072 + ML-DSA-65"
        generate_cert "mldsa65" "pure" "Pure ML-DSA-65"
        generate_cert "mldsa87" "pure" "Pure ML-DSA-87"
        ;;
    
    0)
        echo "Exiting..."
        exit 0
        ;;
    
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=================================="
echo "Certificate Generation Complete!"
echo "=================================="
echo ""
echo "Generated files in: $CERT_DIR"
ls -lh "$CERT_DIR"
echo ""
echo "Next steps:"
echo "  1. Update NGINX configuration to use new certificates"
echo "  2. Set paths in nginx-hybrid.conf:"
echo "       ssl_certificate     $CERT_DIR/<algo>_cert.pem;"
echo "       ssl_certificate_key $CERT_DIR/<algo>_key.pem;"
echo "  3. Restart NGINX to apply changes"
echo ""
echo "Test with:"
echo "  openssl s_client -connect localhost:8443 -showcerts"
echo ""
