# Performance Analysis Questions
# คำถามวิเคราะห์ประสิทธิภาพ PQC

**Lab:** 04-Hybrid Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 🎯 Purpose

These questions help you think critically about PQC migration trade-offs beyond just raw numbers. There's no single "correct" answer—your reasoning matters more than the conclusion.

---

## Section 1: Performance Trade-offs

### Question 1: Acceptable Overhead

You measured that PQC hybrid has:
- +25% handshake time
- +15% CPU usage
- -10% throughput

**For each scenario, is this overhead acceptable? Why or why not?**

**A) E-commerce checkout page**
- Expected: 1,000 purchases/hour (peak Black Friday)
- Current latency budget: 200ms
- PQC adds: 50ms to handshake

**Your answer:**
- [ ] Acceptable [ ] Not acceptable
- **Reason:** 
_________________________________________________________________
_________________________________________________________________

**B) High-frequency trading platform**
- Current: 100,000 trades/second
- Latency SLA: <5ms (P99)
- PQC adds: 20ms to each new connection

**Your answer:**
- [ ] Acceptable [ ] Not acceptable
- **Reason:**
_________________________________________________________________
_________________________________________________________________

**C) Government secure email**
- Current: 10 emails/minute
- Security requirement: NIST-approved PQC by 2035
- PQC adds: 100ms per email

**Your answer:**
- [ ] Acceptable [ ] Not acceptable
- **Reason:**
_________________________________________________________________
_________________________________________________________________

---

### Question 2: Cost-Benefit Analysis

**Your infrastructure:**
- 100 web servers
- Current: $1,000/month total
- PQC requires +20% CPU → +20 servers → +$200/month

**Value of data protected:**
- Customer PII: 1 million records
- Financial data: credit card info
- Cost of breach: $150 per record (industry average)

**Calculate:**
```
Annual PQC cost = $200 × 12 = $_______
Potential breach cost = 1,000,000 × $150 = $_______
Risk reduction = _______% (quantum computers viable in 10 years)
Expected benefit = $_______ × _______% = $_______

ROI = (Benefit - Cost) / Cost = _______
```

**Is it worth it?**
- [ ] Yes, positive ROI
- [ ] No, negative ROI
- [ ] Depends on risk tolerance

**Explain:**
_________________________________________________________________

---

## Section 2: Architectural Implications

### Question 3: Scaling Strategy

You have 3 options to handle PQC overhead:

**Option A: Vertical Scaling**
- Upgrade each server: 4 cores → 6 cores
- Cost: +$50/server/month
- Total: 100 servers × $50 = $5,000/month

**Option B: Horizontal Scaling**
- Add 20% more servers (same size)
- Cost: +$1,000/server/month × 20 = $20,000/month

**Option C: Mixed Deployment**
- PQC for 20% of traffic (high-value users)
- Classical TLS for 80% (public content)
- Cost: +$4,000/month (20 PQC servers)

**Which would you choose? Explain your reasoning:**

_________________________________________________________________
_________________________________________________________________

**Trade-offs of your choice:**

| Factor | Pro | Con |
|--------|-----|-----|
| Cost | | |
| Complexity | | |
| Security coverage | | |
| Performance | | |

---

### Question 4: Client Compatibility

PQC hybrid uses X25519+ML-KEM-768 (hybrid KEM).

**Problem:** Old clients don't support ML-KEM.

**What happens?**
- [ ] Connection fails (client rejects unknown algorithm)
- [ ] Falls back to X25519-only (classical)
- [ ] Server refuses connection (enforce PQC)

**Correct answer: Falls back to X25519** (hybrid design)

**Now consider:**

| Client | Supports ML-KEM? | Gets PQC? | Security Level |
|--------|------------------|-----------|----------------|
| Chrome 120+ | Yes | Yes | Quantum-safe |
| Firefox 115 | No | No (fallback) | Classical only |
| IE 11 | No | No (fallback) | Classical only |
| OpenSSL 3.2 | Yes | Yes | Quantum-safe |

**Your deployment:**
- 60% Chrome/Edge (PQC capable)
- 30% Firefox (mixed support)
- 10% legacy (no PQC)

**Effective PQC coverage:**
```
Coverage = _______% of users
Remaining risk = _______% vulnerable to quantum attack
```

**Mitigation strategies:**
1. _________________________________________________________________
2. _________________________________________________________________

---

## Section 3: Security Analysis

### Question 5: Hybrid vs Pure PQC

You have 2 choices:

**A) Hybrid: X25519 + ML-KEM-768**
- Security: Safe if either algorithm is secure
- Performance: Slower (runs both algorithms)
- Size: Larger (both public keys)

**B) Pure PQC: ML-KEM-768 only**
- Security: Depends entirely on ML-KEM
- Performance: Faster (one algorithm)
- Size: Smaller

**Which would you deploy in 2025? Explain:**

_________________________________________________________________
_________________________________________________________________

**What about in 2035 (when quantum computers are mature)?**

_________________________________________________________________

---

### Question 6: Migration Timeline

**NIST timeline:**
- 2024: ML-KEM/ML-DSA standardized (FIPS 203/204)
- 2025-2030: Migration period
- 2030: CNSA 2.0 requires PQC for NSS
- 2035: All federal systems must use PQC

**Your organization:**
- Has sensitive data with 10+ year lifetime
- Subject to government regulations
- Currently uses RSA-2048 (breakable by quantum computer)

**When should you start migrating?**

- [ ] 2025: Early adopter (be ready before deadline)
- [ ] 2027: Middle of migration period (balance risk & stability)
- [ ] 2029: Late migration (wait for mature ecosystem)
- [ ] 2030: Deadline-driven (comply with regulation)

**Explain your choice:**
_________________________________________________________________
_________________________________________________________________

**Risk of waiting too long:**
_________________________________________________________________

**Risk of migrating too early:**
_________________________________________________________________

---

## Section 4: Technical Deep Dive

### Question 7: Bottleneck Analysis

**From your measurements:**

| Operation | Classical TLS | PQC Hybrid | Time Increase |
|-----------|---------------|------------|---------------|
| ML-KEM Encapsulation | N/A | 0.2 ms | +0.2 ms |
| ML-DSA Verification | N/A | 1.5 ms | +1.5 ms |
| Certificate parsing | 0.1 ms | 0.3 ms | +0.2 ms |
| **Total handshake** | 5 ms | 7.2 ms | +2.2 ms |

**Which is the bottleneck?**
- [ ] ML-KEM encapsulation
- [ ] ML-DSA signature verification ← (accounts for 68% of overhead)
- [ ] Certificate parsing

**How would you optimize this?**

_________________________________________________________________
_________________________________________________________________

**Research:** Look up Falcon-512 (alternative to ML-DSA-65)
- Signature size: 666 bytes (vs 2420 bytes for ML-DSA)
- Verification time: ~2.5 ms (slower than ML-DSA!)
- Trade-off: Smaller sig, but slower verification

**Would you switch to Falcon? Why?**

_________________________________________________________________

---

### Question 8: Memory Pressure

**Scenario:**
- Your server handles 50,000 concurrent connections
- Each PQC TLS session uses +2 KB extra memory (keys + cert)
- Total extra memory: 50,000 × 2 KB = 100 MB

**Current server:**
- RAM: 32 GB
- Available: 8 GB (after OS + app)
- Extra 100 MB = 1.25% of available RAM

**Is this a problem?**
- [ ] No, negligible
- [ ] Yes, significant

**Now scale to 500,000 connections (10x):**
- Extra memory: _______ GB
- Percentage of available: _______%

**At what scale does memory become a bottleneck?**

_________________________________________________________________

**Mitigation:**
_________________________________________________________________

---

## Section 5: Real-World Decisions

### Question 9: Phased Rollout

You decide to migrate gradually. Design a 3-phase rollout:

**Phase 1: Canary (Week 1-2)**
- Traffic coverage: _______%
- Target users: _______________________________________________
- Success criteria: _____________________________________________
- Rollback trigger: _____________________________________________

**Phase 2: Expansion (Week 3-8)**
- Traffic coverage: _______%
- Target users: _______________________________________________
- Success criteria: _____________________________________________

**Phase 3: Full Deployment (Week 9+)**
- Traffic coverage: 100%
- Monitoring: _________________________________________________

---

### Question 10: Monitoring & Alerting

**Post-migration, what metrics should you monitor?**

Check the top 5:

- [ ] TLS handshake latency (P50, P95, P99)
- [ ] Handshake failure rate
- [ ] CPU usage per server
- [ ] Memory usage per server
- [ ] Throughput (requests/sec)
- [ ] Certificate validation errors
- [ ] Client algorithm negotiation (which clients use PQC?)
- [ ] Certificate expiration (ML-DSA certs)
- [ ] Time to first byte (TTFB)
- [ ] Connection establishment time

**Alert thresholds:**

| Metric | Warning | Critical |
|--------|---------|----------|
| Handshake latency P95 | > _____ ms | > _____ ms |
| CPU usage | > _____% | > _____% |
| Handshake failure rate | > _____% | > _____% |

---

## Section 6: Critical Thinking

### Question 11: Threat Model

**Quantum threat timeline (expert estimates):**
- Optimistic (QC advocates): 2030-2035
- Realistic (NIST): 2035-2040
- Pessimistic (skeptics): 2050+

**Your data:**
- Sensitive medical records
- Retention: 30 years
- HIPAA compliance required

**"Harvest Now, Decrypt Later" attack:**
- Adversary captures encrypted traffic today
- Decrypts in 2035 when QC is available
- Data still sensitive in 2035? [ ] Yes [ ] No

**Should you migrate to PQC now, or wait?**

_________________________________________________________________
_________________________________________________________________

---

### Question 12: Future-Proofing

**5 years from now (2030):**
- Quantum computers more powerful
- PQC algorithms battle-tested (or broken?)
- New algorithms emerge (NIST Round 4?)
- Hardware acceleration available (PQC co-processors?)

**How would you design your system to be adaptable?**

**Architecture principles:**
1. _________________________________________________________________
2. _________________________________________________________________
3. _________________________________________________________________

**Specific tactics:**
- [ ] Use TLS 1.3 (algorithm agility)
- [ ] Abstract crypto layer (easy to swap algorithms)
- [ ] Monitor NIST announcements (stay updated)
- [ ] Test new algorithms in staging
- [ ] Other: ____________________________________________________

---

## 🎯 Reflection

### What did you learn?

**Most important insight:**
_________________________________________________________________

**What surprised you:**
_________________________________________________________________

**What would you do differently in a real deployment?**
_________________________________________________________________

---

## ✅ Checkpoint

Verify completion:

- [ ] Analyzed performance trade-offs for different scenarios
- [ ] Evaluated cost-benefit of PQC migration
- [ ] Designed scaling strategy
- [ ] Considered client compatibility
- [ ] Compared hybrid vs pure PQC
- [ ] Created migration timeline
- [ ] Identified performance bottlenecks
- [ ] Assessed memory scalability
- [ ] Designed phased rollout plan
- [ ] Defined monitoring strategy
- [ ] Evaluated quantum threat timeline
- [ ] Proposed future-proof architecture

---

<div align="center">

**Next:** [Lab 05: Data Aggregation & Visualization →](../../05-data-aggregation-viz/README.md)

[← Back to Lab 04](../README.md)

</div>
