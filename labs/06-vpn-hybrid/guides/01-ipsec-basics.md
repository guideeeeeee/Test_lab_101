# IPsec Basics: Understanding VPN Security
# พื้นฐาน IPsec: ทำความเข้าใจความปลอดภัยของ VPN

**Lab:** 06-VPN Hybrid [BONUS]  
**Duration:** 30 minutes (reading + exercises)

---

## 📖 What is IPsec?

**Internet Protocol Security (IPsec)** is a protocol suite for securing IP communications by authenticating and encrypting each IP packet in a communication session.

**Use cases:**
- Site-to-site VPNs (connect two offices)
- Remote access VPNs (employees work from home)
- Secure cloud connections (hybrid cloud)

---

## 🏗️ IPsec Architecture

### Two Main Protocols

**1. AH (Authentication Header)**
- Provides: Authentication + Integrity
- Does NOT provide: Encryption
- Rarely used alone

**2. ESP (Encapsulating Security Payload)**
- Provides: Encryption + Authentication + Integrity
- Most common choice
- What we'll use in this lab

### Two Modes

**1. Transport Mode**
```
[ IP Header | ESP Header | Original Payload | ESP Trailer | ESP Auth ]
             └─────────── Encrypted ──────────┘
```
- Encrypts only the payload
- IP header remains visible
- Used for end-to-end encryption (host-to-host)

**2. Tunnel Mode**
```
[ New IP | ESP | Original IP | Original Payload | ESP Trailer | ESP Auth ]
          └──────────────── Encrypted ────────────────┘
```
- Encrypts entire original packet (including IP header)
- Adds new IP header for routing
- **Used for site-to-site VPNs** ← We use this

---

## 🔐 IPsec Cryptography

### Phase 1: IKE (Internet Key Exchange)

**Purpose:** Establish secure channel for negotiation

**IKEv2 (modern version) uses:**
1. **Key Exchange:** Diffie-Hellman (classical) or ML-KEM (PQC)
2. **Authentication:** Pre-shared key (PSK) or certificates (RSA/ECDSA → ML-DSA)
3. **Encryption:** AES
4. **Integrity:** HMAC-SHA256

**In this lab:**
- Classical: ECDHE P-256 + RSA-2048
- PQC Hybrid: X25519+ML-KEM-768 + ECDSA+ML-DSA-65

### Phase 2: IPsec SA (Security Association)

**Purpose:** Encrypt actual data traffic

**Uses:**
- **Encryption:** AES-GCM (not affected by quantum computers)
- **Integrity:** Built into GCM
- **Key derivation:** From Phase 1 keys

---

## 🚀 Connection Flow

```
┌─────────┐                         ┌─────────┐
│ Site A  │                         │ Site B  │
│ (VPN GW)│                         │ (VPN GW)│
└────┬────┘                         └────┬────┘
     │                                   │
     │ 1. IKE_SA_INIT                    │
     ├──────────────────────────────────>│
     │    (Exchange DH/ML-KEM keyshares) │
     │                                   │
     │ 2. IKE_AUTH                       │
     ├──────────────────────────────────>│
     │    (Authenticate with certs)      │
     │                                   │
     │ 3. CREATE_CHILD_SA                │
     ├──────────────────────────────────>│
     │    (Establish IPsec tunnel)       │
     │                                   │
     │ 4. Encrypted Data Traffic         │
     ├<─────────────────────────────────>│
     │    (ESP packets, AES-GCM)         │
     │                                   │
```

**Steps:**
1. **IKE_SA_INIT:** Exchange nonces and DH keyshares (or ML-KEM ciphertexts)
2. **IKE_AUTH:** Authenticate using certificates (RSA/ECDSA signatures → ML-DSA)
3. **CREATE_CHILD_SA:** Derive IPsec keys and create tunnel
4. **Data transfer:** Encrypt with AES-GCM using derived keys

---

## 🛠️ StrongSwan: Open-Source IPsec

**StrongSwan** is the most popular open-source IPsec implementation for Linux.

### Key Components

```
┌───────────────────────────────────────┐
│         charon (IKE daemon)           │
├───────────────────────────────────────┤
│  Plugins:                             │
│  ├─ kernel-netlink: Talk to kernel    │
│  ├─ openssl: Crypto operations        │
│  ├─ pem: Certificate loading          │
│  └─ oqs: Post-quantum (via liboqs)    │
└───────────────────────────────────────┘
         ↓
┌───────────────────────────────────────┐
│      Linux Kernel IPsec (XFRM)        │
│  - ESP packet processing              │
│  - Encryption/decryption (AES)        │
│  - Packet routing                     │
└───────────────────────────────────────┘
```

### Configuration Files

**Main config:** `/etc/ipsec.conf`
```conf
conn myvpn
    type=tunnel
    authby=rsasig           # Use certificate auth
    left=%any               # This side (dynamic IP)
    leftcert=server.crt
    right=192.168.1.100     # Remote side IP
    rightcert=client.crt
    ike=aes256-sha256-modp2048!  # IKE algorithms
    esp=aes256-sha256!           # ESP algorithms
    auto=start
```

**Secrets:** `/etc/ipsec.secrets`
```conf
: RSA server.key "password"
```

---

## 📊 Performance Characteristics

### Classical IPsec (RSA-2048 + ECDHE-P256)

| Phase | Operation | Time |
|-------|-----------|------|
| IKE | Key exchange | ~50-100ms |
| IKE | Certificate verify | ~10-20ms |
| IPsec | AES-GCM encryption | ~1 Gbps per core |

**Total connection time:** ~100-300ms

### PQC Hybrid IPsec (X25519+ML-KEM-768 + ECDSA+ML-DSA-65)

| Phase | Operation | Time |
|-------|-----------|------|
| IKE | Hybrid key exchange | ~150-300ms (+100-200ms) |
| IKE | Hybrid cert verify | ~30-50ms (+20ms) |
| IPsec | AES-GCM encryption | ~1 Gbps per core (same) |

**Total connection time:** ~300-500ms

**Overhead:** ~2-3x connection time, but data throughput unchanged

---

## 🎯 Why VPN is Different from Web TLS

| Aspect | Web (TLS) | VPN (IPsec) |
|--------|-----------|-------------|
| **Connection frequency** | Every page load | Once per session (long-lived) |
| **Handshake impact** | High (repeated) | Low (amortized) |
| **Data volume** | KB-MB per request | GB per session |
| **Latency sensitivity** | High (user waits) | Medium (background) |
| **Throughput priority** | Medium | **High** (bulk transfer) |

**Key difference:** VPN handshake overhead is amortized over long-lived tunnel
- Web: 100 handshakes/hour → overhead matters
- VPN: 1 handshake/day → overhead negligible

**Conclusion:** PQC overhead is MORE acceptable for VPN than web!

---

## 🧪 Lab Exercise: Analyze IPsec Traffic

### Step 1: Capture IPsec Packets

```bash
# Install tcpdump
sudo apt install tcpdump

# Capture ESP packets
sudo tcpdump -i any -n esp -w ipsec-capture.pcap

# In another terminal, start VPN connection
# Then stop tcpdump with Ctrl+C
```

### Step 2: Analyze with Wireshark

```bash
# Install Wireshark (GUI)
sudo apt install wireshark

# Open capture
wireshark ipsec-capture.pcap
```

**Look for:**
- **IKE_SA_INIT** (UDP port 500): Key exchange packets
- **IKE_AUTH** (UDP port 500): Authentication
- **ESP packets** (protocol 50): Encrypted data

**Observations:**
- ESP packet payload is encrypted → opaque
- Packet sizes larger with PQC (bigger ciphertexts)

---

## 🔍 Comparison: Web TLS vs VPN IPsec

```
┌─────────────┬──────────────────┬──────────────────┐
│   Aspect    │   TLS (HTTPS)    │  IPsec (VPN)     │
├─────────────┼──────────────────┼──────────────────┤
│ Layer       │ Application (L7) │ Network (L3)     │
│ Scope       │ Single app       │ All traffic      │
│ Handshake   │ Per connection   │ Per tunnel       │
│ Overhead    │ ~20-50ms/request │ ~200ms/tunnel    │
│ Throughput  │ App-dependent    │ Line-rate        │
│ PQC Impact  │ Moderate-High    │ Low-Moderate     │
└─────────────┴──────────────────┴──────────────────┘
```

---

## 💡 Key Takeaways

1. **IPsec encrypts at network layer** → protects all traffic, not just HTTPS
2. **Tunnel mode wraps entire packet** → hides internal topology
3. **IKE establishes keys** → this is where PQC matters (DH → ML-KEM)
4. **ESP encrypts data** → uses AES (quantum-resistant for data encryption)
5. **VPN overhead amortized** → PQC impact less critical than web TLS

---

## 🎯 Quiz: Test Your Understanding

**1. What does ESP provide?**
- [ ] Authentication only
- [x] Encryption + Authentication
- [ ] Compression only

**2. Where does PQC apply in IPsec?**
- [x] IKE Phase 1 (key exchange)
- [x] IKE Phase 2 (authentication with certs)
- [ ] ESP data encryption (already quantum-resistant with AES)

**3. Why is PQC overhead more acceptable for VPN than web?**
- [ ] VPN is faster
- [x] VPN connections are long-lived (handshake cost amortized)
- [ ] VPN uses weaker encryption

**4. What happens if IKE key exchange is broken by quantum computer?**
- [x] Attacker can decrypt past VPN traffic (if recorded)
- [ ] Only future traffic is compromised
- [ ] No impact (AES-GCM protects data)

**Answers:**
1. B (ESP = Encapsulating Security Payload = Encryption + Auth)
2. A + B (PQC replaces DH and signatures, not AES)
3. B (amortized cost over long session)
4. A ("Harvest Now, Decrypt Later" attack applies to key exchange)

---

<div align="center">

**Next:** [StrongSwan PQC Configuration →](02-strongswan-pqc.md)

[← Back to Lab 06](../README.md)

</div>
