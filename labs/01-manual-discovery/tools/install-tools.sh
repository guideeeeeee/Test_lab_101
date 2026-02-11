#!/bin/bash

# Tool Installation Script for Lab 01
# Installs testssl.sh, nmap scripts, and other scanning tools

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Lab 01: Installing Scanning Tools"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Install testssl.sh
echo -e "${BLUE}[1/3]${NC} Installing testssl.sh..."
if [ ! -d "testssl.sh" ]; then
    git clone --depth 1 https://github.com/drwetter/testssl.sh.git
    chmod +x testssl.sh/testssl.sh
    echo -e "${GREEN}✓${NC} testssl.sh installed"
else
    echo -e "${GREEN}✓${NC} testssl.sh already installed"
fi

# Install nmap (if not present)
echo -e "${BLUE}[2/3]${NC} Checking nmap..."
if command -v nmap &> /dev/null; then
    echo -e "${GREEN}✓${NC} nmap already installed"
else
    echo "Installing nmap..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y nmap
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install nmap
    fi
    echo -e "${GREEN}✓${NC} nmap installed"
fi

# Install Python dependencies
echo -e "${BLUE}[3/3]${NC} Installing Python dependencies..."
pip3 install --user pyyaml jinja2 &>/dev/null
echo -e "${GREEN}✓${NC} Python dependencies installed"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ All tools installed successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Available tools:"
echo "  • testssl.sh - ./testssl.sh/testssl.sh localhost:443"
echo "  • nmap - nmap --script ssl-enum-ciphers -p 443 localhost"
echo "  • OpenSSL - openssl s_client -connect localhost:443"
echo ""
