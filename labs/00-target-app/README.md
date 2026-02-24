# Lab 00: Target Application (2019 Standard)
# เป้าหมาย: Corporate Website มาตรฐาน 2019

⏱️ **Duration:** 15 minutes  
🎯 **Objective:** Deploy a realistic 2019-standard HTTPS website for testing

---

## 📖 Overview | ภาพรวม

This lab sets up a **corporate website using 2019 security standards**. This represents a typical production environment before post-quantum cryptography, featuring:

- TLS 1.2 as default protocol
- RSA-2048 certificates
- ECDHE-RSA key exchange
- Classical cipher suites

ห้องปฏิบัติการนี้จะติดตั้ง **เว็บไซต์ขององค์กรที่ใช้มาตรฐานความปลอดภัยปี 2019** ซึ่งเป็นตัวแทนของระบบจริงก่อนมี post-quantum cryptography ประกอบด้วย:

- โปรโตคอล TLS 1.2 เป็นค่าเริ่มต้น
- ใบรับรอง RSA-2048
- การแลกเปลี่ยนคีย์ ECDHE-RSA
- Cipher suites แบบคลาสสิก

---

## 🎯 Learning Objectives | วัตถุประสงค์

After this lab, you will be able to:
- Deploy a Docker-based web server
- Understand 2019 TLS configuration standards
- Verify the server is running correctly
- Connect to an HTTPS server

หลังจากจบ lab นี้ คุณจะสามารถ:
- ติดตั้ง web server บน Docker ได้
- เข้าใจมาตรฐานการตั้งค่า TLS ในปี 2019
- ตรวจสอบว่า server ทำงานถูกต้อง
- เชื่อมต่อกับ HTTPS server

---

## 🏗️ Architecture | สถาปัตยกรรม

```
┌──────────────────────────────────────────────┐
│   Docker Containers (docker-compose)          │
│                                              │
│   ┌──────────────────────────────────────┐   │
│   │  pqc-nginx-vulnerable  (port 4430)   │   │
│   │                                      │   │
│   │  ├── TLS 1.0 / 1.1 / 1.2            │   │
│   │  ├── 3DES, CBC ciphers               │   │
│   │  ├── DH-1024 bit                     │   │
│   │  └── Mimics Supreme.swu.ac.th        │   │
│   └──────────────────────────────────────┘   │
│                                              │
│   ┌──────────────────────────────────────┐   │
│   │  pqc-nginx-secure      (port 4431)   │   │
│   │                                      │   │
│   │  ├── TLS 1.3 + TLS 1.2 only         │   │
│   │  ├── AEAD ciphers only               │   │
│   │  ├── HSTS enabled                    │   │
│   │  └── Hardened 2026 baseline          │   │
│   └──────────────────────────────────────┘   │
│                                              │
│   MySQL 5.7 Database                          │
│   (shared backend for both servers)           │
└──────────────────────────────────────────────┘
         │
         │ Port 4430 (HTTPS - Vulnerable)
         │ Port 4431 (HTTPS - Secure)
         ↓
    Your Browser
```

---

## 📁 Files Structure | โครงสร้างไฟล์

```
labs/00-target-app/
├── README.md (this file)
├── setup.sh (one-command deployment)
├── docker-compose.yml (container orchestration)
├── Dockerfile (NGINX container)
├── configs/
│   ├── nginx.conf (main NGINX config)
│   ├── ssl-params.conf (TLS 1.2 parameters)
│   └── default.conf (virtual host)
├── certs/
│   ├── generate-certs.sh (RSA-2048 certificates)
│   └── .gitkeep
├── www/
│   ├── index.html (corporate homepage)
│   ├── about.html
│   ├── products.html
│   └── assets/ (CSS, images)
├── database/
│   └── init.sql (MySQL initialization)
└── verify.sh (test if everything works)
```

---

## 🚀 Step 1: Setup | การติดตั้ง

### Navigate to Lab Directory

```bash
cd ~/pqcv2/labs/00-target-app
```

### Run Setup Script

```bash
chmod +x setup.sh
./setup.sh
```

### What the Script Does:

1. ✅ Checks Docker is running
2. 🔐 Generates RSA-2048 self-signed certificates
3. 🏗️ Builds NGINX Docker image
4. 🗄️ Starts MySQL database
5. 🌐 Starts NGINX web server
6. ✓ Verifies deployment

### Expected Output:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Lab 00: Target Application Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[1/6] Checking prerequisites...              ✓
[2/6] Generating RSA-2048 certificates...    ✓
[3/6] Building NGINX container...            ✓
[4/6] Starting MySQL database...             ✓
[5/6] Starting NGINX servers (vulnerable: 4430 | secure: 4431)...  ✓
[6/6] Verifying deployment...                ✓

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Target applications are running!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  [VULNERABLE] https://localhost:4430  →  Status: 200 OK
  [SECURE]     https://localhost:4431  →  Status: 200 OK

Next steps:
  1. Vulnerable: curl -k https://localhost:4430
  2. Secure:     curl -k https://localhost:4431
  3. Compare TLS: openssl s_client -connect localhost:4430 -brief
                  openssl s_client -connect localhost:4431 -brief
```

---

## 🧪 Step 2: Verification | การทดสอบ

### Method 1: Web Browser

Open your browser and navigate to:
```
https://localhost
```

**Note:** You'll see a security warning because we're using a self-signed certificate. This is **expected and safe** for this lab.

- **Chrome/Edge:** Click "Advanced" → "Proceed to localhost (unsafe)"
- **Firefox:** Click "Advanced" → "Accept the Risk and Continue"

You should see a **corporate website** with navigation menu.

### Method 2: Command Line (curl)

```bash
# Vulnerable server
curl -k https://localhost:4430

# Secure server
curl -k https://localhost:4431
```

**Expected output:** HTML content of the homepage (same site, different TLS config)

### Method 3: OpenSSL Client — Compare both servers

```bash
# Vulnerable server (expects TLS 1.0/1.1/1.2 + weak ciphers)
openssl s_client -connect localhost:4430 -brief

# Secure server (expects TLS 1.3 + AEAD only)
openssl s_client -connect localhost:4431 -brief
```

**Vulnerable expected output:**
```
CONNECTION ESTABLISHED
Protocol version: TLSv1.2
Ciphersuite: ECDHE-RSA-AES256-SHA384
Peer certificate: CN = corporate-2019.local
```

**Secure expected output:**
```
CONNECTION ESTABLISHED
Protocol version: TLSv1.3
Ciphersuite: TLS_AES_256_GCM_SHA384
Peer certificate: CN = corporate-2019.local
```

### Method 4: Check Running Containers

```bash
docker ps
```

**Expected output:**
```
CONTAINER ID   IMAGE                         STATUS
abc123def456   pqc-nginx-vulnerable          Up 2 minutes
def456ghi789   pqc-nginx-secure              Up 2 minutes
789ghi012jkl   mysql:5.7                     Up 2 minutes
```

---

## 📊 Step 3: Explore Configuration | สำรวจการตั้งค่า

### View NGINX TLS Configuration

```bash
cat configs/ssl-params.conf
```

**Key settings explained:**

```nginx
# TLS Protocol Versions
ssl_protocols TLSv1.2;  # Only TLS 1.2 (1.3 disabled - 2019 standard)

# Cipher Suites (2019 best practices)
ssl_ciphers 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-CHACHA20-POLY1305';

# Prefer server cipher order
ssl_prefer_server_ciphers on;

# RSA Certificate
ssl_certificate /etc/nginx/certs/server.crt;      # RSA-2048 public key
ssl_certificate_key /etc/nginx/certs/server.key;  # RSA-2048 private key

# Perfect Forward Secrecy
ssl_dhparam /etc/nginx/certs/dhparam.pem;         # DH-2048 parameters

# Session settings
ssl_session_timeout 1d;
ssl_session_cache shared:SSL:50m;
ssl_session_tickets off;

# HSTS (commented out for lab)
# add_header Strict-Transport-Security "max-age=31536000" always;
```

### Inspect Certificate

```bash
openssl x509 -in certs/server.crt -text -noout | head -20
```

**Look for:**
- **Public Key Algorithm:** RSA (2048 bit)
- **Signature Algorithm:** sha256WithRSAEncryption
- **Subject:** CN = corporate-2019.local
- **Validity:** 365 days

---

## 🔍 Step 4: Understanding 2019 Standards | ทำความเข้าใจมาตรฐาน 2019

### Why These Settings in 2019?

#### ✅ **TLS 1.2 (Not 1.3)**
- TLS 1.3 was published in August 2018
- In 2019, many enterprises still used TLS 1.2 by default
- Better compatibility with older clients
- TLS 1.3 adoption was gradual

#### ✅ **RSA-2048 Certificates**
- Industry standard for SSL certificates
- Considered secure until ~2030 (pre-quantum era)
- Balance between security and performance
- NIST recommended 2048-bit RSA until 2030

#### ✅ **ECDHE-RSA Key Exchange**
- **ECDHE:** Elliptic Curve Diffie-Hellman Ephemeral (Perfect Forward Secrecy)
- **RSA:** For authentication (certificate signature)
- Best practice in 2019
- Provides forward secrecy

#### ✅ **AES-GCM Ciphers**
- AES-256-GCM: Strong encryption (256-bit keys)
- GCM: Galois/Counter Mode (authenticated encryption)
- Hardware acceleration available (AES-NI)
- No known practical attacks in 2019

### ⚠️ **Quantum Vulnerability**

All of these "secure" 2019 algorithms are vulnerable to quantum computers:

| Algorithm | Type | Quantum Threat |
|-----------|------|----------------|
| RSA-2048 | Signature/Key Exchange | ❌ **Broken by Shor's algorithm** |
| ECDHE (P-256, X25519) | Key Exchange | ❌ **Broken by Shor's algorithm** |
| AES-256-GCM | Symmetric cipher | ⚠️ **Weakened** but not broken (Grover's algorithm) |
| SHA-256/384 | Hash | ⚠️ **Partially weakened** (Grover's algorithm) |

**This is why we need Post-Quantum Cryptography!**

---

## 📈 Step 5: Baseline Metrics | เมตริกพื้นฐาน

Before proceeding to next labs, collect some quick metrics:

### Handshake Time

```bash
# Vulnerable server
curl -k -o /dev/null -s -w "Time: %{time_connect}s\n" https://localhost:4430

# Secure server
curl -k -o /dev/null -s -w "Time: %{time_connect}s\n" https://localhost:4431
```

**Expected:** 0.010 - 0.050 seconds (10-50ms)

### Certificate Size

```bash
openssl s_client -connect localhost:4430 -showcerts </dev/null 2>/dev/null | \
  grep -E 'BEGIN|END' -A 100 | \
  wc -c
```

**Expected:** ~1,200 - 1,400 bytes (RSA-2048 certificate)

### Server Response

```bash
ab -n 100 -c 10 -t 10 https://localhost:4430/ 2>&1 | grep "Requests per second"
ab -n 100 -c 10 -t 10 https://localhost:4431/ 2>&1 | grep "Requests per second"
```

**Expected:** 1000-5000 requests/second (varies by hardware)

**Note:** Write these down! You'll compare them with hybrid PQC later.

---

## 🎯 Lab Checklist | รายการตรวจสอบ

Before proceeding to Lab 01, ensure:

- [ ] Containers are running (`docker ps`)
- [ ] Can access `https://localhost:4430` (vulnerable) in browser
- [ ] Can access `https://localhost:4431` (secure) in browser
- [ ] `curl -k https://localhost:4430` returns HTML
- [ ] `curl -k https://localhost:4431` returns HTML
- [ ] Vulnerable: OpenSSL shows TLS 1.0/1.1/1.2 available, 3DES in cipher list
- [ ] Secure: OpenSSL shows TLS 1.3, AEAD only
- [ ] Certificate is RSA-2048 (`openssl x509 -in certs/server.crt -text | grep "Public-Key"`)
- [ ] No errors in NGINX logs (`docker logs pqc-nginx-vulnerable` / `docker logs pqc-nginx-secure`)

---

## 🛠️ Commands Reference | คำสั่งอ้างอิง

```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# View logs
docker logs pqc-nginx-vulnerable
docker logs pqc-nginx-secure
docker logs pqc-target-mysql

# Restart services
docker-compose restart

# Rebuild after config changes
docker-compose up -d --build

# Shell into container
docker exec -it pqc-nginx-vulnerable bash
docker exec -it pqc-nginx-secure bash

# Check NGINX config
docker exec pqc-nginx-vulnerable nginx -t
docker exec pqc-nginx-secure nginx -t
```

---

## 🐛 Troubleshooting | แก้ไขปัญหา

### Issue: "Port 4430 or 4431 already in use"

```bash
# Find what's using port 4430 or 4431
sudo lsof -i :4430
sudo lsof -i :4431

# Stop the conflicting process, or change port mapping in docker-compose.yml:
ports:
  - "4432:443"  # Use a different host port
```

### Issue: "Cannot connect to https://localhost:4430 or :4431"

```bash
# Check container status
docker ps

# Check logs
docker logs pqc-nginx-vulnerable
docker logs pqc-nginx-secure

# Restart
docker-compose restart

# Full reset
docker-compose down
./setup.sh
```

### Issue: "SSL certificate problem"

```bash
# Use -k flag with curl (ignore certificate verification)
curl -k https://localhost

# This is expected with self-signed certificates
```

### Issue: "MySQL connection refused"

```bash
# Check MySQL container
docker logs pqc-target-mysql

# Wait 10-15 seconds for MySQL to fully start
sleep 15

# Restart services
docker-compose restart
```

---

## 📚 What's Next? | ขั้นตอนต่อไป

Now that you have a working 2019-standard HTTPS server, you'll:

1. **Lab 01:** Scan this server to identify quantum-vulnerable algorithms
2. **Lab 02:** Measure its baseline performance
3. **Lab 03:** Upgrade it to hybrid post-quantum cryptography
4. **Lab 04:** Measure performance again
5. **Lab 05:** Compare and analyze the differences

---

## 🧹 Cleanup | การทำความสะอาด

When you're completely done with all labs:

```bash
# Stop and remove containers
docker-compose down

# Remove volumes (database data)
docker-compose down -v

# Remove images (optional)
docker rmi 00-target-app-pqc-nginx-vulnerable 00-target-app-pqc-nginx-secure mysql:5.7
```

**Note:** Don't run cleanup until you finish all labs!

---

## 📖 Additional Reading | อ่านเพิ่มเติม

- [docs/2019-landscape.md](../../docs/2019-landscape.md) - Why these standards in 2019?
- [docs/crypto-basics-101.md](../../docs/crypto-basics-101.md) - RSA and ECDHE explained

---

<div align="center">

**✅ Lab 00 Complete!**

[← Back to Main](../../README.md) | [Lab 01: Discovery →](../01-manual-discovery/)

</div>
