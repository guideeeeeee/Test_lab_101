# Performance Comparison Summary
# สรุปการเปรียบเทียบประสิทธิภาพ Classical TLS vs PQC Hybrid

**Lab:** 04-Hybrid Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📊 Executive Summary

**Test Environment:**
- Classical TLS: RSA-2048 + ECDHE-P256 + AES-GCM
- PQC Hybrid: X25519+ML-KEM-768 (KEM) + ECDSA+ML-DSA-65 (Sig) + AES-GCM

**Overall Assessment:**

| Category | Status | Notes |
|----------|--------|-------|
| **Handshake Time** | [ ] ✅ Acceptable [ ] ⚠️ Marginal [ ] ❌ Too slow | |
| **CPU Usage** | [ ] ✅ Acceptable [ ] ⚠️ Marginal [ ] ❌ Too high | |
| **Memory Usage** | [ ] ✅ Acceptable [ ] ⚠️ Marginal [ ] ❌ Too high | |
| **Throughput** | [ ] ✅ Acceptable [ ] ⚠️ Marginal [ ] ❌ Too low | |

---

## 🔐 TLS Handshake Performance

### Raw Measurements

| Metric | Classical TLS | PQC Hybrid | Difference | Overhead % |
|--------|---------------|------------|------------|------------|
| **Mean handshake time** | _______ ms | _______ ms | _______ ms | _______% |
| **Median handshake time** | _______ ms | _______ ms | _______ ms | _______% |
| **95th percentile (P95)** | _______ ms | _______ ms | _______ ms | _______% |
| **Standard deviation** | _______ ms | _______ ms | _______ ms | _______% |

**Source:**
- Classical: [Lab 02 Handshake Measurements](../../02-baseline-testing/worksheets/handshake-measurements.md)
- PQC Hybrid: [Lab 04 Handshake Measurements](handshake-measurements-hybrid.md)

### Visual Comparison

```
Handshake Time Distribution

Frequency
    |              Classical (RSA+ECDHE)
    |              ╭──────────╮
    |         ╭────┤  ▒▒▒▒▒▒  ├────╮
    |    ╭────┤    │  ▒▒▒▒▒▒  │    ├────╮
    |────┤    │    │  ▒▒▒▒▒▒  │    │    ├─────
    |____|____|____|__▒▒▒▒▒▒__|____|____↓________
        10   15   20   25   30   35   40  45  50 ms
                           
                           PQC Hybrid (ML-KEM+ML-DSA)
                           ╭──────────────╮
                      ╭────┤   ▓▓▓▓▓▓▓▓   ├────╮
                 ╭────┤    │   ▓▓▓▓▓▓▓▓   │    ├────╮
            ─────┤    │    │   ▓▓▓▓▓▓▓▓   │    │    ├─────
        _________|____|____|___▓▓▓▓▓▓▓▓___|____|____|_______
                      30   40   50   60   70   80 ms
```

### Analysis

**Why is PQC hybrid slower?**

1. **ML-KEM-768 Encapsulation:**
   - Operation: Encapsulate shared secret with ML-KEM public key
   - Cost: ~0.1-0.2 ms (lattice-based matrix operations)
   - vs ECDHE: ~0.05 ms

2. **ML-DSA-65 Signature Verification:**
   - Operation: Verify server certificate signature
   - Cost: ~1-2 ms (polynomial arithmetic)
   - vs ECDSA P-256: ~0.5 ms

3. **Larger Certificate Processing:**
   - PQC cert size: ~4-5 KB (vs ~1-2 KB classical)  
   - Parsing overhead: ~0.1-0.2 ms extra

**Combined overhead:** ~_______ms (_______%)

**Is this acceptable?**
- For most web applications: [ ] Yes (user won't notice <100ms difference)
- For high-frequency trading: [ ] No (every ms counts)
- For IoT devices: [ ] Depends (CPU constraints)

---

## 💻 CPU & Memory Impact

### CPU Usage

| Load State | Classical TLS | PQC Hybrid | Overhead % |
|------------|---------------|------------|------------|
| **Idle** | _______% | _______% | _______% |
| **Average (under load)** | _______% | _______% | _______% |
| **Peak** | _______% | _______% | _______% |

**Source:**
- Classical: [Lab 02 CPU/Memory Log](../../02-baseline-testing/worksheets/cpu-memory-log.md)
- PQC Hybrid: [Lab 04 CPU/Memory Log](cpu-memory-log-hybrid.md)

### Memory Usage

| Load State | Classical TLS | PQC Hybrid | Overhead % |
|------------|---------------|------------|------------|
| **Idle** | _______ MiB | _______ MiB | _______% |
| **Under load** | _______ MiB | _______ MiB | _______% |
| **Per connection** | _______ KiB | _______ KiB | _______% |

### Cost Projection

**For 10,000 concurrent connections:**

| Resource | Classical | PQC Hybrid | Extra Cost |
|----------|-----------|------------|------------|
| **CPU cores needed** | _______ | _______ | _______ cores |
| **RAM needed** | _______ GB | _______ GB | _______ GB |
| **AWS EC2 cost/month** | $_______ | $_______ | +$_______ |

---

## 🚀 Throughput Comparison

### Requests per Second

| Load Level | Classical TLS | PQC Hybrid | Degradation % |
|------------|---------------|------------|---------------|
| **Low (10 concurrent)** | _______ req/s | _______ req/s | _______% |
| **Medium (50 concurrent)** | _______ req/s | _______ req/s | _______% |
| **High (100 concurrent)** | _______ req/s | _______ req/s | _______% |

**Source:**
- Classical: [Lab 02 Throughput Results](../../02-baseline-testing/worksheets/throughput-results.md)
- PQC Hybrid: [Lab 04 Throughput Results](throughput-results-hybrid.md)

### Latency Percentiles (High Load)

| Percentile | Classical TLS | PQC Hybrid | Difference |
|------------|---------------|------------|------------|
| **P50 (median)** | _______ ms | _______ ms | +_______ms |
| **P95** | _______ ms | _______ ms | +_______ms |
| **P99** | _______ ms | _______ ms | +_______ms |
| **Max** | _______ ms | _______ ms | +_______ms |

### Visual Throughput Comparison

```
Throughput (req/s)
      |
9000  |  ████ Classical TLS
      |  ████
8000  |  ████             
      |  ████ 
7000  |  ████  
      |  ████  
6000  |  ████  ▓▓▓▓ PQC Hybrid
      |  ████  ▓▓▓▓
5000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
4000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
3000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
2000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
1000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
    0 |__████__▓▓▓▓__████__▓▓▓▓__████__▓▓▓▓_______
        |Low|      |Med|      |High|
```

---

## 📈 Trend Analysis

### Does overhead increase with load?

**Overhead % at different loads:**

| Load Level | Handshake Overhead | CPU Overhead | Throughput Degradation |
|------------|-------------------|--------------|------------------------|
| Low | _______% | _______% | _______% |
| Medium | _______% | _______% | _______% |
| High | _______% | _______% | _______% |

**Pattern:**
- [ ] Constant overhead (scales linearly)
- [ ] Increasing overhead (bottleneck at high load)
- [ ] Decreasing overhead (amortized cost improves)

**Reason:**
_________________________________________________________________

---

## 🎯 Practical Decision Matrix

### Use Case Assessment

**Scenario 1: Public-facing web application**
- Expected traffic: _______ req/s (peak)
- PQC capacity: _______ req/s
- Verdict: [ ] ✅ Sufficient [ ] ⚠️ Need scaling [ ] ❌ Not feasible

**Scenario 2: API server (backend)**
- Expected load: _______ req/s
- Latency SLA: _______ ms (P99)
- PQC P99 latency: _______ ms
- Verdict: [ ] ✅ Meets SLA [ ] ⚠️ Close [ ] ❌ Exceeds SLA

**Scenario 3: IoT gateway**
- Device CPU: _______ (e.g., ARM Cortex-A53)
- PQC handshake time on device: _______ ms (estimate)
- Battery impact: [ ] ✅ Negligible [ ] ⚠️ Moderate [ ] ❌ Significant

---

## 💡 Optimization Recommendations

### Quick Wins (Low Effort, High Impact)

1. **Enable Session Resumption**
   - Saves full handshake for returning clients
   - Expected savings: ~70-80% handshake cost
   - Implementation: Already in nginx.conf

2. **Connection Keep-Alive**
   - Reuse TLS connection for multiple requests
   - Benefit: Amortize handshake overhead
   - Status: [ ] Enabled [ ] Not enabled

3. **Hardware Acceleration**
   - Use AVX2/AVX-512 CPU instructions for ML-KEM
   - Expected speedup: 2-3x
   - Check: `lscpu | grep avx` → _________________

### Medium Effort Optimizations

4. **Tune NGINX Workers**
   ```nginx
   worker_processes auto;  # Match CPU cores
   worker_connections 1024;  # Adjust based on load
   ```

5. **Caching Strategy**
   - Cache static content aggressively (reduce TLS load)
   - Use CDN for static assets

6. **Algorithm Selection**
   - Try ML-KEM-512 (faster, but 128-bit security vs 192-bit)
   - Try Falcon-512 instead of Dilithium (smaller sig, but slower verify)

### High Effort (Major Changes)

7. **Horizontal Scaling**
   - Add more PQC-enabled servers
   - Use load balancer
   - Cost: +_______ servers needed

8. **Traffic Migration Strategy**
   - Phase 1: PQC for 10% of traffic (canary)
   - Phase 2: PQC for internal traffic only
   - Phase 3: Gradual rollout to 100%

---

## ✅ Final Assessment

### Overall Overhead Summary

| Category | Overhead % | Acceptable? |
|----------|------------|-------------|
| Handshake Time | _______% | [ ] Yes [ ] No |
| CPU Usage | _______% | [ ] Yes [ ] No |
| Memory Usage | _______% | [ ] Yes [ ] No |
| Throughput | _______% degradation | [ ] Yes [ ] No |

### Migration Recommendation

**Based on your measurements, do you recommend migrating to PQC hybrid?**

- [ ] ✅ **Yes, migrate now**
  - Reason: _________________________________________________

- [ ] ⚠️ **Yes, but with optimizations**
  - Must implement: ________________________________________
  - ________________________________________________________

- [ ] ⏸️ **Wait for hardware/software improvements**
  - Blockers: _______________________________________________

- [ ] ❌ **No, not feasible**
  - Reason: _________________________________________________

### Risk vs Benefit

**Risk of NOT migrating:**
- [ ] High: Critical infrastructure, high-value data
- [ ] Medium: Important data, but not immediately critical
- [ ] Low: Can wait for CNSA 2.0 (2030+) timeline

**Cost of migrating:**
- Development effort: _______ person-days
- Infrastructure cost: $_______ / month
- Performance trade-off: _______% degradation

**Decision:**
- [ ] Benefit >> Cost → Migrate
- [ ] Benefit ≈ Cost → Monitor and prepare
- [ ] Benefit << Cost → Defer

---

## 📝 Key Takeaways

**3 most important insights from this comparison:**

1. _________________________________________________________________

2. _________________________________________________________________

3. _________________________________________________________________

**What surprised you the most?**

_________________________________________________________________

**What would you tell management?**

_________________________________________________________________

---

## ✅ Checkpoint

Verify completion:

- [ ] Compared handshake times (mean, P95, P99)
- [ ] Compared CPU usage (idle, average, peak)
- [ ] Compared memory usage
- [ ] Compared throughput (low, medium, high load)
- [ ] Calculated overhead percentages for all metrics
- [ ] Assessed practical feasibility for your use case
- [ ] Proposed optimization strategies
- [ ] Made final migration recommendation

---

<div align="center">

**Next:** [Analysis Questions →](analysis-questions.md)

[← Back to Lab 04](../README.md)

</div>
