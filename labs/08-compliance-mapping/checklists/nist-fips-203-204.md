# NIST FIPS 203 & 204 Compliance Checklist
# รายการตรวจสอบการปฏิบัติตามมาตรฐาน NIST FIPS 203 & 204

**Lab:** 08-Compliance Mapping [BONUS]  
**Standard:** FIPS 203 (ML-KEM), FIPS 204 (ML-DSA)  
**Date:** _________________________

---

## 📖 Overview

This checklist helps verify compliance with NIST's newly standardized post-quantum cryptographic algorithms:
- **FIPS 203:** Module-Lattice-Based Key-Encapsulation Mechanism (ML-KEM)
- **FIPS 204:** Module-Lattice-Based Digital Signature Algorithm (ML-DSA)

Published: August 2024

---

## 🔐 FIPS 203: ML-KEM Compliance

### Algorithm Selection

| Requirement | Implementation | Compliant? | Notes |
|-------------|----------------|------------|-------|
| **Uses NIST-approved KEM** | ML-KEM-768 | [x] Yes [ ] No | Security Level 3 (192-bit) |
| **Correct parameter set** | 768 (not 512 or 1024) | [x] Yes [ ] No | Balances security & performance |
| **Security level documented** | Level 3 (meets CNSA 2.0) | [x] Yes [ ] No | Equivalent to AES-192 |

**Parameter Sets:**
- ML-KEM-512: Security level 1 (128-bit) - Not used
- **ML-KEM-768: Security level 3 (192-bit)** ← Our choice
- ML-KEM-1024: Security level 5 (256-bit) - Overkill for most use cases

### Implementation Requirements

| Requirement | Status | Implementation | Evidence |
|-------------|--------|----------------|----------|
| **Proper key generation** | [x] Compliant | Uses liboqs 0.10.0+ | `openssl list -kem-algorithms` |
| **Secure encapsulation** | [x] Compliant | Follows FIPS 203 spec | Code review needed |
| **Secure decapsulation** | [x] Compliant | Constant-time implementation | Timing analysis recommended |
| **Shared secret derivation** | [x] Compliant | KDF per specification | Verified in tests |
| **Random number generation** | [x] Compliant | Uses FIPS 140-3 RNG | System entropy source |

### Key Sizes (ML-KEM-768)

| Key Component | Size (bytes) | Verification |
|---------------|--------------|--------------|
| Public key | 1,184 | `openssl pkey -pubin -in pub.pem -text` |
| Private key | 2,400 | Secure storage verified |
| Ciphertext | 1,088 | TLS handshake capture |
| Shared secret | 32 | Standard output size |

**Verification command:**
```bash
openssl list -kem-algorithms | grep MLKEM768
# Expected: mlkem768
```

**Your output:**
```
___________________________________________________________________
```

### Hybrid Approach (Transitional)

| Requirement | Status | Implementation | Justification |
|-------------|--------|----------------|---------------|
| **Classical KEM included** | [x] Yes | X25519 | NIST recommendation during transition |
| **Combiner function** | [x] Implemented | KDF with both secrets | Security if either algorithm secure |
| **Backward compatibility** | [x] Yes | Falls back to X25519 | Older clients supported |

**Hybrid KEM Formula:**
```
Shared_Secret_Final = KDF(Shared_Secret_Classical || Shared_Secret_PQC)
                    = KDF(X25519_Secret || MLKEM768_Secret)
```

---

## 🖊️ FIPS 204: ML-DSA Compliance

### Algorithm Selection

| Requirement | Implementation | Compliant? | Notes |
|-------------|----------------|------------|-------|
| **Uses NIST-approved signature** | ML-DSA-65 | [x] Yes [ ] No | Security Level 3 |
| **Correct parameter set** | 65 (not 44 or 87) | [x] Yes [ ] No | Balances sig size & speed |
| **Security level matches KEM** | Level 3 = Level 3 | [x] Yes [ ] No | Consistent security |

**Parameter Sets:**
- ML-DSA-44: Security level 2 (128-bit, smallest signature)
- **ML-DSA-65: Security level 3 (192-bit)** ← Our choice
- ML-DSA-87: Security level 5 (256-bit, largest signature)

### Implementation Requirements

| Requirement | Status | Implementation | Evidence |
|-------------|--------|----------------|----------|
| **Proper key generation** | [x] Compliant | Uses liboqs | `openssl genpkey -algorithm MLDSA65` |
| **Secure signing** | [x] Compliant | Randomized signing | Follows FIPS 204 |
| **Secure verification** | [x] Compliant | Public key validation | Certificate chain verified |
| **Side-channel protection** | [ ] Partial | Timing attacks mitigated | Hardware audit recommended |
| **Signature encoding** | [x] Compliant | DER/PEM format | OpenSSL compatible |

### Signature Sizes (ML-DSA-65)

| Component | Size (bytes) | Comparison |
|-----------|--------------|------------|
| Public key | 1,952 | vs RSA-2048: 294 bytes (6.6x larger) |
| Private key | 4,032 | vs RSA-2048: 1,704 bytes (2.4x larger) |
| Signature | 3,309 | vs RSA-2048: 256 bytes (13x larger) |

**Certificate size comparison:**
```bash
# Classical RSA-2048 certificate
ls -lh certs/classical-cert.pem
# Size: ~1.2 KB

# PQC ML-DSA-65 certificate  
ls -lh certs-hybrid/hybrid-cert.pem
# Size: ~5.5 KB (+358%)
```

**Your measurements:**
- Classical cert size: _______ KB
- PQC cert size: _______ KB
- Increase: _______%

### Hybrid Signature Approach

| Requirement | Status | Implementation | Notes |
|-------------|--------|----------------|-------|
| **Classical signature included** | [x] Yes | ECDSA P-256 | For backward compatibility |
| **Both signatures verified** | [x] Yes | Dual verification | Secure if either valid |
| **Certificate chain** | [x] Valid | CA signs with ML-DSA | End-to-end PQC |

---

## 📋 NIST Migration Guidelines Compliance

### Timeline Adherence (CNSA 2.0)

| Milestone | Deadline | Status | Evidence |
|-----------|----------|--------|----------|
| **Algorithm standardization** | 2024 | [x] Complete | FIPS 203/204 published Aug 2024 |
| **Vendor implementations** | 2024-2025 | [x] In Progress | OpenSSL 3.2+, liboqs 0.10+ |
| **Pilot deployments** | 2025 | [x] This lab! | Hybrid TLS/VPN implementations |
| **NSS compliance** | 2030 | [ ] Planned | Government systems deadline |
| **Full migration** | 2035 | [ ] Planned | All federal systems |

**Your organization's timeline:**
- Current status: _____________________
- Pilot start date: _____________________
- Production target: _____________________

### Cryptographic Agility

| Requirement | Status | Implementation | Notes |
|-------------|--------|----------------|-------|
| **Algorithm negotiation** | [x] Yes | TLS 1.3 | Client-server negotiate algorithms |
| **Easy algorithm swap** | [x] Yes | Config-driven | Change in ipsec.conf/nginx.conf |
| **Multiple algorithms supported** | [x] Yes | Classical, Hybrid, PQC-only | Flexible deployment |
| **Rollback capability** | [x] Yes | Can revert to classical | Emergency fallback |

**Test algorithm negotiation:**
```bash
# Test with different algorithms
openssl s_client -connect localhost:8443 -curves X25519
openssl s_client -connect localhost:8443 -curves X25519MLKEM768

# Server should support both
```

---

## 🛡️ Security Requirements

### Key Management

| Requirement | Status | Implementation | Verification |
|-------------|--------|----------------|--------------|
| **Secure key generation** | [x] Yes | FIPS 140-3 RNG | `cat /proc/sys/kernel/random/entropy_avail` |
| **Key storage protection** | [x] Yes | Encrypted at rest | File permissions: 0600 |
| **Key rotation policy** | [x] Yes | 90-day rotation | Automated renewal |
| **Private key access control** | [x] Yes | Root-only access | `ls -l /etc/ipsec.d/private/` |
| **Secure key deletion** | [ ] Partial | Overwrite on deletion | Implement `shred` |

### Operational Security

| Requirement | Status | Implementation | Notes |
|-------------|--------|----------------|-------|
| **Algorithm security monitoring** | [ ] Planned | Subscribe to NIST updates | Check CSRC regularly |
| **Incident response plan** | [ ] Partial | Crypto failure procedures | Document crypto rollback |
| **Logging & auditing** | [x] Yes | TLS handshake logs | Monitor for algorithm usage |
| **Performance monitoring** | [x] Yes | Metrics collection | CPU/latency thresholds |

---

## ✅ Compliance Assessment

### FIPS 203 (ML-KEM)

**Checklist:**
- [x] Uses ML-KEM-768 (security level 3)
- [x] Proper key sizes (1,184-byte pubkey)
- [x] Secure implementation (liboqs)
- [x] Hybrid approach (X25519 + ML-KEM)
- [x] Backward compatible
- [ ] FIPS validation certificate (pending)

**Score:** 5/6 = 83% → **Substantially Compliant**

### FIPS 204 (ML-DSA)

**Checklist:**
- [x] Uses ML-DSA-65 (security level 3)
- [x] Proper signature sizes (3,309 bytes)
- [x] Secure implementation (liboqs)
- [x] Hybrid approach (ECDSA + ML-DSA)
- [x] Certificate chain validation
- [ ] Side-channel protection audit

**Score:** 5/6 = 83% → **Substantially Compliant**

### NIST Migration Guidelines

**Checklist:**
- [x] Started migration before 2025
- [x] Hybrid approach adopted
- [x] Cryptographic agility implemented
- [x] Performance testing conducted
- [ ] Formal migration plan documented
- [ ] Compliance deadline tracking

**Score:** 4/6 = 67% → **Partially Compliant**

---

## 📝 Recommendations

### Immediate Actions

1. **Document migration plan**
   - Formalize timeline
   - Assign responsibilities
   - Define success criteria

2. **Conduct side-channel analysis**
   - Timing attack testing
   - Power analysis (if hardware-dependent)
   - Cache timing evaluation

3. **Obtain FIPS validation**
   - Submit liboqs implementation for validation
   - Track validation status
   - Update documentation with certificate number

### Medium-Term Goals

4. **Implement comprehensive monitoring**
   - Algorithm usage metrics
   - Performance baselines
   - Anomaly detection

5. **Staff training**
   - PQC fundamentals
   - Operational procedures
   - Incident response

6. **Vendor coordination**
   - Track OpenSSL PQC roadmap
   - Evaluate commercial PQC solutions
   - Plan for hardware acceleration

---

## 🔗 References

- [NIST FIPS 203 (ML-KEM)](https://csrc.nist.gov/pubs/fips/203/final)
- [NIST FIPS 204 (ML-DSA)](https://csrc.nist.gov/pubs/fips/204/final)
- [NIST Post-Quantum Cryptography Standardization](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [CNSA 2.0 Guidance](https://media.defense.gov/2022/Sep/07/2003071834/-1/-1/0/CSA_CNSA_2.0_ALGORITHMS_.PDF)
- [Open Quantum Safe (liboqs)](https://openquantumsafe.org/)

---

<div align="center">

**Next:** [ISO 27001 Mapping →](iso27001-mapping.md)

[← Back to Lab 08](../README.md)

</div>
