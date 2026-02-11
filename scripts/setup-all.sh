#!/bin/bash

# Global Setup Script for PQC Labs
# Sets up all prerequisites and tools for the lab environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Functions
print_header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

print_step() {
    echo -e "${BLUE}[$1/$2]${NC} $3"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Header
print_header "PQC Lab Environment Setup"

# Check current directory
if [ ! -f "README.md" ] || [ ! -d "labs" ]; then
    print_error "Please run this script from the pqcv2 root directory"
    exit 1
fi

TOTAL_STEPS=10

# Step 1: Check OS
print_step 1 $TOTAL_STEPS "Detecting operating system..."
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
    Linux*)
        OS="Linux"
        PKG_MGR="apt-get"
        ;;
    Darwin*)
        OS="macOS"
        PKG_MGR="brew"
        ;;
    *)
        print_warning "Unsupported OS: $OS_TYPE (trying anyway...)"
        OS="Unknown"
        ;;
esac
print_success "OS: $OS"

# Step 2: Check Docker
print_step 2 $TOTAL_STEPS "Checking Docker..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    echo "Please install Docker first:"
    echo "  Linux: sudo apt-get install docker.io"
    echo "  macOS: brew install --cask docker"
    exit 1
fi

if ! docker ps &> /dev/null; then
    print_error "Docker daemon is not running"
    echo "Please start Docker and try again"
    exit 1
fi
print_success "Docker $(docker --version | awk '{print $3}' | tr -d ',')"

# Step 3: Check Docker Compose
print_step 3 $TOTAL_STEPS "Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    print_warning "docker-compose not found, trying docker compose plugin..."
    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed"
        exit 1
    fi
    DOCKER_COMPOSE="docker compose"
else
    DOCKER_COMPOSE="docker-compose"
fi
print_success "$($DOCKER_COMPOSE version --short 2>/dev/null || echo 'installed')"

# Step 4: Check Python
print_step 4 $TOTAL_STEPS "Checking Python..."
if ! command -v python3 &> /dev/null; then
    print_error "Python 3 is not installed"
    exit 1
fi
PYTHON_VERSION=$(python3 --version | awk '{print $2}')
print_success "Python $PYTHON_VERSION"

# Step 5: Check pip
print_step 5 $TOTAL_STEPS "Checking pip..."
if ! command -v pip3 &> /dev/null; then
    print_warning "pip3 not found, installing..."
    if [ "$OS" = "Linux" ]; then
        sudo apt-get update && sudo apt-get install -y python3-pip
    fi
fi
print_success "pip $(pip3 --version | awk '{print $2}')"

# Step 6: Install Python dependencies
print_step 6 $TOTAL_STEPS "Installing Python dependencies..."

# Check if python3-venv is available
if ! python3 -m venv --help &>/dev/null; then
    print_warning "python3-venv not installed, installing..."
    if [ "$OS" = "Linux" ]; then
        sudo apt-get update -qq && sudo apt-get install -y python3-venv python3-full
    else
        print_error "Please install python3-venv manually"
        exit 1
    fi
fi

# Create virtual environment for lab
VENV_DIR="$HOME/.pqc-venv"
if [ ! -d "$VENV_DIR" ]; then
    print_warning "Creating virtual environment at $VENV_DIR..."
    if python3 -m venv "$VENV_DIR"; then
        print_success "Virtual environment created"
    else
        print_error "Failed to create virtual environment"
        exit 1
    fi
fi

# Verify venv exists and activate
if [ ! -f "$VENV_DIR/bin/activate" ]; then
    print_error "Virtual environment activation script not found"
    print_warning "Trying to recreate venv..."
    rm -rf "$VENV_DIR"
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

if [ -f "requirements.txt" ]; then
    pip install --quiet --upgrade pip
    pip install --quiet -r requirements.txt
    print_success "Python packages installed in virtual environment"
else
    print_warning "requirements.txt not found, creating minimal version..."
    cat > requirements.txt << 'EOF'
matplotlib>=3.5.0
pandas>=1.5.0
numpy>=1.23.0
jinja2>=3.1.0
pyyaml>=6.0
requests>=2.28.0
cryptography>=41.0.0
colorama>=0.4.6
psutil>=5.9.0
plotly>=5.14.0
EOF
    pip install --quiet --upgrade pip
    pip install --quiet -r requirements.txt
    print_success "Basic Python packages installed in virtual environment"
fi

# Step 7: Check OpenSSL
print_step 7 $TOTAL_STEPS "Checking OpenSSL..."
if ! command -v openssl &> /dev/null; then
    print_error "OpenSSL is not installed"
    exit 1
fi
OPENSSL_VERSION=$(openssl version | awk '{print $2}')
print_success "OpenSSL $OPENSSL_VERSION"

if [[ "$OPENSSL_VERSION" < "1.1.1" ]]; then
    print_warning "OpenSSL version is old. Some features may not work."
    print_warning "Consider upgrading to OpenSSL 1.1.1 or 3.x"
fi

# Step 8: Check network tools
print_step 8 $TOTAL_STEPS "Checking network tools..."
MISSING_TOOLS=()

if ! command -v curl &> /dev/null; then
    MISSING_TOOLS+=("curl")
fi

if ! command -v wget &> /dev/null; then
    MISSING_TOOLS+=("wget")
fi

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    print_warning "Missing tools: ${MISSING_TOOLS[*]}"
    if [ "$OS" = "Linux" ]; then
        echo "Installing missing tools..."
        sudo apt-get update && sudo apt-get install -y "${MISSING_TOOLS[@]}"
    elif [ "$OS" = "macOS" ]; then
        echo "Please install: brew install ${MISSING_TOOLS[*]}"
    fi
fi
print_success "Network tools OK"

# Step 9: Check disk space
print_step 9 $TOTAL_STEPS "Checking disk space..."
if [ "$OS" = "Linux" ] || [ "$OS" = "macOS" ]; then
    AVAILABLE=$(df -BG . | tail -1 | awk '{print $4}' | tr -d 'G')
    if [ "$AVAILABLE" -lt 10 ]; then
        print_warning "Low disk space: ${AVAILABLE}GB available (recommend 20GB+)"
    else
        print_success "${AVAILABLE}GB available"
    fi
fi

# Step 10: Pull Docker images
print_step 10 $TOTAL_STEPS "Pulling required Docker images..."
echo "This may take a few minutes..."
docker pull nginx:1.18-alpine &>/dev/null &
docker pull mysql:5.7 &>/dev/null &
wait
print_success "Docker images ready"

# Summary
print_header "Setup Complete!"

echo "Environment summary:"
echo "  • OS: $OS"
echo "  • Docker: $(docker --version | awk '{print $3}' | tr -d ',')"
echo "  • Python: $PYTHON_VERSION (venv at ~/.pqc-venv)"
echo "  • OpenSSL: $OPENSSL_VERSION"
echo ""
echo -e "${YELLOW}IMPORTANT:${NC} Activate Python virtual environment before labs:"
echo -e "  ${GREEN}source ~/.pqc-venv/bin/activate${NC}"
echo ""
echo "Next steps:"
echo "  1. source ~/.pqc-venv/bin/activate  # Activate venv"
echo "  2. cd labs/00-setup"
echo "  3. ./setup.sh"
echo "  4. Follow lab instructions"
echo ""
echo -e "${BLUE}TIP:${NC} Add to ~/.bashrc for auto-activation:"
echo -e "  echo 'source ~/.pqc-venv/bin/activate' >> ~/.bashrc"
echo ""
echo "For help: cat QUICK-START.md"
echo ""

# Create environment info file
cat > .env-info << EOF
SETUP_DATE=$(date +%Y-%m-%d)
OS=$OS
PYTHON_VERSION=$PYTHON_VERSION
PYTHON_VENV=$HOME/.pqc-venv
OPENSSL_VERSION=$OPENSSL_VERSION
DOCKER_VERSION=$(docker --version | awk '{print $3}' | tr -d ',')
EOF

print_success "Ready to start labs!"
echo ""
