# Installing OpenSSL with OQS Support
# การติดตั้ง OpenSSL พร้อม OQS

## 📦 What We're Installing

To use PQC algorithms in TLS, we need:

```
┌─────────────────────────────────────┐
│     OpenSSL 3.x                     │  ← TLS/SSL library
│                                     │
│   ┌─────────────────────────────┐   │
│   │   oqs-provider              │   │  ← Provider plugin for OpenSSL
│   │                             │   │     (bridges OpenSSL ↔ liboqs)
│   │  ┌────────────────────┐     │   │
│   │  │   liboqs           │     │   │  ← PQC algorithm implementations
│   │  │                    │     │   │     (ML-KEM, ML-DSA, etc.)
│   │  └────────────────────┘     │   │
│   └─────────────────────────────┘   │
└─────────────────────────────────────┘
```

### Components

1. **OpenSSL 3.x**: Modern TLS library with provider architecture
2. **liboqs**: Open Quantum Safe library with PQC algorithms
3. **oqs-provider**: OpenSSL 3.x provider plugin

---

## ⚠️ Important: No Pre-compiled Binaries Available

**UPDATE:** Open Quantum Safe does NOT provide ready-to-use pre-compiled binary bundles of OpenSSL+liboqs+oqs-provider.

You have **2 options**:

### Option 1: Use Docker (⭐ RECOMMENDED - Fastest)
Skip manual installation and use our pre-built Docker image:
```bash
# See Part 2 - Docker approach (saves 30-40 minutes)
cd ~/pqcv2/labs/03-pqc-hybrid-setup
docker-compose -f docker-compose-hybrid.yml build
```

### Option 2: Build from Source (Advanced)
Continue below to build everything manually (~30-40 minutes).

---

## 🔨 Building from Source

⏱️ **Time Required:** 30-40 minutes  
💾 **Disk Space:** ~2GB during build, ~500MB after cleanup

### Step 1: Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    libssl-dev \
    ninja-build \
    ca-certificates \
    wget

# RHEL/CentOS
sudo yum groupinstall "Development Tools"
sudo yum install -y cmake git openssl-devel ninja-build wget
```

### Step 2: Download Source Code

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries

# ⚠️ WARNING: This downloads SOURCE CODE, not binaries!
# You will need to build everything (30-40 minutes)

# Option A: Download release tarball
wget https://github.com/open-quantum-safe/oqs-provider/releases/download/0.11.0/oqs-provider-0.11.0.tar.gz
tar -xzf oqs-provider-0.11.0.tar.gz
cd oqs-provider-0.11.0
# ⚠️ This is SOURCE CODE - see build instructions below!

# Option B: Clone repositories (recommended for latest)
# See "Build from Source" section below
```

### Step 3: Verify You Have Source Code (Not Binaries)

```bash
# Check what you downloaded
ls -la oqs-provider-0.11.0/

# If you see CMakeLists.txt, examples/, oqsprov/:
# ✅ You have source code (correct)

# If you see bin/, lib/, openssl executable:
# ❌ This would be binaries (not available from OQS!)
```

⚠️ **Important:** You MUST build from source. Continue to "Build from Source" section below.

---

## 🔨 Build from Source (REQUIRED)

### Prerequisites Check

```bash
# Check OpenSSL version
openssl version
# Expected: OpenSSL 3.3.0 or later (3.2.0+ minimum)

# List providers
openssl list -providers
# Should show: oqsprovider

# List KEM algorithms (both NIST and legacy names)
openssl list -kem-algorithms | grep -E "(mlkem|kyber)"
# Should show: mlkem512, mlkem768, mlkem1024 (NIST names)
#              kyber512, kyber768, kyber1024 (legacy names)
#              x25519_mlkem768, x25519_kyber768 (hybrid)

# List signature algorithms (both NIST and legacy names)
openssl list -signature-algorithms | grep -E "(mldsa|dilithium)"
# Should show: mldsa44, mldsa65, mldsa87 (NIST names)
#              dilithium2, dilithium3, dilithium5 (legacy names)
```

### Build Output Location

All components will be installed to: `~/pqcv2/labs/03-pqc-hybrid-setup/binaries/openssl-oqs/`

```
openssl-oqs/
├── bin/openssl           ← OpenSSL executable
├── lib/
│   ├── liboqs.so        ← PQC algorithms
│   ├── libssl.so        ← OpenSSL library
│   ├── libcrypto.so     ← Crypto library
│   └── ossl-modules/
│       └── oqsprovider.so  ← Provider plugin
└── openssl.cnf          ← Configuration
```

⚠️ **Note:** This directory will NOT exist until you complete all build steps below!

---

### Build Method

You have 2 approaches:

**Method A: Step-by-Step Build** (Better for learning, easier to debug)  
**Method B: Automated Build Script** (Faster, but harder to troubleshoot)

We'll show Method A (step-by-step).

---

## 📦 Step-by-Step Build Instructions

### Prerequisites

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    libssl-dev \
    ninja-build \
    ca-certificates \
    wget

# RHEL/CentOS
sudo yum groupinstall "Development Tools"
sudo yum install -y cmake git openssl-devel ninja-build wget
```

### Step 1: Build liboqs

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries

# Clone liboqs (latest stable: 0.11.0+)
# Check latest: https://github.com/open-quantum-safe/liboqs/releases
git clone --depth 1 --branch 0.11.0 https://github.com/open-quantum-safe/liboqs.git
cd liboqs

# Build
mkdir build && cd build
cmake -GNinja -DCMAKE_INSTALL_PREFIX=~/pqcv2/labs/03-pqc-hybrid-setup/binaries/openssl-oqs ..
ninja
ninja install

cd ../..
```

### Step 2: Build OpenSSL 3.x

```bash
# Clone OpenSSL (use 3.3.0+ for best compatibility)
# Check latest 3.x: https://github.com/openssl/openssl/tags
git clone --depth 1 --branch openssl-3.3.0 https://github.com/openssl/openssl.git
cd openssl

# Configure
./Configure --prefix=~/pqcv2/labs/03-pqc-hybrid-setup/binaries/openssl-oqs shared

# Build (this takes ~10 minutes)
make -j$(nproc)
make install

cd ..
```

### Step 3: Build oqs-provider

```bash
# Clone oqs-provider (latest stable: 0.11.0+)
# Important: 0.11.0+ uses NIST standard names (mlkem, mldsa)
# Check latest: https://github.com/open-quantum-safe/oqs-provider/releases
git clone --depth 1 --branch 0.11.0 https://github.com/open-quantum-safe/oqs-provider.git
cd oqs-provider

# Build
mkdir build && cd build
cmake -GNinja \
    -DCMAKE_PREFIX_PATH=~/pqcv2/labs/03-pqc-hybrid-setup/binaries/openssl-oqs \
    -DCMAKE_INSTALL_PREFIX=~/pqcv2/labs/03-pqc-hybrid-setup/binaries/openssl-oqs \
    ..
ninja
ninja install

cd ../..
```

### Step 4: Set Environment Variables

⚠️ **CRITICAL:** Use absolute path (not ~)

```bash
# Navigate to correct directory first
cd ~/pqcv2/labs/03-pqc-hybrid-setup/binaries

# Set environment variables with ABSOLUTE path
export PATH="$PWD/openssl-oqs/bin:$PATH"
export LD_LIBRARY_PATH="$PWD/openssl-oqs/lib:$LD_LIBRARY_PATH"

# Verify paths are set
echo "PATH: $PATH" | grep openssl-oqs
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH" | grep openssl-oqs

# Make permanent (add to ~/.bashrc)
echo "export PATH=\"$PWD/openssl-oqs/bin:\$PATH\"" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=\"$PWD/openssl-oqs/lib:\$LD_LIBRARY_PATH\"" >> ~/.bashrc
source ~/.bashrc

# Test installation
openssl version
# Expected: OpenSSL 3.3.0 or later

openssl list -providers
# Expected: oqsprovider should be listed
```

---

## 🧪 Testing the Installation

### Test 1: Check Algorithm Support

```bash
# List all KEM algorithms
openssl list -kem-algorithms

# Expected output includes both NIST and legacy names:
# NIST names (recommended):
#   - mlkem512, mlkem768, mlkem1024
#   - x25519_mlkem768, p256_mlkem768 (hybrid)
# Legacy names (backward compatible):
#   - kyber512, kyber768, kyber1024
#   - x25519_kyber768, p256_kyber768 (hybrid)

# List signature algorithms
openssl list -signature-algorithms

# Expected output includes both NIST and legacy names:
# NIST names (recommended):
#   - mldsa44, mldsa65, mldsa87
# Legacy names (backward compatible):
#   - dilithium2, dilithium3, dilithium5
# Others:
#   - falcon512, falcon1024, sphincssha2128fsimple, etc.
```

### Test 2: Generate PQC Key Pair

```bash
# Generate ML-KEM-768 keypair
openssl genpkey -algorithm mlkem768 -out test-mlkem.key

# Check key
openssl pkey -in test-mlkem.key -text -noout
# Should show: Symmetric key information for mlkem768

# Generate ML-DSA-65 keypair
openssl genpkey -algorithm mldsa65 -out test-mldsa.key

# Check key
openssl pkey -in test-mldsa.key -text -noout
```

### Test 3: Create Self-Signed PQC Certificate

```bash
# Generate ML-DSA-65 certificate
openssl req -new -x509 \
    -newkey mldsa65 \
    -keyout test-cert.key \
    -out test-cert.crt \
    -nodes \
    -days 365 \
    -subj "/CN=test-pqc"

# Verify certificate
openssl x509 -in test-cert.crt -text -noout

# Look for:
# Public Key Algorithm: mldsa65
# Signature Algorithm: mldsa65
```

### Test 4: Test TLS Connection

```bash
# Start test server (use NIST name)
openssl s_server \
    -accept 4433 \
    -cert test-cert.crt \
    -key test-cert.key \
    -groups x25519_mlkem768 \
    -www &

# Test client connection with NIST name
openssl s_client -connect localhost:4433 -groups x25519_mlkem768

# Look for:
# Shared Elliptic groups: x25519_mlkem768 (or x25519_kyber768 for legacy)

# Test with legacy name (should also work)
# openssl s_client -connect localhost:4433 -groups x25519_kyber768

# Kill test server
pkill -f "openssl s_server"

# Cleanup
rm test-*.key test-*.crt test-mlkem.key test-mldsa.key
```

---

## 🐛 Troubleshooting

### Issue: "unknown group name: x25519_mlkem768" or "x25519_kyber768"

```bash
# Check if oqs-provider is loaded
openssl list -providers

# If oqsprovider is missing:
export OPENSSL_MODULES=$PWD/binaries/openssl-oqs/lib/ossl-modules

# Or check openssl.cnf
cat /path/to/openssl-oqs/openssl.cnf

# Note: Use NIST names (mlkem) with 0.11.0+
# Legacy names (kyber) still work for backward compatibility
```

### Issue: "error while loading shared libraries: liboqs.so"

```bash
# Add to library path
export LD_LIBRARY_PATH=/path/to/openssl-oqs/lib:$LD_LIBRARY_PATH

# Or add permanently
echo "/path/to/openssl-oqs/lib" | sudo tee /etc/ld.so.conf.d/oqs.conf
sudo ldconfig
```

### Issue: OpenSSL still uses system version

```bash
# Check which openssl is being used
which openssl
# Should show: /path/to/binaries/openssl-oqs/bin/openssl

# If not, PATH is wrong
export PATH="/path/to/binaries/openssl-oqs/bin:$PATH"

# Verify
openssl version
```

### Issue: Build errors on Ubuntu 24.04+

```bash
# Install older gcc/g++ if needed
sudo apt-get install gcc-11 g++-11
export CC=gcc-11
export CXX=g++-11

# Rebuild
```

---

## 📋 Directory Structure

After installation:

```
binaries/
├── openssl-oqs/
│   ├── bin/
│   │   └── openssl              (PQC-enabled OpenSSL)
│   ├── lib/
│   │   ├── liboqs.so           (PQC algorithms)
│   │   ├── libssl.so           (OpenSSL SSL library)
│   │   ├── libcrypto.so        (OpenSSL crypto library)
│   │   └── ossl-modules/
│   │       └── oqsprovider.so  (Provider plugin)
│   ├── include/
│   └── openssl.cnf             (Configuration)
│
├── liboqs/                     (source, can delete)
├── openssl/                    (source, can delete)
└── oqs-provider/               (source, can delete)
```

---

## 🎯 Verification Checklist

- [ ] `openssl version` shows 3.3.0+ (3.2.0+ minimum)
- [ ] `openssl list -providers` shows `oqsprovider`
- [ ] `openssl list -kem-algorithms` includes both `mlkem` (NIST) and `kyber` (legacy)
- [ ] `openssl list -signature-algorithms` includes both `mldsa` (NIST) and `dilithium` (legacy)
- [ ] Can generate ML-KEM keypair (`mlkem768` or `kyber768`)
- [ ] Can generate ML-DSA certificate (`mldsa65` or `dilithium3`)
- [ ] Can connect with hybrid groups (`x25519_mlkem768` or `x25519_kyber768`)
- [ ] Environment variables set in `~/.bashrc`

---

## 📦 Docker Alternative

If you prefer Docker:

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git cmake ninja-build build-essential libssl-dev

# Build steps same as above...

# Or use pre-built image
FROM openquantumsafe/nginx:latest
```

---

## 🎯 Key Takeaways

1. **Use latest versions** (liboqs 0.11.0+, oqs-provider 0.11.0+, OpenSSL 3.3.0+)
2. **Pre-compiled binaries save time** (~2 minutes vs ~30 minutes)
3. **Three components needed:** OpenSSL 3.x + liboqs + oqs-provider
4. **NIST standard names** preferred: `mlkem768`, `mldsa65` (0.11.0+)
5. **Legacy names still work:** `kyber768`, `dilithium3` (backward compatible)
6. **Set LD_LIBRARY_PATH** to load shared libraries
7. **Verify with `openssl list`** commands
8. **Test with simple TLS connection** before proceeding
9. **Environment variables must persist** (add to ~/.bashrc)

---

**Next:** [04-certificate-generation.md](04-certificate-generation.md) - Generate hybrid certificates
