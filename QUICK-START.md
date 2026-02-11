# Quick Start Guide | คู่มือเริ่มต้นอย่างรวดเร็ว

เอกสารนี้จะแนะนำคุณในการเตรียมสภาพแวดล้อมและเริ่มต้นใช้งาน lab ภายใน 15 นาที

---

## 📋 Table of Contents

- [System Requirements](#system-requirements)
- [Step 1: Install Prerequisites](#step-1-install-prerequisites)
- [Step 2: Clone Repository](#step-2-clone-repository)
- [Step 3: Run Setup](#step-3-run-setup)
- [Step 4: Verify Installation](#step-4-verify-installation)
- [Step 5: Start First Lab](#step-5-start-first-lab)
- [Troubleshooting](#troubleshooting)

---

## 💻 System Requirements | ความต้องการของระบบ

### Minimum | ขั้นต่ำ
- **OS:** Ubuntu 20.04+ / Debian 11+ / macOS 11+ / Windows 10 (WSL2)
- **RAM:** 4 GB
- **Storage:** 10 GB free space
- **CPU:** 2 cores
- **Internet:** Required for initial setup

### Recommended | แนะนำ
- **OS:** Ubuntu 22.04 LTS
- **RAM:** 8 GB
- **Storage:** 20 GB free space
- **CPU:** 4 cores
- **Internet:** Stable connection

---

## 🔧 Step 1: Install Prerequisites

### On Ubuntu/Debian

```bash
# Update package list
sudo apt update

# Install essential tools
sudo apt install -y \
    docker.io \
    docker-compose \
    git \
    python3 \
    python3-pip \
    curl \
    wget \
    openssl \
    net-tools

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Apply group changes (requires logout/login or reboot)
newgrp docker

# Verify Docker
docker --version
docker-compose --version
```

### On macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install git python3 docker docker-compose

# Start Docker Desktop
open -a Docker

# Verify installation
docker --version
python3 --version
```

### On Windows (WSL2)

```powershell
# 1. Install WSL2 (PowerShell as Administrator)
wsl --install

# 2. Install Ubuntu from Microsoft Store

# 3. Open Ubuntu terminal and follow Ubuntu steps above

# 4. Install Docker Desktop for Windows
# Download from: https://www.docker.com/products/docker-desktop
```

---

## 📥 Step 2: Clone Repository

```bash
# Navigate to your preferred directory
cd ~

# Clone the repository
git clone https://github.com/yourusername/pqcv2.git

# Enter project directory
cd pqcv2

# Check structure
ls -la
```

**Expected output:**
```
drwxr-xr-x  labs/
drwxr-xr-x  docs/
drwxr-xr-x  scripts/
-rw-r--r--  README.md
-rw-r--r--  QUICK-START.md
-rw-r--r--  PREREQUISITES.md
```

---

## ⚙️ Step 3: Run Setup

The setup script will:
- Install Python dependencies
- Pull required Docker images
- Download pre-compiled OpenSSL+OQS binaries
- Set up network configurations
- Prepare lab environments

```bash
# Make script executable
chmod +x scripts/setup-all.sh

# Run setup (takes 5-10 minutes)
./scripts/setup-all.sh

# Activate venv ก่อนใช้ lab เสมอ
source ~/.pqc-venv/bin/activate
```

### What's Happening?

```bash
[1/7] Checking system requirements...              ✓
[2/7] Installing Python dependencies...            ✓
[3/7] Pulling Docker images...                     ✓
[4/7] Downloading PQC binaries...                  ✓
[5/7] Setting up lab environments...               ✓
[6/7] Creating network configurations...           ✓
[7/7] Running verification tests...                ✓

✅ Setup complete! Ready to start labs.
```

---

## ✅ Step 4: Verify Installation

Run the verification script to ensure everything is properly installed:

```bash
./scripts/verify-setup.sh
```

### Expected Output:

```
🔍 Verifying PQC Lab Setup...

✓ Docker daemon is running
✓ Docker Compose is available
✓ Python 3.8+ is installed
✓ Required Python packages installed
✓ OpenSSL 3.x found
✓ liboqs library present
✓ oqs-provider configured
✓ Network connectivity OK
✓ Port 443 available
✓ Port 8080 available

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All checks passed!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Next steps:
  cd labs/00-target-app
  ./setup.sh
```

### If Verification Fails

See [Troubleshooting](#troubleshooting) section below.

---

## 🚀 Step 5: Start First Lab

### Lab 00: Target Application

```bash
# Navigate to first lab
cd labs/00-target-app

# Read the instructions
cat README.md

# Run setup script
./setup.sh
```

This will:
1. Build a Docker container with a 2019-standard web server
2. Generate RSA-2048 certificates
3. Configure TLS 1.2 with classical cipher suites
4. Start the web server on https://localhost

### Verify it's running:

```bash
# Check container status
docker ps

# Test connection
curl -k https://localhost

# Check TLS configuration
openssl s_client -connect localhost:443 -brief
```

**Expected:**
```
CONNECTION ESTABLISHED
Protocol version: TLSv1.2
Ciphersuite: ECDHE-RSA-AES256-GCM-SHA384
Peer certificate: CN = corporate-2019.local
Hash used: SHA256
Signature type: RSA
```

---

## 📚 Next Steps

After completing Lab 00, proceed sequentially:

1. **[Lab 01: Manual Discovery](labs/01-manual-discovery/)** (45 min)
   - Learn cryptography basics
   - Scan the target application
   - Identify quantum-vulnerable algorithms

2. **[Lab 02: Baseline Testing](labs/02-baseline-testing/)** (60 min)
   - Measure classical TLS performance
   - Collect baseline metrics

3. **[Lab 03: PQC Hybrid Setup](labs/03-pqc-hybrid-setup/)** (90 min)
   - Install post-quantum cryptography
   - Configure hybrid TLS

4. **[Lab 04: Hybrid Testing](labs/04-hybrid-testing/)** (60 min)
   - Measure hybrid TLS performance

5. **[Lab 05: Analysis & Reporting](labs/05-analysis-reporting/)** (90 min)
   - Compare results
   - Generate professional reports

---

## 🆘 Troubleshooting

### Docker daemon not running

```bash
# Linux
sudo systemctl start docker
sudo systemctl enable docker

# macOS
open -a Docker

# Verify
docker ps
```

### Permission denied errors

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply immediately (or logout/login)
newgrp docker
```

### Port 443 already in use

```bash
# Find process using port 443
sudo lsof -i :443

# Kill the process (replace PID)
sudo kill -9 <PID>

# Or change lab port in docker-compose.yml
ports:
  - "8443:443"  # Use 8443 instead
```

### Python package installation fails

```bash
# Upgrade pip
python3 -m pip install --upgrade pip

# Install with user flag
pip3 install --user -r requirements.txt

# Or use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Cannot connect to localhost

```bash
# Check if container is running
docker ps

# Check container logs
docker logs pqc-target-app

# Restart container
cd labs/00-target-app
docker-compose down
docker-compose up -d
```

### OpenSSL version too old

```bash
# Check version
openssl version

# If < 3.0, we'll use containerized version
# (all labs use Docker, so this shouldn't be an issue)
```

---

## 📖 Additional Resources

- **Detailed Prerequisites:** [PREREQUISITES.md](PREREQUISITES.md)
- **Lab Overview:** [README.md](README.md)
- **Troubleshooting Guide:** [docs/troubleshooting.md](docs/troubleshooting.md)
- **Glossary:** [docs/glossary.md](docs/glossary.md)

---

## 💡 Tips for Success

1. **Follow labs in order** - Each lab builds on previous ones
2. **Read README files** - Each lab has detailed instructions
3. **Take notes** - Use provided worksheets
4. **Ask questions** - Use GitHub Discussions
5. **Don't skip breaks** - Labs are intensive!

---

## ⏱️ Time Estimates

| Task | Time |
|------|------|
| Prerequisites installation | 10-15 min |
| Repository clone | 1 min |
| Setup script | 5-10 min |
| Verification | 2 min |
| Lab 00 setup | 5 min |
| **Total** | **~30 min** |

---

## 🎯 Ready to Start?

```bash
cd labs/00-target-app
cat README.md
./setup.sh
```

**Good luck! 🚀**

---

<div align="center">

[← Back to README](README.md) | [Prerequisites →](PREREQUISITES.md) | [Lab 00 →](labs/00-target-app/)

</div>
