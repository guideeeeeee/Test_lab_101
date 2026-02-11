# The Quantum Threat to Cryptography
# ภัยคุกคามจาก Quantum Computer ต่อการเข้ารหัส

⏱️ **Reading time:** 8-10 minutes

---

## 🔬 What are Quantum Computers?

### Classical vs Quantum

**Classical computers** (your laptop, servers):
- Use bits: 0 or 1
- Process sequentially
- Fast at many things, but struggle with certain math problems

**Quantum computers**:
- Use **qubits**: can be 0, 1, or *both simultaneously* (superposition)
- Perform many calculations in parallel
- Excellent at specific problems (like factoring large numbers)

```
Classical Bit:  [0] or [1]
Quantum Qubit:  [0 + 1]  ← Both states at once!
```

---

## ⚡ Shor's Algorithm: The RSA Killer

### What RSA Relies On

RSA security depends on this fact:
```
Easy:    Multiply two large primes:  67 × 61 = 4,087
Hard:    Factor back to primes:      4,087 = ?? × ??
```

**Classical computer:** Would take 6.4 quadrillion years to factor RSA-2048
**Quantum computer with Shor's algorithm:** Could do it in hours!

### How Shor's Algorithm Works (Simplified)

1. **Convert factoring to period-finding problem**
2. **Use quantum superposition** to test many periods simultaneously
3. **Quantum Fourier Transform** to find the period
4. **Calculate factors** from the period

**Time complexity:**
- Classical: O(e^n) - exponential (impossible for large numbers)
- Quantum (Shor): O(n³) - polynomial (feasible!)

---

## 💥 What Shor's Algorithm Breaks

| Algorithm | Used For | Quantum Vulnerable? | Break Time |
|-----------|----------|---------------------|------------|
| **RSA** | Signatures, Key Exchange | ✅ YES | Hours |
| **ECDSA** | Signatures | ✅ YES | Hours |
| **ECDHE** | Key Exchange | ✅ YES | Hours |
| **DSA** | Signatures | ✅ YES | Hours |
| **DH** | Key Exchange | ✅ YES | Hours |

**Bottom line:** All public-key crypto based on factoring or discrete logarithm is broken!

---

## 🔐 Grover's Algorithm: The AES Weakener

### What AES Relies On

AES security depends on:
```
Try all possible keys:  2^256 combinations for AES-256
Classical computer:     Physically impossible (10^50 years)
```

### How Grover's Algorithm Works

Grover's algorithm can search an unsorted database in **√N** time instead of N.

**Impact on AES:**
- AES-256: 2²⁵⁶ → 2¹²⁸ effective security (still secure!)
- AES-128: 2¹²⁸ → 2⁶⁴ effective security (potentially vulnerable)

**Conclusion:** AES-256 remains secure even against quantum computers!

---

## 📅 Timeline: When Will This Happen?

### Current State (2026)

- **Largest quantum computers:** ~1,000 qubits (very noisy)
- **Needed to break RSA-2048:** ~20 million error-corrected qubits
- **Consensus:** 10-15 years away for practical cryptanalysis

### Expert Predictions

| Source | Prediction | Confidence |
|--------|------------|------------|
| **NSA** | 2030-2035 | Medium |
| **NIST** | 2030-2040 | Medium-High |
| **Industry (Google, IBM)** | 2035-2040 | Medium |
| **Pessimistic estimates** | 2025-2030 | Low |
| **Optimistic estimates** | 2040+ | Low |

---

## ⚠️ "Harvest Now, Decrypt Later" Attack

### The Real Threat is NOW!

Even if quantum computers are 10 years away, adversaries can:

```
┌─────────────────────────────────────────────────────────┐
│ YEAR 2024-2026: Harvest Phase                          │
├─────────────────────────────────────────────────────────┤
│ Adversary records ALL encrypted traffic                 │
│ ├─ TLS sessions (RSA-2048 key exchange)                │
│ ├─ VPN tunnels                                          │
│ ├─ Encrypted backups                                    │
│ └─ Even if data is "secure" today                      │
└─────────────────────────────────────────────────────────┘
              ↓ Store encrypted data
              ↓ Wait 10-15 years...
┌─────────────────────────────────────────────────────────┐
│ YEAR 2035-2040: Decrypt Phase                          │
├─────────────────────────────────────────────────────────┤
│ Quantum computer becomes available                      │
│ ├─ Run Shor's algorithm on stored data                 │
│ ├─ Break RSA-2048 in hours                             │
│ ├─ Recover session keys                                │
│ └─ Decrypt all historic traffic                        │
└─────────────────────────────────────────────────────────┘
```

**Impact:**
- Medical records exposed (10 years later)
- Financial data compromised
- State secrets revealed
- Personal privacy destroyed

**This is why we need PQC migration NOW, not in 10 years!**

---

## 🛡️ Post-Quantum Cryptography (PQC)

### What Makes PQC Different?

PQC algorithms are based on math problems that are hard for BOTH classical and quantum computers:

| Problem | PQC Algorithm Family | Example |
|---------|---------------------|---------|
| **Lattice problems** | Ideal lattices | Kyber (ML-KEM), Dilithium (ML-DSA) |
| **Code-based** | Error-correcting codes | Classic McEliece |
| **Multivariate** | Polynomial equations | Rainbow (deprecated) |
| **Hash-based** | Merkle trees | SPHINCS+ |
| **Isogeny-based** | Elliptic curve isogenies | SIKE (broken!) |

---

## 🏆 NIST PQC Competition Winners (2022-2024)

### Selected Algorithms

**For Key Exchange (KEM):**
- ✅ **Kyber** → Renamed **ML-KEM** (FIPS 203)
  - Security: Based on Module-LWE (lattice problem)
  - Variants: ML-KEM-512, ML-KEM-768, ML-KEM-1024

**For Signatures:**
- ✅ **Dilithium** → Renamed **ML-DSA** (FIPS 204)
  - Security: Based on Module-LIS (lattice problem)
  - Variants: ML-DSA-44, ML-DSA-65, ML-DSA-87
  
- ✅ **Falcon** → **FN-DSA** (FIPS 205)
  - Smaller signatures, but more complex

- ✅ **SPHINCS+** → **SLH-DSA** (FIPS 206)
  - Hash-based, very conservative

---

## 🔄 Hybrid Approach: Best of Both Worlds

### Why Hybrid?

Instead of replacing RSA completely, we combine classical + PQC:

```
Hybrid Key Exchange:  X25519 + ML-KEM-768
                        ↓         ↓
                    Classical   PQC
                        ↓         ↓
                    Secure today + Quantum-safe future
```

**Benefits:**
- If PQC is broken → Classical crypto still protects
- If Quantum breaks classical → PQC protects
- **Maximum security!**

---

## 📊 Performance Impact: Classical vs PQC

| Metric | RSA-2048 | ECDSA P-256 | ML-DSA-65 | ML-KEM-768 |
|--------|----------|-------------|-----------|------------|
| **Public Key** | 256 bytes | 64 bytes | 1,952 bytes | 1,184 bytes |
| **Signature** | 256 bytes | 64 bytes | 3,309 bytes | N/A |
| **Ciphertext** | 256 bytes | N/A | N/A | 1,088 bytes |
| **Key Gen** | 100 ms | 2 ms | 5 ms | 0.5 ms |
| **Sign/Encaps** | 10 ms | 1 ms | 8 ms | 0.3 ms |
| **Verify/Decaps** | 1 ms | 2 ms | 3 ms | 0.4 ms |

**Tradeoffs:**
- ✅ PQC is often FASTER at operations
- ❌ PQC has LARGER key/signature sizes
- ⚖️ Net result: 10-30% overhead in TLS handshake

---

## 🎯 Summary

### Key Takeaways

1. **Quantum computers will break RSA, ECDSA, ECDHE** (via Shor's algorithm)
2. **AES-256 remains secure** (Grover's only weakens, doesn't break)
3. **Threat is NOW** ("Harvest Now, Decrypt Later" attack)
4. **NIST has standardized PQC** (ML-KEM, ML-DSA)
5. **Hybrid approach** combines classical + PQC for maximum security
6. **Migration must begin immediately** to protect long-term sensitive data

---

## ❓ Quiz Yourself

Before continuing, make sure you can answer:

1. **What math problem does RSA security depend on?**
   <details><summary>Answer</summary>Integer factorization (hard for classical, easy for quantum)</details>

2. **Can quantum computers break AES-256?**
   <details><summary>Answer</summary>No, Grover's only reduces to 128-bit effective security (still secure)</details>

3. **What is "Harvest Now, Decrypt Later"?**
   <details><summary>Answer</summary>Recording encrypted traffic today to decrypt when quantum computers are available</details>

4. **What does "hybrid" cryptography mean?**
   <details><summary>Answer</summary>Combining classical (RSA/ECDSA) with PQC (ML-KEM/ML-DSA) for layered security</details>

5. **What is ML-KEM-768?**
   <details><summary>Answer</summary>NIST's post-quantum key exchange algorithm (formerly Kyber-768), FIPS 203</details>

---

<div align="center">

[← Back to Crypto Concepts](01-crypto-concepts.md) | [Next: OpenSSL Basics →](03-openssl-basics.md)

[← Back to Lab 01](../README.md)

</div>
