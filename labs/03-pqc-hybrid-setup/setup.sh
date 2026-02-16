#!/bin/bash
# Setup script for Lab 03: PQC Hybrid Setup
# ติดตั้งและกำหนดค่า PQC Hybrid TLS

set -e

echo "=================================="
echo "Lab 03: PQC Hybrid Setup"
echo "=================================="
echo ""

LAB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$LAB_DIR"

# Step 1: Check prerequisites
echo "[1/6] Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker not installed"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "ERROR: Docker Compose not installed"
    exit 1
fi

echo "✓ Docker: $(docker --version)"
echo "✓ Docker Compose: $(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo 'not found')"
echo ""

# Important notice
echo "⚠️  IMPORTANT NOTICE:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "This script will BUILD OpenSSL + liboqs + oqs-provider from source."
echo ""
echo "⏱️  Expected time: 30-40 minutes"
echo "💾 Disk space required: ~2GB during build"
echo ""
echo "There are NO pre-compiled binaries available from OQS."
echo "All components must be built from source code."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Continue with build? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi
echo ""

# Step 2: Create directories
echo "[2/6] Creating directories..."
mkdir -p certs-hybrid logs www

# Create placeholder website if not exists
if [ ! -f "www/index.html" ]; then
    cat > www/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PQC Hybrid TLS Server</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            max-width: 900px;
            margin: 50px auto;
            padding: 30px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .container {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 { margin-top: 0; font-size: 2.5em; }
        .badge {
            display: inline-block;
            background: rgba(255, 255, 255, 0.2);
            padding: 8px 16px;
            border-radius: 20px;
            margin: 5px;
            font-size: 0.9em;
        }
        .success { background: rgba(16, 185, 129, 0.3); }
        a { color: #fbbf24; text-decoration: none; font-weight: bold; }
        a:hover { text-decoration: underline; }
        ul { line-height: 2; }
        .warning {
            background: rgba(245, 158, 11, 0.2);
            border-left: 4px solid #f59e0b;
            padding: 15px;
            margin: 20px 0;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔐 PQC Hybrid TLS Server</h1>
        
        <p><strong>Congratulations!</strong> You've successfully connected to a server using <strong>Post-Quantum Cryptography (PQC)</strong>!</p>
        
        <h2>🎯 Active Algorithms</h2>
        <div>
            <span class="badge success">ML-KEM-768 (Key Exchange)</span>
            <span class="badge success">ML-DSA-65 (Signature)</span>
            <span class="badge success">AES-256-GCM (Encryption)</span>
            <span class="badge">TLS 1.3</span>
        </div>
        
        <h2>✨ What Makes This Special?</h2>
        <ul>
            <li><strong>Quantum-Resistant:</strong> Secure against future quantum computers</li>
            <li><strong>Hybrid Approach:</strong> Combines classical (ECDSA/RSA) with PQC (ML-DSA)</li>
            <li><strong>NIST Standardized:</strong> Uses FIPS 203 (ML-KEM) and FIPS 204 (ML-DSA)</li>
            <li><strong>Forward Compatible:</strong> Ready for post-quantum era</li>
        </ul>
        
        <h2>🔍 Verify Your Connection</h2>
        <p>Check TLS details with:</p>
        <pre style="background: rgba(0,0,0,0.3); padding: 15px; border-radius: 10px; overflow-x: auto;">openssl s_client -connect localhost:8443 -showcerts</pre>
        
        <p><a href="/tls-info">📊 View TLS Connection Info (JSON)</a></p>
        
        <div class="warning">
            <strong>⚠️ Educational Lab Only</strong><br>
            This is a laboratory environment for learning purposes. Do not deploy to production without proper security review and hardening.
        </div>
        
        <hr style="border: 1px solid rgba(255,255,255,0.2); margin: 30px 0;">
        
        <p style="text-align: center; font-size: 0.9em; opacity: 0.8;">
            Lab 03: PQC Hybrid Setup | 
            <a href="https://csrc.nist.gov/projects/post-quantum-cryptography" target="_blank">NIST PQC Project</a>
        </p>
    </div>
</body>
</html>
EOF
    echo "✓ Created default website"
fi

echo "✓ Directories created"
echo ""

# Step 3: Check for certificates
echo "[3/6] Checking certificates..."
if [ -f "certs-hybrid/server-hybrid.crt" ] && [ -f "certs-hybrid/server-hybrid.key" ]; then
    echo "✓ Hybrid certificates found"
    echo "  - Using existing certificates in certs-hybrid/"
else
    echo "⚠ Certificates not found in certs-hybrid/"
    echo ""
    echo "✓ No problem! Certificates will be auto-generated by Docker container"
    echo ""
    echo "The container will automatically generate:"
    echo "  - Hybrid CA: P-384 + ML-DSA-65"
    echo "  - Server Certificate: P-384 + ML-DSA-65"
    echo "  - Using OQS-enabled OpenSSL from container"
    echo ""
    echo "If you want to generate certificates manually:"
    echo "  docker compose -f docker-compose-hybrid.yml run nginx-pqc-hybrid /usr/local/bin/generate-pqc-certs.sh"
fi
echo ""

# Step 4: Build Docker image
echo "[4/6] Building PQC-enabled NGINX Docker image..."
echo "⚠ This will take 30-60 minutes (compiling OpenSSL, liboqs, oqs-provider, NGINX)"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Build cancelled."
    echo ""
    echo "Alternative: Use pre-built image (if available)"
    echo "  docker pull <registry>/pqc-nginx:latest"
    exit 1
fi

docker compose -f docker-compose-hybrid.yml build
echo "✓ Docker image built"
echo ""

# Step 5: Start services
echo "[5/6] Starting services..."
docker compose -f docker-compose-hybrid.yml up -d

echo "✓ Services started"
echo ""

# Step 6: Verify
echo "[6/6] Verifying deployment..."
sleep 5

if docker ps | grep -q "pqc-hybrid-nginx"; then
    echo "✓ NGINX container is running"
else
    echo "✗ NGINX container failed to start"
    echo "Check logs: docker logs pqc-hybrid-nginx"
    exit 1
fi

if docker ps | grep -q "pqc-hybrid-mysql"; then
    echo "✓ MySQL container is running"
else
    echo "✗ MySQL container failed to start"
    echo "Check logs: docker logs pqc-hybrid-mysql"
    exit 1
fi

echo ""
echo "=================================="
echo "Setup Complete!"
echo "=================================="
echo ""
echo "Access the server:"
echo "  HTTPS: https://localhost:8443"
echo "  HTTP:  http://localhost:8080 (redirects to HTTPS)"
echo ""
echo "Verify TLS connection:"
echo "  openssl s_client -connect localhost:8443 -showcerts"
echo ""
echo "Check logs:"
echo "  docker logs pqc-hybrid-nginx"
echo "  tail -f logs/access.log"
echo ""
echo "Next: Lab 04 - Hybrid Testing"
echo "  cd ../04-hybrid-testing"
echo ""
