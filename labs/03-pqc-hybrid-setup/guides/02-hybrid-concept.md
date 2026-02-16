# Hybrid Cryptography Concept
# แนวคิด Hybrid Cryptography

## 🤔 Why Hybrid?

When transitioning to post-quantum cryptography, we face a dilemma:

### Option 1: Stay Classical Only
```
Risk: Quantum computers will break it
Status: Vulnerable to future attacks
Decision: ❌ Not safe long-term
```

### Option 2: Switch to Pure PQC
```
Risk: PQC algorithms are new (2024 standards)
      What if a flaw is discovered?
Status: Unproven in real-world at scale
Decision: ⚠️ Risky to fully trust
```

### Option 3: Hybrid (Classical + PQC) ✅
```
Security: Safe if EITHER algorithm is secure
Fallback: Classical crypto still works
Migration: Smooth transition path
Decision: ✅ Best of both worlds!
```

---

## 🔐 Hybrid Security Model

### Security Guarantee

```
Hybrid Security = Classical Security ∩ PQC Security

If Classical is broken → PQC protects us
If PQC is broken → Classical protects us
Both must be broken → Then we're vulnerable
```

**Mathematical Property:**
```
P(break_hybrid) = P(break_classical) × P(break_pqc)
```

This multiplicative security is powerful!

---

## 🔑 Hybrid Key Exchange

### How X25519+MLKEM768 Works

```
Client                                Server
------                                ------

1. Generate X25519 keypair
   (pk_ecdh, sk_ecdh) ← X25519.KeyGen()

2. Generate ML-KEM keypair  
   (pk_pqc, sk_pqc) ← MLKEM.KeyGen()

3. Send pk_ecdh, pk_pqc ---------->

                                      4. Generate X25519 secret
                                         ss_ecdh ← X25519.DH(pk_ecdh)
                                      
                                      5. Encapsulate ML-KEM secret
                                         (ct_pqc, ss_pqc) ← MLKEM.Encap(pk_pqc)

6. <---------- Send pk_ecdh', ct_pqc

7. Compute X25519 secret
   ss_ecdh ← X25519.DH(pk_ecdh', sk_ecdh)

8. Decapsulate ML-KEM secret
   ss_pqc ← MLKEM.Decap(ct_pqc, sk_pqc)

9. Combine secrets
   shared_secret = KDF(ss_ecdh || ss_pqc)
```

### Secret Combination Methods

**Method 1: Concatenation + KDF (Recommended)**
```
shared_secret = HKDF(ss_ecdh || ss_pqc, salt, info)
```

**Method 2: XOR**
```
shared_secret = ss_ecdh ⊕ ss_pqc
```

**Method 3: Cascade KDF**
```
k1 = KDF(ss_ecdh)
shared_secret = KDF(k1 || ss_pqc)
```

**Note:** TLS 1.3 uses concatenation + HKDF-Extract

---

## ✍️ Hybrid Signatures

### Dual Certificate Approach

Instead of combining signature algorithms, we serve **multiple certificates**:

```
Server Certificate Chain:

1. Classical Certificate (ECDSA P-256)
   - Widely compatible
   - Works with all clients
   - Quantum-vulnerable

2. PQC Certificate (ML-DSA-65)  
   - Quantum-resistant
   - Only PQC-aware clients use it
   - Larger size

Client selects based on support!
```

### Certificate Negotiation

```
Client Hello:
-------------
Supported Groups: x25519_kyber768, X25519, P-256
Signature Algorithms: mldsa65, ecdsa_secp256r1, rsa_pss_rsae_sha256

Server Hello:
-------------
Selected Group: x25519_kyber768 ✅ Hybrid!
Selected Certificate: mldsa65 ✅ PQC!

(Or falls back to classical if client doesn't support PQC)
```

---

## 📊 Hybrid vs Pure Comparison

### Security Analysis

| Scenario | Classical Only | Pure PQC | Hybrid |
|----------|----------------|----------|--------|
| **No attacks** | ✅ Secure | ✅ Secure | ✅ Secure |
| **Quantum computer exists** | ❌ Broken | ✅ Secure | ✅ Secure |
| **PQC flaw discovered** | ✅ Secure | ❌ Broken | ✅ Secure |
| **Both broken** | ❌ Broken | ❌ Broken | ❌ Broken |

### Performance Impact

| Metric | Classical | Hybrid | Pure PQC |
|--------|-----------|--------|----------|
| **Handshake Time** | 10 ms | 25 ms (+150%) | 20 ms |
| **Certificate Size** | 1 KB | 5 KB (+400%) | 4 KB |
| **Bandwidth** | 2 KB | 6 KB (+200%) | 4 KB |
| **CPU Usage** | Low | Medium | Medium |

**Tradeoff:** 2-3x slower but still acceptable (<50ms total)

---

## 🌐 Real-World Deployment Strategy

### Phase 1: Add Hybrid Support (Now)
```
Server Configuration:
- Enable both classical and hybrid groups
- Serve dual certificates
- Monitor adoption
```

### Phase 2: Prefer Hybrid (2025-2026)
```
Server Configuration:
- Prioritize hybrid in group list
- Still support classical fallback
- Track client capabilities
```

### Phase 3: Hybrid Only (2027-2030)
```
Server Configuration:
- Remove pure classical groups
- Require PQC support
- Drop old clients (if acceptable)
```

### Phase 4: Pure PQC (2030+)
```
Server Configuration:
- Once PQC is proven secure
- Classical crypto deprecated
- Full quantum resistance
```

---

## 🔧 Implementation Examples

### OpenSSL Configuration

```bash
# Classical only (old)
openssl s_client -connect example.com:443 -groups X25519:P-256

# Hybrid (recommended)
openssl s_client -connect example.com:443 -groups x25519_kyber768:X25519

# Pure PQC (future)
openssl s_client -connect example.com:443 -groups kyber768
```

### NGINX Configuration

```nginx
# Hybrid groups (priority order)
ssl_ecdh_curve x25519_kyber768:X25519:P-256;

# Dual certificates
ssl_certificate /path/to/ecdsa.crt;
ssl_certificate_key /path/to/ecdsa.key;
ssl_certificate /path/to/mldsa.crt;
ssl_certificate_key /path/to/mldsa.key;
```

---

## 🎯 Algorithm Pairing Recommendations

### Recommended Hybrid Pairs

**For Key Exchange:**
```
✅ X25519 + ML-KEM-768 (recommended)
   - Balanced security and performance
   - AES-192 equivalent

✅ P-256 + ML-KEM-768 (alternative)
   - More compatible
   - Slightly slower

✅ X25519 + ML-KEM-1024 (high security)
   - AES-256 equivalent
   - Larger and slower
```

**For Signatures:**
```
✅ ECDSA P-256 + ML-DSA-65 (recommended)
   - Balanced
   - ~5KB total certificate

✅ RSA-2048 + ML-DSA-65 (compatible)
   - Better compatibility
   - ~6KB total certificate

⚠️ RSA-2048 + ML-DSA-87 (avoid)
   - Too large (~8KB)
   - Slower
```

---

## ⚠️ Potential Issues

### 1. Middleboxes and Firewalls

Some network equipment may:
- Drop unknown TLS extensions
- Reject large ClientHello messages
- Timeout on slow handshakes

**Solution:** Enable classical fallback

### 2. Certificate Size Limits

Some systems have limits:
- Load balancers: Often 8KB limit
- CDNs: May cache only small certs
- Embedded devices: Memory constraints

**Solution:** Use selective deployment

### 3. Performance on Low-End Devices

PQC operations are CPU-intensive:
- IoT devices may struggle
- Mobile devices drain battery faster
- Embedded systems need optimization

**Solution:** Hardware acceleration or offload to gateway

---

## 📈 Adoption Timeline

```
2024: NIST finalizes ML-KEM and ML-DSA standards
2024-2025: Major vendors add PQC support
      - Chrome, Firefox add hybrid support
      - OpenSSL 3.2+ includes oqs-provider
      - AWS, Cloudflare test PQC
      
2025-2026: Early adopters deploy hybrid
      - Financial institutions
      - Government agencies
      - Critical infrastructure
      
2027-2030: Mainstream adoption
      - Most websites support hybrid
      - PQC becomes default
      
2030+: Classical crypto phase-out
      - Pure PQC becomes standard
      - RSA/ECC deprecated
```

---

## 🎯 Key Takeaways

1. **Hybrid = Classical + PQC** for defense in depth
2. **Security if EITHER is secure** (multiplicative protection)
3. **Smooth migration path** with backward compatibility
4. **Performance cost: 2-3x classical** but acceptable
5. **X25519+MLKEM768 recommended** for key exchange
6. **Dual certificates (ECDSA+MLDSA)** for signatures
7. **Fallback to classical** ensures compatibility
8. **Plan for 5-10 year transition** to pure PQC

---

## 📚 References

- [RFC 9370: Multiple Key Exchanges in TLS 1.3](https://www.rfc-editor.org/rfc/rfc9370)
- [Hybrid Post-Quantum TLS](https://datatracker.ietf.org/doc/draft-ietf-tls-hybrid-design/)
- [Google: CECPQ2 Experiment](https://www.imperialviolet.org/2018/12/12/cecpq2.html)
- [Cloudflare: Post-Quantum for All](https://blog.cloudflare.com/post-quantum-for-all/)

---

**Next:** [03-install-oqs.md](03-install-oqs.md) - Install OpenSSL with PQC support
