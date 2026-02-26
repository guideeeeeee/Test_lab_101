# Packet Size Analysis Worksheet (Classical TLS Baseline)
# แบบบันทึกการวิเคราะห์ขนาด Packet (Baseline)

**Lab:** 02-Baseline Testing  
**Student Name:** _________________________  
**Date:** _________________________

---

## 📋 Test Configuration

**Target Server:** `pqc-nginx-secure` – https://localhost:4431  
**Capture Method:** tcpdump via `docker exec` (ไม่ต้อง sudo)  
**Protocol:** TLS 1.2 / TLS 1.3 over TCP port 443 (inside container)

---

## 🔧 Capture Setup

### Step 1: ติดตั้ง tcpdump ใน container

```bash
docker exec pqc-nginx-secure apk add --no-cache tcpdump
```

### Step 2: เริ่ม capture ใน background

```bash
docker exec -d pqc-nginx-secure sh -c \
  "tcpdump -i eth0 'port 443' -c 50 -w /tmp/handshake.pcap 2>/tmp/tcpdump.log"

sleep 1
```

### Step 3: Trigger TLS handshakes

```bash
for i in {1..5}; do
  curl -k -s https://localhost:4431 > /dev/null
done

sleep 2
```

### Step 4: ตรวจสอบผล

```bash
# ดู log ของ tcpdump
docker exec pqc-nginx-secure cat /tmp/tcpdump.log

# ดู packet list
docker exec pqc-nginx-secure tcpdump -r /tmp/handshake.pcap -nn -q 2>/dev/null

# Copy ออกมา (optional)
docker cp pqc-nginx-secure:/tmp/handshake.pcap ./handshake.pcap
```

---

## 📦 Part 1: Certificate Size

### Capture Certificate Chain

```bash
openssl s_client -connect localhost:4431 -showcerts </dev/null 2>/dev/null | \
  sed -n '/BEGIN CERTIFICATE/,/END CERTIFICATE/p' > cert-chain.pem
```

### Measure Size

```bash
wc -c cert-chain.pem
ls -lh cert-chain.pem
# Count number of certificates
grep -c 'BEGIN CERTIFICATE' cert-chain.pem
```

**Record:**

| Metric | Value |
|--------|-------|
| Certificate chain size (bytes) | _______ |
| Certificate chain size (KB) | _______ |
| Number of certificates | _______ |

---

## 📡 Part 2: TLS Handshake Packet Sizes

### Packet List from pcap

ดู packets ที่บันทึกได้ (1 connection = ประมาณ 10 packets แรก):

```bash
docker exec pqc-nginx-secure tcpdump -r /tmp/handshake.pcap -nn -q 2>/dev/null | head -25
```

**บันทึกผล (1 connection แรก):**

| # | Direction | Description | Size (bytes) |
|---|-----------|-------------|--------------|
| 1 | Client → Server | TCP SYN | 0 (header only) |
| 2 | Server → Client | TCP SYN-ACK | 0 (header only) |
| 3 | Client → Server | TCP ACK | 0 (header only) |
| 4 | Client → Server | **ClientHello** | _______ |
| 5 | Server → Client | TCP ACK | 0 |
| 6 | Server → Client | **ServerHello + CertificateStatus** | _______ |
| 7 | Client → Server | ACK | 0 |
| 8 | Client → Server | **Key Exchange + ChangeCipherSpec** | _______ |
| 9 | Server → Client | **Certificate chain (fragment 1)** | _______ |
| 10 | Server → Client | **Certificate chain (fragment 2)** | _______ |
| 11 | Server → Client | **Finished** | _______ |
| 12 | Client → Server | **Finished / Application Data** | _______ |

---

## 📊 Part 3: Handshake Data Summary

### Calculate Total Sizes

```bash
# สรุปขนาด packets ทั้งหมดที่ส่ง (client → server)
docker exec pqc-nginx-secure tcpdump -r /tmp/handshake.pcap -nn -q 2>/dev/null | \
  grep "172.19.0.1.*>" | grep -v "tcp 0" | awk '{print $NF}' | \
  awk 'BEGIN{s=0} {s+=$1} END{print "Client->Server total:", s, "bytes"}'

# สรุปขนาด packets ทั้งหมดที่รับ (server → client)
docker exec pqc-nginx-secure tcpdump -r /tmp/handshake.pcap -nn -q 2>/dev/null | \
  grep "172.19.0.4.*>" | grep -v "tcp 0" | awk '{print $NF}' | \
  awk 'BEGIN{s=0} {s+=$1} END{print "Server->Client total:", s, "bytes"}'
```

**Record:**

| Metric | Value | Unit |
|--------|-------|------|
| **ClientHello size** | _______ | bytes |
| **ServerHello + Certificate** | _______ | bytes |
| **Total handshake (client→server)** | _______ | bytes |
| **Total handshake (server→client)** | _______ | bytes |
| **Total handshake data** | _______ | bytes |
| **Number of packets** | _______ | packets |

---

## 🔍 Part 4: Detailed TLS Handshake Analysis

### Verbose packet dump (TLS record detail)

```bash
docker exec pqc-nginx-secure tcpdump -r /tmp/handshake.pcap -nn -v 2>/dev/null | \
  grep -E "length [0-9]+" | head -20
```

### วิเคราะห์ด้วย openssl (เพื่อดู cipher suite)

```bash
# ดู cipher suite และ cert ที่ใช้
openssl s_client -connect localhost:4431 -brief </dev/null 2>&1

# ดู cipher suite โดยละเอียด
openssl s_client -connect localhost:4431 </dev/null 2>/dev/null | \
  grep -E "Protocol|Cipher|Subject|Issuer"
```

**TLS Configuration:**

| Parameter | Value |
|-----------|-------|
| Protocol version | _______ |
| Cipher suite | _______ |
| Certificate subject | _______ |
| Key exchange | _______ |

---

## 📈 Part 5: Overhead Analysis

### Bandwidth Overhead Calculation

```
Handshake overhead per connection:
= Total handshake data / Connection payload size
= _______ bytes / _______ bytes
= _______ %
```

**Comparison with HTTP (no TLS):**

| | With TLS | Without TLS | Overhead |
|-|----------|-------------|----------|
| Connection setup | _______ bytes | ~172 bytes (3-way) | _______ bytes (+_____%) |
| Total per GET | _______ bytes | _______ bytes | _______ bytes (+_____%) |

---

## 💡 Analysis Questions

1. **ClientHello ส่ง cipher suites กี่ตัว?**  
   (ดูได้จาก length ของ ClientHello – ยิ่งใหญ่ = ยิ่งมี cipher suites)  
   ตอบ: _________________________________________________

2. **Certificate chain ขนาดใหญ่แค่ไหนเมื่อเทียบกับ payload ปกติ?**  
   ตอบ: _________________________________________________

3. **ถ้าใช้ TLS session resumption จะลดขนาด handshake ได้เท่าไร?**  
   ตอบ: _________________________________________________

4. **เมื่อเปรียบเทียบกับ PQC Hybrid (Lab 03-04) คาดว่า ClientHello จะใหญ่ขึ้นหรือเล็กลง เพราะอะไร?**  
   ตอบ: _________________________________________________

---

## 🎯 Baseline Summary for Comparison

**บันทึกตัวเลขเหล่านี้เพื่อเปรียบเทียบกับ PQC Hybrid ใน Lab 04:**

| Metric | Classical TLS (Baseline) | PQC Hybrid (Lab 04) | Change |
|--------|--------------------------|---------------------|--------|
| ClientHello (bytes) | _______ | _______ | _______ |
| ServerHello+Cert (bytes) | _______ | _______ | _______ |
| Total handshake (bytes) | _______ | _______ | _______ |
| Certificate size (bytes) | _______ | _______ | _______ |

---

## ✅ Checkpoint

Before moving on:

- [ ] Captured TLS handshake packets (handshake.pcap)
- [ ] Measured ClientHello size
- [ ] Measured ServerHello + Certificate size
- [ ] Measured total handshake bytes
- [ ] Measured certificate chain size
- [ ] Recorded baseline values for Lab 04 comparison

---

<div align="center">

**Next:** [Baseline Summary Report →](baseline-summary.md)

[← Back to Lab 02](../README.md)

</div>
