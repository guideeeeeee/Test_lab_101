#!/bin/bash
# Test VPN Connection Script
# สคริปต์ทดสอบการเชื่อมต่อ VPN

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║    VPN Connection Test Suite          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo

# Configuration
REMOTE_SUBNET="${1:-10.2.0.0/24}"
REMOTE_HOST="${2:-10.2.0.5}"
CONNECTION_NAME="site-to-site-hybrid"

# Test counter
TOTAL_TESTS=0
PASSED_TESTS=0

# Function: Run test
run_test() {
    local test_name=$1
    local test_command=$2
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "[$TOTAL_TESTS] $test_name... "
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC}"
        return 1
    fi
}

# Function: Show test details
show_details() {
    local description=$1
    echo -e "${YELLOW}  → $description${NC}"
}

echo -e "${YELLOW}Running VPN connectivity tests...${NC}"
echo

# ===== Test 1: StrongSwan is running =====
echo -e "${BLUE}─── Service Status ───${NC}"
run_test "StrongSwan daemon running" "pgrep -f charon"

# ===== Test 2: IKE SA established =====
run_test "IKE Security Association" "sudo ipsec status | grep -q 'ESTABLISHED'"

if [ $? -eq 0 ]; then
    show_details "$(sudo ipsec status | grep ESTABLISHED | head -1)"
fi

# ===== Test 3: IPsec SA installed =====
run_test "IPsec tunnel installed" "sudo ipsec status | grep -q 'INSTALLED'"

if [ $? -eq 0 ]; then
    show_details "$(sudo ipsec status | grep INSTALLED | head -1)"
fi

echo

# ===== Test 4: PQC algorithm in use =====
echo -e "${BLUE}─── Cryptography ───${NC}"
run_test "Hybrid PQC algorithm active" "sudo ipsec statusall | grep -qE '(MLKEM|X25519MLKEM)'"

if [ $? -eq 0 ]; then
    # Show detailed algorithm info
    local algo_line=$(sudo ipsec statusall | grep -E '(MLKEM|X25519MLKEM)' | head -1)
    show_details "$algo_line"
fi

# ===== Test 5: Certificate validation =====
run_test "Certificate authentication OK" "sudo ipsec statusall | grep -q 'certificate'"

echo

# ===== Test 6: Network connectivity =====
echo -e "${BLUE}─── Network Connectivity ───${NC}"

# Test 6a: Routing
run_test "Route to remote subnet exists" "ip route | grep -q '$REMOTE_SUBNET'"

# Test 6b: XFRM policies
run_test "IPsec policies configured" "sudo ip xfrm policy | grep -q 'proto esp'"

# Test 6c: Ping test
echo -n "[$((TOTAL_TESTS + 1))] Ping remote host ($REMOTE_HOST)... "
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if ping -c 3 -W 2 "$REMOTE_HOST" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    
    # Show latency
    local latency=$(ping -c 1 "$REMOTE_HOST" 2>/dev/null | grep "time=" | awk -F'time=' '{print $2}' | awk '{print $1}')
    show_details "RTT: ${latency}"
else
    echo -e "${RED}✗ FAIL${NC}"
    show_details "Cannot reach remote host via VPN"
fi

echo

# ===== Test 7: Traffic encryption =====
echo -e "${BLUE}─── Traffic Analysis ───${NC}"

echo -n "[$((TOTAL_TESTS + 1))] ESP packets present... "
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# Capture ESP packets for 5 seconds while sending traffic
sudo timeout 5 tcpdump -i any -c 10 esp > /tmp/esp_capture.txt 2>&1 &
TCPDUMP_PID=$!

# Generate traffic
ping -c 5 -i 0.5 "$REMOTE_HOST" >/dev/null 2>&1 || true

# Wait for capture
wait $TCPDUMP_PID 2>/dev/null || true

if grep -q "ESP" /tmp/esp_capture.txt 2>/dev/null; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    
    local packet_count=$(grep "ESP" /tmp/esp_capture.txt | wc -l)
    show_details "Captured $packet_count ESP packets (traffic is encrypted)"
else
    echo -e "${RED}✗ FAIL${NC}"
    show_details "No ESP packets found (traffic may not be encrypted)"
fi

rm -f /tmp/esp_capture.txt

echo

# ===== Test 8: Performance check =====
echo -e "${BLUE}─── Performance ───${NC}"

# Test 8a: Basic throughput
echo -n "[$((TOTAL_TESTS + 1))] Quick throughput test... "
TOTAL_TESTS=$((TOTAL_TESTS + 1))

if command -v iperf3 >/dev/null 2>&1; then
    # Check if iperf3 server is running on remote
    if timeout 5 iperf3 -c "$REMOTE_HOST" -t 3 -J > /tmp/iperf_test.json 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        
        local bitrate=$(jq -r '.end.sum_received.bits_per_second' /tmp/iperf_test.json 2>/dev/null || echo "0")
        local mbps=$(echo "scale=2; $bitrate / 1000000" | bc)
        show_details "Throughput: ${mbps} Mbps"
    else
        echo -e "${YELLOW}⚠ SKIP${NC}"
        show_details "iperf3 server not available on remote"
    fi
    
    rm -f /tmp/iperf_test.json
else
    echo -e "${YELLOW}⚠ SKIP${NC}"
    show_details "iperf3 not installed (optional)"
fi

echo

# ===== Test 9: Dead Peer Detection =====
echo -e "${BLUE}─── Tunnel Health ───${NC}"

run_test "Dead Peer Detection enabled" "sudo ipsec statusall | grep -q 'dpd'"

# ===== Test 10: Rekeying configuration =====
run_test "Automatic rekeying configured" "grep -qE '(ikelifetime=|lifetime=)' /etc/ipsec.conf"

echo

# ===== Summary =====
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Test Summary                 ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo
echo -e "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$((TOTAL_TESTS - PASSED_TESTS))${NC}"
echo

if [ $PASSED_TESTS -eq $TOTAL_TESTS ]; then
    echo -e "${GREEN}✓ All tests passed! VPN is fully functional.${NC}"
    exit 0
elif [ $PASSED_TESTS -ge $((TOTAL_TESTS * 7 / 10)) ]; then
    echo -e "${YELLOW}⚠ Most tests passed. Review failures above.${NC}"
    exit 1
else
    echo -e "${RED}✗ Many tests failed. VPN may not be working correctly.${NC}"
    echo
    echo "Troubleshooting steps:"
    echo "  1. Check logs: sudo journalctl -u strongswan -f"
    echo "  2. Verify config: sudo ipsec statusall"
    echo "  3. Test manually: sudo ipsec up $CONNECTION_NAME"
    echo "  4. Check firewall: sudo iptables -L"
    exit 1
fi
