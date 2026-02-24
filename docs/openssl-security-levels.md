# OpenSSL Security Levels - Understanding "Key Too Small" Error
# การทำความเข้าใจ Security Levels ของ OpenSSL

⏱️ **Reading Time:** 5 minutes  
🎯 **Audience:** Students encountering "DH key too small" errors

---

## 🔒 What are OpenSSL Security Levels?

Starting with **OpenSSL 1.1.0** (and enforced stricter in 3.x), OpenSSL introduced **security levels** to protect against weak cryptography automatically.

### Security Level Comparison

| Level | Min RSA/DSA | Min DH | Min ECC | Use Case |
|-------|-------------|--------|---------|----------|
| **0** | None | None | None | ⚠️ Labs only - NO restrictions |
| **1** | 1024 bits | 1024 bits | 160 bits | 🧪 Vulnerable demos |
| **2** | 2048 bits | 2048 bits | 224 bits | ✅ **Default** - Production |
| **3** | 3072 bits | 3072 bits | 256 bits | 🔐 High security |
| **4** | 7680 bits | 7680 bits | 384 bits | 🏛️ Government/Critical |
| **5** | 15360 bits | 15360 bits | 512 bits | 🚀 Extreme paranoia |

**Default in OpenSSL 3.x: Level 2** → Requires minimum 2048-bit keys

---

## ❌ The "Key Too Small" Error

### When You See This:

```
error:0A00018E:SSL routines::dh key too small
error:1408518A:SSL routines:ssl3_ctx_ctrl:dh key too small
```

### What It Means:

OpenSSL **blocked** your connection because:
- DH parameters < 2048 bits (at SECLEVEL=2)
- Or RSA certificate < 2048 bits
- Or using weak ciphers (MD5, SHA1 in some contexts)

### Why This Happens in Our Lab:

We're trying to **demonstrate vulnerabilities** found in real servers (like Supreme.swu.ac.th) that use:
- ❌ 1024-bit DH parameters (considered weak since ~2015)
- ❌ Old TLS 1.0/1.1 protocols
- ❌ Weak ciphers (3DES, CBC)

---

## ✅ Solutions for Lab Environment

### Solution 1: Lower Security Level (Recommended for Lab)

**In NGINX config:**

```nginx
# Add @SECLEVEL=1 to your cipher string
ssl_ciphers 'YOUR_CIPHERS@SECLEVEL=1';

# Example:
ssl_ciphers 'DHE-RSA-AES256-SHA:AES256-SHA:DES-CBC3-SHA@SECLEVEL=1';
```

**What this does:**
- Allows 1024-bit DH parameters
- Allows weak ciphers needed for vulnerability demos
- Still safer than `@SECLEVEL=0`

### Solution 2: Use OpenSSL Config File

**Create `/etc/ssl/openssl-lab.cnf`:**

```ini
openssl_conf = openssl_init

[openssl_init]
ssl_conf = ssl_sect

[ssl_sect]
system_default = system_default_sect

[system_default_sect]
CipherString = DEFAULT:@SECLEVEL=1
MinProtocol = TLSv1
```

**In Dockerfile or docker-compose.yml:**

```dockerfile
ENV OPENSSL_CONF=/etc/ssl/openssl-lab.cnf
```

### Solution 3: Avoid Weak Parameters (Alternative)

**Instead of weak DH, demonstrate vulnerabilities with:**

```nginx
# Use normal 2048-bit DH (passes security check)
ssl_dhparam /etc/nginx/certs/dhparam.pem;  # 2048-bit

# But enable vulnerable ciphers and protocols
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'DES-CBC3-SHA:AES256-SHA:ECDHE-RSA-AES256-SHA';

# Result: Still gets Grade F on testssl.sh
# - SWEET32 vulnerable (3DES)
# - Old TLS versions
# - No "key too small" error
```

---

## 🧪 Testing Your Configuration

### Test 1: Check if NGINX accepts the config

```bash
nginx -t
```

**Expected:** `syntax is ok` and `test is successful`

### Test 2: Check security level in use

```bash
openssl s_client -connect localhost:443 -showcerts 2>&1 | grep -i level

# Or check cipher negotiation
openssl s_client -connect localhost:443 -brief
```

### Test 3: Verify with testssl.sh

```bash
testssl.sh localhost:443

# Look for:
# - "DH group offered: Unknown DH group (1024 bits)" ← Should work now
# - Grade F (if demonstrating vulnerabilities)
```

---

## 🎓 Educational Value

### What Students Learn:

1. **Modern OpenSSL enforces security automatically**
   - Default settings protect against weak crypto
   - This is a **good thing** for production!

2. **Why old servers are vulnerable**
   - They allowed weak parameters that newer software blocks
   - Demonstrates real-world security evolution

3. **Trade-offs in security configuration**
   - Backward compatibility vs. security
   - When to use exceptions (controlled lab only!)

### Key Takeaway:

> **The "key too small" error is not a bug—it's a security feature!**
> 
> We lower the security level ONLY in controlled lab environments to 
> demonstrate vulnerabilities. In production, always use SECLEVEL=2 or higher.

---

## 📋 Quick Reference Card

### For Vulnerable Lab Config:

```nginx
# Minimum changes to make weak DH work:
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'DHE-RSA-AES256-SHA:DES-CBC3-SHA@SECLEVEL=1';  # ← Add this
ssl_dhparam /etc/nginx/certs/dhparam-1024.pem;

# Generate weak DH:
openssl dhparam -out dhparam-1024.pem 1024
```

### For Secure Lab Config:

```nginx
# No special settings needed - use defaults:
ssl_protocols TLSv1.3 TLSv1.2;
ssl_ciphers 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256';
# @SECLEVEL=2 is default (no need to specify)
ssl_dhparam /etc/nginx/certs/dhparam.pem;  # 2048-bit

# Generate strong DH:
openssl dhparam -out dhparam.pem 2048
```

---

## 🔗 Further Reading

- [OpenSSL Security Levels Documentation](https://www.openssl.org/docs/man3.0/man3/SSL_CTX_set_security_level.html)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [NIST SP 800-57 Key Management](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)

---

## ⚠️ Important Reminders

1. **NEVER use `@SECLEVEL=1` or `@SECLEVEL=0` in production**
2. **This setting is ONLY for educational/testing purposes**
3. **Always document why you're lowering security levels**
4. **Consider using Secure config (2048-bit) as the baseline instead**

---

**Last Updated:** February 2026  
**Compatible With:** OpenSSL 1.1.x, 3.0.x, 3.1.x  
**Tested On:** Ubuntu 22.04 LTS, Debian 12
