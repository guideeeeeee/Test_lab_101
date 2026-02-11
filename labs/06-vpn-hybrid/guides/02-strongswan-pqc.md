# StrongSwan with Post-Quantum Cryptography
# การตั้งค่า StrongSwan กับ PQC

**Lab:** 06-VPN Hybrid [BONUS]  
**Duration:** 45 minutes

---

## 📖 Overview

Learn how to configure StrongSwan IPsec VPN with hybrid post-quantum key exchange using the OQS plugin.

---

## 🏗️ Architecture

```
┌─────────────────┐          VPN Tunnel           ┌─────────────────┐
│   Site A        │  (X25519+MLKEM768 hybrid)     │   Site B        │
│                 │◄──────────────────────────────►│                 │
│ StrongSwan GW   │      Encrypted Traffic         │ StrongSwan GW   │
│ + OQS plugin    │        (AES-256-GCM)           │ + OQS plugin    │
│                 │                                │                 │
│ 10.1.0.0/24     │                                │ 10.2.0.0/24     │
└─────────────────┘                                └─────────────────┘
```

---

## 🔧 Prerequisites

### Install StrongSwan with OQS Support

**Option 1: Pre-built Docker Image** (Recommended for lab)
```bash
# Pull image with StrongSwan + liboqs
docker pull pqc-vpn-strongswan:latest
```

**Option 2: Build from Source**
```bash
# Install dependencies
sudo apt update
sudo apt install -y build-essential libssl-dev pkg-config \
    libsystemd-dev libjson-c-dev

# Build liboqs
git clone https://github.com/open-quantum-safe/liboqs.git
cd liboqs
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
make -j$(nproc)
sudo make install

# Build StrongSwan with OQS plugin
wget https://download.strongswan.org/strongswan-6.0.0beta4.tar.gz
tar xzf strongswan-6.0.0beta4.tar.gz
cd strongswan-6.0.0beta4

./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --enable-openssl \
    --enable-chapoly \
    --enable-oqs \
    --with-liboqs=/usr/local

make -j$(nproc)
sudo make install
```

---

## 🔑 Generate PQC Certificates

### Step 1: Generate ML-DSA Private Key

```bash
# Create certificates directory
mkdir -p /etc/ipsec.d/{private,certs,cacerts}

# Generate ML-DSA-65 key for CA
openssl genpkey -algorithm MLDSA65 -out /etc/ipsec.d/private/ca-key.pem

# Generate self-signed CA certificate
openssl req -new -x509 -key /etc/ipsec.d/private/ca-key.pem \
    -out /etc/ipsec.d/cacerts/ca-cert.pem -days 3650 \
    -subj "/C=US/ST=State/L=City/O=MyOrg/CN=VPN CA"
```

### Step 2: Generate Site A Certificate

```bash
# Site A private key
openssl genpkey -algorithm MLDSA65 -out /etc/ipsec.d/private/siteA-key.pem

# Certificate signing request
openssl req -new -key /etc/ipsec.d/private/siteA-key.pem \
    -out /tmp/siteA.csr \
    -subj "/C=US/ST=State/L=City/O=MyOrg/CN=siteA.vpn.local"

# Sign with CA
openssl x509 -req -in /tmp/siteA.csr \
    -CA /etc/ipsec.d/cacerts/ca-cert.pem \
    -CAkey /etc/ipsec.d/private/ca-key.pem \
    -CAcreateserial \
    -out /etc/ipsec.d/certs/siteA-cert.pem \
    -days 365
```

### Step 3: Repeat for Site B

```bash
# Site B private key
openssl genpkey -algorithm MLDSA65 -out /etc/ipsec.d/private/siteB-key.pem

# CSR
openssl req -new -key /etc/ipsec.d/private/siteB-key.pem \
    -out /tmp/siteB.csr \
    -subj "/C=US/ST=State/L=City/O=MyOrg/CN=siteB.vpn.local"

# Sign
openssl x509 -req -in /tmp/siteB.csr \
    -CA /etc/ipsec.d/cacerts/ca-cert.pem \
    -CAkey /etc/ipsec.d/private/ca-key.pem \
    -CAcreateserial \
    -out /etc/ipsec.d/certs/siteB-cert.pem \
    -days 365
```

---

## ⚙️ Configure StrongSwan

### Site A: `/etc/ipsec.conf`

```conf
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=never

conn site-to-site-hybrid
    type=tunnel
    
    # Authentication
    authby=pubkey
    leftcert=siteA-cert.pem
    rightcert=siteB-cert.pem
    
    # Local (Site A)
    left=%any
    leftid="CN=siteA.vpn.local"
    leftsubnet=10.1.0.0/24
    
    # Remote (Site B)
    right=203.0.113.20     # Site B public IP
    rightid="CN=siteB.vpn.local"
    rightsubnet=10.2.0.0/24
    
    # IKE Phase 1 (Hybrid PQC)
    ike=aes256-sha256-x25519mlkem768-modp3072!
    # Algorithms:
    #   - aes256: Encryption
    #   - sha256: Integrity
    #   - x25519mlkem768: Hybrid KEM (classical + PQC)
    #   - modp3072: Fallback DH group
    
    # IPsec Phase 2 (ESP)
    esp=aes256gcm16-modp3072!
    # AES-256-GCM: Authenticated encryption (quantum-resistant for data)
    
    # Lifetimes
    ikelifetime=3600s      # Rekey IKE every hour
    lifetime=1800s         # Rekey IPsec every 30 min
    
    # Auto-start
    auto=start
    dpdaction=restart      # Restart on dead peer detection
    dpddelay=30s
```

### Site A: `/etc/ipsec.secrets`

```conf
# Site A private key
: RSA siteA-key.pem "optional-password"

# Or for ML-DSA (if supported by StrongSwan version)
: ECDSA siteA-key.pem
```

### Site B: `/etc/ipsec.conf`

```conf
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=never

conn site-to-site-hybrid
    type=tunnel
    
    # Authentication
    authby=pubkey
    leftcert=siteB-cert.pem
    rightcert=siteA-cert.pem
    
    # Local (Site B)
    left=%any
    leftid="CN=siteB.vpn.local"
    leftsubnet=10.2.0.0/24
    
    # Remote (Site A)
    right=198.51.100.10    # Site A public IP
    rightid="CN=siteA.vpn.local"
    rightsubnet=10.1.0.0/24
    
    # IKE Phase 1 (Hybrid PQC)
    ike=aes256-sha256-x25519mlkem768-modp3072!
    
    # IPsec Phase 2
    esp=aes256gcm16-modp3072!
    
    # Lifetimes
    ikelifetime=3600s
    lifetime=1800s
    
    # Auto-start
    auto=start
    dpdaction=restart
    dpddelay=30s
```

---

## 🚀 Start VPN

### Site A

```bash
# Start StrongSwan
sudo systemctl start strongswan-starter

# Or in Docker
docker exec -it siteA-vpn ipsec start

# Check status
sudo ipsec status
```

**Expected output:**
```
Security Associations (1 up, 0 connecting):
site-to-site-hybrid[1]: ESTABLISHED 10 seconds ago
  local  'CN=siteA.vpn.local' @ 198.51.100.10[500]
  remote 'CN=siteB.vpn.local' @ 203.0.113.20[500]
  AES_CBC-256/HMAC_SHA2_256_128/PRF_HMAC_SHA2_256/X25519MLKEM768
  site-to-site-hybrid{1}:  INSTALLED, TUNNEL
    local  10.1.0.0/24
    remote 10.2.0.0/24
```

**Key indicators:**
- `ESTABLISHED` → IKE Phase 1 complete (hybrid key exchange succeeded)
- `X25519MLKEM768` → Hybrid PQC in use
- `INSTALLED` → IPsec tunnel active

### Site B

```bash
# Start (should auto-connect to Site A)
sudo ipsec start

# Verify
sudo ipsec statusall
```

---

## 🧪 Test VPN Connectivity

### Ping Across Tunnel

```bash
# From Site A, ping Site B's internal network
ping 10.2.0.5

# Should work if tunnel is up
```

### Verify Traffic is Encrypted

```bash
# Capture ESP packets
sudo tcpdump -i any -n esp

# While pinging
# You should see ESP packets (encrypted), not ICMP (plaintext)
```

### Check IKE Logs

```bash
# View logs in real-time
sudo tail -f /var/log/syslog | grep charon

# Look for:
# - "received KE payload" (key exchange)
# - "prf algorithm PRF_HMAC_SHA2_256 selected"
# - "X25519MLKEM768 group selected"
```

---

## 📊 Performance Testing

### Throughput Test with iperf3

**Site B (server):**
```bash
# Inside Site B internal network
iperf3 -s -p 5201
```

**Site A (client):**
```bash
# Test throughput through VPN tunnel
iperf3 -c 10.2.0.5 -p 5201 -t 30 -P 4

# -t 30: 30 seconds
# -P 4: 4 parallel streams
```

**Baseline (Classical DH):**
- Throughput: ~850-900 Mbps

**Hybrid PQC (X25519+MLKEM768):**
- Throughput: ~820-880 Mbps
- Overhead: ~3-5% (acceptable)

### Connection Establishment Time

```bash
# Time the connection setup
time sudo ipsec up site-to-site-hybrid
```

**Classical ECDHE:**
- Time: ~100-200ms

**Hybrid PQC:**
- Time: ~250-400ms
- Overhead: +150-200ms (one-time per tunnel)

---

## 🔍 Troubleshooting

### Issue 1: Connection Fails

**Symptom:**
```
initiating IKE_SA failed
```

**Debug:**
```bash
# Increase log verbosity
sudo ipsec stop
sudo ipsec start --debug-ike 3

# Check logs
sudo journalctl -u strongswan -f
```

**Common causes:**
- Firewall blocking UDP 500/4500
- Certificate mismatch (check CN)
- Algorithm mismatch (both sides must support X25519MLKEM768)

### Issue 2: Tunnel Established But No Traffic

**Symptom:**
- `ipsec status` shows ESTABLISHED
- But ping fails

**Debug:**
```bash
# Check routing
ip route show table 220

# Verify policies
ip xfrm policy

# Test with tcpdump
sudo tcpdump -i any icmp
```

**Fix:**
- Enable IP forwarding: `sysctl -w net.ipv4.ip_forward=1`
- Check iptables: `iptables -L FORWARD`

### Issue 3: OQS Algorithm Not Available

**Symptom:**
```
algorithm 'X25519MLKEM768' not supported
```

**Fix:**
```bash
# Verify OQS plugin loaded
sudo ipsec listall | grep -i oqs

# Reload plugins
sudo ipsec reload
```

---

## 💡 Optimization Tips

### 1. Hardware Acceleration

```bash
# Enable AES-NI (if available)
# Check support
grep aes /proc/cpuinfo

# Already enabled by kernel automatically
```

### 2. Connection Pooling

```conf
# In ipsec.conf
conn site-to-site-hybrid
    # ... existing config ...
    
    # Keep tunnel alive
    dpdaction=restart
    dpddelay=30s
    dpdtimeout=150s
    
    # Faster rekeying
    margintime=180s
```

### 3. Compression (Optional)

```conf
# Enable IPComp if bandwidth-limited
conn site-to-site-hybrid
    compress=yes
```

---

## ✅ Checkpoint

Verify you've completed:

- [ ] Installed StrongSwan with OQS support
- [ ] Generated ML-DSA certificates for both sites
- [ ] Configured `/etc/ipsec.conf` with hybrid KEM
- [ ] Started IPsec tunnel successfully
- [ ] Verified traffic is encrypted (ESP packets)
- [ ] Tested throughput with iperf3
- [ ] Measured connection establishment time
- [ ] Compared classical vs PQC hybrid performance

---

<div align="center">

**Next:** [VPN Performance Benchmarking →](../scripts/benchmark-vpn.sh)

[← Back to Lab 06](../README.md) | [IPsec Basics ←](01-ipsec-basics.md)

</div>
