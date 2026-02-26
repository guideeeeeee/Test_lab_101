# PQC Algorithm Comparison Worksheet
# แบบฟอร์มเปรียบเทียบอัลกอริทึม PQC

## 🎯 Objective

Test and compare different post-quantum cryptography algorithms to understand their performance characteristics and compatibility.

---

## 📋 Test Setup

**Date:** _______________  
**Tester:** _______________  
**Server:** pqc-lab.local  
**Port:** 8443  

**Test Environment:**
- OS: _______________
- CPU: _______________
- RAM: _______________
- OpenSSL Version: _______________
- NGINX Version: _______________

---

## 🔑 Part 1: Key Exchange Algorithms (KEMs)

### Test Command Template

> ⚠️ ต้องรันผ่าน `docker exec` — host openssl ไม่รองรับ PQC signature

```bash
docker exec pqc-hybrid-nginx sh -c '
OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
time /opt/openssl/bin/openssl s_client \
  -connect localhost:443 \
  -groups [ALGORITHM] \
  -brief </dev/null 2>&1'
```

### Results Table

| Algorithm | Type | Handshake Time (ms) | Success? | Certificate Size | Notes |
|-----------|------|---------------------|----------|------------------|-------|
| **Classical** |
| X25519 | ECDH | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| P-256 | ECDH | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| P-384 | ECDH | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| **Hybrid (X25519 + ML-KEM)** |
| x25519_kyber512 | Hybrid | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| x25519_kyber768 | Hybrid | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| x25519_kyber1024 | Hybrid | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| **Hybrid (P-256 + ML-KEM)** |
| p256_kyber768 | Hybrid | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| p384_kyber1024 | Hybrid | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| **Pure PQC** |
| kyber512 | PQC | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| kyber768 | PQC | _______ | ☐ Yes ☐ No | _______ KB | __________ |
| kyber1024 | PQC | _______ | ☐ Yes ☐ No | _______ KB | __________ |

### Observations

**Fastest algorithm:** _______________  
**Slowest algorithm:** _______________  
**Recommended for production:** _______________  

**Performance overhead of hybrid vs classical:**  
Classical average: _______ ms  
Hybrid average: _______ ms  
Overhead: _______% increase  

---

## ✍️ Part 2: Signature Algorithms

### Test Command Template

```bash
docker exec pqc-hybrid-nginx sh -c '
OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
/opt/openssl/bin/openssl s_client -connect localhost:443 -showcerts </dev/null 2>/dev/null' | grep "Signature Algorithm"
```

### Certificate Information

| Certificate Type | Algorithm | Public Key Size | Signature Size | Total Cert Size | Success? |
|------------------|-----------|-----------------|----------------|-----------------|----------|
| Classical ECDSA | ecdsa_secp256r1 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| Classical RSA | rsa_pss_rsae_sha256 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| PQC ML-DSA-44 | mldsa44 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| PQC ML-DSA-65 | mldsa65 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| PQC ML-DSA-87 | mldsa87 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| PQC Falcon-512 | falcon512 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |
| PQC Falcon-1024 | falcon1024 | _____ bytes | _____ bytes | _____ KB | ☐ Yes ☐ No |

### Certificate Size Analysis

```bash
# Check certificate sizes
ls -lh /path/to/certs-hybrid/*.crt
```

**Size comparison:**
- ECDSA P-256: _______ KB (baseline)
- RSA-2048: _______ KB (_____x baseline)
- ML-DSA-65: _______ KB (_____x baseline)
- ML-DSA-87: _______ KB (_____x baseline)

---

## 📊 Part 3: Cipher Suite Performance

### Test Command

```bash
docker exec pqc-hybrid-nginx sh -c '
OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
/opt/openssl/bin/openssl s_client -connect localhost:443 -cipher [CIPHER_SUITE] -brief </dev/null 2>&1'
```

### Results

| Cipher Suite | Handshake Time | Throughput (MB/s) | CPU Usage (%) | Success? |
|--------------|----------------|-------------------|---------------|----------|
| TLS_AES_128_GCM_SHA256 | _______ ms | _______ | _____% | ☐ Yes ☐ No |
| TLS_AES_256_GCM_SHA384 | _______ ms | _______ | _____% | ☐ Yes ☐ No |
| TLS_CHACHA20_POLY1305_SHA256 | _______ ms | _______ | _____% | ☐ Yes ☐ No |

**Notes:**
- All TLS 1.3 cipher suites use quantum-resistant symmetric crypto (AES, ChaCha20)
- Performance differences mainly due to key size and CPU instructions (AES-NI)

---

## 🧪 Part 4: Compatibility Testing

### Browser Testing

| Browser | Version | Classical TLS | Hybrid TLS | Pure PQC | Notes |
|---------|---------|---------------|------------|----------|-------|
| Chrome | _______ | ☐ Yes ☐ No | ☐ Yes ☐ No | ☐ Yes ☐ No | __________ |
| Firefox | _______ | ☐ Yes ☐ No | ☐ Yes ☐ No | ☐ Yes ☐ No | __________ |
| Edge | _______ | ☐ Yes ☐ No | ☐ Yes ☐ No | ☐ Yes ☐ No | __________ |
| Safari | _______ | ☐ Yes ☐ No | ☐ Yes ☐ No | ☐ Yes ☐ No | __________ |

### Client Tool Testing

| Tool | Version | Hybrid Support | Notes |
|------|---------|----------------|-------|
| curl | _______ | ☐ Yes ☐ No | __________ |
| wget | _______ | ☐ Yes ☐ No | __________ |
| Python requests | _______ | ☐ Yes ☐ No | __________ |
| OpenSSL s_client | _______ | ☐ Yes ☐ No | __________ |

---

## 📈 Part 5: Performance Benchmarking

### Handshake Performance

```bash
# Test 100 handshakes (รันภายใน container)
for i in {1..100}; do
  docker exec pqc-hybrid-nginx sh -c '
  OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
  LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
  time /opt/openssl/bin/openssl s_client -connect localhost:443 -groups [ALGORITHM] -brief </dev/null 2>&1'
done 2>&1 | grep real | awk '{sum+=$2; count++} END {print sum/count}'
```

| Algorithm | Avg Time (100 runs) | Min Time | Max Time | Std Dev |
|-----------|---------------------|----------|----------|---------|
| X25519 | _______ ms | _____ ms | _____ ms | _____ |
| x25519_kyber768 | _______ ms | _____ ms | _____ ms | _____ |
| kyber768 | _______ ms | _____ ms | _____ ms | _____ |

### Throughput Testing

```bash
# Test with ab (Apache Bench)
ab -n 1000 -c 10 https://localhost:8443/
```

| Configuration | Requests/sec | Time per request (ms) | Transfer rate (KB/s) |
|---------------|--------------|------------------------|----------------------|
| Classical only | _______ | _______ | _______ |
| Hybrid | _______ | _______ | _______ |
| Pure PQC | _______ | _______ | _______ |

---

## 🔍 Part 6: Analysis Questions

### 1. Performance Impact

**Q: What is the performance overhead of hybrid vs classical?**

A: ___________________________________________________________________

___________________________________________________________________

### 2. Certificate Size Impact

**Q: How does certificate size affect page load time?**

A: ___________________________________________________________________

___________________________________________________________________

### 3. Algorithm Selection

**Q: Which algorithm combination would you recommend for production and why?**

A: ___________________________________________________________________

___________________________________________________________________

### 4. Compatibility Concerns

**Q: What compatibility issues did you encounter?**

A: ___________________________________________________________________

___________________________________________________________________

### 5. Security vs Performance

**Q: Is the performance cost of PQC acceptable for your use case?**

A: ___________________________________________________________________

___________________________________________________________________

---

## 📊 Summary & Recommendations

### Performance Summary

- **Classical TLS:** _______ ms average handshake
- **Hybrid TLS:** _______ ms average handshake (_____% overhead)
- **Pure PQC:** _______ ms average handshake (_____% overhead)

### Size Summary

- **Classical certificate:** _______ KB
- **Hybrid certificate:** _______ KB (_____x increase)
- **Pure PQC certificate:** _______ KB (_____x increase)

### Recommendation

Based on testing, I recommend:

**Key Exchange:** ☐ X25519 ☐ x25519_kyber768 ☐ kyber768  
**Signature:** ☐ ECDSA ☐ ECDSA+MLDSA ☐ MLDSA  
**Deployment Strategy:** ☐ Classical only ☐ Hybrid ☐ Pure PQC  

**Justification:**

___________________________________________________________________

___________________________________________________________________

___________________________________________________________________

---

## ✅ Completion Checklist

- [ ] Tested all classical algorithms
- [ ] Tested all hybrid algorithms
- [ ] Tested pure PQC algorithms
- [ ] Measured handshake times
- [ ] Checked certificate sizes
- [ ] Tested browser compatibility
- [ ] Ran performance benchmarks
- [ ] Answered analysis questions
- [ ] Made final recommendation

---

**Tester Signature:** _______________  
**Date Completed:** _______________
