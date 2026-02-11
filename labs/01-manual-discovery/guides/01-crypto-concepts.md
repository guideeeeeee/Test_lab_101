# Cryptography Concepts 101
# พื้นฐานการเข้ารหัสลับสำหรับผู้เริ่มต้น

⏱️ **Reading time:** 10-12 minutes  
🎯 **Goal:** Understand crypto fundamentals with **zero prior knowledge**

---

## 🔐 What is Cryptography? | การเข้ารหัสลับคืออะไร?

**Simple definition:**  
Cryptography is the science of **secret communication** - making messages unreadable to everyone except the intended recipient.

**นิยามง่ายๆ:**  
การเข้ารหัสลับคือวิทยาศาสตร์ของ **การสื่อสารที่เป็นความลับ** - ทำให้ข้อความอ่านไม่ได้สำหรับทุกคน ยกเว้นผู้รับที่ต้องการ

### Everyday Example | ตัวอย่างในชีวิตประจำวัน

```
You want to send:  "My password is 123456"
After encryption:  "Xk2$mL9@pQzR#7vN4"
Attacker sees:     "Xk2$mL9@pQzR#7vN4"  ← Looks like gibberish!
Your friend gets:  "My password is 123456"  ← Decrypted with key
```

---

## 🔑 Two Main Types | สองประเภทหลัก

### 1. Symmetric Cryptography (เข้ารหัสแบบสมมาตร)

**Same key** for encryption and decryption | ใช้ **คีย์เดียวกัน** เข้ารหัส-ถอดรหัส

```
┌─────────┐           ┌─────────┐           ┌─────────┐
│  Alice  │           │   Key   │           │   Bob   │
│         │           │  🔑     │           │         │
│  Hello  │ ─Encrypt→ │ secret  │ ─Decrypt→ │  Hello  │
│         │   🔒      │         │   🔓      │         │
└─────────┘           └─────────┘           └─────────┘

Problem: How do Alice and Bob share the key securely?
ปัญหา: Alice กับ Bob จะแชร์คีย์กันอย่างปลอดภัยได้ยังไง?
```

**Examples:** AES, ChaCha20, DES (old)  
**Speed:** ⚡⚡⚡ Very fast  
**Use for:** Encrypting large amounts of data

### 2. Asymmetric Cryptography (เข้ารหัสแบบอสมมาตร)

**Different keys** - Public Key (anyone can use) + Private Key (only you have)  
**คีย์ต่างกัน** - Public Key (ใครก็ใช้ได้) + Private Key (มีแค่คุณ)

```
         Alice                           Bob
    ┌──────────────┐              ┌──────────────┐
    │ Public Key   │ 🌐          │ Public Key   │ 🌐
    │ (everyone)   │              │ (everyone)   │
    ├──────────────┤              ├──────────────┤
    │ Private Key  │ 🔒          │ Private Key  │ 🔒
    │ (secret!)    │              │ (secret!)    │
    └──────────────┘              └──────────────┘

Alice encrypts with Bob's PUBLIC key → Only Bob's PRIVATE key can decrypt
Alice เข้ารหัสด้วย Public key ของ Bob → ถอดรหัสได้แค่ Private key ของ Bob
```

**Examples:** RSA, ECDSA, DSA  
**Speed:** 🐌 Much slower than symmetric  
**Use for:** Key exchange, digital signatures

---

## 🏛️ Three Pillars of TLS | สามเสาหลักของ TLS

TLS (the "S" in HTTPS) uses cryptography for three purposes:

### 1. Encryption (ความลับ) - Confidentiality

**Goal:** Prevent eavesdropping | ป้องกันการดักฟัง

```
Without encryption:
Attacker sees: "username=admin&password=secret123"  ❌

With encryption:
Attacker sees: "aR7$kL2@mX9#qP4..."  ✅ Unreadable!
```

**In TLS:** Uses **AES-256-GCM** (symmetric cipher)

### 2. Authentication (การยืนยันตัวตน) 

**Goal:** Prove identity | พิสูจน์ว่าเป็นตัวจริง

```
Without authentication:
You think you're connecting to: yourbank.com
Actually connecting to:         evilbank.com  ❌

With authentication (certificate):
Server proves: "I am really yourbank.com"
Signed by trusted authority ✅
```

**In TLS:** Uses **RSA or ECDSA signatures** on certificates

### 3. Integrity (ความสมบูรณ์)

**Goal:** Detect tampering | ตรวจจับการแก้ไข

```
Without integrity:
Attacker changes: "Transfer $100" → "Transfer $10000"  ❌

With integrity (hash/MAC):
Hash of original: "7a2f..."
Hash of modified: "9k1m..."  ← Different! Rejected! ✅
```

**In TLS:** Uses **SHA-256/384** hashing

---

## 🌐 How TLS Uses All Three | แกน TLS ใช้ทั้งสามอย่างไร

### TLS Handshake Process (Simplified):

```
1. 🤝 Key Exchange (Asymmetric)
   Client & Server agree on a shared symmetric key
   Uses: ECDHE or RSA
   Why asymmetric? Can't share symmetric key over insecure channel!

2. 📜 Authentication (Asymmetric) 
   Server proves identity with certificate
   Uses: RSA or ECDSA signature
   Signed by trusted Certificate Authority (CA)

3. 🔐 Bulk Encryption (Symmetric)
   All application data encrypted with shared key
   Uses: AES-256-GCM
   Why symmetric? Fast enough for streaming data!

4. ✅ Integrity (Hash)
   Each message tagged with HMAC
   Uses: SHA-256 or SHA-384
   Detects any bit flips or tampering
```

### Example: Browsing https://yourbank.com

```
Step 1: Browser says "Let's use ECDHE for key exchange"
Step 2: Server sends certificate (signed with RSA)
Step 3: Browser verifies: "Certificate signed by TrustCorp CA ✓"
Step 4: Both sides compute shared AES key using ECDHE
Step 5: All data encrypted with AES-256-GCM
Step 6: Each packet tagged with SHA-384 HMAC

Result: 🔒 Confidential, Authenticated, Tamper-proof communication
```

---

## 🔢 The Math (Don't Worry, We'll Keep It Simple!)

### RSA: Based on Factoring Large Numbers

```
Easy:    123 × 456 = 56,088  ← Multiplication is fast
Hard:    56,088 = ? × ?      ← Factoring is slow


Real RSA uses HUGE numbers:
Small number:  123
RSA-2048:      2^2048 ≈ 10^617  ← A number with 617 digits!

Breaking RSA = Factoring this huge number
Classical computer: Would take millions of years
Quantum computer: Could do it in hours! ⚠️
```

### ECDHE: Based on Elliptic Curve Math

```
Problem: Given point P and result Q = k×P, find k
         (k is the secret key)

On elliptic curves:
- Multiplication (k×P) is easy
- Reverse (finding k from Q) is hard

Quantum threat: Shor's algorithm can reverse this! ⚠️
```

---

## 🧩 Real-World TLS Cipher Suite

When you see this:
```
ECDHE-RSA-AES256-GCM-SHA384
```

Let's decode it:
```
ECDHE       → Key Exchange (how to agree on symmetric key)
RSA         → Authentication (signature algorithm on certificate)
AES256      → Bulk Encryption (symmetric cipher for data)
GCM         → Mode of Operation (for AES)
SHA384      → Hash function (for integrity/HMAC)

Full meaning: "Use ECDHE for key exchange, RSA to sign certificate,
               AES-256-GCM to encrypt data, SHA-384 for integrity"
```

---

## ⚡ Speed Comparison | เปรียบเทียบความเร็ว

On a typical laptop:

| Operation | Algorithm | Speed |
|-----------|-----------|-------|
| Encrypt 1 MB | **AES-256** | 0.001s ⚡⚡⚡ |
| Encrypt 1 MB | **RSA-2048** | 5.0s 🐌 |
| Sign message | **RSA-2048** | 0.5ms |
| Sign message | **ECDSA P-256** | 0.2ms ⚡ |
| Verify signature | **RSA-2048** | 0.05ms |
| Verify signature | **ECDSA P-256** | 0.4ms |

**That's why TLS uses:**
- Asymmetric (RSA/ECDHE) only for handshake (~1% of time)
- Symmetric (AES) for bulk data (~99% of time)

---

## 🛡️ Security Levels | ระดับความปลอดภัย

### Pre-Quantum Era (Classic Computers):

| Algorithm | Bits | Years to Break | Status |
|-----------|------|----------------|--------|
| AES-128 | 128 | 10^18 years | ✅ Secure |
| AES-256 | 256 | 10^50 years | ✅ Secure |
| RSA-1024 | ~80 bits | Hours (broken!) | ❌ Insecure |
| RSA-2048 | ~112 bits | Centuries | ✅ Secure (for now) |
| ECDSA P-256 | ~128 bits | Centuries | ✅ Secure (for now) |

### Post-Quantum Era (With Quantum Computers):

| Algorithm | Quantum Threat | Reason |
|-----------|----------------|--------|
| AES-128 | ⚠️ **Weakened to 64-bit** | Grover's algorithm |
| AES-256 | ⚠️ **Weakened to 128-bit** | Grover's algorithm (still okay!) |
| RSA-2048 | ❌ **BROKEN** | Shor's algorithm |
| ECDSA/ECDHE | ❌ **BROKEN** | Shor's algorithm | ML-KEM-768 | ✅ **Quantum-safe** | Lattice-based (Shor doesn't work) |

**This is why we need Post-Quantum Cryptography!**

---

## 📝 Quick Self-Test

Try to answer these (answers at bottom):

1. What's used for encrypting bulk data in TLS?
2. What's the main difference between RSA and AES?
3. Why can't we use only RSA for everything?
4. What does "ECDHE" do in a cipher suite?
5. Which is faster: RSA or AES encryption?

---

## 💡 Key Takeaways | สรุปสำคัญ

After reading this, you should understand:

✅ **Symmetric crypto** (AES) = Fast, same key for encrypt/decrypt  
✅ **Asymmetric crypto** (RSA, ECDHE) = Slower, different keys (public/private)  
✅ **TLS uses both**: Asymmetric for handshake, symmetric for data  
✅ **Three goals**: Encryption (confidentiality), Authentication (identity), Integrity (tamper-detection)  
✅ **Quantum threat**: Shor's algorithm breaks RSA and ECDHE  
✅ **Solution**: Post-Quantum Cryptography (ML-KEM, ML-DSA)

---

## 🎯 What's Next?

Now that you understand the basics:

1. Read [02-quantum-threat.md](02-quantum-threat.md) - Why quantum computers threaten current crypto
2. Continue with Lab 01 scanning exercises
3. Identify which algorithms in the target server are vulnerable

---

## 🧠 Self-Test Answers

1. **AES-256-GCM** (symmetric cipher)
2. **RSA is asymmetric** (public/private keys), **AES is symmetric** (same key)
3. **Too slow!** RSA is ~1000x slower than AES
4. **Key exchange** - agree on a shared symmetric key securely
5. **AES** is much faster (~1000x)

---

<div align="center">

[← Back to Lab 01](../README.md) | [Next: Quantum Threat →](02-quantum-threat.md)

</div>
