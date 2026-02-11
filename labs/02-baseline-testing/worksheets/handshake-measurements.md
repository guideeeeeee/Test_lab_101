# TLS Handshake Measurements Worksheet
# แบบบันทึกผลการวัดเวลา TLS Handshake

**Lab:** 02-Baseline Testing (Classical TLS)  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Test Configuration

| Parameter | Value |
|-----------|-------|
| Target Server | https://localhost:443 |
| TLS Version | (check with testssl.sh) |
| Cipher Suite | (check with openssl s_client) |
| Certificate Type | RSA-2048 |
| Test Tool | curl / openssl s_time |
| Number of Tests | 20 |

---

## ⏱️ Measurement Data

### Run curl 20 times and record results:

```bash
for i in {1..20}; do
  echo -n "Run $i: "
  curl -k -o /dev/null -s -w "%{time_connect}\n" https://localhost
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

### Method 1: Manual Calculation

**Sort data from smallest to largest:**
_______________________________________________________________
_______________________________________________________________

**Calculate:**

1. **Mean (Average):**
   ```
   Mean = Sum of all values / Number of values
   Mean = (__________ + __________ + ... + __________) / 20
   Mean = __________ ms
   ```

2. **Median (Middle value):**
   ```
   Median = Average of 10th and 11th values (when sorted)
   Median = (__________ + __________) / 2
   Median = __________ ms
   ```

3. **Minimum:**
   ```
   Min = __________ ms
   ```

4. **Maximum:**
   ```
   Max = __________ ms
   ```

5. **Range:**
   ```
   Range = Max - Min
   Range = __________ - __________ = __________ ms
   ```

6. **Standard Deviation (simplified):**
   ```
   1. Calculate deviations: (value - mean)²
   2. Sum all squared deviations
   3. Divide by (n-1) = 19
   4. Take square root
   
   Std Dev ≈ __________ ms
   ```

---

### Method 2: Using Python Script

```bash
# Save measurements to file
cat handshake_times.txt | python3 ../../../scripts/calculate-stats.py --stdin

# Or create JSON and use aggregate script
python3 ../../../scripts/calculate-stats.py --input measurements.json --metric time_connect
```

**Results from script:**

```
Mean:     __________ ms
Median:   __________ ms
Std Dev:  __________ ms
Min:      __________ ms
Max:      __________ ms
P95:      __________ ms
P99:      __________ ms
```

---

## 📈 Visualization

Plot your data on this chart (manually mark X for each data point):

```
Time (ms)
    |
 20 |
    |
 15 |
    |
 10 |
    |
  5 |
    |
  0 |________________________________
     1  2  3  4  5  6  7  8  9  10 11 12 13 14 15 16 17 18 19 20
                    Run Number
```

**Observations:**
- Do you see any outliers? _____________________________________
- Is the data consistent? ______________________________________
- What might cause variations? _________________________________

---

## 🎯 Performance Classification

Based on your mean handshake time:

| Time Range | Classification | Status |
|------------|----------------|--------|
| < 5 ms | Excellent | [ ] |
| 5-10 ms | Good | [ ] |
| 10-20 ms | Acceptable | [ ] |
| 20-50 ms | Slow | [ ] |
| > 50 ms | Very Slow | [ ] |

**Your classification:** __________

---

## 🔍 Analysis Questions

1. **What factors might affect handshake time?**
   - [ ] CPU load
   - [ ] Network latency
   - [ ] Certificate size
   - [ ] Key exchange algorithm
   - [ ] Other: _______________

2. **Did any runs take significantly longer?** (outliers)
   - If yes, why? ____________________________________________

3. **How does localhost compare to internet server?**
   ```bash
   # Try this for comparison
   curl -o /dev/null -s -w "%{time_connect}\n" https://google.com
   ```
   - Google.com: __________ ms
   - Localhost: __________ ms
   - Difference: __________ ms
   - Why? ____________________________________________________

4. **Session resumption effect:**
   ```bash
   # First connection (full handshake)
   openssl s_client -connect localhost:443 -no_ticket -brief
   
   # Reconnection (session resume)
   openssl s_client -connect localhost:443 -reconnect -brief
   ```
   - First: __________ ms
   - Resume: __________ ms
   - Speedup: __________x faster

---

## 🎯 Summary for Report

**Baseline (Classical TLS) Handshake Performance:**

| Metric | Value | Unit |
|--------|-------|------|
| Mean | | ms |
| Median | | ms |
| Std Dev | | ms |
| Min | | ms |
| Max | | ms |
| P95 | | ms |
| P99 | | ms |

**Save these numbers!** You'll compare them against PQC hybrid results in Lab 04.

---

## ✅ Checkpoint

Before moving on, make sure you:

- [ ] Recorded all 20 measurements
- [ ] Calculated mean, median, std dev
- [ ] Identified any outliers
- [ ] Saved raw data for later comparison
- [ ] Understand what the numbers mean

---

<div align="center">

**Next:** [CPU & Memory Measurements →](cpu-memory-log.md)

[← Back to Lab 02](../README.md)

</div>
