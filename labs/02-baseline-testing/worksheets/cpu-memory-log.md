# CPU & Memory Monitoring Worksheet (Classical TLS Baseline)
# แบบบันทึกการใช้ CPU และ Memory (Baseline)

**Lab:** 02-Baseline Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Monitoring Setup

**Target Container:** `pqc-nginx-secure`  
**Duration:** 5 minutes of load testing  
**Load Tool:** Apache Bench (ab) - 1000 requests, 10 concurrent

---

## 💻 CPU Usage Monitoring

### Method: docker stats

```bash
# Terminal 1: บันทึกต่อเนื่องทุก 2 วินาที พร้อม timestamp
# กด Ctrl+C เพื่อหยุด
while true; do
  echo -n "$(date '+%H:%M:%S') | " | tee -a cpu-memory-log.txt
  docker stats pqc-nginx-secure --no-stream \
    --format "{{.CPUPerc}} | {{.MemUsage}}" | tee -a cpu-memory-log.txt
  sleep 2
done

# Terminal 2: รัน load test
ab -n 1000 -c 10 -k -q https://localhost:4431/
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
| 2:00 | _____ | Cooling down |
| 2:10 | _____ | |

**Statistics:**
- Idle (baseline) CPU: _______%
- Peak CPU: _______%
- Average under load: _______%
- Cool down CPU: _______%

**Calculation:**
```
CPU load increase = Peak - Idle
                  = _______ - _______ = _______%
```

---

## 🧠 Memory Usage Monitoring

**Record Memory usage (MiB):**

| Time | Memory (MiB) | Memory % | State |
|------|--------------|----------|-------|
| 0:00 (idle) | _______ | _____% | Idle |
| 1:00 (load start) | _______ | _____% | Starting load |
| 1:30 (during load) | _______ | _____% | Under load |
| 2:00 (peak) | _______ | _____% | Peak |
| 3:00 (after load) | _______ | _____% | Cooling down |

**Memory change:**
```
Increase = Peak - Idle
Increase = _______ - _______ = _______ MiB
Percentage increase = (Increase / Idle) × 100 = _______%
```

---

## 📊 Detailed docker stats Output

### Continuous Monitoring

```bash
# ดู snapshot ค่าปัจจุบันครั้งเดียว (สำหรับบันทึก manual)
docker stats pqc-nginx-secure --no-stream \
  --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}\t{{.NetIO}}"
```

**Sample 1 (Idle):**
```
CONTAINER          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O
pqc-nginx-secure   _____     _____ / _____         _____     _____ / _____  _____ / _____
```

**Sample 2 (Under Load):**
```
CONTAINER          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O
pqc-nginx-secure   _____     _____ / _____         _____     _____ / _____  _____ / _____
```

**Sample 3 (Peak):**
```
CONTAINER          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O
pqc-nginx-secure   _____     _____ / _____         _____     _____ / _____  _____ / _____
```

---

## 🔍 Process-Level Monitoring (Advanced)

### Using `top` inside container

```bash
# Enter container
docker exec -it pqc-nginx-secure sh

# Inside container, run:
top

# Record nginx worker process stats
```

**NGINX master process:**
- PID: _______
- CPU %: _______
- MEM %: _______

**NGINX worker processes:**

| Worker PID | CPU % | MEM % | TIME+ |
|------------|-------|-------|-------|
| _______ | _____ | _____ | _____ |
| _______ | _____ | _____ | _____ |
| _______ | _____ | _____ | _____ |
| _______ | _____ | _____ | _____ |

---

## 📈 Visual Comparison

### CPU Over Time

```
CPU Usage (%)
    |
100 |
    |
 80 |
    |
 60 |              ╭────╮
    |         ╭────╯    ╰────╮
 40 |    ╭────╯              ╰────╮
    |────╯                        ╰─────
 20 |
    |
  0 |________________________________________
     00:00   00:30   01:00   01:30   02:00
     Idle    Load    Peak    Load    Cool
                     Start    End    Down
```

**Draw your actual data here:**

---

## 🧪 Load Patterns Analysis

### Different Load Types

**Test A: Short burst (100 requests, 10 concurrent)**
```bash
ab -n 100 -c 10 -k -q https://localhost:4431/
```
- Peak CPU: _______%
- Peak Memory: _______ MiB

**Test B: Sustained load (10,000 requests, 50 concurrent)**
```bash
ab -n 10000 -c 50 -k -q https://localhost:4431/
```
- Peak CPU: _______%
- Peak Memory: _______ MiB

**Test C: High concurrency (10,000 requests, 200 concurrent)**
```bash
ab -n 10000 -c 200 -k -q https://localhost:4431/
```
- Peak CPU: _______%
- Peak Memory: _______ MiB

**Pattern:**
- Does CPU scale linearly with concurrency? [ ] Yes [ ] No
- Does Memory increase with concurrency? [ ] Yes [ ] No

---

## 💡 Analysis

### CPU Usage

**What consumes CPU in TLS handshake?**

1. **RSA operations:**
   - Private key operations (signing)
   - Certificate verification

2. **ECDHE key exchange:**
   - Elliptic curve operations
   - Shared secret derivation  

3. **Symmetric encryption:**
   - AES-GCM encryption/decryption
   - (Relatively cheap)

**Expected costs:**
- RSA-2048 signature: ~1-2 ms
- ECDHE-P256 operations: ~0.5 ms
- Total handshake: ~_______ms (measure with testssl.sh)

---

### Memory Usage

**What consumes memory?**

1. **TLS session state:**
   - Each connection stores:
     - Session keys (~64 bytes)
     - Certificates (~1-2 KB cached)
     - Connection metadata

2. **NGINX buffers:**
   - Read buffers
   - Write buffers  
   - Proxy buffers (if used)

3. **SSL library (OpenSSL):**
   - Internal structures
   - Session cache

**Estimate memory per connection:**
```
Per-connection overhead = (Memory under load - Idle memory) / Concurrent connections
                        = (_______ - _______) / _______ = _______ KiB/connection
```

**For 10,000 concurrent connections:**
```
Required memory = 10,000 × _______ KiB = _______ MiB
```

---

## 🎯 Baseline Established

**Record these baseline numbers for Lab 04 comparison:**

| Metric | Value | Unit |
|--------|-------|------|
| **CPU (idle)** | _______ | % |
| **CPU (average load)** | _______ | % |
| **CPU (peak)** | _______ | % |
| **Memory (idle)** | _______ | MiB |
| **Memory (load)** | _______ | MiB |
| **Memory per connection** | _______ | KiB |

---

## ✅ Checkpoint

Verify completion:

- [ ] Monitored CPU (idle, load, peak)
- [ ] Monitored Memory (idle, load, peak)
- [ ] Tested multiple load patterns
- [ ] Calculated per-connection resource usage
- [ ] Recorded baseline for future comparison
- [ ] Drew visual representation of CPU/Memory over time

---

<div align="center">

**Next:** [Throughput Testing →](throughput-results.md)

[← Back to Lab 02](../README.md)

</div>
