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
# Single measurement with curl in container
docker exec pqc-hybrid-nginx curl -k -o /dev/null -s -w "Handshake: %{time_connect}s\nTotal: %{time_total}s\n" https://localhost

# Run 20 times
for i in {1..20}; do
  docker exec pqc-hybrid-nginx curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost 
done > results/handshake_times_hybrid.txt
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


**Terminal 1: Start monitoring (บันทึกต่อเนื่องทุก 2 วินาที)**
```bash
# บันทึก CPU + Memory ลงไฟล์ + แสดงบน terminal พร้อมกัน
# กด Ctrl+C เพื่อหยุด
while true; do
  echo -n "$(date '+%H:%M:%S') | " | tee -a results/cpu-memory-log.txt
  docker stats pqc-hybrid-nginx --no-stream \
    --format "{{.CPUPerc}}\t{{.MemUsage}}" | tee -a results/cpu-memory-log.txt
  sleep 2
done
```


### Generate Load

```bash
# ab ไม่รองรับ TLS 1.3 — ใช้ openssl s_time จาก OQS build ใน container แทน
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_time \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -new -time 30 -www "/"
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

### Throughput Tests

> **หมายเหตุ:** `ab` รองรับแค่ TLS 1.2 ลงไป แต่ nginx ตั้งค่าเป็น TLS 1.3 only
> ใช้ `openssl s_time` จาก OQS build ใน container แทน ซึ่งรองรับ TLS 1.3 + PQC เต็มรูปแบบ

```bash
# Test 1: New handshake ทุกครั้ง (30 วินาที)
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_time \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -new -time 30 -www "/" 2>&1 | tee results/ab-hybrid-test1.txt

# Test 2: Session reuse (ดู keep-alive effect)
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_time \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -reuse -time 30 -www "/" 2>&1 | tee results/ab-hybrid-test2.txt

# Test 3: Longer run สำหรับ stable measurement
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_time \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -new -time 60 -www "/" 2>&1 | tee results/ab-hybrid-test3.txt
```

### Extract Metrics

```bash
grep "connections/user sec" results/ab-hybrid-test*.txt
grep "connections in" results/ab-hybrid-test*.txt
```

**Expected:** 10-30% lower throughput due to handshake overhead

📝 **[worksheets/throughput-results-hybrid.md](worksheets/throughput-results-hybrid.md)**

---

## 📦 Step 4: Certificate & Packet Size (10 min)

### Hybrid Certificate Size

```bash
# Get hybrid certificate chain (ใช้ OQS openssl ใน container เพราะ cert เป็น PQC hybrid)
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_client \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -showcerts </dev/null 2>/dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > results/cert-chain-hybrid.pem

# Check size
wc -c results/cert-chain-hybrid.pem
ls -lh results/cert-chain-hybrid.pem
```

**Record:**
- Hybrid certificate chain: _______ bytes
- Classical (Lab 02): _______ bytes
- **Difference:** _______ bytes (ratio: ___x)

**Expected:** 3-5x larger (5-8 KB vs 1.2 KB)

### Handshake Packet Capture

```bash
# Capture hybrid handshake (container port 443 mapped to host port 8443)
sudo tcpdump -i any -w results/handshake-hybrid.pcap 'port 443 or port 8443' -c 50 &
TCPDUMP_PID=$!

docker exec pqc-hybrid-nginx curl -k -s -o /dev/null https://localhost
sleep 1
sudo kill $TCPDUMP_PID

# Analyze
tcpdump -r results/handshake-hybrid.pcap -v | less
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

### Issue: ab/TLS handshake failed

```bash
# ab ไม่รองรับ TLS 1.3 — ใช้ openssl s_time แทน (ดู Step 3)
# ตรวจสอบว่า container รันอยู่
docker ps | grep pqc-hybrid-nginx

# ทดสอบ connection ด้วย OQS openssl
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_client \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt </dev/null 2>&1 | head -20
```

### Issue: Certificate size seems wrong

```bash
# ต้องใช้ OQS openssl เพราะ cert เป็น PQC hybrid algorithm
docker exec pqc-hybrid-nginx /opt/openssl/bin/openssl s_client \
  -connect localhost:443 -CAfile /etc/nginx/certs/ca-hybrid.crt \
  -showcerts </dev/null 2>&1 | grep "sigalg:"
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
