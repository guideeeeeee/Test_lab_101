# Prerequisites | สิ่งที่ต้องเตรียม

รายละเอียดครบถ้วนของสิ่งที่คุณต้องรู้และเตรียมก่อนเริ่มต้น lab

---

## 📚 Knowledge Prerequisites | ความรู้พื้นฐานที่ต้องมี

### Essential (Required) | จำเป็น

#### 1. Linux Command Line Basics
```bash
# You should be comfortable with:
cd, ls, mkdir, rm, cp, mv       # File operations
cat, less, grep                 # File viewing
chmod, chown                    # Permissions
ps, top, kill                   # Process management
curl, wget                      # Network tools
```

**Self-test:**
```bash
# Can you do these without googling?
mkdir test && cd test
echo "Hello" > file.txt
cat file.txt
cd .. && rm -rf test
```

#### 2. Text Editing
- **Nano** (easiest) - recommended for beginners
- **Vim** or **Emacs** - if you prefer
- Any GUI editor (VS Code, Sublime, etc.)

**Self-test:**
```bash
nano test.txt
# Can you: edit, save (Ctrl+O), exit (Ctrl+X)?
```

#### 3. Basic Networking Concepts
- Understand IP addresses (e.g., 192.168.1.1)
- Know what ports are (e.g., 443 for HTTPS)
- Familiar with client-server model
- Know what HTTP/HTTPS means

### Helpful (But Not Required) | มีจะดีแต่ไม่จำเป็น

- Container concepts (Docker)
- TLS/SSL basics
- Certificate authorities (CA)
- Public/private key concepts
- Benchmarking tools

### Not Required (We'll Teach You!) | ไม่จำเป็น (เราจะสอน!)

- ❌ Cryptography mathematics
- ❌ Quantum computing theory
- ❌ OpenSSL command syntax
- ❌ Performance profiling tools
- ❌ Python programming (for core labs)

---

## 💻 Software Requirements | ซอฟต์แวร์ที่ต้องติดตั้ง

### Operating System | ระบบปฏิบัติการ

#### Option 1: Linux (Recommended) ⭐

**Ubuntu 22.04 LTS** or **Ubuntu 20.04 LTS**
```bash
# Check your version
lsb_release -a
```

**Debian 11 (Bullseye) or 12 (Bookworm)**
```bash
cat /etc/debian_version
```

**Other Linux:** Should work but untested
- Fedora 36+
- Arch Linux
- CentOS Stream 9

#### Option 2: macOS

**macOS 11 (Big Sur) or newer**
```bash
sw_vers
```

Requirements:
- Docker Desktop for Mac
- Homebrew package manager
- Terminal.app or iTerm2

#### Option 3: Windows

**Windows 10/11 with WSL2**

Must install:
1. Windows Subsystem for Linux 2 (WSL2)
2. Ubuntu from Microsoft Store
3. Docker Desktop for Windows

**Setup guide:**
```powershell
# PowerShell as Administrator
wsl --install
wsl --set-default-version 2
```

Then follow Ubuntu instructions in WSL2 terminal.

---

## 🐳 Docker & Docker Compose

### Why Docker?
- Consistent environment across all systems
- No system-wide package conflicts
- Easy cleanup when done
- Pre-compiled binaries included

### Installation

#### Ubuntu/Debian
```bash
# Remove old versions
sudo apt remove docker docker-engine docker.io containerd runc

# Install Docker
sudo apt update
sudo apt install -y docker.io docker-compose

# Start and enable
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group (avoid sudo)
sudo usermod -aG docker $USER

# Logout and login again, or:
newgrp docker

# Test
docker run hello-world
```

#### macOS
```bash
# Install Docker Desktop
# Download: https://www.docker.com/products/docker-desktop/

# Or via Homebrew
brew install --cask docker

# Start Docker Desktop app
open -a Docker

# Wait for it to start, then test
docker run hello-world
```

#### Windows (WSL2)
1. Install Docker Desktop for Windows
2. Enable WSL2 integration in Docker Desktop settings
3. Test in WSL2 Ubuntu terminal:
```bash
docker run hello-world
```

### Verify Installation
```bash
# Check Docker version (need 20.10+)
docker --version
# Expected: Docker version 20.10.x or higher

# Check Docker Compose version (need 1.29+)
docker-compose --version
# Expected: docker-compose version 1.29.x or higher

# Check Docker daemon
docker ps
# Should show empty list or running containers
```

---

## 🐍 Python 3

### Installation

#### Ubuntu/Debian
```bash
sudo apt install -y python3 python3-pip python3-venv
```

#### macOS
```bash
brew install python3
```

#### Windows (WSL2)
```bash
# Usually pre-installed in Ubuntu on WSL
sudo apt install -y python3 python3-pip python3-venv
```

### Verify Installation
```bash
# Check version (need 3.8+)
python3 --version
# Expected: Python 3.8.x, 3.9.x, 3.10.x, or 3.11.x

# Check pip
pip3 --version
```

### Python Packages

Will be installed automatically by setup script:
```
matplotlib>=3.5.0
pandas>=1.5.0
numpy>=1.23.0
jinja2>=3.1.0
pyyaml>=6.0
```

---

## 🔧 Additional Tools

These will be installed by the setup script, but you can install them manually:

### Network Tools
```bash
# Ubuntu/Debian
sudo apt install -y \
    curl \
    wget \
    net-tools \
    dnsutils \
    tcpdump \
    wireshark

# macOS
brew install curl wget wireshark
```

### Build Tools (Optional)
```bash
# Only needed if you want to compile from source
# (labs use pre-compiled binaries)

# Ubuntu/Debian
sudo apt install -y \
    build-essential \
    cmake \
    ninja-build \
    libssl-dev

# macOS
xcode-select --install
brew install cmake ninja
```

---

## 💾 Disk Space Requirements

### Breakdown

| Component | Size | Notes |
|-----------|------|-------|
| Git repository | ~50 MB | Code and docs |
| Docker images | ~2 GB | NGINX, tools, OQS |
| Pre-compiled binaries | ~500 MB | OpenSSL+liboqs |
| Lab data & logs | ~1 GB | Generated during labs |
| Python packages | ~200 MB | Analysis tools |
| **Buffer/temp** | ~6 GB | Build cache, temp files |
| **Total** | **~10 GB** | Recommended: 20 GB |

### Check Available Space
```bash
# Linux/macOS
df -h ~

# Should show at least 10 GB free in home directory
```

---

## 🌐 Network Requirements

### During Setup
- Internet connection required
- Download ~3 GB of data
- Stable connection recommended (avoid mobile hotspot)

### During Labs
- Labs 00-05: Can work offline after setup
- Labs 06-08: May need occasional internet access

### Firewall/Ports

These ports will be used locally:
- **443** - HTTPS (target application)
- **80** - HTTP redirect
- **8080** - Alternative port (if 443 busy)
- **1194** - VPN (Lab 06 only)
- **500/4500** - IPsec (Lab 06 only)

Make sure these ports are not blocked by:
- Corporate firewall
- Antivirus software  
- Other services (Apache, NGINX already running)

```bash
# Check if port is available
sudo lsof -i :443

# If something is using it, stop that service or use alternative port
```

---

## 🧪 Pre-flight Check

Run this before starting labs:

```bash
# 1. Operating System
echo "OS: $(uname -s)"
echo "Version: $(uname -r)"

# 2. Docker
docker --version || echo "❌ Docker not installed"
docker ps &>/dev/null || echo "❌ Docker daemon not running"

# 3. Docker Compose
docker-compose --version || echo "❌ Docker Compose not installed"

# 4. Python
python3 --version || echo "❌ Python3 not installed"
pip3 --version || echo "❌ pip3 not installed"

# 5. Disk space
df -h ~ | grep -E "Avail|Available"

# 6. Network
curl -s https://google.com > /dev/null && echo "✓ Internet OK" || echo "❌ No internet"

# 7. Ports
sudo lsof -i :443 &>/dev/null && echo "⚠️  Port 443 in use" || echo "✓ Port 443 available"
```

### Expected Output
```
OS: Linux
Version: 5.15.0-xx-generic
Docker version 20.10.x, build xxxxx
✓ Docker daemon running
docker-compose version 1.29.x, build xxxxx
Python 3.10.x
pip 22.x.x from /usr/lib/python3/dist-packages/pip (python 3.10)
Avail 25G
✓ Internet OK
✓ Port 443 available
```

---

## 🎓 Recommended Background Reading

Before starting, consider reading (15-20 minutes):

### Must Read
1. [Crypto Basics 101](docs/crypto-basics-101.md) - If you don't know public/private keys
2. [2019 Landscape](docs/2019-landscape.md) - Why we use 2019 standards

### Optional
3. [Algorithms Comparison](docs/algorithms-comparison.md) - Technical details
4. [Glossary](docs/glossary.md) - Technical terms

---

## ⚠️ Common Issues & Solutions

### Issue: "Permission denied" when running Docker
```bash
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Issue: "Port 443 already in use"
```bash
# Solution 1: Stop conflicting service
sudo systemctl stop apache2
sudo systemctl stop nginx

# Solution 2: Change lab port
# Edit labs/00-target-app/docker-compose.yml
# Change "443:443" to "8443:443"
```

### Issue: Python packages won't install
```bash
# Solution: Use virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Issue: Docker Desktop won't start (macOS)
```bash
# Solution: Reset Docker Desktop
# Open Docker Desktop → Preferences → Reset → Reset to factory defaults
```

### Issue: WSL2 kernel too old
```powershell
# Solution: Update WSL2
wsl --update
wsl --shutdown
```

---

## 📞 Getting Help

If you're stuck during setup:

1. **Check [QUICK-START.md](QUICK-START.md)** - Step-by-step guide
2. **Read [Troubleshooting](docs/troubleshooting.md)** - Common problems
3. **Search [GitHub Issues](https://github.com/yourusername/pqcv2/issues)**
4. **Open new issue** with:
   - Your OS and version
   - Error message (full text)
   - What you tried already

---

## ✅ Ready Checklist

Before proceeding to [QUICK-START.md](QUICK-START.md):

- [ ] Operating system: Linux/macOS/WSL2
- [ ] Docker installed and running
- [ ] Docker Compose installed
- [ ] Python 3.8+ installed
- [ ] At least 10 GB free disk space
- [ ] Internet connection available
- [ ] Port 443 available (or alternative ready)
- [ ] Can run: `docker ps`, `python3 --version`
- [ ] Read Crypto Basics 101 (or willing to learn as you go)

---

<div align="center">

**All set? Let's go!** 🚀

[← Back to README](README.md) | [Quick Start →](QUICK-START.md)

</div>
