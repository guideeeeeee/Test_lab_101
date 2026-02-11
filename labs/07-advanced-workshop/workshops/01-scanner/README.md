# Workshop 1: Build a TLS Scanner
# สร้าง TLS Scanner เอง

**Duration:** 45 minutes  
**Difficulty:** Intermediate  
**Language:** Python 3.8+

---

## 🎯 Objective

Build a command-line tool that scans TLS endpoints and extracts:
- Protocol versions (TLS 1.2, 1.3)
- Cipher suites
- Certificate details
- Post-quantum algorithm detection

---

## 📋 Requirements

```bash
pip install cryptography pyOpenSSL colorama
```

---

## 🏗️ Architecture

```
┌─────────────┐
│   Input:    │  host, port
│  Target URL │
└──────┬──────┘
       │
┌──────▼──────────────────┐
│  1. TCP Connection      │
│     socket.connect()    │
└──────┬──────────────────┘
       │
┌──────▼──────────────────┐
│  2. TLS Handshake       │
│     ssl.wrap_socket()   │
└──────┬──────────────────┘
       │
┌──────▼──────────────────┐
│  3. Extract Information │
│     - Protocol version  │
│     - Cipher suite      │
│     - Certificate       │
└──────┬──────────────────┘
       │
┌──────▼──────────────────┐
│  4. Parse & Display     │
│     JSON or colored text│
└─────────────────────────┘
```

---

## 🚀 Getting Started

### Step 1: Review Starter Code

Open [starter.py](starter.py) and review the skeleton:

```python
#!/usr/bin/env python3
import ssl
import socket
import json
from cryptography import x509
from cryptography.hazmat.backends import default_backend

def scan_tls_endpoint(host, port=443):
    """
    Scan a TLS endpoint and extract configuration details.
    
    TODO: Implement the following:
    1. Establish TLS connection
    2. Get protocol version
    3. Get cipher suite
    4. Extract certificate
    5. Check for PQC algorithms
    """
    pass

def main():
    import argparse
    parser = argparse.ArgumentParser(description='TLS Scanner')
    parser.add_argument('host', help='Target hostname')
    parser.add_argument('--port', type=int, default=443)
    parser.add_argument('--json', action='store_true')
    args = parser.parse_args()
    
    result = scan_tls_endpoint(args.host, args.port)
    
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        print_human_readable(result)

if __name__ == '__main__':
    main()
```

---

## 📝 Tasks

### Task 1: Establish TLS Connection (10 min)

**Goal:** Connect to the target and perform TLS handshake

**Code Location:** `scan_tls_endpoint()` function

**Hints:**
```python
context = ssl.create_default_context()
with socket.create_connection((host, port)) as sock:
    with context.wrap_socket(sock, server_hostname=host) as ssock:
        # You now have a TLS connection!
        protocol = ssock.version()
        cipher = ssock.cipher()
```

**Expected Output:**
```json
{
  "host": "example.com",
  "port": 443,
  "protocol": "TLSv1.3",
  "cipher": {
    "name": "TLS_AES_256_GCM_SHA384",
    "bits": 256
  }
}
```

---

### Task 2: Extract Certificate Information (10 min)

**Goal:** Parse X.509 certificate and extract key details

**Hints:**
```python
der_cert = ssock.getpeercert(binary_form=True)
cert = x509.load_der_x509_certificate(der_cert, default_backend())

# Extract:
subject = cert.subject.rfc4514_string()
issuer = cert.issuer.rfc4514_string()
not_before = cert.not_valid_before
not_after = cert.not_valid_after
public_key = cert.public_key()
```

**Expected Output:**
```json
{
  "certificate": {
    "subject": "CN=example.com",
    "issuer": "CN=DigiCert TLS RSA SHA256 2020 CA1",
    "valid_from": "2024-01-01T00:00:00",
    "valid_until": "2025-01-01T00:00:00",
    "public_key_algorithm": "RSA",
    "key_size": 2048
  }
}
```

---

### Task 3: Detect Post-Quantum Algorithms (15 min)

**Goal:** Identify if the endpoint uses PQC algorithms

**PQC Indicators:**
- Certificate signature algorithm contains: `ML-DSA`, `MLDSA`, `Dilithium`
- Public key algorithm contains: `ML-KEM`, `MLKEM`, `Kyber`
- Cipher suite contains: `X25519MLKEM768`

**Implementation:**
```python
def detect_pqc_algorithms(cert, cipher_name):
    pqc_detected = {
        "signature": False,
        "key_exchange": False,
        "algorithms": []
    }
    
    # Check signature algorithm
    sig_alg = cert.signature_algorithm_oid._name
    if 'mldsa' in sig_alg.lower() or 'dilithium' in sig_alg.lower():
        pqc_detected["signature"] = True
        pqc_detected["algorithms"].append(f"Signature: {sig_alg}")
    
    # Check cipher suite for hybrid KEM
    if 'MLKEM' in cipher_name.upper():
        pqc_detected["key_exchange"] = True
        pqc_detected["algorithms"].append(f"KEM: {cipher_name}")
    
    return pqc_detected
```

**Expected Output:**
```json
{
  "pqc": {
    "detected": true,
    "signature": true,
    "key_exchange": true,
    "algorithms": [
      "Signature: ML-DSA-65",
      "KEM: X25519MLKEM768"
    ]
  }
}
```

---

### Task 4: Pretty Print Results (10 min)

**Goal:** Display results in a human-readable format with colors

**Use colorama:**
```python
from colorama import Fore, Style, init
init(autoreset=True)

def print_human_readable(result):
    print(f"\n{Fore.CYAN}{'='*60}{Style.RESET_ALL}")
    print(f"{Fore.GREEN}TLS Scan Results{Style.RESET_ALL}")
    print(f"{Fore.CYAN}{'='*60}{Style.RESET_ALL}\n")
    
    print(f"🌐 Target: {Fore.YELLOW}{result['host']}:{result['port']}{Style.RESET_ALL}")
    print(f"🔒 Protocol: {Fore.GREEN}{result['protocol']}{Style.RESET_ALL}")
    print(f"🔑 Cipher: {Fore.CYAN}{result['cipher']['name']}{Style.RESET_ALL}")
    
    if result['pqc']['detected']:
        print(f"\n{Fore.GREEN}✓ Post-Quantum Cryptography Detected!{Style.RESET_ALL}")
        for alg in result['pqc']['algorithms']:
            print(f"  • {alg}")
    else:
        print(f"\n{Fore.YELLOW}⚠ Classical cryptography only{Style.RESET_ALL}")
```

---

## 🧪 Testing Your Scanner

### Test 1: Scan Your Lab Server

```bash
python3 scanner.py localhost --port 8443

# Expected: Shows PQC hybrid algorithms
```

### Test 2: Scan Public Website

```bash
python3 scanner.py google.com

# Expected: Shows classical TLS only (as of 2026)
```

### Test 3: JSON Output

```bash
python3 scanner.py localhost --port 8443 --json > scan-result.json

# Verify JSON is valid
cat scan-result.json | jq .
```

---

## ✅ Success Criteria

Your scanner should:
- [x] Successfully connect to TLS endpoints
- [x] Display protocol version (TLS 1.2, 1.3)
- [x] Show cipher suite details
- [x] Extract certificate information
- [x] Detect PQC algorithms (ML-KEM, ML-DSA)
- [x] Support both human-readable and JSON output
- [x] Handle connection errors gracefully

---

## 🎓 Bonus Challenges

### Challenge 1: Scan Multiple Algorithms

Modify the scanner to try connecting with different cipher suites:

```python
def scan_with_cipher(host, port, cipher_suite):
    context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    context.set_ciphers(cipher_suite)
    # ... try connection
```

### Challenge 2: Certificate Chain

Extract and display the entire certificate chain:

```python
chain = ssock.get_peer_cert_chain()
for i, cert_der in enumerate(chain):
    cert = x509.load_der_x509_certificate(cert_der, default_backend())
    print(f"Certificate {i}: {cert.subject}")
```

### Challenge 3: Vulnerability Detection

Add checks for:
- Expired certificates
- Weak key sizes (<2048 bits)
- Deprecated protocols (TLS 1.0, 1.1)

---

## 📚 Resources

- [Python ssl module](https://docs.python.org/3/library/ssl.html)
- [cryptography library](https://cryptography.io/)
- [TLS 1.3 RFC 8446](https://tools.ietf.org/html/rfc8446)
- [testssl.sh source](https://github.com/drwetter/testssl.sh) - Inspiration

---

## 🔗 Next Steps

Once completed:
- Review [solution.py](solution.py) for reference implementation
- Move to [Workshop 2: Automated Benchmarking](../02-benchmark/)

---

<div align="center">

[← Back to Lab 07](../README.md) | [Solution →](solution.py)

</div>
