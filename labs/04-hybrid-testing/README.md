# Lab 04: Hybrid TLS Performance Testing
# การทดสอบประสิทธิภาพ Hybrid TLS

⏱️ **Duration:** 60 minutes  
🎯 **Objective:** Measure hybrid PQC performance using same methods as Lab 02

---

## 📖 Overview | ภาพรวม

Now that hybrid PQC is configured, we'll measure its performance using **exact same tests** as Lab 02. This ensures an **apples-to-apples comparison**.

ตอนนี้ hybrid PQC ตั้งค่าเสร็จแล้ว เราจะวัดประสิทธิภาพด้วย**วิธีการเดียวกันกับ Lab 02 เป๊ะๆ** เพื่อการเปรียบเทียบที่ยุติธรรม

---

## 🎯 Learning Objectives

After this lab, you will:
- Measure hybrid PQC performance systematically
- Compare with classical baseline (Lab 02)
- Understand performance trade-offs
- Identify bottlenecks intro PQC implementations
- Make data-driven migration decisions

---

## 📊 Same Metrics, Same Methods | เมตริกและวิธีการเดียวกัน

We'll measure:
1. ✅ TLS handshake latency
2. ✅ CPU usage
3. ✅ Memory footprint
4. ✅ Throughput (requests/second)
5. ✅ Certificate size
6. ✅ Packet sizes

**Target server:** https://localhost:8443 (hybrid PQC from Lab 03)

---

## 🚀 Step 1: Handshake Latency (15 min)

### Exactly Like Lab 02

```bash
# Single measurement with curl
curl -k -o /dev/null -s -w "Handshake: %{time_connect}s\nTotal: %{time_total}s\n" https://localhost:8443

# Run 20 times
for i in {1..20}; do
  curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost:8443
done > handshake_times_hybrid.txt
```

### Record in Worksheet

📝 **[worksheets/handshake-measurements-hybrid.md](worksheets/handshake-measurements-hybrid.md)**

**Expected:** 2-3x slower than classical (20-100ms vs 10-30ms)

### Compare Immediately

```bash
# Classical (from Lab 02)
echo "Classical average:"
awk '{ total += $1; count++ } END { print total/count }' \
  ../02-baseline-testing/results/handshake_times.txt

# Hybrid (current)
echo "Hybrid average:"
awk '{ total += $1; count++ } END { print total/count }' handshake_times_hybrid.txt
```

---

## 💻 Step 2: CPU & Memory Usage (15 min)

### Same Monitoring, Different Container

```bash
# Monitor hybrid NGINX CPU usage
docker stats pqc-hybrid-nginx --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

### Generate Load

```bash
# Same load as Lab 02
ab -n 100 -c 10 https://localhost:8443/
```

**Record:**
```
Before load:
- CPU: _______% 
- Memory: _______ MB

During load:
- CPU (peak): _______%  [Expected: Higher than classical]
- Memory (peak): _______ MB  [Expected: Similar or slightly higher]
```

📝 **[worksheets/cpu-memory-log-hybrid.md](worksheets/cpu-memory-log-hybrid.md)**

---

## 📈 Step 3: Throughput Testing (15 min)

### Apache Bench - Same Tests

```bash
# Test 1
ab -n 1000 -c 10 https://localhost:8443/ 2>&1 | tee ab-hybrid-test1.txt

# Test 2
ab -n 5000 -c 50 https://localhost:8443/ 2>&1 | tee ab-hybrid-test2.txt

# Test 3
ab -n 10000 -c 100 https://localhost:8443/ 2>&1 | tee ab-hybrid-test3.txt
```

### Extract Metrics

```bash
grep "Requests per second" ab-hybrid-test*.txt
grep "Time per request" ab-hybrid-test*.txt
```

**Expected:** 10-30% lower throughput due to handshake overhead

📝 **[worksheets/throughput-results-hybrid.md](worksheets/throughput-results-hybrid.md)**

---

## 📦 Step 4: Certificate & Packet Size (10 min)

### Hybrid Certificate Size

```bash
# Get hybrid certificate chain
openssl s_client -connect localhost:8443 -showcerts </dev/null 2>/dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > cert-chain-hybrid.pem

# Check size
wc -c cert-chain-hybrid.pem
ls -lh cert-chain-hybrid.pem
```

**Record:**
- Hybrid certificate chain: _______ bytes
- Classical (Lab 02): _______ bytes
- **Difference:** _______ bytes (ratio: ___x)

**Expected:** 3-5x larger (5-8 KB vs 1.2 KB)

### Handshake Packet Capture

```bash
# Capture hybrid handshake
sudo tcpdump -i any -w handshake-hybrid.pcap 'port 8443' -c 30 &
TCPDUMP_PID=$!

curl -k https://localhost:8443 > /dev/null
sleep 1
sudo kill $TCPDUMP_PID

# Analyze
tcpdump -r handshake-hybrid.pcap -v | less
```

**Record total handshake size** and compare with classical

---

## 📊 Step 5: Side-by-Side Comparison (15 min)

### Create Comparison Table

📝 **[worksheets/performance-comparison.md](worksheets/performance-comparison.md)**

| Metric | Classical TLS | Hybrid PQC | Δ | % Change |
|--------|---------------|------------|---|----------|
| Handshake (ms) | _____ | _____ | _____ | _____% |
| CPU Idle (%) | _____ | _____ | _____ | _____% |
| CPU Load (%) | _____ | _____ | _____ | _____% |
| Memory (MB) | _____ | _____ | _____ | _____% |
| Throughput (req/s) | _____ | _____ | _____ | _____% |
| Cert Size (bytes) | _____ | _____ | _____ | _____x |

### Calculate Overhead

```bash
python3 scripts/calculate-overhead.py \
  ../02-baseline-testing/results/baseline-summary.json \
  results/hybrid-summary.json
```

---

## 🎯 Lab Checklist

- [ ] Measured hybrid handshake time (20+ samples)
- [ ] Monitored CPU usage (idle and load)
- [ ] Monitored memory usage
- [ ] Ran throughput tests
- [ ] Measured hybrid certificate size
- [ ] Captured hybrid packet sizes
- [ ] Created side-by-side comparison table
- [ ] Calculated performance overhead (%)
- [ ] Saved all measurements for Lab 05

---

## 📁 Files Structure

```
labs/04-hybrid-testing/
├── README.md (this file)
│
├── worksheets/
│   ├── handshake-measurements-hybrid.md
│   ├── cpu-memory-log-hybrid.md
│   ├── throughput-results-hybrid.md
│   └── performance-comparison.md ⭐
│
├── scripts/
│   ├── calculate-overhead.py (compute % differences)
│   ├── quick-comparison.sh (automated comparison)
│   └── collect-hybrid-metrics.sh (run all tests)
│
└── results/
    ├── handshake_times_hybrid.txt
    ├── ab-hybrid-test1.txt
    ├── ab-hybrid-test2.txt
    └── hybrid-summary.json
```

---

## 💡 Expected Results | ผลลัพธ์ที่คาดหวัง

Based on research literature:

| Metric | Typical Overhead |
|--------|------------------|
| **Handshake Time** | +50% to +200% (15-100ms) |
| **CPU Usage** | +30% to +60% |
| **Memory** | +10% to +30% |
| **Throughput** | -10% to -30% (keep-alive helps!) |
| **Certificate Size** | +300% to +400% (3-5x larger) |
| **Bandwidth** | +100% to +200% (handshake only) |

**Are these acceptable?**
- Handshake happens ONCE per connection
- With connection reuse (keep-alive), amortized over thousands of requests
- For high-security applications: **YES, worthwhile trade-off**

---

## 🔍 Analysis Questions

Answer these based on your measurements:

1. What is the handshake overhead in milliseconds?
2. Is CPU usage significantly higher?
3. Does throughput decrease proportionally to handshake time?
4. How much larger are PQC certificates?
5. Would connection keep-alive help?

📝 **[worksheets/analysis-questions.md](worksheets/analysis-questions.md)**

---

## 🐛 Troubleshooting

### Issue: Much slower than expected

```bash
# Check if running in debug mode
docker exec pqc-hybrid-nginx nginx -V | grep debug

# Check system load
top
```

### Issue: ab can't connect

```bash
# Check if container is running
docker ps | grep pqc-hybrid-nginx

# Check port 8443
curl -k https://localhost:8443
```

### Issue: Certificate size seems wrong

```bash
# Make sure you're getting PQC cert, not classical
openssl s_client -connect localhost:8443 -showcerts | grep "Algorithm:"
```

---

## 💡 Key Takeaways

- **Hybrid PQC has measurable overhead** but not prohibitive
- **Handshake is slower** (cryptographic operations)
- **Bulk encryption unchanged** (still AES-256)
- **With keep-alive**, impact is minimal on long-term throughput
- **Security benefit** outweighs performance cost for most applications
- **Hardware acceleration** (coming soon) will reduce overhead

---

## 🎯 What's Next?

**Lab 05:** Comprehensive analysis and report generation  
We'll visualize data, generate charts, and create professional reports!

<div align="center">

[← Lab 03](../03-pqc-hybrid-setup/) | [Main](../../README.md) | [Lab 05 →](../05-analysis-reporting/)

</div>
