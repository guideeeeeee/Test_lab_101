#!/bin/bash
# Generate real PQC certificates inside Docker container
# Run this AFTER docker-compose build completes

set -e

CONTAINER_NAME="pqc-hybrid-nginx"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOST_CERTS_DIR="$SCRIPT_DIR/../certs-hybrid"

echo "=================================="
echo "Generate PQC Certificates in Docker"
echo "=================================="
echo ""

# Check if container exists
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "❌ Error: Container '$CONTAINER_NAME' not found!"
    echo ""
    echo "Please run first:"
    echo "  docker-compose -f docker-compose-hybrid.yml build"
    echo "  docker-compose -f docker-compose-hybrid.yml up -d"
    echo ""
    exit 1
fi

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠️  Container exists but not running. Starting..."
    docker-compose -f "$SCRIPT_DIR/../docker-compose-hybrid.yml" up -d
    sleep 5
fi

echo "✓ Container is running"
echo ""

# Check if OpenSSL with OQS is available
echo "[1/5] Checking OpenSSL with OQS..."
if ! docker exec "$CONTAINER_NAME" openssl list -providers 2>/dev/null | grep -q "oqsprovider"; then
    echo "❌ Error: OQS provider not available in container!"
    echo "The container may not be built with PQC support."
    exit 1
fi
echo "✓ OQS provider available"
echo ""

# Generate certificates inside container
echo "[2/5] Generating ECDSA certificate in container..."
docker exec "$CONTAINER_NAME" bash -c "
cd /tmp && \
openssl ecparam -name prime256v1 -genkey -out hybrid-ecdsa.key && \
openssl req -new -x509 \
  -key hybrid-ecdsa.key \
  -out hybrid-ecdsa.crt \
  -days 365 \
  -subj '/C=TH/ST=Bangkok/L=Bangkok/O=PQC Lab/OU=Security/CN=pqc-lab.local'
" 2>/dev/null

echo "✓ ECDSA certificate generated"

echo "[3/5] Generating ML-DSA (PQC) certificate in container..."
docker exec "$CONTAINER_NAME" bash -c "
cd /tmp && \
openssl genpkey -algorithm mldsa65 -out hybrid-mldsa.key && \
openssl req -new -x509 \
  -key hybrid-mldsa.key \
  -out hybrid-mldsa.crt \
  -days 365 \
  -subj '/C=TH/ST=Bangkok/L=Bangkok/O=PQC Lab/OU=Security/CN=pqc-lab.local'
" 2>/dev/null

echo "✓ ML-DSA certificate generated"

echo "[4/5] Creating certificate chain..."
docker exec "$CONTAINER_NAME" bash -c "
cd /tmp && \
cat hybrid-ecdsa.crt hybrid-mldsa.crt > hybrid-chain.pem
" 2>/dev/null

echo "✓ Certificate chain created"

echo "[5/5] Installing certificates..."
docker exec "$CONTAINER_NAME" bash -c "
cp /tmp/hybrid-*.key /tmp/hybrid-*.crt /tmp/hybrid-chain.pem /etc/nginx/certs/ && \
chmod 644 /etc/nginx/certs/*.crt /etc/nginx/certs/*.pem && \
chmod 600 /etc/nginx/certs/*.key
" 2>/dev/null

echo "✓ Certificates installed in container"
echo ""

# Copy certificates to host
echo "Copying certificates to host..."
docker cp "$CONTAINER_NAME:/etc/nginx/certs/hybrid-ecdsa.key" "$HOST_CERTS_DIR/"
docker cp "$CONTAINER_NAME:/etc/nginx/certs/hybrid-ecdsa.crt" "$HOST_CERTS_DIR/"
docker cp "$CONTAINER_NAME:/etc/nginx/certs/hybrid-mldsa.key" "$HOST_CERTS_DIR/"
docker cp "$CONTAINER_NAME:/etc/nginx/certs/hybrid-mldsa.crt" "$HOST_CERTS_DIR/"
docker cp "$CONTAINER_NAME:/etc/nginx/certs/hybrid-chain.pem" "$HOST_CERTS_DIR/"

echo "✓ Certificates copied to host"
echo ""

# Restart NGINX
echo "Restarting NGINX to load new certificates..."
docker exec "$CONTAINER_NAME" nginx -s reload 2>/dev/null || \
docker-compose -f "$SCRIPT_DIR/../docker-compose-hybrid.yml" restart

echo "✓ NGINX restarted"
echo ""

echo "=================================="
echo "✓ PQC Certificates Generated!"
echo "=================================="
echo ""

# Show certificate details
echo "Certificate details:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cd "$HOST_CERTS_DIR"
ls -lh *.crt *.key *.pem
echo ""
echo "📍 Location: $HOST_CERTS_DIR"
echo ""

# Verify PQC certificate
echo "Verifying ML-DSA certificate..."
if docker exec "$CONTAINER_NAME" openssl x509 -in /etc/nginx/certs/hybrid-mldsa.crt -text -noout 2>/dev/null | grep -q "mldsa"; then
    echo "✓ ML-DSA certificate verified!"
else
    echo "⚠️  Warning: Certificate may not be using ML-DSA algorithm"
fi

echo ""
echo "Next steps:"
echo "1. Test HTTPS: curl -k https://localhost:8443"
echo "2. Test hybrid TLS: openssl s_client -connect localhost:8443 -groups x25519_mlkem768"
echo "3. Verify certificates work correctly"
echo ""
