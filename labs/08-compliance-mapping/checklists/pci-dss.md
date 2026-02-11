# PCI DSS 4.0 Compliance Mapping
# การแมพกับมาตรฐาน PCI DSS 4.0

**Lab:** 08-Compliance Mapping [BONUS]  
**Standard:** PCI DSS v4.0 (Payment Card Industry Data Security Standard)  
**Date:** _________________________

---

## 📖 Overview

PCI DSS 4.0 (effective March 2024) includes new requirements related to cryptographic agility and post-quantum preparedness.

**Key Updates in PCI DSS 4.0:**
- Requirement 4.2.1.1: Cryptographic key management must consider quantum threats
- Requirement 12.3.4: Cryptographic cipher suites and protocols reviewed annually

---

## 🔐 Requirement 4: Protect Cardholder Data with Strong Cryptography

### 4.2.1: Strong Cryptography for Transmission Over Open, Public Networks

| Sub-Requirement | Implementation | Status | Evidence |
|-----------------|----------------|--------|----------|
| **4.2.1.a: TLS 1.2+ required** | TLS 1.3 with PQC | [x] Compliant | `nginx -V` shows TLS 1.3 |
| **4.2.1.b: Strong ciphers only** | AES-256-GCM | [x] Compliant | No weak ciphers in config |
| **4.2.1.c: Valid certificates** | CA-signed ML-DSA certs | [x] Compliant | Certificate chain verified |
| **4.2.1.1: Key management** | 90-day rotation, quantum-safe | [x] Compliant | Automated rotation |

**Test Compliance:**
```bash
# Verify TLS 1.3 with strong ciphers
nmap --script ssl-enum-ciphers -p 8443 localhost

# Expected: Only TLS 1.3 with AES-256-GCM or ChaCha20-Poly1305
```

---

### 4.2.1.1: Cryptographic Keys Protected Against Quantum Threats (NEW in v4.0)

| Requirement | Implementation | Status | Notes |
|-------------|----------------|--------|-------|
| **Quantum threat assessment** | Risk analysis completed | [x] Complete | [RISK-ASSESS-2024.pdf] |
| **PQC migration plan** | Phased rollout 2024-2030 | [x] Complete | [MIGRATION-PLAN.md] |
| **Key algorithm documentation** | ML-KEM-768, ML-DSA-65 | [x] Complete | NIST FIPS 203/204 |
| **Hybrid approach during transition** | Classical + PQC | [x] Implemented | Lab 03-04 |

**PCI DSS 4.0 Guidance:**
> "Entities should have a plan to migrate to quantum-resistant cryptographic algorithms as they become standardized."

**Our Plan:**
```
2024: ✓ Pilot PQC hybrid in test environment (DONE)
2025: Production deployment for high-value transactions
2026: Mandatory PQC for all payment processing
2028: Sunset classical-only connections
```

---

### 4.2.2: PAN Protected with Strong Cryptography During Processing

| Requirement | PQC Impact | Status | Notes |
|-------------|------------|--------|-------|
| **Encryption at rest** | AES-256 (quantum-resistant for data) | [x] Compliant | Database encryption |
| **Key management** | PQC-safe key exchange (ML-KEM) | [x] Compliant | For key distribution |
| **Application-level encryption** | Tokenization + PQC TLS | [x] Compliant | PAN never in plaintext |

---

## 🔑 Requirement 3: Protect Stored Account Data

### 3.5.1: Cryptographic Keys Stored Securely

| Sub-Requirement | Implementation | Status | Evidence |
|-----------------|----------------|--------|----------|
| **3.5.1.a: Key storage location** | Encrypted filesystem, 0600 perms | [x] Compliant | `/etc/ipsec.d/private/` |
| **3.5.1.b: Key access control** | Root-only, MFA for access | [x] Compliant | PAM + sudo logs |
| **3.5.1.c: Key encrypted at rest** | LUKS or HSM | [x] Compliant | `dm-crypt` verification |

**PQC Consideration:**
- PQC private keys are **larger** (2.4 KB vs 294 bytes for RSA-2048)
- Ensure storage capacity sufficient for future PQC key sizes
- HSM firmware may need updates for PQC support

---

## 📋 Requirement 12: Maintain a Policy Addressing Information Security

### 12.3.4: Cryptographic Cipher Suites and Protocols Reviewed Annually (NEW in v4.0)

| Review Item | Current State | Next Review | Status |
|-------------|---------------|-------------|--------|
| **TLS protocol versions** | TLS 1.3 only | March 2025 | [x] Scheduled |
| **Cipher suites** | AES-256-GCM, ChaCha20 | March 2025 | [x] Scheduled |
| **PQC algorithms** | ML-KEM-768, ML-DSA-65 | March 2025 | [x] Scheduled |
| **Quantum threat assessment** | Updated annually | Q4 2024 | [x] Scheduled |

**Annual Review Checklist:**
- [ ] Check NIST for new PQC standards
- [ ] Review quantum computing progress (D-Wave, IBM, Google reports)
- [ ] Update risk assessment
- [ ] Test new liboqs versions
- [ ] Review incident logs for crypto failures
- [ ] Audit key rotation compliance

---

## 🛡️ Requirement 11: Test Security of Systems and Networks Regularly

### 11.3: External and Internal Penetration Testing

| Test Area | PQC-Specific Tests | Status | Last Test |
|-----------|-------------------|--------|-----------|
| **TLS negotiation** | Downgrade attack resistance | [x] Pass | Lab 04 |
| **Certificate validation** | ML-DSA signature verification | [x] Pass | Lab 01 |
| **Key exchange** | Hybrid KEM security | [x] Pass | Lab 03-04 |
| **Side-channel attacks** | Timing attacks on PQC ops | [ ] Pending | Q1 2025 |

**Recommended PQC Penetration Tests:**
1. **Algorithm downgrade attacks:** Force client to classical-only
2. **Certificate forgery:** Attempt to forge ML-DSA signatures
3. **Timing attacks:** Measure decapsulation time variations
4. **Implementation bugs:** Test liboqs edge cases

---

## 📊 Compliance Assessment

### PCI DSS 4.0 PQC-Relevant Requirements

| Requirement | Title | Status | Priority |
|-------------|-------|--------|----------|
| **4.2.1** | Strong crypto for transmission | ✅ Compliant | Critical |
| **4.2.1.1** | Quantum threat mitigation | ✅ Compliant | Critical (NEW) |
| **3.5.1** | Secure key storage | ✅ Compliant | Critical |
| **12.3.4** | Annual crypto review | ✅ Scheduled | High (NEW) |
| **11.3** | Penetration testing | ⚠️ Partial | High |
| **6.5.3** | Secure crypto implementations | ✅ Compliant | High |

**Overall Status:** ✅ **Substantially Compliant** (5/6 complete, 1 in progress)

---

## 🎯 PQC-Specific Gaps and Remediations

### Gap 1: Side-Channel Analysis Pending

**Risk:** PQC algorithms may be vulnerable to timing attacks  
**Impact:** Potential key extraction  
**Remediation:**
- Schedule external security audit (Q1 2025)
- Implement constant-time operations verification
- Update to latest liboqs (includes timing mitigations)

**PCI DSS Reference:** Requirement 11.3.2 (External penetration testing)

### Gap 2: HSM Not Yet PQC-Compatible

**Risk:** Hardware Security Modules don't support ML-KEM/ML-DSA  
**Impact:** Keys stored in software (less secure)  
**Remediation:**
- Evaluate PQC-enabled HSMs (Thales, Utimaco)
- Timeline: 2025-2026
- Interim: Use encrypted filesystems + strict access control

**PCI DSS Reference:** Requirement 3.5.1.2 (Key storage in secure cryptographic device)

### Gap 3: Payment Gateway Not PQC-Ready

**Risk:** Third-party payment processor uses classical TLS only  
**Impact:** End-to-end PQC not possible  
**Remediation:**
- Contact payment gateway (Stripe, PayPal, etc.)
- Request PQC support roadmap
- Hybrid approach within our control

**PCI DSS Reference:** Requirement 12.8.4 (Service provider PCI DSS compliance)

---

## 📝 Recommendations

### Immediate (Q4 2024)

1. **Document PQC implementation for QSA audit**
   - Technical architecture diagram
   - Key management procedures
   - Quantum threat risk assessment

2. **Update cryptographic inventory**
   - List all systems using classical vs PQC
   - Identify payment flows requiring PQC
   - Prioritize high-value transactions

### Short-Term (2025)

3. **Conduct PQC-focused penetration test**
   - Hire specialized PQC security firm
   - Test downgrade attacks
   - Validate hybrid KEM security

4. **Engage with payment gateway vendors**
   - Request PQC support timeline
   - Participate in vendor PQC pilots
   - Plan coordinated migration

### Long-Term (2026-2030)

5. **Migrate to PQC-enabled HSMs**
   - Evaluate vendors (Thales Luna, Utimaco, AWS CloudHSM)
   - Budget allocation
   - Phased migration

6. **Full PQC deployment for all payment processing**
   - 100% of transactions use PQC
   - Classical TLS disabled
   - Annual compliance verification

---

## 🔗 PCI DSS 4.0 PQC Resources

- [PCI DSS v4.0 Summary of Changes](https://www.pcisecuritystandards.org/document_library/)
- [PCI SSC Quantum Computing FAQ](https://www.pcisecuritystandards.org/faq/)
- [NIST Post-Quantum Cryptography for Financial Services](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Quantum Threat Timeline (NIST)](https://csrc.nist.gov/CSRC/media/Presentations/2023/mosca-quantum-threat-timeline.pdf)

---

<div align="center">

**Next:** [HIPAA Compliance →](hipaa.md)

[← Back to Lab 08](../README.md) | [ISO 27001 ←](iso27001-mapping.md)

</div>
