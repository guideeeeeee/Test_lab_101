# Post-Quantum Cryptography Introduction
# แนะนำ Post-Quantum Cryptography

## 🎯 What is Post-Quantum Cryptography?

**Post-Quantum Cryptography (PQC)** refers to cryptographic algorithms that are believed to be secure against attacks by both classical and quantum computers.

### Why Do We Need PQC?

Current public-key cryptography (RSA, ECC) relies on mathematical problems that are hard for classical computers:
- **RSA**: Integer factorization
- **ECC**: Elliptic curve discrete logarithm

However, quantum computers can solve these problems efficiently using:
- **Shor's Algorithm**: Breaks RSA and ECC in polynomial time
- **Grover's Algorithm**: Weakens symmetric crypto (AES) but only reduces security by half

```
Classical Computer (2024):
RSA-2048 break time: ~300 trillion years ✅

Quantum Computer (future):
RSA-2048 break time: ~8 hours ⚠️
```

### The Quantum Threat Timeline

```
2019: Google claims "quantum supremacy" (53 qubits)
2023: IBM unveils 1,121-qubit quantum processor
2025: Quantum computers reach ~1,000 logical qubits
2030: Estimates suggest 4,000+ qubits for RSA-2048 break
```

**"Harvest now, decrypt later" attack:**
Adversaries collect encrypted data today and wait for quantum computers to decrypt it later.

---

## 🏆 NIST PQC Standardization

NIST (National Institute of Standards and Technology) ran a multi-year competition to select quantum-resistant algorithms.

### Selected Algorithms (2024)

**For Key Encapsulation (Key Exchange):**
1. **ML-KEM** (Module-Lattice-Based KEM) - formerly Kyber ⭐
   - ML-KEM-512: AES-128 security
   - ML-KEM-768: AES-192 security (recommended)
   - ML-KEM-1024: AES-256 security

**For Digital Signatures:**
1. **ML-DSA** (Module-Lattice-Based Digital Signature) - formerly Dilithium ⭐
   - ML-DSA-44: Small signatures
   - ML-DSA-65: Balanced (recommended)
   - ML-DSA-87: High security

2. **SLH-DSA** (Stateless Hash-based Digital Signature) - formerly SPHINCS+
   - Backup option if lattice-based crypto is compromised

3. **FN-DSA** (Fast-Fourier Lattice-based) - formerly FALCON
   - Compact signatures

---

## 🔐 ML-KEM-768 (Kyber) Explained

### What is ML-KEM?

**ML-KEM (Module-Lattice-Based Key Encapsulation Mechanism)** is used for secure key exchange in TLS.

### How It Works

```
Client                          Server
------                          ------
1. Generate keypair
   (pk, sk) ← KeyGen()
   
2. Send pk ------------------>
                                3. Encapsulate shared secret
                                   (ct, ss) ← Encap(pk)
                                   
4. <-------------------- Send ct
   
5. Decapsulate
   ss ← Decap(ct, sk)
   
6. Both sides now have shared secret 'ss'
```

### Key Sizes (ML-KEM-768)

| Component | Size |
|-----------|------|
| Public Key | 1,184 bytes |
| Private Key | 2,400 bytes |
| Ciphertext | 1,088 bytes |
| Shared Secret | 32 bytes |

Compare to X25519 (classical ECDH):
- Public Key: 32 bytes
- Shared Secret: 32 bytes

**ML-KEM is ~40x larger but still practical!**

### Security Level

ML-KEM-768 provides **AES-192 equivalent security** against:
- Classical attacks: 2^192 operations
- Quantum attacks (using Grover): 2^96 operations

---

## ✍️ ML-DSA-65 (Dilithium) Explained

### What is ML-DSA?

**ML-DSA (Module-Lattice-Based Digital Signature Algorithm)** is used for certificate signing and authentication.

### How It Works

```
Signing:
--------
1. Generate keypair: (pk, sk) ← KeyGen()
2. Sign message: sig ← Sign(sk, message)
3. Distribute (message, sig, pk)

Verification:
-------------
1. Verify: valid? ← Verify(pk, message, sig)
```

### Key Sizes (ML-DSA-65)

| Component | Size |
|-----------|------|
| Public Key | 1,952 bytes |
| Private Key | 4,000 bytes |
| Signature | 3,293 bytes |

Compare to ECDSA P-256:
- Public Key: 64 bytes
- Signature: ~72 bytes

**ML-DSA signatures are ~45x larger!**

### Security Level

ML-DSA-65 provides **AES-192 equivalent security**.

---

## 🧊 Lattice-Based Cryptography Basics

Both ML-KEM and ML-DSA are based on **lattice problems**.

### What is a Lattice?

A lattice is a regular grid of points in n-dimensional space:

```
2D Lattice Example:

    •   •   •   •   •
  
  •   •   •   •   •
  
    •   •   •   •   •
  
  •   •   •   •   •
```

### Hard Problems

**Shortest Vector Problem (SVP):**
Find the shortest non-zero vector in a lattice.

**Learning With Errors (LWE):**
Given noisy linear equations, find the secret vector.

```
Example:
a₁ · s + e₁ = b₁
a₂ · s + e₂ = b₂
...
Find s, given a's, b's, and small errors e
```

These problems are believed to be hard for both classical AND quantum computers!

---

## 📊 Algorithm Comparison

| Feature | RSA-2048 | ECDSA P-256 | ML-KEM-768 | ML-DSA-65 |
|---------|----------|-------------|------------|-----------|
| **Use Case** | Key exchange, Sig | Signatures | Key exchange | Signatures |
| **Public Key** | 256 bytes | 64 bytes | 1,184 bytes | 1,952 bytes |
| **Private Key** | 256 bytes | 32 bytes | 2,400 bytes | 4,000 bytes |
| **Signature/CT** | 256 bytes | 72 bytes | 1,088 bytes | 3,293 bytes |
| **Quantum Safe?** | ❌ No | ❌ No | ✅ Yes | ✅ Yes |
| **Standardized** | ✅ 1977 | ✅ 2000 | ✅ 2024 | ✅ 2024 |
| **Performance** | Slow | Fast | Medium | Medium |

---

## 🎯 Key Takeaways

1. **Quantum computers will break RSA/ECC** (timeline: ~2030-2035)
2. **PQC is quantum-resistant** based on lattice problems
3. **NIST selected ML-KEM and ML-DSA** as primary standards (2024)
4. **ML-KEM = Key exchange** (replaces ECDH)
5. **ML-DSA = Signatures** (replaces RSA/ECDSA)
6. **Larger keys/signatures** but still practical for TLS
7. **Hybrid mode recommended** to mitigate risks

---

## 📚 Further Reading

- [NIST PQC Standardization](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Kyber Specification](https://pq-crystals.org/kyber/)
- [Dilithium Specification](https://pq-crystals.org/dilithium/)
- [Open Quantum Safe Project](https://openquantumsafe.org/)

---

**Next:** [02-hybrid-concept.md](02-hybrid-concept.md) - Learn why hybrid mode is recommended
