# Risk Assessment Worksheet
# แบบฝึกหัด: การประเมินความเสี่ยง Quantum Threat

**Lab:** 01-Manual Discovery  
**Student Name:** _________________________  
**Organization:** _________________________ (สมมติ)  
**Date:** _________________________

---

## 📋 Objective

ประเมินความเสี่ยงจากภัยคุกคาม Quantum Computer ต่อระบบ TLS ขององค์กรของคุณ (สมมติ)

---

## 🎯 Part 1: Asset Inventory

### Data Classification

จากข้อมูลที่ Target Application (Lab 00) จัดเก็บ ให้จำแนกตามความสำคัญ:

| Data Type | Classification | Retention Period | Sensitivity |
|-----------|----------------|------------------|-------------|
| User credentials | [ ] Public [ ] Internal [ ] Confidential [ ] Secret | _____ years | [ ] Low [ ] Medium [ ] High |
| Financial transactions | [ ] Public [ ] Internal [ ] Confidential [ ] Secret | _____ years | [ ] Low [ ] Medium [ ] High |
| Personal information | [ ] Public [ ] Internal [ ] Confidential [ ] Secret | _____ years | [ ] Low [ ] Medium [ ] High |
| Medical records | [ ] Public [ ] Internal [ ] Confidential [ ] Secret | _____ years | [ ] Low [ ] Medium [ ] High |
| State secrets | [ ] Public [ ] Internal [ ] Confidential [ ] Secret | _____ years | [ ] Low [ ] Medium [ ] High |

---

### Critical Services

ระบุ service ที่ใช้ TLS:

| Service | Importance | Users | Current TLS Config |
|---------|------------|-------|-------------------|
| Web portal | [ ] Critical [ ] Important [ ] Normal | | RSA-2048, TLS 1.2 |
| VPN access | [ ] Critical [ ] Important [ ] Normal | | |
| Email (SMTP/IMAP) | [ ] Critical [ ] Important [ ] Normal | | |
| API gateway | [ ] Critical [ ] Important [ ] Normal | | |
| Database replication | [ ] Critical [ ] Important [ ] Normal | | |

---

## ⚠️ Part 2: Threat Analysis

### Quantum Timeline Assessment

**คำถาม:** เมื่อไหร่ที่ Quantum Computer จะมีกำลังเพียงพอที่จะ break RSA-2048?

Based on expert predictions:
- [ ] 2025-2030 (pessimistic / near-term)
- [ ] 2030-2035 (most likely)
- [ ] 2035-2040 (optimistic)
- [ ] 2040+ (very optimistic)

**Your assessment:** ________ (year)

**Justification:**
_______________________________________________________________
_______________________________________________________________

---

### "Harvest Now, Decrypt Later" Risk

**Scenario:** Adversary records encrypted traffic TODAY to decrypt in the future when quantum computers are available.

**คำถาม:** ข้อมูลของคุณมีค่าพอที่ adversary จะเก็บไว้หรือไม่?

| Data Type | Still Valuable in 10 Years? | Risk Level |
|-----------|----------------------------|------------|
| User passwords | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High |
| Financial records | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High |
| Medical data | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High |
| Trade secrets | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High |
| State documents | [ ] Yes [ ] No | [ ] Low [ ] Medium [ ] High |

**Overall "Harvest Now" Risk:** [ ] Low [ ] Medium [ ] High [ ] Critical

---

### Adversary Capability

**คำถาม:** ใครคือ adversary ที่น่ากังวลที่สุดสำหรับองค์กรของคุณ?

- [ ] Nation-state actors (มีทรัพยากรสูง, เป้าหมายระยะยาว)
- [ ] Organized crime (มุ่งเน้นผลกำไร, เป้าหมายระยะสั้น)
- [ ] Hacktivists (มุ่งเน้นชื่อเสียง, opportunistic)
- [ ] Insider threats (มีสิทธิ์เข้าถึงอยู่แล้ว)
- [ ] Script kiddies (ความสามารถต่ำ)

**Your assessment:** ___________________________

**Justification:**
_______________________________________________________________
_______________________________________________________________

**คำถาม:** Adversary กลุ่มนี้มีความสามารถในการสร้าง/เข้าถึง Quantum Computer หรือไม่?

- [ ] Yes, definitely (nation-state with quantum research program)
- [ ] Possibly (could purchase access to quantum cloud services)
- [ ] Unlikely (limited resources)
- [ ] No (no technical capability)

---

## 📊 Part 3: Vulnerability Assessment

### Current Configuration Vulnerabilities

จากการทำ Lab 01 (Certificate Analysis + Cipher Enumeration):

**Vulnerable Components:**

| Component | Algorithm | Quantum Vulnerable? | Break Time (Quantum) | Priority |
|-----------|-----------|---------------------|----------------------|----------|
| Certificate | RSA-2048 | [ ] Yes [ ] No | _____ hours/days | [ ] P1 [ ] P2 [ ] P3 |
| Key Exchange | ECDHE P-256 | [ ] Yes [ ] No | _____ hours/days | [ ] P1 [ ] P2 [ ] P3 |
| Signature | ECDSA P-256 | [ ] Yes [ ] No | _____ hours/days | [ ] P1 [ ] P2 [ ] P3 |
| Encryption | AES-256 | [ ] Yes [ ] No | Still secure (Grover reduces to 128-bit) | [ ] P1 [ ] P2 [ ] P3 |
| Hash | SHA-256 | [ ] Yes [ ] No | Still secure (Grover) | [ ] P1 [ ] P2 [ ] P3 |

**Most Critical Vulnerability:** ___________________________

**Reason:** _________________________________________________

---

### Exposure Assessment

**คำถาม:** ระบบของคุณ exposed ต่อ internet อย่างไร?

- [ ] Publicly accessible (anyone can connect)
- [ ] VPN-protected (must authenticate first)
- [ ] Internal only (no internet exposure)
- [ ] Segmented (some public, some internal)

**Traffic Volume:**
- Daily TLS connections: ~___________
- Data transmitted per day: ~___________ GB
- Peak traffic time: ___________

**Logging & Retention:**
- [ ] TLS traffic is logged
- [ ] Logs are encrypted
- [ ] Logs retention period: _____ days/months/years

**Risk:** หากมี adversary บันทึก traffic ทั้งหมด จะได้ข้อมูลเท่าไหร่?
_______________________________________________________________

---

## 🎲 Part 4: Risk Matrix

### Calculate Risk Score

**Risk = Likelihood × Impact**

#### Likelihood Assessment

**คำถาม:** แนวโน้มที่ข้อมูลของคุณจะถูกโจมตีด้วย Quantum Computer:

| Factor | Score (1-5) | Weight | Weighted Score |
|--------|-------------|--------|----------------|
| Quantum timeline (closer = higher) | | 0.3 | |
| Adversary capability (higher = higher) | | 0.3 | |
| Data retention period (longer = higher) | | 0.2 | |
| Exposure level (more exposed = higher) | | 0.2 | |

**Total Likelihood:** _______ / 5.0

---

#### Impact Assessment

**คำถาม:** ผลกระทบหากข้อมูลถูก decrypt ในอนาคต:

| Impact Category | Score (1-5) | Weight | Weighted Score |
|-----------------|-------------|--------|----------------|
| Financial loss (revenue, fines, lawsuits) | | 0.3 | |
| Reputation damage (customer trust) | | 0.2 | |
| Regulatory compliance (GDPR, HIPAA, etc.) | | 0.2 | |
| Operational disruption | | 0.15 | |
| Strategic disadvantage (trade secrets) | | 0.15 | |

**Total Impact:** _______ / 5.0

---

#### Risk Score

```
Risk Score = Likelihood × Impact = _______ × _______ = _______
```

**Risk Level:**
- 0.0 - 5.0: [ ] Low Risk (ติดตามสถานการณ์)
- 5.1 - 12.0: [ ] Medium Risk (วางแผนอัปเกรด)
- 12.1 - 18.0: [ ] High Risk (เริ่มดำเนินการ)
- 18.1 - 25.0: [ ] Critical Risk (ดำเนินการทันที!)

---

## 🛡️ Part 5: Mitigation Strategies

### Migration Options

ประเมินทางเลือกในการแก้ไข:

#### Option 1: Full PQC Migration (Pure Post-Quantum)

**Pros:**
- _______________________________________________________________
- _______________________________________________________________

**Cons:**
- _______________________________________________________________
- _______________________________________________________________

**Feasibility:** [ ] High [ ] Medium [ ] Low  
**Timeline:** _____ months  
**Cost:** $__________

---

#### Option 2: Hybrid Approach (Classical + PQC)

**Pros:**
- _______________________________________________________________
- _______________________________________________________________

**Cons:**
- _______________________________________________________________
- _______________________________________________________________

**Feasibility:** [ ] High [ ] Medium [ ] Low  
**Timeline:** _____ months  
**Cost:** $__________

---

#### Option 3: Do Nothing (Accept Risk)

**Pros:**
- _______________________________________________________________

**Cons:**
- _______________________________________________________________
- _______________________________________________________________

**Feasibility:** [ ] High [ ] Medium [ ] Low  
**Residual Risk:** [ ] Acceptable [ ] Unacceptable

---

### Recommended Approach

**Selection:** [ ] Option 1 [ ] Option 2 [ ] Option 3

**Justification:**
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

---

## 📅 Part 6: Migration Timeline

### Phased Rollout Plan

**Phase 1: Preparation (Months 0-3)**
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________

**Phase 2: Pilot (Months 3-6)**
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________

**Phase 3: Production Rollout (Months 6-12)**
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________

**Phase 4: Full Deployment (Months 12-18)**
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________
- [ ] _______________________________________________________________

---

### Critical Milestones

| Milestone | Target Date | Success Criteria |
|-----------|-------------|------------------|
| | | |
| | | |
| | | |

---

## 🎯 Part 7: Final Recommendation

### Executive Summary (1 paragraph)

สรุปภาพรวมความเสี่ยงและคำแนะนำในการแก้ไข:

_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

---

### Key Recommendations (Top 3)

1. **________________________________________________________________**
   
   Timeline: ________  Budget: ________  Priority: [ ] P1 [ ] P2 [ ] P3

2. **________________________________________________________________**
   
   Timeline: ________  Budget: ________  Priority: [ ] P1 [ ] P2 [ ] P3

3. **________________________________________________________________**
   
   Timeline: ________  Budget: ________  Priority: [ ] P1 [ ] P2 [ ] P3

---

### Approval

**Prepared by:** _________________________ Date: _____________

**Reviewed by:** _________________________ Date: _____________

**Approved by:** _________________________ Date: _____________

---

## ✅ Checkpoint

ก่อนส่งแบบฝึกหัด ตรวจสอบว่าคุณได้:

- [ ] จำแนก assets และ data classification
- [ ] ประเมิน quantum timeline
- [ ] วิเคราะห์ "Harvest Now, Decrypt Later" risk
- [ ] คำนวณ risk score (Likelihood × Impact)
- [ ] เปรียบเทียบทางเลือกในการแก้ไข (PQC, Hybrid, Do Nothing)
- [ ] สร้าง migration timeline แบบ phased
- [ ] เขียน executive summary
- [ ] ให้คำแนะนำชัดเจน (Top 3)

---

<div align="center">

**Next:** [Lab 02 - Baseline Testing →](../../02-baseline-testing/README.md)

[← Back to Cipher Enumeration](cipher-enumeration.md) | [← Back to Lab 01](../README.md)

</div>
