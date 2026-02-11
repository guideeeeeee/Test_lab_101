# Documentation Index
# ดัชนีเอกสาร

This directory contains comprehensive documentation for the PQC Migration Lab.

---

## 📚 Available Documents

### 🎓 Educational Foundation

- **[Crypto Basics 101](crypto-basics-101.md)** (12 min read)
  - Symmetric vs Asymmetric Cryptography
  - How TLS Works (Handshake flow)
  - Quantum Threat Explained (Shor's Algorithm)
  - Post-Quantum Cryptography Introduction
  - Hybrid Approach Concept
  - **Target:** Year 4 students with no crypto background

- **[2019 TLS Landscape](2019-landscape.md)** (8 min read)
  - Why 2019 as Baseline
  - Typical Enterprise Configuration (RSA-2048, TLS 1.2)
  - Industry Standards (NIST, Mozilla)
  - Security Assumptions (What was "secure")
  - Evolution Timeline → PQC Migration
  - **Purpose:** Understand historical context

---

### 🛠️ Technical Guides

- **[Troubleshooting Guide](troubleshooting.md)**
  - Docker Issues (daemon, ports, containers)
  - TLS/SSL Issues (certificates, version mismatch)
  - Python Issues (dependencies, modules)
  - OpenSSH/PQC Issues (oqs-provider, algorithms)
  - Performance Testing Issues (ab, tcpdump)
  - System Resource Issues (memory, disk)
  - Quick Diagnostic Script
  - **Use when:** Something goes wrong!

---

### 📖 Lab-Specific Documentation

Each lab directory (`labs/XX-name/`) contains:
- **README.md** - Lab objectives, methodology, step-by-step guide
- **guides/** - Detailed conceptual explanations
- **worksheets/** - Structured exercises with fill-in-the-blank
- **scripts/** - Automation tools and helpers
- **configs/** - Configuration file templates

---

## 🗺️ Learning Path

### For Complete Beginners:

```
1. Read: Crypto Basics 101 (understand foundation)
   └─ Time: 12 minutes
   
2. Read: 2019 TLS Landscape (understand context)
   └─ Time: 8 minutes
   
3. Start: Lab 00 - Target Application
   └─ Deploy baseline system
   
4. Work through: Labs 01-05 (Core Labs)
   └─ With worksheets and guides
```

### For Advanced Users:

```
1. Skim: Crypto Basics 101 (refresh if needed)
   
2. Jump to: Lab 00 → Labs 01-05
   └─ Focus on hands-on implementation
   
3. Challenge: Bonus Labs 06-08
   └─ VPN, Automation, Compliance
```

---

## 📊 Documentation Format

### README Files
- **Purpose:** Quick overview and getting started
- **Structure:** Context → Prerequisites → Steps → Verification
- **Length:** 5-10 minutes read

### Guide Files
- **Purpose:** Deep dive into concepts
- **Structure:** Theory → Examples → Best Practices
- **Length:** 10-20 minutes read

### Worksheet Files
- **Purpose:** Hands-on exercises with reflection
- **Structure:** Objective → Tasks → Analysis → Summary
- **Length:** 30-60 minutes to complete

### Script Files
- **Purpose:** Automation and tooling
- **Structure:** Header comment → Functions → Main execution
- **Length:** N/A (executable)

---

## 🌐 Bilingual Support

All documentation is provided in **English** with Thai translations/summaries where appropriate:
- Main content: English
- Key terms: Thai translation in parentheses
- Worksheets: Bilingual questions
- Comments in scripts: English

**Reason:** English is the technical standard, but Thai summaries help Year 4 Thai students grasp concepts faster.

---

## 🔍 Quick Reference

### Find Information By Topic:

| Topic | Document | Section |
|-------|----------|---------|
| What is TLS? | [Crypto Basics 101](crypto-basics-101.md) | How TLS Works |
| What is Quantum Threat? | [Crypto Basics 101](crypto-basics-101.md) | The Quantum Threat |
| Why migrate now? | [2019 Landscape](2019-landscape.md) | "Harvest Now, Decrypt Later" |
| What is Hybrid PQC? | [Crypto Basics 101](crypto-basics-101.md) | Hybrid Cryptography |
| Certificate won't work | [Troubleshooting](troubleshooting.md) | TLS/SSL Issues |
| Docker errors | [Troubleshooting](troubleshooting.md) | Docker Issues |
| Port already in use | [Troubleshooting](troubleshooting.md) | Port 443 already in use |
| Python import error | [Troubleshooting](troubleshooting.md) | Python Issues |
| Statistics formulas | Lab 02 README | Baseline Testing Methodology |
| NGINX PQC config | Lab 03 configs/ | nginx-hybrid.conf |
| Report generation | Lab 05 README | Analysis & Reporting |

---

## 📝 Contributing Documentation

If you create additional documentation:

1. **Follow naming convention:** `kebab-case.md`
2. **Include header:** Title in English + Thai
3. **Add to this index:** Update table above
4. **Link from relevant labs:** Add references in README
5. **Keep it concise:** Target 5-20 minute read times

---

## 🆘 Need Help?

1. **Check:** [Troubleshooting Guide](troubleshooting.md)
2. **Search:** Use grep to search all docs:
   ```bash
   grep -r "keyword" docs/
   ```
3. **Ask:** Open GitHub Issue with:
   - What you tried
   - What went wrong
   - Logs/screenshots
   - Output of `diagnose.sh` (from troubleshooting guide)

---

## 📚 External Resources

### Official Standards:
- [NIST FIPS 203 (ML-KEM)](https://csrc.nist.gov/pubs/fips/203/final)
- [NIST FIPS 204 (ML-DSA)](https://csrc.nist.gov/pubs/fips/204/final)
- [Open Quantum Safe Project](https://openquantumsafe.org/)

### Learning Resources:
- [TLS 1.3 RFC 8446](https://datatracker.ietf.org/doc/html/rfc8446)
- [Post-Quantum Cryptography FAQ](https://csrc.nist.gov/Projects/post-quantum-cryptography/faqs)
- [Cloudflare PQC Blog Series](https://blog.cloudflare.com/tag/post-quantum/)

### Tools & Software:
- [testssl.sh Documentation](https://github.com/drwetter/testssl.sh)
- [OpenSSL Documentation](https://www.openssl.org/docs/)
- [liboqs Documentation](https://github.com/open-quantum-safe/liboqs)

---

<div align="center">

[← Back to Main README](../README.md)

**Happy Learning! / สนุกกับการเรียนรู้!**

</div>
