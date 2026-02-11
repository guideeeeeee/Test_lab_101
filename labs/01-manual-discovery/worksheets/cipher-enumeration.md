# Cipher Suite Enumeration Worksheet
# แบบฝึกหัด: การแจกแจง Cipher Suite

**Lab:** 01-Manual Discovery  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Objective

ในแบบฝึกหัดนี้ คุณจะแจกแจง (enumerate) Cipher Suite ทั้งหมดที่ Target Application รองรับ และวิเคราะห์ว่า:
- แต่ละ Cipher Suite ประกอบด้วยอะไรบ้าง
- Cipher Suite ใดปลอดภัย ไม่ปลอดภัย
- Cipher Suite ใดเสี่ยงต่อการโจมตีจาก Quantum Computer

---

## 🔍 Part 1: Enumerate All Cipher Suites

### Method 1: Using nmap

```bash
nmap --script ssl-enum-ciphers -p 443 localhost
```

**Results:** (บันทึกผลที่ได้ทั้งหมด)

```
TLS 1.2 Cipher Suites:
1. __________________________________________ (Grade: ____)
2. __________________________________________ (Grade: ____)
3. __________________________________________ (Grade: ____)
4. __________________________________________ (Grade: ____)
5. __________________________________________ (Grade: ____)

TLS 1.3 Cipher Suites:
1. __________________________________________ (Grade: ____)
2. __________________________________________ (Grade: ____)
3. __________________________________________ (Grade: ____)
```

---

### Method 2: Using testssl.sh

```bash
testssl.sh --cipher-per-proto localhost:443
```

**Results Summary:**

| Protocol | Cipher Count | Strongest | Weakest |
|----------|--------------|-----------|---------|
| SSL 3.0 | | | |
| TLS 1.0 | | | |
| TLS 1.1 | | | |
| TLS 1.2 | | | |
| TLS 1.3 | | | |

---

## 🔐 Part 2: Cipher Suite Analysis

เลือก **3 cipher suites** ที่พบบ่อยที่สุด และวิเคราะห์แต่ละตัว

### Cipher Suite #1

**Full Name:** __________________________________________________

**Example:** `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`

#### Decode Components:

| Component | Value | Purpose | Quantum Vulnerable? |
|-----------|-------|---------|---------------------|
| Key Exchange | | How session key is negotiated | [ ] Yes [ ] No |
| Authentication | | How server identity is verified | [ ] Yes [ ] No |
| Encryption | | How data is encrypted | [ ] Yes [ ] No |
| MAC/AEAD | | How integrity is verified | [ ] Yes [ ] No |

**ตัวอย่างการแยก:**
```
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
│   │     │   │   │       │   │
│   │     │   │   │       │   └─ SHA384 (Hash for PRF)
│   │     │   │   │       └───── GCM (AEAD mode)
│   │     │   │   └───────────── AES-256 (Encryption)
│   │     │   └───────────────── WITH (separator)
│   │     └───────────────────── RSA (Authentication)
│   └─────────────────────────── ECDHE (Key Exchange)
└─────────────────────────────── TLS (Protocol)
```

#### Security Assessment:

**Strengths:** (อะไรที่ดี)
- _______________________________________________________________
- _______________________________________________________________

**Weaknesses:** (อะไรที่เสี่ยง)
- _______________________________________________________________
- _______________________________________________________________

**Quantum Resistance:** (ต้านทานการโจมตีจาก Quantum ได้หรือไม่)
- [ ] Fully Resistant (PQC algorithms)
- [ ] Partially Resistant (only some components)
- [ ] Not Resistant (all classical algorithms)

**Overall Grade:** [ ] A [ ] B [ ] C [ ] D [ ] F

---

### Cipher Suite #2

**Full Name:** __________________________________________________

#### Decode Components:

| Component | Value | Quantum Vulnerable? |
|-----------|-------|---------------------|
| Key Exchange | | [ ] Yes [ ] No |
| Authentication | | [ ] Yes [ ] No |
| Encryption | | [ ] Yes [ ] No |
| MAC/AEAD | | [ ] Yes [ ] No |

**Overall Grade:** [ ] A [ ] B [ ] C [ ] D [ ] F

---

### Cipher Suite #3

**Full Name:** __________________________________________________

#### Decode Components:

| Component | Value | Quantum Vulnerable? |
|-----------|-------|---------------------|
| Key Exchange | | [ ] Yes [ ] No |
| Authentication | | [ ] Yes [ ] No |
| Encryption | | [ ] Yes [ ] No |
| MAC/AEAD | | [ ] Yes [ ] No |

**Overall Grade:** [ ] A [ ] B [ ] C [ ] D [ ] F

---

## 🎯 Part 3: Vulnerability Identification

### Weak Cipher Suites Found

บันทึก Cipher Suite ที่มีช่องโหว่หรือถือว่าอ่อนแอ:

| Cipher Suite | Vulnerability | Severity |
|--------------|---------------|----------|
| | | [ ] Critical [ ] High [ ] Medium |
| | | [ ] Critical [ ] High [ ] Medium |
| | | [ ] Critical [ ] High [ ] Medium |

**Common Vulnerabilities:**
- [ ] NULL encryption (no encryption at all!)
- [ ] EXPORT ciphers (deliberately weakened in 1990s)
- [ ] DES/3DES (too small key space)
- [ ] RC4 (biased output)
- [ ] CBC mode without proper padding (BEAST, POODLE attacks)
- [ ] Anonymous DH (no authentication - MITM risk)
- [ ] MD5 (collision attacks)
- [ ] Static RSA key exchange (no forward secrecy)

---

### Quantum-Vulnerable Cipher Suites

บันทึก Cipher Suite ที่เสี่ยงต่อการโจมตีจาก Quantum Computer:

| Cipher Suite | Vulnerable Component | Algorithm | Attack Method |
|--------------|----------------------|-----------|---------------|
| | Key Exchange | | Shor's Algorithm |
| | Authentication | | Shor's Algorithm |
| | Key Exchange | | Shor's Algorithm |
| | Authentication | | Shor's Algorithm |

**คำถาม:** มีกี่ Cipher Suite ที่เสี่ยงต่อ Quantum?

- TLS 1.2: _____ / _____ suites (____%)
- TLS 1.3: _____ / _____ suites (____%)
- **Total: _____ / _____ suites (_____%)**

---

## 📊 Part 4: Priority Matrix

จัดลำดับความสำคัญในการแก้ไขแต่ละ Cipher Suite:

### High Priority (แก้ไขทันที)

| Cipher Suite | Reason | Recommended Action |
|--------------|--------|-------------------|
| | | Disable immediately |
| | | Disable immediately |

### Medium Priority (วางแผนแก้ไข)

| Cipher Suite | Reason | Recommended Action |
|--------------|--------|-------------------|
| | | Replace with PQC hybrid |
| | | Replace with PQC hybrid |

### Low Priority (เฝ้าติดตาม)

| Cipher Suite | Reason | Recommended Action |
|--------------|--------|-------------------|
| | | Monitor for updates |

---

## 🔄 Part 5: Recommended Configuration

จากการวิเคราะห์ ให้เสนอ Cipher Suite configuration ที่ดีที่สุดสำหรับ:

### 🎯 Option 1: Maximum Security (PQC)

**Protocol:** TLS 1.3

**Cipher Suites (in order of preference):**
1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

**Key Exchange Groups:**
1. _______________________________________________________________
2. _______________________________________________________________

**Signature Algorithms:**
1. _______________________________________________________________
2. _______________________________________________________________

---

### ⚖️ Option 2: Balanced (Hybrid)

**Protocol:** TLS 1.3 + TLS 1.2 (fallback)

**TLS 1.3 Cipher Suites:**
1. _______________________________________________________________
2. _______________________________________________________________

**TLS 1.2 Cipher Suites:**
1. _______________________________________________________________
2. _______________________________________________________________

**Key Exchange Groups:**
1. _______________________________________________________________  (PQC hybrid)
2. _______________________________________________________________  (Classical fallback)

---

### 🔓 Option 3: Compatibility (Legacy Support)

**Protocols:** TLS 1.3 + TLS 1.2 + TLS 1.1 (legacy only)

**Include legacy ciphers:** [ ] Yes [ ] No

**Justification:**
_______________________________________________________________
_______________________________________________________________

---

## 🧪 Part 6: Testing

### Test Preferred Cipher

ทดสอบว่า server ใช้ cipher ที่ดีที่สุดเป็น default:

```bash
openssl s_client -connect localhost:443 -cipher "DEFAULT" < /dev/null 2>&1 | grep "Cipher"
```

**Result:** ______________________________________________________

**คำถาม:** นี่คือ cipher ที่ดีที่สุดที่ server รองรับหรือไม่?
- [ ] ใช่
- [ ] ไม่ (อธิบาย: __________________________________________)

---

### Test Specific Cipher

บังคับใช้ cipher ที่อ่อนแอเพื่อทดสอบว่า server รองรับหรือไม่:

```bash
openssl s_client -connect localhost:443 -cipher "DES-CBC3-SHA" < /dev/null
```

**Result:**
- [ ] Success (เชื่อมต่อได้ - ไม่ดี!)
- [ ] Failure (เชื่อมต่อไม่ได้ - ดี!)

---

## 🎯 Part 7: Summary & Recommendations

### Current State

**Total Cipher Suites:** _____

**Breakdown:**
- Secure: _____ (____%)
- Weak: _____ (____%)
- Quantum-Vulnerable: _____ (____%)

**Protocols Supported:**
- [ ] SSL 3.0 (critical vulnerability!)
- [ ] TLS 1.0 (deprecated)
- [ ] TLS 1.1 (deprecated)
- [ ] TLS 1.2 (current standard)
- [ ] TLS 1.3 (modern standard)
- [ ] TLS 1.3 with PQC (future-proof)

---

### Risk Assessment

**Overall Security Grade:** [ ] A [ ] B [ ] C [ ] D [ ] F

**Major Issues Found:**
1. _______________________________________________________________
2. _______________________________________________________________
3. _______________________________________________________________

**Quantum Readiness:** [ ] 0% [ ] 25% [ ] 50% [ ] 75% [ ] 100%

---

### Action Plan

**Immediate (0-30 days):**
1. _______________________________________________________________
2. _______________________________________________________________

**Short-term (1-3 months):**
1. _______________________________________________________________
2. _______________________________________________________________

**Long-term (3-12 months):**
1. _______________________________________________________________
2. _______________________________________________________________

---

## ✅ Checkpoint

ก่อนส่งแบบฝึกหัด ตรวจสอบว่าคุณได้:

- [ ] แจกแจง cipher suites ครบทั้งหมด (ทั้ง TLS 1.2 และ 1.3)
- [ ] วิเคราะห์อย่างน้อย 3 cipher suites โดยละเอียด
- [ ] ระบุ cipher suites ที่มีช่องโหว่
- [ ] ระบุ cipher suites ที่เสี่ยงต่อ Quantum
- [ ] เสนอ configuration ที่เหมาะสม
- [ ] ทดสอบ cipher selection
- [ ] สรุปและให้คำแนะนำ

---

<div align="center">

**Next:** [Risk Assessment Worksheet →](risk-assessment.md)

[← Back to Certificate Analysis](certificate-analysis.md) | [← Back to Lab 01](../README.md)

</div>
