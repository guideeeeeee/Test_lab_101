# Certificate Analysis Worksheet
# แบบฝึกหัด: การวิเคราะห์ใบรับรอง (Certificate)

**Lab:** 01-Manual Discovery  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Objective

ในแบบฝึกหัดนี้ คุณจะวิเคราะห์ใบรับรอง TLS ของ Target Application (Lab 00) เพื่อทำความเข้าใจว่า:
- ใบรับรองประกอบด้วยข้อมูลอะไรบ้าง
- อัลกอริทึมใดถูกใช้งาน
- ข้อมูลเหล่านี้เกี่ยวข้องกับความปลอดภัย (และภัยคุกคามจาก Quantum) อย่างไร

---

## 🔍 Part 1: Retrieve Certificate

**Command to view certificate:**
```bash
echo | openssl s_client -connect localhost:443 -showcerts 2>/dev/null | openssl x509 -text -noout
```

### Question 1.1: Subject Information

ค้นหาบรรทัดที่ขึ้นต้นด้วย `Subject:` และบันทึกข้อมูล:

| Field | Value |
|-------|-------|
| Common Name (CN) | |
| Organization (O) | |
| Country (C) | |

**ความหมาย:** Subject คือ "เจ้าของ" ของใบรับรอง (เว็บไซต์ที่เรากำลังเชื่อมต่อ)

---

### Question 1.2: Issuer Information

ค้นหาบรรทัดที่ขึ้นต้นด้วย `Issuer:` และบันทึกข้อมูล:

| Field | Value |
|-------|-------|
| Common Name (CN) | |
| Organization (O) | |

**ความหมาย:** Issuer คือผู้ที่ "ออก" ใบรับรองนี้ (Certificate Authority)

**คำถาม:** Subject และ Issuer เหมือนกันหรือไม่?
- [ ] เหมือนกัน (Self-signed certificate)
- [ ] ต่างกัน (CA-signed certificate)

---

### Question 1.3: Validity Period

ค้นหาบรรทัด `Not Before:` และ `Not After:`:

| Field | Value |
|-------|-------|
| Not Before | |
| Not After | |
| Valid for (days) | |

**คำถาม:** ใบรับรองนี้ยังใช้งานได้อยู่หรือไม่?
- [ ] ใช่ (วันที่ปัจจุบันอยู่ระหว่าง Before และ After)
- [ ] ไม่ (หมดอายุแล้ว)

---

## 🔐 Part 2: Public Key Analysis

### Question 2.1: Algorithm and Key Size

ค้นหาบรรทัด `Public Key Algorithm:` และ `Public-Key:`:

| Field | Value |
|-------|-------|
| Algorithm | |
| Key Size (bits) | |

**ตัวอย่าง:**
```
Public Key Algorithm: rsaEncryption
    Public-Key: (2048 bit)
```

---

### Question 2.2: Security Level Assessment

ตอบคำถามต่อไปนี้ตาม Algorithm และ Key Size ที่พบ:

**If RSA:**

| Key Size | Classical Security | Quantum Vulnerable? | NIST Recommendation (2019) |
|----------|-------------------|---------------------|---------------------------|
| 1024 bit | ❌ Weak | ✓ Yes | Deprecated |
| 2048 bit | ✓ Strong | ✓ Yes | Approved until 2030 |
| 3072 bit | ✓ Very Strong | ✓ Yes | Preferred |
| 4096 bit | ✓ Very Strong | ✓ Yes | Overkill (performance cost) |

**Your certificate:** _____ bits → Classical: _____ Quantum: _____

**If ECDSA:**

| Curve | Classical Security | Quantum Vulnerable? | Equivalent RSA |
|-------|-------------------|---------------------|----------------|
| P-256 | ✓ Strong | ✓ Yes | ~3072 bit |
| P-384 | ✓ Very Strong | ✓ Yes | ~7680 bit |
| P-521 | ✓ Very Strong | ✓ Yes | ~15360 bit |

**Your certificate:** Curve _____ → Equivalent to RSA _____ bits

---

### Question 2.3: Quantum Threat Analysis

**คำถาม:** อัลกอริทึมนี้ปลอดภัยจาก Shor's Algorithm (Quantum Computer) หรือไม่?

- [ ] ใช่ (Post-Quantum Algorithm เช่น Dilithium, Falcon)
- [ ] ไม่ (Classical Algorithm เช่น RSA, ECDSA)

**อธิบาย:** 
_______________________________________________________________
_______________________________________________________________

**คำถาม:** หากมี Quantum Computer ใช้งานได้จริงในปี 2035 ใบรับรองนี้จะถูกทำลาย (crack) ได้หรือไม่?

- [ ] ใช่ → ใช้เวลาเท่าไหร่? __________
- [ ] ไม่ → ทำไม? ___________________________________

---

## 🔏 Part 3: Signature Analysis

### Question 3.1: Signature Algorithm

ค้นหาบรรทัด `Signature Algorithm:`:

| Field | Value |
|-------|-------|
| Signature Algorithm | |

**ตัวอย่างที่เจอบ่อย:**
- `sha256WithRSAEncryption` (RSA-2048 + SHA-256)
- `ecdsa-with-SHA256` (ECDSA P-256 + SHA-256)
- `ecdsa-with-SHA384` (ECDSA P-384 + SHA-384)

---

### Question 3.2: Signature Breakdown

**Signature Algorithm = Hash Algorithm + Signing Algorithm**

แยกส่วนประกอบของ Signature Algorithm ที่คุณพบ:

| Component | Value | Purpose |
|-----------|-------|---------|
| Hash Algorithm | | Create digest of certificate |
| Signing Algorithm | | Prove authenticity |

**ตัวอย่าง:**
- `sha256WithRSAEncryption` → SHA-256 (hash) + RSA (signature)
- `ecdsa-with-SHA384` → SHA-384 (hash) + ECDSA (signature)

---

### Question 3.3: Hash Collision Resistance

**คำถาม:** Hash Algorithm ที่ใช้ปลอดภัยจาก Collision Attack หรือไม่?

| Hash | Collision Resistant? | Quantum Vulnerable? | Status (2024) |
|------|---------------------|---------------------|---------------|
| MD5 | ❌ No | N/A | Broken |
| SHA-1 | ❌ No (2017) | N/A | Deprecated |
| SHA-256 | ✓ Yes | Partially (Grover) | Secure |
| SHA-384 | ✓ Yes | Partially (Grover) | Secure |
| SHA-512 | ✓ Yes | Partially (Grover) | Very Secure |

**Your certificate uses:** _____ → Status: _____

**Note:** Quantum computers reduce hash security by ½:
- SHA-256 (256 bits) → effective 128 bits under Grover's
- SHA-384 (384 bits) → effective 192 bits under Grover's

---

## 📊 Part 4: Alternative Names (SAN)

### Question 4.1: Subject Alternative Names

ค้นหา `Subject Alternative Name:` (ถ้ามี):

**DNS Names:**
1. _______________________________
2. _______________________________
3. _______________________________

**คำถาม:** ทำไมต้องมี SAN?
- [ ] เพื่อใช้ใบรับรองเดียวกับหลาย domain (เช่น example.com, www.example.com)
- [ ] เพื่อความปลอดภัย
- [ ] ไม่รู้

---

## 🧪 Part 5: Key Usage Extensions

### Question 5.1: Key Usage

ค้นหา `Key Usage:` และ `Extended Key Usage:`:

**Key Usage:**
- [ ] Digital Signature
- [ ] Key Encipherment
- [ ] Data Encipherment
- [ ] Key Agreement
- [ ] Certificate Sign
- [ ] CRL Sign

**Extended Key Usage:**
- [ ] TLS Web Server Authentication
- [ ] TLS Web Client Authentication
- [ ] Code Signing
- [ ] Email Protection

**คำถาม:** ใบรับรองนี้ถูกจำกัดให้ใช้สำหรับอะไร?
_______________________________________________________________

---

## 🎯 Part 6: Summary & Risk Assessment

### Risk Matrix

จากการวิเคราะห์ใบรับรอง ให้ประเมินความเสี่ยงในแต่ละด้าน:

| Risk Factor | Value Found | Risk Level | Notes |
|-------------|-------------|------------|-------|
| Algorithm | | [ ] Low [ ] Medium [ ] High | |
| Key Size | | [ ] Low [ ] Medium [ ] High | |
| Hash Function | | [ ] Low [ ] Medium [ ] High | |
| Quantum Vulnerable? | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High | |
| Certificate Age | | [ ] Low [ ] Medium [ ] High | |

**Overall Risk:** [ ] Low [ ] Medium [ ] High

---

### Recommendation

**ถ้าคุณเป็น Security Officer คุณจะแนะนำอะไร?**

[ ] ใช้งานต่อได้ (ปลอดภัย)  
[ ] ต้องวางแผนอัปเกรด (เสี่ยงปานกลาง)  
[ ] ต้องเปลี่ยนทันที (เสี่ยงสูง)

**เหตุผล:**
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

**การแก้ไขที่แนะนำ:**
1. _____________________________________________________________
2. _____________________________________________________________
3. _____________________________________________________________

---

## ✅ Checkpoint

ก่อนส่งแบบฝึกหัด ตรวจสอบว่าคุณได้:

- [ ] บันทึกข้อมูล Subject และ Issuer ครบถ้วน
- [ ] ระบุ Algorithm และ Key Size ได้
- [ ] ประเมินความเสี่ยงจาก Quantum Threat
- [ ] วิเคราะห์ Signature Algorithm (Hash + Signing)
- [ ] ให้คำแนะนำการแก้ไข (ถ้ามีความเสี่ยง)

---

<div align="center">

**Next:** [Cipher Suite Enumeration Worksheet →](cipher-enumeration.md)

[← Back to Lab 01](../README.md)

</div>
