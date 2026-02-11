# OpenSSL Command Reference
# คู่มือคำสั่ง OpenSSL

Essential OpenSSL commands for TLS analysis and certificate inspection.

---

## 🔌 TLS Connection Testing

### Basic Connection

```bash
# Simple connection test
openssl s_client -connect localhost:443

# Brief output (easier to read)
openssl s_client -connect localhost:443 -brief

# Quiet mode (only show errors)
openssl s_client -connect localhost:443 -quiet
```

**What you'll see:**
```
CONNECTED(00000003)
depth=0 C = TH, ST = Bangkok, L = Bangkok, O = PQC Lab Corporation, OU = IT Security, CN = localhost
verify error:num=18:self signed certificate
verify return:1
Protocol  : TLSv1.2
Cipher    : ECDHE-RSA-AES256-GCM-SHA384
```

---

### Specify TLS Version

```bash
# Force TLS 1.2
openssl s_client -connect localhost:443 -tls1_2

# Force TLS 1.3
openssl s_client -connect localhost:443 -tls1_3

# Try specific cipher
openssl s_client -connect localhost:443 -cipher "ECDHE-RSA-AES256-GCM-SHA384"
```

---

### Show Certificate Chain

```bash
# Show all certificates in chain
openssl s_client -connect localhost:443 -showcerts

# Save certificate to file
openssl s_client -connect localhost:443 -showcerts 2>/dev/null </dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > server-cert.pem
```

---

## 🔍 Certificate Inspection

### View Certificate Details

```bash
# From file
openssl x509 -in cert.pem -text -noout

# From server (directly)
echo | openssl s_client -connect localhost:443 2>/dev/null | \
  openssl x509 -text -noout
```

**Key sections to look for:**
```
Subject: CN = localhost, O = PQC Lab Corporation
Issuer: CN = localhost, O = PQC Lab Corporation
Validity
    Not Before: Jan  1 00:00:00 2024 GMT
    Not After : Dec 31 23:59:59 2025 GMT
Public Key Algorithm: rsaEncryption
    Public-Key: (2048 bit)
Signature Algorithm: sha256WithRSAEncryption
```

---

### Extract Specific Fields

```bash
# Subject
openssl x509 -in cert.pem -noout -subject

# Issuer
openssl x509 -in cert.pem -noout -issuer

# Dates
openssl x509 -in cert.pem -noout -dates

# Serial number
openssl x509 -in cert.pem -noout -serial

# Fingerprint
openssl x509 -in cert.pem -noout -fingerprint

# Public key
openssl x509 -in cert.pem -noout -pubkey
```

---

### Check Certificate Validity

```bash
# Verify certificate against CA
openssl verify -CAfile ca-cert.pem server-cert.pem

# Check expiration
openssl x509 -in cert.pem -noout -enddate

# Check if expired (exit code 0 = valid, 1 = expired)
openssl x509 -in cert.pem -noout -checkend 0
```

---

## 🔐 Certificate Analysis

### Decode Certificate

```bash
# Human-readable format
openssl x509 -in cert.pem -text

# Modulus (for key matching)
openssl x509 -in cert.pem -noout -modulus

# Compare certificate and key match
CERT_MODULUS=$(openssl x509 -in cert.pem -noout -modulus | md5sum)
KEY_MODULUS=$(openssl rsa -in key.pem -noout -modulus | md5sum)
if [ "$CERT_MODULUS" == "$KEY_MODULUS" ]; then
    echo "Certificate and key match!"
fi
```

---

### Certificate Alternative Names (SAN)

```bash
# Extract SANs
openssl x509 -in cert.pem -noout -ext subjectAltName

# Example output:
# X509v3 Subject Alternative Name:
#     DNS:localhost, DNS:*.localhost, IP:127.0.0.1
```

---

## 🔑 Private Key Operations

### View Private Key

```bash
# View RSA private key
openssl rsa -in key.pem -text -noout

# View ECDSA private key
openssl ec -in key.pem -text -noout

# Check if key is encrypted
openssl rsa -in key.pem -check -noout
```

---

### Convert Key Formats

```bash
# PEM to DER
openssl rsa -in key.pem -outform DER -out key.der

# DER to PEM
openssl rsa -in key.der -inform DER -out key.pem

# Remove passphrase from key
openssl rsa -in encrypted-key.pem -out unencrypted-key.pem
```

---

## 🔬 Cipher Suite Testing

### List Available Ciphers

```bash
# All supported ciphers
openssl ciphers -v

# Filter by protocol
openssl ciphers -v 'TLSv1.2'

# Filter by key exchange
openssl ciphers -v 'ECDHE'

# High security only
openssl ciphers -v 'HIGH:!aNULL:!MD5'
```

---

### Test Specific Cipher

```bash
# Test if server supports a cipher
openssl s_client -connect localhost:443 -cipher "ECDHE-RSA-AES256-GCM-SHA384" < /dev/null

# Exit code 0 = supported, non-zero = not supported

# Test multiple ciphers
for cipher in $(openssl ciphers 'ECDHE' | tr ':' ' '); do
    echo -n "Testing $cipher... "
    if openssl s_client -connect localhost:443 -cipher "$cipher" </dev/null 2>/dev/null | grep -q "Cipher is"; then
        echo "✓ Supported"
    else
        echo "✗ Not supported"
    fi
done
```

---

## ⏱️ Performance Testing

### TLS Handshake Timing

```bash
# Time multiple connections
openssl s_time -connect localhost:443 -new -time 30

# Example output:
# 1234 connections in 30.00s; 41.13 connections/sec
# 12345678 bytes read from SSL
```

---

### Measure Handshake Steps

```bash
# Detailed timing with curl
curl -k -o /dev/null -s -w "\
DNS Lookup:      %{time_namelookup}s\n\
TCP Connect:     %{time_connect}s\n\
TLS Handshake:   %{time_appconnect}s\n\
Total Time:      %{time_total}s\n" https://localhost
```

---

## 🧪 Advanced Features

### Session Resumption

```bash
# Test session resumption
openssl s_client -connect localhost:443 -reconnect

# Save session for reuse
openssl s_client -connect localhost:443 -sess_out session.pem

# Resume saved session
openssl s_client -connect localhost:443 -sess_in session.pem
```

---

### OCSP Stapling

```bash
# Check if server supports OCSP stapling
openssl s_client -connect localhost:443 -status

# Look for:
# OCSP response:
# ======================================
# OCSP Response Status: successful (0x0)
```

---

### Protocol Negotiation

```bash
# See negotiated protocol (HTTP/1.1 vs HTTP/2)
openssl s_client -connect localhost:443 -alpn h2,http/1.1

# Shows: ALPN protocol: h2
```

---

## 📊 Parsing Output

### Extract Cipher Info

```bash
# Get cipher suite only
echo | openssl s_client -connect localhost:443 2>/dev/null | \
  grep "Cipher" | head -1
```

### Extract Certificate Expiry

```bash
# Get expiration date
echo | openssl s_client -connect localhost:443 2>/dev/null | \
  openssl x509 -noout -enddate
```

### Extract Key Size

```bash
# Get public key size
echo | openssl s_client -connect localhost:443 2>/dev/null | \
  openssl x509 -noout -text | \
  grep "Public-Key" | \
  grep -oP '\d+'
```

---

## 🛠️ Common Troubleshooting

### Issue: "unable to get local issuer certificate"

```bash
# Use -CAfile to specify CA
openssl s_client -connect localhost:443 -CAfile ca-cert.pem

# Or disable verification (testing only!)
openssl s_client -connect localhost:443 -verify_return_error
```

---

### Issue: "sslv3 alert handshake failure"

```bash
# Check supported protocols
openssl s_client -connect localhost:443 -tls1
openssl s_client -connect localhost:443 -tls1_1
openssl s_client -connect localhost:443 -tls1_2
openssl s_client -connect localhost:443 -tls1_3
```

---

### Issue: Connection timeout

```bash
# Increase timeout
timeout 10 openssl s_client -connect localhost:443

# Try with IPv4 explicitly
openssl s_client -connect 127.0.0.1:443 -4
```

---

## 📝 Useful One-Liners

```bash
# Quick certificate check
echo | openssl s_client -connect localhost:443 2>/dev/null | \
  openssl x509 -noout -subject -issuer -dates

# List all supported ciphers by server
nmap --script ssl-enum-ciphers -p 443 localhost

# Check weak ciphers
openssl s_client -connect localhost:443 -cipher 'DES-CBC3-SHA' </dev/null 2>&1 | \
  grep -q "Cipher is" && echo "Weak cipher supported!" || echo "Weak cipher blocked"

# Compare certificate fingerprints
diff <(openssl x509 -in cert1.pem -noout -fingerprint) \
     <(openssl x509 -in cert2.pem -noout -fingerprint)

# Find certificate chain issues
openssl s_client -connect localhost:443 -showcerts 2>/dev/null | \
  grep "verify error"
```

---

## 🎯 Lab Exercises

Practice these commands on Lab 00's target application:

1. ✅ Connect and view certificate
2. ✅ Extract subject and issuer
3. ✅ Check certificate expiration
4. ✅ Identify signature algorithm
5. ✅ Test different TLS versions
6. ✅ List supported cipher suites
7. ✅ Measure handshake time

---

<div align="center">

[← Back to Quantum Threat](02-quantum-threat.md) | [← Back to Lab 01](../README.md)

</div>
