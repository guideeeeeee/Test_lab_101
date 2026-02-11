# TLS Handshake Measurements Worksheet (PQC Hybrid)
# แบบบันทึกผลการวัดเวลา TLS Handshake (PQC Hybrid)

**Lab:** 04-Hybrid Testing (PQC Hybrid TLS)  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Test Configuration

| Parameter | Value |
|-----------|-------|
| Target Server | https://localhost:8443 |
| TLS Version | TLS 1.3 (PQC-enabled) |
| Key Exchange | X25519+ML-KEM-768 (hybrid) |
| Signature | ECDSA+ML-DSA-65 (hybrid) |
| Certificate Type | Hybrid PQC |
| Test Tool | curl / openssl s_time |
| Number of Tests | 20 |

---

## ⏱️ Measurement Data

### Run curl 20 times and record results:

```bash
for i in {1..20}; do
  echo -n "Run $i: "
  curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost:8443
done
```

| Run | Time (seconds) | Time (ms) | Notes |
|-----|----------------|-----------|-------|
| 1   | __________ s   | _______ ms | |
| 2   | __________ s   | _______ ms | |
| 3   | __________ s   | _______ ms | |
| 4   | __________ s   | _______ ms | |
| 5   | __________ s   | _______ ms | |
| 6   | __________ s   | _______ ms | |
| 7   | __________ s   | _______ ms | |
| 8   | __________ s   | _______ ms | |
| 9   | __________ s   | _______ ms | |
| 10  | __________ s   | _______ ms | |
| 11  | __________ s   | _______ ms | |
| 12  | __________ s   | _______ ms | |
| 13  | __________ s   | _______ ms | |
| 14  | __________ s   | _______ ms | |
| 15  | __________ s   | _______ ms | |
| 16  | __________ s   | _______ ms | |
| 17  | __________ s   | _______ ms | |
| 18  | __________ s   | _______ ms | |
| 19  | __________ s   | _______ ms | |
| 20  | __________ s   | _______ ms | |

---

## 📊 Statistical Analysis

**Calculate:**

| Metric | Value | Unit |
|--------|-------|------|
| Mean | _______ | ms |
| Median | _______ | ms |
| Std Dev | _______ | ms |
| Min | _______ | ms |
| Max | _______ | ms |
| P95 | _______ | ms |
| P99 | _______ | ms |

---

## 🔄 Comparison with Baseline

**Retrieve baseline values from Lab 02:**

| Metric | Baseline (Classical) | Hybrid (PQC) | Difference | Overhead (%) |
|--------|---------------------|--------------|------------|--------------|
| Mean | _______ ms | _______ ms | _______ ms | _______% |
| Median | _______ ms | _______ ms | _______ ms | _______% |
| P95 | _______ ms | _______ ms | _______ ms | _______% |
| P99 | _______ ms | _______ ms | _______ ms | _______% |

### Calculate Overhead:

```
Overhead (%) = ((Hybrid - Baseline) / Baseline) × 100

Example:
If Baseline = 10 ms, Hybrid = 12 ms
Overhead = ((12 - 10) / 10) × 100 = 20%
```

**Your calculations:**
```
Mean overhead    = ((_______ - _______) / _______) × 100 = _______% 
Median overhead  = ((_______ - _______) / _______) × 100 = _______%
P95 overhead     = ((_______ - _______) / _______) × 100 = _______%
```

---

## 📈 Side-by-Side Visualization

```
Time (ms)
    |
 25 |                                        X (Hybrid P99)
    |                                   X
 20 |                              X    █
    |                         X    █    █
 15 |                    X    █    █    █    X (Classical P99)
    |               X    █    █    █    █ X  █
 10 |          X    █    █    █    █    █ █  █
    |     X    █    █    █    █    █    █ █  █
  5 |  X  █    █    █    █    █    █    █ █  █
    |  █  █    █    █    █    █    █    █ █  █
  0 |__█__█____█____█____█____█____█____█_█__█______
      Min  P25  Median  Mean  P75  P95  P99 Max
      
      █ = Classical TLS
      X = PQC Hybrid
```

---

## 🔍 Analysis: Why is PQC Slower?

**Factors contributing to overhead:**

1. **Larger key sizes:**
   - X25519 public key: _______ bytes
   - ML-KEM-768 public key: _______ bytes (typically 1,184)
   - **Impact:** More data to transmit ➜ slightly higher latency

2. **Certificate size:**
   - Classical cert (RSA-2048): ~1-2 KB
   - Hybrid cert (ECDSA+ML-DSA-65): ~4-5 KB
   - **Impact:** Longer download time

3. **Cryptographic operations:**
   - ML-KEM encapsulation: _____ ms (typically 0.3 ms)
   - ML-DSA verification: _____ ms (typically 3 ms)
   - **Impact:** Additional CPU time

**Which factor has biggest impact?**
- [ ] Key size
- [ ] Certificate size
- [ ] Crypto operations
- [ ] Network overhead

**Justification:** _________________________________________________

---

## 💡 Optimization Ideas

**How could we reduce the overhead?**

1. **Certificate caching:**
   - [ ] Cache certificates on client side
   - Expected improvement: ~_____ ms

2. **Session resumption:**
   ```bash
   # Test with session tickets
   openssl s_client -connect localhost:8443 -reconnect
   ```
   - First handshake: _____ ms
   - Resumed: _____ ms
   - Speedup: _____x

3. **Hardware acceleration:**
   - [ ] Use CPU with AES-NI instructions
   - [ ] Use AVX2/AVX-512 for ML-KEM
   - Expected improvement: ~_____% 

4. **Algorithm choice:**
   - Try ML-KEM-512 instead of ML-KEM-768?
   - Trade security for performance?
   - [ ] Yes (if threat model allows)
   - [ ] No (security first)

---

## 🎯 Performance Assessment

**Is the overhead acceptable?**

| Overhead Range | Assessment | Your Result |
|----------------|------------|-------------|
| 0-10% | Excellent (negligible) | [ ] |
| 10-25% | Good (acceptable) | [ ] |
| 25-50% | Moderate (review case-by-case) | [ ] |
| 50-100% | High (consider optimization) | [ ] |
| >100% | Very High (investigate issues) | [ ] |

**For your use case, is this overhead acceptable?**
- [ ] Yes → Proceed with PQC migration
- [ ] No → Need optimization or re-evaluate

**Reasoning:**
___________________________________________________________________
___________________________________________________________________

---

## 📝 Key Findings

Summarize your findings in 3-5 sentences:

1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________
4. _________________________________________________________________
5. _________________________________________________________________

---

## ✅ Checkpoint

Before moving on, verify:

- [ ] Recorded all 20 PQC hybrid measurements
- [ ] Calculated statistics (mean, median, std dev)
- [ ] Compared with baseline from Lab 02
- [ ] Calculated overhead percentage
- [ ] Analyzed reasons for overhead
- [ ] Assessed if overhead is acceptable
- [ ] Documented findings

---

<div align="center">

**Next:** [CPU & Memory Measurements (Hybrid) →](cpu-memory-log-hybrid.md)

[← Back to Lab 04](../README.md)

</div>
