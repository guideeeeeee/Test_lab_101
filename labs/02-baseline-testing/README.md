# Lab 02: Baseline Performance Testing
# การทดสอบประสิทธิภาพพื้นฐาน (Classical TLS)

⏱️ **Duration:** 60 minutes  
🎯 **Objective:** Measure classical TLS performance as baseline for comparison

---

## 📖 Overview |ภาพรวม

Before migrating to post-quantum cryptography, we need to establish a **performance baseline**. This lab teaches you to manually measure and record key metrics of the classical TLS configuration.

ก่อนย้ายไป post-quantum cryptography เราต้องสร้าง **baseline ประสิทธิภาพ** ก่อน Lab นี้จะสอนการวัดและบันทึกเมตริกสำคัญของ classical TLS

---

## 🎯 Learning Objectives | วัตถุประสงค์

After this lab, you will be able to:
- Measure TLS handshake latency manually
- Monitor CPU and memory usage during TLS operations  
- Measure throughput (requests per second)
- Analyze packet sizes and bandwidth overhead
- Calculate statistical metrics (mean, median, std dev)

---

## 📊 Metrics We'll Measure | เมตริกที่จะวัด

| Metric | Tool | Purpose |
|--------|------|---------|
| **Handshake Time** | curl, openssl s_time | Time to establish TLS connection |
| **CPU Usage** | top, ps | Processor overhead |
| **Memory Usage** | free, ps | RAM consumption |
| **Throughput** | ab (Apache Bench) | Requests/second capacity |
| **Certificate Size** | openssl, wc | Bandwidth overhead |
| **Packet Size** | tcpdump, wireshark | Network efficiency |

---

## 🚀 Step 1: Handshake Latency (15 min)

### Manual Measurement with curl

```bash
# Single measurement
curl -k -o /dev/null -s -w "Handshake: %{time_connect}s\nTotal: %{time_total}s\n" https://localhost

# Run 20 times and record
for i in {1..20}; do
  curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost
done > handshake_times.txt
```

### Record in Worksheet

📝 **[worksheets/handshake-measurements.md](worksheets/handshake-measurements.md)**

```
Run  | Time (ms)
-----|----------
1    | _______
2    | _______
...  | ...
20   | _______

Calculate:
- Average: _______ ms
- Median: _______ ms
- Min: _______ ms
- Max: _______ ms
- Std Dev: _______ ms
```

### Using openssl s_time (Alternative)

```bash
# Test connections for 30 seconds
openssl s_time -connect localhost:443 -time 30 -new -nbio

# Look for:
# - Number of connections
# - Connections per second
```

---

## 💻 Step 2: CPU & Memory Usage (15 min)

### Monitoring CPU

**Terminal 1: Start monitoring**
```bash
# Monitor NGINX CPU usage
docker stats pqc-target-nginx --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# แสดงเฉพาะ container ที่กำลังทำงาน
docker stats pqc-target-nginx --no-trunc --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

**Terminal 2: Generate load**
```bash
# Generate 100 requests
ab -n 100 -c 10 https://localhost/
```

**Record measurements:**
```
Before load:
- CPU: _______% 
- Memory: _______ MB

During load:
- CPU (peak): _______%
- Memory (peak): _______ MB

After 30s:
- CPU: _______%
- Memory: _______ MB
```

📝 **[worksheets/cpu-memory-log.md](worksheets/cpu-memory-log.md)**

### Detailed CPU Profiling (Optional)

```bash
# If perf is available
sudo perf record -a -g -- sleep 30   # Run while ab is testing
sudo perf report
```

---

## 📈 Step 3: Throughput Testing (15 min)

### Using Apache Bench

```bash
# Test 1: 1000 requests, 10 concurrent
ab -n 1000 -c 10 https://localhost/ 2>&1 | tee ab-test1.txt

# Test 2: 5000 requests, 50 concurrent
ab -n 5000 -c 50 https://localhost/ 2>&1 | tee ab-test2.txt

# Test 3: 10000 requests, 100 concurrent
ab -n 10000 -c 100 https://localhost/ 2>&1 | tee ab-test3.txt
```

### Extract Key Metrics

```bash
# From ab output, find:
grep "Requests per second" ab-test*.txt
grep "Time per request" ab-test*.txt
grep "Transfer rate" ab-test*.txt
```

📝 **Record in [worksheets/throughput-results.md](worksheets/throughput-results.md)**

---

## 📦 Step 4: Certificate & Packet Size (10 min)

### Certificate Size

```bash
# Get certificate chain
openssl s_client -connect localhost:443 -showcerts </dev/null 2>/dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > cert-chain.pem

# Check size
wc -c cert-chain.pem
ls -lh cert-chain.pem
```

**Record:** 
- Certificate chain size: _______ bytes
- Number of certificates: _______

### TLS Handshake Packet Capture

```bash
# Capture first 20 packets
sudo tcpdump -i any -w handshake.pcap 'port 443' -c 20 &
TCPDUMP_PID=$!

# Trigger handshake
curl -k https://localhost > /dev/null

# Stop capture
sleep 1
sudo kill $TCPDUMP_PID

# Analyze with tcpdump
tcpdump -r handshake.pcap -v

# Or use Wireshark
wireshark handshake.pcap &
```

**Record:**
- ClientHello size: _______ bytes
- ServerHello + Certificate: _______ bytes
- Total handshake: _______ bytes

📝 **[worksheets/packet-analysis.md](worksheets/packet-analysis.md)**

---

## 📊 Step 5: Statistical Analysis (15 min)

### Calculate Statistics Manually

Use the handshake times you collected:

```bash
# Sort times
sort -n handshake_times.txt > sorted_times.txt

# Calculate average (using awk)
awk '{ total += $1; count++ } END { print total/count }' handshake_times.txt

# Find median (middle value)
cat sorted_times.txt | sed -n '10p'  # For 20 samples, median is 10th value

# Min and max
head -1 sorted_times.txt  # Min
tail -1 sorted_times.txt  # Max
```

### Using Python (Helper Script)

```bash
python3 scripts/calculate-stats.py handshake_times.txt
```

📝 **Template: [calculations/statistical-formulas.md](calculations/statistical-formulas.md)**

---

## 📋 Step 6: Compile Baseline Report

📝 **Final Report: [worksheets/baseline-summary.md](worksheets/baseline-summary.md)**

```markdown
# Baseline Performance Report
Date: _____________
Configuration: TLS 1.2, ECDHE-RSA-AES256-GCM-SHA384

## Summary Metrics

| Metric | Value | Unit |
|--------|-------|------|
| Avg Handshake Time | _____ | ms |
| Requests/sec | _____ | req/s |
| CPU Usage (idle) | _____ | % |
| CPU Usage (load) | _____ | % |
| Memory Usage | _____ | MB |
| Certificate Size | _____ | bytes |
| Handshake Data | _____ | bytes |

## Observations
- Handshake stability: [consistent / variable]
- CPU efficiency: [low / moderate / high]
- Throughput: [excellent / good / moderate / poor]
```

---

## 🎯 Lab Checklist

Before proceeding to Lab 03:

- [ ] Measured handshake time (20+ samples)
- [ ] Calculated mean, median, std dev
- [ ] Monitored CPU usage (idle and load)
- [ ] Monitored memory usage
- [ ] Ran throughput tests (ab)
- [ ] Measured certificate size
- [ ] Captured packet sizes (optional)
- [ ] Compiled baseline summary
- [ ] **Saved all data** (you'll compare with hybrid PQC later!)

---

## 📁 Files Structure

```
lab s/02-baseline-testing/
├── README.md (this file)
│
├── worksheets/
│   ├── handshake-measurements.md
│   ├── cpu-memory-log.md
│   ├── throughput-results.md
│   ├── packet-analysis.md
│   └── baseline-summary.md ⭐ (final report)
│
├── scripts/
│   ├── calculate-stats.py (calculate mean, median, std dev)
│   ├── monitor-cpu.sh (continuous CPU monitoring)
│   ├── automated-tests.sh (run all tests - optional)
│   └── visualize-results.py (generate charts)
│
├── calculations/
│   ├── statistical-formulas.md (how to calculate manually)
│   └── spreadsheet-template.xlsx (Excel template)
│
└── results/
    ├── handshake_times.txt (your measurements)
    ├── ab-test1.txt
    ├── ab-test2.txt
    └── baseline-summary.json (structured data)
```

---

## 🐛 Troubleshooting

### Issue: ab command not found

```bash
# Ubuntu/Debian
sudo apt-get install apache2-utils

# macOS
brew install httpd
```

### Issue: tcpdump permission denied

```bash
# Run with sudo or add user to pcap group
sudo tcpdump -i any 'port 443'
```

### Issue: Inconsistent measurements

- Run more samples (50-100 instead of 20)
- Close other applications
- Run during low system load
- Check if container is throttled

---

## 💡 Key Takeaways

- **Baseline is critical** for comparing hybrid PQC performance
- **Classical TLS is fast**: ~10-50ms handshakes, 1000+ req/s
- **RSA-2048 certificates are small**: ~1.2KB cert chain
- **CPU usage is low**: <5% idle, 10-30% under load
- **Statistical rigor matters**: Need multiple samples

---

## 🎯 What's Next?

**Lab 03:** Implement hybrid post-quantum TLS (X25519+MLKEM768)  
Then we'll measure again and compare!

<div align="center">

[← Lab 01](../01-manual-discovery/) | [Main](../../README.md) | [Lab 03 →](../03-pqc-hybrid-setup/)

</div>
