# Lab 06: VPN Hybrid Implementation [BONUS]
# การนำ Hybrid PQC มาใช้กับ VPN

⏱️ **Duration:** 2-3 hours  
🎯 **Objective:** Implement hybrid PQC in VPN (IPsec/OpenVPN)  
📍 **Level:** Advanced - Optional bonus lab

---

## 📖 Overview

This bonus lab extends PQC implementation to VPN tunnels using StrongSwan (IPsec) with hybrid key exchange.

### What You'll Learn
- Configure IPsec with hybrid KEMs
- Set up post-quantum VPN tunnels
- Measure VPN performance impact
- Compare web vs VPN PQC overhead

---

## 🏗️ Architecture

```
Site A                   VPN Tunnel                 Site B
┌────────┐          (Hybrid PQC IPsec)           ┌────────┐
│ Client │ ←──────────  Encrypted  ───────────→  │ Server │
└────────┘        X25519+MLKEM768               └────────┘
```

---

## 🚀 Quick Start

```bash
cd ~/pqcv2/labs/06-vpn-hybrid

# Build VPN containers
docker-compose up -d

# Test connectivity
./scripts/test-vpn-connection.sh
```

---

## 📁 Contents

- [guides/01-ipsec-basics.md](guides/01-ipsec-basics.md) - IPsec overview
- [guides/02-strongswan-pqc.md](guides/02-strongswan-pqc.md) - PQC setup
- [configs/ipsec-hybrid.conf](configs/ipsec-hybrid.conf) - Configuration
- [scripts/benchmark-vpn.sh](scripts/benchmark-vpn.sh) - Performance test

---

## 🎯 Key Metrics to Measure

- VPN connection establishment time
- Throughput (iperf3)
- Latency (ping)
- CPU overhead during tunneling

---

## 💡 Expected Results

| Metric | Classical IPsec | Hybrid PQC | Overhead |
|--------|----------------|------------|----------|
| Connection time | 50-100ms | 150-300ms | +2-3x |
| Throughput | 900 Mbps | 850 Mbps | -5% |
| Latency | 1ms | 1.2ms | +20% |

**Conclusion:** VPN overhead is acceptable for site-to-site scenarios

---

<div align="center">

[← Lab 05](../05-analysis-reporting/) | [Lab 07 →](../07-advanced-workshop/)

</div>
