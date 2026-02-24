# Quick Fix: "DH key too small" Error
# แก้ไขด่วน: ปัญหา "DH key too small"

> ⚡ **5-Minute Quick Solution for Lab Students**

---

## ❌ The Error You're Seeing

```
error:0A00018E:SSL routines::dh key too small
```

Or when starting NGINX:

```
nginx: [emerg] SSL_CTX_use_PrivateKey_file() failed
nginx: configuration file /etc/nginx/nginx.conf test failed
```

Or when testing with curl:

```
curl: (35) error:0A00018E:SSL routines::dh key too small
```

---

## ✅ Quick Fix (Choose ONE)

### Fix 1: Add @SECLEVEL=1 (For Vulnerable Demo) ⭐

**If you're building the VULNERABLE config for comparison:**

1. Open your `ssl-params-vulnerable.conf` or `ssl-params.conf`
2. Find the `ssl_ciphers` line
3. Add `@SECLEVEL=1` at the very end

**Before:**
```nginx
ssl_ciphers 'DHE-RSA-AES256-SHA:AES256-SHA:DES-CBC3-SHA';
```

**After:**
```nginx
ssl_ciphers 'DHE-RSA-AES256-SHA:AES256-SHA:DES-CBC3-SHA@SECLEVEL=1';
#                                                        ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
#                                                        Add this!
```

4. Restart NGINX:
```bash
docker-compose restart
# or
nginx -s reload
```

---

### Fix 2: Use 2048-bit DH (For Secure Config) ⭐⭐

**If you want a properly secure configuration:**

1. Generate stronger DH parameters:
```bash
cd labs/00-target-app/certs
openssl dhparam -out dhparam.pem 2048
```

2. Update your config:
```nginx
ssl_dhparam /etc/nginx/certs/dhparam.pem;
```

3. Use modern cipher suites:
```nginx
ssl_protocols TLSv1.3 TLSv1.2;
ssl_ciphers 'TLS_AES_256_GCM_SHA384:ECDHE-RSA-AES256-GCM-SHA384';
# No @SECLEVEL needed - this is secure!
```

4. Restart NGINX

---

## 🎯 Which Fix Should I Use?

| Your Goal | Use Fix | Why |
|-----------|---------|-----|
| Demonstrate vulnerabilities (like Supreme.swu.ac.th) | Fix 1: @SECLEVEL=1 | Shows real-world weak configs |
| Create secure baseline for comparison | Fix 2: 2048-bit DH | Production-ready security |
| Just want it to work quickly | Fix 1: @SECLEVEL=1 | Fastest (1 minute) |
| Learn best practices | Fix 2: 2048-bit DH | Understanding modern security |

---

## 🧪 Verify It Works

### Test 1: NGINX Config
```bash
nginx -t
# Should show: syntax is ok, test is successful
```

### Test 2: Connection Test
```bash
curl -kI https://localhost
# Should get: HTTP/1.1 200 OK
```

### Test 3: Check DH Parameters
```bash
openssl s_client -connect localhost:443 -brief
# Look for: Protocol version, Ciphersuite
```

---

## 📚 Understanding the Problem

**Why does this error happen?**

Modern OpenSSL 3.x has strict security defaults:
- Blocks DH keys < 2048 bits
- Blocks RSA keys < 2048 bits
- Blocks weak ciphers

Your lab tries to use 1024-bit DH to demonstrate OLD vulnerabilities.

**Is @SECLEVEL=1 dangerous?**

- In production: YES ❌ (allows weak crypto)
- In isolated lab: NO ✅ (safe for learning)

**Rule:** Never use `@SECLEVEL=1` on real servers!

---

## 🔍 Full Example Configs

### Example 1: Vulnerable (with fix)

```nginx
# labs/00-target-app/configs/ssl-params-vulnerable.conf

ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers 'DHE-RSA-AES256-SHA:DES-CBC3-SHA@SECLEVEL=1';
ssl_dhparam /etc/nginx/certs/dhparam-1024.pem;

# Generate DH:
# openssl dhparam -out dhparam-1024.pem 1024
```

### Example 2: Secure

```nginx
# labs/00-target-app/configs/ssl-params-secure.conf

ssl_protocols TLSv1.3 TLSv1.2;
ssl_ciphers 'TLS_AES_256_GCM_SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_dhparam /etc/nginx/certs/dhparam.pem;  # 2048-bit

# Generate DH:
# openssl dhparam -out dhparam.pem 2048
```

---

## 🆘 Still Not Working?

### Check Docker Logs
```bash
docker-compose logs nginx
```

### Check File Permissions
```bash
ls -l certs/
# All files should be readable
```

### Check OpenSSL Version
```bash
openssl version
# Should be 3.0.x or 3.1.x
```

### Ask for Help
Include this info:
1. OpenSSL version: `openssl version`
2. NGINX config: `cat configs/ssl-params.conf`
3. Error logs: `docker-compose logs nginx`
4. Your OS: `uname -a`

---

## 📖 Learn More

- [docs/openssl-security-levels.md](../docs/openssl-security-levels.md) - Full explanation
- [docs/troubleshooting.md](../docs/troubleshooting.md) - All lab issues
- [labs/00-target-app/configs/ssl-params-vulnerable.conf](../labs/00-target-app/configs/ssl-params-vulnerable.conf) - Example vulnerable config
- [labs/00-target-app/configs/ssl-params-secure.conf](../labs/00-target-app/configs/ssl-params-secure.conf) - Example secure config

---

## ⏰ Time Estimates

| Task | Time |
|------|------|
| Apply Fix 1 (@SECLEVEL=1) | 1-2 minutes |
| Apply Fix 2 (2048-bit DH) | 5-10 minutes |
| Read full explanation | 10 minutes |
| Understand security levels | 15 minutes |

---

**Last Updated:** February 2026  
**Tested On:** Ubuntu 22.04, OpenSSL 3.0.13  
**Lab Version:** Test_lab_101
