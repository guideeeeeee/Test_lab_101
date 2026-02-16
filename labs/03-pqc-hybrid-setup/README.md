# Lab 03: PQC Hybrid Setup 
# การติดตั้ง Post-Quantum Cryptography แบบ Hybrid

⏱️ **Duration:** 90 minutes  
🎯 **Objective:** Configure hybrid classical+post-quantum TLS

---

## 📖 Overview | ภาพรวม

This lab guides you through installing and configuring **hybrid post-quantum cryptography**. You'll upgrade the 2019 server to use:
- **X25519+MLKEM768** for key exchange (hybrid)
- **ECDSA+MLDSA65** for signatures (optional, hybrid)
- Keep AES-256-GCM for encryption (quantum-resistant symmetric)

ห้องปฏิบัติการนี้จะแนะนำการติดตั้งและตั้งค่า **hybrid post-quantum cryptography** คุณจะอัพเกรด server 2019 ให้ใช้:
- **X25519+MLKEM768** สำหรับแลกเปลี่ยนคีย์ (hybrid)
- **ECDSA+MLDSA65** สำหรับลายเซ็น (เลือกได้, hybrid)
- เก็บ AES-256-GCM สำหรับการเข้ารหัส (ทนควอนตัมุมได้แล้ว)

**Note:** We provide **pre-compiled OpenSSL+OQS binaries** to save time!

---

## 🎯 Learning Objectives

After this lab, you will be able to:
- Understand NIST PQC standards (ML-KEM, ML-DSA)
- Install OpenSSL 3.x with oqs-provider
- Generate hybrid PQC certificates
- Configure NGINX for hybrid TLS
- Test different PQC algorithm combinations
- Troubleshoot PQC-related issues

---

## 📚 Part 1: Understanding PQC Algorithms (15 min)

### Step 1.1: Read PQC Overview

📖 **Read:** [guides/01-pqc-intro.md](guides/01-pqc-intro.md)

This covers:
- What is post-quantum cryptography?
- NIST PQC competition results
- ML-KEM-768 (Kyber) explained
- ML-DSA-65 (Dilithium) explained
- Lattice-based cryptography basics

### Step 1.2: Understand Hybrid Approach

 **Read:** [guides/02-hybrid-concept.md](guides/02-hybrid-concept.md)

Why hybrid?
```
Classical Only     → Quantum-vulnerable
Pure PQC Only      → Risk if PQC breaks
Hybrid (Both)      → Secure if EITHER is secure ✅
```

**Example: X25519+MLKEM768**
```
Shared Secret = ECDHE-Secret XOR ML-KEM-Secret

If quantum breaks ECDHE → Still have ML-KEM
If flaw found in ML-KEM → Still have ECDHE
```

---

## 🔧 Part 2: Installing PQC Tools (20 min)

### ⚠️ Important Update: No Pre-compiled Binaries

**The fastest way is to use Docker** (included in Part 4). Building from source takes 30-40 minutes.

### Step 2.1: Choose Installation Method

**Option A: Use Docker (⭐ RECOMMENDED)**
```bash
# Skip manual installation, use Docker instead!
# Continue to Part 4 - you'll build everything in Docker
```

**Option B: Build from Source (Advanced Users)**
```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries

# ⚠️ WARNING: This requires building OpenSSL, liboqs, and oqs-provider
# Time: 30-40 minutes | Disk: ~2GB during build

# See detailed instructions:
# 📝 guides/03-install-oqs.md
```

### Step 2.2: Verify Installation (Skip if using Docker)

⚠️ **Only needed if you built from source manually**

```bash
# Only if you built from source:
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries

# Set environment variables
export PATH="$PWD/openssl-oqs/bin:$PATH"
export LD_LIBRARY_PATH="$PWD/openssl-oqs/lib:$LD_LIBRARY_PATH"

# Verify installation
openssl version
# Expected: OpenSSL 3.x with OQS support

# List available PQC algorithms
openssl list -kem-algorithms
openssl list -signature-algorithms
```

📝 **Follow:** [guides/03-install-oqs.md](guides/03-install-oqs.md) for complete build instructions

⚠️ **Or skip to Part 4 and use Docker instead!**

---

```
┌─────────────────────────────────────┐
│     OpenSSL 3.x                     │  ← TLS implementation
│                                     │
│   ┌─────────────────────────────┐   │
│   │   oqs-provider              │   │  ← Provider plugin
│   │                             │   │
│   │  ┌────────────────────┐     │   │
│   │  │   liboqs           │     │   │  ← PQC algorithms
│   │  │  (ML-KEM, ML-DSA)  │     │   │
│   │  └────────────────────┘     │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

---

## 🔐 Part 3: Generate Hybrid Certificates (20 min)

### ⚠️ Important: Choose Your Path

**If using Docker (Part 4):**
- ✅ **Option A: Generate inside Docker** (Recommended)
  - Skip Part 3 now
  - Create dummy certificates first
  - Generate real certificates after Docker builds
  - See "Option A" below

**If building manually (Part 2):**
- ✅ **Option B: Generate on host**
  - Need OpenSSL+OQS installed first (Part 2)
  - Follow normal steps below
  - See "Option B" below

---

### Option A: For Docker Users (Skip to Part 4)

**Step 1: Create dummy certificates** (temporary)

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/certs-hybrid

# Create dummy self-signed certificates for initial Docker build
# These will be replaced with real PQC certificates later

openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout hybrid-ecdsa.key \
  -out hybrid-ecdsa.crt \
  -days 365 -subj "/CN=pqc-lab.local"

cp hybrid-ecdsa.key hybrid-mldsa.key
cp hybrid-ecdsa.crt hybrid-mldsa.crt

echo "✅ Dummy certificates created for Docker build"
echo "⚠️  These are NOT PQC certificates yet!"
echo "📝 You'll generate real PQC certificates after Docker build (see Part 4)"
```

**Step 2: After Docker builds** (in Part 4), generate real PQC certificates:

```bash
# After docker-compose build completes...

# Generate real PQC certificates inside container
docker exec pqc-hybrid-nginx bash -c "
cd /tmp && \
openssl ecparam -name prime256v1 -genkey -out ecdsa.key && \
openssl req -new -x509 -key ecdsa.key -out ecdsa.crt -days 365 -subj '/CN=pqc-lab.local' && \
openssl genpkey -algorithm mldsa65 -out mldsa.key && \
openssl req -new -x509 -key mldsa.key -out mldsa.crt -days 365 -subj '/CN=pqc-lab.local' && \
cp ecdsa.* mldsa.* /etc/nginx/certs/
"

# Restart NGINX to load new certificates
docker-compose -f docker-compose-hybrid.yml restart

echo "✅ Real PQC certificates generated!"
```

**➡️ Skip to Part 4 now if using Docker**

---

### Option B: For Manual Build Users

⚠️ **Prerequisites:** You must complete Part 2 (build OpenSSL+OQS) first!

### Step 3.1: Understanding Certificate Requirements

For hybrid setup, we need:
1. **Traditional certificate** (ECDSA or RSA) - for compatibility
2. **PQC certificate** (ML-DSA) - for quantum resistance
3. Optional: **Composite/Dual certificate** (both in one)

### Step 3.2: Generate Hybrid Certificate

⚠️ **This requires OpenSSL with OQS installed!** (Part 2 must be complete)

```bash
cd certs-hybrid/  # Note: certs-hybrid, not certs/

# Method 1: ECDSA + MLDSA65 (recommended)
../scripts/generate-hybrid-cert.sh --type ecdsa-mldsa

# Method 2: RSA + MLDSA65 (larger but more compatible)
../scripts/generate-hybrid-cert.sh --type rsa-mldsa

# Method 3: Pure MLDSA65 (smallest but less compatible)
../scripts/generate-hybrid-cert.sh --type pure-mldsa
```

**What this creates:**
```
certs-hybrid/  # Note: directory name
├── hybrid-ecdsa.key    (ECDSA P-256 private key)
├── hybrid-ecdsa.crt    (ECDSA certificate)
├── hybrid-mldsa.key    (ML-DSA-65 private key)
├── hybrid-mldsa.crt    (ML-DSA-65 certificate)
└── hybrid-chain.pem    (Combined chain for dual-cert setup)
```

📖 **Detailed guide:** [guides/04-certificate-generation.md](guides/04-certificate-generation.md)

### Step 3.3: Inspect PQC Certificate

⚠️ **Requires OpenSSL with OQS**

```bash
# View ML-DSA certificate (if you generated with Option B)
openssl x509 -in certs-hybrid/hybrid-mldsa.crt -text -noout

# Look for:
# - Public Key Algorithm: mldsa65
# - Signature Algorithm: mldsa65
# - Key size (much larger than RSA!)
```

---

## ⚙️ Part 4: Configure NGINX for Hybrid TLS (25 min)

### Step 4.1: Understanding Hybrid Configuration

We'll configure NGINX to:
1. Use hybrid key exchange (X25519+MLKEM768)
2. Serve dual certificates (ECDSA + MLDSA)
3. Fall back gracefully for non-PQC clients

### Step 4.2: Create Hybrid NGINX Config

Edit `configs/nginx-hybrid.conf`:

```nginx
# Hybrid TLS Configuration
ssl_protocols TLSv1.3;  # TLS 1.3 required for hybrid KEMs

# Hybrid cipher suites
ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256';

# Hybrid Key Exchange (X25519 + ML-KEM-768)
ssl_ecdh_curve X25519:x25519_kyber768:P-256;

# Dual certificates
ssl_certificate certs/hybrid-ecdsa.crt;
ssl_certificate_key certs/hybrid-ecdsa.key;
ssl_certificate certs/hybrid-mldsa.crt;
ssl_certificate_key certs/hybrid-mldsa.key;

# PQC-specific settings
ssl_prefer_server_ciphers on;
ssl_session_cache shared:MozSSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;
```

📖 **Line-by-line explanation:** [guides/05-nginx-configuration.md](guides/05-nginx-configuration.md)

### Step 4.3: Build PQC-Enabled NGINX Container

```bash
# Build container with OpenSSL+OQS
docker-compose -f docker-compose-hybrid.yml build

# Start hybrid server
docker-compose -f docker-compose-hybrid.yml up -d

# Check logs
docker logs pqc-hybrid-nginx
```

📝 **Dockerfile:** [Dockerfile.nginx-pqc](Dockerfile.nginx-pqc)

---

## 🧪 Part 5: Testing Hybrid TLS (20 min)

### Step 5.1: Test with OpenSSL Client

```bash
# Test hybrid connection
openssl s_client -connect localhost:8443 -groups x25519_kyber768:X25519

# Look for:
# - Protocol: TLSv1.3
# - Cipher: TLS_AES_256_GCM_SHA384
# - Group: x25519_kyber768 (hybrid!)
# - Certificate: mldsa65 or ecdsa
```

### Step 5.2: Test Algorithm Negotiation

```bash
# Test 1: Force X25519 only (classical)
openssl s_client -connect localhost:8443 -groups X25519

# Test 2: Request Kyber768 hybrid
openssl s_client -connect localhost:8443 -groups x25519_kyber768

# Test 3: Pure Kyber (if supported)
openssl s_client -connect localhost:8443 -groups kyber768
```

### Step 5.3: Verify Certificate

```bash
# Check which certificate is served
openssl s_client -connect localhost:8443 -showcerts | grep "Subject:"

# Compare certificate sizes
ls -lh certs/hybrid-*.crt
```

---

## 📊 Part 6: Algorithm Comparison (15 min)

Test different PQC algorithms and record observations:

| Algorithm | Handshake Time | Cert Size | Success? |
|-----------|----------------|-----------|----------|
| X25519 (classical) | ______ | ______ | □ |
| X25519+MLKEM768 (hybrid) | ______ | ______ | □ |
| Pure MLKEM768 | ______ | ______ | □ |
| MLKEM512 (weaker) | ______ | ______ | □ |
| MLKEM1024 (stronger) | ______ | ______ | □ |

📝 **Worksheet:** [worksheets/algorithm-comparison.md](worksheets/algorithm-comparison.md)

---

## 🎯 Lab Checklist

**Option A: Docker Users** (Recommended)
- [ ] Read PQC introduction guides
- [ ] Created dummy RSA certificates (`create-dummy-certs.sh`)
- [ ] Built PQC-enabled container (`docker-compose build`)
- [ ] Started container (`docker-compose up -d`)
- [ ] Generated real PQC certificates in container (`generate-pqc-certs-in-docker.sh`)
- [ ] Inspected ML-DSA certificate
- [ ] Tested hybrid connection (X25519+MLKEM768)
- [ ] Verified certificate serving
- [ ] Container running on port 8443

**Option B: Manual Build Users**
- [ ] Read PQC introduction guides
- [ ] Built OpenSSL+OQS from source (Part 2)
- [ ] Listed available KEM algorithms
- [ ] Generated hybrid certificates with host OpenSSL (`generate-hybrid-cert.sh`)
- [ ] Inspected ML-DSA certificate
- [ ] Configured NGINX for hybrid TLS
- [ ] Tested hybrid connection (X25519+MLKEM768)
- [ ] Verified certificate serving
- [ ] Server running on port 8443

---

## 📁 Files Structure

```
labs/03-pqc-hybrid-setup/
├── README.md (this file)
│
├── guides/
│   ├── 01-pqc-intro.md (NIST PQC overview)
│   ├── 02-hybrid-concept.md (Why hybrid?)
│   ├── 03-install-oqs.md (Installation steps)
│   ├── 04-certificate-generation.md
│   └── 05-nginx-configuration.md
│
├── binaries/ ⭐
│   ├── README-FIRST.md (⚠️ Pre-compiled vs Source explanation)
│   ├── installation-guide.md (Build from source instructions)
│   └── IMPORTANT-PATH-NOTES.md (Path naming clarification)
│
├── scripts/
│   ├── create-dummy-certs.sh ✨ (Phase 1: Temporary RSA certs for Docker)
│   ├── generate-hybrid-cert.sh (Manual: PQC cert generation on host)
│   ├── generate-pqc-certs-in-docker.sh ✨ (Phase 2: Real PQC certs in container)
│   ├── test-algorithms.sh (test all KEMs)
│   └── benchmark-pqc.sh (quick performance test)
│
├── configs/
│   ├── nginx-hybrid.conf (main config)
│   ├── ssl-params-hybrid.conf (TLS settings)
│   └── groups-priority.conf (algorithm priority)
│
├── certs/ (generated certificates go here)
│   └── .gitkeep
│
├── docker-compose-hybrid.yml
├── Dockerfile.nginx-pqc
│
└── worksheets/
    ├── algorithm-comparison.md
    └── configuration-checklist.md
```

---

## 🐛 Troubleshooting

### Issue: "No such file or directory: certs-hybrid/"

**Docker users:** You need certificates before building Docker image!

```bash
# Phase 1: Create dummy certificates
./scripts/create-dummy-certs.sh

# These are temporary RSA certs for initial Docker build
# You'll generate real PQC certs after Docker is running
```

### Issue: "generate-hybrid-cert.sh" fails with Exit Code 1

**Cause:** You don't have OpenSSL+OQS on host system.

**Docker users:** Use the two-phase approach:
1. Create dummy certs first (`create-dummy-certs.sh`)
2. Build Docker with those dummy certs
3. Generate real PQC certs inside container (`generate-pqc-certs-in-docker.sh`)

**Manual users:** Complete Part 2 first to build OpenSSL+OQS on your host.

### Issue: "unknown group name: x25519_kyber768"

```bash
# Check if oqs-provider is loaded
openssl list -providers

# Should show: oqsprovider

# If not, check LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/path/to/openssl-oqs/lib:$LD_LIBRARY_PATH
```

### Issue: Certificate validation failed

```bash
# Use self-signed CA for testing
# Add -CAfile flag or use -k with curl
curl -k https://localhost:8443
```

### Issue: NGINX won't start

```bash
# Check configuration
docker exec pqc-hybrid-nginx nginx -t

# Check logs
docker logs pqc-hybrid-nginx

# Common issue: Certificate paths incorrect in nginx-hybrid.conf
```

### Issue: Slow handshake with PQC

```bash
# This is expected! PQC is slower than classical crypto
# We'll measure and analyze performance in Lab 04
```

### Issue: "Pre-compiled binaries" don't exist

**See:** [binaries/README-FIRST.md](binaries/README-FIRST.md) for complete explanation.

**Quick answer:** OQS doesn't provide ready-to-use OpenSSL bundles. Use Docker (recommended) or build from source (30-40 minutes).

---

## 💡 Key Takeaways

- **Hybrid = Classical + PQC** = Secure against both threats
- **ML-KEM-768 (Kyber)** = NIST standard for key exchange
- **ML-DSA-65 (Dilithium)** = NIST standard for signatures
- **Lattice-based crypto** = Quantum-resistant foundation
- **TLS 1.3 required** for hybrid key exchange
- **Larger certificates** but manageable (~5-10 KB vs 1-2 KB)
- ** Slower handshakes** but still practical (~2-3x classical)

---

## 🎯 What's Next?

**Lab 04:** Measure hybrid TLS performance (same tests as Lab 02)  
Then compare hybrid vs classical!

<div align="center">

[← Lab 02](../02-baseline-testing/) | [Main](../../README.md) | [Lab 04 →](../04-hybrid-testing/)

</div>
