# Lab 07: Advanced Automation Workshop [BONUS]
# Workshop: สร้างเครื่องมือ Automation

⏱️ **Duration:** 2-3 hours  
🎯 **Objective:** Build your own automation tools  
📍 **Level:** Intermediate - Hands-on coding

---

## 📖 Overview

In Labs 01-05, you performed manual measurements. Now learn to **automate** these tasks!

### What You'll Build
1. TLS scanner (like simplified testssl.sh)
2. Performance benchmarking tool
3. Automated report generator
4. CI/CD integration scripts

---

## 🛠️ Workshop Structure

### Workshop 1: Build a TLS Scanner (45 min)

**Goal:** Create a Python script that scans TLS configurations

```python
# Starter code provided in:
workshops/01-scanner/starter.py

# You'll implement:
def scan_tls_endpoint(host, port):
    # 1. Connect with OpenSSL
    # 2. Extract cipher suite
    # 3. Check certificate
    # 4. Identify PQC algorithms
    # 5. Return structured data
    pass
```

📖 **Instructions:** [workshops/01-scanner/README.md](workshops/01-scanner/README.md)  
✅ **Solution:** [workshops/01-scanner/solution.py](workshops/01-scanner/solution.py)

### Workshop 2: Automated Benchmarking (45 min)

**Goal:** Build a tool to run performance tests automatically

```bash
# Your tool should:
./benchmark-tool --target https://localhost --iterations 100

# Output:
{
  "handshake_ms": {"mean": 12.3, "p95": 15.2},
  "throughput_rps": 2341,
  "timestamp": "2026-02-10T10:00:00Z"
}
```

📖 **Instructions:** [workshops/02-benchmark/README.md](workshops/02-benchmark/README.md)

### Workshop 3: Report Generator (45 min)

**Goal:** Generate HTML reports from JSON data

```python
# Template engine (Jinja2)
def generate_report(data, template):
    # 1. Load data
    # 2. Render template
    # 3. Generate charts
    # 4. Export PDF
    pass
```

📖 **Instructions:** [workshops/03-reporting/README.md](workshops/03-reporting/README.md)

### Workshop 4: CI/CD Integration (30 min)

**Goal:** Integrate PQC testing into GitHub Actions

```yaml
# .github/workflows/pqc-test.yml
name: PQC Compatibility Test
on: [push, pull_request]
jobs:
  test-pqc:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Test PQC support
        run: ./scripts/test-pqc.sh
```

📖 **Instructions:** [workshops/04-cicd/README.md](workshops/04-cicd/README.md)

---

## 🎓 Learning Outcomes

After this workshop:
- ✅ Can build custom TLS scanners
- ✅ Automate performance testing
- ✅ Generate reports programmatically
- ✅ Integrate PQC tests in CI/CD
- ✅ Understand test automation architecture

---

## 📁 Structure

```
labs/07-advanced-workshop/
├── workshops/
│   ├── 01-scanner/ (build TLS scanner)
│   ├── 02-benchmark/ (automated benchmarks)
│   ├── 03-reporting/ (report generation)
│   └── 04-cicd/ (GitHub Actions)
│
├── solutions/ (reference implementations)
├── tests/ (unit tests for your code)
└── README.md (this file)
```

---

<div align="center">

[← Lab 06](../06-vpn-hybrid/) | [Lab 08 →](../08-compliance-mapping/)

</div>
