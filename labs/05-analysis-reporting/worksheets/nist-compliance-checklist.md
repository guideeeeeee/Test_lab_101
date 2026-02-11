# NIST PQC Compliance Checklist
# รายการตรวจสอบการปฏิบัติตามมาตรฐาน NIST PQC

**Lab:** 05-Analysis & Reporting  
**Organization:** _________________________  
**Auditor:** _________________________  
**Date:** _________________________

---

## 📖 Overview

This checklist helps you assess compliance with NIST post-quantum cryptography standards (FIPS 203, FIPS 204) and migration guidelines.

---

## 🔐 Part 1: Algorithm Compliance

### FIPS 203: Module-Lattice-Based Key-Establishment Mechanism (ML-KEM)

**Standard:** ML-KEM standardized in FIPS 203 (August 2024)

| Requirement | Status | Evidence | Notes |
|-------------|--------|----------|-------|
| **Uses NIST-approved KEM** | [ ] Yes [ ] No [ ] N/A | ML-KEM-768 | _____ |
| **Proper security level** | [ ] Yes [ ] No | Security level 3 (192-bit) | _____ |
| **Correct parameter set** | [ ] Yes [ ] No | 768 (not 512 or 1024) | _____ |
| **Proper key generation** | [ ] Yes [ ] No | Uses approved RNG | _____ |
| **Secure encapsulation** | [ ] Yes [ ] No | Follows FIPS 203 spec | _____ |
| **Secure decapsulation** | [ ] Yes [ ] No | Constant-time implementation | _____ |

**ML-KEM Verification:**
```bash
# Check OpenSSL supports ML-KEM
openssl list -kem-algorithms | grep MLKEM

# Expected output: MLKEM512, MLKEM768, MLKEM1024
```

**Your output:**
```
___________________________________________________________________
```

---

### FIPS 204: Module-Lattice-Based Digital Signature Algorithm (ML-DSA)

**Standard:** ML-DSA standardized in FIPS 204 (August 2024)

| Requirement | Status | Evidence | Notes |
|-------------|--------|----------|-------|
| **Uses NIST-approved signature** | [ ] Yes [ ] No [ ] N/A | ML-DSA-65 | _____ |
| **Proper security level** | [ ] Yes [ ] No | Security level 3 (192-bit) | _____ |
| **Correct parameter set** | [ ] Yes [ ] No | 65 (not 44 or 87) | _____ |
| **Proper signing** | [ ] Yes [ ] No | Follows FIPS 204 spec | _____ |
| **Proper verification** | [ ] Yes [ ] No | Certificate validation OK | _____ |
| **Side-channel protection** | [ ] Yes [ ] No [ ] Unknown | Implementation reviewed | _____ |

**ML-DSA Verification:**
```bash
# Check certificate uses ML-DSA
openssl x509 -in certs-hybrid/server.crt -text -noout | grep "Signature Algorithm"

# Expected: mldsa65 or similar
```

**Your output:**
```
___________________________________________________________________
```

---

### FIPS 186: Transition from Classical Algorithms

| Algorithm | Deprecated? | Replacement | Status |
|-----------|-------------|-------------|--------|
| **RSA-2048** | Post-2030 | ML-DSA or hybrid | [ ] Migrated [ ] Planned |
| **ECDSA P-256** | Post-2030 | ML-DSA or hybrid | [ ] Migrated [ ] Planned |
| **ECDHE P-256** | Post-2030 | ML-KEM or hybrid | [ ] Migrated [ ] Planned |
| **RSA-4096** | Post-2030 | ML-DSA or hybrid | [ ] Migrated [ ] Planned |

---

## 🛡️ Part 2: Hybrid Approach (NIST Recommendation)

**NIST guidance:** Use hybrid constructions during transition period (2024-2035)

| Requirement | Status | Implementation | Notes |
|-------------|--------|----------------|-------|
| **Hybrid KEM** | [ ] Yes [ ] No | X25519 + ML-KEM-768 | _____ |
| **Hybrid Signature** | [ ] Yes [ ] No | ECDSA + ML-DSA-65 | _____ |
| **Fallback to classical** | [ ] Yes [ ] No | Clients without PQC support | _____ |
| **Forward secrecy** | [ ] Yes [ ] No | Ephemeral keys used | _____ |
| **Algorithm negotiation** | [ ] Yes [ ] No | TLS 1.3 algorithm agility | _____ |

**Hybrid Benefits:**
- ✅ Secure if *either* algorithm is secure
- ✅ Backward compatible with classical clients
- ✅ Reduces risk during transition

**Test hybrid negotiation:**
```bash
# Connect with PQC-capable client
openssl s_client -connect localhost:8443 -curves X25519MLKEM768

# Should show: "Server Temp Key: X25519MLKEM768"
```

**Your output:**
```
___________________________________________________________________
```

---

## 📅 Part 3: Timeline Compliance (CNSA 2.0)

**CNSA 2.0 (Commercial National Security Algorithm Suite 2.0)**

| Deadline | Requirement | Status | Notes |
|----------|-------------|--------|-------|
| **2025** | PQC algorithm standardization complete | [x] Done | FIPS 203/204 published Aug 2024 |
| **2030** | NSS systems must support PQC | [ ] Yes [ ] No [ ] In Progress | _____ |
| **2033** | All new NSS systems must use PQC-only | [ ] Yes [ ] No [ ] Planned | _____ |
| **2035** | All NSS systems must use PQC-only | [ ] Yes [ ] No [ ] Planned | _____ |

**Your organization's target:**
- Migration start date: _____________
- PQC pilot phase: _____________
- Full deployment: _____________  
- Legacy system sunset: _____________

---

## 🔑 Part 4: Key Management

| Requirement | Status | Implementation | Notes |
|-------------|--------|----------------|-------|
| **Key generation** | [ ] Compliant [ ] Non-compliant | Uses FIPS 140-3 RNG | _____ |
| **Key sizes** | [ ] Compliant [ ] Non-compliant | ML-KEM-768: 1184 bytes | _____ |
| **Key storage** | [ ] Secure [ ] Insecure | Encrypted at rest | _____ |
| **Key rotation** | [ ] Yes [ ] No | Rotation policy: _____ days | _____ |
| **Certificate validity** | [ ] Compliant [ ] Non-compliant | Max 825 days (CA/B Forum) | _____ |
| **Private key access** | [ ] Restricted [ ] Unrestricted | HSM or secure enclave | _____ |

**Certificate lifespan:**
```bash
# Check certificate validity
openssl x509 -in certs-hybrid/server.crt -noout -dates

# Validity period should be ≤ 825 days
```

**Your certificate:**
```
Not Before: _________________________
Not After:  _________________________
Duration:   _______ days
```

---

## 🏛️ Part 5: Compliance Frameworks

### ISO/IEC 27001: Information Security

| Control | PQC Relevance | Status | Notes |
|---------|---------------|--------|-------|
| **A.5.1.1: Policies** | Crypto policy includes PQC | [ ] Yes [ ] No | _____ |
| **A.8.24: Cryptography** | Use of approved algorithms | [ ] Yes [ ] No | _____ |
| **A.12.3.1: Backups** | Encrypted with PQC-safe crypto | [ ] Yes [ ] No | _____ |
| **A.14.1.2: Secure comms** | TLS uses PQC hybrid | [ ] Yes [ ] No | _____ |

### NIST Cybersecurity Framework

| Function | Category | PQC Implementation | Status |
|----------|----------|-------------------|--------|
| **Identify (ID)** | Asset Management | Inventory of crypto systems | [ ] Done [ ] In Progress |
| **Protect (PR)** | Data Security | PQC encryption deployed | [ ] Done [ ] In Progress |
| **Detect (DE)** | Monitoring | TLS handshake alerts | [ ] Done [ ] In Progress |
| **Respond (RS)** | Incident Response | Crypto failure playbook | [ ] Done [ ] In Progress |
| **Recover (RC)** | Recovery Planning | Algorithm rollback plan | [ ] Done [ ] In Progress |

---

## ⚠️ Part 6: Risk Assessment

### Quantum Threat Analysis

**Threat:** "Harvest Now, Decrypt Later" attack

| Data Classification | Sensitive Lifetime | Quantum Threat Risk | Mitigation |
|---------------------|-------------------|---------------------|------------|
| **Public** | N/A | Low | [ ] None needed |
| **Internal** | 5 years | Medium | [ ] PQC migration planned |
| **Confidential** | 10+ years | **High** | [ ] PQC migration urgent |
| **Top Secret** | 20+ years | **Critical** | [ ] PQC required now |

**Risk calculation:**
```
Risk = Data Sensitivity × Lifetime × Quantum Capability Timeline
```

**Your organization:**
- Highest data classification: ______________
- Data retention period: _______ years
- Quantum threat arrival (est.): _______ year
- **Risk level:** [ ] Low [ ] Medium [ ] High [ ] Critical

---

### Migration Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Performance degradation** | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | _____ |
| **Compatibility issues** | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | _____ |
| **Algorithm breaks (PQC)** | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | Hybrid approach |
| **Implementation bugs** | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | _____ |
| **Staff training needs** | [ ] Low [ ] Med [ ] High | [ ] Low [ ] Med [ ] High | _____ |

---

## 📝 Part 7: Documentation Requirements

| Document | Required For | Status | Location |
|----------|--------------|--------|----------|
| **Crypto Policy** | NSS compliance | [ ] Complete [ ] Draft [ ] Missing | _____ |
| **Migration Plan** | Project management | [ ] Complete [ ] Draft [ ] Missing | _____ |
| **Risk Assessment** | ISO 27001 | [ ] Complete [ ] Draft [ ] Missing | _____ |
| **Performance Report** | Capacity planning | [ ] Complete [ ] Draft [ ] Missing | _____ |
| **Incident Response** | Security ops | [ ] Complete [ ] Draft [ ] Missing | _____ |
| **Training Materials** | Staff readiness | [ ] Complete [ ] Draft [ ] Missing | _____ |

---

## ✅ Part 8: Compliance Score

### Scoring

Count your "Yes" / "Complete" / "Done" responses:

**Algorithm Compliance (Parts 1-2):**
- Total items: 20
- Your score: _____ / 20 = _____% 

**Timeline & Key Management (Parts 3-4):**
- Total items: 13
- Your score: _____ / 13 = _____%

**Framework Compliance (Part 5):**
- Total items: 9
- Your score: _____ / 9 = _____%

**Risk & Documentation (Parts 6-7):**
- Total items: 12
- Your score: _____ / 12 = _____%

### Overall Compliance

```
Total Score = (_____ + _____ + _____ + _____) / 54 = _____%
```

**Interpretation:**
- 90-100%: ✅ **Fully Compliant** - Ready for audit
- 70-89%: ⚠️ **Mostly Compliant** - Minor gaps to address
- 50-69%: ⚠️ **Partially Compliant** - Significant work needed
- <50%: ❌ **Non-Compliant** - Major remediation required

**Your status:** ___________________

---

## 🎯 Action Items

Based on your assessment, list top 3 priorities:

1. **Priority 1 (Critical):**
   - Item: _________________________________________________________
   - Owner: _________________________
   - Deadline: _________________________

2. **Priority 2 (High):**
   - Item: _________________________________________________________
   - Owner: _________________________
   - Deadline: _________________________

3. **Priority 3 (Medium):**
   - Item: _________________________________________________________
   - Owner: _________________________
   - Deadline: _________________________

---

## 📋 Sign-Off

**Reviewed by:**

| Role | Name | Signature | Date |
|------|------|-----------|------|
| **Security Lead** | __________ | __________ | __________ |
| **Compliance Officer** | __________ | __________ | __________ |
| **IT Manager** | __________ | __________ | __________ |

---

<div align="center">

**Next:** [Generate Final Report →](../README.md#part-3-report-generation)

[← Back to Lab 05](../README.md)

</div>
