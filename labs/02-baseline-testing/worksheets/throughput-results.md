# Throughput Results Worksheet (Classical TLS Baseline)
# แบบบันทึกผลการทดสอบ Throughput (Baseline)

**Lab:** 02-Baseline Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Test Configuration

**Tool:** Apache Bench (ab)  
**Target:** https://localhost:4431  
**Test scenarios:**
1. Low load: 100 requests, 10 concurrent  
2. Medium load: 1,000 requests, 50 concurrent  
3. High load: 10,000 requests, 100 concurrent

---

## 🚀 Test 1: Low Load

```bash
ab -n 100 -c 10 -k -q https://localhost:4431/
```

**Results:**

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

**Connection Times (ms):**

|      | min | mean | median | max |
|------|-----|------|--------|-----|
| Connect | ____ | ____ | ____ | ____ |
| Processing | ____ | ____ | ____ | ____ |
| Waiting | ____ | ____ | ____ | ____ |
| **Total** | ____ | ____ | ____ | ____ |

---

## 🚀 Test 2: Medium Load

```bash
ab -n 1000 -c 50 -k -q https://localhost:4431/
```

**Results:**

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

**Connection Times (ms):**

|      | min | mean | median | max |
|------|-----|------|--------|-----|
| Connect | ____ | ____ | ____ | ____ |
| Processing | ____ | ____ | ____ | ____ |
| Waiting | ____ | ____ | ____ | ____ |
| **Total** | ____ | ____ | ____ | ____ |

---

## 🚀 Test 3: High Load

```bash
ab -n 10000 -c 100 -k -q https://localhost:4431/
```

**Results:**

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

**Connection Times (ms):**

|      | min | mean | median | max |
|------|-----|------|--------|-----|
| Connect | ____ | ____ | ____ | ____ |
| Processing | ____ | ____ | ____ | ____ |
| Waiting | ____ | ____ | ____ | ____ |
| **Total** | ____ | ____ | ____ | ____ |

---

## 📊 Throughput Comparison

### Requests per Second vs Concurrency

| Load Level | Concurrent | Req/sec | Time/req (ms) |
|------------|------------|---------|---------------|
| Low | 10 | _______ | _______ |
| Medium | 50 | _______ | _______ |
| High | 100 | _______ | _______ |

**Pattern:**
- Does throughput increase with concurrency? [ ] Yes [ ] No
- At what point does it plateau? ___________ concurrent requests

### Visual Chart

```
Throughput (req/s)
    |
8000|                    ●
    |
7000|              ●
    |
6000|        ●
    |
5000|
    |
4000|
    |
3000|
    |
2000|
    |
1000|  ●
    |
   0|________________________________
      10    50    100   150   200
          Concurrency Level
```

---

## 🔍 Latency Distribution

### Percentile Analysis (from ab output)

**High Load Test (10,000 requests, 100 concurrent):**

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

**Analysis:**
- P50 (median): _______ ms
- P95 (95th percentile): _______ ms
- P99 (99th percentile): _______ ms
- Max latency: _______ ms

**Latency spread:**
```
Tail latency = P99 - P50 = _______ ms
Is there a long tail? [ ] Yes (>3x median) [ ] No
```

---

## 🎯 Performance Analysis

### Bottleneck Identification

**Run ab with `time` to see actual duration:**
```bash
time ab -n 10000 -c 100 -k -q https://localhost:4431/
```

**Results:**
- Real time: _______ seconds
- User time: _______ seconds
- Sys time: _______ seconds

**Is it CPU-bound?**
- User + Sys > 90% of Real? [ ] Yes (CPU-bound) [ ] No (I/O-bound)

---

### TLS Handshake Cost

**Measure handshake vs data transfer:**

**Test A: Full handshake (no keep-alive)**
```bash
ab -n 1000 -c 10 -q https://localhost:4431/
# Result: _______ req/s
```

**Test B: Keep-alive (reuse TLS session)**
```bash
ab -n 1000 -c 10 -k -q https://localhost:4431/
# Result: _______ req/s
```

**Handshake overhead:**
```
Improvement = (B - A) / A × 100
            = (_______ - _______) / _______ × 100
            = _______ %
```

**Conclusion:**
- TLS handshake is _____ expensive
- Keep-alive improves throughput by ~_____% 

---

### Scalability Assessment

**Theoretical maximum (back-of-envelope):**

```
CPU cores available: _______
Requests/sec per core: ~_______ (from test / cores used)
Theoretical max throughput: _______ req/s

Actual throughput: _______ req/s
Efficiency: (Actual / Theoretical) = _______%
```

**Why not 100% efficient?**
- [ ] Lock contention
- [ ] I/O waits
- [ ] Context switching
- [ ] Memory bandwidth
- [ ] Other: _________________

---

## 💡 Optimization Ideas

### 1. Connection Pooling

**Current:** New TLS handshake for each connection  
**Improvement:** Keep-alive / HTTP pipelining  
**Expected gain:** ~_____% (from test above)

### 2. CPU Optimization

**Current setup:**
- NGINX workers: _______ (check with `docker exec pqc-nginx-secure ps aux`)
- CPU cores: _______

**Recommendation:**
- Workers should equal CPU cores
- Adjust in nginx.conf: `worker_processes auto;`

### 3. Session Resumption

**Test if session cache is enabled:**
```bash
docker exec pqc-nginx-secure nginx -T | grep ssl_session
```

**Current config:**
```
ssl_session_cache: _________________
ssl_session_timeout: _________________
```

**Recommendation:**
- Enable: `ssl_session_cache shared:SSL:10m;`
- Reduces handshake cost for returning clients

---

## 📦 Baseline Summary

**Record these numbers for Lab 04 comparison:**

| Metric | Low Load | Medium Load | High Load |
|--------|----------|-------------|-----------|
| **Throughput (req/s)** | _______ | _______ | _______ |
| **Latency P50 (ms)** | _______ | _______ | _______ |
| **Latency P95 (ms)** | _______ | _______ | _______ |
| **Transfer rate (KB/s)** | _______ | _______ | _______ |
| **Failed requests** | _______ | _______ | _______ |

---

## ✅ Checkpoint

Verify completion:

- [ ] Completed low, medium, high load tests
- [ ] Recorded throughput (requests/sec)
- [ ] Recorded latency percentiles
- [ ] Analyzed performance bottlenecks
- [ ] Tested keep-alive impact
- [ ] Proposed optimization strategies
- [ ] Saved baseline numbers for Lab 04 comparison

---

<div align="center">

**Next:** [Lab 03: PQC Hybrid Setup →](../../03-pqc-hybrid-setup/README.md)

[← Back to Lab 02](../README.md)

</div>
