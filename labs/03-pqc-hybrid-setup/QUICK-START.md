# 🚀 Quick Start: PQC Hybrid TLS with Auto-Generated Certificates

## สิ่งใหม่ในเวอร์ชันนี้

✨ **Automatic Certificate Generation** - ไม่ต้องสร้าง certificates ด้วยตัวเอง!
- Docker container จะสร้าง PQC hybrid certificates อัตโนมัติเมื่อเริ่มครั้งแรก
- ใช้ ML-DSA-65 (P-384 + ML-DSA hybrid) สำหรับ signatures
- รองรับ ML-KEM-768 hybrid สำหรับ key exchange

---

## ⚡ Quick Start (5 นาที)

```bash
cd labs/03-pqc-hybrid-setup

# 1. Build Docker image (30-40 นาที - ครั้งเดียว)
./setup.sh

# 2. รอให้ build เสร็จ จากนั้น container จะ:
#    - สร้าง certificates อัตโนมัติ
#    - เริ่ม NGINX ด้วย PQC hybrid TLS

# 3. ทดสอบ
curl -k https://localhost:8443
```

---

## 📦 สิ่งที่ Container ทำอัตโนมัติ

เมื่อ container start ครั้งแรก:

1. **ตรวจสอบ OpenSSL & oqsprovider**
   - Verify OpenSSL 3.x มี OQS provider loaded
   - แสดง PQC algorithms ที่ใช้ได้

2. **สร้าง Certificates (ถ้ายังไม่มี)**
   - CA Certificate: `P-384 + ML-DSA-65` hybrid
   - Server Certificate: `P-384 + ML-DSA-65` hybrid
   - Subject Alternative Names: `pqc-lab.local`, `localhost`, `127.0.0.1`

3. **เริ่ม NGINX**
   - TLS 1.3 เท่านั้น
   - KEM Groups: `x25519_mlkem768:p384_mlkem768:mlkem768:x25519:prime256v1`
   - Signature: ตาม certificate (P-384 + ML-DSA-65)

---

## 🔍 ดูสถานะ

```bash
# ดู logs ของ container
docker compose -f docker-compose-hybrid.yml logs -f nginx-pqc-hybrid

# ดู certificates ที่สร้าง
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid ls -la /etc/nginx/certs/

# ตรวจสอบ certificate details
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  /opt/openssl/bin/openssl x509 \
  -in /etc/nginx/certs/server-hybrid.crt \
  -noout -text
```

---

## 🧪 ทดสอบ PQC Connection

### ทดสอบจาก Host

```bash
# ทดสอบด้วย curl
curl -k -v https://localhost:8443

# ดู TLS handshake details
openssl s_client -connect localhost:8443 -showcerts < /dev/null
```

### ทดสอบจากภายใน Container (PQC-enabled OpenSSL)

```bash
# เข้า container
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid bash

# ทดสอบด้วย OQS-enabled OpenSSL
/opt/openssl/bin/openssl s_client \
  -connect localhost:443 \
  -showcerts \
  < /dev/null
```

---

## 🔧 Configuration Files

### Certificates

เก็บอยู่ใน `certs-hybrid/` (mounted to `/etc/nginx/certs/`):

```
certs-hybrid/
├── ca-hybrid.crt           # CA certificate (P-384+ML-DSA-65)
├── ca-hybrid.key           # CA private key
├── server-hybrid.crt       # Server certificate
├── server-hybrid.key       # Server private key
└── fullchain-hybrid.crt    # Full certificate chain
```

### NGINX Config

[configs/nginx-hybrid.conf](configs/nginx-hybrid.conf):
- **ssl_certificate**: `/etc/nginx/certs/fullchain-hybrid.crt`
- **ssl_certificate_key**: `/etc/nginx/certs/server-hybrid.key`
- **ssl_conf_command Groups**: `x25519_mlkem768:p384_mlkem768:mlkem768:x25519:prime256v1`

---

## 🔄 สร้าง Certificates ใหม่

### ตัวเลือก 1: Restart Container (ลบ certificates ก่อน)

```bash
# ลบ certificates เก่า
rm -rf certs-hybrid/*

# Restart container - จะสร้างใหม่อัตโนมัติ
docker compose -f docker-compose-hybrid.yml restart nginx-pqc-hybrid

# ดู logs
docker compose -f docker-compose-hybrid.yml logs -f nginx-pqc-hybrid
```

### ตัวเลือก 2: รันคำสั่งสร้างใหม่ใน Container

```bash
# เข้า container และสร้างใหม่
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid bash
/usr/local/bin/generate-pqc-certs.sh

# Reload NGINX
nginx -s reload
```

---

## 🎯 PQC Algorithms ที่ใช้

### Signature Algorithm (จาก Certificate)
- **p384_mldsa65** - Hybrid: NIST P-384 + ML-DSA-65
  - Classical: ECDSA P-384 (256-bit security)
  - PQC: ML-DSA-65 (FIPS 204 - Module-Lattice Digital Signature)
  - NIST Level 3 security (~ AES-192)

### KEM Algorithms (Key Exchange)
Priority order:
1. **x25519_mlkem768** - X25519 + ML-KEM-768 hybrid (RECOMMENDED)
2. **p384_mlkem768** - P-384 + ML-KEM-768 hybrid
3. **mlkem768** - Pure ML-KEM-768 (FIPS 203)
4. **x25519** - Classical X25519 (fallback)
5. **prime256v1** - Classical P-256 (compatibility)

---

## 🐛 Troubleshooting

### Container ไม่เริ่ม

```bash
# ดู logs
docker compose -f docker-compose-hybrid.yml logs nginx-pqc-hybrid

# ตรวจสอบว่า oqsprovider loaded หรือไม่
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  /opt/openssl/bin/openssl list -providers
```

### Certificates ไม่ถูกสร้าง

```bash
# รัน manual
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  /usr/local/bin/generate-pqc-certs.sh

# ตรวจสอบ permissions
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  ls -la /etc/nginx/certs/
```

### NGINX Config Error

```bash
# ทดสอบ config
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid nginx -t

# ดู error logs
docker compose -f docker-compose-hybrid.yml exec nginx-pqc-hybrid \
  cat /var/log/nginx/error.log
```

---

## 📚 เอกสารเพิ่มเติม

- [README.md](README.md) - เอกสารฉบับเต็ม
- [guides/01-pqc-intro.md](guides/01-pqc-intro.md) - PQC Overview
- [guides/02-hybrid-concept.md](guides/02-hybrid-concept.md) - Hybrid Approach
- [IMPORTANT-PATH-NOTES.md](IMPORTANT-PATH-NOTES.md) - Path configuration notes

---

## 🚦 Next Steps

1. ✅ ได้ PQC hybrid TLS ทำงานแล้ว
2. 📊 Lab 04: [Hybrid Testing](../04-hybrid-testing/) - วัดประสิทธิภาพ
3. 📈 Lab 05: [Analysis & Reporting](../05-analysis-reporting/) - วิเคราะห์ผล
4. 🔐 Lab 06: [VPN Hybrid](../06-vpn-hybrid/) - Apply PQC กับ VPN

---

## ⚙️ Environment Variables

Customize certificate generation:

```yaml
# In docker-compose-hybrid.yml
environment:
  - AUTO_GENERATE_CERTS=yes     # Auto-generate on first start
  - CERT_COUNTRY=TH
  - CERT_STATE=Bangkok
  - CERT_LOCALITY=Bangkok
  - CERT_ORG=PQC Lab
  - CERT_CN=pqc-lab.local
```

---

## 🎓 Key Learnings

หลังจากทำ lab นี้ คุณจะเข้าใจ:

✅ วิธีการ build OpenSSL + liboqs + oqs-provider  
✅ วิธีสร้าง PQC hybrid certificates  
✅ วิธี configure NGINX สำหรับ PQC hybrid TLS  
✅ วิธีทดสอบและ verify PQC connections  
✅ Troubleshooting PQC-related issues  

---

**🎉 ตอนนี้คุณมี Production-ready PQC Hybrid TLS Server แล้ว!**
