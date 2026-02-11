# 2019 TLS Landscape
# ภูมิทัศน์ TLS ในปี 2019

---

## 🗓️ Why 2019 as a Reference Point?

In 2019, the cryptographic landscape represented a **"peak classical security"** moment:

- TLS 1.3 (published 2018) was just beginning adoption
- Post-quantum cryptography was purely academic
- RSA-2048 was industry standard
- ECDHE provided Perfect Forward Secrecy
- AES-256 was considered unbreakable

**This lab uses 2019 as baseline to show *how systems were "secure" before quantum threat*.**

---

## 📊 Typical 2019 Enterprise Configuration

### Web Servers

```
Protocol: TLS 1.2 (95% of sites) or TLS 1.3 (5%)
Certificates: RSA-2048 (85%) or ECDSA P-256 (15%)
Key Exchange: ECDHE (for forward secrecy)
Cipher: AES-256-GCM or ChaCha20-Poly1305
Hash: SHA-256 or SHA-384

Example cipher suite:
TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

### Why These Choices?

1. **TLS 1.2:** Mature, widely supported
2. **RSA-2048:** Balance of security vs performance
3. **ECDHE:** Perfect Forward Secrecy without performance hit
4. **AES-256:** "Military grade" encryption
5. **SHA-384:** Collision-resistant hashing

**All considered "unbreakable" in 2019!**

---

## 🏛️ Industry Standards in 2019

### Mozilla SSL Configuration Generator (2019)

**Modern configuration:**
```
TLS 1.3, TLS 1.2
ECDHE+AESGCM:ECDHE+CHACHA20
ECDSA or RSA certificates
```

**Intermediate configuration:** (most common)
```
TLS 1.2, TLS 1.3
ECDHE-RSA-AES256-GCM-SHA384
ECDHE-RSA-AES128-GCM-SHA256
```

**Old configuration:** (legacy support)
```
TLS 1.0+
Includes RSA key exchange (no forward secrecy)
```

### NIST Recommendations (2019)

| Algorithm | Minimum Key Size | Recommended Until |
|-----------|------------------|-------------------|
| RSA | 2048 bits | 2030 |
| ECDSA | P-256 (256 bits) | 2030 |
| AES | 128 bits | Beyond 2030 |
| SHA-2 | SHA-256 | Beyond 2030 |

**Note:** These assumed NO quantum computers!

---

## 🔒 Security Assumptions (2019)

### What Was "Secure"

✅ **RSA-2048:**
- Would take classical supercomputer 6.4 quadrillion years to break
- NIST approved until 2030

✅ **ECDSA P-256:**
- Equivalent to 128-bit symmetric security  
- More efficient than RSA
- Modern standard

✅ **Perfect Forward Secrecy (ECDHE):**
- Even if server key compromised, past sessions safe
- Best practice since ~2013

✅ **AES-256-GCM:**
- No known practical attacks
- Would require 2^256 operations (impossible)

### What Changed After 2019

- **2019:** NIST PQC Round 2 (still theoretical)
- **2020:** NIST PQC Round 3 finalists announced
- **2022:** NIST selected ML-KEM and ML-DSA
- **2024:** FIPS 203/204 published (standards ready!)
- **2025:** Major vendors beginning PQC deployment
- **2026:** We are here - migration beginning

---

## 🌐 Real-World Examples (circa 2019)

### Major Websites

**Google.com:**
```
TLS 1.3
ECDHE_RSA
AES_128_GCM
```

**Amazon.com:**
```
TLS 1.2
ECDHE_RSA
AES_256_GCM_SHA384
```

**Banks (typical):**
```
TLS 1.2 only (avoid 1.3 until mature)
ECDHE-RSA-AES256-GCM-SHA384
Extended Validation (EV) certificates
```

---

## 📉 What Would Attackers Need? (2019)

### To Break RSA-2048:

**Classical computer:**
- Need: Thousands of CPU-years
- Cost: Billions of dollars
- Result: Not economically feasible

**Quantum computer:**
- Status in 2019: ~50 qubits (very noisy)
- Needed: ~20 million qubits (error-corrected)
- Timeline: 15-30 years away?

**Conclusion:** RSA-2048 safe for foreseeable future ✓

### To Break AES-256:

**Classical brute force:**
- Need: Try 2^256 keys
- Time: 10^50 years (heat death of universe: 10^14 years)
- Result: Physically impossible

**Quantum (Grover's algorithm):**
- Reduces to 2^128 operations
- Still: 10^25 years
- Result: Still practically impossible

**Conclusion:** AES-256 safe forever ✓

---

## ⚠️ The "Harvest Now, Decrypt Later" Threat

### What Changed the Calculus?

**2019 thinking:**
"Quantum computers are decades away, no need to worry now."

**Current reality (2026):**
"Adversaries are recording encrypted traffic TODAY to decrypt in 10-15 years."

### Threat Model

```
2024: Adversary records TLS session (RSA-2048)
      └─ Data encrypted, safe for now

2035: Quantum computer available
      ├─ Adversary breaks RSA-2048
      ├─ Recovers session key
      └─ Decrypts 2024 data retroactively

Impact: Medical records, financial data, state secrets compromised
```

**This is why we migrate NOW even though quantum computers don't exist yet!**

---

## 🔄 Evolution Timeline

```
2008: TLS 1.2 published
2013: Snowden revelations → Push for Perfect Forward Secrecy
2015: Major sites adopt ECDHE
2016: NIST launches PQC competition
2018: TLS 1.3 published (removes RSA key exchange)
2019: ← Our baseline (peak classical security)
2020: COVID accelerates cloud/VPN adoption
2022: NIST PQC winners announced
2024: FIPS 203/204 published
2025: Vendors add PQC support
2026: Migration begins (← We are here)
2030: NIST deadline for federal systems
```

---

## 📚 Why This Matters for the Lab

### Educational Value

1. **See "secure" systems:** Experience what was best practice
2. **Measure baseline:** Compare against PQC overhead
3. **Understand migration:** Why organizations are changing
4. **Realistic testing:** Production systems still use 2019 config

### Technical Realism

Most production systems TODAY (2026) still use 2019-style config:
- RSA-2048 certificates everywhere
- TLS 1.2 widely deployed
- Slow PQC adoption

**Your lab simulates REAL migration path organizations face!**

---

## 🎯 Summary

**2019 = Peak Classical Security**
- RSA-2048: Industry standard
- ECDHE: Perfect Forward Secrecy
- AES-256: "Unbreakable"
- TLS 1.2/1.3: Mature protocols

**2026 = Transition Era**
- Quantum threat recognized
- Standards available (FIPS 203/204)
- Migration beginning
- Hybrid approach emerging

**2030+ = Post-Quantum Era**
- PQC widespread
- Quantum computers practical
- Classical-only considered insecure

---

<div align="center">

[← Back to Docs](README.md) | [Crypto Basics →](crypto-basics-101.md)

</div>
