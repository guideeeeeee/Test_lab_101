# Self-Test Answers
# เฉลยแบบทดสอบความเข้าใจ

Answers to the self-test questions from the Crypto Basics guide.

---

## ❓ Question 1: Symmetric vs Asymmetric Cryptography

**Question:** What's the difference between symmetric and asymmetric cryptography?

**Answer:**

**Symmetric Cryptography:**
- Uses **ONE key** for both encryption and decryption
- Same key for sender and receiver
- Examples: AES, ChaCha20
- **Fast** (good for bulk data)
- **Problem:** How to share the key securely?

**Asymmetric Cryptography:**
- Uses **TWO keys**: public key (encrypt) and private key (decrypt)
- Different keys for sender and receiver
- Examples: RSA, ECDSA
- **Slower** (used for small data like keys)
- **Benefit:** No need to share private key!

**Real-world use:**
TLS uses **both**:
1. Asymmetric (RSA/ECDHE) to exchange a session key
2. Symmetric (AES) to encrypt the actual data

---

## ❓ Question 2: TLS Key Exchange

**Question:** In TLS, which algorithm is used for key exchange?

**Answer:**

In **classical TLS** (what we use in Lab 00):
- **ECDHE** (Elliptic Curve Diffie-Hellman Ephemeral)
- Or **RSA** key exchange (older, no forward secrecy)

**How ECDHE works:**
1. Client generates random keypair (private, public)
2. Server generates random keypair (private, public)
3. They exchange public keys
4. Both compute **same shared secret** using their private key + other's public key
5. This shared secret becomes the AES session key

**Why ECDHE?**
- ✅ Perfect Forward Secrecy (PFS) - past sessions stay secure even if private key is compromised later
- ✅ Faster than RSA key exchange
- ✅ Smaller keys than RSA

**In PQC TLS** (Lab 03):
- **ML-KEM-768** (post-quantum KEM)
- Often **hybrid**: X25519+ML-KEM-768 (classical + PQC)

---

## ❓ Question 3: Why Not Use AES for Everything?

**Question:** Why can't we just use AES-256 for everything?

**Answer:**

**The Key Distribution Problem!**

AES is symmetric → both parties need the **same key**.

**Scenario:**
```
You:  "I want to send encrypted data to server"
Problem: How do you send the AES key to the server?
         If you send it unencrypted → anyone can intercept it!
         If you encrypt it → what key do you use to encrypt the key? ♾️
```

**Solution:** Use asymmetric crypto (RSA/ECDHE) to **securely exchange** the AES key

**TLS Handshake:**
```
1. Client → Server: "Hello, I want to connect"
2. Server → Client: "Here's my public key (RSA/ECDSA certificate)"
3. Client generates random AES session key
4. Client encrypts session key with server's PUBLIC key
5. Client → Server: [Encrypted session key]
6. Server decrypts with its PRIVATE key
7. Now both have the same AES session key!
8. Use AES for fast bulk encryption
```

**Summary:**
- **Asymmetric (RSA/ECDHE):** Key exchange (slow but solves distribution problem)
- **Symmetric (AES):** Data encryption (fast for large amounts of data)

---

## ❓ Question 4: Shor's Algorithm

**Question:** What will Shor's algorithm break?

**Answer:**

Shor's algorithm breaks **all public-key cryptography based on:**

1. **Integer factorization:**
   - ❌ **RSA** (factoring n = p × q)

2. **Discrete logarithm problem:**
   - ❌ **Diffie-Hellman (DH)**
   - ❌ **Elliptic Curve Diffie-Hellman (ECDH/ECDHE)**
   - ❌ **DSA** (Digital Signature Algorithm)
   - ❌ **ECDSA** (Elliptic Curve DSA)

**What Shor's CANNOT break:**

✅ **Symmetric crypto:** AES, ChaCha20 (Grover's algorithm only weakens by half the bits)
✅ **Hash functions:** SHA-256, SHA-3 (some weakness from Grover's, but still secure)
✅ **Post-Quantum crypto:** ML-KEM, ML-DSA (based on different math problems)

**Time to break RSA-2048:**
- Classical computer: 6.4 quadrillion years
- Quantum computer with Shor's algorithm: **Hours to days** (with ~20M qubits)

**This is why we need PQC!**

---

## ❓ Question 5: Hybrid Cryptography

**Question:** What is "hybrid" cryptography?

**Answer:**

**Hybrid cryptography** means using **classical AND post-quantum algorithms together**.

**Why hybrid instead of pure PQC?**

1. **Defense in depth:** If one algorithm is broken, the other still protects
2. **Conservative approach:** PQC is new (standardized 2024), might have undiscovered weaknesses
3. **Backwards compatibility:** Some old clients don't support PQC yet
4. **Regulatory compliance:** Some standards still require classical algorithms

**Example in TLS:**

**Classical TLS 1.2:**
```
Key Exchange:   ECDHE-P256
Signature:      RSA-2048 or ECDSA-P256
Encryption:     AES-256-GCM
```

**Hybrid TLS 1.3:**
```
Key Exchange:   X25519 + ML-KEM-768      ← Hybrid!
Signature:      ECDSA-P256 + ML-DSA-65   ← Hybrid!
Encryption:     AES-256-GCM              ← Already quantum-resistant
```

**How it works:**
1. Perform classical ECDHE key exchange → get shared secret A
2. Perform PQC ML-KEM key exchange → get shared secret B
3. Combine both secrets: `final_key = KDF(A || B)`
4. Result: Secure against classical AND quantum attacks!

**Commercial examples (2026):**
- **Cloudflare:** X25519Kyber768Draft00
- **Google Chrome:** X25519+Kyber768 in TLS 1.3
- **AWS:** Hybrid KEM in AWS KMS
- **Signal Messenger:** PQXDH (hybrid key agreement)

**In Lab 03, we implement:**
- Key Exchange: **X25519+ML-KEM-768**
- Signature: **ECDSA+ML-DSA-65** (via hybrid certificate)

---

## 🎯 Score Yourself

How many did you get right?

- **5/5:** Excellent! You're ready for the labs
- **4/5:** Good! Review the one you missed
- **3/5:** Review the crypto basics guide once more
- **<3/5:** Please re-read [01-crypto-concepts.md](01-crypto-concepts.md) carefully

---

## 📚 Further Reading

If you want to learn more:

- **Shor's Algorithm explained:** [Quantum Computing for Computer Scientists (YouTube)](https://www.youtube.com/results?search_query=shor%27s+algorithm)
- **TLS 1.3 Handshake:** [RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)
- **Post-Quantum Crypto:** [NIST PQC Project](https://csrc.nist.gov/projects/post-quantum-cryptography)
- **Hybrid TLS:** [IETF Draft: Hybrid Key Exchange in TLS 1.3](https://datatracker.ietf.org/doc/draft-ietf-tls-hybrid-design/)

---

<div align="center">

[← Back to Lab 01](../README.md)

</div>
