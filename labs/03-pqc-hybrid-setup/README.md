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

## 🔐 Part 3: Generate Hybrid Certificates (5 min)

### ✨ Automated Certificate Generation

**Docker automatically generates PQC hybrid certificates on first start!**

No manual steps required. The container will:
1. Detect if certificates exist
2. If not, generate hybrid certificates automatically:
   - **CA:** P-384 + ML-DSA-65
   - **Server:** P-384 + ML-DSA-65
3. Start NGINX with PQC hybrid TLS

---

### Quick Setup

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup

# Option 1: Using setup script
./setup.sh

# Option 2: Using pqc.sh helper (recommended)
./pqc.sh build   # Build Docker image
./pqc.sh start   # Start and auto-generate certs
./pqc.sh certs   # View certificate details
```

**That's it!** Certificates are created automatically.

---

### Manual Certificate Generation (Optional)

If you need to regenerate certificates manually:

```bash
# Inside container
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid bash
/usr/local/bin/generate-pqc-certs.sh

# Or using helper script
./pqc.sh gencerts
```

---

### Understanding Certificate Structure

The auto-generated certificates use:
- **Algorithm:** P-384 + ML-DSA-65 (Hybrid)
- **CA Certificate:** Self-signed root CA
- **Server Certificate:** Signed by CA
- **Subject Alt Names:** pqc-lab.local, localhost, 127.0.0.1

**Certificate files created:**
```
certs-hybrid/
├── ca-hybrid.key           (CA private key)
├── ca-hybrid.crt           (CA certificate)
├── server-hybrid.key       (Server private key)
├── server-hybrid.crt       (Server certificate)
└── fullchain-hybrid.crt    (Full certificate chain)
```

📖 **Detailed guide:** [guides/04-certificate-generation.md](guides/04-certificate-generation.md)

### Step 3.3: Inspect PQC Certificate

✅ **Inspect certificates using container's OQS-enabled OpenSSL**

```bash
# Using pqc.sh helper
./pqc.sh certs

# Or manually

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

**Docker Users** (Recommended - Automated Setup)
- [ ] Read PQC introduction guides
- [ ] Built PQC-enabled container (`./setup.sh` or `./pqc.sh build`)
- [ ] Started container (certificates auto-generated on first start)
- [ ] Verified PQC certificates were created
- [ ] Inspected hybrid certificate (P-384 + ML-DSA-65)
- [ ] Tested hybrid connection (X25519+MLKEM768)
- [ ] Verified TLS handshake using PQC algorithms
- [ ] Container running on port 8443

**Manual Certificate Generation** (Optional - Advanced Users)
- [ ] Read PQC introduction guides
- [ ] Container running with OQS-enabled OpenSSL
- [ ] Manually generated certificates: `./pqc.sh gencerts`
- [ ] Inspected certificate details
- [ ] Tested different PQC algorithm combinations
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
│   ├── docker-entrypoint.sh ⭐ (Auto-generate certs on container start)
│   ├── generate-pqc-certs.sh ⭐ (Main cert generation script)
│   ├── test-algorithms.sh (test all KEMs)
│   └── benchmark-pqc.sh (performance testing)
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

### Issue: Container fails to start or certificates not found

**Solution:** Ensure `certs-hybrid/` directory exists and is writable

```bash
# Create directory if missing
mkdir -p certs-hybrid

# Start container - certificates will be auto-generated
./pqc.sh start

# View logs to see certificate generation
./pqc.sh logs
```

### Issue: Certificates not auto-generated

**Check logs for errors:**

```bash
# View container logs
./pqc.sh logs

# Manually generate certificates
./pqc.sh gencerts
```

**Common causes:**
- `certs-hybrid/` not writable
- oqsprovider not loaded in container
- OpenSSL configuration issue

### Issue: "unknown group name: x25519_mlkem768"

**Cause:** NGINX not compiled with OQS-enabled OpenSSL

```bash
# Verify oqs-provider is loaded in container
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  /opt/openssl/bin/openssl list -providers

# Should show: oqsprovider with "status: active"

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
