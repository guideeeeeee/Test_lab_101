# Configuration Checklist
# รายการตรวจสอบการติดตั้ง

## 🎯 Pre-Installation Checklist

### Environment Setup
- [ ] Ubuntu 22.04+ or equivalent Linux distribution
- [ ] At least 4GB RAM available
- [ ] At least 10GB free disk space
- [ ] Docker and Docker Compose installed
- [ ] Internet connection for downloading packages
- [ ] Terminal access with sudo privileges

### Documentation Review
- [ ] Read [01-pqc-intro.md](../guides/01-pqc-intro.md)
- [ ] Read [02-hybrid-concept.md](../guides/02-hybrid-concept.md)
- [ ] Understand ML-KEM-768 concept
- [ ] Understand ML-DSA-65 concept
- [ ] Understand hybrid security model

---

## 🔧 Installation Checklist

### OpenSSL + OQS Installation
- [ ] Pre-compiled binaries extracted OR built from source
- [ ] `openssl version` shows 3.x
- [ ] `openssl list -providers` includes `oqsprovider`
- [ ] `openssl list -kem-algorithms` includes kyber/mlkem algorithms
- [ ] `openssl list -signature-algorithms` includes dilithium/mldsa algorithms
- [ ] Environment variables set (PATH, LD_LIBRARY_PATH)
- [ ] Variables added to ~/.bashrc for persistence
- [ ] Test key generation works: `openssl genpkey -algorithm mlkem768`

### Verification Commands
```bash
# Run these commands and check [ ] if successful
[ ] openssl version                                    # Shows 3.x
[ ] openssl list -providers | grep oqs                 # Shows oqsprovider
[ ] openssl list -kem-algorithms | grep kyber          # Shows kyber variants
[ ] openssl list -signature-algorithms | grep dilithium # Shows dilithium variants
[ ] openssl genpkey -algorithm mlkem768 -out test.key  # Creates key file
[ ] rm test.key                                        # Cleanup
```

---

## 🔐 Certificate Generation Checklist

### Classical Certificate (ECDSA)
- [ ] Generated ECDSA P-256 private key
- [ ] Key file: `certs-hybrid/hybrid-ecdsa.key` exists
- [ ] Key file permissions: 600 (read/write owner only)
- [ ] Generated certificate signing request (CSR)
- [ ] Generated self-signed certificate
- [ ] Certificate file: `certs-hybrid/hybrid-ecdsa.crt` exists
- [ ] Certificate valid for 365 days
- [ ] Certificate size ~1-2 KB
- [ ] Can inspect with: `openssl x509 -in hybrid-ecdsa.crt -text -noout`

### PQC Certificate (ML-DSA)
- [ ] Generated ML-DSA-65 private key
- [ ] Key file: `certs-hybrid/hybrid-mldsa.key` exists
- [ ] Key file permissions: 600
- [ ] Generated certificate signing request (CSR)
- [ ] Generated self-signed certificate
- [ ] Certificate file: `certs-hybrid/hybrid-mldsa.crt` exists
- [ ] Certificate valid for 365 days
- [ ] Certificate size ~4-5 KB
- [ ] Can inspect with: `openssl x509 -in hybrid-mldsa.crt -text -noout`

### Certificate Chain
- [ ] Created hybrid-chain.pem combining both certificates
- [ ] Chain file size ~5-7 KB
- [ ] Both certificates have same Subject/CN
- [ ] Certificates not expired

### Verification Commands
```bash
# Check all files exist
[ ] ls -lh certs-hybrid/hybrid-ecdsa.key
[ ] ls -lh certs-hybrid/hybrid-ecdsa.crt
[ ] ls -lh certs-hybrid/hybrid-mldsa.key
[ ] ls -lh certs-hybrid/hybrid-mldsa.crt
[ ] ls -lh certs-hybrid/hybrid-chain.pem

# Verify certificates
[ ] openssl x509 -in certs-hybrid/hybrid-ecdsa.crt -noout -dates
[ ] openssl x509 -in certs-hybrid/hybrid-mldsa.crt -noout -dates
```

---

## ⚙️ NGINX Configuration Checklist

### Configuration Files
- [ ] `configs/nginx-hybrid.conf` exists
- [ ] TLS 1.3 protocol enabled
- [ ] Hybrid groups configured: `ssl_ecdh_curve x25519_kyber768:X25519:P-256`
- [ ] Cipher suites configured: TLS_AES_256_GCM_SHA384
- [ ] Both certificates referenced in config
- [ ] Certificate paths absolute or correct relative paths
- [ ] Session cache configured
- [ ] Session tickets disabled
- [ ] Security headers added (HSTS, X-Frame-Options, etc.)
- [ ] Health check endpoint configured
- [ ] SSL info endpoint configured (for debugging)

### Optional Configuration Files
- [ ] `configs/ssl-params-hybrid.conf` created (if using)
- [ ] `configs/groups-priority.conf` created (if using)
- [ ] Additional configs included in main nginx.conf

### Configuration Validation
```bash
# Test configuration syntax
[ ] docker exec pqc-hybrid-nginx nginx -t    # Shows "syntax is ok"
```

---

## 🐳 Docker Setup Checklist

### Docker Files
- [ ] `docker/Dockerfile.nginx-pqc` exists
- [ ] Dockerfile includes OpenSSL+OQS
- [ ] Dockerfile includes NGINX build
- [ ] Dockerfile copies configuration files
- [ ] Dockerfile copies certificate files
- [ ] Dockerfile exposes ports 80 and 443
- [ ] `docker-compose-hybrid.yml` exists
- [ ] Compose file maps correct ports (8443:443, 8080:80)
- [ ] Compose file mounts configs as read-only
- [ ] Compose file mounts certificates as read-only
- [ ] Compose file sets LD_LIBRARY_PATH

### Docker Build & Run
- [ ] Built Docker image successfully
- [ ] Container starts without errors
- [ ] Container name: `pqc-hybrid-nginx`
- [ ] Port 8443 accessible
- [ ] Port 8080 accessible
- [ ] Logs show no errors: `docker logs pqc-hybrid-nginx`
- [ ] Container restarts automatically (unless-stopped)

### Docker Verification
```bash
# Check container status
[ ] docker ps | grep pqc-hybrid-nginx           # Shows running
[ ] docker logs pqc-hybrid-nginx | grep error   # No errors
[ ] curl -k https://localhost:8443              # Returns content
[ ] curl http://localhost:8080                  # Redirects to HTTPS
```

---

## 🧪 Testing Checklist

### Basic Connectivity
- [ ] HTTP (8080) redirects to HTTPS
- [ ] HTTPS (8443) responds
- [ ] Health check endpoint responds: `curl -k https://localhost:8443/health`
- [ ] SSL info endpoint shows TLS details: `curl -k https://localhost:8443/ssl-info`
- [ ] Index page loads in browser

### TLS Connection Tests
- [ ] Classical connection works: `openssl s_client -connect localhost:8443 -groups X25519`
- [ ] Hybrid connection works: `openssl s_client -connect localhost:8443 -groups x25519_kyber768`
- [ ] Connection shows TLSv1.3
- [ ] Connection shows correct cipher suite
- [ ] Connection shows correct group (x25519_kyber768 for hybrid)

### Certificate Tests
- [ ] ECDSA certificate served to classical clients
- [ ] ML-DSA certificate served to PQC clients (if client supports)
- [ ] Certificate chain valid
- [ ] Certificate not expired
- [ ] Certificate CN matches server name

### Advanced Tests
- [ ] Multiple concurrent connections succeed
- [ ] Session resumption works (if enabled)
- [ ] Performance acceptable (handshake < 100ms)
- [ ] No memory leaks after 1000 connections
- [ ] CPU usage reasonable under load

---

## 📊 Performance Checklist

### Resource Monitoring
- [ ] Container CPU usage tracked: `docker stats pqc-hybrid-nginx`
- [ ] Container memory usage tracked
- [ ] Disk I/O monitored
- [ ] Network bandwidth monitored
- [ ] Log sizes managed

### Baseline Metrics Recorded
- [ ] Classical handshake time: _______ ms
- [ ] Hybrid handshake time: _______ ms
- [ ] Performance overhead calculated: _______ %
- [ ] Acceptable for use case: ☐ Yes ☐ No

---

## 🐛 Troubleshooting Checklist

### Common Issues Checked
- [ ] LD_LIBRARY_PATH set correctly
- [ ] OpenSSL finds oqs-provider
- [ ] Certificate paths correct in nginx.conf
- [ ] Certificate file permissions correct (644 for .crt, 600 for .key)
- [ ] Ports not already in use
- [ ] Firewall allows ports 8080 and 8443
- [ ] Docker has sufficient resources
- [ ] No typos in algorithm names
- [ ] Client supports TLS 1.3 (for hybrid)

### Known Issues Documented
- [ ] List any issues encountered: ___________________________________
- [ ] List workarounds applied: _____________________________________
- [ ] List unresolved issues: _______________________________________

---

## 📝 Documentation Checklist

### Lab Documentation
- [ ] Worksheet filled out: [algorithm-comparison.md](algorithm-comparison.md)
- [ ] Test results recorded
- [ ] Performance metrics documented
- [ ] Screenshots taken (optional)
- [ ] Issues and solutions documented

### Understanding Verified
- [ ] Can explain hybrid key exchange
- [ ] Can explain dual certificates
- [ ] Can explain ML-KEM-768
- [ ] Can explain ML-DSA-65
- [ ] Can explain security benefits
- [ ] Can explain performance tradeoffs

---

## ✅ Final Verification

### System Status
- [ ] All services running
- [ ] All tests passing
- [ ] No errors in logs
- [ ] Performance acceptable
- [ ] Ready for Lab 04 (performance testing)

### Sign-off
**Completed by:** _______________  
**Date:** _______________  
**Time spent:** _______ minutes  
**Overall success:** ☐ Complete ☐ Partial ☐ Issues  

**Notes:**
___________________________________________________________________
___________________________________________________________________
___________________________________________________________________

---

## 🎯 Next Steps

After completing this checklist:
1. ✅ All items checked → Proceed to **Lab 04: Hybrid Testing**
2. ⚠️ Some items unchecked → Review relevant guide sections
3. ❌ Major issues → Check [docs/troubleshooting.md](../../../docs/troubleshooting.md)

---

**Ready for Lab 04?** ☐ Yes ☐ No  
**If No, what's blocking:** _______________
