# Throughput Results Worksheet (PQC Hybrid)
# แบบบันทึกผลการทดสอบ Throughput (PQC Hybrid)

**Lab:** 04-Hybrid Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Test Configuration

**Tool:** Apache Bench (ab)  
**Target:** https://localhost:8443  
**Test scenarios:**
1. Low load: 100 requests, 10 concurrent  
2. Medium load: 1,000 requests, 50 concurrent  
3. High load: 10,000 requests, 100 concurrent

---

## 🚀 Test 1: Low Load

```bash
ab -n 100 -c 10 -q https://localhost:8443/
```

| Metric | Value | Unit |
|--------|-------|------|
| Total requests | 100 | requests |
| Concurrency level | 10 | |
| Time taken for tests | _______ | seconds |
| **Requests per second** | _______ | req/s |
| **Time per request** (mean) | _______ | ms |
| Time per request (concurrent mean) | _______ | ms |
| **Transfer rate** | _______ | KB/sec |
| Failed requests | _______ | |

---

## 🚀 Test 2: Medium Load

```bash
ab -n 1000 -c 50 -q https://localhost:8443/
```

| Metric | Value | Unit |
|--------|-------|------|
| Total requests | 1,000 | requests |
| Concurrency level | 50 | |
| Time taken for tests | _______ | seconds |
| **Requests per second** | _______ | req/s |
| **Time per request** (mean) | _______ | ms |
| Time per request (concurrent mean) | _______ | ms |
| **Transfer rate** | _______ | KB/sec |
| Failed requests | _______ | |

---

## 🚀 Test 3: High Load

```bash
ab -n 10000 -c 100 -q https://localhost:8443/
```

| Metric | Value | Unit |
|--------|-------|------|
| Total requests | 10,000 | requests |
| Concurrency level | 100 | |
| Time taken for tests | _______ | seconds |
| **Requests per second** | _______ | req/s |
| **Time per request** (mean) | _______ | ms |
| Time per request (concurrent mean) | _______ | ms |
| **Transfer rate** | _______ | KB/sec |
| Failed requests | _______ | |

---

## 🔄 Comparison with Baseline (Classical TLS)

### Retrieve from Lab 02:

**Test 1: Low Load**

| Metric | Classical TLS | PQC Hybrid | Difference | Overhead % |
|--------|---------------|------------|------------|------------|
| Req/sec | _______ | _______ | _______ | _______% |
| Time/req (ms) | _______ | _______ | _______ | _______% |
| Transfer rate | _______ | _______ | _______ | _______% |

**Test 2: Medium Load**

| Metric | Classical TLS | PQC Hybrid | Difference | Overhead % |
|--------|---------------|------------|------------|------------|
| Req/sec | _______ | _______ | _______ | _______% |
| Time/req (ms) | _______ | _______ | _______ | _______% |
| Transfer rate | _______ | _______ | _______ | _______% |

**Test 3: High Load**

| Metric | Classical TLS | PQC Hybrid | Difference | Overhead % |
|--------|---------------|------------|------------|------------|
| Req/sec | _______ | _______ | _______ | _______% |
| Time/req (ms) | _______ | _______ | _______ | _______% |
| Transfer rate | _______ | _______ | _______ | _______% |

---

## 📊 Throughput Degradation Chart

```
Requests per Second
      |
7000  |  ████ Classical
      |  ████
6000  |  ████             
      |  ████ 
5000  |  ████  ▓▓▓▓ PQC
      |  ████  ▓▓▓▓
4000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
3000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
2000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
1000  |  ████  ▓▓▓▓
      |  ████  ▓▓▓▓
    0 |__████__▓▓▓▓_____________________________
        Low   Med   High
```

**Pattern observed:**
- Does PQC perform worse at higher concurrency? [ ] Yes [ ] No
- At what load level is the difference most noticeable? _________

---

## 🔍 Latency Distribution (ab percentiles)

**From ab output:**

```
Percentage of the requests served within a certain time (ms)
  50%  _______
  66%  _______
  75%  _______
  80%  _______
  90%  _______
  95%  _______
  98%  _______
  99%  _______
 100%  _______ (longest request)
```

**Compare 95th percentile with Classical:**
- Classical P95: _______ ms
- PQC Hybrid P95: _______ ms
- Difference: _______ ms (_______%)

---

## 📦 Packet Size Analysis

**Measure certificate size (affects first request):**

```bash
# Classical TLS cert size
ls -lh ~/pqcv2/labs/00-target-app/certs/*.pem
# Size: _______ KB

# PQC Hybrid cert size  
ls -lh ~/pqcv2/labs/03-pqc-hybrid-setup/certs-hybrid/*.pem
# Size: _______ KB

# Increase: _______ KB (_______%)
```

**Impact on transfer rate:**
- Does larger cert affect first request? [ ] Yes [ ] No
- Does session resumption help? [ ] Yes [ ] No (Test with ab -s flag)

---

## 💡 Analysis

### Why is throughput lower for PQC?

**Bottleneck analysis:**

1. **TLS handshake overhead:**
   - PQC handshake takes longer → less time for data transfer
   - More noticeable at high concurrency

2. **Larger certificates:**
   - 3-5 KB PQC cert vs 1-2 KB classical
   - Extra bandwidth consumption

3. **CPU saturation:**
   - PQC crypto operations consume more CPU
   - At high load, CPU becomes bottleneck

**Use `top` or `htop` during ab test:**
```bash
# In another terminal
top -p $(docker inspect -f '{{.State.Pid}}' pqc-hybrid-nginx)
```

- CPU usage during high load: _______%
- Is CPU at 100%? [ ] Yes [ ] No

**If CPU at 100%:** CPU-bound (bottleneck is crypto operations)  
**If CPU < 80%:** Network or other bottleneck

---

### Scaling Considerations

**How many requests/sec do you need?**
- Expected traffic: _______ req/s
- PQC hybrid capacity: _______ req/s
- Sufficient? [ ] Yes [ ] No

**If insufficient, how to scale?**

1. **Vertical scaling:**
   - Add more CPU cores
   - Expected capacity: _______ req/s with _____ cores

2. **Horizontal scaling:**
   - Add more servers (load balancer)
   - Expected capacity: _______ req/s with _____ servers

3. **Session resumption:**
   - Cache TLS sessions (avoid full handshake)
   - Expected improvement: ~_____% throughput increase

---

## 🎯 Throughput Assessment

**Is PQC throughput acceptable?**

| Load Level | PQC Throughput | Required | Status |
|------------|----------------|----------|--------|
| Low | _______ req/s | _______ req/s | [ ] ✅ OK [ ] ❌ Insufficient |
| Medium | _______ req/s | _______ req/s | [ ] ✅ OK [ ] ❌ Insufficient |
| High | _______ req/s | _______ req/s | [ ] ✅ OK [ ] ❌ Insufficient |

**Overall verdict:**
- [ ] ✅ Throughput acceptable for our use case
- [ ] ⚠️ Need optimization (session caching, etc.)
- [ ] ❌ Must scale horizontally (add more servers)

---

## ✅ Checkpoint

Verify completion:

- [ ] Tested low, medium, high load scenarios
- [ ] Recorded requests/sec and time/request
- [ ] Compared with classical TLS baseline
- [ ] Calculated throughput overhead
- [ ] Analyzed reasons for degradation
- [ ] Assessed if throughput meets requirements
- [ ] Proposed scaling strategy if needed

---

<div align="center">

**Next:** [Performance Comparison Summary →](performance-comparison.md)

[← Back to Lab 04](../README.md)

</div>
