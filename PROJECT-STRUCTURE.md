# Project Structure
# โครงสร้างโปรเจกต์

Total Files: **39 main files** | Total Lines: **~9,300 lines**

---

## 📁 Root Directory

```
pqcv2/
├── README.md                    # Main project overview 🎯
├── QUICK-START.md              # 30-minute fast setup guide ⚡
├── PREREQUISITES.md            # System requirements checklist
├── REFERENCES.md               # External resources and links
├── LICENSE                     # MIT License
├── requirements.txt            # Python dependencies
├── .gitignore                  # Git ignore rules
│
├── docs/                       # 📚 Documentation
│   ├── README.md              # Documentation index
│   ├── crypto-basics-101.md   # Cryptography fundamentals (12 min read)
│   ├── 2019-landscape.md      # Historical TLS context (8 min read)
│   └── troubleshooting.md     # Common issues & solutions
│
├── scripts/                    # 🛠️ Global Utilities
│   ├── setup-all.sh           # One-command environment setup
│   ├── verify-setup.sh        # Health check script (11 tests)
│   ├── calculate-stats.py     # Statistical analysis tool
│   ├── aggregate-data.py      # Combine test results
│   └── generate-charts.py     # Visualization generator
│
└── labs/                       # 🧪 Laboratory Exercises
    ├── 00-target-app/         # Baseline 2019 TLS server
    ├── 01-manual-discovery/   # Security scanning & analysis
    ├── 02-baseline-testing/   # Performance benchmarking
    ├── 03-pqc-hybrid-setup/   # PQC implementation
    ├── 04-hybrid-testing/     # PQC performance testing
    ├── 05-analysis-reporting/ # Results & visualization
    ├── 06-vpn-hybrid/         # BONUS: VPN with PQC
    ├── 07-advanced-workshop/  # BONUS: Automation workshop
    └── 08-compliance-mapping/ # BONUS: Standards compliance
```

---

## 🧪 Lab Breakdown

### Lab 00: Target Application (2019 Baseline)
**Duration:** 30 minutes | **Difficulty:** ⭐ Easy

```
labs/00-target-app/
├── README.md                   # Lab guide
├── docker-compose.yml          # MySQL + NGINX containers
├── Dockerfile                  # Custom NGINX image
├── setup.sh                    # Automated deployment ✓ executable
├── verify.sh                   # Health checks ✓ executable
├── configs/
│   ├── nginx.conf             # Main NGINX config (TLS 1.2)
│   ├── ssl-params.conf        # RSA-2048 SSL parameters
│   └── default.conf           # Server block config
├── database/
│   └── init.sql               # MySQL initialization
├── www/
│   └── index.html             # Corporate website
└── certs/
    └── .gitkeep               # Auto-generated certificates directory
```

**Key Features:**
- RSA-2048 certificates (2019 standard)
- TLS 1.2 with ECDHE cipher suites
- MySQL 5.7 database
- Self-signed certificates
- Port 443 (HTTPS), 3306 (MySQL)

---

### Lab 01: Manual Discovery
**Duration:** 90 minutes | **Difficulty:** ⭐⭐ Moderate

```
labs/01-manual-discovery/
├── README.md                   # Lab guide (comprehensive)
├── guides/
│   └── 01-crypto-concepts.md  # Crypto fundamentals (extended)
├── tools/
│   └── install-tools.sh       # testssl.sh, nmap, ab, tcpdump ✓
├── worksheets/
│   ├── discovery-report-template.md
│   ├── certificate-analysis.md      # Certificate deep dive
│   ├── cipher-enumeration.md        # Cipher suite analysis
│   └── risk-assessment.md           # Quantum threat evaluation
└── results/
    └── .gitkeep               # Scan results storage
```

**Learning Objectives:**
- Understand symmetric/asymmetric cryptography
- Analyze TLS certificates (RSA-2048)
- Enumerate cipher suites
- Assess quantum vulnerability
- Calculate risk scores

---

### Lab 02: Baseline Testing
**Duration:** 60 minutes | **Difficulty:** ⭐⭐ Moderate

```
labs/02-baseline-testing/
├── README.md                   # Testing methodology
└── results/
    └── .gitkeep               # JSON test results
```

**Metrics Collected:**
- TLS handshake latency (ms)
- Request/response time (ms)
- Throughput (Mbps)
- CPU usage (%)
- Memory consumption (MB)
- Packet size analysis

**Tools Used:**
- `curl` - Handshake timing
- `ab` (Apache Bench) - Load testing
- `docker stats` - Resource monitoring
- `tcpdump` - Packet capture

---

### Lab 03: PQC Hybrid Setup
**Duration:** 120 minutes | **Difficulty:** ⭐⭐⭐ Advanced

```
labs/03-pqc-hybrid-setup/
├── README.md                   # Implementation guide
├── docker-compose.yml          # PQC-enabled stack
├── setup.sh                    # Automated setup ✓
├── configs/
│   └── nginx-hybrid.conf      # TLS 1.3 + ML-KEM + ML-DSA
├── docker/
│   └── Dockerfile.nginx-pqc   # Compile OpenSSL+liboqs+NGINX
├── scripts/
│   ├── generate-hybrid-cert.sh # Certificate generator ✓
│   └── test-algorithms.sh      # PQC algorithm verification ✓
├── certs-hybrid/
│   └── .gitkeep               # Hybrid certificates
├── logs/
│   └── .gitkeep               # NGINX logs
└── www/
    └── index.html             # PQC-enabled website
```

**Key Features:**
- Hybrid ECDSA P-256 + ML-DSA-65 certificates
- TLS 1.3 only (no fallback)
- Key Exchange: X25519+ML-KEM-768
- Signature: ECDSA+ML-DSA-65 (hybrid)
- Encryption: AES-256-GCM, ChaCha20-Poly1305
- Port 8443 (HTTPS), 8080 (HTTP redirect)

**Build Time:** 30-60 minutes (compiles OpenSSL, liboqs, oqs-provider, NGINX)

---

### Lab 04: Hybrid Testing
**Duration:** 60 minutes | **Difficulty:** ⭐⭐ Moderate

```
labs/04-hybrid-testing/
├── README.md                   # Testing guide (same methods as Lab 02)
└── results/
    └── .gitkeep               # PQC test results
```

**Comparison Metrics:**
- Handshake overhead: Classical vs PQC
- CPU increase: % difference
- Memory increase: MB difference
- Latency impact: ms added
- Throughput degradation: % reduction

---

### Lab 05: Analysis & Reporting
**Duration:** 90 minutes | **Difficulty:** ⭐⭐⭐ Advanced

```
labs/05-analysis-reporting/
├── README.md                   # Report generation guide
└── charts/
    └── .gitkeep               # Generated visualizations
```

**Deliverables:**
- Aggregated JSON data (baseline + hybrid)
- Comparison charts (PNG/PDF):
  - Handshake time comparison
  - CPU usage comparison
  - Memory usage comparison
  - Throughput comparison
  - Distribution plots
- Bilingual PDF report (English + Thai)
- Executive summary (1 page)
- Technical details (10-15 pages)
- Recommendations

**Python Scripts Used:**
- `aggregate-data.py` → Combine results
- `generate-charts.py` → Create visualizations
- `build-report.py` → Generate PDF (optional)

---

### Lab 06: VPN Hybrid (BONUS)
**Duration:** 120 minutes | **Difficulty:** ⭐⭐⭐⭐ Expert

```
labs/06-vpn-hybrid/
└── README.md                   # VPN implementation guide
```

**Scope:**
- IPsec/StrongSwan with PQC
- IKEv2 with ML-KEM KEMs
- Authentication with ML-DSA
- Performance impact on tunnels
- iperf3 throughput testing

---

### Lab 07: Advanced Workshop (BONUS)
**Duration:** 180 minutes | **Difficulty:** ⭐⭐⭐⭐ Expert

```
labs/07-advanced-workshop/
└── README.md                   # Automation workshop
```

**Workshops:**
1. **TLS Scanner:** Build custom scanner
2. **Benchmark Tool:** Automated performance testing
3. **Report Generator:** Custom PDF reports
4. **CI/CD Integration:** Automated testing pipeline

---

### Lab 08: Compliance Mapping (BONUS)
**Duration:** 90 minutes | **Difficulty:** ⭐⭐⭐ Advanced

```
labs/08-compliance-mapping/
└── README.md                   # Compliance checklist
```

**Standards Covered:**
- NIST FIPS 203 (ML-KEM)
- NIST FIPS 204 (ML-DSA)
- ISO 27001 controls
- PCI DSS requirements
- HIPAA security rules
- GDPR technical measures

---

## 📊 Statistics

### File Counts
- **Markdown (*.md):** 21 files (~6,500 lines)
- **Shell Scripts (*.sh):** 8 files (~1,100 lines)
- **Python Scripts (*.py):** 3 files (~850 lines)
- **YAML Configs (*.yml):** 2 files (~150 lines)
- **NGINX Configs (*.conf):** 5 files (~700 lines)

### Total Content
- **~9,300 lines** of code and documentation
- **~50,000 words** of educational content
- **8 complete labs** (5 core + 3 bonus)
- **4 comprehensive worksheets**
- **3 Python analysis tools**
- **5 automation scripts**

---

## 🎯 Learning Path

### 1-Day Intensive (Core Labs)
```
8:00 - 8:30   Setup (QUICK-START.md + setup-all.sh)
8:30 - 9:00   Lab 00: Deploy baseline
9:00 - 10:30  Lab 01: Discovery + Worksheets
10:30 - 11:30 Lab 02: Baseline testing
11:30 - 13:30 Lab 03: PQC setup (includes lunch break)
13:30 - 14:30 Lab 04: Hybrid testing
14:30 - 16:00 Lab 05: Analysis & reporting
16:00 - 16:30 Review & Q&A
```

**Total:** 8 hours (6.5 hours active + 1.5 hours breaks)

### Extended Learning (+ Bonus Labs)
```
Day 2 (3 hours): Lab 06 - VPN Hybrid
Day 3 (6 hours): Lab 07 - Automation Workshop
Day 4 (3 hours): Lab 08 - Compliance Mapping
```

**Total:** 20 hours for complete mastery

---

## 🚀 Quick Navigation

| Need | File |
|------|------|
| **Get started fast** | [QUICK-START.md](../QUICK-START.md) |
| **Check requirements** | [PREREQUISITES.md](../PREREQUISITES.md) |
| **Learn crypto basics** | [docs/crypto-basics-101.md](../docs/crypto-basics-101.md) |
| **Fix problems** | [docs/troubleshooting.md](../docs/troubleshooting.md) |
| **Setup environment** | `./scripts/setup-all.sh` |
| **Verify setup** | `./scripts/verify-setup.sh` |
| **Start Lab 00** | `cd labs/00-target-app && ./setup.sh` |

---

## 🛠️ Developer Notes

### Key Design Decisions

1. **Docker-based:** Consistent environment across platforms
2. **Pre-compiled binaries:** Save 30-60 min compilation time
3. **Bilingual:** English primary, Thai summaries
4. **Manual-first:** Learn fundamentals before automation
5. **Worksheet-driven:** Active learning vs passive reading
6. **Real-world focused:** Enterprise migration scenarios

### Future Enhancements

- [ ] Pre-built Docker images (Docker Hub)
- [ ] Video tutorials (YouTube)
- [ ] Interactive Jupyter notebooks
- [ ] Automated grading system
- [ ] Multi-language support (CN, JP, KR)

---

<div align="center">

**Last Updated:** 2024-01-15  
**Version:** 1.0.0  
**License:** [MIT](../LICENSE)

[← Back to Main README](../README.md)

</div>
