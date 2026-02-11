# GDPR Encryption Requirements Mapping
# การแมพกับข้อกำหนดการเข้ารหัสของ GDPR

**Lab:** 08-Compliance Mapping [BONUS]  
**Standard:** GDPR (General Data Protection Regulation - EU)  
**Date:** _________________________

---

## 📖 Overview

The GDPR requires appropriate technical measures to protect personal data. Post-quantum cryptography addresses GDPR's requirements for long-term data protection and "privacy by design."

---

## 🔐 Article 32: Security of Processing

**GDPR Text:**
> "Taking into account the state of the art, the costs of implementation and the nature, scope, context and purposes of processing... the controller and the processor shall implement appropriate technical and organisational measures to ensure a level of security appropriate to the risk, including... the pseudonymisation and encryption of personal data."

### Article 32(1)(a): Encryption of Personal Data

| Requirement | PQC Implementation | Status | GDPR Alignment |
|-------------|-------------------|--------|----------------|
| **Encryption in transit** | TLS 1.3 with hybrid PQC | [x] Implemented | ✅ "State of the art" |
| **Encryption at rest** | AES-256-GCM | [x] Implemented | ✅ Quantum-resistant |
| **Key management** | ML-KEM for secure key exchange | [x] Implemented | ✅ Forward secrecy |
| **Quantum resistance** | Hybrid PQC approach | [x] Implemented | ✅ Future-proof |

**"State of the Art" Justification:**
- NIST standardized PQC (FIPS 203/204) in 2024
- Industry best practice (hybrid approach)
- Protects against "harvest now, decrypt later"

---

### Article 32(1)(b): Ability to Ensure Ongoing Confidentiality

**Requirement:** Systems must maintain confidentiality despite future threats.

| Threat | Classical Crypto | PQC Hybrid | GDPR Compliance |
|--------|------------------|------------|-----------------|
| **Current threats** | ✅ Secure | ✅ Secure | Both compliant |
| **Quantum computers (2030+)** | ❌ Vulnerable | ✅ Resistant | PQC needed |
| **"Harvest now, decrypt later"** | ❌ At risk | ✅ Protected | PQC recommended |

**GDPR Interpretation:** 
- Personal data may remain sensitive for decades (e.g., biometrics, health data)
- Controllers must consider **future threats** when choosing encryption
- PQC demonstrates "privacy by design" (Article 25)

---

## 🛡️ Article 25: Data Protection by Design and by Default

**GDPR Text:**
> "Taking into account the state of the art... the controller shall... implement appropriate technical and organisational measures... which are designed to implement data-protection principles... in an effective manner."

### Privacy by Design: PQC as Proactive Measure

| GDPR Principle | PQC Contribution | Status |
|----------------|------------------|--------|
| **Data minimization** | Ephemeral keys (forward secrecy) | [x] Implemented |
| **Integrity** | ML-DSA signatures prevent tampering | [x] Implemented |
| **Confidentiality** | Quantum-resistant encryption | [x] Implemented |
| **Future-proofing** | Cryptographic agility (easy algorithm swap) | [x] Implemented |

**Demonstrating Compliance:**
- PQC migration plan shows proactive risk management
- Hybrid approach balances security and compatibility
- Annual cryptographic reviews (best practice)

---

## 📋 Article 33/34: Data Breach Notification

### Breach Scenario: Encrypted Data Stolen

**Question:** If encrypted personal data is stolen, do you need to notify under GDPR?

**GDPR Article 34(3)(a):**
> "The communication to the data subject... shall not be required if... the controller has implemented appropriate technical and organisational protection measures... such as encryption... which render the personal data unintelligible to any person who is not authorised to access it."

| Encryption Type | Data Stolen | Notify Required? | PQC Impact |
|-----------------|-------------|------------------|------------|
| **No encryption** | Yes | ✅ **YES** (within 72h) | N/A |
| **Weak encryption** (e.g., DES) | Yes | ✅ **YES** | Classical crypto may be weak |
| **Strong classical** (RSA-2048) | Yes | ⚠️ Depends | Vulnerable if attacker waits for quantum |
| **PQC hybrid** | Yes | ❌ **NO** (if keys secure) | Data remains unintelligible long-term |

**Key Point:** PQC reduces likelihood of mandatory breach notification by ensuring data remains protected even if stolen today and decrypted attempts made with future quantum computers.

---

## 🌍 Article 44-50: International Data Transfers

### Adequacy Decisions & Standard Contractual Clauses (SCCs)

**GDPR Requirement:** Data transfers to non-EU countries require adequate protection.

| Transfer Mechanism | PQC Relevance | Status |
|-------------------|---------------|--------|
| **TLS encryption** | Required for data in transit | [x] PQC implemented |
| **SCCs** | Must specify encryption standards | [ ] Update SCCs to mention PQC |
| **Binding Corporate Rules** | Include cryptographic requirements | [ ] Update BCRs |

**Schrems II Implications:**
- European Court of Justice requires "essentially equivalent" protection
- PQC demonstrates robust encryption beyond government backdoors
- Helps address "access by public authorities" concerns

---

## 📊 GDPR + PQC Compliance Matrix

### Article-by-Article Assessment

| GDPR Article | Title | PQC Relevance | Status |
|--------------|-------|---------------|--------|
| **Art. 5(1)(f)** | Integrity & confidentiality | Critical | ✅ Compliant |
| **Art. 25** | Data protection by design | High | ✅ Compliant |
| **Art. 32** | Security of processing | **Critical** | ✅ Enhanced |
| **Art. 33/34** | Breach notification | Medium | ✅ Reduced risk |
| **Art. 44-50** | International transfers | Medium | ⚠️ Update SCCs |

**Overall Status:** ✅ **Compliant** (PQC exceeds minimum GDPR requirements)

---

## 🎯 PQC-Specific Recommendations for GDPR

### 1. Document "State of the Art" Assessment

**GDPR Article 32:** Controllers must demonstrate they considered "state of the art."

**Your Documentation:**
```markdown
# Cryptographic State of the Art Assessment (2026)

## Industry Standards
- NIST FIPS 203/204 (ML-KEM, ML-DSA) standardized Aug 2024
- IETF draft-ietf-tls-hybrid-design (hybrid PQC in TLS)
- Major vendors (Google, Cloudflare) testing PQC

## Threat Landscape
- Quantum computing progress: 1000+ qubit systems demonstrated
- "Harvest now, decrypt later" attacks documented
- NIST estimates quantum threat viable 2030-2035

## Our Decision
- Deploy hybrid PQC (X25519+ML-KEM-768, ECDSA+ML-DSA-65)
- Rationale: Balances security, compatibility, performance
- Timeline: Pilot 2025, production 2026
```

### 2. Update Data Processing Agreements (DPAs)

**GDPR Article 28:** Processors must comply with controller's instructions.

**Add to DPA:**
```
Clause X: Cryptographic Requirements

The Processor shall:
(a) Encrypt personal data in transit using TLS 1.3 with post-quantum 
    cryptographic algorithms approved by NIST (FIPS 203, 204);
(b) Implement hybrid key exchange (classical + PQC) by [deadline];
(c) Maintain cryptographic agility to adapt to evolving standards;
(d) Notify Controller within 24 hours of any cryptographic vulnerability.
```

### 3. Privacy Impact Assessment (PIA/DPIA)

**GDPR Article 35:** Required for high-risk processing.

**PQC-Related Risks to Address:**
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Quantum computer breakthrough | Medium (2030s) | High | Deploy PQC now |
| PQC algorithm vulnerabilities | Low | Medium | Hybrid approach |
| Interoperability issues | Medium | Low | Test thoroughly |

---

## 💡 Practical GDPR Compliance Steps

### Immediate Actions (Q1 2026)

1. **Update Privacy Policy**
   ```
   "We protect your personal data using state-of-the-art encryption, 
   including post-quantum cryptographic algorithms approved by NIST, 
   to ensure long-term confidentiality."
   ```

2. **Document Technical Measures**
   - Create "Encryption Standards" document
   - Reference NIST FIPS 203/204
   - Include in Art. 30 processing records

3. **Train Data Protection Officer (DPO)**
   - PQC fundamentals
   - Quantum threat timeline
   - Breach notification implications

### Short-Term (2026)

4. **Update Vendor Contracts**
   - Require PQC support from cloud providers
   - Update SLAs to include PQC deployment timeline
   - Audit third-party processors

5. **Conduct DPIA for PQC Migration**
   - Assess performance impact on user experience
   - Evaluate risks of delayed migration
   - Document balancing test (Art. 32)

### Long-Term (2027-2030)

6. **Regular Cryptographic Reviews**
   - Annual assessment of "state of the art"
   - Monitor NIST announcements
   - Update PQC algorithms as needed

7. **Compliance Audits**
   - Include PQC in ISO 27001 audits
   - Demonstrate GDPR Art. 32 compliance
   - Update BCRs and SCCs

---

## ⚠️ Common GDPR + PQC Pitfalls

### Pitfall 1: "Encryption is Optional"

**Myth:** GDPR doesn't mandate encryption.  
**Reality:** Art. 32 requires "appropriate" measures. For sensitive data, encryption is expected.  
**PQC Impact:** Courts may consider quantum resistance when assessing "appropriate."

### Pitfall 2: "Classical TLS is Sufficient"

**Myth:** Current TLS is good enough for GDPR.  
**Reality:** "State of the art" evolves. By 2030, classical-only may be insufficient.  
**PQC Impact:** Proactive PQC adoption demonstrates due diligence.

### Pitfall 3: "Only EU Data Needs Protection"

**Myth:** GDPR only applies to EU residents.  
**Reality:** Applies to any organization processing EU personal data.  
**PQC Impact:** Global encryption standards (like PQC) simplify compliance.

---

## 📚 GDPR Authority Guidance on Encryption

### European Data Protection Board (EDPB)

**EDPB Guidelines 4/2019 on Article 25:**
> "Controllers should... encrypt data in transit and at rest using state-of-the-art cryptography."

### National DPAs

| Authority | Guidance | PQC Mention |
|-----------|----------|-------------|
| **CNIL** (France) | Recommends strong encryption | Acknowledges quantum threat |
| **ICO** (UK) | "Use industry-standard encryption" | Monitoring PQC developments |
| **BfDI** (Germany) | ISO 27002 recommended | Supports NIST standards |

---

## 🔗 References

- [GDPR Official Text](https://gdpr-info.eu/)
- [EDPB Guidelines on Security (Art. 32)](https://edpb.europa.eu/)
- [ENISA: Post-Quantum Cryptography](https://www.enisa.europa.eu/topics/quantum-safe-cryptography)
- [NIST PQC Standardization](https://csrc.nist.gov/projects/post-quantum-cryptography)

---

<div align="center">

**Next:** [Back to Compliance Overview →](../README.md)

[← Back to Lab 08](../README.md) | [HIPAA ←](hipaa.md)

</div>
