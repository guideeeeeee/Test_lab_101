# Baseline Performance Report
# รายงานผล Baseline ประสิทธิภาพ (Classical TLS)

**Lab:** 02-Baseline Testing  
**Student Name:** _________________________  
**Date:** _________________________  
**Configuration:** TLS with ECDHE-RSA, AES-256-GCM-SHA384

---

## 1. Handshake Latency

> วัดจาก [worksheets/handshake-measurements.md](handshake-measurements.md)

| Metric | Value | Unit |
|--------|-------|------|
| **Mean** | _______ | ms |
| **Median** | _______ | ms |
| **Std Dev** | _______ | ms |
| **Min** | _______ | ms |
| **Max** | _______ | ms |
| **P95** | _______ | ms |
| **P99** | _______ | ms |
| Samples | 20 | runs |

**Commands used:**
```bash
for i in {1..20}; do
  curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost:4431
done > handshake_times_4431.txt

python3 ../../../scripts/calculate-stats.py --stdin < handshake_times_4431.txt
```

---

## 2. CPU & Memory Usage

> วัดจาก [worksheets/cpu-memory-log.md](cpu-memory-log.md)

| State | CPU % | Memory (MiB) |
|-------|-------|--------------|
| **Idle (before load)** | _______ | _______ |
| **Under load (avg)** | _______ | _______ |
| **Peak** | _______ | _______ |
| **After load (cool down)** | _______ | _______ |

**CPU increase under load:**
```
Load increase = Peak - Idle = _______ - _______ = _______% 
```

**Load test used:**
```bash
# Terminal 1: บันทึกต่อเนื่องทุก 2 วินาที
while true; do
  echo -n "$(date '+%H:%M:%S') | " | tee -a cpu-memory-log.txt
  docker stats pqc-nginx-secure --no-stream \
    --format "{{.CPUPerc}} | {{.MemUsage}}" | tee -a cpu-memory-log.txt
  sleep 2
done

# Terminal 2: generate load
ab -n 1000 -c 10 -k -q https://localhost:4431/
```

---

## 3. Throughput

> วัดจาก [worksheets/throughput-results.md](throughput-results.md)

| Load Level | Concurrent | Requests/sec | Latency P50 (ms) | Latency P95 (ms) | Failed |
|------------|------------|--------------|------------------|------------------|--------|
| **Low** | 10 (100 req) | _______ | _______ | _______ | _______ |
| **Medium** | 50 (1,000 req) | _______ | _______ | _______ | _______ |
| **High** | 100 (10,000 req) | _______ | _______ | _______ | _______ |

**Keep-alive impact:**

| Mode | Requests/sec | Improvement |
|------|--------------|-------------|
| No keep-alive | _______ | — |
| Keep-alive (`-k`) | _______ | +_______ % |

---

## 4. Certificate & Packet Sizes

> วัดจาก [worksheets/packet-analysis.md](packet-analysis.md)

| Metric | Value | Unit |
|--------|-------|------|
| **Certificate chain size** | _______ | bytes |
| Number of certificates | _______ | |
| **ClientHello size** | _______ | bytes |
| **ServerHello + Certificate** | _______ | bytes |
| **Total TLS handshake data** | _______ | bytes |

---

## 5. TLS Configuration Details

```bash
# Verify by running:
openssl s_client -connect localhost:4431 </dev/null 2>/dev/null | \
  grep -E "Protocol|Cipher|Subject"
```

| Parameter | Value |
|-----------|-------|
| TLS Protocol version | _______ |
| Cipher suite | _______ |
| Certificate type | RSA-2048 |
| Key exchange | ECDHE |

---

## 6. Observations

**Handshake stability:**  
[ ] Consistent (std dev < 10% of mean)  
[ ] Slightly variable (std dev 10–25%)  
[ ] Very variable (std dev > 25%)  

Notes: _________________________________________________

**CPU efficiency:**  
[ ] Low overhead (< 5% idle, < 20% under load)  
[ ] Moderate (5–10% idle, 20–40% under load)  
[ ] High overhead (> 10% idle or > 40% under load)  

Notes: _________________________________________________

**Throughput rating:**  
[ ] Excellent (> 5,000 req/s)  
[ ] Good (1,000–5,000 req/s)  
[ ] Moderate (200–1,000 req/s)  
[ ] Poor (< 200 req/s)  

Notes: _________________________________________________

---

## 7. ⭐ Master Comparison Table

> ตารางนี้จะถูกเติมอีกครั้งใน Lab 04 หลังทดสอบ PQC Hybrid

| Metric | Classical TLS (this lab) | PQC Hybrid (Lab 04) | Difference |
|--------|--------------------------|---------------------|------------|
| Avg Handshake Time (ms) | _______ | _______ | _______ |
| Requests/sec (high load) | _______ | _______ | _______ |
| CPU idle (%) | _______ | _______ | _______ |
| CPU under load (%) | _______ | _______ | _______ |
| Memory usage (MiB) | _______ | _______ | _______ |
| Certificate size (bytes) | _______ | _______ | _______ |
| ClientHello size (bytes) | _______ | _______ | _______ |
| Total handshake data (bytes) | _______ | _______ | _______ |

---

## ✅ Lab 02 Checklist

Before proceeding to Lab 03:

- [ ] Measured handshake time (20+ samples)
- [ ] Calculated mean, median, std dev
- [ ] Monitored CPU usage (idle and under load)
- [ ] Monitored memory usage
- [ ] Ran throughput tests (low / medium / high load)
- [ ] Measured certificate chain size
- [ ] Captured and analyzed TLS handshake packets
- [ ] Compiled this baseline summary
- [ ] **Saved all raw data** – you'll compare with PQC Hybrid in Lab 04!

---

<div align="center">

**Next Step:** [Lab 03: PQC Hybrid Setup →](../../03-pqc-hybrid-setup/README.md)

[← Back to Lab 02](../README.md)

</div>
