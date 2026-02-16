#!/bin/bash
# Create dummy certificates for Docker build
# These are temporary and will be replaced with real PQC certificates later

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CERTS_DIR="$SCRIPT_DIR/../certs-hybrid"

echo "=================================="
echo "Creating Dummy Certificates"
echo "=================================="
echo ""
echo "⚠️  WARNING: These are NOT PQC certificates!"
echo "These are temporary RSA certificates for initial Docker build."
echo "Real PQC certificates will be generated after Docker build completes."
echo ""

# Create certs directory if not exists
mkdir -p "$CERTS_DIR"
cd "$CERTS_DIR"

# Check if certificates already exist
if [ -f "hybrid-ecdsa.crt" ] && [ -f "hybrid-mldsa.crt" ]; then
    echo "⚠️  Certificates already exist!"
    echo ""
    ls -lh *.crt *.key 2>/dev/null || true
    echo ""
    read -p "Overwrite existing certificates? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Keeping existing certificates."
        exit 0
    fi
fi

echo "[1/3] Generating dummy ECDSA certificate..."
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout hybrid-ecdsa.key \
  -out hybrid-ecdsa.crt \
  -days 365 \
  -subj "/C=TH/ST=Bangkok/L=Bangkok/O=PQC Lab/OU=Dummy/CN=pqc-lab.local" \
  2>/dev/null

echo "✓ Created hybrid-ecdsa.key and hybrid-ecdsa.crt"

echo "[2/3] Creating dummy ML-DSA certificate (copy of ECDSA)..."
cp hybrid-ecdsa.key hybrid-mldsa.key
cp hybrid-ecdsa.crt hybrid-mldsa.crt

echo "✓ Created hybrid-mldsa.key and hybrid-mldsa.crt"

echo "[3/3] Creating certificate chain..."
cat hybrid-ecdsa.crt hybrid-mldsa.crt > hybrid-chain.pem
echo "✓ Created hybrid-chain.pem"

echo ""
echo "=================================="
echo "✓ Dummy Certificates Created"
echo "=================================="
echo ""
ls -lh *.crt *.key *.pem
echo ""
echo "📍 Location: $CERTS_DIR"
echo ""
echo "⚠️  IMPORTANT: These are DUMMY certificates!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo "1. Build Docker image: docker-compose -f docker-compose-hybrid.yml build"
echo "2. Start container: docker-compose -f docker-compose-hybrid.yml up -d"
echo "3. Generate real PQC certificates: ./scripts/generate-pqc-certs-in-docker.sh"
echo ""
echo "Or see: README.md Part 3 → Option A"
echo ""
