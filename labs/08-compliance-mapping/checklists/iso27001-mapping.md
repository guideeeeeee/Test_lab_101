# ISO/IEC 27001:2022 Compliance Mapping
# การแมพกับมาตรฐาน ISO/IEC 27001:2022

**Lab:** 08-Compliance Mapping [BONUS]  
**Standard:** ISO/IEC 27001:2022 (Information Security Management)  
**Date:** _________________________

---

## 📖 Overview

ISO/IEC 27001:2022 is the international standard for Information Security Management Systems (ISMS). This document maps our PQC hybrid implementation to relevant ISO 27001 controls.

---

## 🔐 Annex A.8: Cryptographic Controls

### A.8.24: Use of Cryptography

**Control Statement:**
> "Rules for the effective use of cryptography, including cryptographic key management, should be defined and implemented."

| Requirement | Implementation | Status | Evidence |
|-------------|----------------|--------|----------|
| **Cryptography policy defined** | PQC migration policy documented | [x] Complete | [CRYPTO-POLICY-001.md] |
| **Appropriate algorithms** | ML-KEM-768, ML-DSA-65 (NIST-approved) | [x] Complete | FIPS 203/204 compliance |
| **Key strengths documented** | Security level 3 (192-bit equivalent) | [x] Complete | Algorithm spec sheets |
| **Quantum resistance** | Hybrid PQC approach | [x] Complete | Lab 03-04 implementation |
| **Algorithm selection justification** | Risk assessment performed | [x] Complete | [RISK-ASSESSMENT-2024.md] |

**Evidence:**
```bash
# Show algorithms in use
openssl ciphers -v | grep -E "(MLKEM|MLDSA|X25519)"

# Output: TLS_AES_256_GCM_SHA384 with X25519MLKEM768
```

**Compliance Assessment:** ✅ **Compliant**

---

### A.8.7: Protection Against Malware

| Requirement | PQC Relevance | Implementation | Status |
|-------------|---------------|----------------|--------|
| **Malware detection** | Encrypted traffic inspection | TLS decryption at gateway | [x] Implemented |
| **Regular updates** | Crypto library updates | liboqs auto-updates | [x] Implemented |

**Note:** PQC doesn't significantly impact malware controls. Standard practices apply.

---

## 🔒 Annex A.5: Information Security Policies

### A.5.1: Policies for Information Security

**Control Statement:**
> "Information security policy and topic-specific policies should be defined, approved by management, published, communicated to and acknowledged by relevant personnel and relevant interested parties, and reviewed at planned intervals and if significant changes occur."

| Policy Component | Content | Status | Review Date |
|------------------|---------|--------|-------------|
| **Cryptographic Policy** | Approved algorithms (ML-KEM, ML-DSA) | [x] Approved | Q1 2025 |
| **Key Management Policy** | Generation, storage, rotation, destruction | [x] Approved | Q1 2025 |
| **Migration Timeline** | 2024-2030 phased rollout | [x] Approved | Annually |
| **Risk Assessment** | Quantum threat analysis | [x] Complete | Q4 2024 |
| **Incident Response** | Crypto failure procedures | [ ] Draft | Q2 2025 |

**Management Approval:**
- Signed by: _____________________ (CISO)
- Date: _____________
- Next review: _____________

---

## 🔑 Annex A.8: Key Management

### A.8.8 & A.8.10: Management of Technical Vulnerabilities

| Requirement | Implementation | Status | Notes |
|-------------|----------------|--------|-------|
| **Key generation** | FIPS 140-3 RNG | [x] Implemented | `/dev/urandom` with sufficient entropy |
| **Secure key storage** | Encrypted at rest, 0600 permissions | [x] Implemented | `/etc/ipsec.d/private/` |
| **Key distribution** | Certificate-based (X.509) | [x] Implemented | CA-signed certificates |
| **Key rotation** | 90-day automatic rotation | [x] Implemented | cert-manager automation |
| **Key destruction** | Secure deletion (shred) | [ ] Partial | Manual process, needs automation |
| **Key backup** | Encrypted backups | [x] Implemented | HSM or encrypted vault |
| **Access control** | Root-only access | [x] Implemented | `ls -l` verification |

**Key Lifecycle:**
```
┌──────────────┐
│  Generate    │  ML-KEM-768 / ML-DSA-65 keypair
│  (OpenSSL)   │  Using FIPS 140-3 RNG
└──────┬───────┘
       │
┌──────▼───────┐
│   Store      │  /etc/ipsec.d/private/*.pem
│  (Encrypted) │  Permissions: 0600, Owner: root
└──────┬───────┘
       │
┌──────▼───────┐
│     Use      │  TLS/IPsec operations
│  (Runtime)   │  Loaded into memory
└──────┬───────┘
       │
┌──────▼───────┐
│   Rotate     │  Every 90 days
│  (Automated) │  New keys generated
└──────┬───────┘
       │
┌──────▼───────┐
│   Destroy    │  Secure overwrite (shred -n 3)
│  (Shredding) │  Then delete
└──────────────┘
```

**Verification:**
```bash
# Check key permissions
ls -l /etc/ipsec.d/private/
# Expected: -rw------- 1 root root (600 permissions)

# Check key file encryption (if using encrypted filesystem)
df -T /etc/ipsec.d/
# Expected: ext4 with LUKS or similar
```

---

## 🌐 Annex A.5.14: Information Transfer

**Control Statement:**
> "Information transfer policies, procedures and controls should be in place to protect the transfer of information through the use of all types of communication facilities."

| Requirement | Implementation | Status | Evidence |
|-------------|----------------|--------|----------|
| **Encryption in transit** | TLS 1.3 with hybrid PQC | [x] Complete | Lab 03-04 |
| **Mutual authentication** | Client & server certificates | [x] Complete | X.509 ML-DSA certs |
| **Forward secrecy** | Ephemeral key exchange (ECDHE+MLKEM) | [x] Complete | TLS configuration |
| **Protection from eavesdropping** | Strong ciphers (AES-256-GCM) | [x] Complete | Cipher suite config |
| **Data integrity** | HMAC / AEAD | [x] Complete | GCM authenticated encryption |
| **Non-repudiation** | Digital signatures (ML-DSA) | [x] Complete | Certificate logging |

**Test secure information transfer:**
```bash
# Verify TLS 1.3 with PQC
openssl s_client -connect localhost:8443 -tls1_3 | grep "Protocol\|Cipher"

# Expected output:
# Protocol  : TLSv1.3
# Cipher    : TLS_AES_256_GCM_SHA384
# Server Temp Key: X25519MLKEM768
```

---

## 🛡️ Annex A.8.23: Web Filtering

| Requirement | PQC Impact | Implementation | Status |
|-------------|------------|----------------|--------|
| **TLS inspection** | Requires PQC-aware proxies | Update to PQC-compatible tools | [ ] Planned |
| **Certificate pinning** | Update pins for PQC certs | New cert hashes documented | [x] Complete |
| **Content filtering** | No change | Existing tools compatible | [x] N/A |

**Note:** TLS inspection tools (proxies, firewalls) must support PQC algorithms or be bypassed.

---

## 📋 Annex A.5.37: Documented Operating Procedures

| Documentation | Content | Status | Location |
|---------------|---------|--------|----------|
| **PQC Migration Plan** | Timeline, milestones, owners | [x] Complete | `/docs/migration-plan.md` |
| **Runbooks** | Deployment, troubleshooting | [x] Complete | `/docs/runbooks/` |
| **Configuration Standards** | nginx.conf, ipsec.conf templates | [x] Complete | `/configs/` |
| **Testing Procedures** | Performance, security tests | [x] Complete | `/labs/02-04/` |
| **Incident Response** | Crypto failure response | [ ] Draft | TBD |

---

## 🔍 Annex A.8.16: Monitoring Activities

**Control Statement:**
> "Networks, systems and applications should be monitored for anomalous behavior and appropriate action taken to evaluate potential information security incidents."

| Monitoring Area | Metrics | Alerting Threshold | Status |
|-----------------|---------|-------------------|--------|
| **TLS handshake failures** | Count, error codes | >5% failure rate | [x] Implemented |
| **Algorithm negotiation** | Classical vs PQC usage | <50% PQC adoption | [x] Implemented |
| **Performance degradation** | Latency, throughput | >30% increase | [x] Implemented |
| **Certificate expiration** | Days until expiry | <30 days | [x] Implemented |
| **Key rotation status** | Last rotation date | >90 days overdue | [ ] Planned |
| **Crypto library updates** | Version check | Update available | [ ] Planned |

**Monitoring Commands:**
```bash
# Check TLS handshake success rate
grep "SSL handshake" /var/log/nginx/error.log | wc -l

# Check algorithm usage
sudo ipsec statusall | grep "MLKEM"

# Check certificate expiry
openssl x509 -in certs/server.crt -noout -dates
```

---

## 📊 Annex A.8.9: Configuration Management

| Asset | Configuration | Version Control | Status |
|-------|---------------|-----------------|--------|
| **nginx.conf** | TLS 1.3, PQC ciphers | Git | [x] Tracked |
| **ipsec.conf** | Hybrid KEM config | Git | [x] Tracked |
| **OpenSSL config** | oqs-provider enabled | Git | [x] Tracked |
| **Certificates** | ML-DSA signed | Certificate inventory | [x] Tracked |
| **Crypto libraries** | liboqs 0.10.0+ | Package manager | [x] Tracked |

**Configuration Baseline:**
```bash
# Capture current config
git clone https://github.com/yourorg/pqc-configs.git
cd pqc-configs
git log --oneline

# Expected: Version-controlled configs with change history
```

---

## ✅ Compliance Summary

### Controls Assessment

| Annex A Control | Relevance | Status | Priority |
|-----------------|-----------|--------|----------|
| **A.8.24: Use of Cryptography** | Critical | ✅ Compliant | P1 |
| **A.5.1: Policies** | High | ✅ Compliant | P1 |
| **A.8.8/8.10: Key Management** | Critical | ⚠️ Mostly Compliant | P1 |
| **A.5.14: Information Transfer** | High | ✅ Compliant | P1 |
| **A.8.16: Monitoring** | Medium | ⚠️ Partial | P2 |
| **A.8.9: Configuration Mgmt** | Medium | ✅ Compliant | P2 |
| **A.8.23: Web Filtering** | Low | ⏸️ Planned | P3 |
| **A.5.37: Documentation** | Medium | ⚠️ Partial | P2 |

**Overall Compliance:** 75% (6/8 fully compliant)

### Risk Assessment

| Gap | Risk Level | Impact | Mitigation | Deadline |
|-----|------------|--------|------------|----------|
| **Key destruction not automated** | Medium | Keys may persist after rotation | Implement automated shredding | Q1 2025 |
| **Incident response incomplete** | Medium | Delayed crypto failure response | Document procedures | Q2 2025 |
| **Monitoring not comprehensive** | Low | Late detection of issues | Extend monitoring coverage | Q2 2025 |
| **TLS inspection incompatible** | Low | Reduced visibility in proxies | Evaluate PQC-aware tools | Q3 2025 |

---

## 📝 Recommendations

### High Priority

1. **Complete Key Lifecycle Automation**
   - Implement automated secure deletion (shred)
   - Test backup/restore procedures
   - Document emergency key recovery

2. **Finalize Incident Response Plan**
   - Crypto algorithm break response
   - Certificate compromise procedures
   - Rollback to classical TLS

3. **Enhance Monitoring**
   - Real-time algorithm usage dashboard
   - Performance degradation alerts
   - Certificate inventory automation

### Medium Priority

4. **Staff Training**
   - ISO 27001 + PQC awareness
   - Operational procedures
   - Compliance auditing

5. **Third-Party Assessment**
   - External audit of PQC implementation
   - Penetration testing with PQC focus
   - ISMS certification review

---

## 🔗 References

- [ISO/IEC 27001:2022 Standard](https://www.iso.org/standard/27001)
- [ISO/IEC 27002:2022 (Implementation Guidance)](https://www.iso.org/standard/75652.html)
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework)
- [PQC Migration Handbook (NIST)](https://csrc.nist.gov/publications/detail/white-paper/2021/04/28/getting-ready-for-post-quantum-cryptography)

---

<div align="center">

**Next:** [PCI DSS Mapping →](pci-dss.md)

[← Back to Lab 08](../README.md) | [NIST FIPS ←](nist-fips-203-204.md)

</div>
