# NGINX Hybrid TLS Configuration
# การตั้งค่า NGINX สำหรับ Hybrid TLS

## 🎯 Configuration Goals

Configure NGINX to:
1. Support hybrid key exchange (X25519+MLKEM768)
2. Serve dual certificates (ECDSA + MLDSA)
3. Use quantum-resistant cipher suites
4. Fall back gracefully for non-PQC clients
5. Optimize performance

---

## 📝 Base Configuration

### Complete nginx-hybrid.conf

```nginx
# PQC Hybrid TLS Configuration
# labs/03-pqc-hybrid-setup/configs/nginx-hybrid.conf

user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for" '
                    'ssl_protocol=$ssl_protocol ssl_cipher=$ssl_cipher '
                    'ssl_curve=$ssl_curve';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    keepalive_timeout 65;

    # PQC-Hybrid HTTPS Server
    server {
        listen 443 ssl http2;
        listen [::]:443 ssl http2;
        server_name pqc-lab.local localhost;

        # Root directory
        root /usr/share/nginx/html;
        index index.html;

        # ============================================
        # SSL/TLS Protocol Configuration
        # ============================================
        
        # TLS 1.3 is REQUIRED for hybrid key exchange
        ssl_protocols TLSv1.3;
        
        # TLS 1.2 fallback (if needed for compatibility)
        # ssl_protocols TLSv1.3 TLSv1.2;

        # ============================================
        # Hybrid Key Exchange (KEM)
        # ============================================
        
        # Priority order: hybrid first, then classical fallback
        # x25519_kyber768 = X25519 + ML-KEM-768 (hybrid)
        # X25519 = Classical ECDHE
        # P-256 = Classical ECDHE (fallback)
        
        ssl_ecdh_curve x25519_kyber768:X25519:P-256;
        
        # Alternative: More PQC options
        # ssl_ecdh_curve x25519_kyber768:x25519_kyber1024:X25519:P-256;

        # ============================================
        # Cipher Suites
        # ============================================
        
        # TLS 1.3 cipher suites (quantum-resistant symmetric crypto)
        ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256';
        
        # Prefer server cipher order
        ssl_prefer_server_ciphers on;

        # ============================================
        # Dual Certificates (Classical + PQC)
        # ============================================
        
        # Classical certificate (ECDSA P-256)
        # Used by clients without PQC support
        ssl_certificate /etc/nginx/certs/hybrid-ecdsa.crt;
        ssl_certificate_key /etc/nginx/certs/hybrid-ecdsa.key;
        
        # PQC certificate (ML-DSA-65)
        # Used by PQC-capable clients
        ssl_certificate /etc/nginx/certs/hybrid-mldsa.crt;
        ssl_certificate_key /etc/nginx/certs/hybrid-mldsa.key;
        
        # ============================================
        # Session Configuration
        # ============================================
        
        # Session cache (10MB = ~40,000 sessions)
        ssl_session_cache shared:MozSSL:10m;
        ssl_session_timeout 1d;
        
        # Disable session tickets (recommended for PQC)
        # Reduces attack surface
        ssl_session_tickets off;

        # ============================================
        # Security Headers
        # ============================================
        
        # HSTS (HTTP Strict Transport Security)
        add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
        
        # Prevent clickjacking
        add_header X-Frame-Options "SAMEORIGIN" always;
        
        # Prevent MIME sniffing
        add_header X-Content-Type-Options "nosniff" always;
        
        # XSS Protection
        add_header X-XSS-Protection "1; mode=block" always;

        # ============================================
        # Application Routes
        # ============================================
        
        location / {
            try_files $uri $uri/ =404;
        }
        
        # API endpoint (if needed)
        location /api/ {
            proxy_pass http://localhost:3000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Health check endpoint
        location /health {
            access_log off;
            return 200 "OK\n";
            add_header Content-Type text/plain;
        }
        
        # TLS info endpoint (for debugging)
        location /ssl-info {
            return 200 "Protocol: $ssl_protocol\nCipher: $ssl_cipher\nCurve: $ssl_curve\n";
            add_header Content-Type text/plain;
        }
    }

    # HTTP to HTTPS redirect
    server {
        listen 80;
        listen [::]:80;
        server_name pqc-lab.local localhost;

        # Redirect all HTTP traffic to HTTPS
        return 301 https://$server_name$request_uri;
    }
}
```

---

## 🔍 Line-by-Line Explanation

### TLS Protocol

```nginx
ssl_protocols TLSv1.3;
```
- **TLS 1.3 required** for hybrid key exchange
- TLS 1.2 doesn't support post-handshake authentication needed for hybrid KEMs
- Can add `TLSv1.2` for fallback but loses hybrid benefits

### Hybrid Key Exchange

```nginx
ssl_ecdh_curve x25519_kyber768:X25519:P-256;
```
- **Priority order**: Try hybrid first, fallback to classical
- `x25519_kyber768`: Hybrid (X25519 + ML-KEM-768)
- `X25519`: Classical ECDHE (fast, widely supported)
- `P-256`: Classical ECDHE (NIST standard, slower)

**Available hybrid curves:**
- `x25519_kyber512`: Lower security (AES-128 equivalent)
- `x25519_kyber768`: Recommended (AES-192 equivalent) ⭐
- `x25519_kyber1024`: Highest security (AES-256 equivalent)
- `p256_kyber768`: Alternative using P-256 instead of X25519
- `p384_kyber1024`: High security alternative

### Cipher Suites

```nginx
ssl_ciphers 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256';
```
- **TLS 1.3 cipher suites** (symmetric crypto)
- `AES-256-GCM`: AES with Galois/Counter Mode (quantum-resistant)
- `CHACHA20-POLY1305`: Alternative stream cipher (mobile-friendly)
- These are already quantum-resistant (symmetric crypto is safer)

### Dual Certificates

```nginx
ssl_certificate /etc/nginx/certs/hybrid-ecdsa.crt;
ssl_certificate_key /etc/nginx/certs/hybrid-ecdsa.key;
ssl_certificate /etc/nginx/certs/hybrid-mldsa.crt;
ssl_certificate_key /etc/nginx/certs/hybrid-mldsa.key;
```
- **Multiple `ssl_certificate` directives** serve different certs
- NGINX selects based on client's `signature_algorithms` extension
- Client without PQC support → Gets ECDSA cert
- Client with PQC support → Gets ML-DSA cert

### Session Management

```nginx
ssl_session_cache shared:MozSSL:10m;
ssl_session_timeout 1d;
ssl_session_tickets off;
```
- **Session cache**: Store session data to avoid full handshake
- **10MB cache**: ~40,000 sessions (each hybrid session is larger)
- **Session tickets disabled**: Security best practice for PQC
  - Tickets would require encrypting with long-term key
  - Increases attack surface

---

## 📂 Additional Configuration Files

### ssl-params-hybrid.conf

Advanced SSL parameters:

```nginx
# labs/03-pqc-hybrid-setup/configs/ssl-params-hybrid.conf

# Diffie-Hellman parameters (for TLS 1.2 fallback)
# ssl_dhparam /etc/nginx/certs/dhparam.pem;

# OCSP Stapling (if using real CA)
# ssl_stapling on;
# ssl_stapling_verify on;
# ssl_trusted_certificate /etc/nginx/certs/chain.pem;
# resolver 8.8.8.8 8.8.4.4 valid=300s;
# resolver_timeout 5s;

# Session ticket key (if enabling tickets)
# ssl_session_ticket_key /etc/nginx/certs/ticket.key;

# Client certificate verification (optional)
# ssl_client_certificate /etc/nginx/certs/client-ca.crt;
# ssl_verify_client optional;
# ssl_verify_depth 2;

# Buffer sizes (tune for performance)
ssl_buffer_size 4k;  # Smaller = lower latency, higher overhead

# Timeouts
ssl_session_timeout 1d;
keepalive_timeout 65;
send_timeout 60;
```

### groups-priority.conf

Different prioritization strategies:

```nginx
# labs/03-pqc-hybrid-setup/configs/groups-priority.conf

# Strategy 1: PQC-First (Recommended for testing)
# ssl_ecdh_curve x25519_kyber768:x25519_kyber1024:X25519:P-256;

# Strategy 2: Balanced (Recommended for production)
# ssl_ecdh_curve X25519:x25519_kyber768:P-256;

# Strategy 3: Pure PQC (Future)
# ssl_ecdh_curve kyber768:kyber1024;

# Strategy 4: Maximum Compatibility
# ssl_ecdh_curve X25519:P-256:P-384:x25519_kyber768;
```

---

## 🐳 Docker Integration

### Dockerfile.nginx-pqc

```dockerfile
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    ninja-build \
    libpcre3-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Build OpenSSL with OQS
WORKDIR /build
COPY binaries/openssl-oqs /usr/local/

# Build NGINX with OpenSSL+OQS
RUN wget https://nginx.org/download/nginx-1.24.0.tar.gz && \
    tar -xzf nginx-1.24.0.tar.gz && \
    cd nginx-1.24.0 && \
    ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-openssl=/usr/local \
        --with-openssl-opt="-I/usr/local/include -L/usr/local/lib" && \
    make -j$(nproc) && \
    make install

# Copy configuration
COPY configs/nginx-hybrid.conf /etc/nginx/nginx.conf

# Copy certificates
COPY certs-hybrid/*.crt /etc/nginx/certs/
COPY certs-hybrid/*.key /etc/nginx/certs/

# Create html directory
RUN mkdir -p /usr/share/nginx/html
COPY www/index.html /usr/share/nginx/html/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose-hybrid.yml

```yaml
version: '3.8'

services:
  nginx-pqc:
    build:
      context: .
      dockerfile: docker/Dockerfile.nginx-pqc
    container_name: pqc-hybrid-nginx
    ports:
      - "8443:443"
      - "8080:80"
    volumes:
      - ./configs/nginx-hybrid.conf:/etc/nginx/nginx.conf:ro
      - ./certs-hybrid:/etc/nginx/certs:ro
      - ./www:/usr/share/nginx/html:ro
      - ./logs:/var/log/nginx
    environment:
      - LD_LIBRARY_PATH=/usr/local/lib
    restart: unless-stopped
    networks:
      - pqc-network

networks:
  pqc-network:
    driver: bridge
```

---

## 🧪 Testing the Configuration

### Test Configuration Syntax

```bash
# If using Docker
docker exec pqc-hybrid-nginx nginx -t

# If using local NGINX
nginx -t -c /path/to/nginx-hybrid.conf
```

### Test TLS Connection

> ⚠️ ต้องรันผ่าน `docker exec` — host openssl ไม่รองรับ PQC signature

```bash
# Test hybrid connection
docker exec pqc-hybrid-nginx sh -c '
OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
/opt/openssl/bin/openssl s_client \
  -connect localhost:443 \
  -groups mlkem768:p384_mlkem768:X25519 \
  -servername pqc-lab.local \
  -brief </dev/null 2>&1'

# Look for:
# Protocol: TLSv1.3
# Cipher: TLS_AES_256_GCM_SHA384
# Signature type: p384_mldsa65
```

### Test Certificate Selection

```bash
# Request with PQC support
docker exec pqc-hybrid-nginx sh -c '
OPENSSL_CONF=/opt/openssl/ssl/openssl.cnf \
LD_LIBRARY_PATH=/opt/openssl/lib64:/opt/oqs/lib \
/opt/openssl/bin/openssl s_client -connect localhost:443 -showcerts </dev/null 2>/dev/null' | grep "Signature"
# Should see: p384_mldsa65
```

### Check SSL Info Endpoint

```bash
# ✅ ใช้ docker exec เพราะ host curl ไม่รองรับ PQC signature
docker exec pqc-hybrid-nginx curl -k -s https://localhost/ssl-info
# Output:
# Protocol: TLSv1.3
# Cipher: TLS_AES_256_GCM_SHA384
# Curve: x25519_mlkem768
```

---

## 📊 Performance Tuning

### Worker Configuration

```nginx
# Adjust based on CPU cores
worker_processes auto;  # One per CPU core

# Increase connections for high traffic
events {
    worker_connections 2048;  # Default: 1024
    use epoll;  # Linux optimization
}
```

### Buffer Tuning

```nginx
# Smaller buffer = lower latency (good for PQC)
ssl_buffer_size 4k;  # Default: 16k

# But increases overhead, tune based on:
# - 4k: Low latency (recommended for PQC)
# - 16k: Higher throughput
# - 8k: Balanced
```

### Caching

```nginx
# Increase cache for PQC (larger session data)
ssl_session_cache shared:MozSSL:20m;  # 20MB instead of 10MB

# Or use distributed cache
# ssl_session_cache shared:MozSSL:50m;
```

---

## 🐛 Troubleshooting

### Issue: "unknown directive ssl_ecdh_curve"

```bash
# NGINX not built with OQS support
# Rebuild NGINX with OpenSSL+OQS

# Or check openssl
nginx -V 2>&1 | grep OpenSSL
# Should show: OpenSSL 3.x
```

### Issue: "no suitable shared cipher"

```bash
# Client doesn't support TLS 1.3 or hybrid groups
# Add TLS 1.2 fallback:
ssl_protocols TLSv1.3 TLSv1.2;
ssl_ecdh_curve X25519:P-256:x25519_kyber768;
```

### Issue: Certificate not found

```bash
# Check paths
docker exec pqc-hybrid-nginx ls -l /etc/nginx/certs/

# Check permissions
chmod 644 certs-hybrid/*.crt
chmod 600 certs-hybrid/*.key
```

---

## 🎯 Key Takeaways

1. **TLS 1.3 required** for hybrid key exchange
2. **Priority order matters**: Hybrid first, classical fallback
3. **Dual certificates** provide smooth transition
4. **Session tickets disabled** for PQC security
5. **Buffer tuning** can improve latency
6. **Health check endpoint** helps monitoring
7. **Docker simplifies** deployment

---

**Next:** Test the hybrid setup in Lab 04!
