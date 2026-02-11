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

### Step 2.1: Extract Pre-compiled Binaries

We provide pre-compiled OpenSSL 3.x + liboqs + oqs-provider for faster setup!

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup

# Extract pre-compiled binaries
tar -xzf binaries/openssl-3.x-oqs-linux-x64.tar.gz -C binaries/

# Set environment variables
export PATH="$PWD/binaries/openssl-oqs/bin:$PATH"
export LD_LIBRARY_PATH="$PWD/binaries/openssl-oqs/lib:$LD_LIBRARY_PATH"

# Verify installation
openssl version
# Expected: OpenSSL 3.x with OQS support

# List available PQC algorithms
openssl list -kem-algorithms
openssl list -signature-algorithms
```

📝 **Follow:** [guides/03-install-oqs.md](guides/03-install-oqs.md)

### Step 2.2: Understanding the Components

```
┌─────────────────────────────────────┐
│     OpenSSL 3.x                      │  ← TLS implementation
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

### Step 3.1: Understanding Certificate Requirements

For hybrid setup, we need:
1. **Traditional certificate** (ECDSA or RSA) - for compatibility
2. **PQC certificate** (ML-DSA) - for quantum resistance
3. Optional: **Composite/Dual certificate** (both in one)

### Step 3.2: Generate Hybrid Certificate

```bash
cd certs/

# Method 1: ECDSA + MLDSA65 (recommended)
../scripts/generate-hybrid-cert.sh --type ecdsa-mldsa

# Method 2: RSA + MLDSA65 (larger but more compatible)
../scripts/generate-hybrid-cert.sh --type rsa-mldsa

# Method 3: Pure MLDSA65 (smallest but less compatible)
../scripts/generate-hybrid-cert.sh --type pure-mldsa
```

**What this creates:**
```
certs/
├── hybrid-ecdsa.key    (ECDSA P-256 private key)
├── hybrid-ecdsa.crt    (ECDSA certificate)
├── hybrid-mldsa.key    (ML-DSA-65 private key)
├── hybrid-mldsa.crt    (ML-DSA-65 certificate)
└── hybrid-chain.pem    (Combined chain for dual-cert setup)
```

📖 **Detailed guide:** [guides/04-certificate-generation.md](guides/04-certificate-generation.md)

### Step 3.3: Inspect PQC Certificate

```bash
# View ML-DSA certificate
openssl x509 -in certs/hybrid-mldsa.crt -text -noout

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

- [ ] Read PQC introduction guides
- [ ] Installed OpenSSL+OQS (pre-compiled)
- [ ] Listed available KEM algorithms
- [ ] Generated hybrid certificates (ECDSA+MLDSA)
- [ ] Inspected ML-DSA certificate
- [ ] Configured NGINX for hybrid TLS
- [ ] Built PQC-enabled container
- [ ] Tested hybrid connection (X25519+MLKEM768)
- [ ] Verified certificate serving
- [ ] Compared different algorithms
- [ ] Container running on port 8443

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
│   ├── openssl-3.x-oqs-linux-x64.tar.gz (pre-compiled)
│   └── installation-guide.md
│
├── scripts/
│   ├── generate-hybrid-cert.sh (certificate generator)
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

# Common issue: Certificate paths incorrect
```

### Issue: Slow handshake with PQC

```bash
# This is expected! PQC is slower
# We'll measure and analyze in Lab 04
```

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
