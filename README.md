# Hybrid Classical-Post-Quantum TLS Lab
# การฝึกปฏิบัติ TLS แบบ Hybrid Classical-Post-Quantum

<div align="center">

**🔐 A Comprehensive Lab for Post-Quantum Cryptography Migration**  
**การทดลองที่ครอบคลุมสำหรับการย้ายไปสู่ Post-Quantum Cryptography**

[![NIST PQC](https://img.shields.io/badge/NIST-PQC%20Standards-blue)](https://csrc.nist.gov/projects/post-quantum-cryptography)
[![ML-KEM-768](https://img.shields.io/badge/Algorithm-ML--KEM--768-green)](https://csrc.nist.gov/pubs/fips/203/final)
[![ML-DSA-65](https://img.shields.io/badge/Algorithm-ML--DSA--65-green)](https://csrc.nist.gov/pubs/fips/204/final)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## 📖 Overview | ภาพรวม

This laboratory provides hands-on experience with **hybrid post-quantum TLS** implementation and performance evaluation. Designed for senior undergraduate students with basic Linux/Docker knowledge but **no prior cryptography background required**.

ห้องปฏิบัติการนี้ให้ประสบการณ์ตรงในการทำงานกับ **TLS แบบ hybrid post-quantum** พร้อมการประเมินประสิทธิภาพ ออกแบบสำหรับนักศึกษาชั้นปีที่ 4 ที่มีความรู้พื้นฐาน Linux/Docker แต่**ไม่จำเป็นต้องมีพื้นฐาน cryptography**

### 🎯 Learning Objectives | วัตถุประสงค์

**English:**
- Understand quantum computing threats to current cryptography
- Implement hybrid classical-post-quantum TLS using open-source libraries
- Measure performance impacts: handshake latency, CPU usage, bandwidth overhead
- Evaluate operational feasibility for enterprise deployment
- Generate data-driven migration recommendations

**ภาษาไทย:**
- เข้าใจภัยคุกคามจาก quantum computing ต่อ cryptography ปัจจุบัน
- นำ hybrid classical-post-quantum TLS มาใช้งานด้วย open-source libraries
- วัดผลกระทบด้านประสิทธิภาพ: เวลา handshake, การใช้ CPU, bandwidth overhead
- ประเมินความเป็นไปได้ในการนำไปใช้ในองค์กร
- สร้างข้อเสนอแนะการย้ายระบบโดยอิงข้อมูล

---

## ⏱️ Lab Structure | โครงสร้าง Lab

### 🎓 Core Labs (1 Day - 8 Hours)

| Lab | Topic | Duration | Type |
|-----|-------|----------|------|
| **00** | [Target Application (2019 Standard)](labs/00-target-app/) | 15 min | Setup |
| **01** | [Manual Discovery + Crypto Basics](labs/01-manual-discovery/) | 45 min | 60% Manual |
| **02** | [Baseline Performance Testing](labs/02-baseline-testing/) | 60 min | 40% Manual |
| **03** | [PQC Hybrid Setup](labs/03-pqc-hybrid-setup/) | 90 min | 50% Manual |
| **04** | [Hybrid Performance Testing](labs/04-hybrid-testing/) | 60 min | 40% Manual |
| **05** | [Analysis & Reporting](labs/05-analysis-reporting/) | 90 min | Interactive |

**Total Core: 6.5 hours + breaks = ~8 hours intensive**

### 🌟 Bonus Labs (Self-Paced)

| Lab | Topic | Duration | Difficulty |
|-----|-------|----------|------------|
| **06** | [VPN Hybrid Implementation](labs/06-vpn-hybrid/) | 2-3 hours | Advanced |
| **07** | [Automation Workshop](labs/07-advanced-workshop/) | 2-3 hours | Intermediate |
| **08** | [Compliance Mapping (NIST/ISO)](labs/08-compliance-mapping/) | 1 hour | Reference |

---

## 🚀 Quick Start | เริ่มต้นอย่างรวดเร็ว

### Prerequisites | สิ่งที่ต้องเตรียม

```bash
# Operating System | ระบบปฏิบัติการ
- Linux (Ubuntu 20.04/22.04, Debian 11/12) *recommended
- macOS (with Docker Desktop)
- Windows (WSL2 + Docker Desktop)

# Software | ซอฟต์แวร์
- Docker & Docker Compose
- Git
- Python 3.8+
- Basic terminal knowledge
```

### Installation | การติดตั้ง

```bash
# 1. Clone repository
git clone https://github.com/yourusername/pqcv2.git
cd pqcv2

# 2. Run setup script
# รันสคริปต์ใหม่
./scripts/setup-all.sh

# Activate venv ก่อนใช้ lab เสมอ
source ~/.pqc-venv/bin/activate

# (Optional) เพิ่มใน ~/.bashrc เพื่อ auto-activate
echo 'source ~/.pqc-venv/bin/activate' >> ~/.bashrc

# 3. Verify installation
./scripts/verify-setup.sh

# 4. Start first lab
cd labs/00-target-app
./setup.sh
```

📚 **See [QUICK-START.md](QUICK-START.md) for detailed instructions**  
📚 **ดูรายละเอียดใน [QUICK-START.md](QUICK-START.md)**

---

## 🗓️ Suggested Timeline | ตารางเวลาแนะนำ

### One-Day Intensive Schedule

```
08:00-08:15  ☕ Environment Setup
08:15-09:00  📊 Lab 01: Discovery & Crypto Basics
09:00-10:00  📈 Lab 02: Baseline Testing
10:00-10:15  ☕ Break
10:15-11:45  🔐 Lab 03: PQC Setup
11:45-12:45  🧪 Lab 04: Hybrid Testing
12:45-13:30  🍽️ Lunch
13:30-15:00  📊 Lab 05: Analysis & Reporting
15:00-15:15  ☕ Break
15:15-17:00  ✅ Finalization & Q&A
17:00-17:30  🎓 Wrap-up & Next Steps
```

---

## 🛠️ Technologies Used | เทคโนโลยีที่ใช้

### Cryptographic Libraries
- **OpenSSL 3.x** - TLS/SSL implementation
- **liboqs** - Open Quantum Safe library
- **oqs-provider** - OpenSSL 3.x provider for PQC

### Algorithms Tested
- **Classical:**
  - Key Exchange: ECDHE-X25519
  - Signature: ECDSA P-256
  - Cipher: AES-256-GCM
  
- **Post-Quantum (NIST Standards):**
  - Key Exchange: ML-KEM-768 (FIPS 203)
  - Signature: ML-DSA-65 (FIPS 204)

- **Hybrid:**
  - X25519+MLKEM768
  - ECDSA+MLDSA65

### Testing & Analysis
- **testssl.sh** - TLS/SSL scanner
- **Apache Bench (ab)** - HTTP benchmarking
- **perf, vmstat** - System profiling
- **Python (matplotlib, pandas)** - Data analysis
- **Wireshark/tcpdump** - Packet analysis

---

## 📊 Performance Metrics | เมตริกที่วัด

Each lab measures and compares:

- ⏱️ **Handshake Latency** - Time to establish TLS connection
- 💻 **CPU Usage** - Processor overhead during operations
- 🧠 **Memory Footprint** - RAM consumption
- 📶 **Throughput** - Requests per second
- 📦 **Bandwidth Overhead** - Certificate and packet sizes

---

## 📁 Repository Structure | โครงสร้างโฟลเดอร์

```
pqcv2/
├── README.md                 # This file
├── QUICK-START.md           # Detailed getting started guide
├── PREREQUISITES.md         # System requirements & setup
├── LICENSE                  # MIT License
│
├── labs/                    # All laboratory exercises
│   ├── 00-target-app/       # 2019-standard web application
│   ├── 01-manual-discovery/ # Scanning & cryptography basics
│   ├── 02-baseline-testing/ # Classical TLS performance
│   ├── 03-pqc-hybrid-setup/ # Post-quantum setup
│   ├── 04-hybrid-testing/   # Hybrid TLS performance
│   ├── 05-analysis-reporting/ # Comparative analysis
│   ├── 06-vpn-hybrid/       # [BONUS] VPN implementation
│   ├── 07-advanced-workshop/ # [BONUS] Automation
│   └── 08-compliance-mapping/ # [BONUS] NIST/ISO mapping
│
├── docs/                    # Documentation
│   ├── crypto-basics-101.md # Cryptography fundamentals
│   ├── algorithms-comparison.md # PQC algorithms overview
│   ├── 2019-landscape.md    # Why 2019 standards?
│   ├── troubleshooting.md   # Common issues & fixes
│   └── glossary.md          # Technical terms
│
├── scripts/                 # Utility scripts
│   ├── setup-all.sh         # One-command installation
│   ├── verify-setup.sh      # Verify environment
│   ├── run-core-labs.sh     # Guided lab execution
│   └── cleanup.sh           # Remove all containers/data
│
└── REFERENCES.md            # Academic papers & standards
```

---

## 🎓 Target Audience | กลุ่มเป้าหมาย

**Ideal for:**
- Senior undergraduate students (Year 4) in Computer Science/Engineering
- IT professionals exploring post-quantum cryptography
- Security researchers studying quantum-resistant protocols
- Anyone interested in practical cryptography migration

**Prerequisites:**
- Basic Linux command line
- Understanding of client-server architecture
- Familiarity with Docker (helpful but not required)
- **No cryptography background needed** - we'll teach you!

---

## 🏆 Learning Outcomes | ผลลัพธ์การเรียนรู้

After completing this lab, you will be able to:

✅ Explain quantum computing threats to current cryptographic systems  
✅ Identify vulnerable algorithms in existing TLS deployments  
✅ Implement hybrid post-quantum TLS configurations  
✅ Measure and analyze performance trade-offs  
✅ Generate professional reports with data-driven recommendations  
✅ Understand NIST PQC standards and migration pathways  
✅ Make informed decisions about PQC deployment strategies  

---

## 🔗 Additional Resources | แหล่งข้อมูลเพิ่มเติม

### Official Standards
- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [FIPS 203: ML-KEM](https://csrc.nist.gov/pubs/fips/203/final)
- [FIPS 204: ML-DSA](https://csrc.nist.gov/pubs/fips/204/final)
- [IETF PQC in TLS](https://datatracker.ietf.org/wg/tls/documents/)

### Open Source Projects
- [Open Quantum Safe](https://openquantumsafe.org/)
- [liboqs GitHub](https://github.com/open-quantum-safe/liboqs)
- [oqs-provider](https://github.com/open-quantum-safe/oqs-provider)

### Research Papers
See [REFERENCES.md](REFERENCES.md) for full bibliography

---

## 🤝 Contributing | การมีส่วนร่วม

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

For major changes, please open an issue first to discuss what you would like to change.

---

## 📧 Support | การสนับสนุน

- **Issues:** [GitHub Issues](https://github.com/yourusername/pqcv2/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/pqcv2/discussions)
- **Email:** your.email@example.com

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments | กิตติกรรมประกาศ

- **Open Quantum Safe Project** - PQC implementations
- **NIST** - Post-Quantum Cryptography standards
- **OpenSSL Community** - TLS/SSL foundation
- All contributors and testers

---

## 🌟 Star History

If you find this lab useful, please consider giving it a star! ⭐

---

<div align="center">

**Made with ❤️ for the post-quantum era**  
**สร้างด้วย ❤️ สำหรับยุค post-quantum**

[Get Started](QUICK-START.md) | [Documentation](docs/) | [Report Issues](https://github.com/yourusername/pqcv2/issues)

</div>
