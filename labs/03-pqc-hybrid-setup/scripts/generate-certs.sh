#!/bin/bash
# Script to generate ECDSA and ML-DSA certificates for PQC Hybrid TLS
# Usage: ./generate-certs.sh [container_name]

set -e

CONTAINER_NAME="${1:-pqc-hybrid-nginx}"
CERT_DIR="/etc/nginx/certs"
TEMP_DIR="/tmp"

echo "================================================"
echo "  PQC Hybrid Certificate Generation Script"
echo "================================================"

# Fix library paths (needed after container restart)
echo ""
echo "Step 1: Configuring OpenSSL library paths..."
docker exec "$CONTAINER_NAME" bash -c "
    echo '/opt/openssl/lib64' > /etc/ld.so.conf.d/openssl.conf && \
    echo '/opt/oqs/lib' > /etc/ld.so.conf.d/liboqs.conf && \
    ldconfig
"
echo "✓ Library paths configured"

# Verify OpenSSL works
echo ""
echo "Step 2: Verifying OpenSSL installation..."
docker exec "$CONTAINER_NAME" bash -c "openssl version"
echo "✓ OpenSSL verified"

# Generate ECDSA certificate
echo ""
echo "Step 3: Generating ECDSA (classical) certificate..."
docker exec "$CONTAINER_NAME" bash -c "
    cd $TEMP_DIR && \
    rm -f ecdsa.* && \
    openssl ecparam -name prime256v1 -genkey -out ecdsa.key && \
    openssl req -new -x509 -key ecdsa.key -out ecdsa.crt -days 365 \
        -subj '/CN=pqc-lab.local/O=PQC Lab/C=TH'
"
echo "✓ ECDSA certificate generated"

# Generate ML-DSA certificate
echo ""
echo "Step 4: Generating ML-DSA65 (post-quantum) certificate..."
docker exec "$CONTAINER_NAME" bash -c "
    cd $TEMP_DIR && \
    rm -f mldsa.* && \
    openssl genpkey -algorithm mldsa65 -provider oqsprovider -out mldsa.key && \
    openssl req -new -x509 -key mldsa.key \
        -provider oqsprovider -provider default \
        -out mldsa.crt -days 365 \
        -subj '/CN=pqc-lab.local/O=PQC Lab/C=TH'
"
echo "✓ ML-DSA certificate generated"

# Copy certificates to nginx directory
echo ""
echo "Step 5: Copying certificates to nginx directory..."
docker exec "$CONTAINER_NAME" bash -c "
    cp $TEMP_DIR/ecdsa.* $TEMP_DIR/mldsa.* $CERT_DIR/ && \
    chmod 644 $CERT_DIR/ecdsa.crt $CERT_DIR/mldsa.crt && \
    chmod 600 $CERT_DIR/ecdsa.key $CERT_DIR/mldsa.key
"
echo "✓ Certificates copied and permissions set"

# Verify certificates
echo ""
echo "Step 6: Verifying generated certificates..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ECDSA Certificate (Classical Cryptography):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec "$CONTAINER_NAME" bash -c "
    openssl x509 -in $CERT_DIR/ecdsa.crt -noout -text | \
    grep -E 'Subject:|Issuer:|Not Before|Not After|Public Key Algorithm:|Signature Algorithm:'
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ML-DSA Certificate (Post-Quantum Cryptography):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec "$CONTAINER_NAME" bash -c "
    openssl x509 -in $CERT_DIR/mldsa.crt -noout -text | \
    grep -E 'Subject:|Issuer:|Not Before|Not After|Public Key Algorithm:|Signature Algorithm:'
"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Certificate Files:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
docker exec "$CONTAINER_NAME" bash -c "ls -lh $CERT_DIR/*.{crt,key} 2>/dev/null"

echo ""
echo "================================================"
echo "  ✓ Certificate generation completed!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Update nginx configuration to use these certificates"
echo "  2. Test with: docker exec $CONTAINER_NAME nginx -t"
echo "  3. Reload nginx: docker exec $CONTAINER_NAME nginx -s reload"
echo ""
