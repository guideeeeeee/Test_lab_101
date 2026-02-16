# Hybrid Certificate Generation
# การสร้าง Hybrid Certificates

## 🎯 Understanding Certificate Types

For hybrid TLS, we need certificates that support:
1. **Classical algorithms** (for compatibility)
2. **PQC algorithms** (for quantum resistance)

### Certificate Strategy Options

**Option 1: Dual Certificates (Recommended)**
```
Serve two separate certificates:
- ECDSA P-256 certificate (classical)
- ML-DSA-65 certificate (PQC)
Client negotiates which to use
```

**Option 2: Composite Certificate**
```
Single certificate with both keys:
- Larger size (~8KB)
- Not widely supported yet
- Future standard (draft-ietf-lamps-pq-composite-certs)
```

**Option 3: Pure PQC Certificate**
```
ML-DSA-65 only:
- Quantum-resistant
- No classical fallback
- Not compatible with older clients
```

We'll implement **Option 1: Dual Certificates** ✅

---

## 🔐 Part 1: Classical Certificate (ECDSA)

### Generate ECDSA Key and Certificate

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup/certs-hybrid

# Generate ECDSA P-256 private key
openssl ecparam -name prime256v1 -genkey -out hybrid-ecdsa.key

# Create certificate signing request (CSR)
openssl req -new \
    -key hybrid-ecdsa.key \
    -out hybrid-ecdsa.csr \
    -subj "/C=TH/ST=Bangkok/L=Bangkok/O=PQC Lab/OU=Security/CN=pqc-lab.local"

# Generate self-signed certificate (valid 365 days)
openssl x509 -req \
    -in hybrid-ecdsa.csr \
    -signkey hybrid-ecdsa.key \
    -out hybrid-ecdsa.crt \
    -days 365 \
    -sha256

# Inspect certificate
openssl x509 -in hybrid-ecdsa.crt -text -noout
```

### Certificate Details

```bash
# Check key size
openssl ec -in hybrid-ecdsa.key -text -noout

# Expected:
# Private-Key: (256 bit)
# ASN1 OID: prime256v1
# NIST CURVE: P-256

# Check certificate size
ls -lh hybrid-ecdsa.crt
# Expected: ~1.2 KB
```

---

## 🧊 Part 2: PQC Certificate (ML-DSA)

### Generate ML-DSA-65 Key and Certificate

```bash
# Generate ML-DSA-65 private key
openssl genpkey -algorithm mldsa65 -out hybrid-mldsa.key

# Create CSR with PQC key
openssl req -new \
    -key hybrid-mldsa.key \
    -out hybrid-mldsa.csr \
    -subj "/C=TH/ST=Bangkok/L=Bangkok/O=PQC Lab/OU=Security/CN=pqc-lab.local"

# Generate self-signed PQC certificate
openssl x509 -req \
    -in hybrid-mldsa.csr \
    -signkey hybrid-mldsa.key \
    -out hybrid-mldsa.crt \
    -days 365

# Inspect certificate
openssl x509 -in hybrid-mldsa.crt -text -noout
```

### Certificate Details

```bash
# Check key details
openssl pkey -in hybrid-mldsa.key -text -noout

# Expected:
# MLDSA65 Private-Key

# Check certificate size
ls -lh hybrid-mldsa.crt
# Expected: ~4-5 KB (much larger!)

# Compare sizes
ls -lh hybrid-*.crt
```

---

## 📦 Part 3: Certificate Chain

### Create Combined Chain File

For some servers (like NGINX), we can serve both certificates:

```bash
# Create certificate chain
cat hybrid-ecdsa.crt hybrid-mldsa.crt > hybrid-chain.pem

# Verify chain
openssl crl2pkcs7 -nocrl -certfile hybrid-chain.pem | openssl pkcs7 -print_certs -noout
```

### Alternative: Separate Certificate Files

```bash
# NGINX can use multiple ssl_certificate directives
# We'll configure this in the next guide
```

---

## 🔧 Part 4: Using the Generation Script

We provide a script to automate certificate generation.

### Script Usage

```bash
cd ~/pqcv2/labs/03-pqc-hybrid-setup

# Default: ECDSA + ML-DSA-65
./scripts/generate-hybrid-cert.sh

# Specify type
./scripts/generate-hybrid-cert.sh --type ecdsa-mldsa
./scripts/generate-hybrid-cert.sh --type rsa-mldsa
./scripts/generate-hybrid-cert.sh --type pure-mldsa

# Custom options
./scripts/generate-hybrid-cert.sh \
    --type ecdsa-mldsa \
    --domain "myserver.local" \
    --days 365 \
    --output-dir certs-hybrid
```

### What the Script Does

```bash
#!/bin/bash
# Simplified version

TYPE=${1:-ecdsa-mldsa}
DOMAIN=${2:-pqc-lab.local}
DAYS=${3:-365}

case $TYPE in
  ecdsa-mldsa)
    # Generate ECDSA certificate
    openssl ecparam -name prime256v1 -genkey -out ecdsa.key
    openssl req -new -x509 -key ecdsa.key -out ecdsa.crt -days $DAYS -subj "/CN=$DOMAIN"
    
    # Generate ML-DSA certificate
    openssl genpkey -algorithm mldsa65 -out mldsa.key
    openssl req -new -x509 -key mldsa.key -out mldsa.crt -days $DAYS -subj "/CN=$DOMAIN"
    ;;
  
  rsa-mldsa)
    # Generate RSA certificate
    openssl genrsa -out rsa.key 2048
    openssl req -new -x509 -key rsa.key -out rsa.crt -days $DAYS -subj "/CN=$DOMAIN"
    
    # Generate ML-DSA certificate
    openssl genpkey -algorithm mldsa65 -out mldsa.key
    openssl req -new -x509 -key mldsa.key -out mldsa.crt -days $DAYS -subj "/CN=$DOMAIN"
    ;;
    
  pure-mldsa)
    # Generate ML-DSA only
    openssl genpkey -algorithm mldsa65 -out mldsa.key
    openssl req -new -x509 -key mldsa.key -out mldsa.crt -days $DAYS -subj "/CN=$DOMAIN"
    ;;
esac
```

---

## 📊 Certificate Comparison

### Size Comparison

```bash
# Check all certificate sizes
ls -lh certs-hybrid/*.crt

# Expected:
# hybrid-ecdsa.crt   : ~1.2 KB
# hybrid-mldsa.crt   : ~4.5 KB
# hybrid-chain.pem   : ~5.7 KB
```

### Generated Files

```
certs-hybrid/
├── hybrid-ecdsa.key      (ECDSA P-256 private key, 256 bits)
├── hybrid-ecdsa.csr      (Certificate signing request)
├── hybrid-ecdsa.crt      (ECDSA certificate, ~1.2 KB)
│
├── hybrid-mldsa.key      (ML-DSA-65 private key, ~4000 bytes)
├── hybrid-mldsa.csr      (Certificate signing request)
├── hybrid-mldsa.crt      (ML-DSA-65 certificate, ~4.5 KB)
│
└── hybrid-chain.pem      (Combined certificate chain, ~5.7 KB)
```

---

## 🔍 Inspecting Certificates

### View Certificate Details

```bash
# ECDSA certificate
openssl x509 -in hybrid-ecdsa.crt -text -noout | less

# Look for:
# Signature Algorithm: ecdsa-with-SHA256
# Public Key Algorithm: id-ecPublicKey
# Public-Key: (256 bit)
# ASN1 OID: prime256v1
```

```bash
# ML-DSA certificate
openssl x509 -in hybrid-mldsa.crt -text -noout | less

# Look for:
# Signature Algorithm: mldsa65
# Public Key Algorithm: mldsa65
# (Much larger key data)
```

### Verify Certificate Validity

```bash
# Check dates
openssl x509 -in hybrid-ecdsa.crt -noout -dates
openssl x509 -in hybrid-mldsa.crt -noout -dates

# Check subject
openssl x509 -in hybrid-ecdsa.crt -noout -subject
openssl x509 -in hybrid-mldsa.crt -noout -subject

# Verify self-signed
openssl verify -CAfile hybrid-ecdsa.crt hybrid-ecdsa.crt
openssl verify -CAfile hybrid-mldsa.crt hybrid-mldsa.crt
```

---

## 🎓 Advanced: Certificate Authority Setup

For production, you'd use a proper CA hierarchy:

```bash
# 1. Create Root CA (ML-DSA)
openssl genpkey -algorithm mldsa87 -out root-ca.key
openssl req -new -x509 -key root-ca.key -out root-ca.crt -days 3650 \
    -subj "/CN=PQC Root CA"

# 2. Create Intermediate CA (ML-DSA)
openssl genpkey -algorithm mldsa65 -out intermediate-ca.key
openssl req -new -key intermediate-ca.key -out intermediate-ca.csr \
    -subj "/CN=PQC Intermediate CA"
openssl x509 -req -in intermediate-ca.csr -CA root-ca.crt -CAkey root-ca.key \
    -out intermediate-ca.crt -days 1825 -CAcreateserial

# 3. Create Server Certificate (ML-DSA)
openssl genpkey -algorithm mldsa65 -out server.key
openssl req -new -key server.key -out server.csr \
    -subj "/CN=pqc-server.local"
openssl x509 -req -in server.csr -CA intermediate-ca.crt -CAkey intermediate-ca.key \
    -out server.crt -days 365 -CAcreateserial

# 4. Create full chain
cat server.crt intermediate-ca.crt root-ca.crt > full-chain.pem
```

---

## 🐛 Troubleshooting

### Issue: "unknown signature algorithm mldsa65"

```bash
# Check if oqs-provider is loaded
openssl list -providers | grep oqs

# If missing, set environment
export LD_LIBRARY_PATH=/path/to/openssl-oqs/lib:$LD_LIBRARY_PATH
```

### Issue: Certificate size too large

```bash
# Use smaller PQC algorithm
openssl genpkey -algorithm mldsa44 -out smaller.key

# Or use pure ECDSA (not quantum-resistant)
openssl ecparam -name prime256v1 -genkey -out classical.key
```

### Issue: Browser doesn't trust certificate

```bash
# For testing, use self-signed
# For production, get certificate from CA

# Chrome: chrome://settings/certificates
# Firefox: about:preferences#privacy → View Certificates

# Or use curl with -k flag
curl -k https://localhost:8443
```

---

## 📋 Verification Checklist

- [ ] Generated ECDSA private key (256 bits)
- [ ] Generated ECDSA certificate (~1.2 KB)
- [ ] Generated ML-DSA-65 private key (~4000 bytes)
- [ ] Generated ML-DSA-65 certificate (~4.5 KB)
- [ ] Created certificate chain file
- [ ] Inspected both certificates
- [ ] Verified certificate validity
- [ ] Checked certificate sizes
- [ ] Certificates in `certs-hybrid/` directory
- [ ] Script runs without errors

---

## 🎯 Key Takeaways

1. **Dual certificates** provide classical + PQC support
2. **ECDSA P-256** for compatibility (~1.2 KB)
3. **ML-DSA-65** for quantum resistance (~4.5 KB)
4. **PQC certificates are 3-5x larger** than classical
5. **Self-signed OK for testing**, use CA for production
6. **Certificate chain** combines both for flexibility
7. **Generation script** automates the process

---

**Next:** [05-nginx-configuration.md](05-nginx-configuration.md) - Configure NGINX to use hybrid certificates
