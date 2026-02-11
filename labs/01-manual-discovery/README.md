# Lab 01: Manual Discovery & Cryptography Basics
# การสำรวจระบบด้วยมือและพื้นฐานการเข้ารหัส

⏱️ **Duration:** 45 minutes  
🎯 **Objective:** Learn cryptography fundamentals and manually scan TLS configurations

---

## 📖 Overview | ภาพรวม

This lab teaches you the **fundamentals of cryptography** needed to understand post-quantum threats, then guides you through **manually scanning** the target application to identify vulnerable algorithms.

ห้องปฏิบัติการนี้จะสอน **พื้นฐานการเข้ารหัส** ที่จำเป็นเพื่อเข้าใจภัยคุกคาม post-quantum จากนั้นจะแนะนำการ **สแกนด้วยมือ** เพื่อระบุ algorithm ที่เสี่ยง

**No prior cryptography knowledge required!** | **ไม่ต้องมีความรู้ cryptography มาก่อน!**

---

## 🎯 Learning Objectives | วัตถุประสงค์

After this lab, you will be able to:
- Explain basic cryptographic concepts (encryption, signatures, hashing)
- Understand why quantum computers threaten current cryptography
- Use OpenSSL to inspect TLS connections
- Identify quantum-vulnerable algorithms
- Document security configurations manually

หลังจากจบ lab นี้ คุณจะสามารถ:
- อธิบายแนวคิดพื้นฐานทาง cryptography (การเข้ารหัส, ลายเซ็น, hashing)
- เข้าใจว่าทำไม quantum computer คุกคาม cryptography ปัจจุบัน
- ใช้ OpenSSL ตรวจสอบ TLS connection
- ระบุ algorithm ที่เสี่ยงต่อ quantum
- บันทึก security configuration ด้วยมือ

---

## 📚 Part 1: Cryptography Basics (20 minutes)

### Step 1.1: Read Crypto Fundamentals

📖 **Read this first:** [guides/01-crypto-concepts.md](guides/01-crypto-concepts.md)

This guide covers:
- What is cryptography?
- Symmetric vs. asymmetric (public-key) cryptography
- Three pillars: Encryption, Signatures, Hashing
- How TLS uses these concepts
- **Why quantum computers break RSA and ECDHE**

**Estimated reading: 10-12 minutes**

### Step 1.2: Understand Quantum Threat

📖 **Read this:** [guides/02-quantum-threat.md](guides/02-quantum-threat.md)

This guide explains:
- What are quantum computers?
- Shor's Algorithm (breaks RSA and ECDHE)
- Grover's Algorithm (weakens AES)
- Timeline: When will quantum computers break current crypto?
- Post-Quantum Cryptography (PQC) overview

**Estimated reading: 8-10 minutes**

### Step 1.3: Quick Self-Test

Answer these questions (no need to submit, just for your understanding):

1. What's the difference between symmetric and asymmetric cryptography?
2. In TLS, which algorithm is used for key exchange?
3. Why can't we just use AES-256 for everything?
4. What will Shor's algorithm break?
5. What is "hybrid" cryptography?

**Answers in:** [guides/self-test-answers.md](guides/self-test-answers.md)

---

## 🔍 Part 2: Manual Discovery (25 minutes)

Now that you understand the concepts, let's scan the target application!

### Step 2.1: Basic OpenSSL Client

**Goal:** Connect to the server and see the raw TLS handshake

```bash
openssl s_client -connect localhost:443 -brief
```

**What to look for:**
- Protocol version (TLSv1.2 or TLSv1.3?)
- Ciphersuite (which algorithms are used?)
- Peer certificate (who signed it?)

📖 **Detailed explanation:** [guides/03-openssl-basics.md](guides/03-openssl-basics.md)

### Step 2.2: Inspect Certificate Details

```bash
# Method 1: Through connection
openssl s_client -connect localhost:443 -showcerts </dev/null 2>/dev/null | \
  openssl x509 -text -noout

# Method 2: Direct file inspection (if you have access)
openssl x509 -in ../00-target-app/certs/server.crt -text -noout
```

**Fill in the worksheet:** [worksheets/certificate-analysis.md](worksheets/certificate-analysis.md)

Find and record:
- **Subject:** Who is certified (CN, O, OU)?
- **Issuer:** Who signed it?
- **Public Key Algorithm:** RSA? ECDSA? Size?
- **Signature Algorithm:** sha256WithRSAEncryption?
- **Validity:** Not Before and Not After dates

### Step 2.3: Enumerate Cipher Suites

```bash
# Test specific ciphers manually
openssl s_client -connect localhost:443 -cipher 'ECDHE-RSA-AES256-GCM-SHA384' -brief

# Try different TLS versions
openssl s_client -connect localhost:443 -tls1_2 -brief
openssl s_client -connect localhost:443 -tls1_3 -brief
```

**Fill in the worksheet:** [worksheets/cipher-enumeration.md](worksheets/cipher-enumeration.md)

### Step 2.4: Using testssl.sh (Semi-Automated)

Install and run testssl.sh:

```bash
# Navigate to tools directory
cd tools

# Clone testssl.sh (if not already there)
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

# Run scan
./testssl.sh/testssl.sh localhost:443
```

**This will take 2-3 minutes** and produce a comprehensive report.

📖 **How to read the output:** [guides/04-understanding-testssl.md](guides/04-understanding-testssl.md)

### Step 2.5: Manual Risk Assessment

Using the data you collected, fill in the risk assessment worksheet:

📝 **Worksheet:** [worksheets/risk-assessment.md](worksheets/risk-assessment.md)

For each algorithm, mark:
- ✅ Quantum-safe
- ⚠️ Partially vulnerable
- ❌ Completely broken by quantum computers

---

## 📊 Part 3: Documentation (Extra 10 minutes if time allows)

### Compile Your Findings

Create a simple text summary (template provided):

```
Target: https://localhost
Scan Date: [TODAY]
Scanned By: [YOUR NAME]

=== TLS Configuration ===
Protocol: TLSv1.2
Cipher Suite: ECDHE-RSA-AES256-GCM-SHA384

=== Certificate ===
Algorithm: RSA (2048 bit)
Signature: sha256WithRSAEncryption
Subject: CN=corporate-2019.local
Issuer: [self-signed]

=== Quantum Risk Assessment ===
Key Exchange (ECDHE): ❌ VULNERABLE - Broken by Shor's algorithm
Authentication (RSA): ❌ VULNERABLE - Broken by Shor's algorithm
Encryption (AES-256): ⚠️ WEAKENED - Grover reduces to 128-bit security
Hash (SHA-384): ⚠️ WEAKENED - Grover reduces to 192-bit security

=== Recommendation ===
Requires migration to post-quantum cryptography (ML-KEM, ML-DSA)
```

**Template:** [worksheets/discovery-report-template.md](worksheets/discovery-report-template.md)

---

## 📁 Files Structure | โครงสร้างไฟล์

```
labs/01-manual-discovery/
├── README.md (this file)
│
├── guides/
│   ├── 01-crypto-concepts.md ⭐ (Cryptography 101)
│   ├── 02-quantum-threat.md ⭐ (Quantum computing explained)
│   ├── 03-openssl-basics.md (OpenSSL command tutorial)
│   ├── 04-understanding-testssl.md (testssl.sh output guide)
│   └── self-test-answers.md (Quiz answers)
│
├── worksheets/
│   ├── certificate-analysis.md (Fill-in-the-blank)
│   ├── cipher-enumeration.md (Record cipher tests)
│   ├── risk-assessment.md ⭐ (Quantum risk matrix)
│   └── discovery-report-template.md (Final report)
│
├── tools/
│   ├── install-tools.sh (Install scanners)
│   └── testssl.sh/ (Will be cloned here)
│
├── examples/
│   ├── example-openssl-output.txt
│   ├── example-certificate.txt
│   ├── example-testssl-report.html
│   └── completed-worksheet-example.md
│
└── scripts/
    ├── quick-scan.sh (Helper script for manual scans
    └── explain-cipher.py (Cipher suite decoder)
```

---

## 🚀 Getting Started | เริ่มต้น

### Prerequisites Check

```bash
# Check if Lab 00 is running
curl -k https://localhost &>/dev/null && echo "✓ Lab 00 is running" || echo "✗ Start Lab 00 first"

# Check OpenSSL
openssl version

# Expected: OpenSSL 1.1.1 or 3.x
```

### Install Tools

```bash
cd ~/pqcv2/labs/01-manual-discovery

# Install scanning tools
chmod +x tools/install-tools.sh
./tools/install-tools.sh
```

This installs:
- testssl.sh (TLS scanner)
- nmap + ssl-enum-ciphers script
- tlsx (modern TLS toolkit)

---

## 🧪 Exercises | แบบฝึกหัด

### Exercise 1: Identify the Key Exchange
**Time:** 5 minutes

Run this command:
```bash
openssl s_client -connect localhost:443 -brief
```

**Question:** What key exchange algorithm is used? (Hint: Look for "ECDHE" or "RSA")

**Answer location:** [exercises/exercise-1-solution.md](exercises/exercise-1-solution.md)

### Exercise 2: Certificate Size Comparison
**Time:** 5 minutes

```bash
# Get certificate
openssl s_client -connect localhost:443 -showcerts </dev/null 2>/dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > /tmp/cert.pem

# Check size
wc -c /tmp/cert.pem
```

**Question:** How many bytes is the RSA-2048 certificate? Write it down - you'll compare with PQC later!

### Exercise 3: Risk Matrix
**Time:** 10 minutes

Fill in the risk matrix in [worksheets/risk-assessment.md](worksheets/risk-assessment.md)

For each algorithm discovered, classify:
- Algorithm name
- Quantum threat level (None / Partial / Critical)
- Time to break with quantum computer
- Recommended replacement (from NIST PQC standards)

---

## 🎓 Lab Checklist | รายการตรวจสอบ

Before proceeding to Lab 02, ensure you:

- [ ] Read crypto-concepts.md (understand symmetric/asymmetric)
- [ ] Read quantum-threat.md (understand Shor's algorithm)
- [ ] Successfully connected with `openssl s_client`
- [ ] Inspected the RSA-2048 certificate
- [ ] Ran testssl.sh scan
- [ ] Identified: TLS 1.2, ECDHE-RSA, AES-256-GCM
- [ ] Filled risk assessment worksheet
- [ ] Understand why these algorithms are quantum-vulnerable
- [ ] Completed at least 2 of 3 exercises

---

## 💡 Key Takeaways | สิ่งที่ได้เรียนรู้

After this lab, you should understand:

1. **Cryptography Fundamentals**
   - Encryption protects confidentiality
   - Signatures prove authenticity
   - Hashing ensures integrity

2. **Public Key Cryptography**
   - RSA: Used for key exchange and signatures
   - ECDHE: Used for key exchange (with forward secrecy)
   - Both rely on hard math problems

3. **Quantum Threat**
   - Shor's algorithm breaks RSA and ECDHE
   - Quantum computers coming in 10-20 years
   - Need to migrate to PQC now (data harvesting risk)

4. **Current TLS Configuration**
   - Target server uses TLS 1.2
   - RSA-2048 certificates
   - ECDHE-RSA-AES256-GCM-SHA384 cipher
   - **All quantum-vulnerable except AES (which is only weakened)**

5. **Next Steps**
   - Measure performance of current setup (Lab 02)
   - Migrate to hybrid PQC (Lab 03)
   - Compare performance (Lab 04-05)

---

## 🐛 Troubleshooting | แก้ไขปัญหา

### Issue: "Connection refused" with OpenSSL

```bash
# Check if Lab 00 is running
docker ps | grep pqc-target-nginx

# If not running, start it
cd ../00-target-app
./setup.sh
```

### Issue: testssl.sh not found

```bash
# Install manually
cd tools
git clone --depth 1 https://github.com/drwetter/testssl.sh.git
```

### Issue: "Unable to load certificate"

```bash
# Use -k flag with curl (ignore certificate errors)
curl -k https://localhost

# This is expected with self-signed certificates
```

---

## 📚 Additional Resources | แหล่งข้อมูลเพิ่มเติม

### External Reading
- [Mozilla TLS Configuration Guide](https://wiki.mozilla.org/Security/Server_Side_TLS)
- [NIST PQC Project](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Cloudflare: Quantum Threat Timeline](https://blog.cloudflare.com/towards-post-quantum-cryptography-in-tls/)

### Videos (Optional)
- "Quantum Computing and Cryptography" - Computerphile
- "How RSA Works" - Art of the Problem

---

## 🎯 What's Next? | ขั้นตอนต่อไป

Now that you've identified vulnerable algorithms, you'll:

1. **Lab 02:** Measure **baseline performance** of classical TLS
2. **Lab 03:** Implement **hybrid post-quantum** cryptography
3. **Lab 04:** Measure **hybrid performance**
4. **Lab 05:** **Compare** and generate reports

---

<div align="center">

**✅ Lab 01 Complete!**

[← Lab 00](../00-target-app/) | [Back to Main](../../README.md) | [Lab 02: Baseline Testing →](../02-baseline-testing/)

</div>
