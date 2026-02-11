# Troubleshooting Guide
# คู่มือแก้ไขปัญหา

Common issues and solutions for PQC labs.

---

## 🐳 Docker Issues

### Issue: "Cannot connect to Docker daemon"

**Symptom:**
```
docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Solutions:**

**Linux:**
```bash
# Start Docker daemon
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker  # Apply without logout
```

**macOS:**
```bash
# Start Docker Desktop application
open -a Docker

# Wait for Docker to fully start (look for whale icon in menu bar)
```

**Windows (WSL2):**
```powershell
# In PowerShell (Administrator)
wsl --shutdown
# Restart Docker Desktop
```

---

### Issue: "Port 443 already in use"

**Symptom:**
```
Error starting userland proxy: listen tcp 0.0.0.0:443: bind: address already in use
```

**Solutions:**

**Option 1: Stop conflicting service**
```bash
# Find what's using port 443
sudo lsof -i :443
# or
sudo netstat -tulpn | grep :443

# Common culprits:
sudo systemctl stop apache2
sudo systemctl stop nginx
```

**Option 2: Change lab port**
```yaml
# Edit docker-compose.yml
ports:
  - "8443:443"  # Use 8443 instead of 443

# Then access via https://localhost:8443
```

**Option 3: Kill process**
```bash
sudo kill -9 <PID>
```

---

### Issue: "Container keeps restarting"

**Symptom:**
```bash
docker ps  # Shows "Restarting (1) X seconds ago"
```

**Solutions:**

```bash
# Check logs
docker logs <container-name>

# Common issues in logs:
# - Configuration syntax error
# - Missing certificate files
# - Port already bound

# Test NGINX config
docker exec <container> nginx -t

# Restart with fresh state
docker-compose down
docker-compose up --force-recreate
```

---

## 🔒 TLS/SSL Issues

### Issue: "Unable to get local issuer certificate"

**Symptom:**
```
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

**Solution:**
```bash
# For testing with self-signed certs, use -k flag
curl -k https://localhost

# Or with OpenSSL
openssl s_client -connect localhost:443 -CAfile certs/ca.crt
```

---

### Issue: "wrong version number" or "SSL routines error"

**Symptom:**
```
error:1408F10B:SSL routines:ssl3_get_record:wrong version number
```

**Causes & Solutions:**

**Cause 1: Connecting to HTTP instead of HTTPS**
```bash
# Wrong
curl http://localhost:443

# Correct
curl https://localhost:443
```

**Cause 2: TLS version mismatch**
```bash
# Try specific TLS version
openssl s_client -connect localhost:443 -tls1_2
openssl s_client -connect localhost:443 -tls1_3
```

---

## 🐍 Python Issues

### Issue: "ModuleNotFoundError: No module named 'matplotlib'"

**Solution:**
```bash
# Install missing packages
pip3 install -r requirements.txt

# Or install individually
pip3 install matplotlib pandas numpy

# Use --user if permission denied
pip3 install --user matplotlib pandas numpy
```

---

### Issue: "pip3: command not found"

**Solution:**

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install python3-pip
```

**macOS:**
```bash
# pip3 comes with Python 3
brew install python3

# Or use python3 -m pip instead
python3 -m pip install matplotlib
```

---

## 🔐 OpenSSL / PQC Issues

### Issue: "unknown group name: x25519_kyber768"

**Symptom:**
```
error:0A00018E:SSL routines::unknown group
```

**Cause:** oqs-provider not loaded or not in library path

**Solutions:**

```bash
# Check if oqs-provider is available
openssl list -providers

# Should show: oqsprovider

# If not, set library path
export LD_LIBRARY_PATH=/path/to/openssl-oqs/lib:$LD_LIBRARY_PATH

# Or use full path to OpenSSL binary
/path/to/openssl-oqs/bin/openssl s_client -connect localhost:8443
```

---

### Issue: "PQC algorithms not listing"

**Check installation:**
```bash
# List available KEMs
openssl list -kem-algorithms

# Should show: kyber512, kyber768, kyber1024, etc.

# If empty, oqs-provider not properly installed
# Re-run Lab 03 installation steps
```

---

## 📊 Performance Testing Issues

### Issue: "ab: command not found"

**Solution:**

**Ubuntu/Debian:**
```bash
sudo apt-get install apache2-utils
```

**macOS:**
```bash
brew install httpd
# or
brew install apr-util
```

---

### Issue: "ab: SSL not supported"

**Symptom:**
```
ab: SSL not compiled in; no https support
```

**Solution:**

**Use alternative tools:**
```bash
# wrk (more modern)
wrk -t4 -c100 -d30s https://localhost

# hey (Go-based)
hey -n 1000 -c 10 https://localhost

# Or use curl in loop (slower but works)
for i in {1..100}; do curl -k https://localhost; done
```

---

### Issue: "tcpdump: permission denied"

**Solutions:**

**Option 1: Use sudo**
```bash
sudo tcpdump -i any port 443
```

**Option 2: Add capability (Linux)**
```bash
sudo setcap cap_net_raw,cap_net_admin=eip /usr/bin/tcpdump
```

**Option 3: Add user to pcap group**
```bash
sudo usermod -aG pcap $USER
newgrp pcap
```

---

## 📁 File/Path Issues

### Issue: "No such file or directory"

**Common causes:**

**Wrong working directory:**
```bash
# Always check you're in correct directory
pwd

# Should be in lab directory, e.g.:
# /home/user/pqcv2/labs/00-target-app
```

**Missing generated files:**
```bash
# Certificates not generated
cd labs/00-target-app
./setup.sh  # This generates certs

# Scripts not executable
chmod +x setup.sh
chmod +x scripts/*.sh
```

---

## 🖥️ System Resource Issues

### Issue: "Out of memory" or slow performance

**Check resources:**
```bash
# Check available memory
free -h

# Check Docker resource limits
docker stats

# Check disk space
df -h
```

**Solutions:**

```bash
# Increase Docker memory limit (Docker Desktop)
# Settings → Resources → Memory: 4GB minimum

# Clean up Docker
docker system prune -a --volumes

# Stop unused containers
docker ps -a
docker rm $(docker ps -aq)
```

---

## 🌐 Network Issues

### Issue: "Network error" or "Connection refused"

**Checklist:**

```bash
# 1. Is container running?
docker ps | grep pqc-target

# 2. Is port exposed?
docker port <container>

# 3. Is service listening?
docker exec <container> netstat -tuln | grep 443

# 4. Can connect from inside container?
docker exec <container> curl -k https://localhost

# 5. Firewall blocking?
sudo ufw status  # Ubuntu
sudo firewall-cmd --list-all  # CentOS/RHEL
```

---

## 📄 Lab-Specific Issues

### Lab 00: Target Application

**Issue: MySQL not starting**
```bash
# Wait for MySQL to initialize (first time takes 30-60s)
docker logs pqc-target-mysql

# Look for: "MySQL init process done. Ready for start up."

# If stuck, remove volume and restart
docker-compose down -v
docker-compose up -d
```

---

### Lab 03: PQC Setup

**Issue: Compilation takes forever**
```bash
# Use pre-compiled binaries instead!
# They're provided in binaries/ directory

# If you must compile:
# Expect 30-60 minutes depending on CPU
# Use ninja instead of make (faster)
cmake -GNinja ..
ninja
```

---

### Lab 05: Report Generation

**Issue: PDF generation fails**
```bash
# Install system dependencies
sudo apt-get install wkhtmltopdf

# Or use alternative
pip3 install weasyprint

# Or just generate HTML
python3 scripts/build-report.py --format html
```

---

## 🆘 Getting Help

If issue persists:

1. **Check logs:**
```bash
docker logs <container>
journalctl -u docker  # System Docker logs
```

2. **Search issues:**
- GitHub Issues: https://github.com/yourusername/pqcv2/issues
- Stack Overflow (tag: openssl, docker)

3. **Reset to clean state:**
```bash
cd ~/pqcv2
docker-compose -f labs/*/docker-compose*.yml down -v
git clean -fdx  # Remove all untracked files
./scripts/setup-all.sh  # Start fresh
```

4. **Collect debug info:**
```bash
# System info
uname -a
docker version
python3 --version
openssl version

# Lab state
docker ps -a
docker images
docker network ls
```

---

## 📋 Quick Diagnostic Script

```bash
#!/bin/bash
echo "=== System Info ==="
uname -a
echo ""

echo "=== Docker ==="
docker --version
docker ps
echo ""

echo "=== Ports ==="
sudo netstat -tuln | grep -E ':(443|8443|3306)'
echo ""

echo "=== Disk Space ==="
df -h .
echo ""

echo "=== Memory ==="
free -h
echo ""

echo "=== Recent Docker Logs ==="
docker logs --tail 20 pqc-target-nginx 2>&1 || echo "Container not running"
```

Save as `diagnose.sh`, then:
```bash
chmod +x diagnose.sh
./diagnose.sh > debug-info.txt
```

---

<div align="center">

[← Back to Docs](README.md) | [Report Issue](https://github.com/yourusername/pqcv2/issues)

</div>
