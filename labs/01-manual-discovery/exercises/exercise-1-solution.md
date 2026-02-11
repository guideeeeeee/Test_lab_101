# Exercise 1 Solution: Identify the Key Exchange
# เฉลยแบบฝึกหัดที่ 1: การระบุอัลกอริทึมแลกเปลี่ยนคีย์

## Question
What key exchange algorithm is used when connecting to the target app?

## Command
```bash
openssl s_client -connect localhost:443 -brief
```

## Answer

**Key Exchange Algorithm: ECDHE (Elliptic Curve Diffie-Hellman Ephemeral)**

### Sample Output
When you run the command, look for a line like:
```
Protocol version: TLSv1.2
Ciphersuite: ECDHE-RSA-AES256-GCM-SHA384
```

### Explanation

The cipher suite **ECDHE-RSA-AES256-GCM-SHA384** breaks down as:

1. **ECDHE** - Key Exchange (Elliptic Curve Diffie-Hellman Ephemeral)
   - Used to establish a shared secret between client and server
   - Provides forward secrecy
   - **Quantum Vulnerable** ⚠️ - Can be broken by Shor's algorithm

2. **RSA** - Authentication
   - Used to verify server identity (digital signature on key exchange)
   - Based on RSA certificate
   - **Quantum Vulnerable** ⚠️ - Can be broken by Shor's algorithm

3. **AES256-GCM** - Symmetric Encryption
   - Used to encrypt the actual data
   - **Quantum Resistant** ✓ - Grover's algorithm only weakens it (needs AES-256 instead of AES-128)

4. **SHA384** - Message Authentication
   - Used for message integrity (HMAC)
   - **Quantum Resistant** ✓ - Hash functions are less affected

### Why This Matters

- **ECDHE** provides forward secrecy, which is good for classical security
- But it's **quantum-vulnerable** because it relies on the Elliptic Curve Discrete Logarithm Problem
- This is why we need **PQC hybrid mode** in later labs!

### Alternative: RSA Key Exchange

Some older servers might use:
```
TLS_RSA_WITH_AES_256_GCM_SHA384
```

This uses RSA for both authentication AND key exchange, which:
- Is also quantum-vulnerable
- Does NOT provide forward secrecy
- Is being phased out in modern TLS

---

## Next Steps

Continue to Exercise 2 to measure the certificate size, which you'll compare with PQC certificates later!
