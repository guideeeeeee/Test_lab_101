# Discovery Report Template
# แบบฟอร์มรายงานการค้นพบ

**Target:** https://localhost  
**Scan Date:** _______________  
**Scanned By:** _______________  
**Lab:** 01 - Manual Discovery

---

## 1. TLS Configuration | การตั้งค่า TLS

### Protocol Version
```
□ TLS 1.0 (deprecated)
□ TLS 1.1 (deprecated)
☑ TLS 1.2
□ TLS 1.3
```

**Notes:**  
_____________________________________________  
_____________________________________________

### Cipher Suite Used
```
Full cipher suite name: _______________________________

Decoded:
- Key Exchange: _____________
- Authentication: _____________
- Encryption: _____________
- Hash/MAC: _____________
```

---

## 2. Certificate Analysis | การวิเคราะห์ใบรับรอง

### Basic Information
```
Subject (CN): ________________________________
Organization (O): ________________________________
Organizational Unit (OU): ________________________________
Country (C): ________________________________

Issuer: ________________________________
(Self-signed? Yes / No)

Validity:
- Not Before: ________________________________
- Not After: ________________________________
- Days remaining: ____________
```

### Public Key
```
Algorithm: □ RSA  □ ECDSA  □ DSA  □ Ed25519
Key Size: ________ bits
Signature Algorithm: ________________________________
```

---

## 3. Quantum Vulnerability Assessment | การประเมินความเสี่ยง Quantum

### Key Exchange

**Algorithm Found:** _______________________________

| Criterion | Value |
|-----------|-------|
| Quantum-safe? | □ Yes  ☑ No  □ Partial |
| Threat Level | □ None  □ Low  □ Medium  ☑ Critical |
| Attack Method | Shor's Algorithm |
| Time to Break (Quantum) | Hours to Days |
| Recommended Replacement | ML-KEM-768 |

**Explanation:**  
ECDHE uses elliptic curve discrete logarithm, which Shor's algorithm can solve efficiently on a quantum computer.

### Authentication (Certificate Signature)

**Algorithm Found:** _______________________________

| Criterion | Value |
|-----------|-------|
| Quantum-safe? | □ Yes  ☑ No  □ Partial |
| Threat Level | □ None  □ Low  □ Medium  ☑ Critical |
| Attack Method | Shor's Algorithm |
| Time to Break (Quantum) | Hours |
| Recommended Replacement | ML-DSA-65 |

**Explanation:**  
RSA signatures rely on factoring large numbers, which Shor's algorithm can do efficiently.

### Encryption Cipher

**Algorithm Found:** _______________________________

| Criterion | Value |
|-----------|-------|
| Quantum-safe? | □ Yes  □ No  ☑ Partial |
| Threat Level | □ None  ☑ Low  □ Medium  □ Critical |
| Attack Method | Grover's Algorithm |
| Effective Security (Quantum) | Reduced by half (256 → 128 bits) |
| Recommended Action | Keep AES-256 (or upgrade to AES-256 if using AES-128) |

**Explanation:**  
AES is partially affected by Grover's algorithm, which reduces effective key length by half. AES-256 becomes ~128-bit security, which is still acceptable.

### Hash Function

**Algorithm Found:** _______________________________

| Criterion | Value |
|-----------|-------|
| Quantum-safe? | □ Yes  □ No  ☑ Partial |
| Threat Level | □ None  ☑ Low  □ Medium  □ Critical |
| Attack Method | Grover's Algorithm |
| Effective Security (Quantum) | Reduced by half |
| Recommended Action | Use SHA-384 or SHA-512 |

---

## 4. Overall Risk Score | คะแนนความเสี่ยงรวม

```
Critical Vulnerabilities:  ___ / 4
High Vulnerabilities:      ___ / 4
Medium Vulnerabilities:    ___ / 4
Low Vulnerabilities:       ___ / 4

Overall Assessment:
□ Secure (Quantum-safe)
□ Needs Monitoring
☑ Requires Migration (Quantum-vulnerable)
□ Critically Insecure
```

---

## 5. Observations | ข้อสังเกต

### Positive Findings
- Uses Perfect Forward Secrecy (ECDHE)
- Strong symmetric cipher (AES-256-GCM)
- Modern cipher suite selection
- ________________________________________________

### Areas of Concern
- RSA-2048 vulnerable to quantum computing
- ECDHE vulnerable to quantum computing  
- TLS 1.2 only (TLS 1.3 would be better even pre-quantum)
- ________________________________________________

---

## 6. Recommendations | ข้อเสนอแนะ

### Immediate Actions (Pre-Quantum Era)
1. Continue using current configuration (still secure against classical attacks)
2. Monitor quantum computing developments
3. Plan migration timeline

### Post-Quantum Migration (Recommended within 5-10 years)

**Priority 1: Key Exchange**
- Current: ECDHE-X25519
- Migrate to: **X25519+MLKEM768** (hybrid)
- Reason: Critical vulnerability, primary attack vector

**Priority 2: Authentication**
- Current: RSA-2048
- Migrate to: **ECDSA+MLDSA65** (hybrid) or **RSA+MLDSA65**
- Reason: Certificate forgery risk

**Priority 3: Encryption & Hash**
- Current: AES-256-GCM, SHA-384
- Action: **Keep current** (acceptable quantum resistance)
- Note: AES-256 reduced to ~128-bit security is still strong

### Migration Strategy
```
□ Immediate (within 1 year)
☑ Short-term (1-3 years)
□ Medium-term (3-5 years)
□ Long-term (5-10 years)
```

**Justification:**  
Start migration testing now. Deploy hybrid solutions within 1-3 years to protect against "harvest now, decrypt later" attacks.

---

## 7. Timeline & Next Steps | ไทม์ไลน์และขั้นตอนต่อไป

### This Lab Series
1. ✅ Lab 01: Identified quantum vulnerabilities
2. ⏭️ Lab 02: Measure baseline performance
3. ⏭️ Lab 03: Implement hybrid PQC
4. ⏭️ Lab 04: Measure hybrid performance
5. ⏭️ Lab 05: Compare and generate report

### Production Deployment (After Lab)
1. Test hybrid implementations in staging
2. Measure performance impact
3. Update certificates and configurations
4. Deploy to production gradually
5. Monitor compatibility issues

---

## 8. Additional Notes | บันทึกเพิ่มเติม

_____________________________________________  
_____________________________________________  
_____________________________________________  
_____________________________________________  
_____________________________________________

---

## 9. Appendix: Command Reference | คำสั่งอ้างอิง

```bash
# OpenSSL connection test
openssl s_client -connect localhost:443 -brief

# Certificate details
openssl s_client -connect localhost:443 -showcerts | \
  openssl x509 -text -noout

# Test specific TLS version
openssl s_client -connect localhost:443 -tls1_2

# Full scan with testssl.sh
./testssl.sh/testssl.sh localhost:443

# Cipher enumeration
nmap --script ssl-enum-ciphers -p 443 localhost
```

---

**Report Completed:** _______________  
**Reviewed By:** _______________  
**Next Action:** Proceed to Lab 02 - Baseline Performance Testing

<div align="center">

[← Back to Lab 01](../README.md) | [Example Report →](../examples/completed-worksheet-example.md)

</div>
