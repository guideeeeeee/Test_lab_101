# Cryptography Basics 101
# สารานุกรมการเข้ารหัสขั้นพื้นฐาน

---

## 📘 Introduction | บทนำ

This document provides foundational cryptography knowledge for students with **no prior background**. Essential reading before Lab 01.

เอกสารนี้ให้ความรู้พื้นฐานทาง cryptography สำหรับนักศึกษาที่**ไม่มีพื้นฐานมาก่อน** อ่านก่อน Lab 01

---

## 🔐 What is Cryptography?

**Simple Definition:**
The science of hiding information from unauthorized parties while allowing authorized parties to access it.

**Real-world analogy:**
Like sending a locked box through untrusted mail - only the recipient with the key can open it.

### Three Main Goals

1. **Confidentiality** (ความลับ) - Keep data secret
2. **Integrity** (ความสมบูรณ์) - Detect tampering
3. **Authentication** (การยืนยันตัวตน) - Verify identity

---

## 🔑 Symmetric Cryptography

**Concept:** Same key encrypts and decrypts

```
Alice                          Bob
  |                             |
  | Shared secret key: "cat"    |
  |                             |
  | Encrypt("Hello", "cat")     |
  |-----> "X7$kL2" ------------>|
  |                             |
  |                Decrypt("X7$kL2", "cat")
  |                    = "Hello"|
```

**Problem:** How to share the key securely?

**Examples:**
- AES (Advanced Encryption Standard)
- ChaCha20
- DES (old, deprecated)

**Speed:** Very fast (GBs per second)

---

## 🏛️ Asymmetric (Public Key) Cryptography

**Concept:** Two keys - public (anyone can use) and private (only you have)

```
Bob's Keys:
├── Public Key (🌐 published to world)
│   └── Used to ENCRYPT messages to Bob
└── Private Key (🔒 kept secret)
    └── Used to DECRYPT messages

Example:
Alice encrypts with Bob's PUBLIC key
→ Only Bob's PRIVATE key can decrypt
```

**Analogy:** Public padlock, private key
- Anyone can lock a message in your padlock
- Only you can unlock it

**Examples:**
- RSA (Rivest-Shamir-Adleman)
- ECDSA (Elliptic Curve Digital Signature)
- Diffie-Hellman / ECDHE

**Speed:** Much slower than symmetric

---

## 🤝 How TLS Combines Both

**TLS Handshake:**

```
Client                               Server
  |                                    |
  | 1. "Hello, let's use ECDHE"        |
  |------------------------------------>|
  |                                    |
  | 2. [Server Certificate (RSA)]      |
  |<-----------------------------------|
  | Verify certificate signature       |
  |                                    |
  | 3. Generate shared secret (ECDHE)  |
  |<----------------------------------->|
  | Both compute AES key               |
  |                                    |
  | 4. Encrypt data with AES-256       |
  |<===================================>|
```

**Why?**
- Asymmetric (ECDHE, RSA): Solve key distribution problem
- Symmetric (AES): Fast encryption for bulk data

---

## 📊 Security Levels (Pre-Quantum)

| Algorithm | Key Size | Security (bits) | Breakable by |
|-----------|----------|-----------------|--------------|
| AES-128 | 128 bits | 128 bits | Never (classical) |
| AES-256 | 256 bits | 256 bits | Never (classical) |
| RSA-2048 | 2048 bits | ~112 bits | Supercomputer (years) |
| RSA-4096 | 4096 bits | ~140 bits | Impossible (classical) |
| ECDSA P-256 | 256 bits | ~128 bits | Impossible (classical) |

**"Security bits" explained:**
- 128 bits: 2^128 = 340 undecillion attempts needed
- Classical computer: Would take longer than age of universe

---

## ⚛️ The Quantum Threat

### What Changed?

**Shor's Algorithm (1994):**
Quantum computers can factor large numbers efficiently.

```
Classical computer:
Factor 2048-bit number → 10^9 years

Quantum computer (when available):
Factor 2048-bit number → Hours or days
```

**Result:**
- ❌ RSA → BROKEN
- ❌ ECDHE/ECDSA → BROKEN  
- ⚠️ AES → Weakened (but still okay if you double key size)

### Timeline

```
2020: ~50-100 qubits (noisy)
2024: ~1000 qubits (still noisy) ← We are here
2030: ~10,000 qubits? (error-corrected)
2035+: Million qubits? (breaks RSA-2048)
```

**Why migrate NOW?**
"Harvest now, decrypt later" attack:
- Adversaries record encrypted traffic today
- Decrypt it in 10-20 years when quantum computers exist
- Long-term secrets (medical, financial) at risk!

---

## 🛡️ Post-Quantum Cryptography

**Goal:** Algorithms that quantum computers CAN'T break

### NIST PQC Competition (2016-2024)

After 8 years of evaluation:

**Winners:**
1. **ML-KEM** (Kyber) - Key Exchange
   - Based on lattice problems
   - Quantum computers can't solve efficiently

2. **ML-DSA** (Dilithium) - Digital Signatures
   - Also lattice-based
   - Quantum-resistant

3. **SLH-DSA** (SPHINCS+) - Backup signatures
   - Hash-based

**Standardized:** FIPS 203, 204, 205 (August 2024)

---

## 🔄 Hybrid Cryptography

**Concept:** Use BOTH classical AND post-quantum

```
Hybrid KEM:
Shared Secret = Classical_Secret XOR PQC_Secret
              = (ECDHE result)   XOR  (MLKEM result)

Security:
└─ Secure if AT LEAST ONE is secure
   ├─ If quantum breaks ECDHE → MLKEM saves you
   └─ If flaw found in MLKEM → ECDHE saves you
```

**Best of both worlds!**

---

## 🧮 The Math (Simplified)

### RSA: Factoring Problem

```
Easy direction:
p = 61, q = 53
n = p × q = 3233  ← Fast multiplication

Hard direction:
n = 3233
Find p and q such that p × q = 3233  ← Slow factoring

RSA security: Uses number with 617 digits!
Classical: ~10^18 years to factor
Quantum: ~Hours to factor (Shor's algorithm)
```

### ECDHE: Discrete Logarithm

```
Given: P (base point), Q = k×P (result)
Find: k (secret)

On elliptic curves:
- k×P is easy (repeated addition)
- Finding k from Q is hard

Quantum threat: Shor's algorithm solves this too!
```

### ML-KEM (Kyber): Lattice Problem

```
Problem: Learning With Errors (LWE)
Given: A (matrix), b = A×s + e (with small errors e)
Find: s (secret)

Why quantum-safe?
- No efficient quantum algorithm known
- Lattice problems are hard even for quantum computers
```

---

## 📖 Glossary | อภิธานศัพท์

- **TLS:** Transport Layer Security (HTTPS uses this)
- **Certificate:** Digital ID card for servers
- **CA:** Certificate Authority (issues certificates)
- **Cipher Suite:** Combination of algorithms (e.g., ECDHE-RSA-AES256-GCM-SHA384)
- **Handshake:** Initial negotiation in TLS
- **Forward Secrecy:** Past sessions secure even if long-term key leaked

---

## 🎯 Summary for Lab

**What you need to remember:**

1. **Two types of crypto:**
   - Symmetric (AES) = fast, same key
   - Asymmetric (RSA, ECDHE) = slow, different keys

2. **TLS uses both:**
   - Asymmetric for handshake
   - Symmetric for data

3. **Quantum computers threaten:**
   - RSA (Shor's algorithm)
   - ECDHE (Shor's algorithm)
   - AES is weakened but okay

4. **Solution:**
   - Post-Quantum Crypto (ML-KEM, ML-DSA)
   - Hybrid approach (classical + PQC)

5. **In Lab 01:**
   - You'll scan for RSA and ECDHE (vulnerable!)
   - Identify which need replacement

---

## 📚 Further Reading

**Beginner:**
- Khan Academy: Cryptography Course
- Computerphile: YouTube videos on crypto

**Technical:**
- "Introduction to Modern Cryptography" - Katz & Lindell
- NIST PQC Project: csrc.nist.gov/pqc

**Standards:**
- RFC 8446: TLS 1.3
- FIPS 203: ML-KEM
- FIPS 204: ML-DSA

---

<div align="center">

[← Back to Main](../README.md) | [Lab 01 →](../labs/01-manual-discovery/)

</div>
