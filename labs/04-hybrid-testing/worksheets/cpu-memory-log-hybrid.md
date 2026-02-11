# CPU & Memory Monitoring Worksheet (PQC Hybrid)
# แบบบันทึกการใช้ CPU และ Memory (PQC Hybrid)

**Lab:** 04-Hybrid Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Monitoring Setup

**Target Container:** `pqc-hybrid-nginx`  
**Duration:** 5 minutes of load testing  
**Load Tool:** Apache Bench (ab) - 100 requests, 10 concurrent

---

## 💻 CPU Usage Monitoring

### Method: docker stats

```bash
# Run in one terminal
docker stats pqc-hybrid-nginx --no-stream --format "{{.CPUPerc}}" 

# While running ab in another terminal
ab -n 1000 -c 10 -q https://localhost:8443/
```

**Record CPU % every 10 seconds:**

| Time | CPU % | Load State |
|------|-------|------------|
| 0:00 | _____ | Idle |
| 0:10 | _____ | |
| 0:20 | _____ | |
| 0:30 | _____ | |
| 0:40 | _____ | |
| 0:50 | _____ | |
| 1:00 | _____ | Under load |
| 1:10 | _____ | |
| 1:20 | _____ | |
| 1:30 | _____ | |
| 1:40 | _____ | |
| 1:50 | _____ | |
| 2:00 | _____ | |

**Statistics:**
- Idle (baseline) CPU: _______%
- Peak CPU: _______%
- Average under load: _______%

---

## 🧠 Memory Usage Monitoring

**Record Memory usage:**

| Time | Memory (MiB) | Memory % |
|------|--------------|----------|
| 0:00 (idle) | _______ | _____% |
| During load | _______ | _____% |
| After load | _______ | _____% |

**Memory change:**
```
Increase = Peak - Idle
Increase = _______ - _______ = _______ MiB
```

---

## 🔄 Comparison with Baseline (Classical TLS)

**Retrieve from Lab 02:**

| Metric | Classical TLS | PQC Hybrid | Difference | Overhead % |
|--------|---------------|------------|------------|------------|
| **CPU (idle)** | _____% | _____% | _____% | _____% |
| **CPU (peak)** | _____% | _____% | _____% | _____% |
| **CPU (avg load)** | _____% | _____% | _____% | _____% |
| **Memory (idle)** | _____ MiB | _____ MiB | _____ MiB | _____% |
| **Memory (load)** | _____ MiB | _____ MiB | _____ MiB | _____% |

### Calculate Overhead:
```
CPU overhead = ((PQC_CPU - Classical_CPU) / Classical_CPU) × 100
Memory overhead = ((PQC_Memory - Classical_Memory) / Classical_Memory) × 100
```

**Your calculations:**
- CPU overhead: _______% 
- Memory overhead: _______%

---

## 📊 Visual Comparison  

```
CPU Usage (%)
    |
100 |
    |
 80 |                    ╭────╮
    |               ╭────╯    ╰────╮
 60 |          ╭────╯  PQC         ╰────╮
    |     ╭────╯    ╭────Classical──────╰────╮
 40 |─────╯         ╯                         ╰─────
    |
 20 |
    |
  0 |_____________________________________________
      Idle      Load Start      Peak        Cool Down
```

---

## 🎯 Analysis

### Why does PQC use more CPU?

**Operations that consume more CPU:**
1. **ML-KEM-768 operations:**
   - Encapsulation: Uses lattice-based math (matrix operations)
   - More complex than X25519

2. **ML-DSA-65 verification:**
   - Signature verification involves polynomial arithmetic
   - Typically 2-3x slower than ECDSA

3. **Larger data processing:**
   - Bigger certificates → more parsing
   - Larger keys → more memory operations

**Which is the bottleneck?**
- [ ] ML-KEM encapsulation
- [ ] ML-DSA signature verification
- [ ] Data transfer (larger packets)
- [ ] Certificate processing

---

### Memory Usage Analysis

**Why does PQC use more memory?**

1. **Larger keys in memory:**
   - ECDSA P-256: 64 bytes
   - ML-DSA-65: 1,952 bytes
   - **Impact:** ~30x larger public key

2. **Certificate cache:**
   - Classical cert: ~1-2 KB
   - PQC hybrid cert: ~4-5 KB
   - **Impact:** 2-3x more memory per cached cert

3. **Connection state:**
   - Each TLS session stores keys
   - PQC keys larger → more memory per connection

**Calculate memory per connection:**
```
Classical TLS:   RSA-2048 + ECDHE = ~500 bytes/connection
PQC Hybrid:      ML-KEM + ML-DSA = ~_____ bytes/connection
Increase:        ~_____ bytes extra per connection
```

**For 10,000 concurrent connections:**
```
Extra memory = 10,000 × _____ bytes = _____ MB
```

---

## 💡 Optimization Strategies

### CPU Optimization

1. **Hardware acceleration:**
   ```bash
   # Check for AVX2/AVX-512 support (helps ML-KEM)
   lscpu | grep -i avx
   ```
   - AVX2 available: [ ] Yes [ ] No
   - Expected speedup: ~2-3x

2. **Algorithm selection:**
   - Use ML-KEM-512 instead of 768? (Lower security)
   - Use Falcon instead of Dilithium? (Smaller but slower)

3. **Connection pooling:**
   - Reuse TLS connections → amortize handshake cost

### Memory Optimization

1. **Certificate compression:**
   - Use certificate compression (RFC 8879)
   - Expected savings: ~30-40%

2. **Session resumption:**
   - Store session tickets instead of full keys
   - Savings: ~80% memory per resumed session

3. **Connection limits:**
   - Set `worker_connections` appropriately
   - Monitor and tune based on actual memory usage

---

## 🎯 Acceptability Assessment

**Is the resource overhead acceptable?**

| Resource | Overhead | Acceptable? | Reason |
|----------|----------|-------------|--------|
| CPU | _____% | [ ] Yes [ ] No | |
| Memory | _____% | [ ] Yes [ ] No | |

**Overall verdict:**
- [ ] ✅ Acceptable - Proceed with PQC migration
- [ ] ⚠️ Marginal - Monitor in production
- [ ] ❌ Too high - Need optimization first

**Considerations:**
- Do you have spare CPU capacity? _____% available
- Do you have spare RAM? _____ GB available  
- Can you scale horizontally? [ ] Yes [ ] No
- What's the cost of NOT migrating? (Quantum threat)

---

## ✅ Checkpoint

Verify you've completed:

- [ ] Monitored CPU usage (idle, load, peak)
- [ ] Monitored memory usage
- [ ] Compared with classical TLS baseline
- [ ] Calculated overhead percentages
- [ ] Analyzed reasons for overhead
- [ ] Proposed optimization strategies
- [ ] Assessed if overhead is acceptable

---

<div align="center">

**Next:** [Throughput Testing →](throughput-results-hybrid.md)

[← Back to Lab 04](../README.md)

</div>
